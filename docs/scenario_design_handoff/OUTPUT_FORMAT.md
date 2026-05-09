# Canonical MD 輸出格式規範

> **這份文件是「劇情設計 Claude 給工程實作 Claude 的交付規格」**。
> 你的最終輸出 = 一份完整可獨立解析的 canonical MD，命名：`chXX_<theme>_canonical.md`（例：`ch03_apartment_canonical.md`）

最權威的範例 = `reference/ch02_canonical.md`。**你的輸出結構應該跟它一樣**。

---

## 必要章節（依此順序）

### 1. 標題與 metadata
```markdown
# 第 X 章「<中文標題>」canonical 劇本

> 卷X · 23:47

| 項目 | 設定 |
|------|------|
| 章節 ID | chXX_<theme> |
| 主角 | <一句話描述> |
| 場景 | <時間 + 地點> |
| 真結局救援者 | <Ch(X-1) 主角> |
| 估時 | <玩一輪約 N 分鐘> |
```

### 2. 故事框架（200-400 字）
- 引子（觸發事件）
- 真相（血咒怎麼運作於這章）
- 真結局條件（玩家要做到什麼）
- 失神結局形式（這章的「自我毀滅」是什麼樣）

### 3. 7 個結局清單
表格格式：
```markdown
| # | 結局 ID | 名稱 | 觸發條件 | mirror 分類 | 情緒底色 |
|---|---------|------|---------|------------|---------|
| 1 | scene_xxx | <中文名> | <條件> | mirror Ch1 真結局 | <一句話> |
```
情緒底色**全部 7 個必須不同**（檢查 CHECKLIST.md）。

### 4. 主決策路線（3 條）
表格 + 簡述。例：
```markdown
| 路線 | 觸發 | 涵蓋結局 |
|------|------|---------|
| A. <名> | <玩家 scene_start 選了什麼> | <結局 ID 列表> |
```

### 5. Resources & Skills

#### Resources
```markdown
| ID | 名稱 | initial | max | hidden | 用途 |
|----|------|---------|-----|--------|------|
| san | 神智 | 70 | 100 | false | 標準 |
| clue | 線索 | 0 | 3 | false | 標準 |
| <flag> | <名> | 0 | 1 | true | <為什麼需要這個 hidden flag> |
```

#### Skills（沿用 8 個既有 ID，初值依主角）
```markdown
| skill_id | 名稱 | 初值 | 為什麼這值 |
|---------|-----|-----|----------|
| observe | 觀察 | 60 | 主角是 X 性格 |
| ... | ... | ... | ... |
```

### 6. 場景詳細（最大區塊）

每個 scene 一個 `## scene_<id>` 標題。**順序大致按玩家流程**。

#### 6.1 一般場景格式
```markdown
## scene_xxx

> 場景圖：<主體 + 氛圍描述，不要構圖細節>
> BGM：<氛圍描述，例：壓抑的鋼琴 / 校園悲懼弦樂 / liminal 樓梯間感>
> （optional）Ambient：<環境聲描述 + 間隔>
> （optional）SFX on enter：<一次性音效，例：電梯開門 / 簡訊提示音>

<narrative 內文，可多段。每段 2-4 句最佳。第二人稱「妳/你」、現在式>

選項：

1. **「<選項標籤>」** — <技能> 檢定
   - 大成功 → scene_yyy [clue+2, san-3]
   - 成功 → scene_yyy [clue+1, san-5]
   - 代價成功 → scene_yyy [san-10]
   - 失敗 → scene_zzz [san-15]
   - 大失敗 → scene_zzz [san-30]

2. **「<選項標籤>」**（**直通**）→ scene_yyy [san-5]

3. **「<選項標籤>」**
   - require: clue ≥ 2
   - direct → scene_yyy [clue+1]
```

#### 6.2 router 場景格式
```markdown
## scene_dispatch_xxx （**Router**）

無 narrative，無選項。依資源條件分流：

1. san < 50 → scene_lost_sanity
2. clue ≥ 3 AND san ≥ 50 AND <flag> ≥ 1 → scene_truth
3. default → scene_normal
```

