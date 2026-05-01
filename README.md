# 異聞錄 — 模板化文字 TRPG 工廠

一套用於量產文字冒險 TRPG 遊戲的引擎，核心循環為「劇情 → 選擇 / 骰子檢定 → 多線分支 → 多重結局」。同一套引擎可載入不同 JSON 劇本，快速產出多款主題不同的遊戲。

## 線上試玩

部署到 GitHub Pages 後，網址會是：
**https://blackwing04.github.io/mobile-games/**

> Android 手機開瀏覽器即可遊玩，無需安裝。

## 技術選型

- **Flutter 3.41.9** + **Dart 3.11.5**
- **flutter_riverpod 2.x**（狀態管理）
- **目標平台**：Web（MVP）／ Android APK（後期）／ iOS（待 Mac 環境就緒）

## 架構

```
lib/
├── main.dart                  入口，包 ProviderScope
├── app.dart                   MaterialApp + 主題
│
├── engine/                    遊戲引擎（劇本無關，可重用）
│   ├── models/                劇本 / 場景 / 選項 / 技能檢定 / 資源 / 角色 / 遊戲狀態
│   ├── dice/dice_roller.dart  d100 + 5 階結果判定
│   ├── runtime/
│   │   ├── scenario_loader.dart   JSON → Scenario 物件
│   │   └── scenario_runner.dart   純邏輯狀態機（無 Flutter 依賴，方便測試）
│   └── ads/ad_hooks.dart      廣告呼叫點（MVP 為 stub）
│
├── ui/                        Flutter UI 層
│   ├── theme/app_theme.dart   暗色 horror 主題
│   ├── widgets/               narrative_text、choice_button、resource_bar、dice_overlay
│   └── screens/               home_screen、scenario_screen、ending_screen
│
└── providers/game_provider.dart   Riverpod providers
```

## 骨子系統設計（A+B 混血）

d100 基底 + 5 階結果，給劇本提供豐富分支：

| 結果 | 觸發條件 | 設計用途 |
|------|---------|---------|
| 大成功 | 擲到 ≤ 技能/5 | 額外資訊 / 加 buff |
| 成功 | 擲到 ≤ 技能 | 主線推進 |
| 代價成功 | 擲到 > 技能 但差距 ≤ 10 | 推進但有副作用 |
| 失敗 | 上述都不滿足 | 主線受阻 / 替代路徑 |
| 大失敗 | 擲到 96-100 | 嚴重後果 / 觸發黑暗結局 |

> 規則細節見 `lib/engine/dice/dice_roller.dart`，特殊情形（技能 0 等）有單元測試覆蓋。

## 劇本格式

劇本是純 JSON，放在 `assets/scenarios/`。Schema 範例見 `assets/scenarios/demo_office.json`。每個劇本獨立宣告：
- `resources`：本劇本使用的資源（如神智、線索、HP）
- `skills`：技能名稱與起始值
- `scenes`：場景樹，每個場景含 `narrative` 文字、`choices` 列表（含可選的 `skill_check`）、可選的 `ending`

新增一款遊戲 ＝ 新增一份 JSON ＋ 改名 ＋ build。引擎程式碼不需要動。

## 變現策略（MVP 預留 hooks，未接 SDK）

廣告策略依**劇本長度**自動切換：
- **短劇本**（單章 / 無 chapters 欄位）：開場插頁 1 次 + 遊戲中獎勵影片
- **長劇本**（多 chapters）：每章結束插頁 + 章節中獎勵影片 + 章節列表橫幅
- **劇情閱讀畫面禁止橫幅**

實作見 `lib/engine/ads/ad_hooks.dart`，介面已定義，未來換成 `google_mobile_ads` 即可。

## 開發指令

```bash
# 安裝依賴
flutter pub get

# 跑測試
flutter test

# 靜態檢查
flutter analyze

# 本地跑 Web 開發伺服器
flutter run -d chrome

# Build Web 正式版
flutter build web --release --base-href "/mobile-games/"

# Build Android APK
flutter build apk --release
```

## 部署

`.github/workflows/deploy-web.yml` 設定為：每次 push 到 `claude/setup-git-repo-464UR` 或 `main` 分支，自動跑 analyze + test + build web，並部署到 GitHub Pages。

**首次啟用步驟**：
1. 推上分支後，到 GitHub repo 的 **Settings → Pages**
2. 將 **Source** 設為 **GitHub Actions**
3. 等待 workflow 跑完，造訪上面列出的網址即可

## 內容創作守則

避免法務風險：
- ❌ 不使用 "Call of Cthulhu" / "CoC" 字樣，技能名稱不照抄 POW/SAN/EDU
- ❌ 不直接複製個人創作的鬼故事文章內容（Dcard、PTT、YouTube 等）
- ❌ 不使用 SCP / Backrooms / Mandela Catalogue 等社群 IP 的專有名詞與具體設定
- ✅ 使用民俗 / 都市傳說 / 文化母題（公共領域）
- ✅ 借鑒美學與類型，自寫具體情節與設定

## 路線圖

- [x] MVP：引擎 + 示範劇本 + Web 部署
- [ ] 第一款商業劇本（30 分鐘正式作）
- [ ] 接 AdMob：獎勵影片 + 章節插頁
- [ ] Build APK + Play Store 上架
- [ ] 第 2~5 款劇本，驗證模板化生產速度
- [ ] 演化為 monorepo（多 app 共用 packages/game_engine）
- [ ] iOS 支援（需 Mac + Apple 開發者帳號）
