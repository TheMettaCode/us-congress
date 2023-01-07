import 'dart:async';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:congress_watcher/app_user/developer_page.dart';
import 'package:congress_watcher/app_user/settings.dart';
import 'package:congress_watcher/app_user/user_profile.dart';
import 'package:congress_watcher/constants/animated_widgets.dart';
import 'package:congress_watcher/constants/styles.dart';
import 'package:congress_watcher/constants/widgets.dart';
import 'package:congress_watcher/functions/functions.dart';
import 'package:congress_watcher/home_page.dart';
import 'package:congress_watcher/constants/themes.dart';
import 'package:congress_watcher/models/order_detail.dart';
import 'package:congress_watcher/services/congress_stock_watch/congress_stock_watch_api.dart';
import 'package:congress_watcher/services/ecwid/ecwid_store_model.dart';
import 'package:congress_watcher/services/emailjs/emailjs_api.dart';
import 'package:congress_watcher/services/github/usc_app_data_api.dart';
import 'package:congress_watcher/notifications_handler/notification_api.dart';
import 'package:congress_watcher/services/stripe/stripe_api.dart';
import 'package:congress_watcher/services/youtube/top_congressional_videos.dart';
import 'package:congress_watcher/congress/onboarding_page.dart';
import 'constants/constants.dart';
import 'functions/rapidapi_functions.dart';
import 'services/revenuecat/revenuecat_api.dart';

// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  // pragma('vm:entry-point');
  String taskId = task.taskId;
  bool isTimedOut = task.timeout;
  if (isTimedOut) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    debugPrint("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  // Do your work here...
  debugPrint('[BackgroundFetch] Headless event received.');
  debugPrint(
      '[BackgroundFetch] $appTitle BACKGROUND FETCH IS WORKING HERE! *****');

  /// To load the .env file contents into dotenv.
  /// NOTE: fileName defaults to .env and can be omitted in this case.
  /// Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: ".env");
  debugPrint('[BackgroundFetch] OPENING DATA BOX (Background Fetch) *****');
  await BoxInit.initializeBox();
  Box userDatabase = Hive.box(appDatabase);
  await userDatabase.put(
      'backgroundFetches', userDatabase.get('backgroundFetches') + 1);
  await Functions.processCredits(false, creditsToRemove: 15);
  await RapidApiFunctions.fetchNewsArticles();
  await RapidApiFunctions.getFloorActions(isHouseChamber: true);
  await RapidApiFunctions.getFloorActions(isHouseChamber: false);
  await Functions.fetchStatements();
  await Functions.fetchBills();
  await Functions.fetchVotes();
  await YouTubeVideosApi.getYoutubeVideos();
  await Functions.fetchRecentLobbyEvents();
  await CongressStockWatchApi.fetchHouseStockDisclosures();
  await CongressStockWatchApi.fetchSenateStockDisclosures();
  await EmailjsApi.sendCapitolBabbleSocialEmail();
  await GithubApi.getGithubNotifications();

  BackgroundFetch.finish(taskId);
  debugPrint(
      '[BackgroundFetch] $appTitle Background Fetch Complete and Closed *****');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BoxInit.initializeBox();

  // logger.d('***** Halting Background Fetch... *****');
  // await BackgroundFetch.stop();
  logger.d('***** Loading .env variables... *****');

  /// To load the .env file contents into dotenv.
  /// NOTE: fileName defaults to .env and can be omitted in this case.
  /// Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: ".env");
  logger.d('***** Enabling Mobile Ads... *****');
  await MobileAds.instance.initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();
  Box userDatabase = Hive.box(appDatabase);

  final String devCode = dotenv.env['dCode'];

  AndroidDeviceInfo deviceInfo;
  PackageInfo packageInfo;
  UserProfile thisUser;

  bool stripeTestMode = false;
  bool googleTestMode = false;
  bool amazonTestMode = false;
  bool testing = false;

  // ignore: unused_field
  int _status = 0;
  final List<DateTime> _events = [];
  bool showAlertOptions = false;

  /// COMMENT BOX DATA
  String userEmail = '';
  String userComment = '';
  bool isCommenting = false;
  bool commentSending = false;
  bool commentSent = false;

  bool onboarding = true;

  List<EcwidStoreItem> ecwidProductsList = [];
  List<Order> productOrdersList = [];

  int bannerImageIndex = 0;
  int commentBoxImageIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setInitialVariables();
    });
    super.initState();
    initBackgroundFetchPlatformState();
  }

  Future<void> setInitialVariables() async {
    await Functions.getPosition();

    await DeviceInfoPlugin()
        .androidInfo
        .then((info) => setState(() => deviceInfo = info));

    await PackageInfo.fromPlatform()
        .then((info) => setState(() => packageInfo = info));

    await AppUser.initialize().then((user) async {
      setState(() {
        thisUser = user;
      });

      /// INITIALIZE IN-APP PURCHASES
      user.revenueCatIapAvailable
          ? await RcPurchaseApi.revenuecatPlatformInit()
          : await StripeApi.stripePlatformInit();

      debugPrint(
          '[SET INITIAL VARIABLES (Main.dart)] THIS USER RETURNED ${userProfileToJson(user).toString()}');
    });

    logger.d(
        '[SET INITIAL VARIABLES (Main.dart)] Enabling Notifications... *****');
    await NotificationApi.init();

    /// LOAD GITHUB PROMOTIONAL MESSAGES
    await GithubApi.getGithubNotifications();

    /// ECWID STORE PRODUCTS LIST
    try {
      setState(() => ecwidProductsList =
          ecwidStoreFromJson(userDatabase.get('ecwidProducts')).items);
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING ECWID STORE ITEMS DATA FROM DBASE (MAIN.DART): $e ^^^^^');
    }

    /// PRODUCT ORDERS LIST
    try {
      setState(() => productOrdersList =
          orderDetailListFromJson(userDatabase.get('ecwidProductOrdersList'))
              .orders);
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (MAIN.DART): $e ^^^^^');
    }

    setState(() {
      stripeTestMode = userDatabase.get('stripeTestMode');
      googleTestMode = userDatabase.get('googleTestMode');
      amazonTestMode = userDatabase.get('amazonTestMode');
      testing = userDatabase.get('stripeTestMode') ||
          userDatabase.get('googleTestMode') ||
          userDatabase.get('amazonTestMode');
      onboarding = userDatabase.get('onboarding');
      bannerImageIndex = random.nextInt(4);
      commentBoxImageIndex = random.nextInt(4);
    });
  }

  Future<void> initBackgroundFetchPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            startOnBoot: true,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            forceAlarmManager: false,
            requiredNetworkType: NetworkType.ANY), (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback.
      logger.d("[BackgroundFetch] Event received $taskId");
      setState(() {
        _events.insert(0, DateTime.now());
      });
      logger.d("^^^^ Background Fetch Task ID: $taskId");
      if (taskId == "flutter_background_fetch") {
        logger.d("Background Fetch - app running");
      }
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      logger.d("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    logger.d('[BackgroundFetch] configure success: $status');
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable:
            Hive.box(appDatabase).listenable(keys: userDatabase.keys.toList()),
        builder: (context, box, widget) {
          stripeTestMode = userDatabase.get('stripeTestMode');
          googleTestMode = userDatabase.get('googleTestMode');
          amazonTestMode = userDatabase.get('amazonTestMode');
          testing = userDatabase.get('stripeTestMode') ||
              userDatabase.get('googleTestMode') ||
              userDatabase.get('amazonTestMode');

          try {
            thisUser = userProfileFromJson(userDatabase.get('userProfile'));
          } catch (e) {
            logger.w(
                '[MAIN.DART VALUE LISTENABLE BUILDER] ERROR RETRIEVING USER PROFILE FROM DBASE: $e ^^^^^');
          }

          try {
            productOrdersList = orderDetailListFromJson(
                    userDatabase.get('ecwidProductOrdersList'))
                .orders;
          } catch (e) {
            productOrdersList = [];
            logger.w(
                '[MAIN.DART VALUE LISTENABLE BUILDER] ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE: $e ^^^^^');
          }

          return userDatabase.get('onboarding')
              ? MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: appTitle,
                  theme: userDatabase.get('darkTheme')
                      ? darkThemeData
                      : userDatabase.get('grapeTheme')
                          ? grapeThemeData
                          : defaultThemeData,
                  home: const OnBoardingPage())
              : thisUser == null
                  ? MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: appTitle,
                      theme: userDatabase.get('darkTheme')
                          ? darkThemeData
                          : userDatabase.get('grapeTheme')
                              ? grapeThemeData
                              : defaultThemeData,
                      home: Scaffold(
                          body: AnimatedWidgets.circularProgressWatchtower(
                              context, userDatabase,
                              isFullScreen: true,
                              isHomePage: true,
                              backgroundImage:
                                  'assets/congress_pic_${Random().nextInt(5)}.png')))
                  : MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: appTitle,
                      theme: thisUser.darkTheme
                          ? darkThemeData
                          : thisUser.grapeTheme
                              ? grapeThemeData
                              : defaultThemeData,
                      home: Scaffold(
                          endDrawer: OrientationBuilder(
                              builder: (context, orientation) {
                            return SafeArea(
                              child: Drawer(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      orientation == Orientation.landscape
                                          ? const SizedBox.shrink()
                                          : Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              // height: 125,
                                              child: Stack(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                children: [
                                                  FadeIn(
                                                    child: Image.asset(
                                                      'assets/congress_pic_$bannerImageIndex.png',
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fit: BoxFit.cover,
                                                      colorBlendMode:
                                                          BlendMode.overlay,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: SizedBox(
                                                      height: 22,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          userDatabase.get(
                                                                      'interstitialAdIsNew') &&
                                                                  thisUser
                                                                      .developerStatus
                                                              ? Expanded(
                                                                  child: OutlinedButton.icon(
                                                                      icon: const Icon(Icons.ad_units, size: 10),
                                                                      label: Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(3),
                                                                        child: Text(
                                                                            ((1 - ((thisUser.temporaryCredits + thisUser.supportCredits) / adChanceToShowThreshold)) * 100) > 0
                                                                                ? '${((1 - ((userDatabase.get('credits') + userDatabase.get('permCredits')) / adChanceToShowThreshold)) * 100).toStringAsFixed(2)}%'
                                                                                : '0.00%',
                                                                            style:
                                                                                Styles.regularStyle.copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                                                                      ),
                                                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColorDark.withOpacity(0.85))),
                                                                      onPressed: () => Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const DeveloperPage(),
                                                                          ))),
                                                                )
                                                              : const SizedBox
                                                                  .shrink(),
                                                          userDatabase.get(
                                                                      'interstitialAdIsNew') &&
                                                                  thisUser
                                                                      .developerStatus
                                                              ? const SizedBox(
                                                                  width: 3)
                                                              : const SizedBox
                                                                  .shrink(),
                                                          Expanded(
                                                            // flex: 2,
                                                            child:
                                                                OutlinedButton
                                                                    .icon(
                                                              style: ButtonStyle(
                                                                  backgroundColor: MaterialStateProperty.all<
                                                                      Color>(Theme.of(
                                                                          context)
                                                                      .primaryColorDark
                                                                      .withOpacity(
                                                                          0.85))),
                                                              icon: const FaIcon(
                                                                  FontAwesomeIcons
                                                                      .coins,
                                                                  size: 10),
                                                              label: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(3),
                                                                child: Text(
                                                                    'Credits: ${userDatabase.get('credits') + userDatabase.get('permCredits') + userDatabase.get('purchCredits')}'
                                                                        .toUpperCase(),
                                                                    style: Styles
                                                                        .regularStyle
                                                                        .copyWith(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                              ),
                                                              onPressed: () => Functions
                                                                  .requestPurchase(
                                                                      context,
                                                                      null,
                                                                      whatToShow:
                                                                          'credits'),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      BounceInRight(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                          child: Card(
                                            elevation: 5,
                                            color: thisUser.darkTheme
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .background
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                            child: ListTile(
                                              enabled: true,
                                              enableFeedback: true,
                                              dense: true,
                                              title: FadeInRight(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                            thisUser
                                                                    .premiumStatus
                                                                ? Icons
                                                                    .workspace_premium
                                                                : thisUser
                                                                        .legacyStatus
                                                                    ? Icons
                                                                        .stars
                                                                    : Icons
                                                                        .free_breakfast,
                                                            size: 20,
                                                            color: thisUser
                                                                    .premiumStatus
                                                                ? altHighlightColor
                                                                : thisUser
                                                                        .legacyStatus
                                                                    ? altHighlightColor
                                                                    : darkThemeTextColor),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          thisUser.premiumStatus
                                                              ? 'Premium User'
                                                              : thisUser
                                                                      .legacyStatus
                                                                  ? 'Legacy User'
                                                                  : 'Free User',
                                                          style: Styles
                                                              .googleStyle
                                                              .copyWith(
                                                                  color:
                                                                      darkThemeTextColor,
                                                                  fontSize: 23),
                                                        ),
                                                        thisUser.appRated
                                                            ? Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .star_border_purple500_rounded,
                                                                    size: 15,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                  ),
                                                                  const Icon(
                                                                    Icons
                                                                        .star_border_purple500_rounded,
                                                                    size: 12,
                                                                    color:
                                                                        altHighlightColor,
                                                                  ),
                                                                ],
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        const Spacer(),
                                                        Text(
                                                            thisUser.userIdList
                                                                            .last
                                                                            .split('<|:|>')[
                                                                        1] ==
                                                                    dotenv.env[
                                                                        'dCode']
                                                                ? 'MettaCode Dev'
                                                                    .toUpperCase()
                                                                : thisUser
                                                                    .userIdList
                                                                    .last
                                                                    .split('<|:|>')[
                                                                        1]
                                                                    .toUpperCase(),
                                                            style: Styles
                                                                .regularStyle
                                                                .copyWith(
                                                                    color:
                                                                        darkThemeTextColor,
                                                                    fontSize:
                                                                        12)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () => drawerTextInput(
                                                  context,
                                                  'Update your user name',
                                                  userDatabase
                                                      .get('devLegacyCode'),
                                                  userDatabase
                                                      .get('devPremiumCode'),
                                                  userDatabase
                                                      .get('freeTrialCode')),
                                            ),
                                          ),
                                        ),
                                      ),
                                      !thisUser.premiumStatus
                                          ? BounceInRight(
                                              duration: const Duration(
                                                  milliseconds: 800),
                                              child: SharedWidgets
                                                  .premiumUpgradeContainer(
                                                      context,
                                                      null,
                                                      thisUser.freeTrialUsed,
                                                      userDatabase),
                                            )
                                          : const SizedBox.shrink(),
                                      Column(
                                        children: [
                                          isCommenting
                                              ? const SizedBox.shrink()
                                              : BounceInRight(
                                                  duration: const Duration(
                                                      milliseconds: 400),
                                                  child: ListTile(
                                                    enabled: true,
                                                    dense: true,
                                                    leading: const FaIcon(
                                                        FontAwesomeIcons.bug,
                                                        size: 12,
                                                        color:
                                                            darkThemeTextColor),
                                                    title: Text(
                                                        commentSent
                                                            ? 'Your message was sent'
                                                            : 'Report A Bug',
                                                        style: Styles
                                                            .regularStyle
                                                            .copyWith(
                                                                color:
                                                                    darkThemeTextColor)),
                                                    subtitle: Text(
                                                        commentSent
                                                            ? 'Tap to send another'
                                                            : 'Or message the development team',
                                                        style: Styles
                                                            .regularStyle
                                                            .copyWith(
                                                                color:
                                                                    darkThemeTextColor,
                                                                fontSize: 12)),
                                                    trailing: isCommenting
                                                        ? const Icon(
                                                            Icons.close,
                                                            color:
                                                                darkThemeTextColor)
                                                        : const SizedBox
                                                            .shrink(),
                                                    onTap: () {
                                                      setState(() {
                                                        isCommenting =
                                                            !isCommenting;
                                                        commentSent = false;
                                                      });
                                                    },
                                                  ),
                                                ),
                                          isCommenting
                                              ? commentBox()
                                              : const SizedBox.shrink()
                                        ],
                                      ),
                                      Expanded(
                                        child: ListView(
                                          shrinkWrap: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          children: <Widget>[
                                            BounceInRight(
                                              duration: const Duration(
                                                  milliseconds: 800),
                                              child: ListTile(
                                                enabled: true,
                                                enableFeedback: true,
                                                leading: const Icon(
                                                    FontAwesomeIcons.share,
                                                    size: 15,
                                                    color: darkThemeTextColor),
                                                title: Text('Share The App',
                                                    style: Styles.regularStyle
                                                        .copyWith(
                                                            color:
                                                                darkThemeTextColor)),
                                                subtitle: Text(
                                                    'Receive credits for sharing with others',
                                                    style: Styles.regularStyle
                                                        .copyWith(
                                                            color:
                                                                darkThemeTextColor,
                                                            fontSize: 12)),
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  await Messages.shareContent(
                                                      true);
                                                },
                                              ),
                                            ),
                                            thisUser.appRated // || !installerStoreIsValid
                                                ? const SizedBox.shrink()
                                                : BounceInRight(
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    child: ListTile(
                                                      enabled: true,
                                                      enableFeedback: true,
                                                      leading: const Icon(
                                                          FontAwesomeIcons.star,
                                                          size: 15,
                                                          color:
                                                              darkThemeTextColor),
                                                      title: Text(
                                                          'Rate The App',
                                                          style: Styles
                                                              .regularStyle
                                                              .copyWith(
                                                                  color:
                                                                      darkThemeTextColor)),
                                                      subtitle: Text(
                                                          'Receive credits for rating $appTitle App',
                                                          style: Styles
                                                              .regularStyle
                                                              .copyWith(
                                                                  color:
                                                                      darkThemeTextColor,
                                                                  fontSize:
                                                                      12)),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        // await launchUrl(Uri.parse(installerStoreLink),
                                                        //         mode: LaunchMode.platformDefault)
                                                        await Functions.linkLaunch(
                                                                null,
                                                                googleAppLink,
                                                                fullScreen:
                                                                    true,
                                                                appBarTitle:
                                                                    'Thank you for your rating!',
                                                                interstitialAd:
                                                                    null)
                                                            .then((_) async {
                                                          userDatabase.put(
                                                              'appRated', true);
                                                          await Functions
                                                              .processCredits(
                                                                  true,
                                                                  isPermanent:
                                                                      true,
                                                                  creditsToAdd:
                                                                      100);
                                                        });
                                                      },
                                                    ),
                                                  ),
                                            ecwidProductsList.isEmpty
                                                ? const SizedBox.shrink()
                                                : BounceInRight(
                                                    duration: const Duration(
                                                        milliseconds: 600),
                                                    child: ListTile(
                                                      enabled: true,
                                                      enableFeedback: true,
                                                      leading: const Icon(
                                                          FontAwesomeIcons
                                                              .store,
                                                          size: 15,
                                                          color:
                                                              darkThemeTextColor),
                                                      title: Text(
                                                          'Shop Merchandise',
                                                          style: Styles
                                                              .regularStyle
                                                              .copyWith(
                                                                  color:
                                                                      darkThemeTextColor)),
                                                      subtitle: productOrdersList
                                                              .isEmpty
                                                          ? const SizedBox
                                                              .shrink()
                                                          : Text(
                                                              'Long press to view past orders',
                                                              style: Styles
                                                                  .regularStyle
                                                                  .copyWith(
                                                                      color:
                                                                          darkThemeTextColor,
                                                                      fontSize:
                                                                          12)),
                                                      onTap: () async {
                                                        Navigator.pop(context);

                                                        showModalBottomSheet(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            isScrollControlled:
                                                                false,
                                                            enableDrag: true,
                                                            context: context,
                                                            builder: (context) {
                                                              return SharedWidgets
                                                                  .ecwidProductsListing(
                                                                      context,
                                                                      null,
                                                                      ecwidProductsList,
                                                                      userDatabase,
                                                                      productOrdersList);
                                                            });
                                                      },
                                                      onLongPress:
                                                          productOrdersList
                                                                  .isEmpty
                                                              ? null
                                                              : () async {
                                                                  Navigator.pop(
                                                                      context);

                                                                  showModalBottomSheet(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      isScrollControlled:
                                                                          false,
                                                                      enableDrag:
                                                                          true,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return SharedWidgets
                                                                            .pastProductOrders(
                                                                          context,
                                                                          userDatabase,
                                                                          // productOrdersList,
                                                                        );
                                                                      });
                                                                },
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      BounceInRight(
                                        duration:
                                            const Duration(milliseconds: 1200),
                                        child: ListTile(
                                          enabled: true,
                                          enableFeedback: true,
                                          leading: const FaIcon(
                                              FontAwesomeIcons.gear,
                                              size: 13,
                                              color: darkThemeTextColor),
                                          title: Text('Settings',
                                              style: Styles.regularStyle
                                                  .copyWith(
                                                      color:
                                                          darkThemeTextColor)),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Settings(
                                                          thisUser: thisUser),
                                                ));
                                          },
                                        ),
                                      ),
                                      thisUser.developerStatus
                                          ? FadeInRight(
                                              duration: const Duration(
                                                  milliseconds: 2000),
                                              child: ListTile(
                                                enabled: true,
                                                enableFeedback: true,
                                                leading: const Icon(
                                                    Icons.developer_board,
                                                    size: 15,
                                                    color: darkThemeTextColor),
                                                title: Text('Developer Page',
                                                    style: Styles.regularStyle
                                                        .copyWith(
                                                            color:
                                                                darkThemeTextColor)),
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const DeveloperPage(),
                                                      ));
                                                },
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                      FadeInRight(
                                          child:
                                              SharedWidgets.createdByContainer(
                                                  context, userDatabase)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          body: const HomePage(title: appTitle)),
                    );
        });
  }

  Widget commentBox() {
    return BounceInRight(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              image: DecorationImage(
                  opacity: 0.15,
                  image: AssetImage(
                      'assets/congress_pic_$commentBoxImageIndex.png'),
                  fit: BoxFit.cover,
                  colorFilter:
                      const ColorFilter.mode(Colors.grey, BlendMode.color)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                        errorStyle: const TextStyle(color: Colors.white),
                        hintText: 'Your email',
                        hintStyle: Styles.regularStyle
                            .copyWith(color: darkThemeTextColor, fontSize: 15),
                        counterStyle:
                            const TextStyle(color: darkThemeTextColor)),
                    style: const TextStyle(color: darkThemeTextColor),
                    validator: (val) =>
                        // _val.isEmpty ||
                        //         !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        //             .hasMatch(_val)
                        //     ? "Enter a valid email"
                        //     : null,
                        EmailValidator.validate(val)
                            ? null
                            : "Please enter a valid email",
                    onChanged: (email) {
                      setState(() => userEmail = email);
                      logger.d(userEmail);
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: thisUser.premiumStatus
                        ? 400
                        : thisUser.legacyStatus
                            ? 300
                            : 200,
                    decoration: InputDecoration(
                        errorStyle: const TextStyle(color: Colors.white),
                        hintText: 'Your comment',
                        hintStyle: Styles.regularStyle
                            .copyWith(color: darkThemeTextColor, fontSize: 15),
                        counterStyle:
                            const TextStyle(color: darkThemeTextColor)),
                    style: const TextStyle(color: darkThemeTextColor),
                    validator: (val) => val.isEmpty || val.length < 10
                        ? 'Not enough information'
                        : null,
                    onChanged: (comment) {
                      setState(() => userComment = comment);
                      logger.d(userComment);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Container(
                      alignment: Alignment.centerRight,
                      height: 22,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              style: ButtonStyle(
                                  foregroundColor: darkThemeTextMSPColor,
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(5))),
                              onPressed: () => setState(() {
                                    isCommenting = false;
                                    userComment = '';
                                  }),
                              child: const Text('Cancel')),
                          const SizedBox(width: 5),
                          ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: thisUser.darkTheme
                                      ? MaterialStateProperty.all<Color>(
                                          Colors.black)
                                      : MaterialStateProperty.all<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .primary)),
                              icon: commentSending
                                  ? AnimatedWidgets.circularProgressWatchtower(
                                      context, userDatabase,
                                      widthAndHeight: 11,
                                      strokeWidth: 1,
                                      isFullScreen: false)
                                  : const Icon(Icons.send,
                                      size: 10, color: darkThemeTextColor),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() => commentSending = true);

                                  /// UPDATE DBASE EMAIL LIST WITH NEW EMAIL ADDRESS
                                  List<String> userEmailList = List.from(
                                      userDatabase.get('userEmailList'));
                                  if (!userEmailList.any((element) =>
                                      element.toLowerCase() ==
                                      userEmail.toLowerCase())) {
                                    userEmailList.add(
                                        '$userEmail<|:|>${DateTime.now()}');
                                    userDatabase.put(
                                        'userEmailList', userEmailList);
                                    await AppUser.buildUserProfile().then(
                                        (value) =>
                                            setState(() => thisUser = value));
                                    !thisUser.revenueCatIapAvailable
                                        ? StripeApi.updateStripeCustomer(
                                            forceUpdate: true)
                                        : null;
                                  }

                                  /// EMAIL COMMENT TO DEVELOPER EMAIL ADDRESS
                                  try {
                                    await EmailjsApi.sendCommentEmail(
                                      'A comment from user ${thisUser.lastUserId}',
                                      'USER COMMENT: $userComment',
                                      'mettacode@gmail.com',
                                      fromEmail: userEmail,
                                      additionalData1:
                                          'USER STATUS => ${thisUser.premiumStatus ? 'Premium' : thisUser.legacyStatus ? 'Legacy' : 'Free'} :: USER IDs => ${thisUser.userIdList.map((e) => '${e.split('<|:|>')[0]} ${e.split('<|:|>')[1]} created ${dateWithTimeFormatter.format(DateTime.parse(e.split('<|:|>')[2]).toUtc())} UTC')} :: DLC => ${userDatabase.get('devLegacyCode')} - DPC => ${userDatabase.get('devPremiumCode')} - FTC => ${userDatabase.get('freeTrialCode')}',
                                      additionalData2:
                                          'USER EMAIL(S) => ${List.from(userDatabase.get('userEmailList')).map((e) => '${e.split('<|:|>')[0]} added ${dateWithTimeFormatter.format(DateTime.parse(e.split('<|:|>')[1]).toUtc())} UTC')}',
                                      additionalData3:
                                          // 'PACKAGE INFO => ${thisUser.packageInfo.toJson().toString()}',
                                          'PACKAGE INFO => ${thisUser.packageInfo.toJson().toString()}',
                                      additionalData4:
                                          'DEVICE INFO => ${thisUser.deviceInfo.toJson().toString()} :: APP OPENS => ${thisUser.appOpens}',
                                      additionalData5:
                                          'TOTAL CREDITS => ${thisUser.purchasedCredits} Purch, ${thisUser.supportCredits} Support & ${thisUser.temporaryCredits} Temp :: LOCATION => ${thisUser.address.toJson().toString()}',
                                    );
                                  } catch (e) {
                                    logger.w(
                                        'EMAIL ERROR: MESSAGE NOT SENT - $e');
                                  }

                                  setState(() {
                                    isCommenting = false;
                                    userComment = '';
                                  });

                                  setState(() {
                                    commentSending = false;
                                    commentSent = true;
                                  });
                                }
                              },
                              label: const Text('Send',
                                  style: TextStyle(color: darkThemeTextColor))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> drawerTextInput(BuildContext context, String titleText,
      String devLegacyCode, String devPremiumCode, String freeTrialCode) async {
    final formKey = GlobalKey<FormState>();
    final String devCode = dotenv.env['dCode'];
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
                                      : val.length < 5 || val.length > 13
                                          ? 'User must be 5 to 13 characters'
                                          : null,
                                  decoration: InputDecoration(
                                      hintText: !thisUser.premiumStatus &&
                                              !thisUser.legacyStatus
                                          ? 'Free users cannot update user name'
                                          : 'What shall we call you?',
                                      errorStyle: TextStyle(
                                          color: thisUser.darkTheme
                                              ? altHighlightColor
                                              : null)),
                                  onChanged: (val) => setState(
                                      () => data = val.replaceAll(' ', '')),
                                ),
                              ),
                              IconButton(
                                  iconSize: 18,
                                  icon: Icon(!thisUser.premiumStatus &&
                                          !thisUser.legacyStatus &&
                                          data != devCode &&
                                          data != devLegacyCode &&
                                          data != devPremiumCode &&
                                          data != freeTrialCode
                                      ? Icons.workspace_premium
                                      : Icons.send),
                                  onPressed: !thisUser.premiumStatus &&
                                          !thisUser.legacyStatus &&
                                          data != devCode &&
                                          data != devLegacyCode &&
                                          data != devPremiumCode &&
                                          data != freeTrialCode
                                      ? () {
                                          Navigator.pop(context);
                                          Functions.requestPurchase(
                                              context, null,
                                              whatToShow: 'upgrades');
                                        }
                                      : () async {
                                          if (formKey.currentState.validate()) {
                                            Navigator.pop(context);

                                            if (data == devLegacyCode) {
                                              List<String> userIdList =
                                                  // List.from(userDatabase.get('userIdList'));
                                                  thisUser.userIdList;
                                              userIdList.insert(
                                                  0, oldUserIDTag);
                                              userDatabase.put('devLegacyCode',
                                                  'DLC${random.nextInt(900000) + 100000}');
                                              userDatabase.put(
                                                  'userIdList', userIdList);
                                              userDatabase.put(
                                                  'devUpgraded', true);
                                            } else if (data == devPremiumCode) {
                                              userDatabase.put(
                                                  'userIsPremium', true);
                                              userDatabase.put(
                                                  'devUpgraded', true);
                                              userDatabase.put('devPremiumCode',
                                                  'DPC${random.nextInt(900000) + 100000}');
                                            } else if (data == freeTrialCode) {
                                              userDatabase.put(
                                                  'userIsPremium', true);
                                              userDatabase.put(
                                                  'freeTrialUsed', true);
                                              userDatabase.put(
                                                  'freeTrialStartDate',
                                                  '${DateTime.now()}');
                                              userDatabase.put('freeTrialCode',
                                                  'FTC${random.nextInt(900000) + 100000}');
                                            } else {
                                              List<String> currentUserIdList =
                                                  thisUser.userIdList;
                                              // List.from(userDatabase.get('userIdList'));
                                              if (!currentUserIdList.any(
                                                  (element) => element.startsWith(
                                                      '$newUserIdPrefix$data'))) {
                                                currentUserIdList.add(
                                                    '$newUserIdPrefix$data<|:|>${DateTime.now()}');
                                              } else if (currentUserIdList.any(
                                                  (element) => element.startsWith(
                                                      '$newUserIdPrefix$data'))) {
                                                int existingUserNameIndex =
                                                    currentUserIdList
                                                        .indexWhere((element) =>
                                                            element.startsWith(
                                                                '$newUserIdPrefix$data'));

                                                String existingUserName =
                                                    currentUserIdList.removeAt(
                                                        existingUserNameIndex);

                                                currentUserIdList
                                                    .add(existingUserName);
                                              }
                                              userDatabase.put('userIdList',
                                                  currentUserIdList);
                                              !thisUser.revenueCatIapAvailable
                                                  ? StripeApi
                                                      .updateStripeCustomer(
                                                          forceUpdate: true)
                                                  : null;
                                            }

                                            await AppUser.buildUserProfile()
                                                .then((value) => setState(
                                                    () => thisUser = value));
                                          } else {
                                            logger.d(
                                                '***** Data is invalid *****');
                                          }
                                        })
                            ],
                          ),
                        ),
                      )
                    ]),
              );
            })
        .then((_) async =>
            await Functions.processCredits(true, isPermanent: false));
  }
}
