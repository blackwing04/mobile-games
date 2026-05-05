# Ch2「下課之後」v2 精修版 — WIP draft

> 🚧 **這是 Gemini 精修中的 v2 版本累積區，未整合到 `ch02_school.json`。**
>
> 工作流：Gemini 寫一場 → 使用者監督拍板 → 累積到本檔 → 全部寫完一次性整合（補 5 階 + routing 驗證 + 同步 canonical MD）→ 覆蓋 v1。
>
> v1 (現行 JSON) 跟 v2 並存期間，Web / APK 跑的還是 v1，玩家無感。

---

## 🎯 線路收斂策略（使用者拍板，整合期遵循）

Route A 已打通 = 大部分路也打通了。其他線路用以下方式收斂，避免場景爆炸：

| 線路 | 收斂方式 |
|------|---------|
| **Route A 主線**（留教室）| 已收齊 — wait_classroom → phone_again → final_ascent → climax → 三結局 |
| **Route B**（找哥哥 → 困永遠的樓梯）| 玩家想下樓但**永遠到不了一樓**（樓層 F 標誌全變掛鐘 23:47）+ 背後被東西盯。1 場 endless_stairs + 2 選項：聽哥哥去天台 → 接主版 phone_again 回主線；打火災警鈴 → 中性偏壞《校警救援》結局 |
| **Route C**（試圖離校 → 被詛咒擋）| 玩家點 scene_start Choice 3「直接回家」→ **詛咒不讓任何人逃**，直接 → `scene_door_stuck_impatient` 變體 → 併進 Route A 主線。**完全不寫 leave_school / phone_at_gate** |
| **detour 失敗**（door_locked_fate / hide_fail / phone_drop / scare_clock 等）| 大多直通 scene_bad_ending_lost；或 san 大扣後 loop back 主流程 |
| **detour 成功**（hide_success / monster_glimpse 等）| 折回 scene_corridor_search 或 scene_phone_again 主軸 |

### 「哥哥第二通電話」萬能 hook

因為 scene_start 已埋「別理會任何人的聲音」伏筆，第二通電話自帶「真的還是假的」的張力 — 玩家自然會被吸進主線。可以在 Route B/C 任何脫線點插入，讓玩家有機會回到 Route A 主軸。

### 整合後場景預估

- Route A 主線：5（已收）
- Route A 真結局 path：1（已收）
- Route B 探索 + hook：2-3
- Route C 離校 + hook：1-2
- 結局：4-5（真結局 / normal_escape / bad_lost / lost_soul / curse_spread / safe_home）
- Router / dispatcher：2-3

**合計約 17-22 場，正好回到黃金量** 🎯

---

## 📊 場景預算

| 項目 | 計數 |
|------|------|
| 黃金預算（EPISODE_BLUEPRINT） | 17-22 |
| v2 已收 narrative | 18 (Route A + B + C 合流，含 endless_stairs + rescued《餘震》)|
| v2 已引用未定義 | 5 (scare_clock / monster_glimpse / phone_static / phone_again_stairs / endless_stairs_search 共用 narrative)|
| **Route A + B + C 合流累積（含結局 + SMS + 4 phone variants + 2 door variants + 2 stairs variants）** | **22** |
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
| ~~scene_corridor_search~~ | v1 在 JSON | ❌ **廢棄** — Route B 改設計為「困永遠的樓梯」(scene_endless_stairs)，走廊探索場景不寫 |
| ~~scene_corridor_deep~~ | v1 在 JSON | ❌ **廢棄** — 同上 |
| ~~scene_mirror_self~~ | v1 在 JSON | ❌ **廢棄** — Wave 3 鏡中我合併到 climax 主線（已在 scene_the_climax 處理）|
| ~~scene_leave_school~~ | v1 在 JSON | ❌ **廢棄** — 使用者拍板：Route C 改為「試圖離校但被詛咒擋」，直接接 door_stuck_impatient |
| ~~scene_phone_at_gate~~ | v1 在 JSON | ❌ **廢棄** — 同上，沒有校門口接電話橋段 |
| 4 個 router (dispatch) | v1 在 JSON | 通常不需改 | 視結局數值有沒有調再說 |
| 7 個結局 | v1 在 JSON | ⏳ 等寫 |  |

### 新增場景（v2 引入，v1 沒有）

