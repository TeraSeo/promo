import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdPage extends StatefulWidget {
  const BannerAdPage({super.key});

  @override
  State<BannerAdPage> createState() => _BannerAddPageState();
}

class _BannerAddPageState extends State<BannerAdPage> {

  final String androidTestUnitId = "ca-app-pub-3940256099942544/6300978111";
  final String iosTestUnitId = "ca-app-pub-3940256099942544/2934735716";

  late BannerAd? banner;
  bool isBannerLoaded = false;

  @override
  void initState() {
    super.initState();

    initializeBannerAd();
  }

  initializeBannerAd() async {
    banner = BannerAd(
            size: AdSize.banner, 
            adUnitId: Platform.isIOS? iosTestUnitId : androidTestUnitId, 
            listener: BannerAdListener(
              onAdLoaded: (ad) {
                if (this.mounted) {
                  setState(() {
                    isBannerLoaded = true;
                  });
                }
              },
              onAdFailedToLoad: (ad, error) {
                ad.dispose();
                isBannerLoaded = false;
              }
            ), 
            request: AdRequest())..load();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: isBannerLoaded ? AdWidget(
            ad: this.banner!
          ) : Container()
    );
  }
}