# 異聞錄：2347 — 第二章「下課之後」場景圖製作 Brief（給 Gemini）

> 本檔案為「劇情設計」端產出的視覺製作指示。請逐項閱讀完畢後，依「工作流程」逐張交付。

---

## 🎯 本次任務 — 全新 21 張

第二章「下課之後」是全新章節（**非補圖**），需從 `scene_start` 開始建立第二章的視覺基準，並維持與第一章同一視覺 IP。

### 21 張清單

| # | scene id | 類型 |
|---|---|---|
| 1 | `scene_start` ⭐ | 風格基準（先做這張）|
| 2 | `scene_wait_classroom` | 主場景 |
| 3 | `scene_classroom_wake` | 主場景 |
| 4 | `scene_door_stuck` | 主場景（與 `scene_door_stuck_impatient` **共用同一張**）|
| 5 | `scene_phone_again` | 主場景（教室站姿視角） |
| 6 | `scene_phone_again_hide` | 變體（桌底視角） |
| 7 | `scene_phone_again_escape` | 變體（走廊視角） |
| 8 | `scene_phone_again_stairs` | 變體（樓梯間視角） |
| 9 | `scene_endless_stairs` | 主場景（與 `scene_endless_stairs_search` **共用同一張**）|
| 10 | `scene_sms_or_call` | 主場景 |
| 11 | `scene_final_ascent` | 主場景（紅光長走廊+天台鐵門） |
| 12 | `scene_the_climax` | 高潮（天台對峙）|
| 13 | `scene_dream_intrusion` | 過場（夢境異象）|
| 14 | `scene_rejection_and_escape` | 假哥哥真面目暴露 |
| 15 | `scene_true_rescue` | 結局《兄妹重逢》好結局 |
| 16 | `scene_self_break` | 結局《逃出生天》好結局 |
| 17 | `scene_normal_escape` | 結局《無盡校園》中性 |
| 18 | `scene_rescued` | 結局《餘震》中性 |
| 19 | `scene_lost_soul` | 結局《失神》壞 |
| 20 | `scene_lost_sanity` | 結局《留校生》壞 |
| 21 | `scene_curse_spread` | 結局《下一個》壞 |

### 開始前的風格一致性 review

**最重要**：開工前請打開第一章已完成的 1-2 張作品（建議：`scene_start`、`scene_approach`）對標風格基準。風格不一致是產圖最大的失敗點。

第二章主視覺基調與第一章的差異：
- **第一章**：辦公大樓茶水間 + 電梯 + 日光燈白光 + **夜**
- **第二章**：**台式公立高中** + 教室 + 走廊 + 掛鐘 + **黃昏**

兩章共用：4 色 palette、manhwa 線條與留白美學、23:47 母題、「熟人模仿」恐怖核心。

---

## 你是誰

你是專業的恐怖遊戲視覺概念設計師，專長於心理恐怖、留白美學、東亞都市怪談的氛圍營造。你熟悉韓系 webtoon / manhwa 的線條與色塊語言，能在嚴格的 4 色 palette 內完成有強烈視覺衝擊的單格構圖。

---

## 專案背景（影響你的視覺判斷）

- **遊戲類型**：CYOA 文字冒險 + 心理恐怖
- **風格參考**：韓系 manhwa horror（《Sweet Home》/《Hellbound》/《Bastard》）
- **設定**：**現代台灣**，本章發生於**台北某老公立高中、模擬考剛結束的黃昏（17:00 後）**
- **主角**：高一/高二女學生（第一章哥哥的親妹妹）
- **市場**：手機橫向螢幕、HD 解析度
- **結局數量**：本章 7 個結局
- **圖片用途**：每個 scene 一張靜態插圖，由遊戲引擎獨立顯示文字疊在畫面下方

---

## 🎯 整體風格規範（每張都要遵守）

### 視覺風格 — **韓系 webtoon / manhwa horror**

請用以下任一組關鍵詞與 Gemini 溝通：

- `Korean manhwa horror style`
- `Korean webtoon black and white horror illustration`
- `manhwa style limited palette horror`
- `Sweet Home / Hellbound / Bastard manhwa visual style`

**不要寫**：photorealistic、cinematic photo、movie still、anime（容易被理解為日系大眼睛）

### 風格參照作品

- **《Sweet Home》Carnby Kim**
- **《地獄公使 / Hellbound》Yeon Sang-ho**
- **《Bastard》Carnby Kim**
- **《Solo Leveling》Dubu**
- **《殭屍校園 / All of Us Are Dead》原作 manhwa**

### 質感與線條

- **強烈黑色塊**處理陰影 — 不畫物理灰階陰影，用**純黑色塊**
- **粗細變化的墨線**勾勒人物輪廓
- **細節 / 留白二元**：人物臉部精細，背景大量留白或填黑塊
- **無景深模糊** — 全圖等銳利

### 配色 Palette（**嚴格 4 色，不增不減**）

| 色 | Hex | 用途 |
|----|-----|------|
| ⬛ 純黑 | `#000000` | 影子、頭髮、眼窩深處、暗區 |
| ⬜ 米白 | `#F0EDE5` | 高光區、皮膚、紙白、磁磚 |
| 🩶 冷灰 | `#6B7178` | 過渡灰階、深色制服裙、牆面陰影 |
| 🔴 血鏽紅 | `#8B1A1A` | **唯一彩色**：血痕、警示、血色夕陽 |

⛔ **不要其他顏色！** 沒有藍、綠、黃、紫、粉。

**第二章特例 — 黃昏夕陽如何處理**：黃昏紅光是本章的主氣氛，但仍嚴格用 4 色 palette 表達：
- **「金橘色夕陽」用大面積米白 + 血鏽紅暈染**（地板上的紅光投影、走廊紅光浸染、天台血色天空）
- **暗紅濃稠光線** = 米白漸層到血鏽紅的色塊過渡，**不要加橘色或黃色**
- 場景圖內可以有寫實的夕陽光線方向感（依 IP 視覺規範第 5 章例外條款），但顏色嚴守 4 色

### 鏡頭語言 — manhwa 構圖思維

- 想像每張是「**漫畫扉頁**」，不是「電影單格」
- **大膽剪影** + 強對比，不是寫實透視
- 第二人稱 POV：玩家（妹妹）少正面，多用**背影 / 過肩 / 手部特寫**
- 假哥哥幻覺出場：**眼神 / 嘴型 / 影子**有「不對勁」的視覺破綻

---

## 👤 角色鎖定（每次生圖都要保持一致）

