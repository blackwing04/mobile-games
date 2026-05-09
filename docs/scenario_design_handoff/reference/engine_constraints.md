# 引擎能力與技術限制（給設計 Claude）

> 這份文件補充 IP_BIBLE 第七章沒展開的引擎細節。設計章節時必須在這個能力範圍內想，超出的功能要先問 user 是否值得加引擎。

---

## 一、scene 三種類型

### 1.1 一般場景
- 有 `narrative`（敘述）+ `choices`（玩家選項）
- 玩家會看到，做選擇推進

### 1.2 結局場景
- 有 `ending: { type, title, description }`
- type = `good` / `neutral` / `bad`（影響上方標籤色）
- 進入結局後沒有選項，只有「再玩一次」/「回主選單」

### 1.3 Router 場景（純條件分流）
- `narrative: ""`、`choices: []`
- 只有 `conditional_next` 規則陣列
- 玩家**看不到**這個 scene — 進入後立刻按條件跳到下個 scene
- 用於：
  - 結局調度（看資源決定走哪個結局）
  - 多入口共用邏輯（多個 phone scene 都導向同一個 dispatch_check）
  - 強制插入步驟（玩家還沒做某動作時強制走某 scene）

> Ch2 用了 4 個 router：`scene_dispatch_clue_check` / `_sms_check` / `_after_sms` / `_routeA_truth_check`

---

## 二、conditional_next 規則

```json
"conditional_next": [
  { "if_resource_below": { "san": 50 }, "next": "scene_lost_sanity" },
  { "if_resource_at_least": { "clue": 3, "san": 50, "sms_sent": 1 }, "next": "scene_truth" },
  { "default": true, "next": "scene_normal" }
]
```

### 2.1 規則
- 依**陣列順序**檢查，第一條符合的決定 next
- 一條規則內**只能用** `if_resource_at_least` **或** `if_resource_below`，**不能混用**
- 同一規則內多個 resource 是 **AND**（全部要滿足）
- 沒有 OR — 要 OR 邏輯就拆成多條規則
- 最後一條建議放 `default: true` 兜底

### 2.2 善用「順序就是優先級」
最常見模式：
```
1. 先檢查 san<50 → 走崩潰結局（最高優先級）
2. 再檢查 clue≥3 + san≥50 + ... → 走真結局
3. default → 走一般結局
```

---

## 三、骰子規則（d100 + 5 階）

每個 skill_check 必須提供**完整 5 個 outcome**：

| key | 對應 |
|-----|-----|
| `critical_success` | 大成功 |
| `success` | 成功 |
| `partial` | 代價成功 |
| `failure` | 失敗 |
| `fumble` | 大失敗 |

### 3.1 outcome 結構
```json
"critical_success": {
  "next": "scene_xxx",
  "effects": [
    { "resource": "clue", "delta": 2 },
    { "resource": "san", "delta": -3 }
  ]
}
```

`effects` 可以同時改多個資源；省略則該 outcome 不改資源。

### 3.2 5 階機率（skill=60 為例）
- 大成功 12% (≤skill/5)
- 成功 48% (skill/5 < roll ≤ skill)
- 代價成功 10% (skill < roll ≤ skill+10，capped 95)
- 失敗 ~25% (skill+10 < roll ≤ 95)
- 大失敗 5% (roll ≥ 96)

### 3.3 設計建議
- 5 階都要有「實質後果」— 不要兩個 outcome 走同個 next 又給同樣 effects（玩家會覺得擲假的）
- 大成功額外給 +clue / +san 當獎勵；大失敗扣較多 san（10-40）
- 失敗 / 大失敗常見：扣 san + 走「次優」分支，不一定立刻 BAD

---

## 四、resource 系統

### 4.1 標準資源（跨章不變）
- `san`（神智）：max 100, initial 70
- `clue`（線索）：max 3, initial 0

### 4.2 hidden flag
專為「內部 routing 旗標」存在。例：
```json
{ "id": "sms_sent", "name": "簡訊", "max": 1, "initial": 0, "hidden": true }
```
- `hidden: true` → 不顯示在 UI ResourceBar
- 用於記錄「玩家做過某事」的布林狀態
- Ch2 用 sms_sent 確認真結局必須有傳簡訊

