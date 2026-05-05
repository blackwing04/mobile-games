# Ch2 v2 故事流程地圖（Gemini 對齊用）

> 📌 **這份文件是 Ch2 v2 目前的故事推進狀態快照。**
> 用途：給 Gemini 隨時對照「現在我寫到哪、上一個場景是什麼、下一個該寫什麼」— 不靠 Gemini 自己記憶。
>
> 圖例：
> - ✅ v2 已寫完
> - 🔁 v1 既有 narrative（v2 可沿用或重寫）
> - ⏳ 待寫（Gemini 工作）
> - 🛠️ 整合期我自己處理（Gemini 不必管）

---

## 一、Route A 主線流程（已打通 — Gemini 不必再動）

```
scene_start ✅
  │
  ├─ Choice 1「聽哥哥的話留教室」 (直接)
  │       │
  │       ▼
  │   scene_wait_classroom ✅
  │       ├─ Choice 1「走過去看時鐘」 (observe 檢定)
  │       │       └─ 任何 outcome → scene_phone_again [effects 不同]
  │       │
  │       ├─ Choice 2「立刻離開教室」 (strength 檢定)
  │       │       ├─ 成功 → scene_corridor_search 🔁 (進 Route B 流程)
  │       │       └─ 失敗 → scene_door_stuck ✅
  │       │
  │       └─ Choice 3「趴著睡覺」 (common_sense 檢定 — 整合期校正)
  │               ├─ 成功 → scene_classroom_wake ✅
  │               └─ 失敗 → 🛠️ 整合期路由（暫定 scene_end_curse_spread）
  │
  ├─ Choice 2「電話和時鐘太奇怪，出去找哥哥」 → scene_corridor_search 🔁 (Route B)
  │
  └─ Choice 3「我又不是小孩子，直接回家」 → scene_leave_school 🔁 (Route C)
```

### Route A 主線（接續 wait_classroom 的 detour）

```
scene_classroom_wake ✅
  ├─ Choice 1「撞開門衝出去」 (strength 檢定)
  │       ├─ 成功 → scene_corridor_search 🔁
  │       └─ 失敗 → scene_door_stuck ✅
  └─ Choice 2「打電話給哥哥」 (observe 檢定)
          ├─ 成功 → scene_phone_again ✅ [clue+1]
          └─ 失敗 → scene_phone_static ⏳ (🛠️ 整合期 1-2 行 + loop back)

scene_door_stuck ✅
  ├─ Choice 1「撞前門」 (strength 檢定)
  │       ├─ 成功 → scene_corridor_search 🔁
  │       └─ 失敗 → scene_door_locked_fate ⏳ (🛠️ 整合期 → scene_bad_ending_lost)
  ├─ Choice 2「躲桌底」 (stealth 檢定)
  │       ├─ 成功 → scene_hide_success ⏳ (🛠️ 整合期 → scene_corridor_search)
  │       └─ 失敗 → scene_hide_fail ⏳ (🛠️ 整合期 → scene_bad_ending_lost)
  └─ Choice 3「手電筒照」 (observe 檢定)
          ├─ 成功 → scene_monster_glimpse ⏳ (🛠️ 整合期 → scene_phone_again 合流)
          └─ 失敗 → scene_phone_drop ⏳ (🛠️ 整合期 → scene_bad_ending_lost)
```

### Route A 結局段（已收齊）

```
scene_phone_again ✅
  └─ 三選項全通 → scene_final_ascent (effects 累積差異)

scene_final_ascent ✅
  └─ 兩選項 4 結果全通 → scene_the_climax (effects 累積差異)

scene_the_climax ✅ (Route A 結局收斂節點)
  ├─ Choice 1「你不是我哥」 (需 clue ≥ 2)
  │       └─ → scene_rejection_and_escape ✅
  │              └─ Agility/athletics 檢定
  │                      ├─ 大失敗/失敗 → scene_bad_ending_lost ✅ (失蹤)
  │                      ├─ 一般成功 → scene_normal_escape ✅ (倖存)
  │                      └─ 條件成功 (clue≥2 AND sms_sent=1) → scene_true_rescue ✅ (真結局)
  │
  ├─ Choice 2「相信眼前的哥哥」 (直接)
  │       └─ → scene_end_lost_soul ✅ (失神 — narrative 已 v2 重寫過)
  │
  └─ Choice 3「閉眼大喊『假的』」 (resolve 檢定)
          ├─ 成功 → ⏳ Gemini 待寫對應結局（暫定 scene_end_safe_home / scene_normal_escape）
          └─ 失敗 → ⏳ Gemini 待寫對應結局（暫定 scene_end_curse_spread）
```

