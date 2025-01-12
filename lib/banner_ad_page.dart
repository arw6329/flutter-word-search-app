import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdPage extends StatefulWidget {
    const BannerAdPage({super.key, required this.child});

    final Widget child;

    @override
    State<BannerAdPage> createState() => _BannerAdPageState();
}

class _BannerAdPageState extends State<BannerAdPage> {
    BannerAd? _bannerAd;
    bool _isLoaded = false;

    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadAd();
        });
    }

    Future<void> _loadAd() async {
        final adUnitId = Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/9214589741'
            : 'ca-app-pub-3940256099942544/2435281174';

        final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.sizeOf(context).width.truncate()
        );
        
        _bannerAd = BannerAd(
            size: size!,
            adUnitId: adUnitId,
            request: const AdRequest(),
            listener: BannerAdListener(
                onAdLoaded: (ad) {
                    debugPrint('Ad $ad loaded');
                    setState(() {
                        _isLoaded = true;
                    });
                },
                onAdFailedToLoad: (ad, error) {
                    debugPrint('Ad failed to load with error: $error');
                    ad.dispose();
                }
            )
        );

        await _bannerAd!.load();
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Flexible(
                    fit: FlexFit.tight,
                    child: widget.child
                ),
                if(_isLoaded) Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                        top: false,
                        child: SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                        )
                    )
                )
            ]
        );
    }
}