### 4.3 自動 clamp
引擎會把 effects 結果 clamp 到 `[0, max]`：
- clue max=3，玩家拿到 +2 但已有 clue=2 → 自動截到 3，不會變 4
- san 不會降到 0 以下

---

## 五、choice 可見性條件

### 5.1 require_resource_at_least
```json
"require_resource_at_least": { "clue": 2 }
```
clue ≥ 2 才**顯示**這個選項。低於就藏起來。

### 5.2 hide_if_resource_at_least
```json
"hide_if_resource_at_least": { "clue": 3 }
```
clue ≥ 3 就**藏起來**。

### 5.3 配對使用模式
```
選項 A：擲骰找線索（hide_if clue ≥ 3）
選項 B：直接想清楚（require clue ≥ 3）
```
線索不夠 → 看到 A、線索夠 → 看到 B。

---

## 六、變體家族模式（Variant Family）

多個入口走到「同一個故事節拍」時，可以做出有「視角差異」的多個 scene 變體共用後段邏輯。

### 6.1 用例（Ch2）
phone_again 4 變體：
- `scene_phone_again`（在教室接電話）
- `scene_phone_again_hide`（躲課桌底接電話 — 開頭多一段「妳蜷縮在課桌下…」）
- `scene_phone_again_escape`（撞門出來在走廊接 — 開頭重寫成撞門逃出）
- `scene_phone_again_stairs`（在樓梯間接 — 結尾換場景描述）

### 6.2 設計原則
- **故事節拍核心一致**（電話內容、選項、effects 全相同）
- **只差「玩家此刻在哪」的場景描述**（開頭幾句 / 結尾幾句）
- 共用度建議 60-90%，太低就乾脆寫成不同 scene

---

## 七、音效系統

每個 scene 可以指定：
- `bgm`: 背景音樂 asset 路徑（`assets/audio/bgm/xxx.mp3`），場景間相同就連續播
- `ambient`: 環境聲循環（`assets/audio/sfx/xxx.wav`），間隔由 `ambient_interval_ms` 控制（預設 3000）
- `sfx_on_enter`: 進場一次性 SFX（key 對應 `SfxKey.jsonKey`，例：`elevator_open`）

設計章節時**只要描述氛圍**（例：「壓抑的鋼琴」/「校園悲懼弦樂」），不必指定檔名 — 我會看現有 BGM 庫挑檔。

現有 BGM（檔名透露氛圍）：
- `building-tension.mp3`、`horror-dark.mp3`、`horror-ambience.mp3`
- `entropy-sad-horror-piano-music.mp3`（悲傷 piano）
- `frozen-in-the-nebula-liminal-dark-eerie-space.mp3`（liminal / 樓梯間感）
- `the_mountain-lonely.mp3`、`the_mountain-horror.mp3`
- `per-sempre-noi.mp3`、`melancholic-piano.mp3`、`music-pain.mp3`
- `halloween-bgmkill-me-babydark.mp3`（黑暗夢境）
- `feedeorfano-terror.mp3`（強烈恐懼）
- `flourescent-light_All.wav`（日光燈嗡嗡）
- `sad-strings.mp3`

---

## 八、不能做（不要在設計裡假設）

- ❌ 沒有 inventory 系統（玩家不能撿東西、組合道具）
- ❌ 沒有「跨章節傳遞角色狀態」 — 只有 unlock 旗標跨章
- ❌ choice 內沒有「OR 條件」，只能 AND
- ❌ outcome.effects 不能修改「下個 scene」（next 是固定的，不能根據擲骰再分流）
  - 要分流就走 router scene
- ❌ 沒有「時間流逝」/「連續行動」/「戰鬥回合」系統
- ❌ 沒有對話系統（分支對話樹）— 全部用「敘述 + 選項」表達
- ❌ 沒有 NPC 隨機反應 / 好感度
- ❌ 不能在劇本中嵌入程式碼

需要這些功能 = 引擎升級提案 = 先跟 user 討論值不值得加。
