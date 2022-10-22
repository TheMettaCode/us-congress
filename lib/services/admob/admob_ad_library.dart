import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';

class AdMobLibrary {
  List<String> testDeviceIds = [dotenv.env["DEV_TEST_DEVICE_ID"]];
  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

  defaultBanner() {
    if (!userDatabase.get('userIsPremium')) {
      logger.d('***** Default Banner Start *****');

      final BannerAd myBanner = BannerAd(
        adUnitId: defaultBannerId,
        size: AdSize.banner,
        request: AdRequest(
          nonPersonalizedAds: false,
          keywords: adMobKeyWords,
        ),
        listener: BannerAdListener(
          // Called when an ad is successfully received.
          onAdLoaded: (Ad ad) {
            logger.d(
                '***** Ad Unit ID Loaded: ${ad.responseInfo.responseId} *****');
            logger.d('***** Banner Results: ${ad?.responseInfo?.responseId}');
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            logger.d(
                '***** Ad failed to load, Code: ${error.code} - Domain: ${error.domain} - Message: ${error.message} *****');
          },
          // Called when an ad opens an overlay that covers the screen.
          onAdOpened: (Ad ad) async =>
              await Functions.processCredits(true, creditsToAdd: 5),
          // Called when an ad removes an overlay that covers the screen.
          onAdClosed: (Ad ad) {
            logger.d('Ad closed.');
          },
        ),
      );

      logger.d(
          '***** Default Banner Response: ${myBanner?.responseInfo?.responseId} *****');
      return myBanner;
    } else {
      logger.d('USER IS PREMIUM... NO BANNER ADS');
    }
  }

