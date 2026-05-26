#!/usr/bin/env python3
"""BGM 響度標準化 — 兩階段 ffmpeg loudnorm 到 -18 LUFS

不同來源的 BGM 響度差很大（測過範圍 -13 ~ -24 LUFS），切歌會忽大忽小。
這腳本走業界標準 EBU R128 loudness normalization：

  Pass 1: 量原檔的 LUFS / True Peak / Loudness Range
  Pass 2: 用量到的數值算 linear gain offset，校正到 -18 LUFS
  目標 True Peak: -1.5 dBTP（給 SFX 疊播留 headroom）

原檔自動備份到 tools/audio_source/bgm_original/（不打包進 APK），
之後反悔或想換 target LUFS 都能從備份重跑。

使用方式：
  # 標準化所有 BGM
  python3 scripts/normalize_bgm.py

  # 只看現況不動檔（dry run）
  python3 scripts/normalize_bgm.py --dry-run

  # 換 target LUFS
  python3 scripts/normalize_bgm.py --target -20

依賴：ffmpeg 在 PATH
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
BGM_DIR = REPO_ROOT / "assets" / "audio" / "bgm"
BACKUP_DIR = REPO_ROOT / "tools" / "audio_source" / "bgm_original"

DEFAULT_TARGET_LUFS = -18.0
TARGET_TP = -1.5  # True peak ceiling
TARGET_LRA = 11.0  # Loudness range


def run(cmd: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True)


def measure(src: Path, target_lufs: float) -> dict:
    """Pass 1: 量原檔，回傳 ffmpeg loudnorm 的測量 JSON。"""
    result = run([
        "ffmpeg", "-hide_banner", "-nostats", "-i", str(src),
        "-af",
        f"loudnorm=I={target_lufs}:TP={TARGET_TP}:LRA={TARGET_LRA}:print_format=json",
        "-f", "null", "-",
    ])
    stderr = result.stderr
    # ffmpeg 把 JSON 印在 stderr 最後一段
    start = stderr.rfind("{")
    end = stderr.rfind("}")
    if start < 0 or end < 0:
        raise RuntimeError(f"無法解析 ffmpeg 輸出：\n{stderr}")
    return json.loads(stderr[start:end + 1])


def normalize(src: Path, dst: Path, m: dict, target_lufs: float) -> None:
    """Pass 2: 套用測量值，輸出標準化版本。"""
    af = (
        f"loudnorm=I={target_lufs}:TP={TARGET_TP}:LRA={TARGET_LRA}:"
        f"measured_I={m['input_i']}:"
        f"measured_TP={m['input_tp']}:"
        f"measured_LRA={m['input_lra']}:"
        f"measured_thresh={m['input_thresh']}:"
        f"linear=true:print_format=summary"
    )
    # 副檔名決定 encoder
    suffix = dst.suffix.lower()
    if suffix == ".mp3":
        codec_args = ["-codec:a", "libmp3lame", "-b:a", "128k"]
    elif suffix == ".wav":
        codec_args = ["-codec:a", "pcm_s16le"]
    elif suffix in (".ogg", ".opus"):
        codec_args = ["-codec:a", "libvorbis", "-q:a", "5"]
    else:
        codec_args = []  # let ffmpeg 自動選

    result = run([
        "ffmpeg", "-hide_banner", "-nostats", "-y", "-i", str(src),
        "-af", af,
        *codec_args,
        str(dst),
    ])
    if result.returncode != 0:
        raise RuntimeError(f"normalize {src.name} 失敗：\n{result.stderr}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--target", type=float, default=DEFAULT_TARGET_LUFS,
                        help=f"目標 LUFS（預設 {DEFAULT_TARGET_LUFS}）")
    parser.add_argument("--dry-run", action="store_true",
                        help="只量不改檔")
    args = parser.parse_args()

    target = args.target
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    bgm_files = sorted(
        [p for p in BGM_DIR.iterdir()
         if p.is_file() and p.suffix.lower() in (".mp3", ".wav", ".ogg", ".opus")]
    )
    if not bgm_files:
        print(f"找不到 BGM 檔於 {BGM_DIR}")
        sys.exit(1)

    print(f"目標：{target} LUFS, True Peak ≤ {TARGET_TP} dBTP")
    print(f"找到 {len(bgm_files)} 個 BGM 檔\n")

    summary_rows = []
    for src in bgm_files:
        backup = BACKUP_DIR / src.name
        # backup 一次：以後反悔 / 改 target 都從備份重跑
        if not backup.exists() and not args.dry_run:
            shutil.copy2(src, backup)

        # 來源永遠用 backup（如果有，否則第一次跑用 src）
        measure_src = backup if backup.exists() else src

        try:
            m = measure(measure_src, target)
        except Exception as e:
            print(f"❌ {src.name}: {e}")
            continue

        before_i = float(m["input_i"])
        before_tp = float(m["input_tp"])

        if args.dry_run:
            print(f"  {src.name:<55} LUFS={before_i:>+6.1f}  TP={before_tp:>+6.1f}")
            summary_rows.append((src.name, before_i, None))
            continue

        # normalize backup → tmp → atomic replace src
        tmp = src.parent / f"_norm_tmp{src.suffix}"
        try:
            normalize(measure_src, tmp, m, target)
        except Exception as e:
            print(f"❌ {src.name}: {e}")
            if tmp.exists():
                tmp.unlink()
            continue
        tmp.replace(src)

        # 量校正後（從新 src 量）
        after = measure(src, target)
        after_i = float(after["input_i"])
        print(f"  {src.name:<55} "
              f"LUFS {before_i:>+6.1f} → {after_i:>+6.1f}  "
              f"({'+' if after_i - before_i >= 0 else ''}{after_i - before_i:.1f} dB)")
        summary_rows.append((src.name, before_i, after_i))

    if args.dry_run:
        print("\n(dry-run — 沒動檔)")
        return

    print("\n標準化完成。原檔備份在：")
    print(f"  {BACKUP_DIR}")
    print("如果要還原原狀，把 backup 那邊的檔覆蓋回 assets/audio/bgm/ 即可。")


if __name__ == "__main__":
    main()
