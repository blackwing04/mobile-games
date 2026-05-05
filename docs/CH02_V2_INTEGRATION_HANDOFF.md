# Ch2 v2 整合交接檔（給接手 Claude）

> 此檔目的：之前 Claude 在寫 ch02_school.json 大改時 API timeout 中斷。新對話接手請從這裡開始。

---

## ⚠️ 接手前先讀

1. **canonical 已寫完且是 source of truth**：`docs/scenarios/ch02_school_canonical.md` 內含完整 v2 19+ 場景 narrative + 7 結局 + router 設計
2. **IP_BIBLE 已對齊 Ch1 canon**：`docs/IP_BIBLE.md` 7.1 段（san 70、threshold 50、clue cap 3）
3. **engine 改動已 commit**：`ResourceDef.hidden` 欄位、`scenario_runner._applyEffects` clamp、`ResourceBar` 過濾 hidden — 已在 commit `8be485b`
4. **branch**：`claude/setup-git-repo-464UR`
5. **平台**：Flutter / Dart，只用 Read / Write / Edit / Bash 工具

---

## 🎯 唯一未做的工作：寫 `assets/scenarios/ch02_school.json`

把 `docs/scenarios/ch02_school_canonical.md` 的內容**翻成 JSON**，配上下列規格：

### 1️⃣ 元資料

```json
{
  "_copyright": "Copyright (c) 2026 blackwing04. This work is licensed under the PolyForm Noncommercial License 1.0.0. ...",
  "id": "ch02_school",
  "title": "下課之後",
  "subtitle": "卷二 · 23:47",
  "author": "Joe & Gemini",
  "estimated_minutes": 12,
  "episode": 2,
  "truth_ending_id": "scene_true_rescue",
  "truth_ending_hint": "妳必須識破那通「哥哥」的電話。每次擲骰成功都可能讓妳發現一個反差跡象（哥哥從不直呼妳全名 / 電話沒有背景音 / 哥哥不會說「我命令妳」 / 對方知道哥哥不可能知道的事）。收集 ≥3 個線索 + 神智 ≥50 + 中途有傳簡訊給哥哥 + 在天台識破假哥哥 → 哥哥趕到校門口救援的真結局。",
  "start_scene": "scene_start"
}
```

### 2️⃣ 資源

```json
"resources": [
  { "id": "san", "name": "神智", "max": 100, "initial": 70, "icon": "🧠" },
  { "id": "clue", "name": "線索", "max": 3, "initial": 0, "icon": "🔍" },
  { "id": "sms_sent", "name": "簡訊", "max": 1, "initial": 0, "icon": "📱", "hidden": true }
]
```

> `hidden: true` 讓 `ResourceBar` UI 不顯示這條（engine 內部仍追蹤）。`max` 由 `_applyEffects` 自動 clamp。

### 3️⃣ 技能（跨章統一 8 個，妹妹 stat）

```json
"skills": [
  { "id": "observe", "name": "觀察", "value": 60 },
  { "id": "listen", "name": "傾聽", "value": 55 },
  { "id": "lore", "name": "博學", "value": 45 },
  { "id": "stealth", "name": "隱匿", "value": 55 },
  { "id": "athletics", "name": "體育", "value": 50 },
  { "id": "strength", "name": "力量", "value": 40 },
  { "id": "resolve", "name": "意志", "value": 50 },
  { "id": "common_sense", "name": "常識", "value": 55 }
]
```

---

## 4️⃣ 場景清單（共 30 個 — 全部要寫）

> Narrative 全部從 `docs/scenarios/ch02_school_canonical.md` 拷貝（除非下面有額外指示）。Note：JSON 的 `\n\n` 段落分隔 = canonical MD 的空白 `>` blockquote 行。

### A. 入口 + 主線場景（narrative 直接從 canonical 拷）

