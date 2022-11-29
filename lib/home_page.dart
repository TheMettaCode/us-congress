import 'dart:async';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:us_congress_vote_tracker/congress/market_activity_page.dart';
import 'package:us_congress_vote_tracker/congress/member_details.dart';
import 'package:us_congress_vote_tracker/congress/bill_search.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/constants/widgets.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/models/lobby_event_model.dart';
import 'package:us_congress_vote_tracker/models/member_payload_model.dart';
import 'package:us_congress_vote_tracker/models/bill_recent_payload_model.dart';
// import 'package:us_congress_vote_tracker/models/floor_actions_model.dart';
import 'package:us_congress_vote_tracker/models/news_article_model.dart';
import 'package:us_congress_vote_tracker/models/office_expenses_total.dart';
import 'package:us_congress_vote_tracker/models/order_detail.dart';
import 'package:us_congress_vote_tracker/models/private_funded_trips_model.dart';
import 'package:us_congress_vote_tracker/models/vote_payload_model.dart';
import 'package:us_congress_vote_tracker/services/admob/admob_ad_library.dart';
import 'package:us_congress_vote_tracker/models/statements_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/congress_stock_watch_api.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/house_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/market_activity_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/senate_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/ecwid/ecwid_store_api.dart';
import 'package:us_congress_vote_tracker/services/ecwid/ecwid_store_model.dart';
import 'package:us_congress_vote_tracker/services/emailjs/emailjs_api.dart';
import 'package:us_congress_vote_tracker/services/github/usc_app_data_api.dart';
import 'package:us_congress_vote_tracker/services/github/usc_app_data_model.dart';
import 'package:us_congress_vote_tracker/notifications_handler/notification_api.dart';
import 'package:us_congress_vote_tracker/services/revenuecat/rc_purchase_api.dart';
import 'package:us_congress_vote_tracker/services/youtube/top_congressional_videos.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'constants/constants.dart';
import 'functions/propublica_api_functions.dart';
import 'functions/rapidapi_functions.dart';
import 'models/floor_action_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool appLoading = false;
  String appLoadingText = 'Loading propaganda...';
  List<bool> userLevels = [false, false, false];
  bool userIsDev = false;
  bool userIsPremium = false;
  bool userIsLegacy = false;
  bool devUpgraded = false;
  bool freeTrialUsed = false;
  bool newEcwidProducts = false;
  List<EcwidStoreItem> ecwidProductsList = [];
  List<Order> productOrdersList = [];
  // bool newVersionAvailable = false;
  String queryString = '';

  bool darkTheme = false;

  Container bannerAdContainer = Container();
  // Container rewardedAdContainer = Container();
  bool showBannerAd = true;
  bool adLoaded = false;
  RewardedAd rewardedAd;
  InterstitialAd interstitialAd;
  // bool showSupport = false;
  bool showPremiumPromo = true;

  // int numberOfPromotions = 0;
  // int thisPromotion = 0;
  // List<Widget> listOfPromotions = [];
  List<GithubNotifications> githubNotificationsList = [];
  GithubNotifications thisGithubNotification;

  int headerImageCounter = 0;
  bool randomImageActivated = false;

  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  int congress = 117;

  Timer thirtySecondTimer;

  // ignore: unused_field
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  // ignore: unused_field
  bool _connectionLost = false;
  // ignore: unused_field
  String _connectionType;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool houseFloorLoading = true;
  bool senateFloorLoading = true;
  String lastRefresh = '';
  bool dataRefresh = false;
  bool _marketPageLoading = false;
  double thisThirtySeconds = 0;

  List<Vote> voteList = [];
  List<UpdatedBill> billList = [];
  List<LobbyingRepresentation> lobbyingEventsList = [];
  List<PrivateTripResult> privatelyFundedTripsList = [];
  List<TotalExpensesResult> officeExpensesList = [];
  List<HouseStockWatch> houseStockWatchList = [];
  List<SenateStockWatch> senateStockWatchList = [];
  List<MarketActivity> marketActivityOverviewList = [];

  bool loadingSenators = false;
  bool loadingRepresentatives = false;

  List<StatementsResults> statementsList = [];
  List<NewsArticle> newsArticlesList = [];

  List<ActionsList> currentHouseFloorActions = [];
  DateTime currentHouseFloorActionsDate = DateTime.now();
  List<ActionsList> currentSenateFloorActions = [];
  DateTime currentSenateFloorActionsDate = DateTime.now();

  // List<FloorAction> senateFloorActions = [];
  // List<FloorAction> houseFloorActions = [];

  List<ChamberMember> houseMembersList = [];
  List<ChamberMember> houseRepublicansList = [];
  List<ChamberMember> houseDemocratsList = [];
  List<ChamberMember> houseIndependentsList = [];
  List<ChamberMember> senateMembersList = [];
  List<ChamberMember> senateRepublicansList = [];
  List<ChamberMember> senateDemocratsList = [];
  List<ChamberMember> senateIndependentsList = [];
  List<ChamberMember> userCongressList = [];

  // List<PlaylistItem> youTubePlaylist = [];
  List<ChannelVideos> youtubeVideosList = [];

  // AnimationController animationController;
  ScrollController scrollController = ScrollController();
  final ScrollController _videoListController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: true,
  );
  ScrollController newsArticleSliderController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: true,
  );