| Scene ID | 引用來源 | 狀態 |
|----------|---------|------|
| scene_classroom_wake | scene_wait_classroom 趴睡成功 | ✅ 已收 |
| scene_scare_clock | scene_wait_classroom 看時鐘失敗 | ⏳ 等 narrative |
| scene_door_stuck | scene_wait_classroom + scene_classroom_wake 撞門失敗（已不安 perspective）| ✅ 已收 |
| scene_door_stuck_impatient | **NEW**：scene_start Choice 3 直接回家入口（不耐煩 perspective）— 跟 scene_door_stuck 共用後段，僅開頭微調 | ✅ 已收 |
| scene_endless_stairs | **NEW Route B 主場景**：wait_classroom Choice 2 撞門成功入口。永遠下不到一樓 + F 標誌變 23:47 + 背後被盯。選項 1 「轉念聽哥哥，去天台」 → phone_again_stairs；選項 2 「打火災警鈴」→ scene_end_rescued | ✅ 已收 narrative |
| scene_endless_stairs_search | **NEW**：scene_start Choice 2 入口（主動找哥哥 perspective）— 跟 endless_stairs 共用 narrative，選項 1 改為「打給哥哥」→ phone_again_stairs（主動撥）；選項 2 共用「打火災警鈴」 | ✅ 已收 (共用 narrative) |
| scene_phone_again_stairs | **NEW phone_again 變體**：endless_stairs 兩變體選項 1 共同 next。樓梯間 perspective — narrative 同主版但**拿掉「教室門推開露出血紅長廊」結尾段** | ⏳ 整合期可從主版 derive |
| scene_phone_static | scene_classroom_wake 打電話失敗 | ⏳ 等 narrative |
| ~~scene_door_locked_fate~~ | ~~scene_door_stuck 撞前門失敗~~ | ❌ 拿掉 — 改直接接 scene_end_curse_spread |
| scene_phone_again_hide | scene_door_stuck 躲桌底成功（重命名自 scene_hide_success，narrative 微縮 + 選項外提）| ✅ 已收 |
| scene_phone_again_escape | scene_door_stuck 撞前門成功（**Gemini 改 routing**：原本 corridor_search → 改回 Route A 主線）| ✅ 已收 |
| ~~scene_hide_fail~~ | ~~scene_door_stuck 躲桌底失敗~~ | ❌ 拿掉 — 改直接接 scene_end_curse_spread |
| scene_monster_glimpse | scene_door_stuck 手電筒成功 | ⏳ 等 narrative |
| ~~scene_phone_drop~~ | ~~scene_door_stuck 手電筒失敗~~ | ❌ 拿掉 — 改直接接 scene_end_curse_spread |
| scene_final_ascent | scene_phone_again 三選項共同 next | ✅ 已收 |
| scene_the_climax | scene_final_ascent 兩選項 4 結果共同 next | ✅ 已收 |
| scene_true_ending / scene_bad_ending_fall / scene_normal_ending | scene_the_climax 三選項分流 | ⚠️ Gemini 命名，整合時對應 v1 既有 scene_end_truth / scene_end_lost_soul / scene_end_rescued |
| scene_rejection_and_escape | scene_the_climax 第 1 選項真結局路徑 | ✅ 已收（含追逐+敏捷檢定，把使用者 design intent 的 2 場合成 1 場） |
| scene_true_rescue | scene_rejection_and_escape 條件成功 | ✅ 已收 → 整合對應 scene_end_truth |
| scene_normal_escape | scene_rejection_and_escape 一般成功 | ✅ 已收 → 整合對應 scene_end_safe_home（妹妹自己逃出）|
| scene_bad_ending_lost | scene_rejection_and_escape 失敗 | ✅ 已收 → 整合對應 scene_end_lost_school（失蹤，非墜樓）|
| scene_sms_or_call | clue=2 觸發點被 dispatcher 強制插入 | ✅ 已收 — 妹妹 recap 兩條反差跡象，2 選：傳簡訊（sms_sent+1）/ 撥電話（雜訊收線）|

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
2. **「電話和時鐘都太奇怪了，出去找哥哥」** → scene_endless_stairs_search（**改 routing**：原 corridor_search → endless_stairs_search，Route B 重新設計為「困永遠的樓梯」）
3. **「我又不是小孩子了，有什麼事回家再講不行喔，直接回家」** → scene_door_stuck_impatient（**詛咒擋下，沒能離開**）

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
   - 成功 → scene_endless_stairs（**改 routing**：原 corridor_search → endless_stairs，Route B 重新設計）
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
   - 成功 → scene_endless_stairs（**改 routing**：原 corridor_search → endless_stairs）
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
   - 成功 → scene_phone_again_escape（**routing 改：原 corridor_search → 改 phone_again_escape，詛咒越纏越深 = 撞出去也被電話拉回 Route A 主線**）
   - 失敗 → scene_end_curse_spread [san-20]
2. **「別管門了，快躲進最近的課桌底下！」** — stealth 檢定
   - 成功 → scene_phone_again_hide（rename 自 scene_hide_success）
   - 失敗 → scene_end_curse_spread [san-25]
3. **「（強壓恐懼）是誰在那裡？打開手機手電筒照過去！」** — observe 檢定
   - 成功 → scene_monster_glimpse [clue+1, san-15]
   - 失敗 → scene_end_curse_spread [san-25]

> 📝 **routing 不一致說明（使用者拍板：A 接受）**：
> - `scene_wait_classroom` Choice 2 撞門 strength 成功 → `scene_endless_stairs`（進 Route B 困樓梯）
> - `scene_door_stuck` Choice 1 撞前門 strength 成功 → `scene_phone_again_escape`（Route A 收回）
>
> Narrative 解釋：door_stuck 是「已被詛咒纏深一次」狀態（門變沉重 + 怪聲音逼近），撞出去也被電話拉回主線；wait_classroom 撞門是「還沒被纏深」，可進 Route B。詛咒越纏越深 = 自由度遞減，IP-canon 對齊。