1. `scene_start` — bgm: `assets/audio/bgm/the_mountain-lonely.mp3`
2. `scene_wait_classroom` — bgm: `building-tension.mp3`
3. `scene_classroom_wake` — bgm: `building-tension.mp3`
4. `scene_door_stuck` — bgm: `building-tension.mp3`
5. `scene_door_stuck_impatient` — bgm: `building-tension.mp3` （narrative 開頭差一句，其他完全同 door_stuck）
6. `scene_phone_again` — bgm: `building-tension.mp3`
7. `scene_phone_again_hide` — bgm: `building-tension.mp3`
8. `scene_phone_again_escape` — bgm: `building-tension.mp3`
9. `scene_phone_again_stairs` — bgm: `building-tension.mp3`（narrative = phone_again 主版**減掉結尾「教室門推開」段** — canonical 已有完整版）
10. `scene_endless_stairs` — bgm: `the_mountain-horror.mp3`
11. `scene_endless_stairs_search` — narrative 100% 同 endless_stairs，僅選項 1 不同
12. `scene_sms_or_call` — bgm: `building-tension.mp3`
13. `scene_dream_intrusion` — bgm: `halloween-bgmkill-me-babydark.mp3`，**純 narrative + next 直接接 scene_lost_sanity**
14. `scene_final_ascent` — bgm: `the_mountain-horror.mp3`
15. `scene_the_climax` — bgm: `the_mountain-horror.mp3`
16. `scene_rejection_and_escape` — bgm: `halloween-bgmkill-me-babydark.mp3`

### B. Detour 場景（接手 Claude 寫短 narrative — 我先給草稿）

17. **`scene_phone_static`** — 觸發：scene_classroom_wake Choice 2 打電話 observe 失敗

```
narrative:
妳顫抖著按下哥哥的號碼，聽筒貼在耳邊。撥號音響了兩聲後，通話接通了。

但聽筒裡傳出的不是哥哥的聲音，而是一陣刺耳的、忽大忽小的電子雜訊。妳隱約聽見背景裡有什麼聲音在說話，那聲音被雜訊撕成碎片，根本聽不清楚。

「⋯⋯哥？」

雜訊瞬間放大成一聲尖銳的嘯叫，妳痛得把手機從耳邊扯開。畫面顯示：通話已結束。

妳僵在原地，背後那種被注視的感覺更強了。

就在這時，手心裡的手機震動了一下。

choices: 無
next: scene_phone_again（直接 → 假哥哥電話打進來）
effects on entry: 由上游 outcome 攜帶 (san-5 / san-15)
```

18. **`scene_monster_glimpse`** — 觸發：scene_door_stuck Choice 3 手電筒 observe 成功

```
narrative:
妳深吸一口氣，按下手電筒鍵。一道慘白的光柱射向教室後排的陰影。

在那一瞬間，妳看見了。

一團蠕動的、濕漉漉的影子蹲在最後一排的課桌之間。它沒有臉，但有什麼東西在它「該是頭部的位置」朝妳轉了過來。妳認得那個輪廓——那是穿著校服的形狀，但比例都錯了，像是被誰把妳的剪影擰歪後重新拼裝的拙劣模仿。

妳本能地關掉手電筒，但那個畫面已經烙在妳的視網膜上。

就在這時，手心裡的手機震動了一下。

choices: 無
next: scene_phone_again（合流主線）
effects on entry: 由上游 outcome 攜帶 (clue+1, san-15)
```

### C. Router 場景（4 個，純條件路由）

19. **`scene_dispatch_clue_check`** — SMS 強制插入點

```json
{
  "narrative": "",
  "conditional_next": [
    { "if_resource_below": { "san": 50 }, "next": "scene_lost_sanity" },
    { "if_resource_at_least": { "clue": 2 }, "next": "scene_dispatch_sms_check" },
    { "default": true, "next": "scene_dispatch_after_sms" }
  ]
}
```

20. **`scene_dispatch_sms_check`** — 看 sms_sent 決定要不要進 SMS scene

```json
{
  "narrative": "",
  "conditional_next": [
    { "if_resource_below": { "sms_sent": 1 }, "next": "scene_sms_or_call" },
    { "default": true, "next": "scene_dispatch_after_sms" }
  ]
}
```

21. **`scene_dispatch_after_sms`** — SMS 結束後折回主流程

```json
{
  "narrative": "",
  "conditional_next": [
    { "if_resource_below": { "san": 50 }, "next": "scene_lost_sanity" },
    { "default": true, "next": "scene_final_ascent" }
  ]
}
```

22. **`scene_dispatch_routeA_truth_check`** — climax 雙軸真結局判定

```json
{
  "narrative": "",
  "conditional_next": [
    { "if_resource_below": { "san": 50 }, "next": "scene_lost_sanity" },
    { "if_resource_at_least": { "clue": 3, "san": 50, "sms_sent": 1 }, "next": "scene_true_rescue" },
    { "default": true, "next": "scene_normal_escape" }
  ]
}
```

