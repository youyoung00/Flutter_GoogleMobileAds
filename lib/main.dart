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
    staticAd = BannerAd(
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

    staticAd.load();
  }

  @override
  void initState() {
    loadInlineBannerAd();
    loadStaticBannerAd();
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
                    onPressed: () {},
                    child: const Text('Show Interstitial Ad'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
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
                          Container(
                            child: AdWidget(ad: inlineAd),
                            width: inlineAd.size.width.toDouble(),
                            height: inlineAd.size.height.toDouble(),
                          ),
                          const SizedBox(height: 20),
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
          )),
        ),
      ),
    );
  }
}
