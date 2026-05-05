# Ch2「下課之後」v2 精修版 — WIP draft

> 🚧 **這是 Gemini 精修中的 v2 版本累積區，未整合到 `ch02_school.json`。**
>
> 工作流：Gemini 寫一場 → 使用者監督拍板 → 累積到本檔 → 全部寫完一次性整合（補 5 階 + routing 驗證 + 同步 canonical MD）→ 覆蓋 v1。
>
> v1 (現行 JSON) 跟 v2 並存期間，Web / APK 跑的還是 v1，玩家無感。

---

## 📊 場景預算

| 項目 | 計數 |
|------|------|
| 黃金預算（EPISODE_BLUEPRINT） | 17-22 |
| v2 已收 narrative | 5 (start / wait_classroom / classroom_wake / door_stuck / phone_again) |
| v2 已引用未定義 | 8 (scare_clock / door_locked_fate / hide_success / hide_fail / monster_glimpse / phone_drop / phone_static / final_ascent) |
| **Route A 已累積** | **13**（光這條線就已 13）|
| Route B / C / 結局 / router | 尚未開始 |
| 樂觀總計預估 | 30+ |

> ⚠️ 整合期須壓縮 30-40%。已知壓縮機會：scene_door_stuck 的 6 個 next（3 成功 + 3 失敗）可併成 2 個（成功 → 既有 corridor_search、失敗 → 新合併場景 caught_in_classroom）。

---

## 🔄 進度追蹤

### 既有場景（v1 → v2 重寫狀態）

| Scene ID | v1 狀態 | v2 狀態 | 備註 |
|----------|--------|---------|------|
| scene_start | ✅ JSON 已套 v2 | ✅ 已收 | 含「別理會任何人的聲音」伏筆 |
| scene_wait_classroom | v1 在 JSON | ✅ 已收 | 3 選項：看時鐘 / 撞門 / 趴睡 |
| scene_phone_again | v1 在 JSON | ✅ 已收 | 含「天台」誘導 + 哥哥語氣反差 |
| scene_walk_to_rooftop | v1 在 JSON | ⏳ 等寫 | Wave 2 終局 |
| scene_corridor_search | v1 在 JSON | ⏳ 等寫 | Route B 入口 |
| scene_corridor_deep | v1 在 JSON | ⏳ 等寫 |  |
| scene_mirror_self | v1 在 JSON | ⏳ 等寫 | Wave 3 終局 |
| scene_leave_school | v1 在 JSON | ⏳ 等寫 | Route C 入口 |
| scene_phone_at_gate | v1 在 JSON | ⏳ 等寫 |  |
| 4 個 router (dispatch) | v1 在 JSON | 通常不需改 | 視結局數值有沒有調再說 |
| 7 個結局 | v1 在 JSON | ⏳ 等寫 |  |

### 新增場景（v2 引入，v1 沒有）

| Scene ID | 引用來源 | 狀態 |
|----------|---------|------|
| scene_classroom_wake | scene_wait_classroom 趴睡成功 | ✅ 已收 |
| scene_scare_clock | scene_wait_classroom 看時鐘失敗 | ⏳ 等 narrative |
| scene_door_stuck | scene_wait_classroom + scene_classroom_wake 撞門失敗 | ✅ 已收 |
| scene_phone_static | scene_classroom_wake 打電話失敗 | ⏳ 等 narrative |
| scene_door_locked_fate | scene_door_stuck 撞前門失敗 | ⏳ 等 narrative |
| scene_hide_success | scene_door_stuck 躲桌底成功 | ⏳ 等 narrative |
| scene_hide_fail | scene_door_stuck 躲桌底失敗 | ⏳ 等 narrative |
| scene_monster_glimpse | scene_door_stuck 手電筒成功 | ⏳ 等 narrative |
| scene_phone_drop | scene_door_stuck 手電筒失敗 | ⏳ 等 narrative |
| scene_final_ascent | scene_phone_again 三選項共同 next | ⏳ 等 narrative |

---

## 📋 Open questions（等使用者拍板）

| # | 問題 | 影響 |
|---|------|------|
| 1 | scene_classroom_wake observe 成功 `clue+1` — clue 來源不對應 IP_BIBLE 4 個 canon「反差跡象」。要 (a) 擴 canon list 加新跡象 / (b) 改成 `san+5` 非 clue 獎勵？ | 真結局 (clue ≥3) 達成難度 |
| 2 | Wave 1 顯現時機：scene_start 已經寫了時鐘停 + 影子融入陰影；scene_wait_classroom 又加秒針顫動 + 夕陽變血色 — Wave 1 加壓快，後面 Wave 2/3 對比強度會否被稀釋？ | 整體節奏 |
| 3 | 「趴著睡」失敗 → `scene_end_lost_school`：但「無盡校園」結局 canon 是「跟著鏡中我走」(Wave 3 終局)。趴睡導致無盡校園邏輯不順 — 要 (a) 接受混用 / (b) 新增「夢魘」結局 / (c) 改走 `scene_end_curse_spread`？ | 結局意涵一致性 |

