import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

const int maxAttempt = 3;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BannerAd staticAd;
  bool staticAdLoaded = false;
  late BannerAd inlineAd;
  bool inlineAdLoaded = false;

  InterstitialAd? interstitialAd;
  int interstitialAttempts = 0;

  RewardedAd? rewardedAd;
  int rewardedAdAttempts = 0;

  static const AdRequest request = AdRequest(
      // keywords: ['', ''],
      // contentUrl: '',
      // nonPersonalizedAds: false,
      );

  void loadStaticBannerAd() {
    staticAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            staticAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('ad failed to load ${error.message}');
        },
      ),
    );

    staticAd.load();
  }

  void loadInlineBannerAd() {
    inlineAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      request: request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            inlineAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('ad failed to load ${error.message}');
        },
      ),
    );

    inlineAd.load();
  }

  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: InterstitialAd.testAdUnitId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          interstitialAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          interstitialAttempts++;
          interstitialAd = null;
          print('falied to load ${error.message}');

          if (interstitialAttempts <= maxAttempt) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      print('trying to show before loading');
      return;
    }

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('ad showed $ad'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        print('failed to show the ad $ad');

        createInterstitialAd();
      },
    );

    interstitialAd!.show();
    interstitialAd = null;
  }

  void createRewardedAd() {
    RewardedAd.load(
      adUnitId: RewardedAd.testAdUnitId,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          rewardedAdAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          rewardedAdAttempts++;
          rewardedAd = null;
          print('failed to load ${error.message}');

          if (rewardedAdAttempts <= maxAttempt) {
            createRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd() {
    if (rewardedAd == null) {
      print('trying to show before loading');
      return;
    }

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('ad showed $ad'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        print('failed to show the ad $ad');

        createRewardedAd();
      },
    );

    rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      print('reward video ${reward.amount} ${reward.type}');
    });
    rewardedAd = null;
  }

  @override
  void initState() {
    loadInlineBannerAd();
    loadStaticBannerAd();
    createInterstitialAd();
    createRewardedAd();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("AdMob Ads"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (staticAdLoaded)
                  Container(
                    child: AdWidget(ad: staticAd),
                    width: staticAd.size.width.toDouble(),
                    height: staticAd.size.height.toDouble(),
                    alignment: Alignment.bottomCenter,
                  ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showInterstitialAd();
                      },
                      child: const Text('Show Interstitial Ad'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showRewardedAd();
                      },
                      child: const Text('Show Rewarded Ad'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      if (inlineAdLoaded && index == 5) {
                        return Column(
                          children: [
                            SizedBox(
                              child: AdWidget(ad: inlineAd),
                              width: inlineAd.size.width.toDouble(),
                              height: inlineAd.size.height.toDouble(),
                            ),
                            ListTile(
                              title: Text('Item ${index + 1}'),
                              leading: const Icon(Icons.star),
                            ),
                          ],
                        );
                      } else {
                        return ListTile(
                          title: Text('Item ${index + 1}'),
                          leading: const Icon(Icons.star),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
