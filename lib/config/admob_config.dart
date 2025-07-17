import 'dart:io';

class AdMobConfig {
  // 테스트 광고 단위 ID (개발 중 사용)
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // 실제 광고 단위 ID (AdMob에서 생성 후 교체)
  static const String _androidBannerAdUnitId =
      'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_BANNER_AD_UNIT_ID';
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_INTERSTITIAL_AD_UNIT_ID';

  static const String _iosBannerAdUnitId =
      'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_BANNER_AD_UNIT_ID';
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_INTERSTITIAL_AD_UNIT_ID';

  // 개발 모드 여부 (릴리즈 시 false로 변경)
  static const bool isDevelopmentMode = true;

  // 현재 사용할 광고 단위 ID 반환
  static String get bannerAdUnitId {
    if (isDevelopmentMode) {
      return testBannerAdUnitId;
    }

    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    }
    throw UnsupportedError('지원되지 않는 플랫폼입니다.');
  }

  static String get interstitialAdUnitId {
    if (isDevelopmentMode) {
      return testInterstitialAdUnitId;
    }

    if (Platform.isAndroid) {
      return _androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _iosInterstitialAdUnitId;
    }
    throw UnsupportedError('지원되지 않는 플랫폼입니다.');
  }

  // AdMob 앱 ID (AndroidManifest.xml과 Info.plist에서 사용)
  static const String androidAppId =
      'ca-app-pub-YOUR_PUBLISHER_ID~YOUR_ANDROID_APP_ID';
  static const String iosAppId = 'ca-app-pub-YOUR_PUBLISHER_ID~YOUR_IOS_APP_ID';
}
