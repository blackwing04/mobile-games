#!/usr/bin/env python3
"""json_to_md.py — 把 production JSON 轉成正典 MD。

用途：當你想拿現有劇本給 Gemini 做大幅改寫時，先用這個工具把 JSON
轉成 MD，再丟給 Gemini，他改完用 md_to_json.py 轉回來。

用法：
    python3 tools/json_to_md.py assets/scenarios/foo.json > docs/scenarios/foo.md
"""
import json
import sys
from pathlib import Path

OUTCOME_KEY_TO_CN = {
    "critical_success": "大成功",
    "success": "成功",
    "partial": "代價成功",
    "failure": "失敗",
    "fumble": "大失敗",
}
ENDING_TYPE_TO_CN = {"good": "好結局", "neutral": "中性結局", "bad": "壞結局"}

def fmt_effects(effs):
    if not effs:
        return ""
    parts = []
    for e in effs:
        sign = "+" if e["delta"] >= 0 else ""
        parts.append(f'{e["resource"]}{sign}{e["delta"]}')
    return f' [{", ".join(parts)}]'

def fmt_blockquote(text):
    if not text:
        return ""
    paras = text.split("\n\n")
    out = []
    for i, p in enumerate(paras):
        for line in p.split("\n"):
            out.append(f"> {line}".rstrip())
        if i < len(paras) - 1:
            out.append(">")
    return "\n".join(out)

def main():
    data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    out = []
    out.append(f'# {data["title"]}')
    out.append("")
    out.append("## 元資料")
    out.append("")
    out.append(f'- ID: {data["id"]}')
    out.append(f'- 作者: {data.get("author", "")}')
    out.append(f'- 預估時長: {data.get("estimated_minutes", 10)} 分鐘')
    out.append(f'- 起始場景: {data["start_scene"]}')
    out.append("")
    out.append("## 資源")
    out.append("")
    out.append("| ID | 名稱 | 圖示 | 起始 | 上限 |")
    out.append("| --- | --- | --- | --- | --- |")
    for r in data.get("resources", []):
        max_v = r.get("max", "-")
        out.append(f'| {r["id"]} | {r["name"]} | {r["icon"]} | {r["initial"]} | {max_v} |')
    out.append("")
    out.append("## 技能")
    out.append("")
    out.append("| ID | 名稱 | 數值 |")
    out.append("| --- | --- | --- |")
    for s in data.get("skills", []):
        out.append(f'| {s["id"]} | {s["name"]} | {s["value"]} |')
    out.append("")
    out.append("---")
    out.append("")
    out.append("# 場景")

    scenes = data.get("scenes", {})
    main_scenes = [(sid, s) for sid, s in scenes.items() if not s.get("ending")]
    ending_scenes = [(sid, s) for sid, s in scenes.items() if s.get("ending")]

    for sid, scene in main_scenes:
        out.append("")
        out.append(f"## {sid}")
        out.append("")
        out.append(fmt_blockquote(scene.get("narrative", "")))
        if scene.get("choices"):
            out.append("")
            out.append("選項：")
            out.append("")
            for i, c in enumerate(scene["choices"], 1):
                if "skill_check" in c:
                    sc = c["skill_check"]
                    out.append(f'{i}. **「{c["label"]}」** — {sc["skill"]} 檢定')
                    for key in ["critical_success", "success", "partial", "failure", "fumble"]:
                        outcome = sc["outcomes"].get(key, {})
                        cn = OUTCOME_KEY_TO_CN[key]
                        nxt = outcome.get("next", "?")
                        eff = fmt_effects(outcome.get("effects", []))
                        out.append(f'   - {cn} → {nxt}{eff}')
                else:
                    eff = fmt_effects(c.get("effects", []))
                    out.append(f'{i}. **「{c["label"]}」** → {c.get("next", "?")}{eff}')
        out.append("")
        out.append("---")

    if ending_scenes:
        out.append("")
        out.append("# 結局")
        for sid, scene in ending_scenes:
            ending = scene["ending"]
            cn_type = ENDING_TYPE_TO_CN.get(ending["type"], "結局")
            out.append("")
            out.append(f'## {sid} — {cn_type}《{ending["title"]}》')
            out.append("")
            out.append(fmt_blockquote(ending.get("description", "")))
            out.append("")
            out.append("---")

    print("\n".join(out))

if __name__ == "__main__":
    main()