---

## 🚧 整合到 v1 時必做的清單

整合 v2 → `ch02_school.json` 時：

1. ☐ 所有 skill_check 補 5 階（critical_success / success / partial / failure / fumble）— Gemini 通常只給 2 階。整合時參考既有 v1 effects 比例補
2. ☐ Routing 完整性 — `flutter test` 跑 JSON integrity，確認所有 next 都指到實際 scene
3. ☐ Skill ID 校驗 — 全部 skill_check 用的 skill 都在統一 8 技能表內
4. ☐ 同步 `ch02_school_canonical.md`
5. ☐ 確認 episode = 2、truth_ending_id = scene_end_truth、resources 沒變
6. ☐ 整合完跑一輪 flutter analyze + flutter test

---

# 已收場景（依寫作順序累積）

## scene_start (v2 ✅ **已整合進 JSON**)

> 內容已寫進 `assets/scenarios/ch02_school.json` + `ch02_school_canonical.md`。本檔不重複貼。

選項：

1. **「聽哥哥的話，留在教室等他」** → scene_wait_classroom
2. **「電話和時鐘都太奇怪了，出去找哥哥」** → scene_corridor_search
3. **「我又不是小孩子了，有什麼事回家再講不行喔，直接回家」** → scene_leave_school

---

## scene_wait_classroom (v2 ✅ 已收，待整合)

> 妳嘆了口氣，坐回座位，把耳機塞進耳朵。妳決定給哥哥五分鐘，如果他沒出現，妳就自己去搭公車回家。
>
> 教室門口傳來幾聲零星的腳步聲。最後一個離開的同學在拉上門前，隔著門窗跟妳揮了揮手，口型似乎是在說「明天見」。妳點了點頭，勉強擠出一個微笑，心裡卻在想：這學校今天靜得讓人耳鳴。
>
> 妳再次抬頭看向黑板旁的掛鐘。
>
> 指針依然停在 23:47。但這一次妳注意到，那根黑色的秒針正在劇烈地顫動著。它像是想要往前跳，卻被某種看不見的力量死死拽住，在寂靜的教室裡發出極其細微的「喀——喀——」聲。
>
> 妳皺起眉，下意識地掏出手機確認：17:03。
>
> 才過了三分鐘。但妳轉頭看向窗外，那抹原本應該緩緩沉落的橘紅夕陽，現在竟然像是融化的蠟一樣，在天邊拉出了幾道詭異的血色條紋。
>
> 妳看著那些斜射進教室的光影，光影的夾角和妳剛才坐下時似乎一模一樣，沒有絲毫移動。一種強烈的違和感像冷水般從腳底竄上脊椎，妳感到一陣莫名的不適，連呼吸都變得有些侷促。

選項（**Gemini 原寫 2 階，整合時要補 5 階**）：

1. **「走過去仔細看那個掛鐘到底怎麼了」** — observe 檢定
   - 成功 → scene_phone_again [clue+1]
   - 失敗 → scene_scare_clock [san-15]
2. **「這地方待不下去，不等了，立刻離開教室」** — strength 檢定（使用者指示：原寫 stealth 改 strength）
   - 成功 → scene_corridor_search
   - 失敗 → scene_door_stuck [san-10]
3. **「哥哥說過別理會聲音⋯⋯我乾脆趴著睡一下好了」** — observe 檢定（待商議：邏輯上比較像 common_sense / resolve）
   - 成功 → scene_classroom_wake
   - 失敗 → scene_end_lost_school（**Open Q3：邏輯爭議**）

---

## scene_classroom_wake (v2 ✅ 已收，新場景)

> 妳的手枕在課桌上，耳機裡的旋律漸漸變得遙遠。就在快要失去意識進入夢鄉時，妳的身體猛然抽搐了一下。
>
> 那是一種類似墜落感的生理警訊。妳沒有聽到任何聲音，但冷汗瞬間浸透了妳的後背。妳僵坐在位子上不敢動彈，那種感覺極其強烈——彷彿在教室後方那些看不見的陰影角落裡，正有人在暗處死死地盯著妳，目光冰冷且充滿惡意。
>
> 妳驚慌地抬起頭，下意識地看向手錶：17:15。
>
> 按照常理，現在應該是夕陽最亮的時候，但窗外的陽光卻不知在何時消失了。整間教室陷入了一片死寂的黑暗，那種黑並非入夜後的自然黑，而是一種像墨水般濃稠、帶著窒息感的混濁。
>
> 剛才那種暖橘色的光影完全不見了，取而代之的是手錶螢幕發出的微弱白光，在絕對的黑暗中顯得孤零零的。妳環顧四周，課桌椅的輪廓在黑暗中扭曲變形，像是一座座沉默的墓碑。
>
> 妳感覺喉嚨乾澀，心臟狂跳的聲音在寂靜的教室裡震耳欲聾。
>
> 妳猛地抓起書包站了起來，椅子在空曠的教室裡劃出一聲刺耳的「吱——」聲。這聲音大得誇張，彷彿在向暗處那個「窺視者」宣告妳已經醒了。