---

## 二、SMS 機制（強制插入，整合期 engine 處理）

**設計**：當玩家拿到 clue 第 2 個的當下，無論在哪個場景，下一步**強制**進 SMS 場景。

```
任何場景 [+clue 後 clue 達到 2 且 sms_sent=0]
  └─ 🛠️ 整合期 dispatcher 強制路由 → scene_sms_or_call
                                                │
                                                ├─ Choice 1「傳簡訊給哥哥」(直接) → 設旗標 sms_sent=1 → 回原本流程
                                                └─ Choice 2「打電話給哥哥」(直接) → 跳訊息「無回應」→ 回原本流程
```

### Gemini 待寫場景

⏳ **scene_sms_or_call** — 妹妹突然感到不對勁的瞬間，2 選：傳簡訊 / 打電話。簡短，1 場。

---

## 三、Route B（找哥哥）— Gemini 待寫 ⏳

### 入口
- `scene_start` Choice 2「電話和時鐘太奇怪，出去找哥哥」
- 或 `scene_wait_classroom` Choice 2 撞門成功
- 或 `scene_classroom_wake` Choice 1 撞門成功
- 或 `scene_door_stuck` Choice 1 撞前門成功

### 流程設計（待 Gemini 寫）

```
scene_corridor_search 🔁 (v1 既有 — Gemini 可重寫成 v2 風格)
  └─ 1-2 場走廊探索（Wave 1 環境異常 — 影子變形 / 走廊變長 / 玻璃倒影）
       │
       ▼
  ⏳ scene_routeB_phone_hook (新)
       │ 「哥哥第二通電話」插入：「我在天台等妳」
       │ scene_start 已埋「別理會任何人的聲音」伏筆，
       │ 玩家在這裡會懷疑是真是假
       ▼
  接回 scene_final_ascent (Route A 主線收斂)
```

### Gemini 待寫場景數
- 走廊探索：1-2 場
- 哥哥第二通電話 hook：1 場
- **合計 2-3 場**

---

## 四、Route C（離校）— Gemini 待寫 ⏳

### 入口
- `scene_start` Choice 3「我又不是小孩子，直接回家」

### 流程設計（待 Gemini 寫）

```
scene_leave_school 🔁 (v1 既有 — Gemini 可重寫成 v2 風格)
  │ 校門口氛圍場景（夕陽過濃、街上太安靜的詭異感）
  ▼
⏳ scene_routeC_phone_hook (新)
  │ 「哥哥第二通電話」插入
  ├─ Choice「相信回頭」 → 接 scene_final_ascent (Route A 主線)
  └─ Choice「不信繼續走」 → scene_normal_escape ✅ (倖存)
```

### Gemini 待寫場景數
- 校門口場景：1 場（可沿用 v1 narrative 重寫）
- 哥哥第二通電話 hook：1 場
- **合計 1-2 場**

---

## 五、結局清單

| Scene ID | 名稱 | 主要觸發路徑 | 狀態 |
|----------|------|-------------|------|
| `scene_end_truth` (= scene_true_rescue) | 真結局《兄妹重逢》 | rejection_and_escape 條件成功 (clue≥2 + sms_sent) | ✅ v2 |
| `scene_end_lost_soul` | 失神《跟著哥哥跳》 | climax Choice 2「相信哥哥」 | ✅ v2 重寫 |
| `scene_end_safe_home` (= scene_normal_escape) | 平安回家 | (a) Route C 不信電話 (b) climax Choice 3 成功 | ✅ v2 + 🔁 v1 |
| `scene_end_lost_school` (= scene_bad_ending_lost) | 失蹤 | rejection_and_escape 失敗 / detour 失敗 | ✅ v2 |
| `scene_end_curse_spread` 🔁 | 下一個 | (a) wait_classroom 趴睡失敗 (b) climax Choice 3 失敗 | 🔁 v1 narrative |
| `scene_end_rescued` 🔁 | 校警救援 | Route B 探索失敗收尾？ | ⏳ 對應路徑待設計 |
| `scene_end_self_break` 🔁 | 自己走出去 | Route C 拒接電話 + 識破？ | ⏳ 對應路徑待設計 |