  Widget bannerContainer(BannerAd banner, BuildContext context) {
    return Container(
      height: banner.size.height.toDouble() + 5,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: BounceInUp(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
              alignment: Alignment.center,
              width: banner.size.width.toDouble(),
              height: banner.size.height.toDouble(),
              child: AdWidget(ad: banner)),
        ),
      ),
    );
  }

  void interstitialAdShow(InterstitialAd interstitialAd) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    final bool userIsPremium = userDatabase.get('userIsPremium');
    // final bool userIsLegacy = !userDatabase.get('userIsPremium') &&
    //     List.from(userDatabase.get('userIdList')).any(
    //         (element) => element.toString().startsWith('$oldUserIdPrefix'));
    if (!userIsPremium) {
      int totalEarnedCredits =
          userDatabase.get('credits') + userDatabase.get('permCredits');
      double chanceToShow = 0;

      if (totalEarnedCredits <= adChanceToShowThreshold)
        chanceToShow = 1 - (totalEarnedCredits / adChanceToShowThreshold);
      else
        chanceToShow = 0;

      bool willShow = random.nextDouble() < chanceToShow;

      debugPrint('^^^^^ CHANCE TO SHOW AD: ${chanceToShow * 100}% ^^^^^');
      debugPrint('^^^^^ WILL SHOW AD: $willShow ^^^^^');

      if (interstitialAd != null && willShow) {
        interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (interstitialAd) => userDatabase.put(
              'interstitialAdId', interstitialAd.responseInfo.responseId),
          onAdDismissedFullScreenContent: (InterstitialAd interstitialAd) {
            userDatabase.put('interstitialAdIsNew', false);
            interstitialAd.dispose();
          },
          onAdFailedToShowFullScreenContent: (interstitialAd, error) {
            userDatabase.put('interstitialAdIsNew', false);
            interstitialAd.dispose();
          },
          onAdImpression: (interstitialAd) => userDatabase.put(
              'interstitialAdCount',
              userDatabase.get('interstitialAdCount') + 1),
          onAdClicked: (interstitialAd) {
            debugPrint("Ad was clicked.");
          },
        );

        interstitialAd.show();
        // return null;
      } else
        logger.d(
            '***** INTERSTITIAL AD DATA IS NULL: AND MAY RELOAD DURING APP REFRESH');
    } else
      logger.d('USER IS UPGRADED TO PREMIUM STATUS!');
  }

  // void rewardedInterstitialAdShow(RewardedInterstitialAd interstitialAd) {
  //   Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  //   final bool userIsPremium = userDatabase.get('userIsPremium');
  //   // final bool userIsLegacy = !userDatabase.get('userIsPremium') &&
  //   //     List.from(userDatabase.get('userIdList')).any(
  //   //         (element) => element.toString().startsWith('$oldUserIdPrefix'));
  //   if (!userIsPremium) {
  //     int totalEarnedCredits =
  //         userDatabase.get('credits') + userDatabase.get('permCredits');
  //     double chanceToShow = 0;

  //     if (totalEarnedCredits <= adChanceToShowThreshold)
  //       chanceToShow = 1 - (totalEarnedCredits / adChanceToShowThreshold);
  //     else
  //       chanceToShow = 0;

  //     bool willShow = random.nextDouble() < chanceToShow;

  //     logger.d('^^^^^ CHANCE TO SHOW AD: ${chanceToShow * 100}% ^^^^^');
  //     logger.d('^^^^^ WILL SHOW AD: $willShow ^^^^^');

  //     if (interstitialAd != null && willShow) {
  //       interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
  //         onAdShowedFullScreenContent:
  //             (RewardedInterstitialAd interstitialAd) => userDatabase.put(
  //                 'interstitialRewardedAdId',
  //                 interstitialAd.responseInfo.responseId),
  //         onAdDismissedFullScreenContent:
  //             (RewardedInterstitialAd interstitialAd) {
  //           userDatabase.put('interstitialRewardedAdIsNew', false);
  //           interstitialAd.dispose();
  //         },
  //         onAdFailedToShowFullScreenContent:
  //             (RewardedInterstitialAd interstitialAd, AdError error) {
  //           userDatabase.put('interstitialRewardedAdIsNew', false);
  //           interstitialAd.dispose();
  //         },
  //         onAdImpression: (RewardedInterstitialAd interstitialAd) =>
  //             userDatabase.put('interstitialRewardedAdCount',
  //                 userDatabase.get('interstitialRewardedAdCount') + 1),
  //       );
  //       interstitialAd.show(
  //         onUserEarnedReward: (interstitialAd, RewardItem rewardItem) async {
  //           logger.d('*****\nImplementing reward now!!!\n*****'.toUpperCase());
  //           await Functions.processCredits(true,
  //               isPermanent: false, creditsToAdd: 5);
  //         },
  //       );
  //       return null;
  //     } else
  //       logger.d(
  //           '***** INTERSTITIAL AD DATA IS NULL: AND MAY RELOAD DURING APP REFRESH');
  //   } else
  //     logger.d('USER IS UPGRADED TO PREMIUM STATUS!');
  // }

  void rewardedAdShow(RewardedAd ad /*, {override = false}*/) {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    // final bool userIsPremium = userDatabase.get('userIsPremium');
    // final bool userIsLegacy = !userDatabase.get('userIsPremium') &&
    //     List.from(userDatabase.get('userIdList')).any(
    //         (element) => element.toString().startsWith('$oldUserIdPrefix'));
    // if (!userIsPremium || (userIsPremium && override)) {
    // int totalEarnedCredits =
    //     userDatabase.get('credits') + userDatabase.get('permCredits');
    // double chanceToShow = 0;
    // Random random = Random();

    // if (totalEarnedCredits <= adChanceToShowThreshold)
    //   chanceToShow = 1 - (totalEarnedCredits / adChanceToShowThreshold);
    // else
    //   chanceToShow = 0;

    // bool willShow = random.nextDouble() < chanceToShow;

    // logger.d('^^^^^ CHANCE TO SHOW AD: ${chanceToShow * 100}% ^^^^^');
    // logger.d('^^^^^ WILL SHOW AD: $willShow ^^^^^');

    if (ad != null) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) =>
            userDatabase.put('rewardedAdId', ad.responseInfo.responseId),
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          userDatabase.put('rewardedAdIsNew', false);
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          userDatabase.put('rewardedAdIsNew', false);
          ad.dispose();
        },
        onAdImpression: (RewardedAd ad) => userDatabase.put(
            'rewardedAdCount', userDatabase.get('rewardedAdCount') + 1),
      );
      ad.show(
        onUserEarnedReward: (ad, RewardItem rewardItem) async {
          logger.d('*****\nImplementing reward now!!!\n*****'.toUpperCase());
          await Functions.processCredits(true,
              isPermanent: true, creditsToAdd: 50);
        },
      );
      return null;
    } else
      logger.d('***** AD DATA IS NULL: AND MAY RELOAD DURING APP REFRESH');
    // } else
    //   logger.d('USER IS UPGRADED TO PREMIUM STATUS!');
  }
}