> 引擎 `ConditionalNext` 一條規則只能用一個 `if_*`（at_least 或 below 不能混）。但同一條規則內**多個 resource AND 一起判**（看 conditional_next.dart 的 matches() 邏輯）。

### D. 7 結局（narrative 從 canonical 拷）

23. `scene_true_rescue` — type good，title 兄妹重逢，bgm: `melancholic-piano.mp3`
24. `scene_self_break` — type good，title 逃出生天，bgm: `melancholic-piano.mp3`
25. `scene_normal_escape` — type neutral，title 無盡校園，bgm: `sad-strings.mp3`
26. `scene_rescued` — type neutral，title 餘震，bgm: `sad-strings.mp3`
27. `scene_lost_soul` — type bad，title 失神，bgm: `halloween-bgmkill-me-babydark.mp3`
28. `scene_lost_sanity` — type bad，title 留校生，bgm: `feedeorfano-terror.mp3`
29. `scene_curse_spread` — type bad，title 下一個，bgm: `feedeorfano-terror.mp3`

---

## 5️⃣ Routing 全表（每個選項的 next + effects）

> san initial 70；effects 已 calibrate；engine 自動 clamp 到 ResourceDef.max（clue 不會超過 3）。

### scene_start (3 直接型)

1. 「聽哥哥的話，留在教室等他」 → `scene_wait_classroom`
2. 「電話和時鐘都太奇怪了，出去找哥哥」 → `scene_endless_stairs_search`
3. 「我又不是小孩子了，有什麼事回家再講不行喔，直接回家」 → `scene_door_stuck_impatient`

### scene_wait_classroom (3 檢定)

1. 「走過去仔細看那個掛鐘到底怎麼了」 — observe
   - critical_success → scene_phone_again [clue+2, san-3]
   - success → scene_phone_again [clue+1, san-5]
   - partial → scene_phone_again [san-10]
   - failure → scene_phone_again [san-8]
   - fumble → scene_phone_again [san-20]
2. 「這地方待不下去，不等了，立刻離開教室」 — strength
   - critical_success → scene_endless_stairs [san-5]
   - success → scene_endless_stairs [san-8]
   - partial → scene_door_stuck [san-10]
   - failure → scene_door_stuck [san-15]
   - fumble → scene_door_stuck [san-20]
3. 「哥哥說過別理會聲音⋯⋯我乾脆趴著睡一下好了」 — common_sense
   - critical_success → scene_classroom_wake [san+5]
   - success → scene_classroom_wake
   - partial → scene_classroom_wake [san-10]
   - failure → scene_dream_intrusion [san-25]
   - fumble → scene_dream_intrusion [san-40]

### scene_classroom_wake (2 檢定)

1. 「不敢再待下去了，用盡全力撞開門衝出去！」 — strength
   - critical_success → scene_endless_stairs
   - success → scene_endless_stairs [san-5]
   - partial → scene_door_stuck [san-10]
   - failure → scene_door_stuck [san-15]
   - fumble → scene_door_stuck [san-20]
2. 「冷靜點，先打電話給哥哥問他在哪」 — observe
   - critical_success → scene_phone_again [clue+1]
   - success → scene_phone_again
   - partial → scene_phone_static [san-5]
   - failure → scene_phone_static [san-5]
   - fumble → scene_phone_static [san-15]

### scene_door_stuck（**和 scene_door_stuck_impatient 共用同樣 3 選項 + routing**）

1. 「後門打不開就去前門！用盡全身力氣去撞！」 — strength
   - critical_success → scene_phone_again_escape
   - success → scene_phone_again_escape [san-5]
   - partial → scene_phone_again_escape [san-15]
   - failure → scene_curse_spread [san-25]
   - fumble → scene_curse_spread [san-40]
2. 「別管門了，快躲進最近的課桌底下！」 — stealth
   - critical_success → scene_phone_again_hide
   - success → scene_phone_again_hide [san-5]
   - partial → scene_phone_again_hide [san-15]
   - failure → scene_curse_spread [san-25]
   - fumble → scene_curse_spread [san-40]
3. 「（強壓恐懼）是誰在那裡？打開手機手電筒照過去！」 — observe
   - critical_success → scene_monster_glimpse [clue+1, san-15]
   - success → scene_monster_glimpse [san-15]
   - partial → scene_monster_glimpse [san-25]
   - failure → scene_curse_spread [san-25]
   - fumble → scene_curse_spread [san-40]

