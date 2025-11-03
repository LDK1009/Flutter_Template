import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key, this.adUnitId});

  final String? adUnitId;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final unitId = widget.adUnitId ?? 'ca-app-pub-3940256099942544/6300978111';
    _bannerAd = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() {
            _isReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('광고 로드 실패 - 코드: ${error.code}, 메시지: ${error.message}');
          print('광고 단위 ID: ${widget.adUnitId ?? '기본값'}');
          _isReady = false;
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}


