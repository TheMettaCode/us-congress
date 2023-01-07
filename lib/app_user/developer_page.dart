import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:congress_watcher/app_user/user_profile.dart';
import 'package:congress_watcher/constants/animated_widgets.dart';
import 'package:congress_watcher/constants/constants.dart';
import 'package:congress_watcher/constants/styles.dart';
import 'package:congress_watcher/constants/themes.dart';
import 'package:congress_watcher/functions/functions.dart';
import 'package:congress_watcher/models/news_article_model.dart';
import 'package:congress_watcher/models/order_detail.dart';
import 'package:congress_watcher/services/ecwid/ecwid_store_model.dart';
import 'package:congress_watcher/services/twitter/twitter_api.dart';
import '../services/github/usc_app_data_model.dart';
import '../services/stripe/stripe_api.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  DeveloperPageState createState() => DeveloperPageState();
}

class DeveloperPageState extends State<DeveloperPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await setInitialValues();
      },
    );
    super.initState();
  }

  // @override
  // void dispose() {}

  Future<void> setInitialValues() async {
    setState(() => _loading = true);
    // await Functions.getUserLevels().then(((status) => setState(() {
    //       userIs = status;
    //       userIsDev = status[0];
    //       userIsPremium = status[1];
    //       userIsLegacy = status[2];
    //     })));

    /// USER INFORMATION
    // String initialUserId = List<String>.from(userDatabase.get('userIdList'))
    //     .firstWhere((element) => element.split('<|:|>')[0].toLowerCase() == 'newuser')
    //     .split('<|:|>')[1];
    // // String firstUserId = List<String>.from(userDatabase.get('userIdList')).last;

    /// GET UPDATED USER PROFILE
    await AppUser.buildUserProfile()
        .then((value) => setState(() => thisUser = value));

    List<NewsArticle> localNewsArticles =
        newsArticleFromJson(userDatabase.get('newsArticles'));
    NewsArticle lThisNewsArticle =
        localNewsArticles[random.nextInt(localNewsArticles.length)];

    List<GithubNotifications> localGithubNotifications =
        githubDataFromJson(userDatabase.get('githubData')).notifications;
    GithubNotifications localThisGithubNotification = localGithubNotifications[
        random.nextInt(localGithubNotifications.length)];

    setState(() {
      stripeTestMode = userDatabase.get('stripeTestMode');
      googleTestMode = userDatabase.get('googleTestMode');
      amazonTestMode = userDatabase.get('amazonTestMode');
      testing = userDatabase.get('stripeTestMode') ||
          userDatabase.get('googleTestMode') ||
          userDatabase.get('amazonTestMode');
      ecwidStoreItems =
          ecwidStoreFromJson(userDatabase.get('ecwidProducts')).items;
      // appOpens = userDatabase.get('appOpens');
      // userId = initialUserId;
      // userIsSubscribed = userDatabase.get('userIsSubscribed');
      newsArticles = localNewsArticles;
      githubNotifications = localGithubNotifications;
      thisNewsArticle = lThisNewsArticle;
      thisGithubNotification = localThisGithubNotification;
      // installerStoreIsValid = userDatabase.get('installerStoreIsValid');
      // rcIapAvailable = userDatabase.get('rcIapAvailable');
      _loading = false;
    });
  }

  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  bool _loading = false;
  bool stripeTestMode = false;
  bool googleTestMode = false;
  bool amazonTestMode = false;
  bool testing = false;
  UserProfile thisUser;
  // List<bool> userIs = [false, false, false];
  // bool userIsDev = false;
  // bool userIsPremium = false;
  // bool userIsSubscribed = false;
  // bool userIsLegacy = false;
  // String userId = '';
  // int appOpens = 0;
  int backgroundFetches = 0;
  // bool appRated = false;
  // bool devUpgraded = false;
  // bool freeTrialUsed = false;
  bool freeTrialDismissed = false;
  // bool installerStoreIsValid = false;
  // bool rcIapAvailable = false;
  List<NewsArticle> newsArticles = [];
  NewsArticle thisNewsArticle;
  GithubNotifications thisGithubNotification;
  List<String> capitolBabbleNotificationsList = [];
  List<EcwidStoreItem> ecwidStoreItems = [];
  List<Order> productOrdersList = [];
  List<GithubNotifications> githubNotifications = [];

  final String freeTrialTestDate =
      '${DateTime.now().subtract(const Duration(days: 3))}';
  final String freeTrialExpiredDate =
      '${DateTime.now().subtract(const Duration(days: 7))}';
  final String freeTrialExpiringSoonDate =
      '${DateTime.now().subtract(Duration(seconds: freeTrialPromoDurationDays * 86400 - 60))}';

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
          // userIsPremium = userDatabase.get('userIsPremium');
          // userIsSubscribed = userDatabase.get('userIsSubscribed');
          // userIsLegacy = !userDatabase.get('userIsPremium') &&
          //         List.from(userDatabase.get('userIdList'))
          //             .any((element) => element.toString().startsWith(oldUserIdPrefix))
          //     ? true
          //     : false;

          try {
            productOrdersList = orderDetailListFromJson(
                    userDatabase.get('ecwidProductOrdersList'))
                .orders;
          } catch (e) {
            productOrdersList = [];
            logger.w(
                '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
          }
          // appRated = userDatabase.get('appRated');
          // appOpens = userDatabase.get('appOpens');
          backgroundFetches = userDatabase.get('backgroundFetches');
          // devUpgraded = userDatabase.get('devUpgraded');
          // freeTrialUsed = userDatabase.get('freeTrialUsed');
          freeTrialDismissed = userDatabase.get('freeTrialDismissed');
          // installerStoreIsValid = userDatabase.get('installerStoreIsValid');
          // rcIapAvailable = userDatabase.get('rcIapAvailable');
          capitolBabbleNotificationsList =
              List.from(userDatabase.get('capitolBabbleNotificationsList'));
          return SafeArea(
              child: Scaffold(
            appBar: AppBar(
              title: const Text('Developer Test Page'),
            ),
            body: _loading || thisUser == null
                ? AnimatedWidgets.circularProgressWatchtower(
                    context, userDatabase,
                    isFullScreen: true)
                : Container(
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () => userDatabase.put('backgroundFetches', 0),
                          onLongPress: () => userDatabase.put('appOpens', 0),
                          child: Container(
                            height: 50,
                            color: Theme.of(context).primaryColorDark,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    '${thisUser.appOpens} Opens - $backgroundFetches Fetches',
                                    style: Styles.googleStyle
                                        .copyWith(color: darkThemeTextColor)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          // height: 20,
                          child: Text(
                              'Installed from ${thisUser.installerStore ?? 'unknown'}\nApp User Id: ${thisUser.userId}'
                                  .toUpperCase()),
                        ),
                        Container(
                          height: 40,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8.0),
                          child: ToggleButtons(
                            onPressed: (val) {},
                            fillColor: Colors.transparent,
                            renderBorder: false,
                            selectedColor: thisUser.darkTheme
                                ? altHighlightColor
                                : Theme.of(context).primaryColorDark,
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            isSelected: [
                              thisUser.premiumStatus,
                              // thisUser.legacyStatus,
                              thisUser.appRated,
                              thisUser.devUpgraded,
                              ecwidStoreItems.isNotEmpty,
                              thisUser.revenueCatIapAvailable
                            ],
                            children: [
                              const Text('Premium '),
                              // const Text('| Legacy '),
                              const Text('| Rated '),
                              const Text('| Dev Upgrd '),
                              Text('| Prod ${ecwidStoreItems.length} '),
                              // const Text('| IAP Avail'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Scrollbar(
                            // trackVisibility: true,
                            // thumbVisibility: true,
                            child: ListView(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              primary: false,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Card(
                                    color: stripeTestMode ? Colors.blue : null,
                                    child: ListTile(
                                      dense: true,
                                      enabled: true,
                                      enableFeedback: true,
                                      title: Text(
                                        'Stripe Test Mode ${stripeTestMode ? 'ON' : 'OFF'}',
                                        style: stripeTestMode
                                            ? const TextStyle(
                                                color: darkThemeTextColor,
                                                fontWeight: FontWeight.bold,
                                              )
                                            : null,
                                      ), // ${userIsSubscribed ? '(Subscribed)' : '(Not Subscribed)'}'),
                                      onTap: () async {
                                        stripeTestMode = !stripeTestMode;
                                        userDatabase.put(
                                            'stripeTestMode', stripeTestMode);
                                        userDatabase.put(
                                            'googleTestMode', false);
                                        userDatabase.put(
                                            'amazonTestMode', false);
                                        await AppUser.buildUserProfile(
                                                updateStripeServer: false)
                                            .then((value) => setState(
                                                () => thisUser = value));
                                      },
                                      trailing: FaIcon(
                                          FontAwesomeIcons.solidLightbulb,
                                          size: 18,
                                          color:
                                              userDatabase.get('stripeTestMode')
                                                  ? altHighlightColor
                                                  : null),
                                    )),
                                Card(
                                    color: googleTestMode ? Colors.red : null,
                                    child: ListTile(
                                      dense: true,
                                      enabled: true,
                                      enableFeedback: true,
                                      title: Text(
                                        'Google Test Mode ${googleTestMode ? 'ON' : 'OFF'}',
                                        style: googleTestMode
                                            ? const TextStyle(
                                                color: darkThemeTextColor,
                                                fontWeight: FontWeight.bold,
                                              )
                                            : null,
                                      ), // ${userIsSubscribed ? '(Subscribed)' : '(Not Subscribed)'}'),
                                      onTap: () async {
                                        googleTestMode = !googleTestMode;
                                        userDatabase.put(
                                            'stripeTestMode', false);
                                        userDatabase.put(
                                            'googleTestMode', googleTestMode);
                                        userDatabase.put(
                                            'amazonTestMode', false);
                                        await AppUser.buildUserProfile(
                                                updateStripeServer: false)
                                            .then((value) => setState(
                                                () => thisUser = value));
                                      },
                                      trailing: FaIcon(
                                          FontAwesomeIcons.solidLightbulb,
                                          size: 18,
                                          color:
                                              userDatabase.get('googleTestMode')
                                                  ? altHighlightColor
                                                  : null),
                                    )),
                                Card(
                                    color: amazonTestMode ? Colors.amber : null,
                                    child: ListTile(
                                      dense: true,
                                      enabled: true,
                                      enableFeedback: true,
                                      title: Text(
                                        'Amazon Test Mode ${amazonTestMode ? 'ON' : 'OFF'}',
                                        style: amazonTestMode
                                            ? const TextStyle(
                                                color:
                                                    altHighlightAccentColorDark,
                                                fontWeight: FontWeight.bold,
                                              )
                                            : null,
                                      ), // ${userIsSubscribed ? '(Subscribed)' : '(Not Subscribed)'}'),
                                      onTap: () async {
                                        amazonTestMode = !amazonTestMode;
                                        userDatabase.put(
                                            'stripeTestMode', false);
                                        userDatabase.put(
                                            'googleTestMode', false);
                                        userDatabase.put(
                                            'amazonTestMode', amazonTestMode);
                                        await AppUser.buildUserProfile(
                                                updateStripeServer: false)
                                            .then((value) => setState(
                                                () => thisUser = value));
                                      },
                                      trailing: FaIcon(
                                          FontAwesomeIcons.solidLightbulb,
                                          size: 18,
                                          color:
                                              userDatabase.get('amazonTestMode')
                                                  ? altHighlightAccentColorDark
                                                  : null),
                                    )),
                                Card(
                                    child: ListTile(
                                  dense: true,
                                  enabled: true,
                                  enableFeedback: true,
                                  title: const Text(
                                      'Premium Toggle'), // ${userIsSubscribed ? '(Subscribed)' : '(Not Subscribed)'}'),
                                  onTap: () async {
                                    bool localUpgraded =
                                        !thisUser.premiumStatus;
                                    userDatabase.put(
                                        'userIsPremium', localUpgraded);
                                    await AppUser.buildUserProfile(
                                            updateStripeServer: true)
                                        .then((value) =>
                                            setState(() => thisUser = value));
                                  },
                                  trailing: FaIcon(
                                      FontAwesomeIcons.solidLightbulb,
                                      size: 18,
                                      color: userDatabase.get('userIsPremium')
                                          ? altHighlightColor
                                          : null),
                                )),
                                // Card(
                                //     child: ListTile(
                                //   dense: true,
                                //   enabled: true,
                                //   enableFeedback: true,
                                //   title: const Text('Legacy Toggle'),
                                //   onTap: () {
                                //     List<String> localUserIdList =
                                //         List.from(userDatabase.get('userIdList'));
                                //     if (localUserIdList
                                //         .any((element) => element.startsWith(oldUserIdPrefix))) {
                                //       localUserIdList.removeWhere(
                                //           (element) => element.startsWith(oldUserIdPrefix));
                                //       // userDatabase.put('devUpgraded', false);
                                //     } else {
                                //       localUserIdList.insert(0, oldUserIDTag);
                                //       // userDatabase.put('devUpgraded', true);
                                //     }
                                //
                                //     userDatabase.put('userIdList', localUserIdList);
                                //     logger.i(userDatabase.get('userIdList'));
                                //   },
                                //   trailing: FaIcon(FontAwesomeIcons.solidLightbulb,
                                //       size: 18,
                                //       color: List<String>.from(userDatabase.get('userIdList'))
                                //               .any((element) => element.startsWith(oldUserIdPrefix))
                                //           ? altHighlightColor
                                //           : null),
                                // )),
                                Card(
                                    child: ListTile(
                                  dense: true,
                                  enabled: true,
                                  enableFeedback: true,
                                  title: const Text('Dev Upgrade Toggle'),
                                  subtitle: Text(
                                      'DLCODE: ${userDatabase.get('devLegacyCode')} DPCODE: ${userDatabase.get('devPremiumCode')}\nFTCODE: ${userDatabase.get('freeTrialCode')}'),
                                  onTap: () async {
                                    bool localDevUpgraded =
                                        !thisUser.devUpgraded;
                                    userDatabase.put(
                                        'devUpgraded', localDevUpgraded);
                                    await AppUser.buildUserProfile(
                                            updateStripeServer: true)
                                        .then((value) =>
                                            setState(() => thisUser = value));
                                  },
                                  trailing: FaIcon(
                                      FontAwesomeIcons.solidLightbulb,
                                      size: 18,
                                      color: userDatabase.get('devUpgraded')
                                          ? altHighlightColor
                                          : null),
                                )),
                                Card(
                                    child: ListTile(
                                  dense: true,
                                  enabled: true,
                                  enableFeedback: true,
                                  title: const Text('App Rating Toggle'),
                                  onTap: () async {
                                    bool localAppRated = !thisUser.appRated;
                                    userDatabase.put('appRated', localAppRated);
                                    await AppUser.buildUserProfile(
                                            updateStripeServer: true)
                                        .then((value) =>
                                            setState(() => thisUser = value));
                                  },
                                  trailing: FaIcon(
                                      FontAwesomeIcons.solidLightbulb,
                                      size: 18,
                                      color: userDatabase.get('appRated')
                                          ? altHighlightColor
                                          : null),
                                )),
                                Card(
                                    child: ListTile(
                                  dense: true,
                                  enabled: true,
                                  enableFeedback: true,
                                  title: const Text('Free Trial Used Toggle'),
                                  subtitle: Text(
                                      'Date Started : ${dateWithTimeAndSecondsFormatter.format(DateTime.parse(userDatabase.get('freeTrialStartDate')).toLocal())}'
                                          .toUpperCase()),
                                  onTap: () async {
                                    bool localFreeTrialUsed =
                                        !thisUser.freeTrialUsed;
                                    userDatabase.put(
                                        'freeTrialUsed', localFreeTrialUsed);
                                    await AppUser.buildUserProfile(
                                            updateStripeServer: true)
                                        .then((value) =>
                                            setState(() => thisUser = value));
                                    if (localFreeTrialUsed) {
                                      userDatabase.put('freeTrialStartDate',
                                          freeTrialTestDate);
                                    }
                                  },
                                  onLongPress: () async {
                                    // bool _freeTrialUsed = freeTrialUsed;
                                    // userDatabase.put(
                                    //     'freeTrialUsed', _freeTrialUsed);
                                    if (thisUser.freeTrialUsed) {
                                      userDatabase.put('freeTrialStartDate',
                                          freeTrialExpiredDate);
                                    } else {
                                      // _freeTrialUsed = !freeTrialUsed;
                                      userDatabase.put('freeTrialUsed', true);
                                      userDatabase.put('freeTrialStartDate',
                                          freeTrialExpiringSoonDate);
                                    }
                                    // await AppUser.buildUserProfile(updateStripeServer: false).then((value) => setState(()=>thisUser = value));
                                  },
                                  trailing: FaIcon(
                                      FontAwesomeIcons.solidLightbulb,
                                      size: 18,
                                      color: userDatabase.get('freeTrialUsed')
                                          ? altHighlightColor
                                          : null),
                                )),
                                Card(
                                    child: ListTile(
                                  dense: true,
                                  enabled: true,
                                  enableFeedback: true,
                                  title:
                                      const Text('Free Trial Dismissed Toggle'),
                                  onTap: () async {
                                    bool localFreeTrialDismissed =
                                        !freeTrialDismissed;
                                    userDatabase.put('freeTrialDismissed',
                                        localFreeTrialDismissed);
                                    await AppUser.buildUserProfile(
                                            updateStripeServer: false)
                                        .then((value) =>
                                            setState(() => thisUser = value));
                                  },
                                  trailing: FaIcon(
                                      FontAwesomeIcons.solidLightbulb,
                                      size: 18,
                                      color:
                                          userDatabase.get('freeTrialDismissed')
                                              ? altHighlightColor
                                              : null),
                                )),
                                // Card(
                                //     child: ListTile(
                                //   dense: true,
                                //   enabled: true,
                                //   enableFeedback: true,
                                //   title: const Text('Installer Store Validity Toggle'),
                                //   onTap: () {
                                //     userDatabase.put(
                                //         'installerStoreIsValid', !installerStoreIsValid);
                                //   },
                                //   trailing: FaIcon(FontAwesomeIcons.solidLightbulb,
                                //       size: 18,
                                //       color: userDatabase.get('installerStoreIsValid')
                                //           ? altHighlightColor
                                //           : null),
                                // )),
                                // Card(
                                //     child: ListTile(
                                //   dense: true,
                                //   enabled: true,
                                //   enableFeedback: true,
                                //   title: const Text('IAP Available Toggle'),
                                //   onTap: () async {
                                //     userDatabase.put('rcIapAvailable',
                                //         !thisUser.revenueCatIapAvailable);
                                //     await AppUser.buildUserProfile(
                                //             updateStripeServer: false)
                                //         .then((value) =>
                                //             setState(() => thisUser = value));
                                //   },
                                //   trailing: FaIcon(
                                //       FontAwesomeIcons.solidLightbulb,
                                //       size: 18,
                                //       color: userDatabase.get('rcIapAvailable')
                                //           ? altHighlightColor
                                //           : null),
                                // )),
                                Column(
                                    // children: [
                                    // Card(
                                    //     child: ListTile(
                                    //   dense: true,
                                    //   enabled: true,
                                    //   enableFeedback: true,
                                    //   title: const Text('Stripe payment verification test'),
                                    //   onTap: () async {
                                    //     bool verified = await StripeApi.verifyStripeNoCodePayment(
                                    //         DateTime.now(), '',
                                    //         isDevTest: true);
                                    //     debugPrint(
                                    //         '[DEVELOPER PAGE STRIPE PAYMENT VERIFICATION] STRIPE PAYMENT VERIFIED: $verified');
                                    //   },
                                    // )),
                                    // ],
                                    ),
                                // const NewVideoPlayer('',[]),
                                // Card(
                                //     child: ListTile(
                                //         dense: true,
                                //         enabled: true,
                                //         enableFeedback: true,
                                //         title: const Text('Pop-Up With Image Test'),
                                //         onTap: () async {
                                //           Messages.showMessage(
                                //               context: context,
                                //               message:
                                //                   'This is just a test to see if the picture to the left is showing up correctly. If so, it will fade in and have a rounded border.',
                                //               assetImageString:
                                //                   'assets/congress_pic_${random.nextInt(4)}.png',
                                //               isAlert: false,
                                //               removeCurrent: false);
                                //         },
                                //         onLongPress: () => userDatabase.put(
                                //             'newHouseFloor', !userDatabase.get('newHouseFloor')))),
                                // Card(
                                //     child: ListTile(
                                //   dense: true,
                                //   enabled: true,
                                //   enableFeedback: true,
                                //   title: Text('Clear Purchases'),
                                //   onTap: () => userDatabase
                                //       .put('ecwidProductOrdersList', {}),
                                //   trailing: Text(
                                //       productOrdersList.length.toString(),
                                //       style: Styles.googleStyle),
                                // )),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        child: const Card(
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text('+100 Use Credits',
                                                textAlign: TextAlign.center),
                                          ),
                                        ),
                                        onTap: () async {
                                          int credits =
                                              userDatabase.get('credits');
                                          userDatabase.put(
                                              'credits', credits + 100);
                                          await AppUser.buildUserProfile(
                                                  updateStripeServer: false)
                                              .then((value) => setState(
                                                  () => thisUser = value));
                                        },
                                      ),
                                    ),
                                    // SizedBox(width: 5),
                                    Expanded(
                                      child: InkWell(
                                        child: const Card(
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text('-100 Use Credits',
                                                textAlign: TextAlign.center),
                                          ),
                                        ),
                                        onTap: () async {
                                          int credits =
                                              userDatabase.get('credits');
                                          if (credits >= 100) {
                                            userDatabase.put(
                                                'credits', credits - 100);
                                          }
                                          await AppUser.buildUserProfile(
                                                  updateStripeServer: false)
                                              .then((value) => setState(
                                                  () => thisUser = value));
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 20.0),
                                      child: Text(
                                          '${userDatabase.get('credits')}',
                                          style: Styles.googleStyle),
                                    ),
                                  ],
                                ),
                                capitolBabbleNotificationsList.isEmpty
                                    ? const SizedBox.shrink()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              child: const Card(
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text(
                                                      'Remove First Babble',
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                              ),
                                              onTap: () {
                                                capitolBabbleNotificationsList
                                                    .removeAt(0);
                                                userDatabase.put(
                                                    'capitolBabbleNotificationsList',
                                                    capitolBabbleNotificationsList);
                                              },
                                            ),
                                          ),
                                          // SizedBox(width: 5),
                                          Expanded(
                                            child: InkWell(
                                              child: const Card(
                                                child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text(
                                                      'Remove Last Babble',
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                              ),
                                              onTap: () {
                                                capitolBabbleNotificationsList
                                                    .removeLast();
                                                userDatabase.put(
                                                    'capitolBabbleNotificationsList',
                                                    capitolBabbleNotificationsList);
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 20.0),
                                            child: Text(
                                                capitolBabbleNotificationsList
                                                    .length
                                                    .toString(),
                                                style: Styles.googleStyle),
                                          ),
                                        ],
                                      ),
                                // thisNewsArticle == null
                                //     ? const SizedBox.shrink()
                                //     : Card(
                                //         child: ListTile(
                                //           dense: true,
                                //           enabled: true,
                                //           enableFeedback: true,
                                //           leading: CircleAvatar(
                                //               maxRadius: 15,
                                //               backgroundColor:
                                //                   Theme.of(context).colorScheme.primary,
                                //               backgroundImage:
                                //                   NetworkImage(thisNewsArticle.imageUrl)),
                                //           title: Text(thisNewsArticle.source),
                                //           subtitle: Text(thisNewsArticle.title),
                                //           trailing: Text(newsArticles.length.toString(),
                                //               style: Styles.googleStyle),
                                //           onTap: () => Functions.linkLaunch(context,
                                //               thisNewsArticle.url, userDatabase, userIsPremium,
                                //               appBarTitle: thisNewsArticle.source),
                                //         ),
                                //       ),
                                // Card(
                                //   child: ListTile(
                                //     dense: true,
                                //     enabled: true,
                                //     enableFeedback: true,
                                //     // leading: CircleAvatar(
                                //     //     maxRadius: 15,
                                //     //     backgroundColor: Theme.of(context)
                                //     //         .colorScheme
                                //     //         .primary,
                                //     //     backgroundImage: NetworkImage(
                                //     //         thisNewsArticle.imageUrl)),
                                //     title: const Text('Twitter API Test'),
                                //     // subtitle: Text(thisGithubNotification.message),
                                //     // trailing: Text(githubNotifications.length.toString(),
                                //     //     style: Styles.googleStyle),
                                //     onTap: () => TwitterServiceApi.postTweet('Hello World!'),
                                //   ),
                                // ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                      // height: 200,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.75),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                          borderRadius:
                                              BorderRadius.circular(3)),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        // shrinkWrap: true,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('Data Output',
                                                  style: Styles.googleStyle
                                                      .copyWith(
                                                          color:
                                                              darkThemeTextColor)),
                                            ],
                                          ),
                                          const Divider(),
                                          Text(
                                              'SUBS: ${userDatabase.get('subscriptionAlertsList')}',
                                              style: const TextStyle(
                                                  color: darkThemeTextColor)),
                                          const SizedBox(height: 3),
                                          Text(
                                              'BACKUP: ${userDatabase.get('subscriptionAlertsListBackup')}',
                                              style: const TextStyle(
                                                  color: darkThemeTextColor)),
                                          const SizedBox(height: 3),
                                          Text(
                                              'ECWID ITEMS: ${ecwidStoreItems.map((e) => e.name)}',
                                              style: const TextStyle(
                                                  color: darkThemeTextColor)),
                                          // SizedBox(height: 3),
                                          // Text(
                                          //     'TWITTER API DATA: \n$twitterData'),
                                          const SizedBox(height: 3),
                                          Text(
                                              '${capitolBabbleNotificationsList.length} STORED BABBLE NOTIFICATIONS: \n${capitolBabbleNotificationsList.map((e) => e.toString().split('<|:|>')[1])}',
                                              style: const TextStyle(
                                                  color: darkThemeTextColor)),
                                          const SizedBox(height: 3),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
            // bottomSheet: ,
            // bottomNavigationBar: Container(
            //     height: 50,
            //     color: Colors.green,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text('Bottom Navigation Bar',
            //             style: Styles.googleStyle
            //                 .copyWith(color: darkThemeTextColor)),
            //       ],
            //     )),
          ));
        });
  }
}
