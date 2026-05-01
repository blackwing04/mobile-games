# 示範劇本：辦公室的最後一夜

> 這份文件是「辦公室的最後一夜」劇本的可讀版本。
>
> **用途**：方便人類 / AI 編修文字。
> **規則**：可改文字（敘事、選項、結局描述），不可改結構（場景 ID、路由、骰子效果）。
> **完成後**：必須依照原 JSON Schema 輸出新版本給遊戲引擎使用。
>
> 對應 JSON：`assets/scenarios/demo_office.json`

---

## 📋 元資料

| 欄位 | 值 |
|------|-----|
| `id` | `demo_office` |
| `title` | 辦公室的最後一夜 |
| `author` | 示範劇本 |
| `estimated_minutes` | 10 |
| `start_scene` | `scene_start` |

## 🧠 資源系統

| ID | 名稱 | 圖示 | 起始 | 上限 |
|----|------|------|------|------|
| `san` | 神智 | 🧠 | 80 | 100 |
| `clue` | 線索 | 🔍 | 0 | — |

## 🎲 技能

| ID | 名稱 | 數值 |
|----|------|------|
| `observe` | 觀察 | 65 |
| `stealth` | 隱匿 | 50 |
| `lore` | 博學 | 55 |

---

# 🎬 場景樹

## `scene_start`

> 公司只剩你一個人。電腦時鐘顯示 23:47。
>
> 你伸了個懶腰，正準備關機，卻聽見茶水間傳來細微的啜泣聲。
>
> 這層樓只有你。

**選項：**

1. **「起身走向茶水間查看」** — 檢定 `觀察 (65)`
   - 大成功 → `scene_clear_view`（線索 +2）
   - 成功 → `scene_clear_view`（線索 +1）
   - 代價成功 → `scene_blurry_view`（神智 -10, 線索 +1）
   - 失敗 → `scene_no_view`
   - 大失敗 → `scene_end_first_look`（神智 -50）

2. **「戴上耳機假裝沒聽見」** → `scene_pretend`

---

## `scene_clear_view`

> 你緩緩探頭。茶水間的燈忽明忽暗。
>
> 是新來的實習生小婷，蹲在地上、面對牆壁哭泣。她沒有發現你。
>
> 但她的影子——投在那面牆上的影子——形狀不對。

**選項：**

1. **「走近輕聲呼喚她」** → `scene_approach`

2. **「退回去找警衛」** — 檢定 `隱匿 (50)`
   - 大成功 → `scene_call_security`（線索 +1）
   - 成功 → `scene_call_security`
   - 代價成功 → `scene_called_but_noticed`（神智 -5）
   - 失敗 → `scene_called_but_noticed`（神智 -10）
   - 大失敗 → `scene_end_caught`（神智 -30）

---

## `scene_blurry_view`

> 你眯著眼。茶水間的日光燈閃爍得厲害。
>
> 你只看見一個模糊的人影蹲著，發出細碎的、像是壓抑的笑聲——不，是哭聲？
>
> 你的太陽穴突突地跳。

**選項：**

1. **「試著回想公司是否曾發生過什麼」** — 檢定 `博學 (55)`
   - 大成功 → `scene_recall_full`（線索 +2）
   - 成功 → `scene_recall_partial`（線索 +1）
   - 代價成功 → `scene_recall_partial`（神智 -5）
   - 失敗 → `scene_pretend`
   - 大失敗 → `scene_pretend`（神智 -10）

2. **「不管了，收東西走人」** → `scene_leave_attempt`

---

## `scene_no_view`

> 你探頭，但茶水間裡空空如也。
>
> 是幻聽嗎？你揉揉眼睛，回到座位。
>
> 但走回辦公桌的路上，你聽見背後的茶水間又傳來啜泣聲。

**選項：**

1. **「再一次回頭看」** → `scene_blurry_view`
2. **「戴上耳機，加快收拾」** → `scene_leave_attempt`