### scene_phone_again（主版，3 個）

1. 「（質問）你剛才不是叫我別出去嗎？為什麼現在又要我去天台？」 — observe
   - critical_success → scene_dispatch_clue_check [clue+2]
   - success → scene_dispatch_clue_check [clue+1]
   - partial → scene_dispatch_clue_check [san-10]
   - failure → scene_dispatch_clue_check [san-10]
   - fumble → scene_dispatch_clue_check [san-20]
2. 「（求救）哥！這學校不對勁！你快點過來接我！」 → scene_dispatch_clue_check
3. 「好，我現在上去找你⋯⋯（放下手機，神情恍惚）」 → scene_dispatch_clue_check [san-25]

### scene_phone_again_hide / scene_phone_again_escape（2 個共用 2 選項）

1. 「（警戒）哥哥給人感覺怪怪的，但好像只能衝出去了。」 — resolve
   - critical_success → scene_dispatch_clue_check [clue+1, san+5]
   - success → scene_dispatch_clue_check [clue+1]
   - partial → scene_dispatch_clue_check [san-10]
   - failure → scene_curse_spread [san-25]
   - fumble → scene_curse_spread [san-40]
2. 「（前進）相信哥哥，跟他拚了。」 — resolve
   - critical_success → scene_dispatch_clue_check
   - success → scene_dispatch_clue_check [san-5]
   - partial → scene_dispatch_clue_check [san-15]
   - failure → scene_curse_spread [san-30]
   - fumble → scene_curse_spread [san-45]

### scene_phone_again_stairs（同 phone_again 主版的 3 選項 + routing）

選項與 routing 跟 scene_phone_again 主版完全相同。

### scene_endless_stairs / scene_endless_stairs_search（2 變體）

```
scene_endless_stairs:
  1. 「轉念聽哥哥的話，去天台找他」 → scene_phone_again_stairs [san-5]
  2. 「打破旁邊的火災警鈴求救」 → scene_rescued [san-5]

scene_endless_stairs_search:
  1. 「直接打給哥哥確認」 → scene_phone_again_stairs [san-5]
  2. 「打破旁邊的火災警鈴求救」 → scene_rescued [san-5]
```

### scene_sms_or_call (2 直接)

1. 「（傳簡訊）你在哪？我在學校等你，但學校好像有點詭異。」 → scene_dispatch_after_sms [sms_sent+1]
2. 「（撥打電話）還是再打一次確認看看，這次我要聽清楚一點。」 → scene_dispatch_after_sms [san-5]

### scene_dream_intrusion （無選項，純過場）

```json
{
  "narrative": "[從 canonical 拷]",
  "conditional_next": [
    { "default": true, "next": "scene_lost_sanity" }
  ]
}
```

### scene_final_ascent (2 檢定)

1. 「（止步）你剛才不是說你在校門口？為什麼現在在這裡？」 — observe
   - critical_success → scene_the_climax [clue+2]
   - success → scene_the_climax [clue+1]
   - partial → scene_the_climax [san-10]
   - failure → scene_the_climax [san-10]
   - fumble → scene_the_climax [san-20]
2. 「（觀察）先不要靠近，觀察周圍。」 — listen
   - critical_success → scene_the_climax [clue+2]
   - success → scene_the_climax [clue+1]
   - partial → scene_the_climax [san-10]
   - failure → scene_the_climax [san-10]
   - fumble → scene_the_climax [san-20]

### scene_the_climax (3 個，2 直接 + 1 檢定)

1. 「你不是我哥⋯⋯（根據線索識破謊言）」 — `require_resource_at_least: {"clue": 2}` → scene_rejection_and_escape [clue+1, san+10]
2. 「相信眼前的哥哥」 → scene_lost_soul [san-50]
3. 「（閉上眼大喊）這一切都是假的！通通消失！」 — resolve
   - critical_success → scene_self_break [san+15]
   - success → scene_dispatch_routeA_truth_check [san+5]
   - partial → scene_lost_sanity [san-30]
   - failure → scene_lost_sanity [san-50]
   - fumble → scene_lost_sanity [san-70]

### scene_rejection_and_escape (1 檢定)

1. 「（逃跑）什麼都不要看，拼命往光亮的地方跑！」 — athletics
   - critical_success → scene_dispatch_routeA_truth_check [san+5]
   - success → scene_dispatch_routeA_truth_check
   - partial → scene_normal_escape [san-15]
   - failure → scene_lost_sanity [san-30]
   - fumble → scene_lost_sanity [san-50]

