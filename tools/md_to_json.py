#!/usr/bin/env python3
"""md_to_json.py — 把劇本 Markdown 轉換為遊戲引擎的 JSON。

用途：MD-first 工作流的解析器。Gemini 只輸出 MD，這個工具把 MD 轉成
引擎能讀的 JSON，並自動補 image 路徑、_copyright、結構驗證。

用法：
    python3 tools/md_to_json.py docs/scenarios/foo.md assets/scenarios/foo.json
    python3 tools/md_to_json.py docs/scenarios/foo.md  # stdout

範例 MD 格式請見：docs/scenarios/demo_office_canonical.md
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

OUTCOME_CN_TO_KEY = {
    "大成功": "critical_success",
    "成功": "success",
    "代價成功": "partial",
    "失敗": "failure",
    "大失敗": "fumble",
}

ENDING_CN_TO_TYPE = {
    "好結局": "good",
    "中性結局": "neutral",
    "壞結局": "bad",
}

DEFAULT_COPYRIGHT = (
    "Copyright (c) 2026 blackwing04. Licensed under PolyForm Noncommercial 1.0.0. "
    "Commercial use prohibited without written permission. See LICENSE and NOTICE."
)


class ParseError(Exception):
    pass


def parse_meta(section: str) -> dict:
    """解析「元資料」段 — 形如 `- ID: foo`"""
    out: dict = {}
    for line in section.splitlines():
        m = re.match(r"^\s*-\s*([^:：]+)[:：]\s*(.+?)\s*$", line)
        if not m:
            continue
        key = m.group(1).strip().lower()
        val = m.group(2).strip()
        if key == "id":
            out["id"] = val
        elif key in ("作者", "author"):
            out["author"] = val
        elif key in ("預估時長", "minutes"):
            num = re.search(r"\d+", val)
            if num:
                out["estimated_minutes"] = int(num.group())
        elif key in ("起始場景", "start_scene"):
            out["start_scene"] = val
        elif key in ("標題", "title"):
            out["title"] = val
    return out


def parse_table(section: str) -> list[dict]:
    """解析 Markdown 表格，回傳 list of {欄名: 值}"""
    rows = []
    lines = [l.rstrip() for l in section.splitlines() if l.strip().startswith("|")]
    if len(lines) < 2:
        return rows
    headers = [c.strip() for c in lines[0].strip("|").split("|")]
    for line in lines[1:]:
        cells = [c.strip() for c in line.strip("|").split("|")]
        if all(re.match(r"^[-:\s]+$", c) for c in cells):  # divider
            continue
        if len(cells) != len(headers):
            continue
        rows.append(dict(zip(headers, cells)))
    return rows


def parse_resources(section: str) -> list[dict]:
    out = []
    for r in parse_table(section):
        item = {
            "id": r.get("ID", "").strip(),
            "name": r.get("名稱", "").strip(),
            "icon": r.get("圖示", "").strip(),
        }
        try:
            item["initial"] = int(r.get("起始", "0"))
        except ValueError:
            item["initial"] = 0
        max_val = r.get("上限", "-").strip()
        if max_val and max_val not in ("-", "—", "無", "null"):
            try:
                item["max"] = int(max_val)
            except ValueError:
                pass
        out.append(item)
    return out


def parse_skills(section: str) -> list[dict]:
    out = []
    for r in parse_table(section):
        try:
            value = int(r.get("數值", "0"))
        except ValueError:
            value = 0
        out.append(
            {
                "id": r.get("ID", "").strip(),
                "name": r.get("名稱", "").strip(),
                "value": value,
            }
        )
    return out


def parse_blockquote(text: str) -> str:
    """把連續 `> xxx` 轉成段落（空行分段）"""
    paragraphs: list[str] = []
    current: list[str] = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith(">"):
            content = stripped.lstrip(">").strip()
            if content:
                current.append(content)
            else:
                if current:
                    paragraphs.append("".join(current))
                    current = []
        else:
            if not stripped and current:
                paragraphs.append("".join(current))
                current = []
            elif stripped and not current:
                # 第一條非 blockquote 內容後就停止（避免誤抓選項）
                if paragraphs or current:
                    break
                continue
    if current:
        paragraphs.append("".join(current))
    return "\n\n".join(paragraphs)


def parse_effects(text: str) -> list[dict]:
    """解析 [clue+2] 或 [san-10, clue+1] 形式"""
    m = re.search(r"\[([^\]]+)\]", text)
    if not m:
        return []
    out = []
    for token in m.group(1).split(","):
        token = token.strip()
        m2 = re.match(r"^([\w]+)\s*([+-]?\d+)$", token)
        if m2:
            out.append({"resource": m2.group(1), "delta": int(m2.group(2))})
    return out


def parse_choices_block(text: str, skill_ids: set[str]) -> list[dict]:
    """解析「選項：」之後的整段。回傳 choice dict 列表。"""
    # 切成每個選項一塊（以 `1.` `2.` 開頭）
    choice_blocks: list[list[str]] = []
    current: list[str] = []
    for line in text.splitlines():
        if re.match(r"^\s*\d+\.\s", line):
            if current:
                choice_blocks.append(current)
            current = [line]
        elif current:
            current.append(line)
    if current:
        choice_blocks.append(current)

    choices = []
    for block in choice_blocks:
        choices.append(parse_single_choice(block, skill_ids))
    return choices


def parse_single_choice(lines: list[str], skill_ids: set[str]) -> dict:
    """解析單一選項。

    格式 A（檢定型）：
      1. **「label」** — observe 檢定
         - 大成功 → scene_a [clue+2]
         - 成功 → scene_b
         - 代價成功 → scene_c [san-10]
         - 失敗 → scene_d
         - 大失敗 → scene_e [san-50]

    格式 B（直接型）：
      1. **「label」** → scene_a [san-5]
    """
    first = lines[0]
    label_m = re.search(r"「([^」]+)」", first)
    label = label_m.group(1) if label_m else re.sub(r"^\s*\d+\.\s*", "", first).strip()

    # 嘗試找技能檢定標記
    skill_m = re.search(r"(?:—|--|–)\s*(\w+)\s*(?:檢定|check)", first, re.IGNORECASE)
    if skill_m and skill_m.group(1) in skill_ids:
        skill = skill_m.group(1)
        outcomes: dict = {}
        for line in lines[1:]:
            line = line.strip()
            for cn, key in OUTCOME_CN_TO_KEY.items():
                if line.startswith(f"- {cn}") or line.startswith(f"-{cn}"):
                    rest = line.split(cn, 1)[1]
                    arrow_m = re.search(r"(?:→|->|=>|⇒)\s*(\w+)", rest)
                    if not arrow_m:
                        continue
                    outcome: dict = {"next": arrow_m.group(1)}
                    eff = parse_effects(rest)
                    if eff:
                        outcome["effects"] = eff
                    outcomes[key] = outcome
                    break
        # 5 階完整性驗證
        missing = set(OUTCOME_CN_TO_KEY.values()) - set(outcomes.keys())
        if missing:
            raise ParseError(
                f"選項『{label}』使用 {skill} 檢定但缺少 5 階結果：{missing}"
            )
        return {
            "label": label,
            "skill_check": {"skill": skill, "outcomes": outcomes},
        }

    # 直接型
    arrow_m = re.search(r"(?:→|->|=>|⇒)\s*(\w+)", first)
    choice: dict = {"label": label}
    if arrow_m:
        choice["next"] = arrow_m.group(1)
    eff = parse_effects(first)
    if eff:
        choice["effects"] = eff
    return choice


SCENE_HEADER_RE = re.compile(r"^##\s+([\w_]+)\s*$")
ENDING_HEADER_RE = re.compile(
    r"^##\s+([\w_]+)\s*[—\-–]+\s*(好結局|中性結局|壞結局)\s*《([^》]+)》"
)


def parse_scene_block(block: str, skill_ids: set[str]) -> tuple[str, dict] | None:
    """解析單一場景或結局。block 是 `## scene_xxx ...` 開始的整段文字。"""
    lines = block.strip().splitlines()
    if not lines:
        return None

    header = lines[0]
    body = "\n".join(lines[1:])

    # 嘗試結局格式
    m = ENDING_HEADER_RE.match(header)
    if m:
        scene_id = m.group(1)
        ending_type = ENDING_CN_TO_TYPE[m.group(2)]
        title = m.group(3)
        description = parse_blockquote(body)
        return scene_id, {
            "narrative": "",
            "ending": {
                "type": ending_type,
                "title": title,
                "description": description,
            },
        }

    # 一般場景
    m = SCENE_HEADER_RE.match(header)
    if not m:
        return None
    scene_id = m.group(1)
    narrative = parse_blockquote(body)

    # 找到「選項：」之後的內容
    choices: list[dict] = []
    choices_match = re.search(r"^\s*選項\s*[:：]\s*$", body, re.MULTILINE)
    if choices_match:
        choices_text = body[choices_match.end():]
        choices = parse_choices_block(choices_text, skill_ids)

    scene: dict = {"narrative": narrative}
    if choices:
        scene["choices"] = choices
    return scene_id, scene


def split_scene_blocks(section_text: str) -> list[str]:
    """以 `## ` 為界切出每個場景的文字塊。"""
    blocks: list[str] = []
    current: list[str] = []
    for line in section_text.splitlines():
        if line.startswith("## "):
            if current:
                blocks.append("\n".join(current))
            current = [line]
        elif current:
            # 跳過 horizontal rule 分隔線
            if line.strip() == "---":
                continue
            current.append(line)
    if current:
        blocks.append("\n".join(current))
    return blocks


def find_section(md: str, heading: str, level: int = 2) -> str:
    """擷取 `## {heading}` 到下一個同級 / 更高級 heading 之間的內容。"""
    prefix = "#" * level
    pattern = rf"^{prefix}\s+{re.escape(heading)}\s*$"
    higher_pattern = rf"^#{{1,{level}}}\s+"
    lines = md.splitlines()
    start = None
    for i, line in enumerate(lines):
        if re.match(pattern, line):
            start = i + 1
            break
    if start is None:
        raise ParseError(f"找不到 section: {prefix} {heading}")
    end = len(lines)
    for j in range(start, len(lines)):
        if re.match(higher_pattern, lines[j]):
            end = j
            break
    return "\n".join(lines[start:end])


def parse_md(md: str, *, copyright_text: str = DEFAULT_COPYRIGHT) -> dict:
    """主入口：MD 字串 → scenario dict。"""
    # 標題
    title_m = re.search(r"^#\s+(.+?)\s*$", md, re.MULTILINE)
    title = title_m.group(1).strip() if title_m else "untitled"

    meta = parse_meta(find_section(md, "元資料"))
    resources = parse_resources(find_section(md, "資源"))
    skills = parse_skills(find_section(md, "技能"))
    skill_ids = {s["id"] for s in skills}

    # 場景 + 結局
    scenes: dict[str, dict] = {}
    try:
        scene_section = find_section(md, "場景", level=1)
    except ParseError:
        scene_section = ""
    try:
        ending_section = find_section(md, "結局", level=1)
    except ParseError:
        ending_section = ""

    for block in split_scene_blocks(scene_section + "\n" + ending_section):
        result = parse_scene_block(block, skill_ids)
        if result:
            scene_id, scene_data = result
            scenes[scene_id] = scene_data

    # 自動補 image 路徑
    scenario_id = meta.get("id", "unknown")
    for scene_id, scene_data in scenes.items():
        if "image" not in scene_data:
            scene_data["image"] = (
                f"assets/images/scenarios/{scenario_id}/{scene_id}.webp"
            )

    return {
        "_copyright": copyright_text,
        "id": meta.get("id", scenario_id),
        "title": meta.get("title", title),
        "author": meta.get("author", "unknown"),
        "estimated_minutes": meta.get("estimated_minutes", 10),
        "resources": resources,
        "skills": skills,
        "start_scene": meta.get("start_scene", "scene_start"),
        "scenes": scenes,
    }


def validate(scenario: dict) -> list[str]:
    """跑連結性 / 5 階 / 完整性檢查，回傳錯誤訊息列表。"""
    errors: list[str] = []
    scenes = scenario.get("scenes", {})
    skill_ids = {s["id"] for s in scenario.get("skills", [])}
    resource_ids = {r["id"] for r in scenario.get("resources", [])}
    referenced: set = set()

    # start_scene 必須存在
    if scenario.get("start_scene") not in scenes:
        errors.append(f"start_scene『{scenario.get('start_scene')}』不在 scenes 裡")

    for sid, scene in scenes.items():
        for choice in scene.get("choices", []):
            if "next" in choice and choice["next"]:
                referenced.add(choice["next"])
                if choice["next"] not in scenes:
                    errors.append(f"場景 {sid} → 選項『{choice['label']}』指向不存在的 {choice['next']}")
            if "skill_check" in choice:
                sc = choice["skill_check"]
                if sc["skill"] not in skill_ids:
                    errors.append(f"場景 {sid} → 選項『{choice['label']}』使用未定義技能 {sc['skill']}")
                missing = set(OUTCOME_CN_TO_KEY.values()) - set(sc["outcomes"].keys())
                if missing:
                    errors.append(f"場景 {sid} → 選項『{choice['label']}』缺少 outcomes：{missing}")
                for key, outcome in sc["outcomes"].items():
                    if outcome.get("next"):
                        referenced.add(outcome["next"])
                        if outcome["next"] not in scenes:
                            errors.append(
                                f"場景 {sid} → 選項『{choice['label']}』 {key} 指向不存在的 {outcome['next']}"
                            )
                    for eff in outcome.get("effects", []):
                        if eff["resource"] not in resource_ids:
                            errors.append(
                                f"場景 {sid} → 選項『{choice['label']}』 {key} 使用未定義資源 {eff['resource']}"
                            )

    orphans = set(scenes.keys()) - referenced - {scenario.get("start_scene")}
    if orphans:
        errors.append(f"孤兒場景（沒人引用，玩家走不到）：{sorted(orphans)}")

    return errors


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    src = Path(sys.argv[1])
    md = src.read_text(encoding="utf-8")

    try:
        scenario = parse_md(md)
    except ParseError as e:
        print(f"❌ Parse error: {e}", file=sys.stderr)
        sys.exit(1)

    errors = validate(scenario)
    if errors:
        print("❌ 結構驗證失敗：", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        sys.exit(1)

    json_text = json.dumps(scenario, ensure_ascii=False, indent=2)
    if len(sys.argv) >= 3:
        Path(sys.argv[2]).write_text(json_text, encoding="utf-8")
        print(
            f"✅ 解析成功 → {sys.argv[2]} "
            f"({len(scenario['scenes'])} 場景, {len(scenario['skills'])} 技能, {len(scenario['resources'])} 資源)"
        )
    else:
        print(json_text)


if __name__ == "__main__":
    main()
