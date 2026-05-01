import '../models/scenario.dart';

/// MVP 階段所有方法為 stub。未來接入 AdMob 時，
/// 改用真正實作（建議用 google_mobile_ads 套件）。
///
/// 設計原則：
///   - 短劇本（單章）：開場插頁 1 次 + 遊戲中獎勵影片
///   - 長劇本（多章）：每章結束插頁 + 章節中獎勵影片 + 章節列表橫幅
///   - 劇情閱讀畫面禁止橫幅
abstract class AdHooks {
  Future<void> onScenarioStart(Scenario scenario);
  Future<void> onChapterEnd(Scenario scenario, String chapterId);
  Future<bool> requestRewardedAd(RewardedAdReason reason);
  bool shouldShowBanner(BannerScreen screen);
}

enum RewardedAdReason {
  reroll, // 重骰
  hint, // 看提示
  protectResource, // 護神智值 / 護血
}

enum BannerScreen {
  home,
  chapterList,
  ending,
  scenarioReading, // 永遠回 false
}

/// MVP stub：永遠允許、不真的播廣告
class StubAdHooks implements AdHooks {
  @override
  Future<void> onScenarioStart(Scenario scenario) async {
    if (scenario.isMultiChapter) {
      // 長劇本不在開場放廣告
      return;
    }
    // ignore: avoid_print
    print('[ad-stub] would show interstitial at scenario start');
  }

  @override
  Future<void> onChapterEnd(Scenario scenario, String chapterId) async {
    if (!scenario.isMultiChapter) return;
    // ignore: avoid_print
    print('[ad-stub] would show interstitial at chapter end: $chapterId');
  }

  @override
  Future<bool> requestRewardedAd(RewardedAdReason reason) async {
    // ignore: avoid_print
    print('[ad-stub] rewarded ad requested for: $reason');
    return true;
  }

  @override
  bool shouldShowBanner(BannerScreen screen) {
    return screen != BannerScreen.scenarioReading;
  }
}
