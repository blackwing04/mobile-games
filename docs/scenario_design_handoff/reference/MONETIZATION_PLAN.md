# 💰 變現策略與廣告計劃

> **這份文件是廣告 + IAP 的設計與實作計劃**。未來接手 Claude 看這份知道整體規劃 + 目前在哪個 Phase。

---

## 一、最終設計（使用者拍板，2026-05）

### 1. 章節 Gating（Ch2+ 才需廣告）

**規則**：

| 章節 | Gating 行為 |
|------|------------|
| **Ch1**（永久免費）| 點開直接進，永遠不需廣告 |
| **Ch2 / Ch3 / Ch4 / Ch5**（需 ad）| 點開 → 若未在 1 小時 cooldown 內 → 看 ad → 進入；若在 cooldown 內 → 直接進 |
| **任何章節（Premium 玩家）** | 永遠直接進，不顯示 ad |

**Cooldown 機制**：
- 每章節**獨立** cooldown timestamp（`ad_cooldown:scenario_id` 存在 SharedPreferences）
- 看完 ad 寫入當下 timestamp
- 點章節時檢查 `now - timestamp < 1 hour` → 免 ad
- 章節間**不共享 cooldown**（玩 Ch2 解鎖不影響 Ch3 仍要看）

**為什麼用 1 小時 cooldown 而不是「每點都看」/「永久解鎖」**：
- 玩家想試不同結局，1 小時內可連續玩（避免疲勞）
- 1 小時後再進需重看，廣告 inventory 仍有量
- 平衡使用者體驗與廣告收益

### 2. Premium IAP（去廣告買斷）

| 項目 | 設定 |
|------|------|
| **商品類型** | One-time non-consumable（買斷，跨裝置可恢復）|
| **商品 ID（暫定）** | `com.blackwing04.mobilegames.premium_pass` |
| **價位** | **NT$60**（台灣手遊入門 sweet spot；不能太高因為廣告 cooldown 已經很寬鬆，玩家動機不強烈，要把 IAP 設成「省麻煩」級別的便宜）|
| **效果** | 永遠跳過所有 ad（不論章節）|
| **Restore 按鈕** | Settings 頁加「恢復購買」按鈕（換手機 / 重灌 app 用）|
| **抽成** | Google Play 抽 15%（前 USD$100 萬）|

### 3. 平台範圍

- **APK / Play Store**：完整 ad + IAP
- **Web (GitHub Pages)**：**內部測試用，不公開**。NoopAdService 全免費，給家人 / 開發測試
- **iOS**：之後再說

### 4. 不做的事（為這款 app 範圍）

- **重骰功能**（看 ad 重擲骰）：不做（user 拍板）。如果未來其他 app 想加，再評估
- **獎勵影片**（看 ad 拿提示 / 多 1 條 clue）：不做（cooldown 機制夠用）
- **章節間插頁** / **結局頁橫幅**：不做（cooldown 已是收益路徑）

---

## 二、實作三 Phase

### Phase 1：Hooks（現在做 — 2026-05）

**目標**：把所有「攔截 / 檢查 / 流程」邏輯都做完，但實際 ad / IAP 用 stub。
**成果**：玩家點 Ch2+ 會走流程（cooldown 檢查 → 「假裝看完 ad」5 秒 → 進章節）。Web 直接進。

**檔案**：
- `lib/services/ad_service.dart` — `AdService` 介面 + `NoopAdService`（web / test）+ `CooldownAdService`（Android Phase 1，stub ad screen）
- `lib/services/premium_service.dart` — `PremiumService`（SharedPreferences flag，現階段 always false，未來 IAP 寫入）
- `lib/ui/screens/home_screen.dart` — `_openScenario` 攔截 Ch2+，走 ad flow
- `lib/ui/screens/ad_overlay_screen.dart`（NEW）— 假廣告畫面（「廣告播放中⋯ 5 秒」+ 跳過 button），未來換真 ad SDK

### Phase 2：真 AdMob 整合（之後做）

**目標**：把 stub ad 換成真 AdMob interstitial。
**檔案**：
- `pubspec.yaml` 加 `google_mobile_ads: ^5.x`
- `android/app/src/main/AndroidManifest.xml` 加 `com.google.android.gms.ads.APPLICATION_ID`
- `lib/services/admob_ad_service.dart`（NEW）— 取代 Phase 1 的 stub
- `android/app/build.gradle.kts` — 確認 minSdk 兼容

