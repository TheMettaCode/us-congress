import 'dart:convert';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/constants/widgets.dart';
import 'package:us_congress_vote_tracker/models/lobby_event_model.dart';
import 'package:us_congress_vote_tracker/models/member_payload_model.dart';
import 'package:us_congress_vote_tracker/models/bill_recent_payload_model.dart';
import 'package:us_congress_vote_tracker/models/floor_actions_model.dart';
import 'package:us_congress_vote_tracker/models/news_article_model.dart';
import 'package:us_congress_vote_tracker/models/private_funded_trips_model.dart';
import 'package:us_congress_vote_tracker/models/statements_model.dart';
import 'package:us_congress_vote_tracker/models/vote_payload_model.dart';
import 'package:us_congress_vote_tracker/models/vote_roll_call_model.dart';
import 'package:us_congress_vote_tracker/services/admob/admob_ad_library.dart';
import 'package:us_congress_vote_tracker/services/notifications/notification_api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:us_congress_vote_tracker/services/propublica/propublica_api.dart';
import 'package:us_congress_vote_tracker/services/revenuecat/rc_purchase_api.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/github/usc_app_data_model.dart';

class Messages {
  static Future<void> showMessage(
      {@required BuildContext context,
      @required String message,
      @required bool isAlert,
      Color barColor = const Color.fromARGB(255, 255, 170, 0),
      bool removeCurrent = true,
      int durationInSeconds = 5,
      String networkImageUrl = '',
      String assetImageString = '',
      String assetImage = 'assets/watchtower.png'}) async {
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    bool darkTheme = userDatabase.get('darkTheme');
    Color borderColor = Theme.of(context).primaryColorDark;

    if (removeCurrent) ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BounceInUp(
          child: FadeIn(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: darkTheme
                          ? alertIndicatorColorBrightGreen
                          : borderColor,
                      width: 3),
                  borderRadius: BorderRadius.circular(10),
                  color: isAlert
                      ? Theme.of(context).errorColor
                      : darkTheme
                          ? Theme.of(context).primaryColorDark
                          : barColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  networkImageUrl.isNotEmpty
                      ? Container(
                          width: 45,
                          height: 45,
                          foregroundDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5)),
                          child: FadeInImage(
                              placeholder: AssetImage(assetImage),
                              image: NetworkImage(networkImageUrl),
                              fit: BoxFit.cover),
                        )
                      : assetImageString.isNotEmpty
                          ? Container(
                              width: 45,
                              height: 45,
                              foregroundDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5)),
                              child: FadeInImage(
                                  placeholder: AssetImage(assetImage),
                                  image: AssetImage(assetImageString),
                                  fit: BoxFit.cover),
                            )
                          : Container(
                              width: 45,
                              height: 45,
                              foregroundDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5)),
                              child: FadeInImage(
                                  placeholder: AssetImage(assetImage),
                                  image: AssetImage(assetImage),
                                  fit: BoxFit.cover),
                            ),
                  const SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    flex: 4,
                    child: Text(message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: isAlert
                                ? const Color.fromRGBO(255, 255, 255, 1)
                                : darkTheme
                                    ? darkThemeTextColor
                                    : altHighlightAccentColorDarkRed,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      duration: Duration(seconds: durationInSeconds),
      elevation: 0,
    ));

    // FlutterRingtonePlayer.play(
    //     android: AndroidSounds.notification,
    //     ios: IosSounds.receivedMessage,
    //     volume: 0.5);
  }

  static Future<void> shareContent(bool shareApp,
      {String subject = 'A message about the US Congress Android App',
      String message = 'Download it now in the Google Play Store!'}) async {
    if (shareApp) {
      Share.share(appShare, subject: appTitle).then((value) async =>
          await Functions.processCredits(true,
              isPermanent: true, creditsToAdd: 5));
    } else {
      Share.share(message, subject: subject).then((value) async =>
          await Functions.processCredits(true,
              isPermanent: false, creditsToAdd: 10));
    }
  }

  static Future<void> sendNotification(
      {BuildContext context,
      String source = '[promo, trial_ending]',
      String summaryTitle = 'A quick message',
      String title = 'A quick message for you!',
      String messageBody =
          'The US Congress App is a great way to keep up with congressional members and actions.',
      dynamic additionalData = ''}) async {
    Box userDatabase = Hive.box<dynamic>(appDatabase);

    // List<bool> userLevels = await Functions.getUserLevels();
    // bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];
    // final DateTime _now = DateTime.now();

    switch (source) {
      // case 'promo':
      //   {
      //     final DateTime _lastPromoNotification =
      //         DateTime.parse(userDatabase.get('lastPromoNotification'));
      //
      //     debugPrint('LAST PROMO NOTIFICATION WAS: $_lastPromoNotification');
      //
      //     List<String> devList = [
      //       'Just A Hello World<|:|>Since you ARE MettaCode. Just sending a test<|:|>dev',
      //       'App Store (Dev)<|:|>Trade in your credits for official App merch (coming soon)<|:|>dev',
      //     ];
      //
      //     List<String> premiumList = [];
      //
      //     List<String> legacyList = [
      //       'GoFundMe Campaign<|:|>To help with funding for development of an iOS version of US Congress app, we\'re running a GoFundMe campaign. Contact us for details or search \'us congress app\' on the GoFundMe website at https://gofundme.com<|:|>support',
      //       'Ready For Premium?<|:|>If you\'re not yet ready to upgrade and haven\'t used your one-time free trial, our Free Premium Days promotion will soon be here where you can try out all app features!<|:|>upgrade',
      //       'Follow The Market<|:|>Keep track of what stocks and commodities congressional members are trading! Premium members receive trade disclosure information and alerts. Consider upgrading today!<|:|>stock',
      //     ];
      //
      //     List<String> freeList = [
      //       'Give Premium A Try<|:|>If you haven\'t used your one-time free trial, our Free Premium Days promotion will soon be here where you can try out all app features!<|:|>upgrade',
      //       'Follow The Market<|:|>Keep track of what stocks and commodities congressional members are trading! Premium members receive trade disclosure information and alerts. Consider upgrading today!<|:|>stock',
      //       'Who\'s Lobbying Congress?<|:|>Get real-time information and alerts for Lobbyists solicitations to Congress. Follow the money and consider upgrading today!<|:|>lobbying',
      //     ];
      //
      //     List<String> everyoneList = [
      //       'Shop Cool Merch<|:|>Shop for cool non-partisan products in the new merch shop.<|:|>shop',
      //       'Earn Permanent Credits<|:|>Get permanent credits when you share US Congress App with friends & colleagues, rate the app, or purchase them directly when prompted.<|:|>share',
      //       'Toggle Notifications<|:|>Getting too many (or not enough) notifications? Activate/Deactivate any of them from the [Settings] tile on the main side menu!<|:|>notification',
      //     ];
      //
      //     final List<String> _promotions = userIsDev
      //         ? devList + premiumList + legacyList + freeList + everyoneList
      //         : userIsPremium
      //             ? premiumList + everyoneList
      //             : userIsLegacy
      //                 ? legacyList + everyoneList
      //                 : freeList + everyoneList;
      //
      //     if (_promotions.isNotEmpty &&
      //         _lastPromoNotification
      //             .isBefore(_now.subtract(Duration(days: 5)))) {
      //       String _thisPromotion =
      //           _promotions[random.nextInt(_promotions.length)];
      //       String _title = _thisPromotion.split('<|:|>')[0];
      //       String _messageBody = _thisPromotion.split('<|:|>')[1];
      //       String _additionalData = _thisPromotion.split('<|:|>')[2];
      //
      //       debugPrint('SENDING NEW PROMO NOTIFICATION: $_thisPromotion');
      //
      //       await NotificationApi.showBigTextNotification(
      //           0,
      //           'promotions',
      //           'App Promotions',
      //           'US Congress App Promotional Notifications',
      //           'Just So You Know...',
      //           '$_title',
      //           '$_messageBody',
      //           '$_additionalData');
      //
      //       userDatabase.put('lastPromoNotification', '${DateTime.now()}');
      //     }
      //   }
      //   break;
      case 'trial_ending':
        {
          await NotificationApi.showBigTextNotification(
              0,
              'free_trial',
              'Free Premium',
              'Free trial of premium features',
              'Free Trial Reminder',
              '🚨 Free Premium Ending!',
              'Just a reminder that your free trial of premium features will be ending very soon. We thank you for trying them out and if you enjoy these extra features, make sure to upgrade when prompted!',
              '$additionalData');

          userDatabase.put('lastPromoNotification', '${DateTime.now()}');
        }
        break;
      // default:
      //   {
      //     await NotificationApi.showBigTextNotification(
      //         0,
      //         'default',
      //         'Default Notification',
      //         'General non-specific notifications',
      //         '$summaryTitle',
      //         '$title',
      //         '$messageBody',
      //         '$additionalData');
      //
      //     userDatabase.put('lastPromoNotification', '${DateTime.now()}');
      //   }
    }
  }
}

class Functions {
  static Future<void> initializeBox() async {
    logger.d(
        '***** OPENING ${appDatabase.toUpperCase()} DATA BOX (Initialization...) *****');

    if (Hive.isBoxOpen(appDatabase)) {
      logger.d(
          '***** ${appDatabase.toUpperCase()} DATA BOX IS ALREADY OPEN *****');
    } else {
      Directory directory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(directory.path);

      await Hive.openBox(appDatabase);
    }

    Box userDatabase = Hive.box<dynamic>(appDatabase);

    if (Hive.isBoxOpen(appDatabase)) {
      logger.d('***** Box is open (Initialize) *****');

      if (userDatabase.toString().isEmpty) {
        logger.d('***** Box is empty! (Initialize) Setting... *****');
        userDatabase.putAll(initialUserData);
      }
      await scrubBoxDatabase(userDatabase);
    } else {
      logger.w('***** Box was not opened! (Initialize) Trying again... *****');
      try {
        await Hive.openBox(appDatabase);
      } catch (e) {
        logger.e('***** Could not open box! (Initialize) Exiting... $e *****');
        // throw ('***** Could not open box! (Initialize) Exiting... ${e.toString()} *****');
      }
    }
  }

  /// THIS SECTION IS USED TO RUN INITIAL CHECKS AND UPDATES
  /// TO THE USER DATABASE.
  ///
  /// ADD ITEMS HERE FOR MAINTENANCE ON EARLIER VERSIONS TO
  /// CLEAN UP THE USER'S DATABASE UPDATE TO THE LATEST APP VERSION REQUIREMENTS

  static Future<void> scrubBoxDatabase(Box userDatabase) async {
    // ADD KEY IF MISSING FROM DATABASE
    for (var key in initialUserData.keys) {
      if (!userDatabase.keys.contains(key)) {
        dynamic value = initialUserData.entries
            .firstWhere((element) => element.key == key)
            .value;
        logger
            .d('***** Missing DBase Key: Adding $key : $value to DBase *****');
        userDatabase.put(key, value);
      }
    }

    // DELETE KEY IF NO LONGER INCLUDED IN DATABASE
    for (var key in userDatabase.keys) {
      if (!initialUserData.keys.contains(key)) {
        logger.d('***** Unused DBase Key: Removing $key from DBase *****');
        userDatabase.delete(key);
      }
    }

    // // UPDATE DATA FOR SPECIFIC KEYS
    // List<dynamic> listOfKeysToUpdate = ['appUpdatesList'];
    // listOfKeysToUpdate.forEach((key) {
    //   if (userDatabase.get(key).toString() != initialUserData[key].toString()) {
    //     logger.d(
    //         '***** Updating User DBase Value for Key $key with ${initialUserData[key]} *****');
    //     userDatabase.put(key, initialUserData[key]);
    //   }
    // });

    /// SCRUB SUBSCRIPTION LIST OF PRE 2.4.5 VERSIONS
    if (List.from(userDatabase.get('subscriptionAlertsList')).isNotEmpty) {
      logger.d('***** CHECKING FOR OUTDATED SUBSCRIPTIONS... *****');
      List<dynamic> scrubbed = [];
      List<dynamic> sub = List.from(userDatabase.get('subscriptionAlertsList'));
      for (var element in sub) {
        if ((element.toString().startsWith('member_') &&
                element.toString().endsWith('_member') &&
                element.toString().split('_').length >= 3) ||
            (element.toString().startsWith('lobby_') &&
                element.toString().endsWith('_lobby') &&
                element.toString().split('_').length >= 7) ||
            (element.toString().startsWith('bill_') &&
                element.toString().endsWith('_bill') &&
                element.toString().split('_').length >= 6) ||
            (element.toString().startsWith('other_') &&
                element.toString().endsWith('_other') &&
                element.toString().split('_').length >= 3)) {
          logger.d('***** ${element.toString().split('_')[1]} IS GOOD...*****');
          scrubbed.add(element);
        } else {
          logger.d(
              '***** ${element.toString()} WAS OUTDATED, SCRUBBED FROM THE LIST *****');
        }
      }

      if (scrubbed.isNotEmpty) {
        userDatabase.put('subscriptionAlertsList', scrubbed);
      } else {
        userDatabase.put('subscriptionAlertsList', []);
      }
    }
  }