---

## scene_door_stuck_impatient (v2 ✅ 已收，新變體 — Route C 入口 perspective)

> 妳不耐煩的走到教室後門，伸手握住把手向下按，準備離開教室。
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

選項（**與 scene_door_stuck 完全共用同一組選項**）：

跟 scene_door_stuck 三個選項一致（撞前門 strength / 躲桌底 stealth / 手電筒 observe），routing 一致。

> 📝 **變體 family**：scene_door_stuck (已不安 perspective) + scene_door_stuck_impatient (不耐煩 perspective)。**唯一差異 = 開頭一句**（「準備離開這間讓妳越來越不安的空間」vs「不耐煩的⋯⋯準備離開教室」）。整合期共用同一張圖、共用後段 narrative、共用後段選項與 routing。

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

---

## scene_final_ascent (v2 ✅ 已收，新場景)

> 妳的話音落下後，電話那頭遲遲沒有回應。
>
> 妳保持著通話的姿勢，耳朵緊貼著冰冷的手機螢幕。原本應該傳來哥哥回覆的頻道，此時卻安靜得像是一個被抽乾空氣的黑洞，連剛才那種微弱的迴響都消失得無影無蹤。
>
> 「⋯⋯喂？哥？你有在聽嗎？」
>
> 妳忍不住再次對著話筒追問，聲音在死寂的教室裡顯得格外單薄。回應妳的依然只有那種讓人背脊發涼的沈默。緊接著，手機螢幕無預警地閃爍了兩下，隨即徹底熄滅，化為一片漆黑的鏡面。
>
> 就在通訊中斷的瞬間，那扇剛才妳怎麼拉都拉不動的門，突然發出「喀擦」一聲，自己緩緩打開了。外面透進來的暗紅光線像是一條血紅色的舌頭，鋪在漆黑的教室地板上。
>
> 妳知道不能再待下去了，無論天台上有什麼，都比留在這間被惡意填滿的教室好。妳深吸一口氣，抓緊書包，跌跌撞撞地衝出教室。
>
> 走廊的景象讓妳頭皮發麻——原本熟悉的長廊似乎被強行「拉長」了，兩側的教室門像是一排排歪斜的墓碑。那種濃郁得近乎黏稠的紅光從窗外滲透進來，將地面塗滿了濕滑的暗紅色，每跑一步，腳下都會發出「噗滋、噗滋」的怪異磨擦聲。
>
> 「這到底怎麼回事⋯⋯」妳邊跑邊在心裡嘀咕，試圖理清這一切詭異的現象。
>
> 妳衝進樓梯間，記憶中牆上原本標示著「4F」的字樣，現在卻莫名被換成一個掛鐘，上面依然停留在 23:47。妳不敢停下來思考，只能不斷往上爬，那是唯一還有光亮的地方。
>
> 終於，妳推開了通往天台的那扇沉重鐵門。
>
> 強風瞬間灌進妳的領口，凍得妳打了個寒顫。妳看見在那片血紅色的天空下，一個熟悉的背影正靜靜地站在天台邊緣，背對著妳。
>
> 那是哥哥。他穿著早上出門時的那件外套，手裡拿著一支妳最愛喝的手搖飲，冰塊撞擊杯壁的「叮、叮」聲，在狂風中竟然聽得清清楚楚，彷彿那聲音是直接在妳腦袋裡響起的。

選項（**Gemini 原寫 2 階，整合時要補 5 階**；**兩個選項都 observe，整合時可考慮第 2 個換 listen / common_sense 做差異化**）：

1. **「（止步）你剛才不是說你在校門口？為什麼現在在這裡？」** — observe 檢定
   - 成功 → scene_the_climax [clue+1]（影子長度與光影方向完全不符 + 聲音不自然的重音疊加）
   - 失敗 → scene_the_climax [san-10]（風沙迷眼，沒看清對方緩慢轉頭時頸部清脆骨裂聲）
2. **「（觀察）先不要靠近，觀察周圍。」** — observe 檢定
   - 成功 → scene_the_climax [clue+1]（飲品封膜標籤寫著 23:47，天台圍欄緩緩向外融化）
   - 失敗 → scene_the_climax [san-10]（腳下天台地面微微跳動，像有心跳）

---

## scene_the_climax (v2 ✅ 已收，新場景 — Route A 收斂結局 dispatcher)

> 透過天台機房玻璃上的倒影，他看見了站在門口的妳。那個背影微微一頓，接著，他緩緩地轉過身來。
>
> 那張臉確實是妳熟悉的哥哥，他舉起拿著手搖飲的手對著妳搖了搖。
>
> 「妹，妳在那邊發什麼呆？過來呀，我買了妳最愛喝的飲料，妳看這夕陽多美，我們看完再一起回家吧。」
>
> 他溫柔地說著，但妳注意到他的嘴型與聲音有著詭異的延遲，那種殘響像是不斷重疊的幻聽。此時，他腳下的影子竟像怪物般，正沿著天台地板朝妳緩緩爬過來。
>
> 見妳遲遲不肯過去，他指了指手腕上的手錶，那上面的指針正瘋狂倒轉，最後死死地卡在 23:47。
>
> 「快點，妹妹。妳再不過來⋯⋯夕陽就要下山了喔。」

