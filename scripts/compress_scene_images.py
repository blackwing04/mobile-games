#!/usr/bin/env python3
"""場景圖壓縮腳本 — PNG → WebP

Gemini 出 PNG（每張 4-6 MB）超出規格上限（200 KB）很多。
此腳本批次處理：
  1. 找指定目錄下所有 *.png
  2. 縮到 1280 寬（16:9 自動算高）+ RGBA 合到黑底
  3. 存 WebP quality 82
  4. 同步更新對應 ch__XXX.json 的 image 路徑（.png → .webp）
  5. 刪掉原 PNG

使用方式：
  # 1. 處理特定章節
  python3 scripts/compress_scene_images.py ch02_school

  # 2. 處理特定目錄（絕對 / 相對路徑都可）
  python3 scripts/compress_scene_images.py assets/images/scenarios/ch02_school

  # 3. 處理 assets/images/scenarios/ 下所有章節
  python3 scripts/compress_scene_images.py --all

依賴：Pillow（pip install Pillow）
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("缺少 Pillow。先跑：pip install Pillow", file=sys.stderr)
    sys.exit(1)

REPO_ROOT = Path(__file__).resolve().parent.parent
IMAGES_ROOT = REPO_ROOT / "assets" / "images" / "scenarios"
SCENARIOS_ROOT = REPO_ROOT / "assets" / "scenarios"

TARGET_WIDTH = 1280
WEBP_QUALITY = 82
WEBP_METHOD = 6  # 0-6，越大壓縮率越好（速度越慢）


def resolve_chapter_dir(arg: str) -> Path:
    """支援 'ch02_school' / 'assets/images/scenarios/ch02_school' / 絕對路徑。"""
    p = Path(arg)
    if p.is_absolute() and p.is_dir():
        return p
    if (REPO_ROOT / arg).is_dir():
        return REPO_ROOT / arg
    if (IMAGES_ROOT / arg).is_dir():
        return IMAGES_ROOT / arg
    raise SystemExit(f"找不到目錄：{arg}")


def find_json_for_chapter(chapter_dir: Path) -> Path | None:
    """從 chapter dir 名稱猜對應 JSON。例：ch02_school → assets/scenarios/ch02_school.json"""
    candidate = SCENARIOS_ROOT / f"{chapter_dir.name}.json"
    return candidate if candidate.is_file() else None


def compress_one(src: Path) -> tuple[int, int]:
    """壓縮單張 PNG → WebP，回傳 (原大小, 壓後大小) bytes。"""
    img = Image.open(src)

    # RGBA 合到黑底（manhwa 場景圖底色多為黑）
    if img.mode == "RGBA":
        bg = Image.new("RGB", img.size, (0, 0, 0))
        bg.paste(img, mask=img.split()[-1])
        img = bg
    elif img.mode != "RGB":
        img = img.convert("RGB")

    # 等比縮到 1280 寬（已經 ≤1280 就不動）
    w, h = img.size
    if w > TARGET_WIDTH:
        new_h = int(h * TARGET_WIDTH / w)
        img = img.resize((TARGET_WIDTH, new_h), Image.LANCZOS)

    dst = src.with_suffix(".webp")
    img.save(dst, "WEBP", quality=WEBP_QUALITY, method=WEBP_METHOD)
    src_size = src.stat().st_size
    dst_size = dst.stat().st_size
    src.unlink()
    return src_size, dst_size


def update_json_paths(json_path: Path) -> int:
    """把 JSON 內所有 image / cover_image 欄位的 .png/.jpg/.jpeg → .webp。回傳替換次數。"""
    text = json_path.read_text(encoding="utf-8")
    new_text = text
    count = 0
    for line in text.splitlines():
        if "image" in line and "scenarios/" in line and any(
            ext in line for ext in (".png", ".jpg", ".jpeg")
        ):
            new_line = (line
                        .replace(".png", ".webp")
                        .replace(".jpeg", ".webp")
                        .replace(".jpg", ".webp"))
            new_text = new_text.replace(line, new_line)
            count += 1
    if count > 0:
        json_path.write_text(new_text, encoding="utf-8")
    return count


def process_chapter(chapter_dir: Path) -> None:
    sources = sorted(
        [p for p in chapter_dir.iterdir()
         if p.suffix.lower() in (".png", ".jpg", ".jpeg")]
    )
    if not sources:
        print(f"[{chapter_dir.name}] 沒有 PNG/JPG，略過")
        return

    print(f"\n[{chapter_dir.name}] 找到 {len(sources)} 張原始圖")
    total_src = total_dst = 0
    for src in sources:
        s, d = compress_one(src)
        total_src += s
        total_dst += d
        print(f"  {src.name} → {src.stem}.webp: "
              f"{s/1024:>5.0f} KB → {d/1024:>4.0f} KB "
              f"({d/s*100:>2.0f}%)")

    saved = total_src - total_dst
    print(f"  總計：{total_src/1024:.0f} KB → {total_dst/1024:.0f} KB "
          f"（省 {saved/1024/1024:.1f} MB）")

    json_path = find_json_for_chapter(chapter_dir)
    if json_path:
        count = update_json_paths(json_path)
        print(f"  更新 {json_path.name}：{count} 個 image 路徑改成 .webp")
    else:
        print(f"  ⚠️ 找不到對應 JSON（{chapter_dir.name}.json），請手動更新 image 路徑")


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("target", nargs="?",
                        help="章節 id（ch02_school）/ 路徑 / 不給的話搭配 --all")
    parser.add_argument("--all", action="store_true",
                        help="處理 assets/images/scenarios/ 下所有章節")
    args = parser.parse_args()

    if args.all:
        chapters = sorted(d for d in IMAGES_ROOT.iterdir() if d.is_dir())
        if not chapters:
            print(f"找不到章節目錄於 {IMAGES_ROOT}")
            return
        for ch in chapters:
            process_chapter(ch)
    elif args.target:
        process_chapter(resolve_chapter_dir(args.target))
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