---

## `scene_pretend`

> 你深呼吸，戴上耳機，把音量轉到最大。
>
> 但音樂中你仍然聽得見——那個聲音，越來越近。
>
> 你抬起頭。茶水間的人影站起來了，正緩緩朝你走來。

**選項：**

1. **「假裝盯著螢幕，靜止不動」** — 檢定 `隱匿 (50)`
   - 大成功 → `scene_passed`
   - 成功 → `scene_passed`
   - 代價成功 → `scene_passed`（神智 -15）
   - 失敗 → `scene_end_caught`（神智 -25）
   - 大失敗 → `scene_end_caught`（神智 -40）

2. **「猛然站起、衝向電梯」** → `scene_leave_attempt`

---

## `scene_recall_full`

> 你想起來了。
>
> 三年前，這層樓有個女實習生在加班時跳樓。當時公司強壓下來，沒上新聞。
>
> 她的座位——就是現在小婷的位置。

**選項：**

1. **「走出去，叫她的名字」** → `scene_approach`
2. **「立刻離開公司」** → `scene_leave_attempt`

---

## `scene_recall_partial`

> 你模糊地記得，公司前幾年好像出過事。
>
> 但具體是什麼，你想不起來。只記得那陣子主管交代「不要問」。
>
> 茶水間的聲音突然停了。

**選項：**

1. **「趁安靜離開」** → `scene_leave_attempt`
2. **「上前一探究竟」** → `scene_approach`

---

## `scene_approach`

> 你走過去，輕聲喊：「⋯⋯小婷？」
>
> 她抬起頭。是她的臉，但眼睛裡沒有東西。她對你微笑，慢慢說：
>
> 「你也會留下來陪我，對吧？」

**選項：**

1. **「一把拉起她的手腕往電梯衝」** → `scene_end_good`
2. **「答應她『好』」** → `scene_end_lost`
3. **「後退一步，慢慢說：『我先打電話給你媽媽』」** — 檢定 `博學 (55)`
   - 大成功 → `scene_end_good`
   - 成功 → `scene_end_good`
   - 代價成功 → `scene_end_neutral`（神智 -10）
   - 失敗 → `scene_end_neutral`（神智 -20）
   - 大失敗 → `scene_end_lost`

---

## `scene_call_security`

> 你壓低呼吸，退回工位旁，撥了警衛室的內線。
>
> 十分鐘後，老警衛搖著手電筒上樓，茶水間裡——什麼也沒有。
>
> 他沉默了一會，輕聲說：「⋯⋯不是第一次了。明天你就請假吧。」

**選項：**

1. **「默默收拾離開」** → `scene_end_neutral`

---

## `scene_called_but_noticed`

> 你才剛拿起電話，那聲音就停了。
>
> 你抬頭——茶水間的燈滅了。整層樓陷入黑暗。
>
> 只剩你電腦螢幕的微光，和走廊盡頭緩慢逼近的腳步聲。

**選項：**

1. **「衝向電梯」** → `scene_leave_attempt`

2. **「躲到桌子底下」** — 檢定 `隱匿 (50)`
   - 大成功 → `scene_end_neutral`
   - 成功 → `scene_end_neutral`
   - 代價成功 → `scene_end_caught`（神智 -20）
   - 失敗 → `scene_end_caught`
   - 大失敗 → `scene_end_caught`

---

## `scene_passed`

> 你屏住呼吸。腳步聲在你身後停下，然後⋯⋯經過了。
>
> 你不敢轉頭。直到天亮，你才發現自己的指甲在手心裡留下了五道血痕。
>
> 第二天，你交了辭呈。

**選項：**

1. **「結束」** → `scene_end_neutral`

---

## `scene_leave_attempt`

> 你抓起包包衝向電梯。
>
> 按鈕亮起。十一樓⋯⋯十二樓⋯⋯叮——
>
> 門開了。電梯裡有人。是小婷，她笑著說：「你也加班到這麼晚啊？」