最終決斷（**Gemini 原寫 1-2 階，整合時要：補 5 階 / id 對應 v1 結局 / skill rename / clue 門檻校準 / san 雙軸**）：

1. **「你不是我哥⋯⋯（根據線索識破謊言）」** — `[需 Clue ≥ 2]`
   → 🚧 **使用者 design intent**：識破後不直通真結局，中間還要 2 場 — 追逐場景 + 一道檢定。整合時 Choice 1 路徑：識破 → 追逐場景（Gemini 待寫）→ 檢定場景（Gemini 待寫）→ scene_end_truth
   → 最終對應 scene_end_truth（**整合：加 san ≥ X 條件 + clue 門檻校準到 IP canon ≥3**）
2. **「相信眼前的哥哥」** → scene_bad_ending_fall（**整合：對應 scene_end_lost_soul + 加 san 大扣**）
3. **「（閉上眼大喊）這一切都是假的！通通消失！」** — willpower 檢定（**整合：rename 為 resolve；補 5 階**）
   - 成功 → scene_normal_ending（**整合：對應 scene_end_rescued / scene_end_safe_home 看情境**）
   - 失敗 → 待 Gemini 補（**整合建議：失敗 → scene_end_lost_soul 或 scene_end_curse_spread**）

> ⚠️ **IP-canon 風險**：第 1 選項 narrative 提到「妳會聽見真正的電話鈴聲將妳喚醒」 — 整合時 narrative 要明確寫成「真哥哥真電話打斷詛咒」，避免被讀成「最後是夢」（IP_BIBLE 6.2「嚴格避免」第 7 條）。

---

## 🆕 SMS 機制（使用者新引入 design — 整合期 engine 處理方案）

**設計目標**：真結局條件 = `clue ≥ 2 AND sent_sms`。當玩家拿到 clue 第 2 次時，無論在哪個場景，下一步強制進「妹妹感到不對勁 → 傳簡訊 / 打電話」選擇場景。傳簡訊設旗標、打電話跳「無回應」訊息後自然回原本流程。

**整合期 engine 方案（不需改引擎 code）**：

1. **新增隱藏 resource `sms_sent`**（initial: 0, max: 1）— UI 不顯示。IP_BIBLE 7.1 規定 san/clue 跨章一致是「玩家認知」考量；hidden flag 不在 UI 上不違反此原則
2. **「強行插入」用 dispatcher 模擬**：每個 clue+1 的 effect 後，原本指向的 next 改為 `scene_dispatch_clue_check`（新增 router）
   - dispatcher 條件：`if_resource_at_least: { clue: 2 }` AND `if_resource_below: { sms_sent: 1 }` → 跳 `scene_sms_or_call`
   - 預設 → 跳原本目標
3. **三層 outcome (失敗/普通/真) 的雙軸**：擲過 → next 進 `scene_dispatch_routeA_climax_check` (新增 router) → 看 `clue ≥ 2 AND sms_sent ≥ 1` 真 / 否則普通

整合期我自己處理，不擋 Gemini 寫作流程。

---

## scene_rejection_and_escape (v2 ✅ 已收，新場景 — Route A 真結局路徑追逐+檢定)

> 「你不是我哥。」
>
> 妳的話音剛落，空氣瞬間凝固。前一秒還溫柔微笑的「哥哥」，臉部肌肉開始像融化的蠟一樣垮下，那張臉迅速乾縮成一個漆黑的深淵。他手裡的那杯手搖飲「啪」地掉落在地，流出的卻是帶著腐臭味的黑色黏液。
>
> 「⋯⋯被⋯⋯發現了⋯⋯啊⋯⋯」
>
> 那聲音化作尖銳的嘶吼，整個天台開始崩塌，地面變得像沼澤般柔軟。那團黑影怪物猛地彈起，像一塊巨大的黑布朝妳撲過來！妳沒有一絲遲疑，轉身就往天台門口的樓梯間狂奔。
>
> 背後傳來那種濕滑、黏稠的磨擦聲，而且越來越近，幾乎就貼在妳的後腦勺上。那股腥臭的惡寒讓妳全身的汗毛直豎。
>
> 妳感覺到，只要一慢下來，背後那頭漆黑怪獸就會將妳整個人吞噬下去。

選項（**Gemini 原寫 3 階含條件式 outcome，整合時補成 5 階 + dispatcher**）：

1. **「（逃跑）什麼都不要看，拼命往光亮的地方跑！」** — Agility 檢定（**整合：rename `athletics`**）
   - 大失敗 / 失敗 → scene_bad_ending_lost
   - 一般成功 → scene_normal_escape
   - 成功且滿足 `clue ≥ 2 AND sms_sent ≥ 1` → scene_true_rescue
   - **整合時改成**：成功 → next: scene_dispatch_routeA_truth_check（router 看雙軸條件）

---

## scene_true_rescue (v2 ✅ 已收，真結局)