**前置工作**：
- AdMob 帳號註冊（免費，需 Play Developer 帳號）
- 建立 interstitial ad unit，拿 unit ID
- 測試環境用 Google 提供的 test unit ID（`ca-app-pub-3940256099942544/1033173712`）

### Phase 3：真 IAP 整合（之後做）

**目標**：玩家可以實際購買 NT$60 去廣告。
**檔案**：
- `pubspec.yaml` 加 `in_app_purchase: ^3.x`
- `lib/services/iap_service.dart`（NEW）— 處理 purchase / restore flow
- `lib/services/premium_service.dart` 改成真實 IAP 紀錄查詢
- `lib/ui/screens/settings_screen.dart`（NEW）— 「去除廣告 NT$60」+「恢復購買」button

**前置工作**：
- Google Play Console 帳號（$25 一次）
- 建立 non-consumable product，product ID 對應 code
- 上架 internal testing 後才能 IAP 測試

---

## 三、法規 / 上架 checklist（Phase 2/3 才需處理）

- [ ] Google Play Developer 註冊 $25
- [ ] AdMob 帳號 + 銀行帳戶
- [ ] 隱私權政策頁面（GitHub Pages 放 URL，內容包含廣告 + IAP 條款）
- [ ] GDPR / PDPA 同意 banner（用 Google 的 UMP SDK）
- [ ] App 內購商品建立（Play Console）
- [ ] App 分級（恐怖類 → 成人？青年？— 看分級審核要求）
- [ ] 內部測試版上架 → 邀請家人 / 朋友測 IAP

---

## 四、關鍵程式設計

### AdService 介面（Phase 1 設計）

```dart
abstract class AdService {
  /// 章節點開時呼叫。如果需要看 ad → 顯示 ad → 等 ad 結束 → 回 true。
  /// 如果已在 cooldown / 是 premium / 是 web → 直接回 true（免 ad）。
  /// 如果使用者按上一頁取消 → 回 false（玩家放棄進入章節）。
  Future<bool> ensureAdWatched(String scenarioId);

  /// 給 settings 顯示用：剩餘 cooldown 秒數（0 = 已過 / 沒紀錄）
  Future<int> remainingCooldownSeconds(String scenarioId);
}
```

### Cooldown 邏輯

```dart
final lastWatched = prefs.getInt('ad_cooldown:$scenarioId') ?? 0;
final now = DateTime.now().millisecondsSinceEpoch;
final cooldownMs = 60 * 60 * 1000; // 1 hour

if (now - lastWatched < cooldownMs) {
  return true; // 還在 cooldown，免 ad
}

// 顯示 ad → 完成後寫入新 timestamp
await _showAdInternal();
await prefs.setInt('ad_cooldown:$scenarioId', now);
return true;
```

### HomeScreen 攔截邏輯

```dart
Future<void> _openScenario(Scenario scenario) async {
  // Ch1 永遠免費
  if (scenario.episode == 1) {
    return _navigateTo(scenario);
  }

  // Premium 玩家免 ad
  final isPremium = await ref.read(premiumServiceProvider).isPremium();
  if (isPremium) {
    return _navigateTo(scenario);
  }

  // Web fallback（NoopAdService 直接 return true）
  // 走 cooldown / ad flow
  final ok = await ref.read(adServiceProvider).ensureAdWatched(scenario.id);
  if (ok) _navigateTo(scenario);
}
```

---

## 五、Phase 1 完成後的 manual 驗證

1. Ch1 點開 → 直接進（無 ad / cooldown）✅
2. Ch2 第一次點開 → 顯示假 ad 畫面 5 秒 → 進章節 ✅
3. Ch2 隔 30 分鐘再點 → 直接進（cooldown 內）✅
4. Ch2 隔 1.5 小時再點 → 又顯示假 ad（cooldown 已過）✅
5. Web build 點 Ch2 → 直接進（NoopAdService）✅
6. （將來 Phase 3）打開 settings 按「去除廣告」→ purchase flow → 之後所有章節都直接進 ✅

---

## 六、未來接手 Claude 注意事項

1. **不要動 Ch1 gating 邏輯** — Ch1 永遠免費
2. **每章獨立 cooldown** — 不要做「全章共用 cooldown」
3. **Web 一律 NoopAdService** — Web 不做 ad 邏輯
4. **新增章節時**：JSON 加 `episode` 欄位，hooks 自動 gating（不必動 ad code）
5. **Phase 2 / 3 開工時**：先 read 這份文件，確認設計沒漂移再 code