選項（**Gemini 原寫 2 階，整合時要補 5 階**）：

1. **「不敢再待下去了，用盡全力撞開門衝出去！」** — strength 檢定
   - 成功 → scene_corridor_search
   - 失敗 → scene_door_stuck [san-10]
2. **「冷靜點，先打電話給哥哥問他在哪」** — observe 檢定
   - 成功 → scene_phone_again [clue+1]（**Open Q1：clue 來源非 canon 反差跡象**）
   - 失敗 → scene_phone_static [san-5]

---

## scene_door_stuck (v2 ✅ 已收，新場景)

> 妳走到教室後門，伸手握住把手向下按，準備離開這間讓妳越來越不安的空間。
>
> 沒反應。把手像是卡死了一樣一動不動。
>
> 妳愣了一下，心想大概是這棟舊大樓的門鎖太老舊，或者是門板受潮變形了。妳稍微加重了力道，試著再次拉動門把，但門扉依然緊緊地咬在門框裡，毫無動靜。
>
> 妳皺起眉，調整了一下姿勢，雙手扣住門把並用腳抵住牆壁，深吸一口氣後拼命向後一拽——
>
> 一次、兩次、三次。除了金屬件在妳用力下發出乾澀、尖銳的磨擦聲外，這扇門依然沉重得像是跟整面牆壁焊死在一起。妳的呼吸漸漸變得急促，掌心因為過度用力而感到一陣刺痛。
>
> 這不合理。就算門板變形，連門把都完全動不了也太扯了。
>
> 就在妳腦中閃過這個念頭，準備轉向教室前門試試看時，背後的黑暗中傳來了一聲輕響。
>
> 「喀。」
>
> 是掛鐘。那個停在 23:47 的秒針發出了咬碎枯木般的聲音。
>
> 緊接著，另一種聲音在死寂的教室裡響起：那是一種濕漉漉的東西，正貼著磨石子地板緩慢磨擦的聲音。它從教室最後一排的陰影裡，一吋一吋地，朝著正背對黑暗的妳移動過來。

選項（**Gemini 原寫 2 階，整合時要補 5 階**）：

1. **「後門打不開就去前門！用盡全身力氣去撞！」** — strength 檢定
   - 成功 → scene_corridor_search
   - 失敗 → scene_door_locked_fate [san-20]
2. **「別管門了，快躲進最近的課桌底下！」** — stealth 檢定
   - 成功 → scene_hide_success
   - 失敗 → scene_hide_fail
3. **「（強壓恐懼）是誰在那裡？打開手機手電筒照過去！」** — observe 檢定
   - 成功 → scene_monster_glimpse [clue+1, san-15]
   - 失敗 → scene_phone_drop

---

## scene_phone_again (v2 ✅ 已收，覆蓋 v1)

> 就在那股冰冷的感覺快要貼上妳的後頸時，手心裡的手機猛然震動，強烈的震感讓妳整隻手發麻。螢幕閃爍著:「哥哥」。
>
> 妳像抓到救命稻草般按下了接聽鍵，電話那頭安靜得詭異，沒有剛才的風聲，只有一種規律的、像是有人在空曠大廳裡緩步移動的微弱迴響。
>
> 「妹，妳還在教室嗎？」哥哥的聲音聽起來輕鬆、溫和，甚至帶著一點笑意，跟三分鐘前那種焦慮到近乎窒息的語氣完全不同。「我到校門口了，這裡的夕陽真的好漂亮，雲都是金色的。妳慢慢收拾，我現在上去天台等妳，我們好久沒一起看風景了，快上來。」
>
> 妳聽著那溫柔的嗓音，看著眼前這間陷入死寂黑暗、連門把都扭不動的教室。
>
> 哥哥剛才說⋯⋯夕陽很漂亮？
>
> 就在妳遲疑的瞬間，背後那個「喀、喀」的掛鐘聲突然加快了。原本打不開的教室門，竟然在此時發出「喀擦」一聲，自己緩緩推開了一道縫隙，露出外面那條血紅色的長廊。

選項（**Gemini 原寫 2 階，整合時要補 5 階**）：

1. **「（質問）你剛才不是叫我別出去嗎？為什麼現在又要我去天台？」** — observe 檢定
   - 成功 → scene_final_ascent [clue+1]（電話背景音與掛鐘聲完全重合）
   - 失敗 → scene_final_ascent [san-10]（對面沉默後的尖銳笑聲）
2. **「（求救）哥！這學校不對勁！你快點過來接我！」** → scene_final_ascent
3. **「好，我現在上去找你⋯⋯（放下手機，神情恍惚）」** → scene_final_ascent（**Gemini 註：自動判定失敗，朝壞結局偏移** — 整合時加 san 大扣 + 旗標）