> 妳在絕望的追逐中猛地撞開一樓大門，就在那漆黑觸手即將纏住妳脖子的瞬間，一個結實溫暖的身影猛地衝上前將妳拉開，真實的怒吼聲震碎了四周的幻象——
>
> 「滾開！別碰我妹！」
>
> 妳整個人被那股巨大的力量帶向後方，重重地撞進一個充滿汗水味與真實溫度的懷抱。妳大口喘著氣，視線終於對焦。那是哥哥。他穿著工作服，滿頭大汗，臉上的焦急與憤怒是那麼地真實。他身後是停在校門口的機車，引擎還在發熱。
>
> 妳回頭看向那座漆黑的舊校舍。門口依然是一片死寂，沒有紅光，沒有掛鐘，也沒有那頭漆黑的怪獸。只有風吹過廢棄教室窗戶的哀鳴聲。
>
> 哥哥的手還在微微發抖，他抓著妳的肩膀，反覆確認妳有沒有受傷。雖然妳依然感到那股揮之不去的惡寒，但當他牽起妳的手，帶著妳走向機車時，妳知道那段 23:47 的夢魘終於結束了。
>
> 「走，我們回家了。以後放學不准再隨便亂跑了，聽到沒有！」

**整合時對應**：scene_end_truth (好結局)

---

## scene_normal_escape (v2 ✅ 已收 — **中性結局《無盡校園》**)

> 妳跌跌撞撞地衝出校門，冰冷的晚風灌進肺部，讓妳劇烈咳嗽起來。
>
> 妳站在空曠的街道上回頭望去，學校教學大樓隱沒在深沉的暮色中，沒有血紅色的光，也沒有那個扭曲的人影。妳顫抖著拿出手機，螢幕乾乾淨淨，沒有通話紀錄，也沒有哥哥發來的任何訊息，彷彿剛才那場令人窒息的追逐只是一場過度疲勞引發的幻覺。
>
> 妳拖著虛脫的身體回到家，在浴室用熱水洗去滿身的冷汗，倒頭便睡。
>
> 隔天一早，鬧鐘準時響起。妳揉著發痠的肩膀，照常揹起書包上學。走進校門時，熟悉的喧鬧聲、學生的談笑聲讓妳感到一絲安心。妳穿過走廊，走進教室，一切都是那麼平常。
>
> 直到下午放學，夕陽再次將教室染成那種詭異的橘紅色。
>
> 妳揹起書包正準備離開，口袋裡的手機卻在此時猛然震動。妳心頭一緊，顫抖著拿出手機。
>
> 螢幕上閃爍著那個熟悉的號碼：「哥哥」。
>
> 妳僵硬地抬起頭看向黑板上方的掛鐘。那一瞬間，妳感覺心臟漏跳了一拍——
>
> 掛鐘的秒針，正死死地定格在 23:47。
>
> 「喀、喀、喀⋯⋯」
>
> 那種咬碎枯木般的磨損聲再次從妳身後響起。妳慢慢轉過頭，看見自己的影子，正一點一釐米地往課桌底下縮了回去。

**結局類型**：中性 (「逃出但永在循環中」)

**整合期取代規則（使用者拍板：「所有逃出結局通用這個」）**：

| v1 結局 | 處理 |
|---------|------|
| `scene_end_safe_home`（好《平安回家》— 不知情倖存）| 🗑️ 廢棄，由 normal_escape 取代 |
| `scene_end_rescued`（中性《校警救援》）| 🗑️ 廢棄，由 normal_escape 取代 |
| `scene_end_self_break`（好《自己走出去》）| ✅ **保留** — 觸發路線重新對應：scene_the_climax Choice 3 (resolve 賭) **大成功** → self_break。**narrative 待重寫**：性質從「掛電話成長」改為「**意志力擊退詛咒，妹妹自己從天台走下來**」|

**結局收斂後路線對應**：
- Route A 真結局路徑 `scene_rejection_and_escape` 一般成功 → normal_escape
- ~~Route C 不接電話直接離校~~ → 廢棄（Route C 改為「試圖離校被擋」併進 Route A）
- Route B 探索失敗收尾 → normal_escape
- climax Choice 3 (resolve 賭) 成功 → normal_escape（候選）

---

## scene_bad_ending_lost (v2 ✅ 已收，失蹤結局)

> 妳在樓梯轉角被陰影纏住腳踝，黑暗瞬間覆蓋了妳的視線。
>
> 妳甚至來不及尖叫，那種濕冷且沉重的力量就將妳拖入了地板的裂縫中。在那最後的一秒鐘，妳看見牆上的掛鐘依舊停在 23:47，對妳而言，這似乎是妳最後能知曉的時間。
>
> 隔天，這座廢棄校舍的門口只留下一隻掉落的鞋子，而妳，再也沒有出現過。

**整合時對應**：scene_end_lost_school (壞結局，失蹤類型 — 被陰影拖入地板)

> ✅ IP-canon 已鬆綁（2026-05 update）：失神結局形式不再限定一致，可以是墜樓 / 失蹤 / 被吞噬等。此場「被陰影拖入地板裂縫」即合法的失神變體。

---

## scene_sms_or_call (v2 ✅ 已收，新場景 — SMS 機制中介)

