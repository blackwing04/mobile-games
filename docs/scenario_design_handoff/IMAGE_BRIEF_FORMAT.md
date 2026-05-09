# 圖片 Brief 輸出格式（給 Gemini 用）

> **觸發**：當 user 說「我要跟 Gemini 討論畫 ChX 的插畫」/「幫我設計 ChX 的圖片設計稿」/ 類似請求時，啟動本格式。
>
> **輸出**：一份完整可貼進 Gemini 對話框當系統訊息的 MD（命名 `chXX_image_brief.md`）。
> user 把它整段貼到新開的 Gemini 對話 → Gemini 依此逐張產圖。

---

## 你的工作

讀完三份輸入，產出一份 `chXX_image_brief.md`：

| 輸入 | 用途 |
|------|------|
| 該章節 canonical MD（你之前產的 / 既有的） | 知道有哪些 scene 要畫、每個 scene 的氣氛 |
| `reference/IP_BIBLE.md` 第五章「視覺風格」 | IP-wide 視覺 canon（4 色 palette、manhwa 風、人物造型規範）|
| `reference/ch01_image_brief_example.md` | **格式範本**。你的輸出結構要跟它一致 |

---

## 輸出 MD 必含章節（依此順序）

### 1. 任務概述 + 風格一致性 review
- 章節名 + 要產的圖數量
- 如果是「補圖」（Ch1 已 19 張，Ch2 是新的全部 16-20 張）— 區分清楚
- 提醒 Gemini「先打開 Ch1 已完成的 1-2 張對標風格再開始」（風格一致性是產圖最大失敗點）

### 2. 你是誰（給 Gemini 的角色設定）
- 「你是專業恐怖遊戲視覺概念設計師…」
- 心理恐怖 / 留白美學 / 東亞都市怪談 — 強調氛圍營造能力

### 3. 專案背景
- 遊戲類型 / 風格參考 / 設定（時代 + 文化背景）/ 市場 / 結局數量
- 直接抄 Ch1 brief 那段，**該章特殊背景才改寫**（例：Ch2 改成「校園 + 黃昏」）

### 4. 整體風格規範（**全章共用，直接抄 Ch1 brief**）
- manhwa horror style 關鍵詞
- 風格參照作品（Sweet Home / Hellbound / Bastard / Solo Leveling / All of Us Are Dead）
- 質感與線條（黑色塊陰影、粗細變化墨線、二元細節留白、無景深）
- **4 色 palette**（黑 / 米白 / 冷灰 / 血紅）— **不可改**
- manhwa 構圖思維（剪影、過肩、第二人稱 POV）

### 5. 角色鎖定（**該章主要角色清楚定義**）

每個重要角色寫：
- 年齡 / 性別 / 國籍
- 服裝（具體色塊 — 用 4 色 palette 描述）
- 髮型（黑色塊形狀）
- 異象啟動時的視覺特徵（沒有影子 / 空眼窩 / 黑霧 / 血痕等 — 沿用 Ch1 母題）
- 「正常時」vs「異象啟動時」差異

如果該章主角是前章主角的家人 / 朋友（Ch2 妹妹 = Ch1 哥哥），記得：
- 標出血脈關聯
- 髮色 / 五官有家族相似（為了視覺辨識）
- 但服裝 / 性格不同

NPC（救援者：上一章主角）：
- 「跑著趕來、出汗、衣服亂、書包帶子斷」這類「真實人感」要寫進 brief
- 對比幻覺中的乾淨無聲假人

### 6. 技術規格（直接抄 Ch1 brief，**不可改**）
- 16:9 橫向、1920×1080 或 1280×720
- WebP 優先，PNG 接受
- ≤ 200KB
- 不可包含文字 / 字幕 / logo / 浮水印 / AI 簽名

### 7. 命名規則（直接抄）
- 用 scene_id 命名：`scene_xxx.webp`
- 結局圖也是用 scene id 命名

### 8. 禁止事項表（直接抄 Ch1 brief，**全章都禁**）
- 照片寫實 / 3D
- 日系大眼睛 / chibi
- 配色超出 4 色
- 景深模糊
- 過度血腥
- 西方建築 / 西方人
- 白衣長髮女鬼老套造型
- 怪物完整正面
- 賽博龐克 / 蒸汽龐克
- 明亮飽和配色
- 任何文字

### 9. 工作流程
- 第一張先做 scene_start（風格基準）
- user 確認再進下一張
- 每張自我檢查清單

