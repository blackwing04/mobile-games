# 異聞錄：2347 — 第二章「下課之後」場景圖補圖 Brief

> **這是補圖版（不是首次製圖）**。Ch2 已完成 27 張，本次只需補剩下 **2 張**。
> 風格規範跟前面 27 張保持完全一致：請開工前打開 1-2 張既有的 Ch2 場景圖對標。

---

## 🎯 本次任務 — 補 2 張

| # | scene id | 場景說明 |
|---|---|---|
| 1 | `scene_phone_static` | 撥電話接通但聽筒只有刺耳電子雜訊，妹妹痛得把手機從耳邊扯開 |
| 2 | `scene_monster_glimpse` | 手電筒照向教室後排，看到擰歪的校服剪影怪物 |

---

## ✅ 已完成（不要重做）

Ch2 已上線的 27 張（共用變體共用同一張，不另出）：

```
scene_start ⭐ (基準圖) / cover
scene_wait_classroom / scene_classroom_wake
scene_door_stuck (含 _impatient 共用)
scene_phone_again (含 _clock / _outgoing 共用)
scene_phone_again_hide / scene_phone_again_escape / scene_phone_again_stairs
scene_endless_stairs (含 _search 共用)
scene_sms_or_call / scene_final_ascent (含 _sms / _call 共用)
scene_the_climax / scene_dream_intrusion / scene_rejection_and_escape
scene_true_rescue / scene_self_break / scene_normal_escape / scene_rescued
scene_lost_soul / scene_lost_sanity / scene_curse_spread
```

---

## 整體風格規範（與 Ch2 既有 27 張一致）

- **韓系 manhwa horror style**（Sweet Home / Hellbound / Bastard 風格參考）
- **黑白基調 + 血鏽紅當唯一彩色點綴**（ink-wash bleeding，不用 hex 色號，照你的畫風直覺處理）
- 黑色塊作陰影語言、無景深模糊、粗細變化的墨線
- 第二人稱 POV：玩家（妹妹）以背影 / 過肩 / 手部呈現為主
- 妹妹外觀：白襯衫 + 深色百褶裙 + 黑長直髮（沿用 Ch2 已鎖定造型）
- **16:9 橫向、無文字浮水印、≤200 KB**
- 命名：`scene_xxx.webp`

> 完整 style canon 與妹妹造型細節 → 參考 Ch1 的 image_generation.md（先前已給過）。

---

## 📚 2 張 Brief

### 1. `scene_phone_static` — 電話雜訊刺耳

**情境**：妹妹剛從詭異夢境中驚醒，雙手顫抖地按下哥哥的號碼。撥號音響了兩聲後通話接通，但聽筒裡不是哥哥的聲音，而是一陣刺耳的電子雜訊。她隱約聽見背景有什麼聲音在說話，被雜訊撕成碎片。雜訊瞬間放大成一聲尖銳嘯叫，妹妹痛得把手機從耳邊扯開。

**構圖**：近景，妹妹**側臉特寫**（半身或胸上半身），**手機被她扯離耳邊的瞬間**（手機在畫面側邊、傾斜不穩定的角度），表情扭曲、單眼閉著、皺眉、嘴微張的痛苦表情。從手機聽筒射出**鋸齒狀、刺耳的視覺化雜訊波形**（manhwa 表現電子雜訊的方式：用破碎墨線 + 衝擊感放射線從手機向外擴散）。

**情緒**：聽覺侵犯、痛苦、第一次明確的詭異「不是哥哥」

**人物**：妹妹（半身、側臉、扯離手機的動作、表情痛苦）

**🚨 給 Gemini 的關鍵指示（英文）**：
> "Render the audio noise as **jagged ink-wash radiation lines emanating from the phone speaker** — like sharp shards bursting outward in fragmented black ink strokes. Do NOT draw sound wave icons or speech bubbles. The noise is a **visual texture** that visually pierces the air around her face/head."

---

### 2. `scene_monster_glimpse` — 教室後排怪物剪影

**情境**：妹妹打開手機手電筒鍵，一道慘白光柱射向教室後排陰影。在那一瞬間，她看見了——一團蠕動的、濕漉漉的影子蹲在最後一排的課桌之間。它沒有臉，但有什麼東西在它「該是頭部的位置」朝她轉過來。她認得那個輪廓——是穿著校服的形狀，但比例都錯了，像是被誰把她的剪影擰歪後重新拼裝的拙劣模仿。

**構圖**：寬鏡頭，**第一人稱 POV 從教室前方往後看**。前景下半部是課桌椅排（剪影、純黑色塊），畫面右下角有妹妹**握著手機的手部特寫**（米白光柱從手機射出）。**光柱照亮的範圍內**是教室最後一排，一個**蹲伏的人形剪影**——**穿校服的形狀但比例扭曲**（手太長、肩膀歪斜、身體輪廓濕漉漉、像融化的蠟一樣不規則），它的「頭部」位置正朝鏡頭方向歪過來，但**沒有臉**（純黑塊空洞）。

**情緒**：手電筒打破黑暗那一瞬間的撞見、視網膜烙印、絕對非人

**人物**：妹妹（畫面側邊握手機的手部 + 手電筒光柱）+ 怪物（最後一排蹲姿、扭曲校服剪影、無臉）

**🚨 給 Gemini 的關鍵指示（英文）**：
> "The monster has **the silhouette of a school uniform** but with **wrong proportions** — arms too long, shoulders uneven, body outline wet and uneven like melting wax. The 'head' position is turning toward the viewer but has **NO face** — render as a solid black ink void where the face should be. The horror is the **wrong proportions of a familiar shape**, not gore or violence. Use **wet, melting ink-wash texture** for the body outline."

---

## 工作流程

1. 先打開 Ch2 既有的 1-2 張（建議 `scene_classroom_wake` 或 `scene_dream_intrusion`）對標風格基準
2. 第一張先做 `scene_phone_static`，user 確認後做第二張
3. 每張完成後自查：與既有 27 張線條粗細、色塊比例、妹妹造型一致 ✅
4. 完成後交付兩個 `.webp` 檔（或 PNG/JPG 我會再壓縮）

---

## 禁忌（沿用前面 27 張同套）

- ❌ 照片寫實 / 3D 渲染
- ❌ 日系大眼動漫 / chibi
- ❌ 配色超出黑 / 米白 / 冷灰 / 血鏽紅
- ❌ 景深模糊 / 軟焦
- ❌ 文字 / 字幕 / 浮水印
- ❌ 怪物完整正面特寫（留白才恐怖）
- ❌ 過度血腥
