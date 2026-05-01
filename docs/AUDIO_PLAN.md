# 🎵 音樂 / 音效配置表 — 異聞錄：辦公室的最後一夜

> **使用方式**：你找好音樂 / 音效檔案後，依據 [音檔規格](#音檔規格) 命名，
> push 到 `assets/audio/` 對應子資料夾，**然後填這份表單** —— 在每個 BGM / SFX
> 欄位填上檔名（不用完整路徑），我把它整合進 JSON + 寫入引擎。
>
> **可空欄位**：沒有適合的音檔就留空白，引擎會自動跳過（不會壞掉）。

---

## 📐 音檔規格

| 項目 | 規格 |
|------|------|
| **格式** | BGM 用 **MP3**（128kbps 即可）；SFX 用 **MP3** 或 **WAV** |
| **長度** | BGM ≥ 30 秒（會循環）；SFX 通常 < 3 秒 |
| **音量** | 統一響度（-14 LUFS 左右），玩家不用一直調音量 |
| **檔名** | 全英數小寫 + 底線，例：`ambient_office_late.mp3` |
| **編碼** | sRGB-ish 統一規格、不要 8kHz 老 codec |

## 📁 資料夾結構

```
assets/audio/
├── bgm/        ← 背景音樂（會循環）
│   ├── ambient_office_late.mp3
│   ├── tension_low.mp3
│   └── ending_calm.mp3
├── sfx/        ← 音效（單次播放）
│   ├── dice_roll.mp3
│   ├── ui_click.mp3
│   └── outcome_success.mp3
└── ambient/    ← 環境音（可選，疊加在 BGM 上）
    ├── fluorescent_buzz.mp3
    └── footsteps_approaching.mp3
```

## 🌐 推薦免費音源（商用 OK）

| 站 | 內容 | 授權 |
|----|------|-----|
| [Freesound.org](https://freesound.org/) | SFX 與短音 | 多為 CC0 / CC BY |
| [Pixabay Music](https://pixabay.com/music/) | BGM | 免費商用 |
| [YouTube Audio Library](https://www.youtube.com/audiolibrary) | BGM + SFX | 免費商用 |
| [OpenGameArt.org](https://opengameart.org/) | 遊戲音樂 | 多為 CC |
| [Incompetech](https://incompetech.com/) | Kevin MacLeod 配樂 | CC BY（要署名） |
| [Free Music Archive](https://freemusicarchive.org/) | 各種風格 | CC |

**搜尋關鍵詞建議**：
- BGM：`dark ambient drone`、`horror underscore`、`cinematic tension`、`liminal soundscape`
- SFX：`dice roll`、`UI click soft`、`door creak`、`fluorescent hum`、`footsteps approaching`、`heartbeat`

⚠️ **要看授權**：CC BY 要在 README / 應用內署名；CC0 / Public Domain 可隨意用；商用 license 看條款。

---

## 📝 第一部分：全域 SFX（一次配置、全劇本共用）

| 用途 | 觸發時機 | 必要性 | 檔名（你填） |
|------|---------|--------|------------|
| `dice_roll` | 玩家點選擇定型選項時，骰子 overlay 跳數字時播放 | ⭐⭐⭐ | |
| `ui_click` | 點任何按鈕時的回饋 | ⭐⭐ | |
| `outcome_critical` | 「大成功」結果揭曉時的提示音（華麗向上音） | ⭐⭐ | |
| `outcome_success` | 「成功」的提示音（柔和肯定） | ⭐⭐⭐ | |
| `outcome_partial` | 「代價成功」的提示音（緊張中略喘） | ⭐⭐ | |
| `outcome_failure` | 「失敗」的提示音（低沉短促） | ⭐⭐⭐ | |
| `outcome_fumble` | 「大失敗」的提示音（不祥、重低音） | ⭐⭐⭐ | |
| `ambient_layer` | 全劇本疊加的微弱環境音（日光燈嗡嗡聲，可選） | ⭐ | |

---

## 📝 第二部分：場景 BGM（每場景的背景音樂）

> 同一首 BGM 可重用在多個場景！只要該場景該用同樣氛圍。
> 「Ambient 疊加」是可選的環境音層（如「腳步漸近」「牆內輕敲」）

| 場景 ID | 情境簡述 | 推薦氛圍 | BGM 檔名 | Ambient 疊加（可選） |
|---------|---------|---------|---------|-------------------|
| `scene_start` | 加班深夜的安靜，茶水間有哭聲 | 靜謐 + 微微壓抑 | | |
| `scene_clear_view` | 看見小婷與牆上不對的影子 | 揭示恐怖（音色突冷） | | |
| `scene_blurry_view` | 視線模糊，閃爍的日光燈 | 焦慮、頭痛感 | | |
| `scene_no_view` | 茶水間空蕩，回頭又有聲音 | 疑神疑鬼 | | |
| `scene_pretend` | 戴耳機假裝沒事，但她走近了 | 壓抑、漸強 | | |
| `scene_recall_full` | 想起 3 年前的跳樓事件 | 揭示真相、記憶感 | | |
| `scene_recall_partial` | 模糊地想起公司出過事 | 悶悶的不安 | | |
| `scene_approach` | 走近發現眼睛是空的 | **本作最高張力** | | |
| `scene_call_security` | 警衛上來，茶水間什麼都沒有 | 釋懷 + 苦澀 | | |
| `scene_called_but_noticed` | 燈滅了，腳步聲逼近 | 純黑暗的恐懼 | | |
| `scene_passed` | 屏息躲過，指甲掐出血 | 劫後虛脫 | | |
| `scene_leave_attempt` | 衝向電梯，門開了她在裡面 | 陷阱揭示 | | |

---

## 📝 第三部分：結局 BGM

| 結局 ID | 結局類型 | 標題 | 推薦氛圍 | BGM 檔名 |
|---------|---------|------|---------|---------|
| `scene_end_good` | 好結局 | 破曉之前 | 苦澀的解脫、晨光感 | |
| `scene_end_neutral` | 中性 | 倖存 | 空洞、回歸日常 | |
| `scene_end_caught` | 壞結局 | 她找到你了 | 凍結、永恆的失去 | |
| `scene_end_lost` | 壞結局 | 陪她 | 悲劇性的優美 | |
| `scene_end_first_look` | 壞結局 | 別回頭看 | 永遠的詛咒、纏繞 | |

---

## 🔧 你填好後，告訴我「表填好了」，我會做：

1. **加入 audio 套件**：`audioplayers` 進 pubspec.yaml
2. **建立 AudioManager**：BGM 跨場景平滑切換、SFX 即時播放
3. **更新 Scene / Ending 模型**：加入 `bgm`、`ambient`、`enter_sfx` 欄位
4. **更新 Scenario JSON**：把你填的檔名整合進 demo_office.json
5. **接入觸發點**：
   - 進場景 → 切 BGM + 播 enter_sfx
   - 點擇定 → 播 dice_roll
   - 結果揭曉 → 播 outcome_xxx 對應 SFX
   - 點按鈕 → 播 ui_click
6. **加靜音 / 音量控制**：主畫面或設定頁加開關（不愛音樂的玩家可關）
7. **跑測試 + 部署**

你填表單時間：~ 30-60 分鐘（找音檔的時間，填表本身很快）
我這邊處理時間：~ 30 分鐘

---

## ⚠️ 法律小提醒

- 用了 **CC BY** 授權的音樂 → 必須在 app 內或 README **署名創作者**
- 用了 **YouTube Audio Library** 的曲子 → 通常 CC0，但建議仍記錄來源
- 不要用任何 **商業專輯** 或 **流行歌**（包括「找不到資訊就應該不會被告」這種僥倖 —— 真的會被告）
- 之後我會幫你在 app 內加 **「音樂來源」credits 頁面**

---

## 🤔 問答 FAQ

**Q: 我可以同一首 BGM 用在多個場景嗎？**
A: 完全可以。`scene_start`、`scene_clear_view`、`scene_blurry_view` 都填同一個檔名也沒事。

**Q: 我可以晚點再補 SFX 嗎？**
A: 可以。先填 BGM 也能跑，SFX 是錦上添花。

**Q: 結局沒有 BGM 行嗎？**
A: 可以留空，引擎會延續上一個場景的音樂或靜音。

**Q: 我音樂找不夠 5 種怎麼辦？**
A: 一首靜謐 + 一首高壓 + 一首結局曲，3 首就能撐起整部。