> **manhwa 渲染原則**：人物比例寫實，臉部精細的墨線勾勒，髮絲用大色塊不畫單根

### 「妳」（玩家 / 主角 — 第二章設定為高中女生）

- **16-17 歲、亞洲女性、台灣高中女生**
- **服裝**：**白襯衫**（米白 `#F0EDE5` 色塊）+ **深色百褶裙**（純黑或冷灰色塊，膝上一點）+ **白短襪 + 黑皮鞋**
- **頭髮**：**黑長直髮、瀏海齊眉或微側分**（純黑大色塊，不畫高光高亮）
- **配件**：肩背或單肩**布製書包**（冷灰色塊）、白色運動手錶（米白小色塊在手腕）、智慧型手機
- **多以背影、手部、肩膀、過肩出現**（POV 風格）
- **正面出現時**：表情多為驚恐、皺眉、咬唇 — 不畫日系大眼，眼睛是寫實比例的墨線勾勒

> 📌 **家族視覺呼應**：妹妹是 Ch1 哥哥的親妹妹，**眉骨輪廓 + 鼻型**請與 Ch1 男主有家族相似。但白襯衫色塊與 Ch1 男主素色襯衫色塊形成「米白 + 黑色塊」一致的視覺族系。

### 「哥哥」（Ch1 男主，本章 NPC，僅在真結局 `scene_true_rescue` 正面出現）

- 沿用 Ch1 男主造型：**30 歲左右亞洲男性、短直黑髮**（純黑色塊）
- **本章救援裝扮**（與 Ch1 不同 — 必須有「真實人感」）：
  - 工作服 / 素色襯衫，**袖口捲起、領口開、襯衫前襟有汗濕痕**（用冷灰色塊暗示濕痕）
  - 黑色長褲
  - **滿頭大汗**（米白小亮點散佈在額頭與鬢角）
  - **抓妹妹肩膀的手在發抖**（用斷續的墨線輪廓表現顫抖感）
  - 背景有**停在校門口的機車**（純黑剪影、引擎發熱用米白小光點處理）
- **重要對比**：真哥哥是「跑著趕來的活人」 — 出汗、衣服亂、表情焦急且憤怒。**對比** scene_the_climax 假哥哥的「乾淨無汗、表情過分溫柔」。

### 「假哥哥」幻覺（本章主要異象，三種型態）

血咒透過電話與幻覺偽裝成哥哥。**三個演化型態**，依場景使用：

#### 型態 1：偽裝期（`scene_the_climax`）— 看起來正常，但有破綻
- 外觀與真哥哥**完全一樣**（相同服裝、髮型、體型）
- **異常處（給 Gemini 的關鍵指示）**：
  - 🕰️ **手錶指針卡在 23:47 且狀態詭異**（手腕特寫時，錶面指針要清晰可辨）
  - 👥 **腳下的影子向妹妹方向爬行**（影子形狀像觸手或爪，不是人形 — 用純黑色塊延伸繪製）
  - 💬 **嘴型開合與語音不同步**（manhwa 表現方式：**嘴型畫成兩層輪廓的疊影**，像錯位印刷）
  - 👀 **過分溫柔的笑容**（嘴角上揚弧度過於對稱，眼睛卻沒有跟著笑 — 眼角無皺紋）

#### 型態 2：暴露期（`scene_rejection_and_escape`）— 識破後真面目崩解
- 臉部肌肉**像融化的蠟一樣垮下**
- **臉部迅速乾縮成一個漆黑的深淵**（整張臉是純黑色塊缺口，邊緣有破碎墨線）
- 手裡拿的手搖飲杯**掉落地面，流出腐臭黑色黏液**（純黑流動色塊 + 墨水暈染感）
- 整體變成一團像**巨大黑布**的怪物形體（純黑剪影、輪廓不規則扭曲）

#### 型態 3：終末期（`scene_lost_sanity`）— 蠟融化露出無五官
- 臉部表面像**融化的蠟向下流淌**（外層臉皮用冷灰色塊處理，邊緣有滴落感的墨線）
- 露出底下**平滑、肉色、完全沒有五官的皮膚**
- ⚠️ **4 色 palette 內如何表達「肉色」**：用**米白為主 + 冷灰過渡**處理。**重點是「光滑無墨線、無凹凸、無五官痕跡」** — 那塊區域完全沒有任何眼睛、鼻子、嘴的勾勒線條，是一個全平的米白色塊
- 細長的手指**輕輕覆蓋在妹妹雙眼上**（手指比例略長，墨線勾勒）

**🚨 給 Gemini 關於假哥哥三型態的關鍵英文指令**：