> 妳放慢了腳步，甚至停了下來。在這片死寂中，那些被恐懼掩蓋的細節開始在腦中拼湊。
>
> 剛才第二通電話裡哥哥那種溫柔的語氣，在妳心頭激起了一陣不安。在妳的記憶中，哥哥從來不曾用那種輕聲細語的方式跟妳說話。雖然他是妳最親的人，但他平時講話直來直往，甚至帶點脾氣，這種突如其來的「溫柔」反而讓妳覺得陌生。
>
> 妳忍不住開始回想第一通電話。那時他的聲音聽起來急急燥燥的，雖然他脾氣不算好，但做事向來有條有理，絕不會像剛才那樣顯得慌亂失序。
>
> 「這真的不像他⋯⋯」
>
> 這種怪異感讓妳心裡毛毛的。妳轉頭看向四周，只有無盡的黑暗與扭曲的課桌椅。就在這時，妳手中手機螢幕發出的微弱白光映入眼簾，那道光在昏暗中跳動著，像是這片混亂空間裡唯一真實的東西，也讓妳產生了一個念頭。

選項（**整合時補 next + effects；兩選項都不擲骰**）：

1. **「（傳簡訊）你在哪？我在學校等你，但學校好像有點詭異。」** [sms_sent+1]
   → 整合期 next 折回原流程（dispatcher 處理 origin，最常見回 phone_again 或 final_ascent）
   - 劇情：妳決定改用文字試探。看著「已傳送」標籤，妳心裡稍微踏實一點。如果他是真的哥哥，他一定會看到。
2. **「（撥打電話）還是再打一次確認看看，這次我要聽清楚一點。」**
   → 整合期 next 折回原流程
   - 劇情：聽筒裡傳來刺耳電子雜訊聲，忽大忽小，中間夾雜指甲刮金屬的尖銳音。妳嚇得縮了一下脖子，通話被硬生生切斷。

> 📝 **使用者拍板**：clue 累積 UI 維持 Ch1 convention「[線索+1]」toast，**不加額外解釋 popup**。本場 narrative 本身就是 natural recap。
>
> 🛠️ **整合 to-do**：
> 1. 加隱藏 resource `sms_sent` (initial: 0, max: 1, UI hidden)
> 2. 在每個 clue+1 觸發點之後路由到 `scene_dispatch_clue_check`（router），條件「clue ≥ 2 AND sms_sent < 1」 → SMS scene；否則 → 原 next
> 3. SMS scene 兩 choices 都 next → `scene_dispatch_after_sms`（router），按 origin 折回主流程

---

## scene_end_curse_spread (v2 ✅ 已收，覆蓋 v1)

> 所有的掙扎在這一刻都失去了意義。
>
> 妳驚恐地發現，視線所及的一切開始迅速崩解、消散。原本存在的輪廓在瞬間液化，化作一股濃稠得近乎固體的黑暗，從四面八方向妳擠壓而來。這不再是單純的陰影，而是一種帶有重量與溫度的寒冷，正一點一滴地滲進妳的皮膚與骨髓。
>
> 妳伸出手，卻連自己的五指都看不見。空間感在這一刻徹底消失，妳像是墜入了一個無止盡的深淵，四周只剩下一片絕對的死寂與壓迫感。無數無形的觸感在暗處緩緩纏繞上妳的腳踝，冰冷且充滿惡意地將妳向下拉扯，直到將妳徹底拽入那片墨色之中。
>
> 妳的意識開始模糊，手中的手機螢幕成了這片虛無中最後的殘光。
>
> 在那慘白的螢幕上，電話正自動撥向妳最熟悉的那個人。聽筒傳來接通的聲音，而妳聽見「自己」正帶著那種令人不寒而慄的空洞笑意，輕聲對著話筒說道：
>
> 「你在哪？我在學校等你⋯⋯這裡好漂亮，你快過來⋯⋯」

**使用者設計筆記**：這場是 Ch3 的伏筆 — Ch3 將以妹妹男朋友的視角寫，他接到的就是這通電話。世界線走 Ch2 真結局時，這場不發生。

> ✅ IP-canon 已對齊（IP_BIBLE 3.3 update）：男朋友是「同個祖先事件」其他倖存者家族的後代，也是血脈成員。兩家從祖先當年同村起就有淵源，後代成為男女朋友是「詛咒的趨向結果」（被詛咒的血脈互相吸引、聚集）。Ch3 男朋友視角合法。

---

## scene_phone_again_hide (v2 ✅ 已收，rename 自 scene_hide_success — 桌底 perspective 變體)

> 妳蜷縮在課桌下的陰影中，心跳聲在死寂的教室裡顯得震耳欲聾。妳能感覺到門口那股冰冷的氣息正緩緩掃過教室，甚至快要貼上妳的後頸。
>
> 就在那股冰冷的感覺快要貼上妳的後頸時，手心裡的手機猛然震動，強烈的震感讓妳整隻手發麻。螢幕閃爍著：「哥哥」。
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

選項（**phone_again_hide / phone_again_escape 共用同一組選項**，整合期可能用 dispatcher 收斂）：

1. **「（警戒）哥哥給人感覺怪怪的，但好像只能衝出去了。」** — resolve 檢定
   - 成功 → scene_final_ascent [clue+1]（環境 vs 電話描述的巨大落差）
   - 失敗 → scene_end_curse_spread（理智被違和感粉碎）