  static Future<void> getTrialStatus(
      BuildContext context, bool userIsPremium, bool userIsLegacy) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    /// PROCESS FREE TRIAL TIME FRAME
    final DateTime freeTrialStartDate =
        DateTime.parse(userDatabase.get('freeTrialStartDate'));
    final DateTime nowDate = DateTime.now();
    // final bool devUpgraded = userDatabase.get('devUpgraded');
    final bool freeTrialUsed = userDatabase.get('freeTrialUsed');
    final bool freeTrialDismissed = userDatabase.get('freeTrialDismissed');

    if (userIsPremium &&
        freeTrialUsed &&
        freeTrialStartDate.isBefore(
            nowDate.subtract(Duration(days: freeTrialPromoDurationDays)))) {
      debugPrint('^^^^^ USER FREE TRIAL HAS EXPIRED ^^^^^');

      /// CLEAR AND BACKUP USER SUBSCRIPTIONS JUST IN CASE THE USER RESUBSCRIBES
      List<String> currentSubscriptions =
          List.from(userDatabase.get('subscriptionAlertsList'));

      if (currentSubscriptions.isNotEmpty) {
        await userDatabase.put(
            'subscriptionAlertsListBackup', currentSubscriptions);
        userDatabase.put('subscriptionAlertsList', []);
      }

      /// DEACTIVATE ANY ACTIVE PREMIUM STATUS ALERTS
      userDatabase.put('userIsPremium', false);
      userDatabase.put('memberAlerts', false);
      userDatabase.put('billAlerts', false);
      userDatabase.put('lobbyingAlerts', false);
      userDatabase.put('privateFundedTripsAlerts', false);
      userDatabase.put('stockWatchAlerts', false);

      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          builder: (context) {
            return SharedWidgets.freeTrialEndedDialog(
                context, userDatabase, userIsPremium, userIsLegacy);
          });
    } else if (!userIsPremium &&
        freePremiumDaysActive &&
        !freeTrialDismissed &&
        DateTime.now().day == freePremiumDaysStartDay) {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          builder: (context) {
            return SharedWidgets.freePremiumDaysDialog(
                context, userDatabase, userIsPremium, userIsLegacy);
          });
    } else if (!userIsPremium && freeTrialUsed) {
      /// CLEAR AND BACKUP USER SUBSCRIPTIONS JUST IN CASE THE USER RESUBSCRIBES
      List<String> currentSubscriptions =
          List.from(userDatabase.get('subscriptionAlertsList'));

      if (currentSubscriptions.isNotEmpty) {
        await userDatabase.put(
            'subscriptionAlertsListBackup', currentSubscriptions);
        userDatabase.put('subscriptionAlertsList', []);
      }

      /// DEACTIVATE ANY ACTIVE PREMIUM STATUS ALERTS
      userDatabase.put('privateFundedTripsAlerts', false);
      userDatabase.put('stockWatchAlerts', false);

      /// DEACTIVATE ANY ACTIVE LEGACY STATUS ALERTS
      if (!userIsLegacy) {
        userDatabase.put('memberAlerts', false);
        userDatabase.put('billAlerts', false);
        userDatabase.put('lobbyingAlerts', false);
      }
    }
  }

  /// THIS FUNCTION RETURNS LIST OF USER LEVELS & PROCESSES FREE TRIAL TIME FRAME
  static Future<List<bool>> getUserLevels({BuildContext context}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    /// DETERMINE CURRENT USER LEVEL
    bool userIsDev = List<String>.from(userDatabase.get('userIdList'))
        .any((element) => element.contains(dotenv.env['dCode']));
    bool userIsPremium = userDatabase.get('userIsPremium');
    bool userIsLegacy = !userDatabase.get('userIsPremium') &&
        List.from(userDatabase.get('userIdList'))
            .any((element) => element.toString().startsWith(oldUserIdPrefix));

    return <bool>[userIsDev, userIsPremium, userIsLegacy];
  }

  // /// THIS FUNCTION CHECKS FOR A NEW VERSION OF THE APP
  // /// AND PROMPTS THE USER TO DOWNLOAD THE LATEST VERSION
  // static Future<bool> checkForNewAppVersion(BuildContext context) async {
  //   // Check for new version updates
  //   logger.d('^^^^^ CHECKING FOR APP VERSION UPDATE ^^^^^');

  //   AppUpdateInfo appUpdateInfo;

  //   appUpdateInfo = await InAppUpdate.checkForUpdate().catchError((e) {
  //     logger.d('^^^^^ APP UPDATE INFO VERSION CHECK ERROR: $e ^^^^^');
  //     return null;
  //   });

  //   if (appUpdateInfo.updateAvailability ==
  //       UpdateAvailability.updateAvailable) {
  //     showModalBottomSheet(
  //         backgroundColor: Colors.transparent,
  //         context: context,
  //         enableDrag: true,
  //         builder: (context) {
  //           return SharedWidgets.appVersionUpdateDialog(context,
  //               appUpdateInfo: appUpdateInfo);
  //         });

  //     return Future<bool>.value(true);
  //   } else {
  //     return Future<bool>.value(false);
  //   }
  // }

  /// THIS FUNCTION CHECKS THE LATEST INITIAL DATABASE
  /// FOR THE LATEST CHANGES TO THE APP AND STORES THEM TO
  /// THE USER'S CURRENT DATABASE FOR DISPLAY WHEN THE USER
  /// FIRST OPENS THE NEW UPDATE

  static Future<void> showLatestUpdates(BuildContext context) async {
    Box userDatabase = Hive.box<dynamic>(appDatabase);

    // Check for latest changes and fixes
    if (userDatabase.get('appUpdatesList').toString() !=
        initialUserData['appUpdatesList'].toString()) {
      logger.d('***** APP HAS NEW UPDATES *****');

      userDatabase.put('appUpdatesList', initialUserData['appUpdatesList']);

      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        enableDrag: true,
        builder: (context) {
          return SharedWidgets.latestUpdates(context, userDatabase);
        },
      )
          // .then((_) {
          //   userDatabase.put('appUpdatesList', initialUserData['appUpdatesList']);
          // })
          ;
    } else {
      logger.d('***** NO CURRENT LATEST UPDATES *****');
    }
  }

  static Future<void> checkRewards(
      BuildContext context,
      RewardedAd ad,
      List<bool> userLevels,
      List<GithubNotifications> githubNotificationsList) async {
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    // bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];
    final currentAppOpens = userDatabase.get('appOpens');

    // REWARD FOR MULTIPLE APP OPENS
    if (currentAppOpens % 10 == 0) {
      logger.d('***** 10 Android Opens Reward Here *****');

      bool appRated = userDatabase.get('appRated');
      if (!appRated) {
        showModalBottomSheet(
            backgroundColor: Colors.transparent,
            isScrollControlled: false,
            enableDrag: true,
            context: context,
            builder: (context) {
              return SharedWidgets.ratingOptions(
                  context, userDatabase, userIsPremium);
            });
      }
    } else if (currentAppOpens % 30 == 0) {
      logger.d('***** 30 Android Opens Reward Here *****');
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        enableDrag: true,
        builder: (context) {
          return SharedWidgets.supportOptions(
              context, userDatabase, ad, userLevels, githubNotificationsList);
        },
      );
      await processCredits(true, isPermanent: true, creditsToAdd: 30);
    } else if (currentAppOpens % 100 == 0) {
      logger.d('***** 100 Android Opens Reward Here *****');
      // showModalBottomSheet(
      //   backgroundColor: Colors.transparent,
      //   context: context,
      //   enableDrag: true,
      //   builder: (context) {
      //     return SharedWidgets.supportOptions(context, userDatabase, ad);
      //   },
      // );
      await processCredits(true, isPermanent: true, creditsToAdd: 100);
    } else {
      logger.d('***** No Opens Reward *****');
    }
  }

  static Future<void> processCredits(bool willAddCredits,
      {bool isPermanent = false,
      bool isPurchased = false,
      int creditsToAdd = 1,
      int creditsToRemove = 1}) async {
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    int currentCredits = userDatabase.get('credits');
    int currentPermCredits = userDatabase.get('permCredits');
    int currentPurchCredits = userDatabase.get('purchCredits');

    debugPrint(
        '^^^^^ CURRENT CREDIT VALUES TO BE UPDATED\n- TEMPORARY: $currentCredits\n- PERMANENT: $currentPermCredits\n- PURCHASED: $currentPurchCredits');

    if (willAddCredits) {
      userDatabase.put(
          isPurchased
              ? 'purchCredits'
              : isPermanent
                  ? 'permCredits'
                  : 'credits',
          isPurchased
              ? currentPurchCredits + creditsToAdd
              : isPermanent
                  ? currentPermCredits + creditsToAdd
                  : currentCredits + creditsToAdd);
    } else if (currentPurchCredits - creditsToRemove >= 0) {
      userDatabase.put('purchCredits', currentPurchCredits - creditsToRemove);
    } else if (currentPurchCredits - creditsToRemove < 0 &&
        currentPurchCredits + currentCredits - creditsToRemove >= 0) {
      int newPurchCredits = 0;
      int newCredits = currentPurchCredits + currentCredits - creditsToRemove;
      userDatabase.put('purchCredits', newPurchCredits);
      userDatabase.put('credits', newCredits);
    } else if (currentPurchCredits - creditsToRemove < 0 &&
        currentPurchCredits + currentCredits - creditsToRemove < 0 &&
        currentPurchCredits +
                currentCredits +
                currentPermCredits -
                creditsToRemove >=
            0) {
      int newPurchCredits = 0;
      int newCredits = 0;
      int newPermCredits = currentPurchCredits +
          currentCredits +
          currentPermCredits -
          creditsToRemove;
      userDatabase.put('purchCredits', newPurchCredits);
      userDatabase.put('credits', newCredits);
      userDatabase.put('permCredits', newPermCredits);
    }

    debugPrint(
        '^^^^^ UPDATED CREDIT VALUES\n- TEMPORARY: ${userDatabase.get('credits')}\n- PERMANENT: ${userDatabase.get('permCredits')}\n- PURCHASED: ${userDatabase.get('purchCredits')}');
  }

  static Future<void> linkLaunch(
    BuildContext context,
    String linkUrl,
    Box userDatabase,
    bool userIsPremium, {
    String appBarTitle = 'US Congress App',
    source = 'default',
    bool isPdf = false,
    InterstitialAd interstitialAd,
  }) async {
    if (await canLaunchUrl(Uri.parse(linkUrl))) {
      context == null
          ? launchUrl(Uri.parse(linkUrl), mode: LaunchMode.platformDefault)
          : Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (webContext) => Scaffold(
                      appBar: AppBar(
                        backgroundColor: source == 'lobby'
                            ? alertIndicatorColorDarkGreen
                            : source == 'travel'
                                ? const Color.fromARGB(255, 0, 80, 100)
                                : source == 'stock_trade'
                                    ? stockWatchColor
                                    : Theme.of(context).primaryColorDark,
                        title: Row(
                          children: [
                            // Image.asset('assets/app_icon_tower.png'),
                            Text(appBarTitle,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      body: WebView(
                        initialUrl: isPdf
                            ? 'http://docs.google.com/viewer?url=$linkUrl'
                            : linkUrl,
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebResourceError:
                            (WebResourceError webResourceError) {
                          Navigator.pop(context);
                          Messages.showMessage(
                              context: context,
                              message: 'Could not launch link',
                              isAlert: true);
                        },
                      ))),
            ).then((_) => !userIsPremium &&
                  interstitialAd != null &&
                  interstitialAd.responseInfo.responseId !=
                      userDatabase.get('interstitialAdId')
              ? AdMobLibrary().interstitialAdShow(interstitialAd)
              : null);
    } else {
      if (context != null) {
        Messages.showMessage(
            context: context, message: 'Could not launch link', isAlert: true);
      }
    }
  }

  /// THIS FUNCTION SHOWS A POP UP SCREEN REQUESTING THE USER
  /// TO UPGRADE AFTER TAPPING ON A PREMIUM FEATURE
  static Future<void> requestInAppPurchase(
      BuildContext context, bool userIsPremium,
      {whatToShow = 'all' /*[all, upgrades,credits]*/}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    try {
      List<Offering> offers = await RcPurchaseApi.fetchOffers();
      logger.d('GETTING OFFERS');
      if (offers.isEmpty) {
        logger.d('NO OFFERINGS FOUND');
        // Messages.showMessage(context, 'No Plans Found', false, true);

      } else {
        // final firstOffer = offers.first;
        logger.d('Offerings: ${offers.map((e) => e)}');
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          isScrollControlled: false,
          enableDrag: true,
          builder: (context) {
            return SharedWidgets.appUpgradeDialog(
                context, userDatabase, offers, userIsPremium,
                whatToShow: whatToShow);
          },
        );
      }
    } catch (e) {
      logger.w(e);
    }
  }

  /// THIS FUNCTION SHOWS A POP UP SCREEN ON FIRST OPEN OF THE APP
  /// UNTIL THE USER HAS EITHER DECLINED OR GRANTED PERMISSION. IF GRANTED,
  /// THE FUNCTION WILL INITIALIZE THE GOOGLE SHEETS FUNCTION FOR FUTURE POST ACCESS

  static Future<void> requestUsageInfo(BuildContext context) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      enableDrag: true,
      isDismissible: false,
      builder: (context) {
        return SharedWidgets.requestUsageInfoSelector(context, userDatabase);
      },
    );
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    // if (userDatabase.get('usageInfo')) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceInfoMap = {};

    if (deviceInfoMap.isNotEmpty) {
      try {
        deviceInfoMap = Map.from(userDatabase.get('deviceInfo'));
      } catch (e) {
        logger
            .w('***** CURRENT DEVICE INFO MAP ERROR: $e - Resetting... *****');
        userDatabase.put('deviceInfo', {});
      }
    }

    if (Platform.isAndroid) {
      try {
        AndroidDeviceInfo androidData = await deviceInfo.androidInfo;
        deviceInfoMap = <String, dynamic>{
          'vendorName': androidData.manufacturer,
          'vendorId': androidData.id,
          'deviceName': androidData.device,
          'deviceModel': androidData.model,
          'isPhysicalDevice': androidData.isPhysicalDevice,
          'version.sdkInt': androidData.version.sdkInt,
          'version.release': androidData.version.release,
          'version.incremental': androidData.version.incremental,
          'version.codename': androidData.version.codename,
          'brand': androidData.brand,
          'hardware': androidData.hardware,
          'product': androidData.product,
          'tags': androidData.tags,
          'type': androidData.type,
          'androidId': androidData.id,
        };
        // logger.d('***** ANDROID DEVICE INFO: $deviceInfoMap *****');
      } catch (e) {
        deviceInfoMap = <String, dynamic>{'Error:': '$e'};
      }
    }

    userDatabase.put('deviceInfo', deviceInfoMap);
    return deviceInfoMap;
    // } else {
    //   logger.d('***** USAGE INFO HAS NOT BEEN ENABLED. MOVING ON... *****');
    //   return null;
    // }
  }

  static Future<PackageInfo> getPackageInfo() async {
    logger.d('***** RETRIEVING PACKAGE DATA *****');
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    // if (userDatabase.get('usageInfo')) {
    PackageInfo packageData;
    Map<String, dynamic> packageMap;

    try {
      final data = await PackageInfo.fromPlatform();

      packageData = data;

      if (packageData.version.isNotEmpty) {
        logger.d('***** PACKAGE DATA RETRIEVED *****');
        packageMap = {
          'appName': packageData.appName,
          'packageName': packageData.packageName,
          'version': packageData.version,
          'buildNumber': packageData.buildNumber,
          'buildSignature': packageData.buildSignature,
        };
        // logger.d('***** PACKAGE MAP: $packageMap *****');
        logger.d(
            '***** PACKAGE VERSION FROM DBASE: ${userDatabase.get('packageInfo')['version']}-${userDatabase.get('packageInfo')['buildNumber']} *****');
        if (userDatabase.get('packageInfo')['version'] != packageData.version) {
          logger.d('***** PACKAGE DATA VERSION MISMATCH. *****');
          logger.d('***** APPLICATION UPDATE DIALOG WILL GO HERE... *****');
        }

        if (userDatabase.get('packageInfo')['buildNumber'] !=
            packageData.buildNumber) {
          logger.d('***** PACKAGE DATA BUILD MISMATCH... Updating... *****');
          userDatabase.put('packageInfo', packageMap);
        }
      }
    } on PlatformException {
      packageData = PackageInfo(
        appName: 'Unknown',
        packageName: 'Unknown',
        version: 'Unknown',
        buildNumber: 'Unknown',
        buildSignature: 'Unknown',
      );
    }

    return packageData;
    // } else {
    //   logger.d('***** USAGE INFO HAS NOT BEEN ENABLED. MOVING ON... *****');
    //   return null;
    // }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.

  static Future<Position> getPosition() async {
    logger.d('***** DETERMINING POSITION... *****');
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    if (userDatabase.get('usageInfo')) {
      bool serviceEnabled;
      LocationPermission permission;
      Position currentPositionData;
      // ignore: unused_local_variable
      Position lastKnownPositionData;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          // Location services are not enabled don't continue
          // accessing the position and request users of the
          // App to enable the location services.

          return Future.error(
            Builder(
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Location Service Not Enabled'),
                  content: const Text(
                      'Could not enable location services. If the issue persists, reinstalling the app may fix the problem.'),
                  actions: <Widget>[
                    TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Close')),
                    // new ElevatedButton.icon(
                    //     onPressed: () {},
                    //     icon: Icon(Icons.replay),
                    //     label: Text('Try Again'))
                  ],
                );
              },
            ),
          );
        }
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error(Builder(
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Location Permissions Denied'),
                content: const Text(
                    'Location permissions are permanently denied, we cannot request permissions. If the issue persists, reinstalling the app may fix the problem.'),
                actions: <Widget>[
                  TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close')),
                  // new ElevatedButton.icon(
                  //     onPressed: () {},
                  //     icon: Icon(Icons.replay),
                  //     label: Text('Try Again'))
                ],
              );
            },
          ));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(Builder(
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Permissions Denied'),
              content: const Text(
                  'Location permissions are permanently denied, we cannot request permissions. If the issue persists, reinstalling the app may fix the problem.'),
              actions: <Widget>[
                TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close')),
                // new ElevatedButton.icon(
                //     onPressed: () {},
                //     icon: Icon(Icons.replay),
                //     label: Text('Try Again'))
              ],
            );
          },
        ));
        // 'Location permissions are permanently denied, we cannot request permissions.');
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      currentPositionData = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      // logger.d('***** CURRENT POSITION DATA: $_currentPositionData');

      // if (!kIsWeb)
      //   _lastKnownPositionData = await Geolocator.getLastKnownPosition();

      // StreamSubscription<Position> positionStream =
      //     Geolocator.getPositionStream(locationOptions)
      //         .listen((Position position) {
      //   logger.d(position == null
      //       ? 'Unknown'
      //       : position.latitude.toString() +
      //           ', ' +
      //           position.longitude.toString());
      // });

      // // To listen for service status changes you can call the getServiceStatusStream.
      // // This will return a Stream<ServiceStatus> which can be listened to, to receive location service status updates.
      // StreamSubscription<ServiceStatus> serviceStatusStream =
      //     Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      //   logger.d(status);
      // });

      if (currentPositionData != null) {
        // logger.d(
        //     '***** Location Received: ${_currentPositionData.toString()} *****');
        final Map<String, dynamic> data = {
          "latitude": "${currentPositionData.latitude}",
          "longitude": "${currentPositionData.longitude}",
          "speed": "${currentPositionData.speed}",
          "speedAccuracy": "${currentPositionData.speedAccuracy}",
          "timestamp": "${currentPositionData.timestamp}",
          "isMock": "${currentPositionData.isMocked}",
          "heading": "${currentPositionData.heading}",
          "accuracy": "${currentPositionData.accuracy}",
          "altitude": "${currentPositionData.altitude}",
          "floor": "${currentPositionData.floor}"
        };

        userDatabase.put('locationData', data);
      } else {
        logger.d('***** CURRENT POSITION DATA IS NULL *****');
      }

      if (currentPositionData.latitude != null &&
          currentPositionData.longitude != null) {
        logger.d('***** Determining Placemark Address *****');
        List<Placemark> placemarks = [];
        placemarks = await placemarkFromCoordinates(
            currentPositionData.latitude, currentPositionData.longitude);
        logger.d('***** 1st Placemark: ${placemarks.first.locality} *****');
        if (placemarks.isNotEmpty) {
          logger.d('***** Determining Full Address *****');
          final Map<String, dynamic> currentFullAddressMap = {
            'street': placemarks.first.street,
            'city': placemarks.first.locality,
            'state': statesMap.entries
                .firstWhere((element) =>
                    element.value.toLowerCase() ==
                    placemarks.first.administrativeArea.toLowerCase().trim())
                .key,
            'zip': placemarks.first.postalCode,
            'country': placemarks.first.isoCountryCode
          };
          // final String currentFullAddress =
          //     '${placemarks.first.street} ${placemarks.first.locality} ${placemarks.first.subAdministrativeArea} ${placemarks.first.administrativeArea} ${placemarks.first.subThoroughfare} ${placemarks.first.postalCode} ${placemarks.first.isoCountryCode}';
          // logger.d(
          //     '***** Placemark Address\n***** Map: $currentFullAddressMap\n***** String: $currentFullAddress\n*****');
          userDatabase.put('currentAddress', currentFullAddressMap);

          if (statesMap.keys
                  .contains(placemarks.first.isoCountryCode.toUpperCase()) &&
              userDatabase.get('representativesLocation')['state'].isEmpty) {
            logger.d(
                '***** Representatives Location Info Is Empty. Updating... *****');
            final Map<String, dynamic> repLocation = {
              "city": placemarks.first.locality.toLowerCase().trim(),
              "state": statesMap.entries
                  .firstWhere((element) =>
                      element.value.toLowerCase() ==
                      placemarks.first.administrativeArea.toLowerCase().trim())
                  .key,
              "country": placemarks.first.isoCountryCode,
              "zip": placemarks.first.postalCode.toLowerCase().trim()
            };
            if (userDatabase.get('representativesLocation')['zip']) {
              userDatabase.put('representativesLocation', repLocation);
            }
          }
        } else {
          logger.d('***** Full Address Not Determined *****');
        }
      } else {
        logger.d('***** Platform is Web (Position Function) *****');
      }

      return currentPositionData;
    } else {
      logger.d('***** USAGE INFO HAS NOT BEEN ENABLED. MOVING ON... *****');
      return null;
    }
  }

  static Future<List<ChamberMember>> getMembersList(
      int congress, String chamber,
      {BuildContext context, List<String> memberIdsToRemove}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await getUserLevels();
    // bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    logger.d('***** Retrieving $chamber Members... *****');
    List<ChamberMember> currentMembersList = [];

    try {
      currentMembersList = memberPayloadFromJson(
              userDatabase.get('${chamber.toLowerCase()}MembersList'))
          .results
          .first
          .members;
    } catch (e) {
      logger.w(
          '^^^^^ ERROR DURING ${chamber.toUpperCase()} MEMBERS LIST (FUNCTION): $e ^^^^^');
      userDatabase.put('${chamber.toLowerCase()}MembersList', {});
      currentMembersList = [];
    }

    List<ChamberMember> finalMembersList = [];

    if (congress != null &&
        chamber.isNotEmpty &&
        (currentMembersList.isEmpty ||
            DateTime.parse(userDatabase.get('lastMembersRefresh'))
                .isBefore(DateTime.now().subtract(const Duration(days: 5))))) {
      final authority = PropublicaApi().authority;
      final url = 'congress/v1/${congress.toString()}/$chamber/members.json';
      final headers = PropublicaApi().apiHeaders;

      final response =
          await http.get(Uri.https(authority, url), headers: headers);

      if (response.statusCode == 200) {
        MemberPayload members = memberPayloadFromJson(response.body);
        if (members.status == 'OK' &&
            members.results.first.members.isNotEmpty) {
          finalMembersList = members.results.first.members;

          /// REMOVE VICE PRESIDENT, EXPIRED MEMBERS
          /// AND ANY OTHER MISCELLANEOUS OUTLIERS
          // List<String> _pruneMembersList = memberIdsToRemove;
          // memberIdsToRemove.forEach((element) {
          finalMembersList.removeWhere((mem) => memberIdsToRemove.any(
                  (element) => element.toLowerCase() == mem.id.toLowerCase())
              //      ||
              // !mem.inOffice
              );
          // });

          if (currentMembersList.isEmpty) currentMembersList = finalMembersList;

          try {
            userDatabase.put('${chamber.toLowerCase()}MembersList',
                memberPayloadToJson(members));
          } catch (e) {
            logger.w(
                'ERROR: ${chamber.toUpperCase()} MEMBERS NOT SAVED TO DATABASE - $e');
            userDatabase.put('${chamber.toLowerCase()}MembersList', {});
          }
        }

        if ((userIsPremium || userIsLegacy) &&
            (userDatabase.get('memberAlerts') /* || memberWatched*/) &&
            (currentMembersList.first.id.toLowerCase() !=
                finalMembersList.first.id.toLowerCase())) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                2,
                'members',
                'Congressional Members',
                'Congressional members recently added or updated',
                'Congressional Member',
                '🧑🏽‍💼 Congressional Member',
                'The list of US $chamber members has been updated',
                members);
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message:
                    '🧑🏽‍💼 The list of US $chamber members has been updated',
                networkImageUrl:
                    '${PropublicaApi().memberImageRootUrl}${finalMembersList.first.id}.jpg',
                isAlert: false,
                removeCurrent: false);
          }
        }
        userDatabase.put('lastMembersRefresh', '${DateTime.now()}');
        return finalMembersList;
      } else {
        logger.w(
            'API ERROR: LOADING ${chamber.toUpperCase()} MEMBERS FROM DBASE - ${response.statusCode}');

        return finalMembersList =
            currentMembersList.isNotEmpty ? currentMembersList : [];
      }
    } else {
      logger.d(
          '***** CURRENT ${chamber.toUpperCase()} MEMBERS LIST: ${currentMembersList.map((e) => e.id)} *****');
      finalMembersList = currentMembersList;
      logger.d(
          '***** ${chamber.toUpperCase()} MEMBERS NOT UPDATED: LIST IS CURRENT *****');
      return finalMembersList;
    }
  }

  static Future<List<NewsArticle>> fetchNewsArticles(
      {BuildContext context}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    List<String> subscriptionAlertsList =
        List.from(userDatabase.get('subscriptionAlertsList'));
    List<bool> userLevels = await getUserLevels();
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    bool sendNotifications = false;

    List<NewsArticle> currentNewsArticlesList = [];

    try {
      currentNewsArticlesList =
          newsArticleFromJson(userDatabase.get('newsArticles'));
      debugPrint('^^^^^ CURRENT NEWS ARTICLE LIST RETRIEVED (FUNCTION) ^^^^^');
    } catch (e) {
      debugPrint('^^^^^ ERROR DURING NEWS ARTICLE LIST (FUNCTION): $e ^^^^^');
      userDatabase.put('newsArticles', {});
      currentNewsArticlesList = [];
    }

    List<NewsArticle> finalNewsArticlesList = [];

    if (currentNewsArticlesList.isEmpty ||
        DateTime.parse(userDatabase.get('lastNewsArticlesRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(minutes: 30)))) {
      logger.d('***** RETRIEVING LATEST NEWS... *****');

      final rapidApiKey = dotenv.env['USCNEWS_API_KEY'];
      final rapidApiHost = dotenv.env['USCNEWS_API_HOST'];

      final url = Uri.parse('https://us-congress-top-news.p.rapidapi.com/news');
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': rapidApiKey,
        'X-RapidAPI-Host': rapidApiHost,
      });
      debugPrint('***** NEWS API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('***** NEWS RETRIEVAL SUCCESS! *****');
        final List<NewsArticle> newsArticles =
            newsArticleFromJson(response.body);
        List<ChamberMember> membersList = [];
        ChamberMember thisMember;

        if (newsArticles.isNotEmpty) {
          // finalNewsArticlesList = newsArticles;
          // List<NewsArticle> rawNewsArticlesList = [];
          // List<String> publisherSlug = rawNewsArticlesList.map((e) => e.slug).toList();

          for (NewsArticle article in newsArticles) {
            switch (article.slug) {
              case "politico":
                {
                  try {
                    if (DateFormat('yyyy/MM/dd')
                        .parse(article.date.trim())
                        .isAfter(DateTime.now()
                            .subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                    // finalNewsArticlesList.removeWhere((element) => DateFormat('yyyy/MM/dd')
                    //     .parse(element.date.trim())
                    //     .isBefore(DateTime.now().subtract(const Duration(days: 14))));
                  } catch (e) {
                    debugPrint(
                        "^^^ ERROR PARSING POLITICO DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              case "usatoday":
                {
                  try {
                    if (DateFormat('yyyy/MM/dd')
                        .parse(article.date.trim())
                        .isAfter(DateTime.now()
                            .subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                    // finalNewsArticlesList.removeWhere((element) => DateFormat('yyyy/MM/dd')
                    //     .parse(element.date.trim())
                    //     .isBefore(DateTime.now().subtract(const Duration(days: 14))));
                  } catch (e) {
                    debugPrint(
                        "^^^ ERROR PARSING USA TODAY DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              case "nytimes":
                {
                  try {
                    if (DateFormat('yyyy/MM/dd')
                        .parse(article.date.trim())
                        .isAfter(DateTime.now()
                            .subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                    // finalNewsArticlesList.removeWhere((element) => DateFormat('yyyy/MM/dd')
                    //     .parse(element.date.trim())
                    //     .isBefore(DateTime.now().subtract(const Duration(days: 14))));
                  } catch (e) {
                    debugPrint(
                        "^^^ ERROR PARSING NY TIMES DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              case "propublica":
                {
                  try {
                    if (DateFormat('MMM dd')
                        .parse(article.date.replaceAll('.', '').trim())
                        .isAfter(DateTime.now()
                            .subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                    // finalNewsArticlesList.removeWhere((element) => DateFormat('MMM dd')
                    //     .parse(element.date.replaceAll('.', '').trim())
                    //     .isBefore(DateTime.now().subtract(const Duration(days: 14))));
                  } catch (e) {
                    debugPrint(
                        "^^^ ERROR PARSING PROPUBLICA DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              case "apnews":
                {
                  try {
                    if (DateFormat('MMMM dd, yyyy')
                        .parse(article.date.trim())
                        .isAfter(DateTime.now()
                            .subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                    // finalNewsArticlesList.removeWhere((element) => DateFormat('MMMM dd, yyyy')
                    //     .parse(element.date.trim())
                    //     .isBefore(DateTime.now().subtract(const Duration(days: 14))));
                  } catch (e) {
                    debugPrint(
                        "^^^ ERROR PARSING AP NEWS DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              default:
                {
                  debugPrint("^^^^^ NO ACTION TAKEN FOR SLUG ${article.slug}");
                }
            }
          }

          // if (_finalNewsArticlesList.length > 30) {
          //   _finalNewsArticlesList.removeRange(
          //       30, _finalNewsArticlesList.length);
          // }

          // finalNewsArticlesList.removeWhere((element) =>
          //     element.date.isAfter(DateTime.now()) ||
          //     element.title == '' ||
          //     element.title == null);

          // List<ArticlesResults> _unsortedNewsArticlesList =
          //     _finalNewsArticleList;

          // /// SORT ALL ARTICLES BY DATE
          // logger.d('***** FILTERING AND SORTING FINAL ARTICLES LIST *****');
          // _finalNewsArticleList
          //     .sort((a, b) => b.date.toString().compareTo(a.date.toString()));

          // /// REORDER ALL ARTICLES TO SHOW THOSE MEMBERS THE USER
          // /// IS SUBSCRIBED TO AT THE TOP OF THE LIST
          // List<ArticlesResults> _subscribedMemberArticles = [];
          // List<ArticlesResults> _notSubscribedMemberArticles = [];
          // _finalNewsArticleList.forEach((article) {
          //   if (List.from(userDatabase.get('subscriptionAlertsList')).any(
          //       (item) => item
          //           .toString()
          //           .toLowerCase()
          //           .contains(article.memberId.toLowerCase())))
          //     _subscribedMemberArticles.add(article);
          //   else
          //     _notSubscribedMemberArticles.add(article);
          // });

          // _finalNewsArticleList =
          //     _subscribedMemberArticles + _notSubscribedMemberArticles;

          if (finalNewsArticlesList.isNotEmpty) {
            finalNewsArticlesList.sort((a, b) => a.index.compareTo(b.index));
            if (currentNewsArticlesList.isEmpty ||
                    !currentNewsArticlesList.any((element) =>
                        element.title == finalNewsArticlesList.first.title)
                // newsArticles.first.title !=
                //     _currentNewsArticlesList.first.title
                ) {
              debugPrint('^^^^^ CHECKING TITLES FOR MEMBERS AND NEW ITEMS');
              sendNotifications = true;
              userDatabase.put('newNewsArticles', true);

              try {
                membersList = memberPayloadFromJson(
                            userDatabase.get('houseMembersList'))
                        .results
                        .first
                        .members +
                    memberPayloadFromJson(userDatabase.get('senateMembersList'))
                        .results
                        .first
                        .members;

                thisMember = membersList.firstWhere((element) =>
                    finalNewsArticlesList.first.title
                        .toLowerCase()
                        .contains(element.firstName.toLowerCase()) &&
                    finalNewsArticlesList.first.title
                        .toLowerCase()
                        .contains(element.lastName.toLowerCase()));
                debugPrint(
                    '^^^^^ MEMBER FOUND FOR NEWS ARTICLE RETRIEVAL FUNCTION: ${thisMember.firstName} ${thisMember.lastName}');
              } catch (e) {
                logger.w(
                    'ERROR DURING RETRIEVAL OF MEMBERS LIST (News Articles Function): $e');
              }

              if (userIsDev) {
                final NewsArticle thisArticle = finalNewsArticlesList.first;

                final subject = thisArticle.title.toUpperCase();
                final messageBody =
                    '${thisMember == null ? '' : '.@${thisMember.twitterAccount} in the news:'} ${thisArticle.title.length > 150 ? thisArticle.title.replaceRange(150, null, '...') : thisArticle.title}';

                List<String> capitolBabbleNotificationsList = List<String>.from(
                    userDatabase.get('capitolBabbleNotificationsList'));
                capitolBabbleNotificationsList.add(
                    '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>medium<|:|>${thisArticle.url == null || thisArticle.url.isEmpty ? '' : thisArticle.url}');
                userDatabase.put('capitolBabbleNotificationsList',
                    capitolBabbleNotificationsList);
              }
            }

            if (currentNewsArticlesList.isEmpty) {
              currentNewsArticlesList = finalNewsArticlesList;
            }

            try {
              logger.d('***** SAVING NEW ARTICLES TO DBASE *****');
              userDatabase.put(
                  'newsArticles', newsArticleToJson(finalNewsArticlesList));
            } catch (e) {
              logger.w(
                  '^^^^^ ERROR SAVING ARTICLES LIST TO DBASE (FUNCTION): $e ^^^^^');
              userDatabase.put('newsArticles', {});
            }
          } else {
            logger.w('NEW ARTICLES LIST IS EMPTY AFTER PRUNING');
            return [];
          }
        }

        bool memberWatched = thisMember != null &&
            subscriptionAlertsList.any((item) =>
                item.toLowerCase().contains(thisMember.id.toLowerCase()));

        // bool memberWatched = await hasSubscription(
        //     userIsPremium,
        //     userIsLegacy,
        //     (_finalNewsArticlesList.map((e) => e.memberId)).toList().asMap(),
        //     'member_',
        //     userIsDev: userIsDev);

        if ((userDatabase.get('newsAlerts') || memberWatched) &&
            sendNotifications) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                15,
                'news_articles',
                'News Article',
                'US Congress News',
                'Latest News',
                'US Congress News',
                memberWatched
                    ? 'A member you\'re watching is in the news!'
                    : finalNewsArticlesList.first.title,
                'news');
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message: memberWatched
                    ? '🧑🏽‍💼 A member you\'re watching is in the news!'
                    : finalNewsArticlesList.first.title,
                networkImageUrl: finalNewsArticlesList.first.imageUrl,
                isAlert: false,
                removeCurrent: false);
          }
        }

        userDatabase.put('lastNewsArticlesRefresh', '${DateTime.now()}');

        return finalNewsArticlesList;
        // } else {
        //   logger.w('NEW STATEMENTS LIST IS EMPTY AFTER PRUNING');
        //   return [];
        // }
      } else {
        logger.w(
            '***** API ERROR: LOADING ARTICLES FROM DBASE: ${response.statusCode} *****');

        return finalNewsArticlesList =
            currentNewsArticlesList.isNotEmpty ? currentNewsArticlesList : [];
      }
    } else {
      logger.d(
          '***** CURRENT ARTICLES LIST: ${currentNewsArticlesList.map((e) => e.title)} *****');
      finalNewsArticlesList = currentNewsArticlesList;
      logger.d('***** ARTICLES NOT UPDATED: LIST IS CURRENT *****');
      return finalNewsArticlesList;
    }
  }

  static Future<List<StatementsResults>> fetchStatements(
      {BuildContext context}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<StatementsResults> currentStatementsList = [];

    try {
      currentStatementsList =
          statementsFromJson(userDatabase.get('statementsResponse')).results;
    } catch (e) {
      logger.w('^^^^^ ERROR DURING STATEMENTS LIST (FUNCTION): $e ^^^^^');
      userDatabase.put('statementsResponse', {});
      currentStatementsList = [];
    }

    List<StatementsResults> finalStatementsList = [];

    if (currentStatementsList.isEmpty ||
        DateTime.parse(userDatabase.get('lastStatementsRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(hours: 6)))) {
      logger.d('***** RETRIEVING LATEST STATEMENTS... *****');
      final url = PropublicaApi().memberStatementsApi;
      final headers = PropublicaApi().apiHeaders;
      final authority = PropublicaApi().authority;
      final response =
          await http.get(Uri.https(authority, url), headers: headers);
      logger.d(
          '***** STATEMENTS API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('***** STATEMENTS RETRIEVAL SUCCESS! *****');
        final Statements statements = statementsFromJson(response.body);
        List<ChamberMember> membersList = [];
        ChamberMember thisMember;
        StatementsResults thisStatement;

        if (statements.status == 'OK' && statements.results.isNotEmpty) {
          finalStatementsList = statements.results;
          finalStatementsList.removeWhere((element) =>
              element.date.isAfter(DateTime.now()) ||
              element.title == '' ||
              element.title == null);

          List<StatementsResults> unsortedStatementsList = finalStatementsList;

          /// SORT ALL STATEMENTS BY DATE
          logger.d('***** FILTERING AND SORTING FINAL STATEMENTS LIST *****');
          finalStatementsList
              .sort((a, b) => b.date.toString().compareTo(a.date.toString()));

          /// REORDER ALL STATEMENTS TO SHOW THOSE MEMBERS THE USER
          /// IS SUBSCRIBED TO AT THE TOP OF THE LIST
          List<StatementsResults> subscribedMemberStatements = [];
          List<StatementsResults> notSubscribedMemberStatements = [];
          for (var statement in finalStatementsList) {
            if (List.from(userDatabase.get('subscriptionAlertsList')).any(
                (item) => item
                    .toString()
                    .toLowerCase()
                    .contains(statement.memberId.toLowerCase()))) {
              subscribedMemberStatements.add(statement);
            } else {
              notSubscribedMemberStatements.add(statement);
            }
          }

          finalStatementsList =
              subscribedMemberStatements + notSubscribedMemberStatements;

          if (finalStatementsList.isNotEmpty) {
            if (currentStatementsList.isEmpty ||
                statements.results.first.title !=
                    currentStatementsList.first.title) {
              userDatabase.put('newStatements', true);

              try {
                membersList = memberPayloadFromJson(
                            userDatabase.get('houseMembersList'))
                        .results
                        .first
                        .members +
                    memberPayloadFromJson(userDatabase.get('senateMembersList'))
                        .results
                        .first
                        .members;

                thisMember = membersList.firstWhere((element) =>
                    element.id.toLowerCase() ==
                    unsortedStatementsList.first.memberId.toLowerCase());
              } catch (e) {
                logger.w(
                    'ERROR DURING RETRIEVAL OF MEMBERS LIST (Statements Function): $e');
              }

              if (userIsDev && thisMember != null) {
                thisStatement = unsortedStatementsList.first;

                final subject =
                    'Public statement from ${thisStatement.name}'.toUpperCase();
                final messageBody =
                    '${thisMember == null ? thisStatement.name : '.@${thisMember.twitterAccount}'}: ${thisStatement.title.length > 150 ? thisStatement.title.replaceRange(150, null, '...') : thisStatement.title}';

                List<String> capitolBabbleNotificationsList = List<String>.from(
                    userDatabase.get('capitolBabbleNotificationsList'));
                capitolBabbleNotificationsList.add(
                    '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>regular<|:|>${thisStatement.url == null || thisStatement.url.isEmpty ? '' : thisStatement.url}');
                userDatabase.put('capitolBabbleNotificationsList',
                    capitolBabbleNotificationsList);
              }
            }

            if (currentStatementsList.isEmpty) {
              currentStatementsList = finalStatementsList;
            }

            try {
              logger.d('***** SAVING NEW STATEMENTS TO DBASE *****');
              userDatabase.put(
                  'statementsResponse', statementsToJson(statements));
            } catch (e) {
              logger.w(
                  '^^^^^ ERROR SAVING STATEMENTS LIST TO DBASE (FUNCTION): $e ^^^^^');
              userDatabase.put('statementsResponse', {});
            }
          } else {
            logger.w('NEW STATEMENTS LIST IS EMPTY AFTER PRUNING');
            return [];
          }
        }

        // if (_finalStatementsList.isNotEmpty) {
        bool memberWatched = await hasSubscription(
            userIsPremium,
            userIsLegacy,
            (finalStatementsList.map((e) => e.memberId)).toList().asMap(),
            'member_',
            userIsDev: userIsDev);

        if (thisMember != null &&
            (userDatabase.get('statementAlerts') || memberWatched) &&
            (currentStatementsList.first.title.toLowerCase() !=
                    statements.results.first.title.toLowerCase() ||
                userDatabase.get('lastStatement').toString().toLowerCase() !=
                    finalStatementsList.first.title.toLowerCase())) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                3,
                'statements',
                'Public Statement',
                'Public Statements from Congressional Members',
                'Public Statement',
                '🧑🏽‍💼 Congressional Statements',
                memberWatched
                    ? thisMember == null
                        ? ''
                        : '${thisMember.shortTitle.replaceFirst('Rep.', 'Hon.')} ${thisMember.firstName} ${thisMember.lastName} has made a public statement'
                    : thisStatement.title,
                statements.results);
          } else if (thisMember != null && ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message: memberWatched
                    ? thisMember == null
                        ? ''
                        : '${thisMember.shortTitle.replaceFirst('Rep.', 'Hon.')} ${thisMember.firstName} ${thisMember.lastName} has made a public statement'
                    : thisStatement.title,
                networkImageUrl:
                    '${PropublicaApi().memberImageRootUrl}${thisStatement.memberId.toLowerCase()}.jpg',
                isAlert: false,
                removeCurrent: false);
          }
        }
        userDatabase.put(
            'lastStatement', finalStatementsList.first.title.toLowerCase());
        userDatabase.put('lastStatementsRefresh', '${DateTime.now()}');

        return finalStatementsList;
        // } else {
        //   logger.w('NEW STATEMENTS LIST IS EMPTY AFTER PRUNING');
        //   return [];
        // }
      } else {
        logger.w(
            '***** API ERROR: LOADING STATEMENTS FROM DBASE: ${response.statusCode} *****');

        return finalStatementsList =
            currentStatementsList.isNotEmpty ? currentStatementsList : [];
      }
    } else {
      logger.d(
          '***** CURRENT STATEMENTS LIST: ${currentStatementsList.map((e) => e.title)} *****');
      finalStatementsList = currentStatementsList;
      logger.d('***** STATEMENTS NOT UPDATED: LIST IS CURRENT *****');
      return finalStatementsList;
    }
  }

  static Future<List<UpdatedBill>> fetchBills(
      {BuildContext context, int congress = 117}) async {
    Box userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<UpdatedBill> currentUpdatedBillsList = [];

    try {
      currentUpdatedBillsList =
          recentbillsFromJson(userDatabase.get('recentBills'))
              .results
              .first
              .bills;
    } catch (e) {
      logger.w('^^^^^ ERROR DURING BILL LIST (FUNCTION): $e ^^^^^');
      userDatabase.put('recentBills', {});
      currentUpdatedBillsList = [];
    }

    List<UpdatedBill> finalUpdatedBillsList = [];

    if (currentUpdatedBillsList.isEmpty ||
        DateTime.parse(userDatabase.get('lastBillsRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(hours: 3)))) {
      logger.d('***** RETRIEVING LATEST BILLS... *****');
      String url = 'congress/v1/$congress/both/bills/active.json';
      final headers = PropublicaApi().apiHeaders;
      final authority = PropublicaApi().authority;

      final response =
          await http.get(Uri.https(authority, url), headers: headers);
      logger.d('***** BILLS API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        Recentbills recentBills = recentbillsFromJson(response.body);
        logger.d(
            '***** BILLS RETRIEVAL SUCCESS! Status: ${recentBills.status} *****');
        if (recentBills.status == 'OK' && recentBills.results.isNotEmpty) {
          finalUpdatedBillsList = recentBills.results.first.bills;

          if (currentUpdatedBillsList.isEmpty ||
              finalUpdatedBillsList.first.billId !=
                  currentUpdatedBillsList.first.billId) {
            userDatabase.put('newBills', true);

            if (userIsDev) {
              final subject =
                  'BILL ${finalUpdatedBillsList.first.billId.toUpperCase()} UPDATED';
              final messageBody =
                  'BILL ${finalUpdatedBillsList.first.billId.toUpperCase()} UPDATED: ${finalUpdatedBillsList.first.shortTitle.length > 150 ? finalUpdatedBillsList.first.shortTitle.replaceRange(150, null, '...') : finalUpdatedBillsList.first.shortTitle} ➭ ${finalUpdatedBillsList.first.latestMajorAction}';

              List<String> capitolBabbleNotificationsList = List<String>.from(
                  userDatabase.get('capitolBabbleNotificationsList'));
              capitolBabbleNotificationsList.add(
                  '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>medium');
              userDatabase.put('capitolBabbleNotificationsList',
                  capitolBabbleNotificationsList);
            }
          }

          if (currentUpdatedBillsList.isEmpty) {
            currentUpdatedBillsList = finalUpdatedBillsList;
          }

          try {
            logger.d('***** SAVING NEW BILLS TO DBASE *****');
            userDatabase.put('recentBills', recentbillsToJson(recentBills));
          } catch (e) {
            logger.w(
                '^^^^^ ERROR SAVING BILL LIST TO DBASE (FUNCTION): $e ^^^^^');
            userDatabase.put('recentBills', {});
          }
        }

        bool billWatched = await hasSubscription(
            userIsPremium,
            userIsLegacy,
            ((finalUpdatedBillsList.map((e) => e.billId).toList()).asMap()),
            'bill_',
            userIsDev: userIsDev);

        if (
            // (userIsPremium || userIsLegacy) &&
            (userDatabase.get('billAlerts') || billWatched) &&
                (currentUpdatedBillsList.first.billId.toLowerCase() !=
                        finalUpdatedBillsList.first.billId.toLowerCase() ||
                    userDatabase.get('lastBill').toString().toLowerCase() !=
                        finalUpdatedBillsList.first.billId.toLowerCase())) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                4,
                'bills',
                'Congressional Bill',
                'Congressional bills recently introduced or updated',
                'Congressional Bill',
                '📜 ${finalUpdatedBillsList.first.billId}'.toUpperCase(),
                billWatched
                    ? 'A bill you\'re watching has been updated in \'Recent Bills\''
                    : finalUpdatedBillsList.first.shortTitle,
                recentBills);
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message: billWatched
                    ? 'A bill you\'re watching has been updated in \'Recent Bills\''
                    : 'New congressional bills listed',
                isAlert: false,
                removeCurrent: false);
          }
        }
        userDatabase.put(
            'lastBill', finalUpdatedBillsList.first.billId.toLowerCase());
        userDatabase.put('lastBillsRefresh', '${DateTime.now()}');
        return finalUpdatedBillsList;
      } else {
        logger.w(
            '***** API ERROR: LOADING BILLS FROM DBASE: ${response.statusCode} *****');

        return finalUpdatedBillsList =
            currentUpdatedBillsList.isNotEmpty ? currentUpdatedBillsList : [];
      }
    } else {
      logger.d(
          '***** CURRENT BILLS LIST: ${currentUpdatedBillsList.map((e) => e.billId)} *****');
      finalUpdatedBillsList = currentUpdatedBillsList;
      logger.d('***** BILLS NOT UPDATED: LIST IS CURRENT *****');
      return finalUpdatedBillsList;
    }
  }

  static Future<List<Vote>> fetchVotes({
    BuildContext context,
  }) async {
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    List<bool> userLevels = await getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<Vote> currentVotesList = [];

    try {
      currentVotesList =
          payloadFromJson(userDatabase.get('recentVotes')).results.votes;
    } catch (e) {
      logger.w('^^^^^ ERROR DURING VOTE LIST (FUNCTION): $e ^^^^^');
      userDatabase.put('recentVotes', {});
      currentVotesList = [];
    }

    List<Vote> finalVotesList = [];

    if (currentVotesList.isEmpty ||
        DateTime.parse(userDatabase.get('lastVotesRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(minutes: 30)))) {
      logger.d('***** RETRIEVING LATEST VOTES... *****');

      final authority = PropublicaApi().authority;
      final url = PropublicaApi().recentChamberVotesApi;
      final headers = PropublicaApi().apiHeaders;

      final response =
          await http.get(Uri.https(authority, url), headers: headers);
      logger.d('***** VOTES API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('***** VOTES RETRIEVAL SUCCESS! *****');
        Payload recentVotes = payloadFromJson(response.body);
        if (recentVotes.status == 'OK' &&
            recentVotes.results.votes.isNotEmpty) {
          finalVotesList = recentVotes.results.votes;

          if (currentVotesList.isEmpty ||
              finalVotesList.first.description !=
                  currentVotesList.first.description) {
            userDatabase.put('newVotes', true);

            if (userIsDev) {
              final subject =
                  'NEW VOTE RECORDED ${finalVotesList.first.bill.billId.toLowerCase() == 'nobillid' ? '' : 'ON BILL ${finalVotesList.first.bill.billId.toUpperCase()}'}';
              final messageBody =
                  '${finalVotesList.first.chamber == null ? '' : '${finalVotesList.first.chamber.name} '}Roll Call #${finalVotesList.first.rollCall} ${finalVotesList.first.bill.billId.toLowerCase() == 'nobillid' ? '' : 'Vote On Bill ${finalVotesList.first.bill.billId.toUpperCase()}'} [${finalVotesList.first.result == null || finalVotesList.first.result.toString() == 'No Results' ? 'RECORDED' : finalVotesList.first.result.name.toUpperCase()}] :: ${finalVotesList.first.question} => ${finalVotesList.first.description.length > 150 ? finalVotesList.first.description.replaceRange(150, null, '...') : finalVotesList.first.description}';

              List<String> capitolBabbleNotificationsList = List<String>.from(
                  userDatabase.get('capitolBabbleNotificationsList'));
              capitolBabbleNotificationsList.add(
                  '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>medium');
              userDatabase.put('capitolBabbleNotificationsList',
                  capitolBabbleNotificationsList);
            }
          }

          if (currentVotesList.isEmpty) currentVotesList = finalVotesList;

          try {
            logger.d('***** SAVING NEW VOTES TO DBASE *****');
            userDatabase.put('recentVotes', payloadToJson(recentVotes));
          } catch (e) {
            logger.w(
                '^^^^^ ERROR SAVING VOTES LIST TO DBASE (FUNCTION): $e ^^^^^');
            userDatabase.put('recentVotes', {});
          }
        }

        bool billWatched = await hasSubscription(
            userIsPremium,
            userIsLegacy,
            (finalVotesList.map((e) => e.bill.billId)).toList().asMap(),
            'bill_',
            userIsDev: userIsDev);

        logger.i(
            'CURRENT 1ST VOTE ROLL CALL: ${currentVotesList.first.rollCall} - FINAL 1ST VOTE ROLL CALL: ${finalVotesList.first.rollCall}');

        /// SEND NOTIFICATIONS IF SUBSCRIBED TO VOTE ALERTS
        if (
            // (userIsPremium || userIsLegacy) &&
            (userDatabase.get('voteAlerts') || billWatched) &&
                (currentVotesList.first.rollCall.toString() !=
                        finalVotesList.first.rollCall.toString() ||
                    userDatabase.get('lastVote').toString() !=
                        finalVotesList.first.rollCall.toString())) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                5,
                'votes',
                'Congressional Vote',
                'Congressional votes recently recorded',
                'Congressional Vote',
                '🗳️ ${finalVotesList.first.rollCall}: ${finalVotesList.first.result.name ?? 'RECORDED'}'
                    .toUpperCase(),
                billWatched
                    ? 'A bill you\'re watching has new vote results'
                    : finalVotesList.first.question,
                recentVotes);
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message: billWatched
                    ? 'A bill you\'re watching has new vote results'
                    : 'New congressional votes listed',
                isAlert: false,
                removeCurrent: false);
          }

          /// SEND FOLLOWED MEMBER VOTE POSITION NOTIFICATIONS
          List<String> subscribedMembers =
              List<String>.from(userDatabase.get('subscriptionAlertsList'))
                  .where((element) => element.startsWith('member_'))
                  .toList();

          if ((userIsPremium || userIsLegacy) &&
              userDatabase.get('memberAlerts') &&
              subscribedMembers.isNotEmpty) {
            debugPrint(
                '***** DETERMINING FOLLOWED MEMBER ROLLCALL VOTE POSITIONS FOR $subscribedMembers *****');

            List<ChamberMember> membersList = [];
            Map<String, dynamic> memberVotePositions = {};

            final List<RcPosition> rollCallPositions =
                await getRollCallPositions(
                    finalVotesList.first.congress,
                    finalVotesList.first.chamber.name.toLowerCase(),
                    finalVotesList.first.session,
                    finalVotesList.first.rollCall);

            try {
              List<ChamberMember> membersList = memberPayloadFromJson(
                          userDatabase.get('houseMembersList'))
                      .results
                      .first
                      .members +
                  memberPayloadFromJson(userDatabase.get('senateMembersList'))
                      .results
                      .first
                      .members;
              membersList = membersList
                  .where((member) =>
                      subscribedMembers.any((item) => item.contains(member.id)))
                  .toList();

              debugPrint(
                  membersList.map((e) => '${e.id}: ${e.firstName}').toString());
            } catch (e) {
              debugPrint(
                  'ERROR DURING RETRIEVAL OF MEMBERS LIST (Fetch Votes Function): $e');
            }

            if (membersList.isNotEmpty && subscribedMembers.isNotEmpty) {
              debugPrint(
                  '***** FINAL LIST OF MEMBER ROLLCALL VOTE POSITIONS ${membersList.map((e) => '${e.lastName}: ${e.id}')} *****');
              for (var mem in membersList) {
                RcPosition thisMemberPosition;
                try {
                  thisMemberPosition = rollCallPositions.firstWhere(
                      (e) => e.memberId.toLowerCase() == mem.id.toLowerCase());
                } catch (e) {
                  debugPrint(
                      'ERROR DURING ROLLCALL POSITION RETRIEVAL OF ${mem.firstName} ${mem.id}: Looks like the roll call position call for this member info returns null (Fetch Votes Function): $e');
                }

                if (thisMemberPosition != null) {
                  memberVotePositions.addAll({
                    '${mem.shortTitle.replaceAll('Rep.', 'Hon.')} ${mem.firstName} ${mem.lastName}':
                        thisMemberPosition.votePosition
                  });
                }

                debugPrint(memberVotePositions.entries
                    .map((e) => '${e.key}: ${e.value}')
                    .toString());
              }

              if (context == null || !ModalRoute.of(context).isCurrent) {
                await NotificationApi.showBigTextNotification(
                    14,
                    'followed_member_vote_positions',
                    'Member Vote',
                    'Followed Member Vote Positions',
                    'Followed Member Votes',
                    'Vote positions by members you\'re following',
                    '-- Roll Call ${finalVotesList.first.rollCall} --\n${finalVotesList.first.question}\n[${finalVotesList.first.result.name == null ? 'RECORDED' : finalVotesList.first.result.name.toUpperCase()}]\n${memberVotePositions.entries.map((e) => '${e.key}: ${e.value}\n')}'
                        .replaceFirst('(', '')
                        .replaceFirst(')', '')
                        .replaceAll(',', ''),
                    'followed_member_vote_positions');
              } else if (ModalRoute.of(context).isCurrent) {
                Messages.showMessage(
                    context: context,
                    message:
                        '-- Roll Call ${finalVotesList.first.rollCall} --\n${finalVotesList.first.question}\n[${finalVotesList.first.result.name == null ? 'RECORDED' : finalVotesList.first.result.name.toUpperCase()}]\n${memberVotePositions.entries.map((e) => '${e.key}: ${e.value}\n')}'
                            .replaceFirst('(', '')
                            .replaceFirst(')', '')
                            .replaceAll(',', ''),
                    isAlert: false,
                    removeCurrent: false,
                    durationInSeconds: memberVotePositions.length * 5);
              }
            } else {
              debugPrint(
                  '***** MEMBER ROLLCALL VOTE POSITIONS NOT RETRIEVED: FULL MEMBERS LIST OR SUBSCRIBED MEMBERS LIST IS EMPTY *****');
            }
          } else {
            debugPrint(
                '***** NO FOLLOWED MEMBER ROLLCALL VOTE POSITIONS *****');
          }
        }

        userDatabase.put('lastVote', finalVotesList.first.rollCall.toString());
        userDatabase.put('lastVotesRefresh', '${DateTime.now()}');
        return finalVotesList;
      } else {
        logger.w(
            '***** API ERROR: LOADING VOTES FROM DBASE: ${response.statusCode} *****');

        return finalVotesList =
            currentVotesList.isNotEmpty ? currentVotesList : [];
      }
    } else {
      logger.d(
          '***** CURRENT VOTES LIST: ${currentVotesList.map((e) => e.rollCall)} *****');
      finalVotesList = currentVotesList;
      logger.d('***** VOTES NOT UPDATED: LIST IS CURRENT *****');
      return finalVotesList;
    }
  }

  static Future<List<LobbyingRepresentation>> fetchRecentLobbyEvents({
    BuildContext context,
  }) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<LobbyingRepresentation> currentLobbyingEventsList = [];
    try {
      currentLobbyingEventsList =
          lobbyEventFromJson(userDatabase.get('lobbyingEventsList'))
              .results
              .first
              .lobbyingRepresentations;
    } catch (e) {
      logger.d('***** CURRENT Lobbying Actions ERROR: $e - Resetting... *****');
      userDatabase.put('lobbyingEventsList', {});
      currentLobbyingEventsList = [];
    }

    List<LobbyingRepresentation> finalLobbyingEventsList = [];

    if (currentLobbyingEventsList.isEmpty ||
        DateTime.parse(userDatabase.get('lastLobbyingRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(hours: 4)))) {
      logger.d('***** Retrieving Lobbying Events... *****');

      final authority = PropublicaApi().authority;
      final url = PropublicaApi().latestLobbyingApi;
      final headers = PropublicaApi().apiHeaders;

      final response =
          await http.get(Uri.https(authority, url), headers: headers);
      logger.d('***** LOBBY API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('***** LOBBY RETRIEVAL SUCCESS! *****');
        LobbyEvent lobbyEvent = lobbyEventFromJson(response.body);

        if (lobbyEvent.status == 'OK' &&
            lobbyEvent.results.first.lobbyingRepresentations.isNotEmpty) {
          finalLobbyingEventsList =
              lobbyEvent.results.first.lobbyingRepresentations;

          finalLobbyingEventsList.removeWhere((element) =>
              element.specificIssues.isEmpty ||
              element.specificIssues.first.toLowerCase() == 'none');

          if (currentLobbyingEventsList.isEmpty ||
              finalLobbyingEventsList.first.id !=
                  currentLobbyingEventsList.first.id) {
            userDatabase.put('newLobbies', true);

            if (userIsDev) {
              final subject =
                  'NEW LOBBYING FILED ON BEHALF OF ${finalLobbyingEventsList.first.lobbyingClient.name}';
              final messageBody =
                  '${finalLobbyingEventsList.first.lobbyingClient.name} is lobbying congress ➭ ${finalLobbyingEventsList.first.specificIssues.first.length > 150 ? finalLobbyingEventsList.first.specificIssues.first.replaceRange(150, null, '...') : finalLobbyingEventsList.first.specificIssues.first}';

              List<String> capitolBabbleNotificationsList = List<String>.from(
                  userDatabase.get('capitolBabbleNotificationsList'));
              capitolBabbleNotificationsList.add(
                  '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>regular');
              userDatabase.put('capitolBabbleNotificationsList',
                  capitolBabbleNotificationsList);
            }
          }

          if (currentLobbyingEventsList.isEmpty) {
            currentLobbyingEventsList = finalLobbyingEventsList;
          }

          try {
            logger.i('***** SAVING NEW LOBBIES TO DBASE *****');
            userDatabase.put(
                'lobbyingEventsList', lobbyEventToJson(lobbyEvent));
          } catch (e) {
            logger.w(
                '^^^^^ ERROR SAVING LOBBY LIST TO DBASE (FUNCTION): $e ^^^^^');
            userDatabase.put('lobbyingEventsList', {});
          }
        }

        bool lobbyWatched = await hasSubscription(
            userIsPremium,
            userIsLegacy,
            (finalLobbyingEventsList.map((e) => e.id)).toList().asMap(),
            'lobby_',
            userIsDev: userIsDev);

        if ((userIsPremium || userIsLegacy) &&
            (userDatabase.get('lobbyingAlerts') ||
                (lobbyWatched &&

                    /// THIS COMPARISON CHECK IS SKETCHY
                    !currentLobbyingEventsList.map((e) => e.id).any((element) =>
                        finalLobbyingEventsList
                            .map((e) => e.id)
                            .contains(element)))) &&
            (currentLobbyingEventsList.first.id.toLowerCase() !=
                    finalLobbyingEventsList.first.id.toLowerCase() ||
                userDatabase.get('lastLobby').toString().toLowerCase() !=
                    finalLobbyingEventsList.first.id.toLowerCase())) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                6,
                'lobbying',
                'Lobbying Activity',
                'Congressional Lobbying Activities',
                'Lobbying Activity',
                '💲${finalLobbyingEventsList.first.lobbyingClient.name}',
                lobbyWatched
                    ? 'A lobbying event you\'re watching has been updated'
                    : finalLobbyingEventsList.first.specificIssues.first,
                'lobbying');
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
              context: context,
              message: lobbyWatched
                  ? 'A lobbying event you\'re watching has been updated'
                  : 'New lobbying events listed',
              assetImageString: 'assets/lobbying${random.nextInt(2)}.png',
              isAlert: false,
              removeCurrent: false,
            );
          }
        }
        userDatabase.put(
            'lastLobby', finalLobbyingEventsList.first.id.toLowerCase());
        userDatabase.put('lastLobbyingRefresh', '${DateTime.now()}');
        return finalLobbyingEventsList;
      } else {
        logger.w(
            '***** API ERROR: LOADING LOBBIES FROM DBASE: ${response.statusCode} *****');

        return finalLobbyingEventsList = currentLobbyingEventsList.isNotEmpty
            ? currentLobbyingEventsList
            : [];
      }
    } else {
      logger.d(
          '***** CURRENT LOBBY LIST: ${currentLobbyingEventsList.map((e) => e.id)} *****');
      finalLobbyingEventsList = currentLobbyingEventsList;
      logger.d('***** LOBBIES NOT UPDATED: LIST IS CURRENT *****');
      return finalLobbyingEventsList;
    }
  }

  static Future<List<PrivateTripResult>> fetchPrivateFundedTravel(
    int congress, {
    BuildContext context,
  }) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<PrivateTripResult> currentPrivateFundedTripList = [];
    try {
      currentPrivateFundedTripList =
          privateFundedTripFromJson(userDatabase.get('privateFundedTripsList'))
              .results;
    } catch (e) {
      logger.d('***** CURRENT PRIVATE TRIPS ERROR: $e - Resetting... *****');
      userDatabase.put('privateFundedTripsList', {});
      currentPrivateFundedTripList = [];
    }

    List<PrivateTripResult> finalPrivateFundedTripList = [];

    if (currentPrivateFundedTripList.isEmpty ||
        DateTime.parse(userDatabase.get('lastPrivateFundedTripsRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(hours: 4)))) {
      logger.d('***** Retrieving Privately Funded Trips... *****');

      final authority = PropublicaApi().authority;
      final url = 'congress/v1/$congress/private-trips.json';
      final headers = PropublicaApi().apiHeaders;

      final response =
          await http.get(Uri.https(authority, url), headers: headers);
      logger
          .d('***** PRIVATE TRIPS RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('***** PRIVATE TRIPS RETRIEVAL SUCCESS! *****');
        PrivateFundedTrip privateFundedTrip =
            privateFundedTripFromJson(response.body);
        List<ChamberMember> membersList = [];
        ChamberMember thisMember;

        if (privateFundedTrip.status == 'OK' &&
            privateFundedTrip.results.isNotEmpty) {
          finalPrivateFundedTripList = privateFundedTrip.results;

          if (currentPrivateFundedTripList.isEmpty ||
              finalPrivateFundedTripList.first.documentId !=
                  currentPrivateFundedTripList.first.documentId) {
            userDatabase.put('newTrips', true);

            try {
              membersList = memberPayloadFromJson(
                          userDatabase.get('houseMembersList'))
                      .results
                      .first
                      .members +
                  memberPayloadFromJson(userDatabase.get('senateMembersList'))
                      .results
                      .first
                      .members;

              thisMember = membersList.firstWhere((element) =>
                  element.id.toLowerCase() ==
                  finalPrivateFundedTripList.first.memberId.toLowerCase());
            } catch (e) {
              logger.w(
                  'ERROR DURING RETRIEVAL OF MEMBERS LIST (Funded Travel Function): $e');
            }

            if (userIsDev) {
              final subject =
                  'PRIVATELY FUNDED TRAVEL FILED BY ${finalPrivateFundedTripList.first.displayName}';
              final messageBody =
                  '${thisMember == null ? finalPrivateFundedTripList.first.displayName : '.@${thisMember.twitterAccount}'} has reported privately funded travel sponsored by ${finalPrivateFundedTripList.first.sponsor}';

              List<String> capitolBabbleNotificationsList = List<String>.from(
                  userDatabase.get('capitolBabbleNotificationsList'));
              capitolBabbleNotificationsList.add(
                  '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>regular');
              userDatabase.put('capitolBabbleNotificationsList',
                  capitolBabbleNotificationsList);
            }
          }

          if (currentPrivateFundedTripList.isEmpty) {
            currentPrivateFundedTripList = finalPrivateFundedTripList;
          }

          try {
            logger.i('***** SAVING NEW PRIVATE TRIPS TO DBASE *****');
            userDatabase.put('privateFundedTripsList',
                privateFundedTripToJson(privateFundedTrip));
          } catch (e) {
            logger.w(
                '^^^^^ ERROR SAVING PRIVATE TRIPS LIST TO DBASE (FUNCTION): $e ^^^^^');
            userDatabase.put('privateFundedTripsList', {});
          }
        }

        bool memberWatched = await hasSubscription(
            userIsPremium,
            userIsLegacy,
            (finalPrivateFundedTripList.map((e) => e.memberId))
                .toList()
                .asMap(),
            'member_',
            userIsDev: userIsDev);

        if (userIsPremium &&
            (userDatabase.get('privateFundedTripsAlerts') || memberWatched) &&
            (currentPrivateFundedTripList.first.documentId.toLowerCase() !=
                    finalPrivateFundedTripList.first.documentId.toLowerCase() ||
                userDatabase
                        .get('lastPrivateFundedTrip')
                        .toString()
                        .toLowerCase() !=
                    finalPrivateFundedTripList.first.documentId
                        .toLowerCase())) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                7,
                'trips',
                'Privately Funded Trips',
                'Congressional Privately Funded Trips Activity',
                'Privately Funded Trip Activity',
                '✈️${finalPrivateFundedTripList.first.displayName}',
                memberWatched
                    ? 'A member you\'re watching logged a privately funded trip'
                    : 'New privately funded trip sponsored by ${finalPrivateFundedTripList.first.sponsor}',
                privateFundedTrip);
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
              context: context,
              message: memberWatched
                  ? 'A member you\'re watching logged a privately funded trip'
                  : 'New privately funded trips logged',
              networkImageUrl: thisMember == null
                  ? ''
                  : '${PropublicaApi().memberImageRootUrl}${thisMember.id}.jpg',
              isAlert: false,
              removeCurrent: false,
            );
          }
        }
        userDatabase.put('lastPrivateFundedTrip',
            finalPrivateFundedTripList.first.documentId.toLowerCase());
        userDatabase.put('lastPrivateFundedTripsRefresh', '${DateTime.now()}');
        return finalPrivateFundedTripList;
      } else {
        logger.w(
            '***** API ERROR: LOADING PRIVATE TRIPS FROM DBASE: ${response.statusCode} *****');

        return finalPrivateFundedTripList =
            currentPrivateFundedTripList.isNotEmpty
                ? currentPrivateFundedTripList
                : [];
      }
    } else {
      logger.d(
          '***** CURRENT PRIVATE TRIPS LIST: ${currentPrivateFundedTripList.map((e) => e.documentId)} *****');
      finalPrivateFundedTripList = currentPrivateFundedTripList;
      logger.d('***** PRIVATE TRIPS NOT UPDATED: LIST IS CURRENT *****');
      return finalPrivateFundedTripList;
    }
  }

  static Future<List<FloorAction>> senateFloor({
    BuildContext context,
  }) async {
    logger.d('***** [Begin] Senate Floor Actions *****');
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<FloorAction> currentSenateFloorActions = [];

    try {
      currentSenateFloorActions =
          floorActionsFromJson(userDatabase.get('senateFloorActionsList'))
              .results
              .first
              .floorActions;
    } catch (e) {
      logger.w(
          '***** CURRENT Senate Floor Actions ERROR: $e - Resetting... *****');
      userDatabase.put('senateFloorActionsList', {});
      currentSenateFloorActions = [];
    }

    List<FloorAction> finalSenateFloorActions = [];

    if (currentSenateFloorActions.isEmpty ||
        DateTime.parse(userDatabase.get('lastSenateFloorActionsRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(minutes: 30)))) {
      debugPrint('CHECKING FOR UPDATED SENATE FLOOR ACTIONS...');
      final url = PropublicaApi().senateFloorUpdatesApi;
      final headers = PropublicaApi().apiHeaders;
      final authority = PropublicaApi().authority;
      final response =
          await http.get(Uri.https(authority, url), headers: headers);
      debugPrint(
          '***** SENATE FLOOR ACTION API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('***** SENATE FLOOR ACTIONS RETRIEVAL SUCCESS! *****');
        FloorActions senateFloorActions = floorActionsFromJson(response.body);

        if (senateFloorActions.status == 'OK' &&
            senateFloorActions.results.first.floorActions.isNotEmpty) {
          finalSenateFloorActions =
              senateFloorActions.results.first.floorActions;

          debugPrint(
              'CURRENT 1ST SENATE FLOOR ACTION: ${currentSenateFloorActions.isEmpty ? 'No current senate floor actions' : finalSenateFloorActions.first.description}');
          debugPrint(
              'NEW 1ST SENATE FLOOR ACTION: ${finalSenateFloorActions.first.description}');

          if (currentSenateFloorActions.isEmpty ||
              finalSenateFloorActions.first.actionId !=
                  currentSenateFloorActions.first.actionId) {
            userDatabase.put('newSenateFloor', true);

            if (userIsDev) {
              final subject = finalSenateFloorActions.first.description
                      .contains(' - ')
                  ? 'SENATE FLOOR: ${finalSenateFloorActions.first.description.split(' - ')[0]}'
                  : 'SENATE FLOOR ACTION UPDATE';
              final messageBody =
                  'SENATE FLOOR: ${finalSenateFloorActions.first.description.length > 150 ? finalSenateFloorActions.first.description.replaceRange(150, null, '...') : finalSenateFloorActions.first.description}';

              List<String> capitolBabbleNotificationsList = List<String>.from(
                  userDatabase.get('capitolBabbleNotificationsList'));
              capitolBabbleNotificationsList.add(
                  '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>high');
              userDatabase.put('capitolBabbleNotificationsList',
                  capitolBabbleNotificationsList);
            }
          }

          if (currentSenateFloorActions.isEmpty) {
            currentSenateFloorActions =
                senateFloorActions.results.first.floorActions;
          }

          try {
            logger.d(
                '***** SAVING NEW SENATE FLOOR ACTIONS TO DBASE: ${senateFloorActions.results.first.floorActions.first.date} *****');
            userDatabase.put('senateFloorActionsList',
                floorActionsToJson(senateFloorActions));
          } catch (e) {
            logger.w(
                '^^^^^ ERROR SAVING SENATE FLOOR ACTIONS TO DBASE (FUNCTION): $e ^^^^^');
            userDatabase.put('senateFloorActionsList', {});
          }
        }

        bool billWatched = await hasSubscription(userIsPremium, userIsLegacy,
            finalSenateFloorActions.first.billIds.asMap(), 'bill_',
            userIsDev: userIsDev);

        if ((userDatabase.get('floorAlerts') || billWatched) &&
            (currentSenateFloorActions.first.description.toLowerCase() !=
                    finalSenateFloorActions.first.description.toLowerCase() ||
                userDatabase.get('lastSenateAction').toString().toLowerCase() !=
                    finalSenateFloorActions.first.description.toLowerCase())) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                8,
                'senatefloor',
                'Senate Floor',
                'Floor Actions from the Senate',
                'Senate Floor',
                '📢 Senate Floor Action',
                billWatched
                    ? 'A bill you\'re watching is being discussed on the Senate Floor'
                    : finalSenateFloorActions.first.description,
                senateFloorActions);
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message: billWatched
                    ? 'A bill you\'re watching is being discussed on the Senate Floor'
                    : 'SENATE FLOOR\n${finalSenateFloorActions.first.description}',
                isAlert: false,
                removeCurrent: false);
          }
        }

        userDatabase.put(
            'lastSenateAction', finalSenateFloorActions.first.description);
        userDatabase.put('lastSenateFloorActionsRefresh', '${DateTime.now()}');
        return finalSenateFloorActions;
      } else {
        logger.w(
            '***** API ERROR: LOADING SENATE FLOOR ACTIONS FROM DBASE: ${response.statusCode} *****');

        return finalSenateFloorActions = currentSenateFloorActions.isNotEmpty
            ? currentSenateFloorActions
            : [];
      }
    } else {
      logger.d(
          '***** CURRENT SENATE FLOOR ACTIONS LIST: ${currentSenateFloorActions.map((e) => e.description)} *****');
      finalSenateFloorActions = currentSenateFloorActions;
      logger.d('***** SENATE FLOOR ACTIONS NOT UPDATED: LIST IS CURRENT *****');
      return finalSenateFloorActions;
    }
  }

  static Future<List<FloorAction>> houseFloor({
    BuildContext context,
  }) async {
    logger.d('***** [Begin] House Floor Actions *****');
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    int currentCongress = userDatabase.get('congress');
    List<FloorAction> currentHouseFloorActions = [];

    try {
      currentHouseFloorActions =
          floorActionsFromJson(userDatabase.get('houseFloorActionsList'))
              .results
              .first
              .floorActions;
    } catch (e) {
      logger.w('***** CURRENT House Actions ERROR: $e - Resetting... *****');
      userDatabase.put('houseFloorActionsList', {});
      currentHouseFloorActions = [];
    }

    List<FloorAction> finalHouseFloorActions = [];

    if (currentHouseFloorActions.isEmpty ||
        DateTime.parse(userDatabase.get('lastHouseFloorActionsRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(minutes: 30)))) {
      final url = PropublicaApi().houseFloorUpdatesApi;
      final headers = PropublicaApi().apiHeaders;
      final authority = PropublicaApi().authority;
      final response =
          await http.get(Uri.https(authority, url), headers: headers);
      logger.d(
          '***** HOUSE FLOOR ACTION API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('***** HOUSE FLOOR ACTIONS RETRIEVAL SUCCESS! *****');
        FloorActions houseFloorActions = floorActionsFromJson(response.body);

        if (houseFloorActions.status == 'OK' &&
            houseFloorActions.results.first.floorActions.isNotEmpty) {
          finalHouseFloorActions = houseFloorActions.results.first.floorActions;

          debugPrint(
              'CURRENT 1ST HOUSE FLOOR ACTION: ${currentHouseFloorActions.isEmpty ? 'No current senate floor actions' : finalHouseFloorActions.first.description}');
          debugPrint(
              'NEW 1ST HOUSE FLOOR ACTION: ${finalHouseFloorActions.first.description}');

          if (currentHouseFloorActions.isEmpty ||
              finalHouseFloorActions.first.actionId !=
                  currentHouseFloorActions.first.actionId) {
            userDatabase.put('newHouseFloor', true);

            if (userIsDev) {
              final subject = finalHouseFloorActions.first.description
                      .contains(' - ')
                  ? 'HOUSE FLOOR: ${finalHouseFloorActions.first.description.split(' - ')[0]}'
                  : 'HOUSE FLOOR UPDATE';
              final messageBody =
                  'HOUSE FLOOR: ${finalHouseFloorActions.first.description.length > 150 ? finalHouseFloorActions.first.description.replaceRange(150, null, '...') : finalHouseFloorActions.first.description}';

              List<String> capitolBabbleNotificationsList = List<String>.from(
                  userDatabase.get('capitolBabbleNotificationsList'));
              capitolBabbleNotificationsList.add(
                  '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>high');
              userDatabase.put('capitolBabbleNotificationsList',
                  capitolBabbleNotificationsList);
            }
          }

          if (currentHouseFloorActions.isEmpty) {
            currentHouseFloorActions =
                houseFloorActions.results.first.floorActions;
          }

          try {
            logger.d('***** SAVING NEW HOUSE FLOOR ACTIONS TO DBASE *****');
            userDatabase.put(
                'houseFloorActionsList', floorActionsToJson(houseFloorActions));
          } catch (e) {
            logger.w(
                '^^^^^ ERROR SAVING HOUSE FLOOR ACTIONS TO DBASE (FUNCTION): $e ^^^^^');
            userDatabase.put('houseFloorActionsList', {});
          }
        }

        int congress = int.parse(finalHouseFloorActions.first.congress);
        if (congress.isFinite && congress != currentCongress) {
          userDatabase.put('congress', congress);
        }

        bool billWatched = await hasSubscription(userIsPremium, userIsLegacy,
            finalHouseFloorActions.first.billIds.asMap(), 'bill_',
            userIsDev: userIsDev);

        if ((userDatabase.get('floorAlerts') || billWatched) &&
            (currentHouseFloorActions.first.description.toLowerCase() !=
                    finalHouseFloorActions.first.description.toLowerCase() ||
                userDatabase.get('lastHouseAction').toString().toLowerCase() !=
                    finalHouseFloorActions.first.description.toLowerCase())) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                9,
                'housefloor',
                'House Floor',
                'Floor Actions from the House of Representatives.',
                'House Floor',
                '📢 House Floor Action',
                billWatched
                    ? 'A bill you\'re watching is being discussed on the House Floor'
                    : finalHouseFloorActions.first.description,
                houseFloorActions);
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message: billWatched
                    ? 'A bill you\'re watching is being discussed on the House Floor'
                    : 'HOUSE FLOOR\n${finalHouseFloorActions.first.description}',
                isAlert: false,
                removeCurrent: false);
          }
        }

        userDatabase.put(
            'lastHouseAction', finalHouseFloorActions.first.description);
        userDatabase.put('lastHouseFloorActionsRefresh', '${DateTime.now()}');
        return finalHouseFloorActions;
      } else {
        logger.w(
            '***** API ERROR: LOADING HOUSE FLOOR ACTIONS FROM DBASE: ${response.statusCode} *****');

        return finalHouseFloorActions =
            currentHouseFloorActions.isNotEmpty ? currentHouseFloorActions : [];
      }
    } else {
      logger.d(
          '***** CURRENT HOUSE FLOOR ACTIONS LIST: ${currentHouseFloorActions.map((e) => e.description)} *****');
      finalHouseFloorActions = currentHouseFloorActions;
      logger.d('***** HOUSE FLOOR ACTIONS NOT UPDATED: LIST IS CURRENT *****');
      // userDatabase.put('newHouseFloor', false);
      return finalHouseFloorActions;
    }
  }

  ///
  /// CHECKING RESULTS FOR SUBSCRIBED MEMBERS
  ///
  static Future<bool> hasSubscription(bool userIsPremium, bool userIsLegacy,
      Map<int, dynamic> listToSearch, String prefix,
      {bool userIsDev}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    bool subscribed = false;
    if (userIsPremium || userIsLegacy) {
      List<dynamic> subscribedItems =
          List.from(userDatabase.get('subscriptionAlertsList'));

      subscribedItems
          .retainWhere((element) => element.toString().startsWith(prefix));

      if (listToSearch.isNotEmpty && subscribedItems.isNotEmpty) {
        logger.d('***** SUBSCRIBER CHECK FUNCTION RUNNING HERE... *****');
        for (var item in subscribedItems) {
          logger.d(
              '***** CHECKING LIST ${listToSearch.values} FOR ${item.split('_')[1]} *****');
          if (listToSearch.values.any((val) => val
              .toString()
              .toLowerCase()
              .contains(item.toString().split('_')[1].toLowerCase()))) {
            logger.d(
                '***** SUB CHECK SUCCESS! ${listToSearch.values} CONTAINS ${item.split('_')[1]} *****');
            subscribed = true;
          } else {
            logger.d(
                '***** SUB CHECK FAILED! ${listToSearch.values} DOES NOT CONTAIN ${item.split('_')[1]} *****');
            subscribed = false;
          }
        }
        return subscribed;
      } else {
        logger.d(
            '***** USER IS NOT SUBSCRIBED TO ANY ITEMS. CONTINUING... *****');
        return Future<bool>.value(false);
      }
    } else {
      return subscribed;
    }
  }

  static Future<List<ChamberMember>> getUserCongress(BuildContext context,
      List<ChamberMember> membersList, String zipCode) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    // List<bool> userLevels = await getUserLevels();
    // bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];
    Map<String, dynamic> currentUserCongress = {};

    try {
      currentUserCongress = jsonDecode(userDatabase.get('representativesMap'));
    } catch (e) {
      logger.w('***** CURRENT USER CONGRESS ERROR: $e - Resetting... *****');
      userDatabase.put('representativesMap', {});
      currentUserCongress = {};
    }

    Map<String, dynamic> finalUserCongress = {};

    if (currentUserCongress.isNotEmpty) {
      finalUserCongress = currentUserCongress;
      logger.i('CURRENT USER CONGRESS AVAILABLE AND USED');
    } else if (zipCode != null && zipCode.isNotEmpty) {
      logger.i('RETRIEVING NEW USER CONGRESS');
      final String googleCivicInfoRepFullApiUrl =
          'https://www.googleapis.com/civicinfo/v2/representatives?address=$zipCode&levels=country&key=${dotenv.env['MettaCodeCivicApiKey']}';
      logger.d('***** Retrieving user congress for zip: $zipCode *****');

      final response = await http.get(
        Uri.parse(googleCivicInfoRepFullApiUrl),
      );
      logger.d('***** Response: ${response.statusCode} *****');

      if (response.statusCode == 200 && response.body != null) {
        finalUserCongress = jsonDecode(response.body);

        if (finalUserCongress['kind'] ==
            'civicinfo#representativeInfoResponse') {
          if (currentUserCongress.isEmpty) {
            currentUserCongress = finalUserCongress;
          }

          try {
            logger.d('***** SAVING NEW USER CONGRESS TO DBASE *****');
            userDatabase.put(
                'representativesMap', jsonEncode(finalUserCongress));
          } catch (e) {
            logger.w(
                '^^^^^ ERROR SAVING USER CONGRESS TO DBASE (FUNCTION): $e ^^^^^');
            userDatabase.put('representativesMap', {});
          }
        }
      } else {
        logger.w(
            '***** API ERROR: LOADING USER CONGRESS: ${response.statusCode} *****');

        Messages.showMessage(
            context: context,
            message: 'No representatives found for given zip code $zipCode',
            isAlert: true);

        return [];
      }
    } else {
      logger.e('***** NO ZIP CODE GIVEN FOR USER CONGRESS RETRIEVAL *****');
      return [];
    }

    final String nameString = finalUserCongress['officials']
        .map((official) => official['name'].toLowerCase())
        .toString()
        .replaceAll(RegExp(r'[^a-zA-Z]'), '');

    if (membersList.isNotEmpty) {
      membersList.retainWhere((member) =>
          nameString.contains(member.firstName
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-zA-Z]'), '')) &&
          nameString.contains(member.lastName
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-zA-Z]'), '')));

      membersList.sort((a, b) => a.shortTitle.compareTo(b.shortTitle));

      userDatabase.put('representativesLocation', {
        'city': finalUserCongress['normalizedInput']['city'],
        'state': finalUserCongress['normalizedInput']['state'],
        'country': '',
        'zip': finalUserCongress['normalizedInput']['zip']
      });

      return membersList;
    } else {
      logger.w('USER CONGRESS: NO MEMBERS LIST GIVEN TO PRUNE FROM');
      return [];
    }
  }

  static Future<List<RcPosition>> getRollCallPositions(int congress,
      String chamber, int sessionNumber, int rollCallNumber) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    final url =
        'congress/v1/$congress/$chamber/sessions/$sessionNumber/votes/$rollCallNumber.json';
    final headers = PropublicaApi().apiHeaders;
    final authority = PropublicaApi().authority;
    final response =
        await http.get(Uri.https(authority, url), headers: headers);

    if (response.statusCode == 200) {
      RollCall rollCall = rollCallFromJson(response.body);

      if (rollCall.status == 'OK') {
        List<RcPosition> rcPositions = rollCall.results.rcVotes.vote.positions;

        List<RcPosition> followingPositions = rcPositions
            .where((element) => userDatabase
                .get('subscriptionAlertsList')
                .contains(element.memberId.toLowerCase()))
            .toList();

        rcPositions.retainWhere((element) => !userDatabase
            .get('subscriptionAlertsList')
            .contains(element.memberId.toLowerCase()));

        return followingPositions + rcPositions;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load Roll Call Data');
    }
  }

  static Future<String> addHashTags(String sentence) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    List<String> hashtags = userDatabase.get('hashtags');
    debugPrint('^^^^^ ORIGINAL SENTENCE: $sentence');
    String newSentence = sentence;

    // List<String> allWordsToHash = wordsToHash + statesMap.values.toList();
    List<String> allWordsToHash = hashtags + statesMap.values.toList();

    for (var word in allWordsToHash) {
      RegExp match = RegExp('\\b$word\\b', caseSensitive: false);
      if (newSentence.contains(match)) {
        String newWord = '#${word.replaceAll(' ', '')}';
        String thisSentence = newSentence.replaceFirst(match, newWord);
        newSentence = thisSentence;
        debugPrint('^^^^^ REPLACED $word with $newWord');
      }
    }
    debugPrint('^^^^^ NEW SENTENCE WITH HASHTAGS: $newSentence');
    return newSentence;
  }

  static Future<void> showSingleTextInput(
      {@required BuildContext context,
      @required Box userDatabase,
      @required String titleText,
      @required bool darkTheme,
      @required List<bool> userLevels,
      String source = '[user_name, dev_page, default]'}) async {
    // bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];
    final formKey = GlobalKey<FormState>();
    String data;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    titleText,
                    style: GoogleFonts.bangers(fontSize: 25),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Form(
                      key: formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Enter text'
                                  : val.length < 5
                                      ? 'Must be more than 5 characters'
                                      : null,
                              decoration: InputDecoration(
                                  hintText: 'What shall we call you?',
                                  errorStyle: TextStyle(
                                      color: darkTheme
                                          ? altHighlightColor
                                          : null)),
                              onChanged: (val) => data = val,
                            ),
                          ),
                          IconButton(
                              iconSize: 18,
                              icon: const Icon(Icons.send),
                              onPressed: () async {
                                if (formKey.currentState.validate()) {
                                  Navigator.pop(context);
                                  logger.d(data);
                                  debugPrint('INPUT TEXT DATA: $data');

                                  if (source == 'user_name') {
                                    String dataReduced =
                                        data.replaceAll(' ', '');
                                    List<String> currentUserIdList = List.from(
                                        userDatabase.get('userIdList'));
                                    if (!currentUserIdList.any((element) =>
                                        element.startsWith(
                                            '$newUserIdPrefix$dataReduced'))) {
                                      currentUserIdList.add(
                                          '$newUserIdPrefix$dataReduced<|:|>${DateTime.now()}');
                                    } else if (currentUserIdList.any(
                                        (element) => element.startsWith(
                                            '$newUserIdPrefix$dataReduced'))) {
                                      int existingUserNameIndex =
                                          currentUserIdList.indexWhere(
                                              (element) => element.startsWith(
                                                  '$newUserIdPrefix$dataReduced'));

                                      String existingUserName =
                                          currentUserIdList
                                              .removeAt(existingUserNameIndex);

                                      currentUserIdList.add(existingUserName);
                                    }
                                    userDatabase.put(
                                        'userIdList', currentUserIdList);
                                  }
                                } else {
                                  logger.d('***** Data is invalid *****');
                                }
                              })
                        ],
                      ),
                    ),
                  )
                ]),
          );
        });
  }
}