> "The 'fake brother' has three visual stages, used in different scenes:
>
> **Stage 1 (the_climax)**: Looks identical to the real brother but with subtle wrong details. Draw the mouth as a **double-outline ghost effect** (two slightly offset mouth shapes overlapping) to suggest lip-sync mismatch. His shadow on the floor should extend toward the protagonist with **claw-like or tentacle-like irregular black ink shapes**, not a normal human shadow.
>
> **Stage 2 (rejection_and_escape)**: His face collapses into a **pure black ink void** (a flat black silhouette where the face should be, with broken ink edges around the perimeter). The drink he holds drips **thick black liquid** (solid black ink shapes, ink-wash bleeding effect).
>
> **Stage 3 (lost_sanity)**: The outer face skin melts downward (cool gray melted-wax shapes around the chin and jawline). Underneath is **smooth featureless flesh** — render this as a **completely flat off-white (#F0EDE5) area with no ink lines, no eyes, no nose, no mouth — just an unbroken pale surface where the face should be**. The horror comes from the **absence** of features."

---

## 🛡️ 老警衛（僅出現在 `scene_rescued` 中性結局）

- 60 歲左右亞洲男性、戴黑框眼鏡、深藍色制服（用冷灰色塊處理）、手電筒、表情疲憊但鎮定
- 與 Ch1 是**同一個視覺角色**（不是同一人，但造型沿用 Ch1 警衛規範）

---

## 📐 技術規格（必須遵守）

| 項目 | 規格 |
|------|------|
| **長寬比** | **16:9 橫向**（`1920x1080` 或 `1280x720`） |
| **格式** | WebP 優先，PNG 也接受 |
| **檔案大小** | 每張壓到 ≤ 200KB |
| **DPI / 色彩** | sRGB |
| **不可包含** | 文字 / 字幕 / 標題 / logo / 浮水印 / AI 生成標記 / 簽名 |

---

## 📁 命名規則（請依此命名後交付）

每張圖直接用對應的 `scene_id` 命名，例如：

```
scene_start.webp
scene_phone_again_hide.webp
scene_lost_soul.webp
```

> 共用圖：`scene_door_stuck.webp` 與 `scene_endless_stairs.webp` 各只交付一張（共用變體不另存）。

---

## ❌ 禁止事項

| 不要 | 為什麼 |
|------|--------|
| **照片寫實 photorealistic / 3D 渲染** | 走 manhwa，**最重要的禁忌** |
| **日系大眼睛動漫 anime / chibi** | 寫實人物比例 |
| **配色超出 4 色 palette** | 嚴格只用黑 / 米白 / 冷灰 / 血鏽紅 |
| **景深模糊 / bokeh / 軟焦** | 漫畫沒景深，全圖等銳利 |
| 過度血腥 / 內臟 / 殘肢 | 心理恐怖，不是 splatter |
| 西方建築 / 西方人物 / 教堂 / 萬聖節元素 | 設定是台灣高中 |
| 典型「白衣長髮女鬼飄浮」造型 | 老套，破壞質感 |
| 怪物完整正面特寫 | 留白才恐怖 |
| 賽博龐克 / 蒸汽龐克 / 奇幻 | 設定是現代台灣 |
| 明亮、飽和、活潑配色 | 與恐怖氣氛衝突 |
| 任何文字 / 字幕 / 對話框 / 浮水印 | 文字由遊戲引擎獨立顯示 |
| 校服露太多 / 物化未成年 | 主角是高中生，鏡頭語言**保守、克制** |

---

## 🧭 工作流程（請依序，不要跳）

1. **先讀完這份指示詞**，回覆「了解，準備好了」
2. **第一張先做 `scene_start`**（最重要，定調整個第二章視覺基準）
3. 我看完 `scene_start` 確認風格後，給你綠燈
4. 接下來 **逐張**生成（每次告訴你下一張的 ID + brief 確認）
5. 每張後，請**自我檢查**是否符合下方 checklist
6. 全部 21 張完成後，請整理成壓縮檔交給我

---

## 📚 21 張場景 Brief

> 每張的 brief 包含：情境 / 構圖 / 色塊處理 / 情緒 / 人物
> 文字描述只是參考，請依視覺最佳化判斷

---

### 1. `scene_start` ⭐（風格基準圖，先做這張）

**情境**：放學鈴聲剛停，黃昏夕陽濃郁地灌進教室，校園空蕩。妹妹收書包時手機在抽屜裡瘋狂震動，是「哥哥」的來電。掛鐘停在 23:47。妹妹的影子被夕陽拉得極長，末端融入走廊深處的黑暗。

**構圖**：寬鏡頭斜角，台灣高中教室一隅。前景是妹妹的**過肩 / 背影**坐在課桌前，手中攤開的書包露出參考書角；中景**抽屜縫透出手機的米白螢幕光**；遠景**黑板上方掛著圓形掛鐘，指針定格 23:47**（清晰可見）；窗外光線從右側灌入，在地板上投出**極長的人影**，影子尾端融入走廊深處的純黑塊。

**色塊處理**：教室磁磚地用米白為主，**地板上的夕陽光線投影用米白 + 血鏽紅暈染色塊**處理（取代橘色）；課桌椅是冷灰色塊；妹妹身影是黑長髮 + 米白襯衫 + 黑色裙子的色塊組合；掛鐘外框純黑、鐘面米白、指針純黑；走廊深處整片純黑。

**情緒**：日常崩解前的最後一刻、不安預感、詭異安寧

**人物**：妹妹（過肩 / 半側影、坐姿、手伸向震動中的抽屜手機 — 米白襯衫色塊 + 黑長髮色塊）

---

### 2. `scene_wait_classroom`

**情境**：妹妹塞耳機等哥哥，掛鐘秒針詭異顫動發出「喀——喀——」聲。手錶顯示 17:03 但窗外夕陽詭異地停在同個位置不移動，光影夾角凝固。

**構圖**：中景，妹妹側面坐姿，戴著耳機、雙手插口袋；前景**黑板旁的掛鐘特寫角**（鐘面 23:47、秒針位置在「47 與 48 之間」的顫動瞬間 — 用兩條疊影黑線表現秒針抖動）；地面上**夕陽斜長的光影條紋整齊排列且毫無移動感**。

**色塊處理**：教室大量米白磁磚地 + 課桌冷灰色塊；窗光投影用米白塊（亮）+ 血鏽紅塊（陰影邊緣染色）；掛鐘是純黑外框 + 米白鐘面 + 純黑指針；妹妹是黑長髮 + 米白襯衫 + 黑裙的色塊。

**情緒**：時間凝固的違和、耳機掩蓋不了的耳鳴感、莫名侷促

**人物**：妹妹（側影、坐姿、戴耳機、低頭看手錶或盯掛鐘）

---

### 3. `scene_classroom_wake`

**情境**：妹妹趴睡瞬間驚醒，教室從黃昏直接墜入濃稠如墨的黑暗。手錶顯示 17:15 但窗外光全無。妹妹猛地站起，椅子在死寂中發出刺耳「吱——」聲。

**構圖**：中景，妹妹剛從課桌站起的瞬間，**椅子向後刮地的動作線**（manhwa 速度線）；周圍課桌椅在墨黑中只剩**輪廓剪影**，像一座座沉默墓碑；**手錶米白螢幕在絕對黑暗中是唯一光源**（特寫到手腕一塊）；遠處教室後方陰影更濃，暗示「窺視者」存在感（不畫實體，留白）。

**色塊處理**：整張**大面積純黑為主**（80% 以上），課桌椅輪廓用粗墨線勾勒；地面與妹妹臉部與手錶用米白小光區突出（孤立感）；無血鏽紅（這是「視覺被吞噬」的瞬間，純黑白對比最有力）。

**情緒**：絕對的黑、被窺視的冰冷、刺耳寂靜

**人物**：妹妹（半身、剛站起姿勢、**臉部表情驚恐**、手錶米白光打亮她的下巴）

**🚨 給 Gemini**：
> "The classroom is **almost entirely filled with solid black ink**, with only desk-chair silhouettes outlined in thick ink lines. The protagonist's face and watch screen should be the **only off-white (#F0EDE5) light areas** in the frame — like islands of pale skin in an ocean of black. Do NOT use gray gradients to fill the darkness; use **flat solid black**. This is manhwa, not photography."

---

### 4. `scene_door_stuck`（與 `scene_door_stuck_impatient` 共用同一張）

**情境**：妹妹拚命拉教室門把但門紋風不動，金屬發出乾澀尖銳的磨擦聲。背後黑暗中傳來「喀」聲（掛鐘秒針）+ 濕漉漉貼地磨擦聲，從教室最後一排陰影一吋吋朝她移動。

**構圖**：中景過肩 POV，前景**妹妹的雙手緊握門把、身體後仰使力的背影 / 半側影**；門板是冷灰木門、米白磁磚牆；**畫面右後方教室深處陰影濃郁**，地板上有一條**濕滑黑色拖痕**從最後一排往妹妹方向延伸（不畫實體，只用拖痕暗示）；牆上掛鐘在畫面一角，秒針位置詭異。

**色塊處理**：門板冷灰、磁磚地米白、教室深處純黑；妹妹白襯衫米白 + 黑裙黑髮；地板拖痕是純黑墨水暈染感（ink-wash bleeding）。

**情緒**：被困、來不及、貼背的冰冷氣息

**人物**：妹妹（背影、雙手抓門把用力後仰、書包斜背）

---

### 5. `scene_phone_again`（教室站姿視角）

**情境**：手機猛震，「哥哥」來電。第二通電話的語氣完全不同 — 輕鬆溫柔、笑意，說已到校門口看金色雲霞，要妹妹上天台看夕陽。妹妹遲疑時，原本打不開的門「喀擦」自己推開一道縫，露出血紅色長廊。

**構圖**：中景，妹妹站在教室中央接電話；**右側教室門自己緩緩打開的瞬間**，門縫透出**血紅色長廊的暗紅光線**（地板被紅光浸染）；妹妹半側身、手機貼耳、眉頭微皺；後方掛鐘秒針的喀聲頻率被視覺化成**幾條斷續的速度線**從鐘面射出。

**色塊處理**：教室內部用大面積純黑（剛從 classroom_wake 的墨黑延續）+ 米白人物高光；**門縫紅光是本張唯一的血鏽紅亮色塊**（血鏽紅 + 米白漸層處理「血色夕陽」）；妹妹米白襯衫 + 黑裙黑髮。

**情緒**：被誘惑前的最後遲疑、語氣反差的不對勁、紅光誘餌

**人物**：妹妹（半身、站姿、手機貼耳、眉頭微皺；表情寫質疑而非恐懼 — 重要！這是她開始懷疑的瞬間）

---

### 6. `scene_phone_again_hide`（桌底視角變體）

**情境**：與 #5 同一通電話、同樣語句，但妹妹此時**蜷縮在課桌下的陰影中**接電話，心跳聲在死寂教室裡震耳欲聾。

**構圖**：**低角度 POV**，從**課桌底下往外看**的視角；前景是課桌椅腳的純黑剪影**像森林一樣**遮擋畫面下半，**畫面中央上半部留出窄窄一條視野**看見遠處門縫透出的紅光；妹妹的手在前景緊握手機（米白螢幕亮著「哥哥」字樣 — **不寫文字，用米白光區暗示**）；妹妹的臉一半藏在課桌陰影裡。

**色塊處理**：80% 純黑色塊（課桌椅腳剪影 + 桌底陰影） + 中間米白條光（門縫遠處紅光投射）+ 妹妹手部米白小光區。

**情緒**：被困桌底的窒息、心跳震耳、躲藏的徒勞

**人物**：妹妹（**低角度近景、半臉藏在桌下陰影**、手握手機）

---

### 7. `scene_phone_again_escape`（走廊視角變體）

**情境**：與 #5 同一通電話，但妹妹此時**已逃出教室在血紅長廊中接電話**，腳下磁磚被紅光浸染。

**構圖**：中景，妹妹站在**血紅光線浸染的長廊中央**接電話；走廊向遠方延伸，**兩側教室門像歪斜的墓碑**（門板輪廓有微微傾斜的不規則感）；遠處走廊盡頭是濃郁的純黑塊（看不見盡頭）；妹妹半側身手機貼耳、書包斜背。

**色塊處理**：**走廊地面是大面積米白 + 血鏽紅暈染**（血色夕陽浸染地面）；牆面冷灰；遠處盡頭純黑；妹妹白襯衫米白 + 黑裙黑髮，**腳下地板的紅色血光浸染到她的鞋邊**。

**情緒**：身處紅色血光中、走廊扭曲、退無可退

**人物**：妹妹（中景背影或半側影、站在走廊中央）

---

### 8. `scene_phone_again_stairs`（樓梯間視角變體）

**情境**：與 #5 同一通電話，但妹妹此時**已逃進樓梯間扶著不鏽鋼扶手**接電話。樓梯延伸向下、向上都是血紅色暗影，看不見盡頭。

**構圖**：仰角構圖，妹妹**側身扶著樓梯不鏽鋼扶手接電話**，後方樓梯**向上盤旋延伸消失在血紅色暗影中**；前景樓梯踏面在血色光中浸染；樓梯間牆上有圓形掛鐘從牆裡長出來的剪影（**不要畫得太清楚，遠景模糊輪廓即可**）。

**色塊處理**：樓梯踏面米白 + 血鏽紅暈染（紅光浸染）；扶手純黑線條；牆面冷灰；上方盤旋樓梯區用大面積純黑色塊堆積出**封閉壓迫感**。

**情緒**：迷失樓梯間、無路可退、聲音與環境脫節

**人物**：妹妹（半側身、扶扶手、手機貼耳）

---

### 9. `scene_endless_stairs`（與 `scene_endless_stairs_search` 共用）

**情境**：妹妹發了瘋似地往下衝，球鞋在磨石子台階上摩擦尖叫，但前方永遠是看不見底的灰色台階。**牆上每個樓層轉角都掛著一模一樣的圓形掛鐘**，全部定格 23:47，秒針發出咬碎枯木的聲音。後方傳來黏稠拖行聲，影子已在腳邊台階拉長。

**構圖**：寬鏡頭俯角 + 透視壓縮，**樓梯井向下延伸的不可能空間構圖**（M.C. Escher 式悖論透視 — 多層樓梯重疊但延伸方向違反物理）；**每個樓層轉角都有一個圓形掛鐘從牆裡長出**（至少 3-4 個鐘出現在畫面中，全部指 23:47）；前景妹妹下衝的背影 / 過肩；後方台階上拉長的純黑影子（不畫怪物實體）。

**色塊處理**：樓梯間磁磚冷灰 + 部分米白；多個掛鐘是純黑外框 + 米白鐘面 + 純黑指針的重複圖案（重複本身就是恐怖）；妹妹米白襯衫黑裙；後方影子純黑墨塊延伸。

**情緒**：逃不出去的無限迴圈、時間錨定、被追逼

**人物**：妹妹（下衝背影、扶扶手、書包甩動感）

**🚨 給 Gemini**：
> "Use **impossible architectural perspective** (Escher-like) where multiple stair flights overlap and extend in physically inconsistent directions. **At least 3-4 identical round wall clocks** must be visible in the frame, all frozen at 23:47, growing organically from the walls at each landing. The repetition of identical clocks is the core horror — make them clearly visible, not background blur."

---

### 10. `scene_sms_or_call`

**情境**：妹妹放慢腳步停下來，意識到第二通電話的「溫柔語氣」完全不像哥哥平時的個性。在死寂中她回想兩通電話的反差。手機螢幕的微弱白光在昏暗中跳動，是這片混亂裡唯一真實的東西，讓她想到傳簡訊或再撥一次。

**構圖**：中景近景，妹妹**低頭看手機螢幕**的半側臉特寫；**手機米白螢幕光從下方打亮她的下巴與臉頰**（manga 經典臉部打光）；周圍環境是模糊的純黑塊（教室或走廊都行，重點是**孤立感**）；妹妹的眼神有思考、回想的神情。

**色塊處理**：80% 純黑環境 + 手機螢幕米白光區 + 被光照亮的妹妹臉部米白色塊 + 黑長髮純黑 + 米白襯衫；無血鏽紅（這是冷靜思考瞬間，不要紅光干擾）。

**情緒**：開始懷疑、回想反差、清醒的瞬間

**人物**：妹妹（**近景、半側臉、手機螢幕從下方打光、眼神思索**）

---

### 11. `scene_final_ascent`

**情境**：手機螢幕無預警閃爍兩下熄滅。原本拉不開的教室門「喀擦」自己打開，外面是被血紅光浸染的長廊。妹妹衝出教室，**走廊被強行拉長、兩側教室門像歪斜墓碑**，地板被濃郁紅光塗成濕滑暗紅色。樓層牌全部變成 23:47 的掛鐘。她衝上樓推開通往天台的鐵門。

**構圖**：兩段式構圖建議：**主畫面是長走廊縱深透視**，妹妹的奔跑背影（有動作速度線）；走廊向遠方延伸**極端拉長**（透視壓縮誇張），兩側教室門**輕微傾斜變形**像墓碑；地板紅光浸染明顯；遠處有一道米白光的天台鐵門剪影。

**色塊處理**：走廊地板**大面積米白 + 血鏽紅暈染**（地板被紅光浸染最重的一張，紅色比例可拉到 30%）；牆面冷灰；教室門純黑剪影；遠處天台鐵門是米白光區（救贖假象）。

**情緒**：紅色血光的逃亡、走廊像血管、奔向未知

**人物**：妹妹（中景奔跑背影、書包甩動、頭髮散亂、有動作線）

---

### 12. `scene_the_climax`（高潮張）

**情境**：天台。血紅色天空下，「哥哥」背影站在天台邊緣手拿手搖飲。透過機房玻璃倒影，他發現妹妹進來，緩緩轉身露出溫柔笑容招手。但他**嘴型與聲音有詭異延遲**（疊影錯位），**腳下影子像怪物般沿地板朝妹妹爬過來**，**手錶指針正瘋狂倒轉並卡在 23:47**。

**構圖**：寬鏡頭，天台場景。**前景左側是天台機房或排風管的純黑剪影**；**中景假哥哥背影**（剛剛轉身、手舉著手搖飲、半轉過來的瞬間）；**右側機房玻璃上反射出他另一個視角的倒影**；遠景是**血紅色天空 + 城市天際線剪影**；地板上**假哥哥的影子像觸手 / 爪子般延伸朝鏡頭爬來**（純黑墨塊不規則延伸）。

**色塊處理**：天空大面積**血鏽紅 + 米白雲層暈染**（最濃的血色）；天台地面冷灰；假哥哥米白襯衫 + 黑長褲；影子怪異延伸用純黑色塊。

**情緒**：偽裝的甜美、第一次正面看見幻覺核心、影子背叛了他

**人物**：假哥哥（**型態 1**：表面正常但破綻明顯 — 嘴型雙重輪廓疊影、影子像爪子、手舉手搖飲、過分溫柔的笑）；**畫面遠景留 1/4 給妹妹的背影 / 過肩**（看著他的視角）

**🚨 給 Gemini — 假哥哥型態 1 的關鍵呈現**：
> "The fake brother's mouth must be drawn with a **double-outline ghosting effect** — two slightly offset mouth shapes overlapping, suggesting lip-sync mismatch. His shadow on the rooftop floor extends toward the protagonist in **claw-like or tentacle-like irregular black ink shapes**, NOT a normal human shadow. His wristwatch (visible because he's gesturing with the cup) shows hands frozen at 23:47, with subtle motion lines suggesting the hands are reversing. His smile is **too symmetrical**, eyes don't crinkle — uncanny valley territory."

---

### 13. `scene_dream_intrusion`（過場場景，趴睡失敗 → 夢境汙染）

**情境**：妹妹趴在課桌上沉入夢境。夢中教室窗外夕陽是刺眼暗紅。**身後座位上坐著無數個「妳」**，全都低頭整齊劃一地用原子筆在課本上反覆刻畫「23:47」，筆尖劃破紙張像切割耳膜。其中一個「妳」抬頭，臉是**抹平的白紙、沒有五官，只有額頭貼一張發黃便條紙**。

**構圖**：寬鏡頭，教室全景。妹妹本人在前景課桌**趴睡的背影**；中後景**無數張一模一樣的「妳」整齊坐在後方所有座位上**（至少 5-7 個複製分身可見）；其中**最近的一個分身抬起頭**，臉是平滑米白色塊（**完全無墨線勾勒五官**），額頭貼一張發黃米白便條紙（用冷灰邊緣處理「發黃」感）。

**色塊處理**：窗外天空**血鏽紅濃重**（夢境異象）；教室地板米白 + 課桌冷灰；無數個「妳」全部黑長髮 + 米白襯衫的重複色塊（**重複本身就是恐怖**）；無臉分身的臉是**完全平滑米白色塊**。

**情緒**：自我複製的迷失、無臉的親密、墮落的安寧

**人物**：妹妹本人（前景趴睡背影）+ 無數複製「妳」（中後景、整齊抄寫姿勢）+ 抬頭的無臉分身（中景特寫）

**🚨 給 Gemini**：
> "Multiple identical copies of the protagonist must sit in the classroom seats behind her, all in **uniform synchronized pose** (heads down, writing in unison). The repetition is the horror. The closest copy has lifted her head — her face is **a completely smooth, featureless off-white (#F0EDE5) shape with NO ink lines at all** for eyes, nose, or mouth. Just a blank pale oval where the face should be, with a small slightly-yellowed sticky note on the forehead (use cool gray edges to suggest yellowing within the 4-color palette)."

---

### 14. `scene_rejection_and_escape`

**情境**：妹妹喊出「你不是我哥」。**假哥哥的臉部肌肉像融化的蠟一樣垮下，迅速乾縮成一個漆黑深淵**。手裡手搖飲杯掉地，**流出的是腐臭黑色黏液**。聲音化作尖銳嘶吼，整個天台開始崩塌、地面變得像沼澤般柔軟。**那團黑影怪物像一塊巨大黑布朝妹妹撲來**！妹妹轉身狂奔。

**構圖**：動態構圖。**畫面左後方是崩解中的假哥哥**（型態 2：臉是純黑深淵缺口、身體輪廓開始扭曲變形、手已掉下手搖飲、地上一灘純黑黏液）；**畫面中前景是妹妹奔跑離開的動態背影**（強烈動作速度線、頭髮飛揚、書包甩動）；後方天台**地面開始扭曲變形**（地板用波浪不規則墨線暗示「沼澤化」）；天空仍是血鏽紅。

**色塊處理**：假哥哥區域大面積純黑色塊（吞噬式存在）；地面冷灰 + 波浪墨線；天空血鏽紅 + 米白雲層；妹妹米白襯衫 + 黑髮飛揚 + 黑裙的動態色塊。

**情緒**：真面目暴露的衝擊、純粹的奔逃、身後黑布緊追

**人物**：假哥哥（**型態 2**：臉部純黑深淵、身體開始崩解）+ 妹妹（前景奔跑背影、強動作線）

**🚨 給 Gemini — 假哥哥型態 2**：
> "The fake brother's face has collapsed into a **flat pure black ink void** — a solid black silhouette where the face should be, with broken jagged ink edges around the perimeter (like torn paper). The drink he dropped pools on the floor as **thick black ink with ink-wash bleeding effect**. His body silhouette is starting to distort, suggesting transformation into a 'large black cloth' creature. The horror is the **face becoming a hole, not a face**."

---

### 15. `scene_true_rescue`（好結局《兄妹重逢》）

**情境**：妹妹撞開一樓大門，黑色觸手即將纏住她脖子的瞬間，**真哥哥衝上前**將她拉開、怒吼「滾開！別碰我妹！」幻象碎裂。妹妹撞進真實溫暖的懷抱（汗水味、真實體溫）。哥哥滿頭大汗、表情焦急且憤怒，身後是停在校門口、引擎還在發熱的機車。

**構圖**：中景，校門口。**前景是真哥哥從畫面側邊衝入、伸手將妹妹拉開的動作瞬間**（動態構圖、強動作線）；妹妹正撞進哥哥懷抱、書包還在背上甩動；**身後校門口停著一台機車**（純黑剪影、引擎排氣管有米白小光點暗示熱度）；後方校舍是濃郁純黑塊（已經沒有紅光、沒有掛鐘 — 異象解除）；天空是黃昏轉夜的米白 + 冷灰。

**色塊處理**：哥哥米白襯衫 + 黑長褲、**滿頭汗的米白小光點散佈在額頭髮際**；妹妹米白襯衫 + 黑裙黑髮；機車純黑剪影 + 引擎處小米白光點；後方校舍純黑（被解除的異象區）；天空米白 + 冷灰漸層（普通黃昏）。

**情緒**：真實人感的懷抱、解脫、活著的溫度

**人物**：真哥哥（**衝入動作、滿頭大汗、表情焦急憤怒、襯衫袖口捲起、領口開有汗濕痕跡、抓妹妹肩膀的手有顫抖墨線**）+ 妹妹（撞進懷抱、書包甩動、半側臉表情驚恐後鬆懈）

**🚨 給 Gemini — 真哥哥的「真實人感」對比**：
> "This is the climactic contrast moment. The real brother MUST look **sweaty, disheveled, panicked-yet-furious** — opposite of the fake brother's clean uncanny smile in scene_the_climax. His shirt sleeves are **rolled up unevenly**, the collar is **open with visible sweat marks** (use cool gray patches to suggest dampness on the off-white shirt), forehead has **scattered off-white highlight dots** for sweat beads, and the **hand gripping the protagonist's shoulder shows trembling broken outlines** (suggest motion/shake through fragmented ink lines). Behind him: a motorcycle parked at the school gate as a **pure black silhouette** with small off-white light points near the exhaust suggesting residual engine heat. He just rode here in panic. He is **alive**."

---

### 16. `scene_self_break`（好結局《逃出生天》）

**情境**：妹妹閉眼大喊「這一切都是假的！通通消失！」幻覺碎裂如玻璃，假哥哥消失。妹妹衝下天台衝出校門跑回家。回到家發現哥哥就坐在客廳沙發滑手機，他今天根本沒打過電話。但**從那天起，每當她轉身離開時都感覺到背後一道冰冷視線；猛回頭時哥哥卻只是平靜喝湯，臉上帶著她從未見過的、僵硬上揚的微笑**。

**構圖**：兩段式構圖。**主畫面是客廳一角**，前景哥哥坐在沙發上喝湯的側影 / 半側臉特寫，他**嘴角帶著微微上揚的僵硬弧度**（**uncanny smile** — 像 scene_the_climax 那種過分對稱）；中景是妹妹的背影**正要離開或回頭看的瞬間**；客廳燈是米白光暖黃感（用米白為主）；**重點視覺：哥哥的眼睛在喝湯時微微抬起、視線追隨著妹妹背影**（不對勁的細節）。

**色塊處理**：客廳整體米白 + 冷灰（家的安全感色塊）；哥哥側影是米白襯衫 + 黑髮；妹妹米白襯衫 + 黑裙；**唯一不對勁是哥哥嘴角的上揚弧度與微微抬起追視妹妹的眼神**（沒有血鏽紅、沒有黑色塊異象 — **這個「正常表面下的不正常」最恐怖**）。

**情緒**：虛假的解脫、看似正常的家、永遠的疑慮

**人物**：哥哥（**側影、坐姿喝湯、嘴角僵硬上揚、眼神追視離開的妹妹** — 但保持「看似正常」的構圖**請勿畫成幻覺型態，這是「真結局之外的灰色解脫」**）+ 妹妹（背影、要離開的瞬間）

**🚨 給 Gemini**：
> "This is the most subtle horror in the chapter. The brother in the living room must look **mostly normal** — no black voids, no melting, no shadows. The horror is in **microexpressions**: a mouth corner slightly too upturned, eyes that follow her too precisely. **Do not exaggerate**. The viewer should look at this image and only on second glance realize something is wrong. Restraint is key."

---

### 17. `scene_normal_escape`（中性結局《無盡校園》）

**情境**：妹妹跌跌撞撞衝出校門，回頭望，學校隱沒於暮色中、沒有紅光沒有人影。手機螢幕乾淨。她回家睡了。隔天上學一切正常。直到放學夕陽再次將教室染成詭異橘紅。手機猛震，「哥哥」來電。妹妹抬頭看掛鐘——指針定格 23:47。「喀、喀、喀」聲再次響起。她慢慢轉頭，看見**自己的影子正一點一釐米地往課桌底下縮回去**。

**構圖**：寬鏡頭，**隔天的教室一隅**（與 scene_start 構圖呼應，但有微妙差異）。前景妹妹半側影坐在課桌前看手機；牆上掛鐘 23:47；**最重要視覺：地板上妹妹的影子正在「主動移動」朝課桌底下縮回**（影子形狀在不自然地變形、邊緣有反向動作的墨線）；窗外又是濃郁血色夕陽。

**色塊處理**：與 scene_start 類似的米白磁磚地 + 血鏽紅夕陽光浸染；妹妹米白襯衫 + 黑裙黑髮；**影子用純黑色塊但形狀正在反常移動**（用斷續墨線表達「縮回」動作）。

**情緒**：循環噩夢、逃不出的詛咒、自己成為下一個

**人物**：妹妹（半側影、坐姿、頭微轉看地板、表情驚恐）

---

### 18. `scene_rescued`（中性結局《餘震》）

**情境**：妹妹擊碎牆上火警警報器，警鈴撕裂死寂走廊，紅色霧氣與拖行聲退去。老警衛提著手電筒氣喘吁吁跑上樓時，她正縮在牆角眼神空洞地不斷重複一個數字。在醫院幾週她拒絕說話。轉學後新生活看似正常，但每當夕陽斜照、掛鐘秒針逼近 47 那刻，她會屏息發抖。

**構圖**：兩段式建議。**主畫面是學校走廊**：警鈴位置牆上有一個被擊碎的火警按鈕（米白外殼 + 紅色按鈕碎裂感）；前景妹妹**蹲縮在牆角、雙手抱膝、雙眼空洞盯著虛空**；中景**老警衛從樓梯間提著手電筒跑來**的剪影（手電筒光是米白光柱）；地面上**紅色霧氣正在退去**的視覺殘影（米白 + 血鏽紅暈染塊正在淡化）。

**色塊處理**：牆面冷灰 + 純黑陰影；妹妹米白襯衫 + 黑裙黑髮，**眼神是空洞的純黑點**（不畫眼神光）；警衛純黑剪影 + 手電筒米白光柱；地面紅霧退去的紅色塊變淡。

**情緒**：被救但留下永久創傷、陽光也是噩夢、心病

**人物**：妹妹（**牆角蹲姿、雙手抱膝、空洞眼神、表情失神**）+ 老警衛（中景背景剪影、提手電筒）

---

### 19. `scene_lost_soul`（壞結局《失神》）

**情境**：妹妹說「好」，慢慢走向天台邊緣的「哥哥」。血紅夕陽染紅整個天台。「哥哥」背對她沒回頭。越靠近，妹妹的思緒越薄弱、認知記憶被蒸發。風灌進領口，她閉上眼睛。**隔天清晨，警衛發現校舍下方躺著穿校服的女生，手機握在手裡通話紀錄是「哥哥」23:47，臉上掛著最安心的微笑**。

**構圖**：兩段建議 — 但**強烈建議用第一段（瞬間之前）**：天台場景。**前景是妹妹的背影朝天台邊緣走去的瞬間**（緩慢步伐、頭髮在風中飛揚、書包還在肩上）；中景假哥哥背影站在邊緣（純黑剪影）；**整片天空與地面都被血鏽紅 + 米白雲層完全染紅**（色彩濃度本章最高）；風吹起妹妹的裙擺與頭髮（動作墨線）。

**色塊處理**：**血鏽紅佔畫面 50% 以上**（天空 + 地面紅光浸染 — 這是色彩濃度最高的一張）；妹妹米白襯衫 + 黑長髮飛揚 + 黑裙；假哥哥純黑剪影；天台地面被夕陽光線浸染。

**情緒**：被吞噬前的安寧、血色救贖的假象、走向終點的乖巧

**人物**：妹妹（**背影、緩慢走向天台邊緣、頭髮裙擺被風吹起**）+ 假哥哥（**遠景純黑剪影、背對、站在天台邊緣**）

**❗ 重要禁忌**：**禁止畫墜落、禁止畫地面屍體、禁止血腥**。這張結局的恐怖在「**走向之前的瞬間**」的安寧美感，不在墜落本身。畫到「她朝邊緣走的背影 + 風吹頭髮」就停。

---

### 20. `scene_lost_sanity`（壞結局《留校生》）

**情境**：妹妹理智崩解。**「哥哥」的臉開始像蠟一樣融化，露出底下平滑、肉色、沒有五官的皮膚**。她不再恐懼反而覺得空洞親切。那東西伸出細長手指輕覆她雙眼，極致寒意滲入大腦帶走所有記憶名字情緒。再睜眼時，她眼神空洞像深井。**她轉身走回血紅走廊，走進一間教室坐在最後一排，雙手平放膝蓋像最乖巧的學生**。當下一個受害者來時，她會露出僵硬完美的微笑問：「你在哪？我在教室等妳⋯⋯」

**構圖**：**強烈建議呈現最後一個畫面**（最有衝擊力）：**教室最後一排座位的中景**。妹妹**端坐在座位上、雙手平放膝蓋、抬頭直視鏡頭、嘴角僵硬上揚的微笑**；她的**眼神是空洞的純黑深井**（瞳孔是純黑色塊缺口）；後方掛鐘依然定格 23:47；周圍其他座位空無一人，純黑的教室深處。

> **可選**：第二輔助元素 — 畫面一角小一點呈現「假哥哥型態 3」（蠟融化的臉露出米白平滑無五官面）作為過去發生事件的暗示，但**主視覺重心仍是端坐微笑的妹妹**。

**色塊處理**：教室深處大量純黑色塊；妹妹米白襯衫 + 黑長髮 + 黑裙 + **眼睛是純黑空洞色塊**；嘴角僵硬上揚的微笑用清晰墨線勾勒（不對稱但不誇張）；掛鐘純黑外框 + 米白鐘面 + 純黑指針 23:47。

**情緒**：自我消失後的虛假乖巧、永恆停留的等待、傳染下一個的循環

**人物**：妹妹（**端坐姿勢、雙手平放膝蓋、抬頭直視鏡頭、空洞眼睛、僵硬微笑** — 像 Ch1 小婷的進化版恐怖）

**🚨 給 Gemini — 妹妹的「留校生」狀態**：
> "The protagonist is now the new haunting entity. She sits perfectly upright in the back-row classroom seat, hands flat on knees in an unnaturally proper posture, facing the camera directly. Her **eyes are pure black ink voids** (solid black shapes with no pupils, no whites — completely filled black sockets). Her smile is **perfect, symmetrical, stiff** — drawn with clear ink lines, slightly off in proportion (mouth corners pulled too evenly). The classroom around her is **almost entirely solid black**, with only her form, the wall clock (23:47), and the desk surface as off-white islands. She IS the new Xiao Ting equivalent for this chapter."

---

### 21. `scene_curse_spread`（壞結局《下一個》）

**情境**：妹妹發現視線所及一切迅速崩解、化作濃稠近乎固體的黑暗從四面八方擠壓。空間感消失、像墜入深淵。無形觸感纏上她的腳踝拉她下沉。意識模糊時，**手中手機螢幕成為虛無中最後殘光**。在那慘白螢幕上，**電話正自動撥向她最熟悉的那個人**。聽筒接通，她聽見「自己」帶著空洞笑意輕聲說：「你在哪？我在學校等你⋯⋯這裡好漂亮，你快過來⋯⋯」

**構圖**：近景特寫。**畫面 80% 被無形的黑暗吞噬**（純黑色塊堆積、邊緣有墨水暈染感的黑霧）；**畫面中央偏下是妹妹的手握住手機的特寫**（米白螢幕亮著「正在通話：哥哥」— **不寫文字，用米白光區與通話介面的剪影暗示**）；周圍**無形的純黑觸手般陰影纏繞她的手腕與手機**（不畫具體生物，用黑色墨水流動感暗示）；遠處再無任何輪廓 — 只有絕對的虛無。

**色塊處理**：**95% 純黑色塊**（吞噬式黑暗）；中央手機螢幕米白光區（最後的光）；手部與手腕的米白色塊被黑色觸手墨塊纏繞；無血鏽紅（這是純粹的黑與白的吞噬瞬間，不需要紅光）。

**情緒**：詛咒繼承、自己成為下一個來電者、傳染給下一章主角的種子

**人物**：妹妹（**僅出現手部與手機特寫、不畫臉**）+ 暗示性的無形觸手（純黑墨水流動感）

**🚨 給 Gemini**：
> "This is the chapter's final cursed transmission. The frame is **almost entirely solid black** (~95%), with only a small bright off-white area in the lower center — the protagonist's **hand gripping the phone, screen lit with a 'calling: brother' interface** (suggest the call interface through silhouettes and light areas, **no text**). Around the hand, **flowing black ink tendrils** (like fluid ink-wash bleeding) wrap around the wrist and phone, suggesting incorporeal entities pulling her down. **Do not draw a face. Do not draw a full body.** Only the hand and phone exist — everything else has been swallowed by the void. The horror is that **she is becoming the next 'fake caller' for the next chapter's protagonist**."

---

## ✅ 自我檢查清單（每張完成後 Gemini 請自審）

- [ ] 16:9 橫向比例
- [ ] **是 manhwa 風格**（不是寫實照片、不是日系大眼動漫、不是 3D 渲染）
- [ ] **配色嚴格 4 色**（純黑 / 米白 / 冷灰 / 血鏽紅）— 沒有藍綠黃紫粉等其他顏色
- [ ] 妹妹外觀符合鎖定設定（白襯衫米白塊、深色百褶裙、黑長直髮純黑塊）
- [ ] **沒有景深模糊 / 軟焦**（manhwa 全圖等銳利）
- [ ] 黑色塊作為陰影語言（不是物理灰階陰影）
- [ ] 沒有文字 / 浮水印 / 簽名 / AI 標記
- [ ] 沒有過度血腥 / 墜落 / 屍體
- [ ] 構圖符合「第二人稱 POV」精神（妹妹少正面）
- [ ] **與第一章已完成的圖**（例：scene_start、scene_approach）線條粗細、色塊比例、人物造型一致
- [ ] 假哥哥型態 1（climax）：嘴型雙重輪廓疊影 ✅、影子像爪子延伸 ✅、手錶卡 23:47 ✅
- [ ] 假哥哥型態 2（rejection）：臉是純黑深淵缺口 ✅、黑色黏液 ✅
- [ ] 假哥哥型態 3（lost_sanity）：蠟融化 + 米白平滑無五官面 ✅
- [ ] 真哥哥（true_rescue）：滿頭汗、衣服亂、手在抖、機車剪影 — **真實人感** ✅
- [ ] 23:47 在每張需要時都清晰可見（掛鐘 / 手錶 / 通話螢幕）
- [ ] 黃昏夕陽用米白 + 血鏽紅暈染表達，**沒有橘色或黃色**
- [ ] 妹妹的 `scene_lost_sanity` 留校生狀態：眼睛是純黑空洞 ✅、僵硬微笑 ✅
- [ ] `scene_lost_soul` 沒有畫墜落、屍體或血腥（只到「走向邊緣的背影」為止）✅

---

## 📦 交付方式

全部 21 張完成後，請：
1. 確認所有檔案命名正確（`scene_xxx.webp` 對應 21 個 ID — `scene_door_stuck_impatient` 與 `scene_endless_stairs_search` 不單獨交付，與主版共用）
2. 整理成一個壓縮檔（zip）
3. 給我一個簡短的「自評：哪幾張你覺得最滿意 / 哪幾張可能還能更好」

---

## 開始

請確認你已理解上述所有規則，回覆「了解，準備好了，請給我綠燈開始 `scene_start`」。