2. **「（前進）相信哥哥，跟他拚了。」** — resolve 檢定
   - 成功 → scene_final_ascent
   - 失敗 → scene_end_curse_spread（虛假希望感崩潰，被深紅陰影吞噬）

---

## scene_phone_again_escape (v2 ✅ 已收，新場景 — 撞門逃出走廊 perspective 變體)

> 妳發出一聲嘶吼，用肩膀全力撞向門板。「砰！」的一聲巨響，那扇沉重的門竟被妳撞開了一道縫隙。妳顧不得肩膀傳來的撕裂感，側身從縫隙中擠了出去。
>
> 就在那股冰冷的感覺快要貼上妳的後頸時，妳撞開了後門逃了出去，此時妳口袋裡的手機猛然震動，強烈的震感讓妳大腿發麻，妳緊張地從口袋拿出手機。螢幕閃爍著：「哥哥」。
>
> 妳像抓到救命稻草般按下了接聽鍵，電話那頭安靜得詭異，沒有剛才的風聲，只有一種規律的、像是有人在空曠大廳裡緩步移動的微弱迴響。
>
> 「妹，妳還在教室嗎？」哥哥的聲音聽起來輕鬆、溫和，甚至帶著一點笑意，跟三分鐘前那種焦慮到近乎窒息的語氣完全不同。「我到校門口了，這裡的夕陽真的好漂亮，雲都是金色的。妳慢慢收拾，我現在上去天台等妳，我們好久沒一起看風景了，快上來。」
>
> 妳聽著那溫柔的嗓音，看著眼前這條被夕陽——或是被鮮血——染紅的長廊。
>
> 哥哥剛才說⋯⋯夕陽很漂亮？
>
> 就在妳遲疑的瞬間，後方教室內那個「喀、喀」的掛鐘聲突然加快了，聲音大得像是就在妳耳邊。妳回頭一看，原本被撞開的教室門竟在妳面前緩緩合上，只留下一條深紅色的長廊在妳面前延伸。

選項（**與 scene_phone_again_hide 共用**）：

1. **「（警戒）哥哥給人感覺怪怪的，但好像只能衝出去了。」** — resolve 檢定
   - 成功 → scene_final_ascent [clue+1]
   - 失敗 → scene_end_curse_spread
2. **「（前進）相信哥哥，跟他拚了。」** — resolve 檢定
   - 成功 → scene_final_ascent
   - 失敗 → scene_end_curse_spread

---

## 📞 phone_again 變體 family — 整合期統一處理

四個變體（`scene_phone_again` / `_hide` / `_escape` / `_stairs`）整合方案：

| 整合 to-do | 處理方式 |
|-----------|---------|
| 圖片資源 | 四變體共用同一張電話螢幕特寫 / 23:47 圖 |
| narrative 中段 | 各場各自寫一份完整 narrative（接受重複，因為玩家在不同路線只會看到一個版本）|
| 後段選項 | hide / escape 共用「警戒 / 前進」(resolve)；主版 + stairs 共用「質問 / 求救 / 神情恍惚」(observe) — 可能用 router 收斂 |
| stairs 變體特殊 | narrative 同主版但**拿掉結尾「教室門推開露出血紅長廊」段**（樓梯間 perspective 不需教室門 visual） |
| 5 階補完 | 四變體所有 resolve / observe 檢定都補 critical_success / partial / fumble |

---

## 🌀 Route B 設計：困永遠的樓梯（使用者拍板）

### 結構（1 場主場景 + 共用結局）

```
scene_start Choice 2「出去找哥哥」 ─→ scene_endless_stairs_search (主動 perspective)
                                                  │
wait_classroom Choice 2 撞門成功 ──→ scene_endless_stairs (被動 perspective)
                                                  │
                                共用 narrative：
                                - 永遠下不到一樓
                                - 樓梯間樓層 F 標誌全變成掛鐘 23:47
                                - 妹妹感覺背後被東西盯上
                                                  │
                            ┌─────────────────────┴────────────────┐
                            │                                       │
                  Choice 1（兩變體不同）                  Choice 2（共用）
                            │                                       │
                            ├─ search 變體：「打給哥哥」（主動撥）   │
                            │       └─→ scene_phone_again_stairs    │
                            │                                       │
                            └─ main 變體：「轉念聽哥哥，去天台」     │
                                    └─→ scene_phone_again_stairs    │
                                                                    │
                                                            「打破火災警鈴求救」
                                                                    │
                                                                    └─→ scene_end_rescued
                                                                       (中性偏壞《校園救援》— 重寫)
```

### scene_endless_stairs / scene_endless_stairs_search

⏳ **narrative 待 Gemini 寫**。設計大綱：
- Wave 1+2 加壓融合：樓梯永無止盡 + 樓層標誌都被掛鐘 23:47 取代 + 妹妹背後被東西盯
- 「背後被東西盯」呼應 phone_again_stairs 開頭「冰冷感快貼上後頸」（narrative 連貫）
- 兩變體 narrative 100% 共用，唯一差異 = 選項 1 動作（search = 打給哥哥 / main = 轉念聽哥哥）
- 選項 2 共用「打破火災警鈴求救」 → scene_end_rescued

