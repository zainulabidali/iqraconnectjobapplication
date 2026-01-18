import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isLoaded = false;

  static void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3072484265637122/3440442086',
      // 'ca-app-pub-3940256099942544/1033173712', // ✅ TEST ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isLoaded = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isLoaded = false;
              loadAd(); // load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isLoaded = false;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoaded = false;
        },
      ),
    );
  }

  static void showAd() {
    if (_isLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isLoaded = false;
    }
  }
}