#### 6.3 結局場景格式
```markdown
## scene_end_xxx （**Ending · good/neutral/bad**）

> 結局圖：<主體 + 氛圍>
> BGM：<氛圍>

ending.title: 「<中文結局名>」
ending.description:

<完整結局描述敘事，2-6 段。第二人稱、現在式或回顧式>
```

#### 6.4 變體家族（Variant family）
如果一組 scene 共用故事節拍但開頭/結尾因玩家位置不同：

```markdown
## scene_phone_again

<完整 narrative + 選項>

## scene_phone_again_hide （**桌底 perspective 變體**）

narrative：開頭多一段「妳蜷縮在課桌下…」其餘與主版相同。
選項：與主版完全共用。
```

> 完整變體清單先寫出主版，後面變體只寫差異即可（**variant override**）。

### 7. 反差跡象（Clue）說明
```markdown
| Clue | 反差跡象 | 觸發場景 | 角色內心 OS |
|------|---------|---------|------------|
| 1 | <反差> | scene_xxx (skill_check 大成功) | 「<想法>」 |
| 2 | <反差> | scene_yyy | 「<想法>」 |
| 3 | <反差> | ... | ... |
| 4（隱藏） | <反差> | <隱藏 detour> | 「<想法>」 |
```

### 8. 視覺 / 音效規範
```markdown
## 視覺 signature

主視覺母題：<例：教室時鐘 + 走廊長影>
配色：沿用 IP 4 色 + <夕陽橘 / 日光燈白 / etc.>
與前章對比：<這章跟 Ch1/Ch2 怎麼區隔>
```

```markdown
## 音效規劃

BGM 整體基調：<一句話>
新增 SFX：<列出該章特有的，例：下課鐘倒退 / 電話響>
共用 SFX：dice / outcome / ui_click（沿用）
```

---

## 必須遵守的格式 convention（很重要）

### A. scene id naming
- 全部 snake_case
- prefix 一律 `scene_`
- 結局 prefix `scene_end_xxx` 或 `scene_<name>`（看 Ch1/Ch2 既有命名風格）
- router prefix `scene_dispatch_<purpose>`
- 變體 suffix：`_hide` / `_escape` / `_stairs` / `_search` / `_revisit` 等（一看就知道是哪個變體）

### B. 選項 effects 表記
固定用方括號 `[resource±N]`：
- `[clue+1]` = clue +1
- `[san-15]` = san -15
- `[clue+2, san+5]` = 兩個一起
- 沒效果就不寫方括號

### C. 條件表記
- `if_resource_at_least`：「clue ≥ 3」
- `if_resource_below`：「san < 50」
- 多條件 AND：「clue ≥ 3 AND san ≥ 50」
- 沒有 OR — 拆成多條規則

### D. 5 階 outcome 必填
**每一個 skill_check 都要寫滿 5 階**。少寫 = 工程實作 Claude 沒法產 JSON。

### E. next 必指明
每個 outcome / 每個直通選項都要有明確的 `→ scene_xxx`。**不能寫「→ TBD」**。

---

## 不要做這些事（會卡到工程實作）

- ❌ 把整個章節寫成散文 — 必須是結構化清單
- ❌ scene id 用中文（例：「教室場景」）— 一律英文 snake_case
- ❌ skill_check 寫「擲一個觀察 60，成功就 +1 線索」— 要寫滿 5 階
- ❌ 用「應該」「可能」「待定」等字眼 — 要明確的 next + effects
- ❌ 在 narrative 裡寫 markdown 標題（例：「## 主角心情：」）— narrative 是純文字段落
- ❌ 不要寫 JSON 範例片段在 MD 裡 — 工程實作會處理 JSON

---

## 完成判準

你的 MD 算「準備好交付」，必須：

1. ✅ 工程實作 Claude 能直接照 MD 產出 JSON，不用回頭問任何「這 outcome 走哪？這扣多少 san？」
2. ✅ 每個 scene 有完整 narrative + 選項 + outcome
3. ✅ 7 個結局都有 description（不是 placeholder）
4. ✅ 跑過 `CHECKLIST.md` 全綠
5. ✅ 所有 scene id 在 next 引用裡都對得上（沒有打錯名 / 漏定義的 scene）

達標就交給 user，user 會傳給工程實作。