### 10. 該章特殊視覺 signature
**這是該章獨特的部分**。要點：
- 主視覺母題（Ch1 = 茶水間 + 電梯 + 日光燈白 / Ch2 = 教室 + 走廊 + 掛鐘 23:47 / Ch3+ = 待你設計）
- 色溫氛圍（Ch1 = 夜 + 冷白 / Ch2 = 黃昏 + 夕陽橘紅 — 但仍只用 4 色 palette 表達，「橘紅」用米白 + 血紅組合暗示，不額外加色）
- 與既有章節對比（Ch3 vs Ch1/Ch2 怎麼區隔，避免風格重複）

### 11. 場景 Brief 列表（最大區塊）

**每個要產的 scene 一筆**，依下列格式：

```markdown
### N. `scene_xxx` ⭐（如果是基準圖加星）
**情境**：<2-3 句話描述場景內發生什麼，從 canonical 的 narrative 提煉>
**構圖**：<鏡頭視角 / 主體位置 / 重點視覺元素 — 寫實具體，不抽象>
**色塊處理**：<黑塊在哪、米白光區在哪、血紅唯一彩色在哪 — 4 色怎麼分配>
**情緒**：<2-4 個形容詞>
**人物**：<該場景出現誰，姿勢 / 角度>

（如果有特殊 manhwa 處理技巧，例如 Ch1 「沒有影子」需要對 Gemini 特別說明，加一個 🚨 區塊強調）
```

#### 該寫哪些 scene
- 全部「玩家會看到」的 scene（即非 router 場景）
- 主場景 + 結局場景
- 變體家族家族（phone_again 主版 + 變體）— **建議每個變體都有自己的圖**（場景不一樣）；如果變體間視覺差別很小（例：door_stuck vs door_stuck_impatient 都在同教室），可以共用一張，brief 寫清楚共用情況
- router 場景**不畫**（玩家看不到）

#### 順序
- 通常照 canonical MD 的 scene 順序
- 主路線優先 → 分支 → 結局

---

## 風格特例：該章獨特技巧

如果該章有 Ch1「沒有影子」這種需要特殊 manhwa 處理的視覺技巧，要在對應 scene 的 brief 後加 🚨 強調區塊，**直接寫給 Gemini 的英文指示**。範例（Ch1）：

```markdown
**🚨 manhwa 處理「沒有影子」的關鍵指令給 Gemini：**
> 「In manhwa visual language, a shadow is just a black ink shape on the floor next to objects. For Xiao Ting specifically, simply do not draw any black shape under or next to her feet — the floor remains clean white where her shadow should be. ...」
```

英文是因為 Gemini 對英文視覺指令理解更精確（特別是 limited palette、ink wash bleeding、no depth blur 之類的詞）。

---

## 完成判準

你的 image brief MD 算「準備好交付」必須：

1. ✅ user 整段複製貼進 Gemini 對話框就能開工，**不用補充任何資訊**
2. ✅ 每個 scene 都有完整 4 段（情境/構圖/色塊/情緒/人物）
3. ✅ 4 色 palette 嚴格守住（沒寫 RGB 色 / 沒寫淺藍紫綠等）
4. ✅ 跟 Ch1 image_brief_example.md 結構一致（user 看了不會困惑）
5. ✅ 該章特殊視覺技巧（如果有）有專門的英文指示給 Gemini

---

## 不要做這些

- ❌ **不要寫 prompt 工程的咒語**（「8K, ultra detailed, masterpiece, best quality...」）— 那是 SD 用法，Gemini 不吃這套
- ❌ **不要在 brief 裡寫長篇 narrative**（會讓 Gemini 試圖「畫故事」而不是「畫單格」） — 寫單一瞬間的視覺
- ❌ **不要要求 Gemini 畫 GIF / 動畫 / 多格漫畫** — 一個 scene 一張靜態圖
- ❌ **不要要求超出 4 色** — 「橘紅夕陽」用米白 + 血紅暗示，「藍光螢幕」用米白塊處理，不用加色
- ❌ **不要把 canonical 的整段 narrative 抄進 brief** — 提煉出「這一瞬間視覺」就好（一張圖只能表達一個瞬間）

---

## 一句話摘要

**讀 canonical + IP_BIBLE 視覺章 + ch01_image_brief_example，產出一份照同樣結構的 chXX_image_brief.md。user 整段貼到 Gemini 對話框 → Gemini 逐張產出 → user 收圖。**