// NOTIFICATION LISTENER FLAGS
  String onClickAction = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (Platform.isAndroid) WebView.platform = AndroidWebView();

        await init();

        executeOnClickNotificationListenerActions();
      },
    );
    super.initState();
  }

  // Dispose the controller
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> init() async {
    setState(() => appLoading = true);

    await setInitialVariables();
    await GithubApi.getPromoMessages(context);

    /// BEGIN VIDEO SCROLL ANIMATIONS
    // if (youTubePlaylist.isNotEmpty) {
    //   _videoListController.animateTo((youTubePlaylist.length.toDouble() - 1) * 150,
    //       duration: const Duration(seconds: 30), curve: Curves.linear);
    // }
    if (youtubeVideosList.isNotEmpty) {
      _videoListController.animateTo((youtubeVideosList.length.toDouble() - 1) * 150,
          duration: const Duration(seconds: 30), curve: Curves.linear);
    }

    /// BEGIN NEWS SCROLL ANIMATIONS
    if (newsArticlesList.isNotEmpty) {
      newsArticleSliderController.animateTo(newsArticlesList.length.toDouble() * 180,
          duration: const Duration(seconds: 120), curve: Curves.linear);
    }

    /// USED TO LISTEN FOR CUSTOMER SUBSCRIPTION UPDATES
    await RcPurchaseApi.getSubscriptionStatus();
    Purchases.addCustomerInfoUpdateListener((purchaserInfo) async => {
          // handle any changes to purchaserInfo
          await RcPurchaseApi.getSubscriptionStatus()
        });

    /// CHECK FOR AND SHOW LATEST APP UPDATES
    await Functions.showLatestUpdates(context);

    /// Listen for online connection state events
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    /// LISTEN FOR NOTIFICATION EVENTS HERE
    listenNotifications();

    /// LOAD REWARDED AD
    await loadAds(userIsPremium);

    /// DETERMINE USER LEVEL
    await Functions.getUserLevels().then((levels) => setState(() {
          userLevels = levels;
          userIsDev = userLevels[0];
          userIsPremium = userLevels[1];
          userIsLegacy = userLevels[2];
        }));

    // if (userIsPremium && freeTrialUsed)
    await Functions.getTrialStatus(context, interstitialAd, userIsPremium, userIsLegacy);

    /// RETREIVE ALL MEMBERS DATA
    await getMembers('all');

    /// LOAD ALL APP DATA AND SET CONGRESS NUMBER
    await getData().whenComplete(() => setState(() {
          congress = userDatabase.get('congress');
        }));

    /// CHECK FOR USER APP USAGE REWARDS
    await Functions.checkRewards(
        context, interstitialAd, rewardedAd, userLevels, githubNotificationsList);

    /// IF USER IS NEW, REQUEST USAGE INFORMATION APPROVAL
    if (!userDatabase.get('usageInfo') && !userDatabase.get('usageInfoSelected')) {
      await Functions.requestUsageInfo(context);
    }

    /// APP 1 MINUTE TIMER FUNCTION. USE TO CREATE PERIODIC
    /// AND DERIVATIVE CLOCKS AND TIMERS
    thirtySecondTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) async {
      logger.d('***** Thirty Seconds Timer Minute Timer Initialized... *****');

      /// THIRTY SECONDS TIMER
      if (thisThirtySeconds % 0.5 == 0) {
        logger.d(
            '***** 30 Seconds Timer Triggered (${dateWithTimeFormatter.format(DateTime.now().toLocal())}) *****');

        if (!randomImageActivated) {
          setState(() => randomImageActivated = !randomImageActivated);
        }
        // setState(() => thisPromotion = random.nextInt(numberOfPromotions));

        /// SEND NOTIFICATION OF FREE PREMIUM TRIAL ENDING
        if (userIsPremium &&
            freeTrialUsed &&
            ((freeTrialPromoDurationDays * 86400) -
                    DateTime.now()
                        .difference(DateTime.parse(userDatabase.get('freeTrialStartDate')))
                        .inSeconds <
                60) &&
            ((freeTrialPromoDurationDays * 86400) -
                    DateTime.now()
                        .difference(DateTime.parse(userDatabase.get('freeTrialStartDate')))
                        .inSeconds >
                30)) {
          await Messages.sendNotification(source: 'trial_ending');
        }

        /// DISABLE FREE PREMIUM TRIAL
        if ((freeTrialPromoDurationDays * 1440) -
                DateTime.now()
                    .difference(DateTime.parse(userDatabase.get('freeTrialStartDate')))
                    .inMinutes <=
            0) {
          await Functions.getTrialStatus(context, interstitialAd, userIsPremium, userIsLegacy);
        }
      }

      /// FIRST MINUTE TIMER
      if (thisThirtySeconds % 1 == 0) {
        logger.d(
            '***** 1 Minute Timer Triggered (${dateWithTimeFormatter.format(DateTime.now().toLocal())}) *****');

        if (showPremiumPromo) {
          setState(() => showPremiumPromo = !showPremiumPromo);
        }

        if (_videoListController.offset >= (youtubeVideosList.length.toDouble() - 1) * 150) {
          _videoListController.animateTo(0,
              duration: const Duration(seconds: 30), curve: Curves.linear);
        } else if (_videoListController.offset <= 30) {
          _videoListController.animateTo((youtubeVideosList.length.toDouble() - 1) * 150,
              duration: const Duration(seconds: 30), curve: Curves.linear);
        }
      }

      /// TWO MINUTE TIMER
      if (thisThirtySeconds % 2 == 0) {
        logger.d(
            '***** 2 Minute Timer Triggered (${dateWithTimeFormatter.format(DateTime.now().toLocal())}) *****');

        /// NEWS SLIDER ANIMATION
        if (newsArticleSliderController.offset >= newsArticlesList.length.toDouble() * 180) {
          newsArticleSliderController.jumpTo(0);
        } else if (newsArticleSliderController.offset <= 30) {
          newsArticleSliderController.animateTo(newsArticlesList.length.toDouble() * 180,
              duration: const Duration(seconds: 120), curve: Curves.linear);
        }
      }

      /// 5 MINUTE TIMER
      if (thisThirtySeconds > 0 && thisThirtySeconds % 5 == 0) {
        logger.d(
            '***** 5 Minute Timer Triggered (${dateWithTimeFormatter.format(DateTime.now().toLocal())}) *****');

        // if (!showSupport) setState(() => showSupport = !showSupport);

        await loadAds(userIsPremium);
        await getData();
      }

      /// 7 MINUTE TIMER
      if (thisThirtySeconds > 0 && thisThirtySeconds % 6 == 0) {
        logger.d(
            '***** 10 Minute Timer Triggered (${dateWithTimeFormatter.format(DateTime.now().toLocal())}) *****');

        if (!showPremiumPromo) {
          setState(() => showPremiumPromo = !showPremiumPromo);
        }
      }

      /// 10 MINUTE TIMER
      if (thisThirtySeconds > 0 && thisThirtySeconds % 10 == 0) {
        logger.d(
            '***** 10 Minute Timer Triggered (${dateWithTimeFormatter.format(DateTime.now().toLocal())}) *****');

        setState(() => headerImageCounter = random.nextInt(4));
      }

      /// 15 MINUTE TIMER
      if (thisThirtySeconds > 0 && thisThirtySeconds % 15 == 0) {
        logger.d(
            '***** 15 Minute Timer Triggered (${dateWithTimeFormatter.format(DateTime.now().toLocal())}) *****');
      }

      /// 20 MINUTE TIMER
      if (thisThirtySeconds > 0 && thisThirtySeconds % 20 == 0) {
        logger.d(
            '***** 20 Minute Timer Triggered (${dateWithTimeFormatter.format(DateTime.now().toLocal())}) *****');
      }

      /// 25 MINUTE TIMER
      if (thisThirtySeconds > 0 && thisThirtySeconds % 25 == 0) {
        logger.d(
            '***** 25 Minute Timer Triggered (${dateWithTimeFormatter.format(DateTime.now().toLocal())}) *****');
      }

      /// 30 MINUTE TIMER
      if (thisThirtySeconds > 0 && thisThirtySeconds % 30 == 0) {
        logger.d('***** 30 Minute Timer Triggered... *****');
        setState(() => thisThirtySeconds = 0);
      }

      // thisMinute += 1;
      thisThirtySeconds += 0.5;
    });
    setState(() => appLoading = false);
  }

  Future<void> setInitialVariables() async {
    await userDatabase.put('appOpens', userDatabase.get('appOpens') + 1);
    logger.d('***** App Opens: ${userDatabase.get('appOpens')} *****');

    await Functions.processCredits(true, isPurchased: false, isPermanent: false, creditsToAdd: 5);
    logger.d(
        '*****\nCREDITS: ${userDatabase.get('credits')}\nPERMANENT CREDITS: ${userDatabase.get('permCredits')}\nPURCHASED CREDITS: ${userDatabase.get('purchCredits')} *****');

    /// GITHUB NOTIFICATIONS LIST
    List<GithubNotifications> tempGithubNotificationsList = [];
    GithubNotifications tempGithubNotification;
    try {
      tempGithubNotificationsList = await GithubApi.pruneAndSortPromoNotifications(
          githubDataFromJson(userDatabase.get('githubData')).notifications,
          userIsDev
              ? "developer"
              : userIsPremium
                  ? "premium"
                  : userIsLegacy
                      ? "legacy"
                      : "free",
          DateTime.now());
      // githubDataFromJson(userDatabase.get('githubData')).notifications;
      tempGithubNotification =
          tempGithubNotificationsList[random.nextInt(tempGithubNotificationsList.length)];
      logger.d(
          '^^^^^ GITHUB NOTIFICATIONS (Home Page): ${tempGithubNotificationsList.map((e) => e.title)}');
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING GITHUB NOTIFICATIONS LIST DATA FROM DBASE (MAIN.DART): $e ^^^^^');
    }

    logger.d(
        '^^^^^ GITHUB NOTIFICATIONS (Home Page): ${tempGithubNotificationsList.map((e) => e.title)}');
    setState(() {
      devUpgraded = userDatabase.get('devUpgraded');
      freeTrialUsed = userDatabase.get('freeTrialUsed');
      newEcwidProducts = userDatabase.get('newEcwidProducts');
      githubNotificationsList = tempGithubNotificationsList;
      thisGithubNotification = tempGithubNotification;
    });

    try {
      List<ChannelVideos> xVideosList =
          topCongressionalVideosFromJson(userDatabase.get('youtubeVideosList'))
              .channels
              .map((e) => e.channelVideos)
              .expand((element) => element)
              .toList();
      await YouTubeVideosApi.convertAllDates(xVideosList)
          .then((value) => setState(() => youtubeVideosList = value));
    } catch (e) {
      logger.w('^^^^^ ERROR DURING YOUTUBE PLAYLIST INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('youtubeVideosList', {});
    }

    /// NEWS ARTICLES LIST
    try {
      List<NewsArticle> tempNewsList = newsArticleFromJson(userDatabase.get('newsArticles'));
      await RapidApiFunctions.processNewsArticleDates(tempNewsList)
          .then((value) => setState(() => newsArticlesList = value));
      debugPrint('[HOME PAGE INITIAL DATA] ${newsArticlesList.length} NEWS ARTICLES');
    } catch (e) {
      logger.w('^^^^^ ERROR DURING NEWS ARTICLES LIST INITIAL VARIABLES SETUP: $e ^^^^^');
      // userDatabase.put('newsArticles', {});
    }

    /// HOUSE FLOOR ACTIONS
    try {
      CongressFloorAction houseFloorAction =
          congressFloorActionFromJson(userDatabase.get('houseFloorActions'));

      setState(() {
        currentHouseFloorActionsDate =
            DateFormat('EEE, dd MMM yyyy hh:mm:ss').parse(houseFloorAction.actionsDate);
        currentHouseFloorActions = houseFloorAction.actionsList;
      });
      logger
          .d('[SET INITIAL VALUES] SET HOUSE FLOOR ACTIONS & DATE: $currentHouseFloorActionsDate');
      setState(() => houseFloorLoading = false);
    } catch (e) {
      logger.w('[NEW FLOOR ACTION FUNCTION] CURRENT HOUSE Actions ERROR: $e - Resetting... *****');
      userDatabase.put('houseFloorActions', {});
      // currentFloorActions = [];
    }

    /// SENATE FLOOR ACTIONS
    try {
      CongressFloorAction senateFloorAction =
          congressFloorActionFromJson(userDatabase.get('senateFloorActions'));

      setState(() {
        currentSenateFloorActionsDate =
            DateFormat('EEEE, MMMM dd, yyyy').parse(senateFloorAction.actionsDate);
        currentSenateFloorActions = senateFloorAction.actionsList;
      });
      logger
          .d('[SET INITIAL VALUES] SET HOUSE FLOOR ACTIONS & DATE: $currentSenateFloorActionsDate');
      setState(() => senateFloorLoading = false);
    } catch (e) {
      logger.w('[NEW FLOOR ACTION FUNCTION] CURRENT SENATE Actions ERROR: $e - Resetting... *****');
      userDatabase.put('senateFloorActions', {});
      // currentFloorActions = [];
    }

    /// LOBBYING EVENTS LIST
    try {
      setState(() => lobbyingEventsList = lobbyEventFromJson(userDatabase.get('lobbyingEventsList'))
          .results
          .first
          .lobbyingRepresentations);
    } catch (e) {
      logger.w('^^^^^ ERROR DURING LOBBY EVENTS INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('lobbyingEventsList', {});
    }

    /// PRIVATELY FUNDED TRIPS LIST
    try {
      setState(() => privatelyFundedTripsList =
          privateFundedTripFromJson(userDatabase.get('privateFundedTripsList')).results);
    } catch (e) {
      logger.w('^^^^^ ERROR DURING PRIVATE TRIPS INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('privateFundedTripsList', {});
    }

    /// HOUSE STOCK ACTIVITY LIST
    try {
      setState(() =>
          houseStockWatchList = houseStockWatchFromJson(userDatabase.get('houseStockWatchList')));
    } catch (e) {
      logger.w('^^^^^ ERROR DURING HOUSE STOCK TRADE INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('houseStockWatchList', []);
    }

    /// SENATE STOCK ACTIVITY LIST
    try {
      setState(() => senateStockWatchList =
          senateStockWatchFromJson(userDatabase.get('senateStockWatchList')));
    } catch (e) {
      logger.w('^^^^^ ERROR DURING SENATE STOCK TRADE INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('senateStockWatchList', []);
    }

    /// MARKET ACTIVITY OVERVIEW LIST
    try {
      setState(() => marketActivityOverviewList =
          marketActivityFromJson(userDatabase.get('marketActivityOverview')));
    } catch (e) {
      logger.w('^^^^^ ERROR DURING MARKET ACTIVITY OVERVIEW INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('marketActivityOverview', {});
    }

    /// RECENT VOTES
    try {
      setState(() => voteList = payloadFromJson(userDatabase.get('recentVotes')).results.votes);
    } catch (e) {
      logger.w('^^^^^ ERROR DURING VOTE LIST INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('recentVotes', {});
    }

    /// RECENT BILLS
    try {
      setState(() =>
          billList = recentbillsFromJson(userDatabase.get('recentBills')).results.first.bills);
    } catch (e) {
      logger.w('^^^^^ ERROR DURING BILL LIST INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('recentBills', {});
    }

    /// HOUSE MEMBERS LIST
    try {
      setState(() => houseMembersList =
          memberPayloadFromJson(userDatabase.get('houseMembersList')).results.first.members);
    } catch (e) {
      logger.w('^^^^^ ERROR DURING HOUSE MEMBERS LIST INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('houseMembersList', {});
    }

    /// SENATE MEMBERS LIST
    try {
      setState(() => senateMembersList =
          memberPayloadFromJson(userDatabase.get('senateMembersList')).results.first.members);
    } catch (e) {
      logger.w('^^^^^ ERROR DURING SENATE MEMBERS LIST INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('senateMembersList', {});
    }

    /// MEMBER STATEMENTS LIST
    try {
      setState(() =>
          statementsList = statementsFromJson(userDatabase.get('statementsResponse')).results);
    } catch (e) {
      logger.w('^^^^^ ERROR DURING MEMBER STATEMENTS LIST INITIAL VARIABLES SETUP: $e ^^^^^');
      userDatabase.put('statementsResponse', {});
    }

    /// ECWID STORE PRODUCTS LIST
    try {
      setState(
          () => ecwidProductsList = ecwidStoreFromJson(userDatabase.get('ecwidProducts')).items);
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING ECWID STORE ITEMS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
      userDatabase.put('ecwidProducts', {});
    }

    /// PRODUCT ORDERS LIST
    try {
      setState(() => productOrdersList =
          orderDetailListFromJson(userDatabase.get('ecwidProductOrdersList')).orders);
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
    }
  }

  /// LISTENING FOR INCOMING NOTIFICATIONS
  void listenNotifications() {
    NotificationApi.onNotifications.stream.listen(onClickedNotification);
  }

  /// ACTIONS TO TAKE WHEN NOTIFICATION IS CLICKED
  void onClickedNotification(String payload) async {
    setState(() => onClickAction = payload);
  }

  void executeOnClickNotificationListenerActions() {
    // if (onClickAction == 'product') {
    //   showModalBottomSheet(
    //       backgroundColor: Colors.transparent,
    //       isScrollControlled: false,
    //       enableDrag: true,
    //       context: context,
    //       builder: (context) {
    //         return SharedWidgets.ecwidProductsListing(context,
    //             ecwidProductsList, userDatabase, userLevels, productOrdersList);
    //       }).then((_) => !userIsPremium &&
    //           rewardedAd != null &&
    //           rewardedAd.responseInfo.responseId !=
    //               userDatabase.get('rewardedAdId')
    //       ? AdMobLibrary().rewardedAdShow(rewardedAd)
    //       : null);
    // } else if (onClickAction == 'share') {
    //   Messages.shareContent(true);
    // }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      logger.d(e.toString());
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }
    // logger.d('***** Connectivity Result: $result *****');
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });

    final connectedTo = result.toString().split('.')[1];

    setState(() => _connectionType = connectedTo);

    if (connectedTo == 'none') {
      Messages.showMessage(context: context, message: 'CONNECTION LOST', isAlert: true);
      setState(() => _connectionLost = true);
    } else if (thisThirtySeconds > 0 && (connectedTo == 'mobile' || connectedTo == 'wifi')) {
      setState(() => _connectionLost = false);
      Messages.showMessage(
        context: context,
        message: 'CONNECTED TO ${connectedTo.toUpperCase()}',
        isAlert: false,
      );

      Future.delayed(const Duration(seconds: 10), () async {
        getData();
      });
    }
  }

  Future<void> getData() async {
    if (!_connectionLost) {
      setState(() {
        dataRefresh = true;
        randomImageActivated = false;
      });

      setState(() => appLoadingText = 'Checking for videos...');
      // await Youtube.getYouTubePlaylistItems(context: context)
      //     .then((value) => setState(() => youTubePlaylist = value));

      await YouTubeVideosApi.getYoutubeVideos()
          .then((value) => setState(() => youtubeVideosList = value));

      setState(() => appLoadingText = 'Retrieving latest news...');
      await RapidApiFunctions.fetchNewsArticles(context: context)
          .then((value) => setState(() => newsArticlesList = value));
      debugPrint('[HOME PAGE GET DATA] ${newsArticlesList.length} NEWS ARTICLES');

      setState(() => appLoadingText = 'Checking for bill activity...');
      await Functions.fetchBills(
        context: context,
      ).then((value) {
        setState(() => billList = value);
      });

      setState(() => appLoadingText = 'Checking for new votes...');
      await Functions.fetchVotes(context: context).then((value) {
        setState(() => voteList = value);
      });

      setState(() => appLoadingText = 'Checking lobbying records...');
      await Functions.fetchRecentLobbyEvents(context: context).then((value) {
        List<LobbyingRepresentation> watchedLobbyingEvents = [];
        List<LobbyingRepresentation> unwatchedLobbyingEvents = [];
        List<LobbyingRepresentation> finalLobbyingEvents = [];

        for (var event in value) {
          if (List.from(userDatabase.get('subscriptionAlertsList')).any((element) =>
              element.toString().toLowerCase().startsWith('lobby_${event.id}'.toLowerCase()))) {
            watchedLobbyingEvents.add(event);
          } else {
            unwatchedLobbyingEvents.add(event);
          }
        }

        finalLobbyingEvents = watchedLobbyingEvents + unwatchedLobbyingEvents;
        setState(() => lobbyingEventsList = finalLobbyingEvents);
      });

      setState(() => appLoadingText = 'Checking for private travel...');
      await Functions.fetchPrivateFundedTravel(congress, context: context)
          .then((value) => setState(() => privatelyFundedTripsList = value));

      setState(() => appLoadingText = 'Checking for Senate stock disclosures...');
      await CongressStockWatchApi.fetchSenateStockDisclosures(context: context)
          .then((value) => setState(() => senateStockWatchList = value));

      setState(() => appLoadingText = 'Checking for House stock disclosures...');
      await CongressStockWatchApi.fetchHouseStockDisclosures(context: context)
          .then((value) => setState(() => houseStockWatchList = value));

      setState(() => appLoadingText = 'Updating market activity overview...');
      await CongressStockWatchApi.updateMarketActivityOverview(
              context: context, allChamberMembers: houseMembersList + senateMembersList)
          .then((value) => setState(() => marketActivityOverviewList = value));

      setState(() => appLoadingText = 'Checking for congressional statements...');
      await Functions.fetchStatements(context: context).then((value) {
        List<StatementsResults> watchedStatements = [];
        List<StatementsResults> unwatchedStatements = [];
        List<StatementsResults> finalStatements = [];

        for (var statement in value) {
          if (List.from(userDatabase.get('subscriptionAlertsList')).any((element) => element
              .toString()
              .toLowerCase()
              .startsWith('member_${statement.memberId}'.toLowerCase()))) {
            watchedStatements.add(statement);
          } else {
            unwatchedStatements.add(statement);
          }
        }

        finalStatements = watchedStatements + unwatchedStatements;
        setState(() => statementsList = finalStatements);
      });

      setState(() => appLoadingText = 'Checking for new house floor actions...');

      await RapidApiFunctions.getFloorActions(context: context).then((value) => setState(() {
            currentHouseFloorActions = value;
            houseFloorLoading = false;
          }));

      setState(() => appLoadingText = 'Checking for new senate floor actions...');

      await RapidApiFunctions.getFloorActions(context: context, isHouseChamber: false)
          .then((value) => setState(() {
                currentSenateFloorActions = value;
                senateFloorLoading = false;
              }));

      await EcwidStoreApi.getEcwidStoreProducts()
          .then((value) => setState(() => ecwidProductsList = value));

      await EmailjsApi.sendCapitolBabbleSocialEmail();

      await userDatabase.put('lastRefresh', DateTime.now().toString());

      setState(() {
        dataRefresh = false;
        randomImageActivated = true;
        lastRefresh = userDatabase.get('lastRefresh');
      });
    }
  }

  Future<void> getMembers(String chamber) async {
    switch (chamber) {
      case 'all':
        setState(() {
          loadingSenators = true;
          loadingRepresentatives = true;
        });
        await Functions.getMembersList(congress, 'senate',
            context: context, memberIdsToRemove: ['h001075', 'l000594']).then((value) {
          setState(() {
            senateMembersList = value;
            senateRepublicansList =
                value.where((element) => element.party.toLowerCase() == 'r').toList();
            senateDemocratsList =
                value.where((element) => element.party.toLowerCase() == 'd').toList();
            senateIndependentsList =
                value.where((element) => element.party.toLowerCase() == 'id').toList();
          });
          setState(() => loadingSenators = false);
        });

        await Functions.getMembersList(congress, 'house',
            context: context, memberIdsToRemove: ['h001075', 'l000594']).then((value) {
          setState(() {
            houseMembersList = value;
            houseRepublicansList =
                value.where((element) => element.party.toLowerCase() == 'r').toList();
            houseDemocratsList =
                value.where((element) => element.party.toLowerCase() == 'd').toList();
            houseIndependentsList =
                value.where((element) => element.party.toLowerCase() == 'id').toList();
          });
          setState(() => loadingRepresentatives = false);
        });
        break;
      case 'senate':
        setState(() => loadingSenators = true);
        await Functions.getMembersList(congress, 'senate',
            context: context, memberIdsToRemove: ['h001075', 'l000594']).then((value) {
          setState(() {
            senateMembersList = value;
            senateRepublicansList =
                value.where((element) => element.party.toLowerCase() == 'r').toList();
            senateDemocratsList =
                value.where((element) => element.party.toLowerCase() == 'd').toList();
            senateIndependentsList =
                value.where((element) => element.party.toLowerCase() == 'id').toList();
          });
          setState(() => loadingSenators = false);
        });
        break;
      case 'house':
        setState(() => loadingRepresentatives = true);
        await Functions.getMembersList(congress, 'house',
            context: context, memberIdsToRemove: ['h001075', 'l000594']).then((value) {
          setState(() {
            houseMembersList = value;
            houseRepublicansList =
                value.where((element) => element.party.toLowerCase() == 'r').toList();
            houseDemocratsList =
                value.where((element) => element.party.toLowerCase() == 'd').toList();
            houseIndependentsList =
                value.where((element) => element.party.toLowerCase() == 'id').toList();
          });
          setState(() => loadingRepresentatives = false);
        });
        break;
      default:
        logger.d('***** ERROR: NO CHAMBER GIVEN FOR MEMBER REFRESH *****');
    }

    if (userDatabase.get('usageInfo') &&
        Map<String, dynamic>.from(userDatabase.get('representativesLocation'))['zip'].isNotEmpty) {
      await Functions.getUserCongress(context, senateMembersList + houseMembersList,
              Map<String, dynamic>.from(userDatabase.get('representativesLocation'))['zip'])
          .then((value) {
        setState(() => userCongressList = value);
      });
    }
  }

  Future<void> loadAds(bool userIsPremium) async {
    // if (!userIsPremium) {
    logger.d('***** Default Rewarded Ad Start *****');

    // if (userIsPremium) {
    RewardedAd.load(
      adUnitId: rewardedAdId,
      request: const AdRequest(nonPersonalizedAds: false, keywords: adMobKeyWords),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdFailedToLoad: (LoadAdError error) {
          logger.d('***** Rewarded Ad failed to load: $error *****');
          userDatabase.put('rewardedAdIsNew', false);
          rewardedAd = null;
        },
        onAdLoaded: (RewardedAd rAd) {
          // Keep a reference to the ad so you can show it later.
          logger.d('***** Rewarded Ad loaded ${rAd.responseInfo.responseId} *****');
          if (rAd.responseInfo.responseId != userDatabase.get('rewardedAdId')) {
            logger.d('***** Loaded Ad is NEW! *****');
            userDatabase.put('rewardedAdIsNew', true);
          }
          setState(() => rewardedAd = rAd);
        },
      ),
    );
    // }
    if (!userIsPremium) {
      logger.d('***** Interstitial Ad Start *****');
      InterstitialAd.load(
        adUnitId: interstitialAdId,
        request: const AdRequest(nonPersonalizedAds: false, keywords: adMobKeyWords),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdFailedToLoad: (LoadAdError error) {
            logger.d('***** Interstitial Ad failed to load: $error *****');
            userDatabase.put('interstitialAdIsNew', false);
            interstitialAd = null;
          },
          onAdLoaded: (InterstitialAd iAd) {
            // Keep a reference to the ad so you can show it later.
            logger.d('***** Interstitial Ad loaded ${iAd.responseInfo.responseId} *****');
            if (iAd.responseInfo.responseId != userDatabase.get('interstitialAdId')) {
              logger.d('***** Loaded Interstitial Ad is NEW! *****');
              userDatabase.put('interstitialAdIsNew', true);
            }
            setState(() => interstitialAd = iAd);
          },
        ),
      );
    }
    // return null;
    // } else {
    //   logger.d('***** USER IS PREMIUM UPGRADE. NO ADS LOADED *****');
    // }
  }

  @override
  Widget build(BuildContext context) {
    // ADMOB INFORMATION HERE
    if (!adLoaded && !userIsPremium) {
      final BannerAd thisBanner = AdMobLibrary().defaultBanner();

      thisBanner?.load();

      if (thisBanner != null) {
        setState(() {
          adLoaded = true;
          bannerAdContainer = AdMobLibrary().bannerContainer(thisBanner, context);
        });
      }
    }

    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase).listenable(keys: /*userDatabase.keys.toList()*/
            [
          'currentAddress',
          'representativesLocation',
          'userIdList',
          'subscriptionAlertsList',
          'credits',
          'permCredits',
          'purchCredits',
          'rewardedAdIsNew',
          'interstitialRewardedAdIsNew',
          'interstitialAdIsNew',
          'userIsPremium',
          'appRated',
          'newBills',
          'newVotes',
          'newTrips',
          'newHouseStock',
          'newSenateStock',
          'newStatements',
          'newVideos',
          'newLobbies',
          'newHouseFloor',
          'newSenateFloor',
          'freeTrialUsed',
          'freeTrialDismissed',
          'newEcwidProducts',
          'ecwidProductOrdersList',
        ]),
        builder: (context, box, widget) {
          darkTheme = userDatabase.get('darkTheme');
          freeTrialUsed = userDatabase.get('freeTrialUsed');
          newEcwidProducts = userDatabase.get('newEcwidProducts');
          userIsDev = List.from(userDatabase.get('userIdList'))
              .any((element) => element.toString().contains(dotenv.env['dCode']));
          userIsPremium = userDatabase.get('userIsPremium');
          userIsLegacy = !userDatabase.get('userIsPremium') &&
                  List.from(userDatabase.get('userIdList'))
                      .any((element) => element.toString().startsWith(oldUserIdPrefix))
              ? true
              : false;
          try {
            productOrdersList =
                orderDetailListFromJson(userDatabase.get('ecwidProductOrdersList')).orders;
          } catch (e) {
            productOrdersList = [];
            logger.w(
                '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
          }

          List<String> subscriptionAlertsList =
              List<String>.from(userDatabase.get('subscriptionAlertsList'));

          List<String> memberSubs =
              subscriptionAlertsList.where((sub) => sub.toString().startsWith('member_')).toList();
          List<String> billSubs =
              subscriptionAlertsList.where((sub) => sub.toString().startsWith('bill_')).toList();
          List<String> lobbySubs =
              subscriptionAlertsList.where((sub) => sub.toString().startsWith('lobby_')).toList();
          List<String> otherSubs =
              subscriptionAlertsList.where((sub) => sub.toString().startsWith('other_')).toList();

          return OrientationBuilder(builder: (context, orientation) {
            return Container(
              foregroundDecoration: BoxDecoration(
                  color: !_connectionLost ? Colors.transparent : Colors.black.withOpacity(0.75),
                  backgroundBlendMode: BlendMode.color),
              child: Scaffold(
                appBar: AppBar(
                  leading: GestureDetector(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        dataRefresh
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: republicanColor,
                                  backgroundColor: democratColor,
                                ),
                              )
                            : const SizedBox.shrink(),
                        List<String>.from(userDatabase.get('userIdList'))
                                .last
                                .contains(dotenv.env['dCode'])
                            ? const Icon(Icons.developer_board)
                            : Image.asset('assets/app_icon_tower.png'),
                      ],
                    ),
                  ),
                  centerTitle: true,
                  title: InkWell(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$appTitle ${congress.toString()}',
                            style: Styles.googleStyle.copyWith(fontSize: 25)),
                        Map.from(userDatabase.get('packageInfo')).isNotEmpty &&
                                (userDatabase.get('packageInfo')['version'] == null ||
                                    userDatabase.get('packageInfo')['version'] == 'null')
                            ? ''
                            : Text(
                                '   ${userDatabase.get('packageInfo')['version']}',
                                style: Styles.regularStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Theme.of(context).primaryColorLight),
                              ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    _connectionLost ? const Icon(Icons.mobiledata_off) : const SizedBox.shrink(),
                    SizedBox(
                      width: 30,
                      child: IconButton(
                        iconSize: 25,
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
                              height: 400,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 50,
                                    alignment: Alignment.center,
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: TextField(
                                      keyboardType: TextInputType.text,
                                      textAlign: TextAlign.center,
                                      autocorrect: true,
                                      autofocus: true,
                                      enableSuggestions: true,
                                      decoration: InputDecoration.collapsed(
                                        hintText:
                                            queryString == '' ? 'Enter your search' : queryString,
                                      ),
                                      onChanged: (val) {
                                        queryString = val;
                                      },
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.search),
                                    onPressed: () {
                                      Navigator.pop(context);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BillSearch(
                                              queryString.toLowerCase().replaceAll('.', ''),
                                              houseStockWatchList,
                                              senateStockWatchList),
                                        ),
                                      ).then(
                                          (_) => AdMobLibrary.interstitialAdShow(interstitialAd));
                                    },
                                    label: const Text('Search'),
                                  )
                                ],
                              ),
                            ),
                          ).then((value) async =>
                              await Functions.processCredits(true, isPermanent: false));
                        },
                      ),
                    ),
                    SizedBox(
                        width: 30,
                        child: IconButton(
                          color: newEcwidProducts ? altHighlightColor : null,
                          onPressed: () {
                            userDatabase.put('newEcwidProducts', false);
                            showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: false,
                                enableDrag: true,
                                context: context,
                                builder: (context) {
                                  return SharedWidgets.ecwidProductsListing(
                                      context,
                                      interstitialAd,
                                      ecwidProductsList,
                                      userDatabase,
                                      userLevels,
                                      productOrdersList);
                                }).then((_) => AdMobLibrary.interstitialAdShow(interstitialAd));
                          },
                          icon: const Icon(Icons.store),
                        )),
                    IconButton(
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        icon: const Icon(Icons.more_vert))
                  ],
                ),
                body: appLoading
                    ? AnimatedWidgets.circularProgressWatchtower(
                        context, userDatabase, userIsPremium,
                        isFullScreen: true,
                        isHomePage: true,
                        thisGithubNotification: thisGithubNotification,
                        backgroundImage: 'assets/congress_pic_$headerImageCounter.png')
                    : RefreshIndicator(
                        onRefresh: getData,
                        child: Row(
                          children: [
                            Container(
                              color: Theme.of(context).colorScheme.background,
                              width: orientation == Orientation.landscape &&
                                      // youTubePlaylist.isNotEmpty &&
                                      youtubeVideosList.isNotEmpty
                                  ? MediaQuery.of(context).size.width * 0.58333
                                  : MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  _connectionLost
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                alignment: Alignment.center,
                                                color: Theme.of(context).colorScheme.error,
                                                child: Text(
                                                  'OFFLINE',
                                                  style: Styles.regularStyle.copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: darkThemeTextColor),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                  userIsDev && isPeakCapitolBabblePostHours
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 2),
                                                alignment: Alignment.center,
                                                color: alertIndicatorColorDarkGreen,
                                                child: Text(
                                                  'PEAK HOURS',
                                                  style: Styles.regularStyle.copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: darkThemeTextColor),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                  userIsPremium && freeTrialUsed
                                      ? InkWell(
                                          onTap: () async => await Functions.requestInAppPurchase(
                                              context, interstitialAd, userIsPremium,
                                              whatToShow: 'upgrades'),
                                          child: Container(
                                            color: altHighlightColor,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 3),
                                            child: Text(
                                                'FREE PREMIUM TRIAL ${freeTrialPromoDurationDays - DateTime.now().difference(DateTime.parse(userDatabase.get('freeTrialStartDate'))).inDays > 1 ? 'EXPIRES IN ${freeTrialPromoDurationDays - DateTime.now().difference(DateTime.parse(userDatabase.get('freeTrialStartDate'))).inDays} DAYS' : (freeTrialPromoDurationDays * 24) - DateTime.now().difference(DateTime.parse(userDatabase.get('freeTrialStartDate'))).inHours > 1 ? 'EXPIRES IN UNDER ${(freeTrialPromoDurationDays * 24) - DateTime.now().difference(DateTime.parse(userDatabase.get('freeTrialStartDate'))).inHours} HOURS' : (freeTrialPromoDurationDays * 1440) - DateTime.now().difference(DateTime.parse(userDatabase.get('freeTrialStartDate'))).inMinutes > 0 ? 'EXPIRES IN LESS THAN ${(freeTrialPromoDurationDays * 1440) - DateTime.now().difference(DateTime.parse(userDatabase.get('freeTrialStartDate'))).inMinutes} MINUTES' : 'HAS EXPIRED'}'
                                                    .toUpperCase(),
                                                textAlign: TextAlign.center,
                                                style: Styles.regularStyle.copyWith(
                                                    color: altHighlightAccentColorDarkRed,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  orientation == Orientation.landscape || youtubeVideosList.isEmpty
                                      ? const SizedBox.shrink()
                                      : Stack(
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            Center(
                                              child: FadeIn(
                                                child: Image.asset(
                                                    'assets/congress_pic_$headerImageCounter.png',
                                                    height: 120,
                                                    width: MediaQuery.of(context).size.width,
                                                    fit: BoxFit.cover,
                                                    color: Theme.of(context).primaryColor,
                                                    colorBlendMode: darkTheme
                                                        ? BlendMode.color
                                                        : BlendMode.softLight),
                                              ),
                                            ),
                                            Container(
                                              height: 100,
                                              foregroundDecoration: BoxDecoration(
                                                border: Border(
                                                    left: BorderSide(
                                                        width: 2,
                                                        color: !userDatabase.get('newVideos')
                                                            ? Colors.transparent
                                                            : userDatabase.get('darkTheme')
                                                                ? alertIndicatorColorBrightGreen
                                                                : altHighlightColor)),
                                              ),
                                              child: ListView.builder(
                                                  primary: false,
                                                  physics: const BouncingScrollPhysics(),
                                                  controller: _videoListController,
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: youtubeVideosList
                                                      .length, // youTubePlaylist.length,
                                                  itemBuilder: (context, index) {
                                                    // final PlaylistItem thisVideo =
                                                    //     youTubePlaylist[index];
                                                    final ChannelVideos thisVideo =
                                                        youtubeVideosList[index];

                                                    return YouTubeVideosApi.videoTile(
                                                        context,
                                                        youtubeVideosList,
                                                        thisVideo,
                                                        index,
                                                        orientation,
                                                        interstitialAd,
                                                        randomImageActivated,
                                                        userLevels);
                                                  }),
                                            ),
                                          ],
                                        ),
                                  Expanded(
                                    child: ListView(
                                      shrinkWrap: true,
                                      primary: false,
                                      physics: const BouncingScrollPhysics(),
                                      children: [
                                        userInfo(memberSubs, billSubs, lobbySubs, otherSubs,
                                            subscriptionAlertsList),
                                        newsArticlesList.isEmpty
                                            ? const SizedBox.shrink()
                                            : newsArticleSlider(newsArticlesList),
                                        // houseFloorActions.isEmpty && senateFloorActions.isEmpty
                                        githubNotificationsList.isEmpty ||
                                                (currentHouseFloorActions.isEmpty &&
                                                    currentSenateFloorActions.isEmpty)
                                            ? const SizedBox.shrink()
                                            : floorActions(orientation),
                                        congressInfoButtons(subscriptionAlertsList),
                                        marketTrades(),
                                        userRepresentatives(orientation, subscriptionAlertsList),
                                        memberPublicStatements(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// RIGHT SIDE OF MAIN ROW
                            orientation == Orientation.portrait ||
                                    // youTubePlaylist.isEmpty ||
                                    youtubeVideosList.isEmpty
                                ? const SizedBox.shrink()
                                : Container(
                                    padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                                    width: MediaQuery.of(context).size.width * 2.5 / 6,
                                    child: Container(
                                      alignment: Alignment.topCenter,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.background,
                                        image: DecorationImage(
                                            opacity: 0.25,
                                            image: AssetImage(
                                                'assets/congress_pic_$headerImageCounter.png'),
                                            fit: BoxFit.cover,
                                            // repeat: ImageRepeat.repeat,
                                            colorFilter: ColorFilter.mode(
                                                Theme.of(context).colorScheme.background,
                                                BlendMode.color)),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.topLeft,
                                        children: [
                                          Column(
                                            children: [
                                              Expanded(
                                                child: SlideInUp(
                                                  animate: true,
                                                  duration: const Duration(milliseconds: 1000),
                                                  child: Container(
                                                    padding: const EdgeInsets.only(top: 2),
                                                    foregroundDecoration: BoxDecoration(
                                                      border: Border(
                                                          top: BorderSide(
                                                              width: 5,
                                                              color: !userDatabase.get('newVideos')
                                                                  ? Colors.transparent
                                                                  : altHighlightColor)),
                                                    ),
                                                    child: ListView.builder(
                                                        primary: false,
                                                        physics: const BouncingScrollPhysics(),
                                                        controller: _videoListController,
                                                        shrinkWrap: true,
                                                        itemCount: youtubeVideosList
                                                            .length, // youTubePlaylist.length,
                                                        itemBuilder: (context, index) {
                                                          final thisVideo =
                                                              youtubeVideosList[index];

                                                          return YouTubeVideosApi.videoTile(
                                                              context,
                                                              youtubeVideosList,
                                                              thisVideo,
                                                              index,
                                                              orientation,
                                                              interstitialAd,
                                                              randomImageActivated,
                                                              userLevels);
                                                        }),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                bottomSheet: bottomSheetContent(),
                bottomNavigationBar: BottomAppBar(
                  // color: Colors.transparent,
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        footerContent(orientation),
                        SharedWidgets.createdByContainer(context, userIsPremium, userDatabase),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  Future<void> homePageTextInput(
      BuildContext homeContext, Orientation orientation, String source, String titleText) async {
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
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Form(
                      key: formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType:
                                  source == 'zipCode' ? TextInputType.number : TextInputType.text,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Enter text'
                                  : (source == 'zipCode' && val.length > 5) ||
                                          val.length < 5 ||
                                          val.length > 13
                                      ? source == 'zipCode'
                                          ? 'Zip must be 5 digits'
                                          : source == 'userId'
                                              ? 'User must be 5 to 13 characters'
                                              : 'Must be more that 5 characters'
                                      : null,
                              onChanged: (val) =>
                                  setState(() => data = val.toLowerCase().replaceAll(' ', '')),
                            ),
                          ),
                          IconButton(
                              iconSize: 20,
                              onPressed: () async {
                                if (formKey.currentState.validate()) {
                                  Navigator.pop(context);
                                  if (source == 'zipCode') {
                                    await Functions.getUserCongress(
                                      homeContext,
                                      houseMembersList + senateMembersList,
                                      data,
                                    ).then((value) {
                                      setState(() => userCongressList = value);
                                    });
                                  } else if (source == 'userId') {
                                    List<String> currentUserIdList =
                                        List.from(userDatabase.get('userIdList'));
                                    if (!currentUserIdList.any(
                                        (element) => element.startsWith('$newUserIdPrefix$data'))) {
                                      currentUserIdList
                                          .add('$newUserIdPrefix$data<|:|>${DateTime.now()}');
                                    } else if (currentUserIdList.any(
                                        (element) => element.startsWith('$newUserIdPrefix$data'))) {
                                      int existingUserNameIndex = currentUserIdList.indexWhere(
                                          (element) => element.startsWith('$newUserIdPrefix$data'));

                                      String existingUserName =
                                          currentUserIdList.removeAt(existingUserNameIndex);

                                      // _currentUserIdList.removeWhere(
                                      //     (element) => element.startsWith(
                                      //         '$newUserIdPrefix$_data'));

                                      currentUserIdList.add(existingUserName);
                                    }
                                    userDatabase.put('userIdList', currentUserIdList);
                                  } else {
                                    logger.d('***** Nothing to Update *****');
                                  }
                                }
                              },
                              icon: const Icon(Icons.send))
                        ],
                      ),
                    ),
                  )
                ]),
          );
        }).then((_) async => await Functions.processCredits(true, isPermanent: false));
  }

  String membersSearchString = '';
  String stateString = '';

  Widget membersListContainer(List<ChamberMember> allMembersList, String chamber,
      {List<HouseStockWatch> houseStockWatchList, List<SenateStockWatch> senateStockWatchList}) {
    String shortTitle = chamber == 'Representatives' ? 'rep.' : 'sen.';
    List<ChamberMember> subscribedMembersList = [];
    List<ChamberMember> notSubscribedMembersList = [];
    List<ChamberMember> otherMembersList = [];

    for (var member in allMembersList) {
      if (List.from(userDatabase.get('subscriptionAlertsList')).any((element) =>
          element.toString().toLowerCase().startsWith('member_${member.id.toLowerCase()}'))) {
        subscribedMembersList.add(member);
      } else if (member.shortTitle.toLowerCase() == shortTitle) {
        notSubscribedMembersList.add(member);
      } else {
        otherMembersList.add(member);
      }
    }

    logger.d(
        '***** All Members List - Short Title: $shortTitle,  Count: ${allMembersList.length} *****');

    final List<ChamberMember> membersList =
        subscribedMembersList + notSubscribedMembersList + otherMembersList;

    // membersList.retainWhere((element) => element.inOffice);

    logger.d(
        '***** Members List - Short Title: $shortTitle\n Sub Count: ${subscribedMembersList.length}\n Not Sub Count: ${notSubscribedMembersList.length}\n Other Count: ${otherMembersList.length} *****');

    List<ChamberMember> allRepublicans = membersList
        .where((element) =>
            element.shortTitle.toLowerCase() == shortTitle.toLowerCase() &&
            element.party.toLowerCase() == 'r')
        .toList();
    List<ChamberMember> allDemocrats = membersList
        .where((element) =>
            element.shortTitle.toLowerCase() == shortTitle.toLowerCase() &&
            element.party.toLowerCase() == 'd')
        .toList();

    final Color thisPartyColor = allDemocrats.length > allRepublicans.length
        ? democratColor
        : allDemocrats.length < allRepublicans.length
            ? republicanColor
            : Theme.of(context).primaryColor;

    List<ChamberMember> finalMembersList = membersList;

    // return ValueListenableBuilder(
    //     valueListenable:
    //         Hive.box(appDatabase).listenable(keys: ['subscriptionAlertsList']),
    //     builder: (context, box, widget) {
    return StatefulBuilder(builder: (context, setState) {
      if (statesMap.entries.any((state) =>
          state.value.trim().toLowerCase().contains(membersSearchString.trim().toLowerCase()))) {
        stateString = statesMap.entries
            .where((element) => element.value
                .trim()
                .toLowerCase()
                .contains(membersSearchString.trim().toLowerCase()))
            .first
            .key
            .trim()
            .toLowerCase();
        // logger.d('***** State String: $stateString *****');
      }

      if (membersSearchString.isNotEmpty && stateString.isNotEmpty) {
        finalMembersList = membersList
            .where((member) =>
                member
                    .toJson()
                    .toString()
                    .toLowerCase()
                    .contains(membersSearchString.trim().toLowerCase()) ||
                member.state.trim().toLowerCase().contains(stateString.trim().toLowerCase()))
            .toList();
      } else if (membersSearchString.isNotEmpty && stateString.isEmpty) {
        finalMembersList = membersList
            .where((member) => member
                .toJson()
                .toString()
                .toLowerCase()
                .contains(membersSearchString.trim().toLowerCase()))
            .toList();
      } else if (membersSearchString.isEmpty && stateString.isEmpty) {
        finalMembersList = membersList;
      }
      List<ChamberMember> finalRepublicans =
          finalMembersList.where((element) => element.party.toLowerCase() == 'r').toList();
      List<ChamberMember> finalDemocrats =
          finalMembersList.where((element) => element.party.toLowerCase() == 'd').toList();
      List<ChamberMember> finalIndependents =
          finalMembersList.where((element) => element.party.toLowerCase() == 'id').toList();

      return BounceInUp(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            image: DecorationImage(
                opacity: 0.15,
                image: AssetImage('assets/congress_pic_${random.nextInt(4)}.png'),
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(Theme.of(context).colorScheme.background, BlendMode.color)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: thisPartyColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                          '${finalMembersList.where((element) => element.shortTitle.toLowerCase() == shortTitle.toLowerCase() && element.inOffice).length} $chamber',
                          style: GoogleFonts.bangers(color: Colors.white, fontSize: 25)),
                    ),
                    Text(
                        '${finalRepublicans.where((element) => element.shortTitle.toLowerCase() == shortTitle.toLowerCase() && element.inOffice).length} Rep | '
                        '${finalDemocrats.where((element) => element.shortTitle.toLowerCase() == shortTitle.toLowerCase() && element.inOffice).length} Dem | '
                        '${finalIndependents.where((element) => element.shortTitle.toLowerCase() == shortTitle.toLowerCase() && element.inOffice).length} Ind',
                        style: const TextStyle(
                            color: Color(0xffffffff), fontStyle: FontStyle.italic, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                // height: 30,
                // alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                color: thisPartyColor,

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: TextFormField(
                      autofocus: false,
                      onChanged: (val) => setState(() {
                        membersSearchString = val;
                        // logger.d('***** $membersSearchString *****');
                      }),
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        isCollapsed: true,
                        fillColor: const Color(0xaaffffff),
                        hintText: 'Search',
                        hintStyle: TextStyle(
                            fontSize: 14, color: thisPartyColor, fontWeight: FontWeight.bold),
                        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                        icon: const Icon(Icons.search, color: Color(0xffffffff), size: 20),
                      ),
                    )),
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    itemCount: finalMembersList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final thisMember = finalMembersList[index];
                      final String thisMemberImageUrl =
                          '${PropublicaApi().memberImageRootUrl}${thisMember.id}.jpg'.toLowerCase();
                      logger.d('**** Image Url: $thisMemberImageUrl *****');
                      final Color thisMemberColor = thisMember.party.toLowerCase() == 'd'
                          ? democratColor
                          : thisMember.party.toLowerCase() == 'r'
                              ? republicanColor
                              : independentColor;
                      return SharedWidgets.congressionalMemberCard(
                          thisMemberColor,
                          thisMemberImageUrl,
                          thisMember,
                          context,
                          index,
                          houseStockWatchList,
                          senateStockWatchList);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
    // });
  }

  Widget bottomSheetContent() {
    return appLoading
        ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            ),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width.toDouble(),
            height: 35,
            child: Text(appLoadingText,
                style: Styles.googleStyle.copyWith(fontSize: 18, color: darkThemeTextColor)))
        : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            ),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width.toDouble(),
            height: 35,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 22,
                      child: FlipInY(
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            enableFeedback: true,
                            backgroundColor: darkTheme
                                ? MaterialStateProperty.all<Color>(
                                    Theme.of(context).primaryColorDark)
                                : altHighlightMSPColor,
                          ),
                          icon: newEcwidProducts
                              ? AnimatedWidgets.flashingText(
                                  context, 'New!', newEcwidProducts, false,
                                  size: 13,
                                  color: darkTheme
                                      ? altHighlightColor
                                      : altHighlightAccentColorDarkRed,
                                  removeShadow: true)
                              : FaIcon(
                                  FontAwesomeIcons.store,
                                  size: 13,
                                  color: darkTheme
                                      ? darkThemeTextColor
                                      : altHighlightAccentColorDarkRed,
                                ),
                          label: Text('Shop Merch',
                              style: TextStyle(
                                  color: darkTheme
                                      ? darkThemeTextColor
                                      : altHighlightAccentColorDarkRed,
                                  fontWeight: FontWeight.bold)),
                          onPressed: ecwidProductsList.isEmpty
                              ? null
                              : () {
                                  userDatabase.put('newEcwidProducts', false);
                                  showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: false,
                                          enableDrag: true,
                                          context: context,
                                          builder: (context) {
                                            return SharedWidgets.ecwidProductsListing(
                                                context,
                                                interstitialAd,
                                                ecwidProductsList,
                                                userDatabase,
                                                userLevels,
                                                productOrdersList);
                                          })
                                      .then((_) => AdMobLibrary.interstitialAdShow(interstitialAd));
                                  // .then((_) => !userIsPremium &&
                                  //     interstitialAd != null &&
                                  //     interstitialAd.responseInfo.responseId !=
                                  //         userDatabase.get('interstitialAdId')
                                  // ? AdMobLibrary().interstitialAdShow(interstitialAd)
                                  // : null);
                                },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: SizedBox(
                      height: 22,
                      child: FlipInY(
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            enableFeedback: true,
                            backgroundColor: darkTheme
                                ? MaterialStateProperty.all<Color>(
                                    Theme.of(context).primaryColorDark)
                                : altHighlightMSPColor,
                          ),
                          icon: Icon(
                            Icons.volunteer_activism,
                            size: 15,
                            color: darkTheme ? darkThemeTextColor : altHighlightAccentColorDarkRed,
                          ),
                          label: Text('Support Options',
                              style: TextStyle(
                                  color: darkTheme
                                      ? darkThemeTextColor
                                      : altHighlightAccentColorDarkRed,
                                  fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: false,
                                enableDrag: true,
                                context: context,
                                builder: (context) {
                                  return SharedWidgets.supportOptions(
                                      context,
                                      interstitialAd,
                                      userDatabase,
                                      rewardedAd,
                                      userLevels,
                                      githubNotificationsList);
                                }).then((_) => AdMobLibrary.interstitialAdShow(interstitialAd));
                            // .then((_) => !userIsPremium &&
                            //     interstitialAd != null &&
                            //     interstitialAd.responseInfo.responseId !=
                            //         userDatabase.get('interstitialAdId')
                            // ? AdMobLibrary().interstitialAdShow(interstitialAd)
                            // : null);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget newsArticleSlider(List<NewsArticle> newsArticles) {
    // debugPrint('[HOME PAGE ARTICLE SLIDER] ${newsArticles.length} NEWS ARTICLES');
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
              color: darkTheme
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.background,
              image: DecorationImage(
                  opacity: darkTheme ? 0.4 : 0.25,
                  image: AssetImage(
                      'assets/congress_pic_${randomImageActivated ? random.nextInt(4) : headerImageCounter}.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      darkTheme
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.background,
                      BlendMode.color)),
              border: Border.all(
                  width: 1,
                  color: darkTheme
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.background),
              borderRadius: BorderRadius.circular(3)),
          child: Row(children: [
            // CircleAvatar(backgroundColor: Colors.purple),
            Expanded(
                child: ListView.builder(
                    controller: newsArticleSliderController,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: newsArticles.length,
                    itemBuilder: (context, index) {
                      NewsArticle thisArticle = newsArticles[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                        child: InkWell(
                            onTap: () => Functions.linkLaunch(
                                context, thisArticle.url, userDatabase, userIsPremium,
                                appBarTitle: thisArticle.source, interstitialAd: interstitialAd),
                            child: FadeInRight(
                              child: Container(
                                  // width: 190,
                                  constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
                                  padding: const EdgeInsets.all(5),
                                  // decoration: BoxDecoration(
                                  //     color: Theme.of(context)
                                  //         .colorScheme
                                  //         .background
                                  //         .withOpacity(0.5),
                                  //     // border: Border.all(width: 1),
                                  //     borderRadius: BorderRadius.circular(3),
                                  //     image: DecorationImage(
                                  //         opacity: 0.25,
                                  //         image: AssetImage(
                                  //             'assets/congress_pic_$headerImageCounter.png'),
                                  //         fit: BoxFit.cover,
                                  //         colorFilter: ColorFilter.mode(
                                  //             Theme.of(context).primaryColor,
                                  //             BlendMode.color))),
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.bottomLeft,
                                        children: [
                                          Container(
                                            width: 55,
                                            // height: 25,
                                            decoration: BoxDecoration(
                                              // shape: BoxShape.circle,
                                              // border: Border.all(width: 1),
                                              borderRadius: BorderRadius.circular(5),

                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/congress_pic_$headerImageCounter.png'),
                                                  fit: BoxFit.cover),
                                            ),
                                            foregroundDecoration: BoxDecoration(
                                              // shape: BoxShape.circle,
                                              border: Border.all(width: 1),
                                              borderRadius: BorderRadius.circular(5),

                                              image: DecorationImage(
                                                  image: NetworkImage(thisArticle.imageUrl),
                                                  fit: BoxFit.cover),
                                            ),
                                            // child: FadeInImage(
                                            //     width: 45,
                                            //     height: 35,
                                            //     placeholder: AssetImage(
                                            //         'assets/congress_pic_$headerImageCounter.png'),
                                            //     image: NetworkImage(
                                            //         thisArticle.imageUrl),
                                            //     fit: BoxFit.cover),
                                          ),
                                          // CircleAvatar(
                                          //   backgroundColor: darkTheme
                                          //       ? alertIndicatorColorBrightGreen
                                          //       : altHighlightColor,
                                          //   radius: 5,
                                          // )
                                        ],
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              thisArticle.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Styles.regularStyle.copyWith(
                                                  fontSize: 12,
                                                  color: darkTheme ? darkThemeTextColor : null,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${thisArticle.source} ${dateWithDayFormatter.format(DateTime.parse(thisArticle.date))}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Styles.regularStyle.copyWith(
                                                  fontSize: 9,
                                                  color: darkTheme
                                                      ? darkThemeTextColor.withOpacity(0.85)
                                                      : null,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            )),
                      );
                    })),
          ]),
        ));
  }

  Widget userInfo(List<String> memberSubs, List<String> billSubs, List<String> lobbySubs,
      List<String> otherSubs, List<String> subscriptionAlertsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 5),
              (!userIsPremium && !userIsLegacy) ||
                      (memberSubs.isEmpty &&
                          billSubs.isEmpty &&
                          lobbySubs.isEmpty &&
                          otherSubs.isEmpty)
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 22,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(
                                  // darkTheme
                                  //     ? null
                                  //     :
                                  Theme.of(context).primaryColorDark.withOpacity(0.5))),
                              icon: AnimatedWidgets.flashingEye(
                                  context,
                                  memberSubs.isNotEmpty ||
                                      billSubs.isNotEmpty ||
                                      lobbySubs.isNotEmpty ||
                                      otherSubs.isNotEmpty,
                                  false,
                                  animate: false,
                                  size: 9),
                              label: Text(
                                  'Watching ${memberSubs.length} Members | ${billSubs.length} Bills | ${lobbySubs.length} Lobbies | ${otherSubs.length} Other Items'
                                      .toUpperCase(),
                                  style: Styles.regularStyle.copyWith(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: darkTheme
                                          ? darkThemeTextColor
                                          : Theme.of(context).primaryColorDark)),
                              // label: Text(
                              //     ' 🧑🏽‍💼  ${memberSubs.length}   📜  ${billSubs.length}   💰  ${lobbySubs.length}' //   ✍🏽  ${otherSubs.length}'
                              //         .toUpperCase(),
                              //     style: Styles.regularStyle.copyWith(
                              //         fontSize: 11,
                              //         fontWeight: FontWeight.bold,
                              //         color: darkTheme
                              //             ? darkThemeTextColor
                              //             : Theme.of(context)
                              //                 .primaryColorDark)),
                              onPressed: (subscriptionAlertsList.any((element) =>
                                              element.toString().startsWith('member_')) &&
                                          (houseMembersList.isEmpty ||
                                              senateMembersList.isEmpty)) ||
                                      (subscriptionAlertsList.any((element) =>
                                              element.toString().startsWith('lobby_')) &&
                                          lobbyingEventsList.isEmpty) ||
                                      (subscriptionAlertsList.any((element) =>
                                              element.toString().startsWith('bill_')) &&
                                          billList.isEmpty)
                                  ? null
                                  : () => showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: false,
                                      enableDrag: true,
                                      context: context,
                                      builder: (context) {
                                        return SharedWidgets.subscriptionsList(
                                            context,
                                            userDatabase,
                                            senateMembersList + houseMembersList,
                                            billList,
                                            lobbyingEventsList,
                                            houseStockWatchList,
                                            senateStockWatchList);
                                      }),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget marketTrades() {
    String buyIndicator = '🟢 ';
    String sellIndicator = '🔴 ';

    return !userIsPremium && freeTrialUsed
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !userIsPremium
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: InkWell(
                          onTap: () async => Functions.requestInAppPurchase(
                              context, interstitialAd, userIsPremium,
                              whatToShow: 'upgrades'),
                          child: BounceInDown(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      opacity: 0.15,
                                      image: AssetImage(
                                          'assets/stock${randomImageActivated ? random.nextInt(3) : headerImageCounter}.png'),
                                      fit: BoxFit.cover,
                                      colorFilter:
                                          const ColorFilter.mode(Colors.grey, BlendMode.color)),
                                  color: Colors.grey,
                                  border: Border.all(width: 2, color: Colors.grey[600]),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text('GET LATEST CONGRESSIONAL MEMBER MARKET TRADES',
                                  style: Styles.googleStyle.copyWith(
                                      fontSize: 18,
                                      color: darkTheme
                                          ? Theme.of(context).primaryColorDark
                                          : darkThemeTextColor)),
                            ),
                          )))
                  : houseStockWatchList.isEmpty && senateStockWatchList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          child: InkWell(
                              onTap: () => getData(),
                              child: ZoomIn(
                                child: Column(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              opacity: 0.15,
                                              image: AssetImage(
                                                  'assets/stock${random.nextInt(3)}.png'),
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(
                                                  darkTheme
                                                      ? Theme.of(context).primaryColorDark
                                                      : stockWatchColor,
                                                  BlendMode.color)),
                                          color: darkTheme
                                              ? Theme.of(context).primaryColorDark
                                              : stockWatchColor,
                                          border: Border.all(
                                              width: 2,
                                              color: darkTheme
                                                  ? Theme.of(context).primaryColorDark
                                                  : stockWatchColor),
                                          borderRadius: BorderRadius.circular(5)),
                                      child: Text('TAP HERE TO REFRESH MARKET TRADE DATA',
                                          style: Styles.googleStyle
                                              .copyWith(fontSize: 18, color: darkThemeTextColor)),
                                    ),
                                    dataRefresh
                                        ? const LinearProgressIndicator(color: stockWatchColor)
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              )))
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                child: Text('LATEST MARKET TRADES BY CHAMBER (Reported)',
                                    style: Styles.googleStyle.copyWith(fontSize: 18)),
                              ),
                              Row(
                                children: [
                                  senateStockWatchList.isEmpty
                                      ? const SizedBox.shrink()
                                      : Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              userDatabase.put('newSenateStock', false);
                                              showModalBottomSheet(
                                                  backgroundColor: Colors.transparent,
                                                  isScrollControlled: false,
                                                  enableDrag: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return SharedWidgets.stockWatchList(
                                                      context,
                                                      false,
                                                      userDatabase,
                                                      houseStockWatchList,
                                                      senateStockWatchList,
                                                      senateMembersList + houseMembersList,
                                                      userIsPremium,
                                                    );
                                                  });

                                              // userDatabase.put(
                                              //     'newSenateStock', false);
                                            },
                                            child: SlideInRight(
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            opacity: 0.4,
                                                            image: AssetImage(
                                                                'assets/stock${randomImageActivated ? random.nextInt(3) : 0}.png'),
                                                            fit: BoxFit.cover,
                                                            colorFilter: ColorFilter.mode(
                                                                darkTheme
                                                                    ? Theme.of(context)
                                                                        .primaryColorDark
                                                                    : stockWatchColor,
                                                                BlendMode.color)),
                                                        color: darkTheme
                                                            ? Theme.of(context).primaryColorDark
                                                            : stockWatchColor,
                                                        border: Border.all(
                                                            width: 2,
                                                            color: darkTheme
                                                                ? Theme.of(context).primaryColorDark
                                                                : stockWatchColor),
                                                        borderRadius: BorderRadius.circular(3)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: FadeInRight(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                'Sen. ${senateStockWatchList.first.senator}',
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: Styles.regularStyle.copyWith(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: darkThemeTextColor)),
                                                            Text(
                                                              'Exec. ${dateWithDayAndYearFormatter.format(senateStockWatchList.first.transactionDate)}',
                                                              style: Styles.regularStyle.copyWith(
                                                                  fontSize: 11,
                                                                  fontWeight: FontWeight.normal,
                                                                  color: darkThemeTextColor),
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment.center,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    '${senateStockWatchList.first.type == null || senateStockWatchList.first.type == 'N/A' ? '' : senateStockWatchList.first.type.toLowerCase().contains('sale') ? sellIndicator : senateStockWatchList.first.type.toLowerCase().contains('purchase') ? buyIndicator : ''} ${senateStockWatchList.first.ticker == null || senateStockWatchList.first.ticker == '--' || senateStockWatchList.first.ticker == 'N/A' ? senateStockWatchList.first.assetType : '\$${senateStockWatchList.first.ticker}'}',
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: Styles.regularStyle
                                                                        .copyWith(
                                                                            fontSize: 12,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            color:
                                                                                darkThemeTextColor),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: userDatabase.get('newSenateStock')
                                                        ? AnimatedWidgets.flashingText(
                                                            context,
                                                            '!!!',
                                                            userDatabase.get('newSenateStock'),
                                                            false,
                                                            size: 14,
                                                            color: darkTheme
                                                                ? altHighlightColor
                                                                : darkThemeTextColor)
                                                        : FaIcon(Icons.more_vert,
                                                            size: 14,
                                                            color:
                                                                userDatabase.get('newSenateStock')
                                                                    ? altHighlightColor
                                                                    : darkThemeTextColor),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  houseStockWatchList.isEmpty || senateStockWatchList.isEmpty
                                      ? const SizedBox.shrink()
                                      : const SizedBox(width: 5),
                                  houseStockWatchList.isEmpty
                                      ? const SizedBox.shrink()
                                      : Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              userDatabase.put('newHouseStock', false);
                                              showModalBottomSheet(
                                                  backgroundColor: Colors.transparent,
                                                  isScrollControlled: false,
                                                  enableDrag: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return SharedWidgets.stockWatchList(
                                                        context,
                                                        true,
                                                        userDatabase,
                                                        houseStockWatchList,
                                                        senateStockWatchList,
                                                        senateMembersList + houseMembersList,
                                                        userIsPremium);
                                                  });

                                              // userDatabase.put(
                                              //     'newHouseStock', false);
                                            },
                                            child: SlideInRight(
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            opacity: 0.4,
                                                            image: AssetImage(
                                                                'assets/stock${randomImageActivated ? random.nextInt(3) : 2}.png'),
                                                            fit: BoxFit.cover,
                                                            colorFilter: ColorFilter.mode(
                                                                darkTheme
                                                                    ? Theme.of(context)
                                                                        .primaryColorDark
                                                                    : stockWatchColor,
                                                                BlendMode.color)),
                                                        color: darkTheme
                                                            ? Theme.of(context).primaryColorDark
                                                            : stockWatchColor,
                                                        border: Border.all(
                                                            width: 2,
                                                            color: darkTheme
                                                                ? Theme.of(context).primaryColorDark
                                                                : stockWatchColor),
                                                        borderRadius: BorderRadius.circular(3)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: FadeInRight(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                houseStockWatchList
                                                                    .first.representative,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: Styles.regularStyle.copyWith(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: darkThemeTextColor)),
                                                            Text(
                                                              'Exec. ${dateWithDayAndYearFormatter.format(houseStockWatchList.first.transactionDate)}',
                                                              style: Styles.regularStyle.copyWith(
                                                                  fontSize: 11,
                                                                  fontWeight: FontWeight.normal,
                                                                  color: darkThemeTextColor),
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment.center,
                                                              // mainAxisAlignment:
                                                              //     MainAxisAlignment
                                                              //         .center,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    '${houseStockWatchList.first.type == null || houseStockWatchList.first.type == '--' ? '' : houseStockWatchList.first.type.toLowerCase().contains('sale') ? sellIndicator : houseStockWatchList.first.type.toLowerCase().contains('purchase') ? buyIndicator : ''} ${houseStockWatchList.first.ticker == null || houseStockWatchList.first.ticker == 'N/A' || houseStockWatchList.first.ticker == '--' ? houseStockWatchList.first.assetDescription.replaceAll(RegExp(r'<(.*)>'), '') : '\$${houseStockWatchList.first.ticker}'}',
                                                                    // textAlign:
                                                                    //     TextAlign
                                                                    //         .center,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: Styles.regularStyle
                                                                        .copyWith(
                                                                            fontSize: 12,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            color:
                                                                                darkThemeTextColor),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: userDatabase.get('newHouseStock')
                                                        ? AnimatedWidgets.flashingText(
                                                            context,
                                                            '!!!',
                                                            userDatabase.get('newHouseStock'),
                                                            false,
                                                            size: 14,
                                                            color: darkTheme
                                                                ? altHighlightColor
                                                                : darkThemeTextColor)
                                                        : FaIcon(Icons.more_vert,
                                                            size: 14,
                                                            color: userDatabase.get('newHouseStock')
                                                                ? altHighlightColor
                                                                : darkThemeTextColor),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              FlipInY(
                                child: InkWell(
                                  onTap: (houseStockWatchList.isEmpty &&
                                          senateStockWatchList.isEmpty)
                                      ? null
                                      : () {
                                          setState(() => _marketPageLoading = true);
                                          userDatabase.put('newMarketOverview', false);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => MarketActivityPage(
                                                      houseMembersList + senateMembersList,
                                                      houseStockWatchList,
                                                      senateStockWatchList,
                                                      marketActivityOverviewList))).then(
                                              (_) => setState(() => _marketPageLoading = false));
                                        },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: darkTheme
                                            ? Theme.of(context).primaryColorDark
                                            : stockWatchColor,
                                        image: DecorationImage(
                                            opacity: 0.4,
                                            image: AssetImage(
                                                'assets/stock${randomImageActivated ? random.nextInt(3) : 1}.png'),
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                                darkTheme
                                                    ? Theme.of(context).primaryColorDark
                                                    : stockWatchColor,
                                                BlendMode.color)),
                                        border: Border.all(
                                            width: 2,
                                            color: darkTheme
                                                ? Theme.of(context).primaryColorDark
                                                : stockWatchColor),
                                        borderRadius: BorderRadius.circular(3)),
                                    child: TextButton.icon(
                                      icon:
                                      // userDatabase.get('newMarketOverview')
                                      //     ? AnimatedWidgets.flashingText(context, '!!!',
                                      //         userDatabase.get('newMarketOverview'), false,
                                      //         size: 13,
                                      //         color: userDatabase.get('newSenateStock')
                                      //             ? altHighlightColor
                                      //             : darkThemeTextColor,
                                      //         sameColor: true)
                                      //     :
                                      _marketPageLoading
                                              ? const FaIcon(
                                                  FontAwesomeIcons.solidHourglass,
                                                  size: 11,
                                                  color: darkThemeTextColor,
                                                )
                                              : const FaIcon(
                                                  FontAwesomeIcons.chartSimple,
                                                  size: 13,
                                                  color: darkThemeTextColor,
                                                ),
                                      label: Text(
                                          _marketPageLoading
                                              ? 'Loading Latest Market Data...'
                                              : 'Stock Market Activity Overview',
                                          style: Styles.regularStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: darkThemeTextColor)),
                                      onPressed: null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ],
          );
  }

  Widget floorActions(Orientation orientation) {
    logger.d(
        '[FLOOR ACTIONS WIDGET]\nHouse Date: ${currentHouseFloorActionsDate.toString()}\nSenate Date: ${currentSenateFloorActionsDate.toString()}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
          child: (currentHouseFloorActions.isNotEmpty &&
                      currentHouseFloorActionsDate
                          .isBefore(DateTime.now().subtract(const Duration(hours: 36)))) &&
                  (currentSenateFloorActions.isNotEmpty &&
                      currentSenateFloorActionsDate
                          .isBefore(DateTime.now().subtract(const Duration(hours: 36))))
              ? const SizedBox.shrink()
              : Text('Latest Floor Actions', style: GoogleFonts.bangers(fontSize: 18)),
        ),
        currentHouseFloorActions.isNotEmpty &&
                currentHouseFloorActionsDate
                    .isBefore(DateTime.now().subtract(const Duration(hours: 36)))
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                width: orientation == Orientation.landscape
                    ? MediaQuery.of(context).size.width * 0.58333
                    : MediaQuery.of(context).size.width,
                height: 75,
                child: houseFloorLoading ||
                        currentHouseFloorActions == null ||
                        currentHouseFloorActions.isEmpty
                    ? AnimatedWidgets.circularProgressWatchtower(
                        context, userDatabase, userIsPremium,
                        widthAndHeight: 20, strokeWidth: 3, isFullScreen: false)
                    : BounceInRight(
                        from: 75,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 2.5),
                              child: RotatedBox(
                                  quarterTurns: -1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                                    decoration: BoxDecoration(
                                        color: userDatabase.get('newHouseFloor')
                                            ? Theme.of(context).primaryColorDark
                                            : Theme.of(context).highlightColor.withOpacity(0.125),
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'HOUSE',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: userDatabase.get('newHouseFloor')
                                                  ? userDatabase.get('darkTheme')
                                                      ? alertIndicatorColorBrightGreen
                                                      : darkThemeTextColor
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: currentHouseFloorActions.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                              backgroundColor: Colors.transparent,
                                              isScrollControlled: false,
                                              enableDrag: true,
                                              context: context,
                                              builder: (context) => SharedWidgets.floorActionsList(
                                                  context,
                                                  'House',
                                                  currentHouseFloorActions,
                                                  userDatabase,
                                                  houseStockWatchList,
                                                  senateStockWatchList)).then((_) =>
                                              AdMobLibrary.interstitialAdShow(interstitialAd));
                                          // .then((_) => !userIsPremium &&
                                          //     interstitialAd != null &&
                                          //     interstitialAd.responseInfo.responseId !=
                                          //         userDatabase.get('interstitialAdId')
                                          // ? AdMobLibrary().interstitialAdShow(interstitialAd)
                                          // : null);

                                          userDatabase.put('newHouseFloor', false);
                                        },
                                        // onHorizontalDragEnd: (swipe) =>
                                        //     userDatabase.put('newHouseFloor', false),
                                        child: Container(
                                          width: orientation == Orientation.landscape
                                              ? MediaQuery.of(context).size.width * 0.5
                                              : MediaQuery.of(context).size.width * 0.85,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).highlightColor.withOpacity(0.125),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      currentHouseFloorActions[index].header == '--'
                                                          ? dateWithTimeOnlyFormatter.format(
                                                              DateFormat('EEE, dd MMM yyyy h:mm:ss')
                                                                  .parse(currentHouseFloorActions[
                                                                          index]
                                                                      .actionTimeStamp)
                                                                  .toLocal())
                                                          : currentHouseFloorActions[index]
                                                              .header
                                                              .toUpperCase(),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Flexible(
                                                child: Text(
                                                  currentHouseFloorActions[index].actionItem,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
              ),
        // const SizedBox(height: 5),
        currentSenateFloorActions.isNotEmpty &&
                currentSenateFloorActionsDate
                    .isBefore(DateTime.now().subtract(const Duration(hours: 36)))
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                width: orientation == Orientation.landscape
                    ? MediaQuery.of(context).size.width * 0.58333
                    : MediaQuery.of(context).size.width,
                height: 75,
                child: senateFloorLoading ||
                        currentSenateFloorActions == null ||
                        currentSenateFloorActions.isEmpty
                    ? AnimatedWidgets.circularProgressWatchtower(
                        context, userDatabase, userIsPremium,
                        widthAndHeight: 20, strokeWidth: 3, isFullScreen: false)
                    : BounceInRight(
                        from: 75,
                        delay: const Duration(milliseconds: 300),
                        child: Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 2.5),
                                  child: RotatedBox(
                                    quarterTurns: -1,
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                                      decoration: BoxDecoration(
                                          color: userDatabase.get('newSenateFloor')
                                              ? Theme.of(context).primaryColorDark
                                              : Theme.of(context).highlightColor.withOpacity(0.125),
                                          borderRadius: BorderRadius.circular(3)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'SENATE',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: userDatabase.get('newSenateFloor')
                                                    ? userDatabase.get('darkTheme')
                                                        ? alertIndicatorColorBrightGreen
                                                        : darkThemeTextColor
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: currentSenateFloorActions.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 5),
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  backgroundColor: Colors.transparent,
                                                  isScrollControlled: false,
                                                  enableDrag: true,
                                                  context: context,
                                                  builder: (context) =>
                                                      SharedWidgets.floorActionsList(
                                                          context,
                                                          'Senate',
                                                          currentSenateFloorActions,
                                                          userDatabase,
                                                          houseStockWatchList,
                                                          senateStockWatchList)).then((_) =>
                                                  AdMobLibrary.interstitialAdShow(interstitialAd));
                                              // .then((_) => !userIsPremium &&
                                              //     interstitialAd != null &&
                                              //     interstitialAd.responseInfo.responseId !=
                                              //         userDatabase.get('interstitialAdId')
                                              // ? AdMobLibrary().interstitialAdShow(interstitialAd)
                                              // : null);

                                              userDatabase.put('newSenateFloor', false);
                                            },
                                            // onHorizontalDragEnd: (swipe) =>
                                            //     userDatabase.put('newSenateFloor', false),
                                            child: Container(
                                              width: orientation == Orientation.landscape
                                                  ? MediaQuery.of(context).size.width * 0.5
                                                  : MediaQuery.of(context).size.width * 0.85,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .highlightColor
                                                    .withOpacity(0.125),
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          currentSenateFloorActions[index]
                                                                      .actionTimeStamp ==
                                                                  '--'
                                                              ? currentSenateFloorActions[index]
                                                                  .header
                                                                  .toUpperCase()
                                                              : dateWithTimeFormatter.format(
                                                                  DateFormat(
                                                                          'EEE, dd MMM yyyy h:mm:ss')
                                                                      .parse(
                                                                          currentSenateFloorActions[
                                                                                  index]
                                                                              .actionTimeStamp)
                                                                      .toLocal()),
                                                          // dateWithTimeFormatter.format(
                                                          //     senateFloorActions[index]
                                                          //         .timestamp
                                                          //         .toLocal()),
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Flexible(
                                                    child: Text(
                                                      currentSenateFloorActions[index].actionItem,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
      ],
    );
  }

  Widget congressInfoButtons(List<String> subscriptionAlertsList) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: SizedBox(
          height: 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FlipInY(
                  child: ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Theme.of(context).primaryColorDark)),
                      onPressed: billList == null || billList.isEmpty
                          ? null
                          : () async {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: false,
                                  enableDrag: true,
                                  context: context,
                                  builder: (context) {
                                    return SharedWidgets.recentBillsList(context, userDatabase,
                                        billList, houseStockWatchList, senateStockWatchList);
                                  }).then((_) => AdMobLibrary.interstitialAdShow(interstitialAd));
                              // .then((_) => !userIsPremium &&
                              //     interstitialAd != null &&
                              //     interstitialAd.responseInfo.responseId !=
                              //         userDatabase.get('interstitialAdId')
                              // ? AdMobLibrary().interstitialAdShow(interstitialAd)
                              // : null);

                              userDatabase.put('newBills', false);
                              await Functions.processCredits(true, isPermanent: false);
                            },
                      icon: userDatabase.get('newBills')
                          ? AnimatedWidgets.flashingText(
                              context, '!!!', userDatabase.get('newBills'), false,
                              size: 13, sameColor: true)
                          : const FaIcon(FontAwesomeIcons.scroll,
                              color: darkThemeTextColor, size: 12.5),
                      label:
                          const Text('Recent Bills', style: TextStyle(color: darkThemeTextColor))),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: FlipInY(
                  child: ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Theme.of(context).primaryColorDark)),
                      onPressed: voteList.isEmpty
                          ? null
                          : () async {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: false,
                                  enableDrag: true,
                                  context: context,
                                  builder: (context) {
                                    return SharedWidgets.recentVotesList(
                                        context,
                                        userDatabase,
                                        userIsPremium,
                                        voteList,
                                        houseStockWatchList,
                                        senateStockWatchList);
                                  }).then((_) => AdMobLibrary.interstitialAdShow(interstitialAd));
                              // .then((_) => !userIsPremium &&
                              //     interstitialAd != null &&
                              //     interstitialAd.responseInfo.responseId !=
                              //         userDatabase.get('interstitialAdId')
                              // ? AdMobLibrary().interstitialAdShow(interstitialAd)
                              // : null);

                              userDatabase.put('newVotes', false);
                              await Functions.processCredits(true, isPermanent: false);
                            },
                      icon: userDatabase.get('newVotes')
                          ? AnimatedWidgets.flashingText(
                              context, '!!!', userDatabase.get('newVotes'), false,
                              size: 13, sameColor: true)
                          : const FaIcon(FontAwesomeIcons.gavel,
                              color: darkThemeTextColor, size: 13),
                      label:
                          const Text('Recent Votes', style: TextStyle(color: darkThemeTextColor))),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: SizedBox(
          height: 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FlipInY(
                  child: ElevatedButton.icon(
                      style: ButtonStyle(
                          enableFeedback: true,
                          backgroundColor: darkTheme
                              ? primaryMSPColorDark
                              : senateRepublicansList.length > senateDemocratsList.length
                                  ? republicanMSPColor
                                  : senateRepublicansList.length < senateDemocratsList.length
                                      ? democratMSPColor
                                      : null),
                      onPressed: senateMembersList.isEmpty
                          ? null
                          : () async {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: false,
                                  enableDrag: true,
                                  context: context,
                                  builder: (context) {
                                    return membersListContainer(senateMembersList, 'Senators',
                                        houseStockWatchList: houseStockWatchList,
                                        senateStockWatchList: senateStockWatchList);
                                  }).then((_) {
                                Functions.processCredits(true, isPermanent: false);
                                AdMobLibrary.interstitialAdShow(interstitialAd);
                              }).whenComplete(() => setState(() => membersSearchString = ''));
                            },
                      icon: loadingSenators
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                color: republicanColor,
                                backgroundColor: democratColor,
                              ),
                            )
                          : const FaIcon(FontAwesomeIcons.peopleGroup,
                              size: 13, color: Color(0xffffffff)),
                      label: const Text('Senators', style: TextStyle(color: Color(0xffffffff)))),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: FlipInY(
                  child: ElevatedButton.icon(
                    icon: loadingRepresentatives
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: republicanColor,
                              backgroundColor: democratColor,
                            ),
                          )
                        : const FaIcon(FontAwesomeIcons.peopleGroup,
                            size: 13, color: Color(0xffffffff)),
                    label:
                        const Text('Representatives', style: TextStyle(color: Color(0xffffffff))),
                    style: ButtonStyle(
                        enableFeedback: true,
                        backgroundColor: darkTheme
                            ? primaryMSPColorDark
                            : houseRepublicansList.length > houseDemocratsList.length
                                ? republicanMSPColor
                                : houseRepublicansList.length < houseDemocratsList.length
                                    ? democratMSPColor
                                    : null),
                    onPressed: houseMembersList.isEmpty
                        ? null
                        : () async {
                            showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: false,
                                enableDrag: true,
                                context: context,
                                builder: (context) {
                                  return membersListContainer(houseMembersList, 'Representatives',
                                      houseStockWatchList: houseStockWatchList,
                                      senateStockWatchList: senateStockWatchList);
                                }).then((value) {
                              Functions.processCredits(true, isPermanent: false);
                              AdMobLibrary.interstitialAdShow(interstitialAd);
                            }).whenComplete(() => setState(() => membersSearchString = ''));
                          },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      !userIsPremium && freeTrialUsed
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: SizedBox(
                height: 30,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FlipInY(
                        child: ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: !userIsPremium && !userIsLegacy
                                  ? disabledMSPColorGray
                                  : darkTheme
                                      ? primaryMSPColorDark
                                      : lobbyingEventsList.isEmpty
                                          ? disabledMSPColorGray
                                          : alertIndicatorMSPColorDarkGreen,
                            ),
                            icon: (userIsPremium || userIsLegacy) && userDatabase.get('newLobbies')
                                ? AnimatedWidgets.flashingText(
                                    context, '!!!', userDatabase.get('newLobbies'), false,
                                    size: 13, sameColor: true)
                                : FaIcon(
                                    FontAwesomeIcons.moneyBills,
                                    size: 13,
                                    color:
                                        userIsPremium || userIsLegacy ? darkThemeTextColor : null,
                                  ),
                            label: Text('Lobbying',
                                style: TextStyle(
                                  color: userIsPremium || userIsLegacy ? darkThemeTextColor : null,
                                )),
                            onPressed: !userIsPremium && !userIsLegacy
                                ? () async => Functions.requestInAppPurchase(
                                    context, interstitialAd, userIsPremium,
                                    whatToShow: 'upgrades')
                                : lobbyingEventsList.isEmpty
                                    ? null
                                    : () async {
                                        showModalBottomSheet(
                                                backgroundColor: Colors.transparent,
                                                isScrollControlled: false,
                                                enableDrag: true,
                                                context: context,
                                                builder: (context) {
                                                  return SharedWidgets.lobbyingList(
                                                    context,
                                                    userDatabase,
                                                    lobbyingEventsList,
                                                  );
                                                })
                                            .then((_) =>
                                                AdMobLibrary.interstitialAdShow(interstitialAd));
                                        // .then((_) => !userIsPremium &&
                                        //     interstitialAd != null &&
                                        //     interstitialAd.responseInfo.responseId !=
                                        //         userDatabase.get('interstitialAdId')
                                        // ? AdMobLibrary().interstitialAdShow(interstitialAd)
                                        // : null);

                                        userDatabase.put('newLobbies', false);
                                        await Functions.processCredits(true, isPermanent: false);
                                      }),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FlipInY(
                              child: ElevatedButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: !userIsPremium && !userIsLegacy
                                        ? disabledMSPColorGray
                                        : darkTheme
                                            ? primaryMSPColorDark
                                            : privatelyFundedTripsList.isEmpty
                                                ? disabledMSPColorGray
                                                : MaterialStateProperty.all<Color>(
                                                    const Color.fromARGB(255, 0, 80, 100)),
                                  ),
                                  icon: (userIsPremium || userIsLegacy) &&
                                          userDatabase.get('newTrips')
                                      ? AnimatedWidgets.flashingText(
                                          context, '!!!', userDatabase.get('newTrips'), false,
                                          size: 13, sameColor: true)
                                      : FaIcon(
                                          FontAwesomeIcons.planeDeparture,
                                          size: 13,
                                          color: userIsPremium || userIsLegacy
                                              ? darkThemeTextColor
                                              : null,
                                        ),
                                  label: Text('Funded Travel',
                                      style: TextStyle(
                                        color: userIsPremium || userIsLegacy
                                            ? darkThemeTextColor
                                            : null,
                                      )),
                                  onPressed: !userIsPremium && !userIsLegacy
                                      ? () async => Functions.requestInAppPurchase(
                                          context, interstitialAd, userIsPremium,
                                          whatToShow: 'upgrades')
                                      : privatelyFundedTripsList.isEmpty
                                          ? null
                                          : () async {
                                              showModalBottomSheet(
                                                  backgroundColor: Colors.transparent,
                                                  isScrollControlled: false,
                                                  enableDrag: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return SharedWidgets.privateFundedTripsList(
                                                        context,
                                                        userDatabase,
                                                        privatelyFundedTripsList,
                                                        senateMembersList + houseMembersList,
                                                        houseStockWatchList,
                                                        senateStockWatchList,
                                                        userIsPremium);
                                                  });

                                              userDatabase.put('newTrips', false);
                                              await Functions.processCredits(true,
                                                  isPermanent: false);
                                            }),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    ]);
  }

  Widget userRepresentatives(Orientation orientation, List<String> subscriptionAlertsList) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      userCongressList.isEmpty || userDatabase.get('usageInfo') == false
          ? ZoomIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    child:
                        Text('FIND YOUR REPRESENTATIVES', style: GoogleFonts.bangers(fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: SizedBox(
                      height: 30,
                      child: userDatabase.get('usageInfo') == false ||
                              /* (!userIsPremium &&
                                                                !userIsLegacy) ||*/
                              (!statesMap.keys.contains(Map<String, dynamic>.from(
                                      userDatabase.get('currentAddress'))['state']) &&
                                  !statesMap.keys.contains(Map<String, dynamic>.from(
                                      userDatabase.get('representativesLocation'))['state']))
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: ElevatedButton.icon(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(
                                              Theme.of(context).primaryColorDark)),
                                      label: const Text('Enter Zip',
                                          style: TextStyle(color: darkThemeTextColor)),
                                      icon: const FaIcon(FontAwesomeIcons.solidCompass,
                                          size: 13, color: darkThemeTextColor),
                                      onPressed: () async =>
                                          await Functions.requestUsageInfo(context)),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: ElevatedButton.icon(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(
                                              Theme.of(context).primaryColorDark)),
                                      label: const Text('Enter Zip',
                                          style: TextStyle(color: darkThemeTextColor)),
                                      icon: const Icon(Icons.location_pin,
                                          size: 15, color: darkThemeTextColor),
                                      onPressed: () {
                                        return homePageTextInput(context, orientation, 'zipCode',
                                            'Enter your 5 digit U.S. Zip Code');
                                      }),
                                ),
                                Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    ElevatedButton.icon(
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(
                                                Theme.of(context).primaryColorDark)),
                                        label: Text(
                                            'Use ${Map<String, dynamic>.from(userDatabase.get('currentAddress'))['zip']}',
                                            style: const TextStyle(color: darkThemeTextColor)),
                                        icon: const Icon(Icons.location_searching,
                                            size: 15, color: darkThemeTextColor),
                                        onPressed: () async {
                                          String zip = Map<String, dynamic>.from(
                                              userDatabase.get('currentAddress'))['zip'];
                                          logger.d(
                                              '***** DBase update to $zip will happen here. *****');
                                          await Functions.getUserCongress(context,
                                                  houseMembersList + senateMembersList, zip)
                                              .then((value) {
                                            setState(() => userCongressList = value);
                                          });
                                          Functions.processCredits(true,
                                              isPurchased: false, isPermanent: false);
                                        }),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  )
                ],
              ),
            )
          : ZoomIn(
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                decoration: const BoxDecoration(
                    // color: Theme.of(context).accentColor,
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 2, 10, 2),
                      child: Row(
                        children: [
                          Text(
                              'REPRESENTATIVES FOR ZIP CODE ${Map<String, dynamic>.from(userDatabase.get('representativesLocation'))['zip']}',
                              style: GoogleFonts.bangers(fontSize: 18)),
                          const Spacer(),
                          SizedBox(
                            height: 20,
                            child: OutlinedButton(
                                child: const Text('Update Zip', style: TextStyle(fontSize: 10)),
                                onPressed: () {
                                  setState(() => userCongressList = []);
                                  userDatabase.put('representativesLocation',
                                      initialUserData['representativesLocation']);
                                  userDatabase.put('representativesMap', {});
                                }),
                          ),
                        ],
                      ),
                    ),
                    Column(
                        // verticalDirection: VerticalDirection.up,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: userCongressList
                            .map<Widget>((official) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MemberDetail(official.id,
                                              houseStockWatchList, senateStockWatchList),
                                        ),
                                      ).then(
                                          (_) => AdMobLibrary.interstitialAdShow(interstitialAd));
                                      // .then((_) => !userIsPremium &&
                                      //     interstitialAd != null &&
                                      //     interstitialAd.responseInfo.responseId !=
                                      //         userDatabase.get('interstitialAdId')
                                      // ? AdMobLibrary().interstitialAdShow(interstitialAd)
                                      // : null);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                            colors: [
                                              official.party == 'R'
                                                  ? republicanColor
                                                  : official.party == 'D'
                                                      ? democratColor
                                                      : independentColor,
                                              // Colors.white,
                                              Theme.of(context).highlightColor.withOpacity(0.15),
                                              Theme.of(context).highlightColor.withOpacity(0.15),
                                              Theme.of(context).highlightColor.withOpacity(0.15)
                                            ],
                                          )),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Container(
                                                width: official.shortTitle.toLowerCase() == 'rep.'
                                                    ? 30
                                                    : 20,
                                                height: official.shortTitle.toLowerCase() == 'rep.'
                                                    ? 30
                                                    : 20,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/congress_pic_$headerImageCounter.png'),
                                                      fit: BoxFit.cover),
                                                ),
                                                foregroundDecoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          'https://www.congress.gov/img/member/${official.id.toLowerCase()}.jpg'),
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                                '${official.shortTitle} ${official.firstName} ${official.lastName} ${official.suffix ?? ''}',
                                                style:
                                                    const TextStyle(fontWeight: FontWeight.bold)),
                                            AnimatedWidgets.flashingEye(
                                                context,
                                                subscriptionAlertsList.any((element) => element
                                                    .toLowerCase()
                                                    .startsWith(
                                                        'member_${official.id}'.toLowerCase())),
                                                false,
                                                size: 8,
                                                reverseContrast: false),
                                            const SizedBox(width: 5),
                                            Text(official.title,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.normal, fontSize: 12)),
                                            const Spacer(),
                                            Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8.0, vertical: 3),
                                                child: const Icon(Icons.person_pin_circle_rounded,
                                                    color: Color(0xffffffff), size: 20))
                                          ]),
                                    ),
                                  ),
                                ))
                            .toList()),
                  ],
                ),
              ),
            ),
    ]);
  }

  Widget memberPublicStatements() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 10, 2),
                child: Text(
                  'PUBLIC STATEMENTS',
                  style: GoogleFonts.bangers(fontSize: 18),
                ),
              ),
              statementsList == null || statementsList.isEmpty
                  ? SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                        child: Column(
                          children: [
                            Text('No Public Statements',
                                style: GoogleFonts.bangers(
                                    color: altHighlightColor,
                                    fontSize: 25,
                                    shadows: Styles.shadowStrokeTextGrey),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      itemCount: statementsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        StatementsResults thisStatement = statementsList[index];
                        // return ValueListenableBuilder(
                        //     valueListenable: Hive.box(appDatabase)
                        //         .listenable(keys: userDatabase.keys.toList()),
                        //     builder: (context, box, widget) {
                        return Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3.0),
                                child: SharedWidgets.statementTile(
                                    context,
                                    headerImageCounter,
                                    thisStatement,
                                    houseStockWatchList,
                                    senateStockWatchList,
                                    userIsPremium,
                                    interstitialAd)),
                          ],
                        );
                        // });
                      },
                    ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget footerContent(Orientation orientation) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        orientation == Orientation.landscape
            ? const SizedBox.shrink()
            : !userIsPremium && showBannerAd
                ? showPremiumPromo
                    ? BounceInUp(
                        child: SharedWidgets.premiumUpgradeContainer(context, interstitialAd,
                            userIsPremium, userIsLegacy, devUpgraded, freeTrialUsed, userDatabase,
                            color: Theme.of(context).colorScheme.primary),
                      )
                    : bannerAdContainer
                : const SizedBox.shrink(),
      ],
    );
  }
}