---

## 六、待寫場景總清單（給 Gemini 的工作單）

### 🔥 真的需要 Gemini 寫的（4-6 場）

| 場景 ID | 用途 | 預估長度 |
|---------|------|---------|
| `scene_sms_or_call` | SMS 機制中介（Choice 1 傳簡訊 / Choice 2 打電話） | 1 場（短）|
| Route B 走廊探索 (1-2 場) | Wave 1 走廊異常 + 為什麼進天台 | 1-2 場 |
| Route B 「哥哥第二通電話」hook | 把玩家從 Route B 拉回主線 | 1 場 |
| Route C 校門口場景 | 氛圍鋪陳 | 1 場（可重寫 v1）|
| Route C 「哥哥第二通電話」hook | 玩家二選 — 信回頭 / 不信繼續走 | 1 場 |

### 🛠️ 整合期我自己處理（不勞 Gemini）

- 8 個未定義 detour 場景（door_locked_fate / hide_* / monster_glimpse / phone_drop / phone_static / scare_clock）→ 大多直 route 到既有結局
- 4 個 router 場景（scene_dispatch_clue_check / scene_dispatch_routeA_truth_check / scene_dispatch_route_b / scene_dispatch_route_c）
- 隱藏 resource `sms_sent`（hidden flag 不顯示在 UI）
- skill ID rename（agility → athletics、willpower → resolve）
- 5 階 outcome 補完（Gemini 多寫 2-3 階）

---

## 七、目前 Route 完整路徑表（給 Gemini 看自己的進度）

| 路徑 | 從 → 到 | 場景數 | 狀態 |
|------|--------|--------|------|
| Route A 主線 → 真結局 | start → wait_classroom → phone_again → final_ascent → climax → rejection → true_rescue | 7 | ✅ 全寫 |
| Route A → 失神 | start → wait_classroom → ... → climax → end_lost_soul | 6 | ✅ 全寫 |
| Route A → 失蹤 | start → wait_classroom → ... → climax → rejection → bad_ending_lost | 7 | ✅ 全寫 |
| Route A → 倖存 | start → wait_classroom → ... → climax → rejection → normal_escape | 7 | ✅ 全寫 |
| Route A 趴睡 detour | start → wait_classroom → classroom_wake → 撞門 / 打電話 → 主線 | +1-2 | ✅ 寫 |
| Route A 撞門 detour | start → wait_classroom → door_stuck → 3 選項 | +1 | ✅ 寫（next 整合期處理）|
| **Route B**（找哥哥）| start → corridor_search → ??? → final_ascent | **2-3 場** | ⏳ Gemini |
| **Route C**（離校）| start → leave_school → phone_hook → final_ascent / normal_escape | **1-2 場** | ⏳ Gemini |
| **SMS 機制**（強制插入）| 任何場景 [clue=2] → sms_or_call → 回原流程 | **1 場** | ⏳ Gemini |

---

## 八、Gemini 下一步建議

按優先順序：

1. **先寫 scene_sms_or_call**（短，1 場，補真結局必需條件）
2. **再寫 Route C**（最簡單，2 場，可大幅重用 v1 場景設定）
3. **最後寫 Route B**（2-3 場，較複雜因為要處理走廊探索氛圍）

寫完這 3 段，Ch2 v2 就完整了，整合期我接手做：
- 把 v2 draft 內容掃描合併到 ch02_school.json
- 補 5 階 outcome / 統一 skill ID / 補 router / 處理 SMS dispatcher
- 清理沒用到的 detour 未定義場景
- flutter test + 跑一次 web 預覽