---

## 6️⃣ 7 結局結構（標準 JSON shape）

```json
"scene_true_rescue": {
  "bgm": "assets/audio/bgm/melancholic-piano.mp3",
  "narrative": "",
  "ending": {
    "type": "good",
    "title": "兄妹重逢",
    "description": "[從 canonical 拷整段 narrative]"
  }
}
```

7 結局的 type / title / bgm 對照（narrative 全部從 canonical MD 拷）：

| ID | type | title | bgm |
|----|------|-------|-----|
| scene_true_rescue | good | 兄妹重逢 | melancholic-piano.mp3 |
| scene_self_break | good | 逃出生天 | melancholic-piano.mp3 |
| scene_normal_escape | neutral | 無盡校園 | sad-strings.mp3 |
| scene_rescued | neutral | 餘震 | sad-strings.mp3 |
| scene_lost_soul | bad | 失神 | halloween-bgmkill-me-babydark.mp3 |
| scene_lost_sanity | bad | 留校生 | feedeorfano-terror.mp3 |
| scene_curse_spread | bad | 下一個 | feedeorfano-terror.mp3 |

---

## 7️⃣ 完成後的步驟

```bash
# 1. flutter analyze (預期 0 issues)
flutter analyze

# 2. flutter test (預期 36 全綠)
flutter test

# 3. 如果 tests fail，可能 update tests:
#    - test/engine/scenario_runner_test.dart 第 132 行 `_runScenarioIntegrityChecks('ch02_school', ch02);` — 該 test 自動驗 routing / skill / 5 階 outcome / dispatcher default
#    - 注意 truth_dispatch_test.dart 只跑 ch01_office, 不會影響

# 4. commit + push
git add -A && git commit -m "ch02 v2 完整整合 — 純 v2 命名 7 結局 + SMS 機制 + 全局兜底" && git push origin claude/setup-git-repo-464UR
```

---

## 8️⃣ Sanity check 清單（寫完 JSON 自審）

- [ ] 元資料：truth_ending_id = `scene_true_rescue`，episode = 2，san initial 70
- [ ] resources 三個：san / clue (max 3) / sms_sent (hidden true)
- [ ] skills 八個（observe / listen / lore / stealth / athletics / strength / resolve / common_sense）值對應妹妹 stat
- [ ] 30 個 scene id 都存在（包含 4 個 dispatcher）
- [ ] 所有選項的 next / outcome.next 都指向實際存在的 scene id
- [ ] 所有 skill_check 引用的 skill id 都在 skills 表中
- [ ] 所有 dispatcher 都有 `"default": true` 兜底規則
- [ ] 所有 dispatcher 第一條 rule 都是 `if_resource_below: {san: 50} → scene_lost_sanity`（除了 dispatch_sms_check）
- [ ] scene_the_climax Choice 1 識破有 `require_resource_at_least: {"clue": 2}`（玩家 clue < 2 時看不到此選項）
- [ ] scene_dream_intrusion 是 router-style（無 narrative + conditional_next default）
- [ ] scene_phone_again_stairs narrative = scene_phone_again 主版**減掉結尾「教室門推開」段**
- [ ] scene_door_stuck_impatient narrative 開頭「妳不耐煩的⋯⋯準備離開教室」（vs door_stuck「⋯⋯離開這間讓妳越來越不安的空間」）
- [ ] scene_endless_stairs / scene_endless_stairs_search narrative 100% 同
- [ ] flutter test 36 全綠

---

## 📁 重要檔案

- `assets/scenarios/ch02_school.json` — **這個就是要寫的目標**
- `docs/scenarios/ch02_school_canonical.md` — narrative source
- `docs/IP_BIBLE.md` — IP canon 規則
- `lib/engine/runtime/scenario_runner.dart` — clamp 邏輯（已 commit）
- `lib/engine/models/resource.dart` — hidden 欄位（已 commit）

## 🌳 git 現況

- branch: `claude/setup-git-repo-464UR`
- last commit: `8be485b` (engine + IP_BIBLE + canonical 對齊)
- 還沒 push：無（都已 push）
- 工作目錄：clean

接手 Claude 接續寫 `assets/scenarios/ch02_school.json`，跑 test，commit + push 即完成。

加油。