**選項：**

1. **「進電梯」** → `scene_end_lost`

2. **「退一步、按樓梯間的門」** — 檢定 `隱匿 (50)`
   - 大成功 → `scene_end_good`
   - 成功 → `scene_end_neutral`
   - 代價成功 → `scene_end_neutral`（神智 -15）
   - 失敗 → `scene_end_caught`
   - 大失敗 → `scene_end_caught`

---

# 🎭 結局

## `scene_end_good`（好結局：破曉之前）

> 你拉著她、半拖半抱地下了十二層樓梯。
>
> 警衛室前，她忽然清醒、不知道自己怎麼了。你沒告訴她剛才的事。
>
> 隔天小婷請了長假回老家。你知道她是誰，也知道她不是她。但至少——你都活著走出了那棟大樓。

---

## `scene_end_neutral`（中性結局：倖存）

> 你回到家，洗了一個很長很長的澡。
>
> 那夜的事你誰也沒說。第二天上班，茶水間又恢復成普通的茶水間，公司沒有任何異樣。
>
> 只是從此之後，你再也沒有加班到晚上十一點之後。

---

## `scene_end_caught`（壞結局：她找到你了）

> 你聽見耳邊有溫熱的呼吸。
>
> 「找到你了。」
>
> 隔天早上，清潔阿姨在茶水間發現你。你坐在地上，面對牆壁，反覆地、輕聲地哭。
>
> 沒有人能讓你說話。

---

## `scene_end_lost`（壞結局：陪她）

> 你說了「好」。
>
> 她笑得很開心。十二樓的窗戶是開的，夜風吹進來。
>
> 你跟著她走過去。腳步輕得像棉花。
>
> ——隔天，公司又少了一個人。

---

## `scene_end_first_look`（壞結局：別回頭看）

> 你只是不小心，多看了一眼。
>
> 茶水間裡那個東西的臉，從此再也離不開你的腦海。
>
> 你辭職了、搬家了、換了城市、剃了光頭。但每天半夜十一點四十七分，你都會在床上坐起，朝牆角微笑。

---

## 🗺️ 場景流程圖（給編輯參考）

```
scene_start
  ├─ 觀察檢定 ────┬─ critical/success → scene_clear_view
  │              ├─ partial          → scene_blurry_view
  │              ├─ failure          → scene_no_view
  │              └─ fumble           → 結局（別回頭看）
  └─ 戴耳機 → scene_pretend

scene_clear_view ─┬─ 走近 → scene_approach
                  └─ 隱匿檢定 ──┬─ ok → scene_call_security → 結局（倖存）
                              └─ ng → scene_called_but_noticed
                                       └─ 躲檢定 → 結局（倖存 / 找到你了）

scene_blurry_view ─┬─ 博學檢定 ──┬─ ok → scene_recall_full → 接近 / 離開
                  │            └─ ng → scene_pretend
                  └─ 收拾 → scene_leave_attempt

scene_pretend ─┬─ 隱匿檢定 → scene_passed → 結局（倖存）
              └─ 衝電梯 → scene_leave_attempt

scene_approach ─┬─ 拉走 → 結局（破曉）
               ├─ 答應 → 結局（陪她）
               └─ 博學檢定 → 結局（破曉 / 倖存 / 陪她）

scene_leave_attempt ─┬─ 進電梯 → 結局（陪她）
                    └─ 樓梯間 → 結局（破曉 / 倖存 / 找到你了）
```

---

> **編輯重點提示**：
> - 文字風格參考 PTT marvel 板、Cthulhu 中篇、台灣都市怪談
> - 第二人稱「你」、現在式
> - 短句節奏、留白美學、心理恐怖優先於視覺恐怖
> - 不要過度解釋怪物來源
> - 對白要日常、不戲劇化
