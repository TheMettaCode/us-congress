import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us_congress_vote_tracker/congress/developer_page.dart';
import 'package:us_congress_vote_tracker/congress/settings.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/widgets.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/home_page.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/models/order_detail.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/congress_stock_watch_api.dart';
import 'package:us_congress_vote_tracker/services/ecwid/ecwid_store_model.dart';
import 'package:us_congress_vote_tracker/services/emailjs/emailjs_api.dart';
import 'package:us_congress_vote_tracker/services/github/usc_app_data_api.dart';
import 'package:us_congress_vote_tracker/notifications_handler/notification_api.dart';
import 'package:us_congress_vote_tracker/services/revenuecat/rc_purchase_api.dart';
import 'package:us_congress_vote_tracker/services/youtube/top_congressional_videos.dart';
import 'package:us_congress_vote_tracker/services/youtube/youtube_player.dart';
import 'package:us_congress_vote_tracker/congress/onboarding_page.dart';
import 'constants/constants.dart';
import 'functions/rapidapi_functions.dart';

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
  debugPrint('***** US CONGRESS BACKGROUND FETCH IS WORKING HERE! *****');

  /// To load the .env file contents into dotenv.
  /// NOTE: fileName defaults to .env and can be omitted in this case.
  /// Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: ".env");
  debugPrint('***** OPENING DATA BOX (Background Fetch) *****');
  await Functions.initializeBox();
  Box userDatabase = Hive.box(appDatabase);
  await userDatabase.put('backgroundFetches', userDatabase.get('backgroundFetches') + 1);
  await Functions.processCredits(false, creditsToRemove: 15);
  await RapidApiFunctions.fetchNewsArticles();
  await RapidApiFunctions.getFloorActions(isHouseChamber: true);
  await RapidApiFunctions.getFloorActions(isHouseChamber: false);
  await Functions.fetchStatements();
  // await Functions.houseFloor();
  // await Functions.senateFloor();
  await Functions.fetchBills();
  await Functions.fetchVotes();
  await Youtube.getYouTubePlaylistItems(); // TODO: Remove when new video api is working
  await YouTubeVideosApi.getYoutubeVideoIds();
  await Functions.fetchRecentLobbyEvents();
  await CongressStockWatchApi.fetchHouseStockDisclosures();
  await CongressStockWatchApi.fetchSenateStockDisclosures();
  await EmailjsApi.sendCapitolBabbleSocialEmail();
  // await Messages.sendNotification(source: 'promo');
  await GithubApi.getPromoMessages();

  BackgroundFetch.finish(taskId);
  debugPrint('***** US Congress Background Fetch Complete and Closed *****');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Functions.initializeBox();

  // logger.d('***** Halting Background Fetch... *****');
  // await BackgroundFetch.stop();
  logger.d('***** Loading .env variables... *****');

  /// To load the .env file contents into dotenv.
  /// NOTE: fileName defaults to .env and can be omitted in this case.
  /// Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load(fileName: ".env");
  logger.d('***** Enabling Mobile Ads... *****');
  await MobileAds.instance.initialize();
  logger.d('***** Enabling Notifications... *****');
  await NotificationApi.init();
  await RcPurchaseApi.init();

  runApp(const MyApp());

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
  List<bool> userLevels = [false, false, false];
  bool userIsPremium = false;
  bool userIsLegacy = false;
  bool userIsDev = false;
  bool freeTrialUsed = false;
  bool devUpgraded = false;
  bool appRated = false;

  // ignore: unused_field
  // int _status = 0;
  final List<DateTime> _events = [];

  bool showAlertOptions = false;

  String userEmail = '';
  String userComment = '';
  bool isCommenting = false;
  bool commentSending = false;
  bool commentSent = false;

  bool darkTheme = false;
  bool onboarding = true;
  List<String> userIdList = [];
  int credits = 0;
  int permCredits = 0;
  List<EcwidStoreItem> ecwidProductsList = [];
  List<Order> productOrdersList = [];

  // List<GithubNotifications> githubNotificationsList = [];
  // GithubNotifications thisGithubNotification;

  int appOpens = 0;
  int bannerImageIndex = 0;
  int commentBoxImageIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setInitialVariables();
      await Functions.getPosition();
      await Functions.getDeviceInfo();
      await Functions.getPackageInfo();
    });
    super.initState();
    initBackgroundFetchPlatformState();
  }

  Future<void> setInitialVariables() async {
    await Functions.getUserLevels().then((levels) => setState(() {
          userLevels = levels;
          userIsDev = levels[0];
          userIsPremium = levels[1];
          userIsLegacy = levels[2];
        }));

    /// LOAD GITHUB PROMOTIONAL MESSAGES
    await GithubApi.getPromoMessages();

    /// ECWID STORE PRODUCTS LIST
    try {
      setState(
          () => ecwidProductsList = ecwidStoreFromJson(userDatabase.get('ecwidProducts')).items);
    } catch (e) {
      logger.w('^^^^^ ERROR RETRIEVING ECWID STORE ITEMS DATA FROM DBASE (MAIN.DART): $e ^^^^^');
    }

    /// PRODUCT ORDERS LIST
    try {
      setState(() => productOrdersList =
          orderDetailListFromJson(userDatabase.get('ecwidProductOrdersList')).orders);
    } catch (e) {
      logger.w('^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (MAIN.DART): $e ^^^^^');
    }

    setState(() {
      darkTheme = userDatabase.get('darkTheme');
      onboarding = userDatabase.get('onboarding');
      userIdList = List.from(userDatabase.get('userIdList'));
      freeTrialUsed = userDatabase.get('freeTrialUsed');
      devUpgraded = userDatabase.get('devUpgraded');
      credits = userDatabase.get('credits');
      permCredits = userDatabase.get('permCredits');
      appOpens = userDatabase.get('appOpens');
      appRated = userDatabase.get('appRated');
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
    // setState(() {
    //   _status = status;
    // });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase).listenable(keys: userDatabase.keys.toList()),
        builder: (context, box, widget) {
          credits = userDatabase.get('credits');
          permCredits = userDatabase.get('permCredits');
          try {
            productOrdersList =
                orderDetailListFromJson(userDatabase.get('ecwidProductOrdersList')).orders;
          } catch (e) {
            productOrdersList = [];
            logger.w(
                '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
          }
          appRated = userDatabase.get('appRated');
          darkTheme = userDatabase.get('darkTheme');
          freeTrialUsed = userDatabase.get('freeTrialUsed');
          userIdList = List.from(userDatabase.get('userIdList'));
          userIsPremium = userDatabase.get('userIsPremium');
          userIsLegacy = !userDatabase.get('userIsPremium') &&
                  List.from(userDatabase.get('userIdList'))
                      .any((element) => element.toString().startsWith(oldUserIdPrefix))
              ? true
              : false;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "US Congress",
            theme: userDatabase.get('darkTheme') ? darkThemeData : defaultThemeData,
            home: userDatabase.get('onboarding') == true
                ? const OnBoardingPage()
                : Scaffold(
                    endDrawer: OrientationBuilder(builder: (context, orientation) {
                      return SafeArea(
                        child: Drawer(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorDark,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                orientation == Orientation.landscape
                                    ? const SizedBox.shrink()
                                    : Container(
                                        color: Theme.of(context).colorScheme.primary,
                                        // height: 125,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            FadeIn(
                                              child: Image.asset(
                                                'assets/congress_pic_$bannerImageIndex.png',
                                                color: Theme.of(context).primaryColor,
                                                fit: BoxFit.cover,
                                                colorBlendMode: BlendMode.overlay,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: SizedBox(
                                                height: 22,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    userDatabase.get('interstitialAdIsNew') &&
                                                            userIsDev
                                                        ? Expanded(
                                                            child: OutlinedButton.icon(
                                                                icon: const Icon(Icons.ad_units,
                                                                    size: 10),
                                                                label: Padding(
                                                                  padding: const EdgeInsets.all(3),
                                                                  child: Text(
                                                                      ((1 -
                                                                                      ((userDatabase.get(
                                                                                                  'credits') +
                                                                                              userDatabase.get(
                                                                                                  'permCredits')) /
                                                                                          adChanceToShowThreshold)) *
                                                                                  100) >
                                                                              0
                                                                          ? '${((1 - ((userDatabase.get('credits') + userDatabase.get('permCredits')) / adChanceToShowThreshold)) * 100).toStringAsFixed(2)}%'
                                                                          : '0.00%',
                                                                      style: Styles.regularStyle
                                                                          .copyWith(
                                                                              fontSize: 11,
                                                                              fontWeight:
                                                                                  FontWeight.bold)),
                                                                ),
                                                                style: ButtonStyle(
                                                                    backgroundColor:
                                                                        MaterialStateProperty.all<
                                                                            Color>(Theme.of(
                                                                                context)
                                                                            .colorScheme
                                                                            .background
                                                                            .withOpacity(0.85))),
                                                                onPressed: () => Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          const DeveloperPage(),
                                                                    ))),
                                                          )
                                                        : const SizedBox.shrink(),
                                                    userDatabase.get('interstitialAdIsNew') &&
                                                            userIsDev
                                                        ? const SizedBox(width: 3)
                                                        : const SizedBox.shrink(),
                                                    Expanded(
                                                      // flex: 2,
                                                      child: OutlinedButton.icon(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty.all<Color>(
                                                                    Theme.of(context)
                                                                        .colorScheme
                                                                        .background
                                                                        .withOpacity(0.85))),
                                                        icon: const FaIcon(FontAwesomeIcons.coins,
                                                            size: 10),
                                                        label: Padding(
                                                          padding: const EdgeInsets.all(3),
                                                          child: Text(
                                                              'Credits: ${userDatabase.get('credits') + userDatabase.get('permCredits') + userDatabase.get('purchCredits')}'
                                                                  .toUpperCase(),
                                                              style: Styles.regularStyle.copyWith(
                                                                  fontSize: 11,
                                                                  fontWeight: FontWeight.bold)),
                                                        ),
                                                        onPressed: () =>
                                                            Functions.requestInAppPurchase(
                                                                context, null, userIsPremium,
                                                                whatToShow: 'credits'),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   child: SizedBox(
                                                    //     height: 22,
                                                    //     child: OutlinedButton(
                                                    //       style: ButtonStyle(
                                                    //           backgroundColor: MaterialStateProperty
                                                    //               .all<Color>(darkTheme
                                                    //                   ? Theme.of(
                                                    //                           context)
                                                    //                       .colorScheme
                                                    //                       .background
                                                    //                   : null)),
                                                    //       child: Padding(
                                                    //         padding:
                                                    //             const EdgeInsets
                                                    //                 .all(3),
                                                    //         child: Row(
                                                    //           mainAxisAlignment:
                                                    //               MainAxisAlignment
                                                    //                   .center,
                                                    //           children: [
                                                    //             Text(
                                                    //                 userIsPremium
                                                    //                     ? 'Premium User'
                                                    //                         .toUpperCase()
                                                    //                     : userIsLegacy
                                                    //                         ? 'Legacy User'
                                                    //                             .toUpperCase()
                                                    //                         : 'Free User'
                                                    //                             .toUpperCase(),
                                                    //                 style: Styles
                                                    //                     .regularStyle
                                                    //                     .copyWith(
                                                    //                         fontSize:
                                                    //                             11,
                                                    //                         fontWeight:
                                                    //                             FontWeight.bold)),
                                                    //             SizedBox(
                                                    //                 width: 3),
                                                    //             userIsPremium
                                                    //                 ? AnimatedWidgets.jumpingPremium(
                                                    //                     context,
                                                    //                     userIsPremium,
                                                    //                     false,
                                                    //                     animate:
                                                    //                         true,
                                                    //                     infinite:
                                                    //                         true,
                                                    //                     size: 10,
                                                    //                     color: darkTheme
                                                    //                         ? altHighlightColor
                                                    //                         : Theme.of(context)
                                                    //                             .colorScheme
                                                    //                             .primary)
                                                    //                 : userIsLegacy
                                                    //                     ? Icon(
                                                    //                         Icons
                                                    //                             .stars,
                                                    //                         size:
                                                    //                             10)
                                                    //                     : Icon(
                                                    //                         Icons
                                                    //                             .free_breakfast,
                                                    //                         size:
                                                    //                             10),
                                                    //             SizedBox(
                                                    //                 width: 3),
                                                    //             Text(
                                                    //                 '${List.from(userDatabase.get('userIdList')).last.contains(dotenv.env['dCode']) ? 'MettaCode Dev'.toUpperCase() : List.from(userDatabase.get('userIdList')).last.toString().split('<|:|>')[1].toUpperCase()} ',
                                                    //                 style: Styles
                                                    //                     .regularStyle
                                                    //                     .copyWith(
                                                    //                         fontSize:
                                                    //                             11,
                                                    //                         fontWeight:
                                                    //                             FontWeight.bold)),
                                                    //           ],
                                                    //         ),
                                                    //       ),
                                                    //       onPressed: !userIsPremium &&
                                                    //               !userIsLegacy
                                                    //           ? null
                                                    //           : () => Functions.showSingleTextInput(
                                                    //               context:
                                                    //                   context,
                                                    //               userDatabase:
                                                    //                   userDatabase,
                                                    //               titleText:
                                                    //                   'Update User Name',
                                                    //               darkTheme:
                                                    //                   darkTheme,
                                                    //               userLevels:
                                                    //                   userLevels,
                                                    //               source:
                                                    //                   'user_name'),
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                BounceInRight(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                    child: Card(
                                      elevation: 5,
                                      color: darkTheme
                                          ? Theme.of(context).colorScheme.background
                                          : Theme.of(context).colorScheme.primary,
                                      child: ListTile(
                                        enabled: true,
                                        enableFeedback: true,
                                        dense: true,
                                        title: FadeInRight(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                      userIsPremium
                                                          ? Icons.workspace_premium
                                                          : userIsLegacy
                                                              ? Icons.stars
                                                              : Icons.free_breakfast,
                                                      size: 20,
                                                      color: userIsPremium
                                                          ? altHighlightColor
                                                          : userIsLegacy
                                                              ? alertIndicatorColorBrightGreen
                                                              : darkThemeTextColor),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    userIsPremium
                                                        ? 'Premium User'
                                                        : userIsLegacy
                                                            ? 'Legacy User'
                                                            : 'Free User',
                                                    style: Styles.googleStyle.copyWith(
                                                        color: darkThemeTextColor, fontSize: 23),
                                                  ),
                                                  appRated
                                                      ? Stack(
                                                          alignment: Alignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.star_border_purple500_rounded,
                                                              size: 15,
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                            const Icon(
                                                              Icons.star_border_purple500_rounded,
                                                              size: 12,
                                                              color: altHighlightColor,
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox.shrink(),
                                                  const Spacer(),
                                                  Text(
                                                      userIdList.last.split('<|:|>')[1] ==
                                                              dotenv.env['dCode']
                                                          ? 'MettaCode Dev'.toUpperCase()
                                                          : userIdList.last
                                                              .split('<|:|>')[1]
                                                              .toUpperCase(),
                                                      style: Styles.regularStyle.copyWith(
                                                          color: darkThemeTextColor, fontSize: 12)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () => drawerTextInput(
                                            context,
                                            'Update your user name',
                                            userDatabase.get('devLegacyCode'),
                                            userDatabase.get('devPremiumCode'),
                                            userDatabase.get('freeTrialCode')),
                                      ),
                                    ),
                                  ),
                                ),
                                !userIsPremium
                                    ? BounceInRight(
                                        duration: const Duration(milliseconds: 800),
                                        child: SharedWidgets.premiumUpgradeContainer(
                                            context,
                                            null,
                                            userIsPremium,
                                            userIsLegacy,
                                            devUpgraded,
                                            freeTrialUsed,
                                            userDatabase),
                                      )
                                    : const SizedBox.shrink(),
                                Column(
                                  children: [
                                    isCommenting
                                        ? const SizedBox.shrink()
                                        : BounceInRight(
                                            duration: const Duration(milliseconds: 400),
                                            child: ListTile(
                                              enabled: true,
                                              dense: true,
                                              leading: const FaIcon(FontAwesomeIcons.bug,
                                                  size: 12, color: darkThemeTextColor),
                                              title: Text(
                                                  commentSent
                                                      ? 'Your message was sent'
                                                      : 'Report A Bug',
                                                  style: Styles.regularStyle
                                                      .copyWith(color: darkThemeTextColor)),
                                              subtitle: Text(
                                                  commentSent
                                                      ? 'Tap to send another'
                                                      : 'Or message the development team',
                                                  style: Styles.regularStyle.copyWith(
                                                      color: darkThemeTextColor, fontSize: 12)),
                                              trailing: isCommenting
                                                  ? const Icon(Icons.close,
                                                      color: darkThemeTextColor)
                                                  : const SizedBox.shrink(),
                                              onTap: () {
                                                setState(() {
                                                  isCommenting = !isCommenting;
                                                  commentSent = false;
                                                });
                                              },
                                            ),
                                          ),
                                    isCommenting ? commentBox() : const SizedBox.shrink()
                                  ],
                                ),
                                Expanded(
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    children: <Widget>[
                                      BounceInRight(
                                        duration: const Duration(milliseconds: 800),
                                        child: ListTile(
                                          enabled: true,
                                          enableFeedback: true,
                                          leading: const Icon(FontAwesomeIcons.share,
                                              size: 15, color: darkThemeTextColor),
                                          title: Text('Share The App',
                                              style: Styles.regularStyle
                                                  .copyWith(color: darkThemeTextColor)),
                                          subtitle: Text('Receive credits for sharing with others',
                                              style: Styles.regularStyle.copyWith(
                                                  color: darkThemeTextColor, fontSize: 12)),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await Messages.shareContent(true);
                                          },
                                        ),
                                      ),
                                      appRated
                                          ? const SizedBox.shrink()
                                          : BounceInRight(
                                              duration: const Duration(milliseconds: 1000),
                                              child: ListTile(
                                                enabled: true,
                                                enableFeedback: true,
                                                leading: const Icon(FontAwesomeIcons.star,
                                                    size: 15, color: darkThemeTextColor),
                                                title: Text('Rate The App',
                                                    style: Styles.regularStyle
                                                        .copyWith(color: darkThemeTextColor)),
                                                subtitle: Text(
                                                    'Receive credits for rating US Congress App',
                                                    style: Styles.regularStyle.copyWith(
                                                        color: darkThemeTextColor, fontSize: 12)),
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  await Functions.linkLaunch(context, googleAppLink,
                                                          userDatabase, userIsPremium,
                                                          appBarTitle: 'Thank you for your rating!',
                                                          interstitialAd: null)
                                                      .then((_) async {
                                                    userDatabase.put('appRated', true);
                                                    await Functions.processCredits(true,
                                                        isPermanent: true, creditsToAdd: 100);
                                                  });
                                                },
                                              ),
                                            ),
                                      ecwidProductsList.isEmpty
                                          ? const SizedBox.shrink()
                                          : BounceInRight(
                                              duration: const Duration(milliseconds: 600),
                                              child: ListTile(
                                                enabled: true,
                                                enableFeedback: true,
                                                leading: const Icon(FontAwesomeIcons.store,
                                                    size: 15, color: darkThemeTextColor),
                                                title: Text('Shop Merchandise',
                                                    style: Styles.regularStyle
                                                        .copyWith(color: darkThemeTextColor)),
                                                subtitle: productOrdersList.isEmpty
                                                    ? const SizedBox.shrink()
                                                    : Text('Long press to view past orders',
                                                        style: Styles.regularStyle.copyWith(
                                                            color: darkThemeTextColor,
                                                            fontSize: 12)),
                                                onTap: () async {
                                                  Navigator.pop(context);

                                                  showModalBottomSheet(
                                                      backgroundColor: Colors.transparent,
                                                      isScrollControlled: false,
                                                      enableDrag: true,
                                                      context: context,
                                                      builder: (context) {
                                                        return SharedWidgets.ecwidProductsListing(
                                                            context,
                                                            null,
                                                            ecwidProductsList,
                                                            userDatabase,
                                                            userLevels,
                                                            productOrdersList);
                                                      });
                                                },
                                                onLongPress: productOrdersList.isEmpty
                                                    ? null
                                                    : () async {
                                                        Navigator.pop(context);

                                                        showModalBottomSheet(
                                                            backgroundColor: Colors.transparent,
                                                            isScrollControlled: false,
                                                            enableDrag: true,
                                                            context: context,
                                                            builder: (context) {
                                                              return SharedWidgets
                                                                  .pastProductOrders(
                                                                context,
                                                                userDatabase,
                                                                userLevels,
                                                                darkTheme,
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
                                  duration: const Duration(milliseconds: 1200),
                                  child: ListTile(
                                    enabled: true,
                                    enableFeedback: true,
                                    leading: const FaIcon(FontAwesomeIcons.gear,
                                        size: 13, color: darkThemeTextColor),
                                    title: Text('Settings',
                                        style: Styles.regularStyle
                                            .copyWith(color: darkThemeTextColor)),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const Settings(),
                                          ));
                                    },
                                  ),
                                ),
                                List.from(userDatabase.get('userIdList'))
                                        .any((element) => element.toString().contains(devCode))
                                    ? FadeInRight(
                                        duration: const Duration(milliseconds: 2000),
                                        child: ListTile(
                                          enabled: true,
                                          enableFeedback: true,
                                          leading: const Icon(Icons.developer_board,
                                              size: 15, color: darkThemeTextColor),
                                          title: Text('Developer Page',
                                              style: Styles.regularStyle
                                                  .copyWith(color: darkThemeTextColor)),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const DeveloperPage(),
                                                ));
                                          },
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                FadeInRight(
                                    child: SharedWidgets.createdByContainer(
                                        context, userIsPremium, userDatabase)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    body: const HomePage(title: "US Congress")),
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
                  image: AssetImage('assets/congress_pic_$commentBoxImageIndex.png'),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.color)),
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
                        hintStyle:
                            Styles.regularStyle.copyWith(color: darkThemeTextColor, fontSize: 15),
                        counterStyle: const TextStyle(color: darkThemeTextColor)),
                    style: const TextStyle(color: darkThemeTextColor),
                    validator: (val) =>
                        // _val.isEmpty ||
                        //         !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        //             .hasMatch(_val)
                        //     ? "Enter a valid email"
                        //     : null,
                        EmailValidator.validate(val) ? null : "Please enter a valid email",
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
                    maxLength: userIsPremium
                        ? 400
                        : userIsLegacy
                            ? 300
                            : 200,
                    decoration: InputDecoration(
                        errorStyle: const TextStyle(color: Colors.white),
                        hintText: 'Your comment',
                        hintStyle:
                            Styles.regularStyle.copyWith(color: darkThemeTextColor, fontSize: 15),
                        counterStyle: const TextStyle(color: darkThemeTextColor)),
                    style: const TextStyle(color: darkThemeTextColor),
                    validator: (val) =>
                        val.isEmpty || val.length < 10 ? 'Not enough information' : null,
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
                                  padding: MaterialStateProperty.all(const EdgeInsets.all(5))),
                              onPressed: () => setState(() {
                                    isCommenting = false;
                                    userComment = '';
                                  }),
                              child: const Text('Cancel')),
                          const SizedBox(width: 5),
                          ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: darkTheme
                                      ? MaterialStateProperty.all<Color>(Colors.black)
                                      : MaterialStateProperty.all<Color>(
                                          Theme.of(context).colorScheme.primary)),
                              icon: commentSending
                                  ? AnimatedWidgets.circularProgressWatchtower(
                                      context, userDatabase, userIsPremium,
                                      widthAndHeight: 11, strokeWidth: 1, isFullScreen: false)
                                  : const Icon(Icons.send, size: 10, color: darkThemeTextColor),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() => commentSending = true);

                                  /// UPDATE DBASE EMAIL LIST WITH NEW EMAIL ADDRESS
                                  List<String> userEmailList =
                                      List.from(userDatabase.get('userEmailList'));
                                  if (!userEmailList.any((element) =>
                                      element.toLowerCase() == userEmail.toLowerCase())) {
                                    userEmailList.add('$userEmail<|:|>${DateTime.now()}');
                                    userDatabase.put('userEmailList', userEmailList);
                                  }
                                  logger.d('${userDatabase.get('userEmailList')}');

                                  /// EMAIL COMMENT TO DEVELOPER EMAIL ADDRESS
                                  try {
                                    await EmailjsApi.sendCommentEmail(
                                      'A comment from user ${userIdList.last.toString().split('<|:|>')[1]}',
                                      'USER COMMENT: $userComment',
                                      'mettacode@gmail.com',
                                      fromEmail: userEmail,
                                      additionalData1:
                                          'USER STATUS => ${userIsPremium ? 'Premium' : userIsLegacy ? 'Legacy' : 'Free'} :: USER IDs => ${userIdList.map((e) => '${e.split('<|:|>')[0]} ${e.split('<|:|>')[1]} created ${dateWithTimeFormatter.format(DateTime.parse(e.split('<|:|>')[2]).toUtc())} UTC')} :: DLC => ${userDatabase.get('devLegacyCode')} - DPC => ${userDatabase.get('devPremiumCode')} - FTC => ${userDatabase.get('freeTrialCode')}',
                                      additionalData2:
                                          'USER EMAIL(S) => ${List.from(userDatabase.get('userEmailList')).map((e) => '${e.split('<|:|>')[0]} added ${dateWithTimeFormatter.format(DateTime.parse(e.split('<|:|>')[1]).toUtc())} UTC')}',
                                      additionalData3:
                                          'PACKAGE INFO => ${userDatabase.get('packageInfo')}',
                                      additionalData4:
                                          'DEVICE INFO => ${userDatabase.get('deviceInfo')}',
                                      additionalData5:
                                          'TOTAL CREDITS => ${userDatabase.get('purchCredits')} Purch, ${userDatabase.get('permCredits')} Perm & ${userDatabase.get('credits')} Temp :: CURRENT ADDRESS => ${userDatabase.get('currentAddress')} :: LOCATION INFO => ${userDatabase.get('locationData')}',
                                    );
                                  } catch (e) {
                                    logger.w('EMAIL ERROR: MESSAGE NOT SENT - $e');
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
                              label:
                                  const Text('Send', style: TextStyle(color: darkThemeTextColor))),
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

  Future<void> drawerTextInput(BuildContext context, String titleText, String devLegacyCode,
      String devPremiumCode, String freeTrialCode) async {
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
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                                  hintText: !userIsPremium && !userIsLegacy
                                      ? 'Free users cannot update user name'
                                      : 'What shall we call you?',
                                  errorStyle:
                                      TextStyle(color: darkTheme ? altHighlightColor : null)),
                              onChanged: (val) => setState(() => data = val.replaceAll(' ', '')),
                            ),
                          ),
                          IconButton(
                              iconSize: 18,
                              icon: Icon(!userIsPremium &&
                                      !userIsLegacy &&
                                      data != devCode &&
                                      data != devLegacyCode &&
                                      data != devPremiumCode &&
                                      data != freeTrialCode
                                  ? Icons.workspace_premium
                                  : Icons.send),
                              onPressed: !userIsPremium &&
                                      !userIsLegacy &&
                                      data != devCode &&
                                      data != devLegacyCode &&
                                      data != devPremiumCode &&
                                      data != freeTrialCode
                                  ? () {
                                      Navigator.pop(context);
                                      Functions.requestInAppPurchase(context, null, userIsPremium,
                                          whatToShow: 'upgrades');
                                    }
                                  : () async {
                                      if (formKey.currentState.validate()) {
                                        Navigator.pop(context);

                                        if (data == devLegacyCode) {
                                          List<String> userIdList =
                                              List.from(userDatabase.get('userIdList'));
                                          userIdList.insert(0, oldUserIDTag);
                                          userDatabase.put('devLegacyCode',
                                              'DLC${random.nextInt(900000) + 100000}');
                                          userDatabase.put('userIdList', userIdList);
                                          userDatabase.put('devUpgraded', true);
                                        } else if (data == devPremiumCode) {
                                          userDatabase.put('userIsPremium', true);
                                          userDatabase.put('devUpgraded', true);
                                          userDatabase.put('devPremiumCode',
                                              'DPC${random.nextInt(900000) + 100000}');
                                        } else if (data == freeTrialCode) {
                                          userDatabase.put('userIsPremium', true);
                                          userDatabase.put('freeTrialUsed', true);
                                          userDatabase.put(
                                              'freeTrialStartDate', '${DateTime.now()}');
                                          userDatabase.put('freeTrialCode',
                                              'FTC${random.nextInt(900000) + 100000}');
                                        } else {
                                          List<String> currentUserIdList =
                                              List.from(userDatabase.get('userIdList'));
                                          if (!currentUserIdList.any((element) =>
                                              element.startsWith('$newUserIdPrefix$data'))) {
                                            currentUserIdList
                                                .add('$newUserIdPrefix$data<|:|>${DateTime.now()}');
                                          } else if (currentUserIdList.any((element) =>
                                              element.startsWith('$newUserIdPrefix$data'))) {
                                            int existingUserNameIndex =
                                                currentUserIdList.indexWhere((element) =>
                                                    element.startsWith('$newUserIdPrefix$data'));

                                            String existingUserName =
                                                currentUserIdList.removeAt(existingUserNameIndex);

                                            currentUserIdList.add(existingUserName);
                                          }
                                          userDatabase.put('userIdList', currentUserIdList);
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
        }).then((_) async => await Functions.processCredits(true, isPermanent: false));
  }
}