### scene_phone_again_stairs

⏳ **整合期可從主版 derive**。差異：
- narrative = scene_phone_again 主版 - 結尾「教室門推開露出血紅長廊」段
- 後段選項組同主版（質問 / 求救 / 神情恍惚 → final_ascent）
- 圖片同主版

### scene_endless_stairs (main 變體) — narrative 已收

> 妳衝出走廊，一頭栽進空曠的樓梯間。妳扶著冰冷的不鏽鋼扶手，發了瘋似地往下衝，球鞋在磨石子階梯上發出急促且混亂的摩擦聲。
>
> 妳下了一層又一層，但無論妳怎麼加速，前方永遠是向下延伸、看不見底的灰色台階。
>
> 妳猛然停下腳步，轉頭看向牆上的樓層標示。
>
> 原本應該標註樓層的藍色壓克力牌不見了。取而代之的，是一個圓形的掛鐘。它像是直接從牆壁裡長出來的一樣，鐘面上的秒針發出咬碎枯木般的聲音，正死死地定格在 23:47。
>
> 妳不死心地繼續往下跑，每經過一個樓層轉角，牆上都掛著一模一樣的鐘，每一面都指著同一個時間。樓梯間的回音讓妳產生錯覺，彷彿有無數個妳正在不同的時空同時奔跑。
>
> 此時，妳感覺後頸傳來一陣刺骨的惡寒。
>
> 上方的樓梯轉角傳來了那種黏稠的拖行聲，在那種完全開放的空間裡，聲音被牆壁折射得無處不在。妳不敢回頭，因為妳知道，那個「東西」正順著扶手滑行，祂的影子已經在妳腳邊的台階上緩緩拉長。

選項（**Claude 設定，直接型無擲骰；進場 san-5 反映 Wave 加壓**）：

1. **「轉念聽哥哥的話，去天台找他」** → scene_phone_again_stairs
2. **「打破旁邊的火災警鈴求救」** → scene_end_rescued

### scene_endless_stairs_search 變體 — 共用 narrative，選項 1 不同

narrative 完全同 main 變體（共用上方那段）。

選項：

1. **「直接打給哥哥確認」**（**search 變體 only**：scene_start Choice 2 玩家還沒接過第二通電話，這裡是主動撥）→ scene_phone_again_stairs
2. **「打破旁邊的火災警鈴求救」** → scene_end_rescued

### scene_end_rescued — 中性結局《餘震》（v2 ✅ 已收）

> 妳用盡最後的力氣擊碎了牆上的火警警報器。尖銳、單調的警鈴聲瞬間撕裂了死寂的走廊，也震碎了那種黏稠的、不自然的靜謐。
>
> 黑暗中傳來一聲憤怒且不甘的嘶吼，隨後那些紅色的霧氣與拖行聲迅速退去。當老警衛提著手電筒，氣喘吁吁地跑上樓梯時，妳正縮在牆角，雙眼無神地盯著虛空，口中不斷重複著一個誰也聽不清的數字。
>
> 妳被救出來了，但有些東西已經回不來了。
>
> 在醫院的那幾週，妳拒絕與任何人交談。哥哥守在妳床邊，眼眶通紅地握著妳的手，但妳看著他的臉，卻總覺得那層皮膚下隱藏著另一張平滑、無面孔的臉。
>
> 妳休學了半年。在家休養的日子裡，妳拆掉了家裡所有的時鐘。妳無法忍受那種「滴答」聲，那聲音聽起來像是在磨碎妳的骨頭。
>
> 後來，父母幫妳辦了轉學。新學校的教室窗明几淨，同學們都很友善，生活似乎回到了正軌。
>
> 可是，每當夕陽斜斜地照進教室時，妳都會停下筆，死死地盯著黑板上方的掛鐘。妳看著秒針一下、一下地跳動，隨著分針漸漸逼近數字 9 與 10 之間，妳的呼吸會變得短促，指尖開始不由自主地劇烈顫抖。
>
> 45⋯⋯46⋯⋯
>
> 當分針觸碰到 47 的那一刻，妳會感覺教室的光線瞬間冷了下去，四周的談笑聲變得遙遠且扭曲。妳屏住呼吸，直到看著分針緩緩跨過那個刻度，妳才敢重新吐出那口憋在胸腔裡的氣。

**結局類型**：中性

**觸發路線**：scene_endless_stairs / scene_endless_stairs_search Choice 2「打破旁邊的火災警鈴求救」 → 此結局

**narrative 強點**：
- 「一個誰也聽不清的數字」留白讓玩家自己拼出 23:47
- 「皮膚下另一張平滑無面孔的臉」= IP「熟人模仿」精神後遺症，妹妹從此看誰都不確定是不是真的
- 「拆掉所有時鐘」+「滴答聲像磨碎骨頭」= 23:47 PTSD 具象化
- 結尾「分針逼近 47 → 呼吸短促 → 跨過刻度才敢吐氣」把結局從短期事件拉成「一輩子的時間焦慮」
