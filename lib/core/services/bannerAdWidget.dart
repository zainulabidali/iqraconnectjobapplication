import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  AdSize? _adSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    final width = MediaQuery.of(context).size.width.truncate();

    _adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width) ??
        AdSize.banner;

    _bannerAd = BannerAd(
      // adUnitId: 'ca-app-pub-3072484265637122/5836517041',
      
      adUnitId: 'ca-app-pub-3072484265637122/5836517041',

      // adUnitId: 'ca-app-pub-3940256099942544/6300978111', test id

      // 'ca-app-pub-3940256099942544/6300978111', // ✅ TEST banner ID
      size: _adSize!,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() => _bannerAd = null);
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || _adSize == null) {
      return const SizedBox(height: 0);
    }

    return SizedBox(
      width: _adSize!.width.toDouble(),
      height: _adSize!.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
