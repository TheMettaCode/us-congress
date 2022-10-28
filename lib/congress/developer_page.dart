import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/models/news_article_model.dart';
import 'package:us_congress_vote_tracker/models/order_detail.dart';
import 'package:us_congress_vote_tracker/services/ecwid/ecwid_store_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/github/usc-app-data-model.dart';

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
        if (Platform.isAndroid) WebView.platform = AndroidWebView();

        await init();
      },
    );
    super.initState();
  }

  // @override
  // void dispose() {}

  Future<void> init() async {
    setState(() => _loading = true);
    await Functions.getUserLevels().then(((status) => setState(() {
          userIs = status;
          userIsDev = status[0];
          userIsPremium = status[1];
          userIsLegacy = status[2];
        })));

    List<NewsArticle> _newsArticles =
        newsArticleFromJson(userDatabase.get('newsArticles'));
    NewsArticle _thisNewsArticle =
        _newsArticles[random.nextInt(_newsArticles.length)];

    List<GithubNotifications> _githubNotifications =
        githubDataFromJson(userDatabase.get('githubData'))
            .notifications;
    GithubNotifications _thisGithubNotification =
        _githubNotifications[random.nextInt(_githubNotifications.length)];

    setState(() {
      ecwidStoreItems =
          ecwidStoreFromJson(userDatabase.get('ecwidProducts')).items;
      appOpens = userDatabase.get('appOpens');
      userIsSubscribed = userDatabase.get('userIsSubscribed');
      newsArticles = _newsArticles;
      githubNotifications = _githubNotifications;
      thisNewsArticle = _thisNewsArticle;
      thisGithubNotification = _thisGithubNotification;
      _loading = false;
    });
  }

  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  bool _loading = false;
  List<bool> userIs = [false, false, false];
  bool userIsDev = false;
  bool userIsPremium = false;
  bool userIsSubscribed = false;
  bool userIsLegacy = false;
  int appOpens = 0;
  bool appRated = false;
  bool devUpgraded = false;
  bool freeTrialUsed = false;
  bool freeTrialDismissed = false;
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
          userIsPremium = userDatabase.get('userIsPremium');
          userIsSubscribed = userDatabase.get('userIsSubscribed');
          userIsLegacy = !userDatabase.get('userIsPremium') &&
                  List.from(userDatabase.get('userIdList')).any((element) =>
                      element.toString().startsWith(oldUserIdPrefix))
              ? true
              : false;
          try {
            productOrdersList = orderDetailListFromJson(
                    userDatabase.get('ecwidProductOrdersList'))
                .orders;
          } catch (e) {
            productOrdersList = [];
            logger.w(
                '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
          }
          appRated = userDatabase.get('appRated');
          appOpens = userDatabase.get('appOpens');
          devUpgraded = userDatabase.get('devUpgraded');
          freeTrialUsed = userDatabase.get('freeTrialUsed');
          freeTrialDismissed = userDatabase.get('freeTrialDismissed');
          capitolBabbleNotificationsList =
              List.from(userDatabase.get('capitolBabbleNotificationsList'));
          return SafeArea(
              child: Scaffold(
            appBar: AppBar(
              title: const Text('Developer Test Page'),
            ),
            body: _loading
                ? AnimatedWidgets.circularProgressWatchtower(context, userDatabase, userIsPremium,
                    isFullScreen: true)
                : Container(
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onLongPress: () => userDatabase.put('appOpens', 0),
                          child: Container(
                            height: 50,
                            color: Theme.of(context).primaryColorDark,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('US Congress App - $appOpens Opens',
                                    style: Styles.googleStyle
                                        .copyWith(color: darkThemeTextColor)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8.0),
                          child: ToggleButtons(
                            onPressed: (val) {},
                            fillColor: Colors.transparent,
                            renderBorder: false,
                            selectedColor: userDatabase.get('darkTheme')
                                ? alertIndicatorColorBrightGreen
                                : alertIndicatorColorDarkGreen,
                            isSelected: [
                              userIsPremium,
                              userIsLegacy,
                              appRated,
                              devUpgraded,
                              ecwidStoreItems.isNotEmpty,
                              freeTrialUsed
                            ],
                            children: [
                              const Text('Premium '),
                              const Text('| Legacy '),
                              const Text('| Rated '),
                              const Text('| Dev Upgrd '),
                              Text('| Prod ${ecwidStoreItems.length} '),
                              const Text('| Trial'),
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
                                    child: ListTile(
                                  dense: true,
                                  enabled: true,
                                  enableFeedback: true,
                                  title: Text(
                                      'Premium Toggle ${userIsSubscribed ? '(Subscribed)' : '(Not Subscribed)'}'),
                                  onTap: () {
                                    bool _upgraded = !userIsPremium;
                                    userDatabase.put(
                                        'userIsPremium', _upgraded);
                                    // userDatabase.put('devUpgraded', _upgraded);
                                  },
                                  trailing: FaIcon(
                                      FontAwesomeIcons.solidLightbulb,
                                      size: 18,
                                      color: userDatabase.get('userIsPremium')
                                          ? altHighlightColor
                                          : null),
                                )),
                                Card(
                                    child: ListTile(
                                  dense: true,
                                  enabled: true,
                                  enableFeedback: true,
                                  title: const Text('Legacy Toggle'),
                                  onTap: () {
                                    List<String> _userIdList = List.from(
                                        userDatabase.get('userIdList'));
                                    if (_userIdList.any((element) =>
                                        element.startsWith(oldUserIdPrefix))) {
                                      _userIdList.removeWhere((element) =>
                                          element.startsWith(oldUserIdPrefix));
                                      // userDatabase.put('devUpgraded', false);
                                    } else {
                                      _userIdList.insert(0, oldUserIDTag);
                                      // userDatabase.put('devUpgraded', true);
                                    }

                                    userDatabase.put('userIdList', _userIdList);
                                    logger.i(userDatabase.get('userIdList'));
                                  },
                                  trailing: FaIcon(
                                      FontAwesomeIcons.solidLightbulb,
                                      size: 18,
                                      color: List<String>.from(userDatabase
                                                  .get('userIdList'))
                                              .any((element) => element
                                                  .startsWith(oldUserIdPrefix))
                                          ? altHighlightColor
                                          : null),
                                )),
                                Card(
                                    child: ListTile(
                                  dense: true,
                                  enabled: true,
                                  enableFeedback: true,
                                  title: const Text('Dev Upgrade Toggle'),
                                  subtitle: Text(
                                      'DLCODE: ${userDatabase.get('devLegacyCode')} DPCODE: ${userDatabase.get('devPremiumCode')}\nFTCODE: ${userDatabase.get('freeTrialCode')}'),
                                  onTap: () {
                                    bool _devUpgraded = !devUpgraded;
                                    userDatabase.put(
                                        'devUpgraded', _devUpgraded);
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
                                  onTap: () {
                                    bool _appRated = !appRated;
                                    userDatabase.put('appRated', _appRated);
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
                                  onTap: () {
                                    bool _freeTrialUsed = !freeTrialUsed;
                                    userDatabase.put(
                                        'freeTrialUsed', _freeTrialUsed);
                                    if (_freeTrialUsed) {
                                      userDatabase.put('freeTrialStartDate',
                                          freeTrialTestDate);
                                    }
                                  },
                                  onLongPress: () {
                                    // bool _freeTrialUsed = freeTrialUsed;
                                    // userDatabase.put(
                                    //     'freeTrialUsed', _freeTrialUsed);
                                    if (freeTrialUsed) {
                                      userDatabase.put('freeTrialStartDate',
                                          freeTrialExpiredDate);
                                    } else {
                                      // _freeTrialUsed = !freeTrialUsed;
                                      userDatabase.put('freeTrialUsed', true);
                                      userDatabase.put('freeTrialStartDate',
                                          freeTrialExpiringSoonDate);
                                    }
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
                                  title: const Text('Free Trial Dismissed Toggle'),
                                  onTap: () {
                                    bool _freeTrialDismissed =
                                        !freeTrialDismissed;
                                    userDatabase.put('freeTrialDismissed',
                                        _freeTrialDismissed);
                                  },
                                  trailing: FaIcon(
                                      FontAwesomeIcons.solidLightbulb,
                                      size: 18,
                                      color:
                                          userDatabase.get('freeTrialDismissed')
                                              ? altHighlightColor
                                              : null),
                                )),
                                Card(
                                    child: ListTile(
                                  dense: true,
                                  enabled: true,
                                  enableFeedback: true,
                                  title: const Text('Pop-Up With Image Test'),
                                  onTap: () async {
                                    Messages.showMessage(
                                        context: context,
                                        message:
                                            'This is just a test to see if the picture to the left is showing up correctly. If so, it will fade in and have a rounded border.',
                                        assetImageString:
                                            'assets/congress_pic_${random.nextInt(4)}.png',
                                        isAlert: false,
                                        removeCurrent: false);
                                  },
                                )),
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
                                            child: Text(
                                                '+100 Use Credits',
                                                textAlign: TextAlign.center),
                                          ),
                                        ),
                                        onTap: () {
                                          int credits =
                                              userDatabase.get('credits');
                                          userDatabase.put(
                                              'credits', credits + 100);
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
                                                '-100 Use Credits',
                                                textAlign: TextAlign.center),
                                          ),
                                        ),
                                        onTap: () {
                                          int credits =
                                              userDatabase.get('credits');
                                          if (credits >= 100) {
                                            userDatabase.put(
                                                'credits', credits - 100);
                                          }
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
                                                padding:
                                                    EdgeInsets.all(
                                                        10),
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
                                                padding:
                                                    EdgeInsets.all(
                                                        10),
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
                                thisNewsArticle == null
                                    ? const SizedBox.shrink()
                                    : Card(
                                        child: ListTile(
                                          dense: true,
                                          enabled: true,
                                          enableFeedback: true,
                                          leading: CircleAvatar(
                                              maxRadius: 15,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              backgroundImage: NetworkImage(
                                                  thisNewsArticle.imageUrl)),
                                          title: Text(thisNewsArticle.source),
                                          subtitle: Text(thisNewsArticle.title),
                                          trailing: Text(
                                              newsArticles.length.toString(),
                                              style: Styles.googleStyle),
                                          onTap: () => Functions.linkLaunch(
                                              context,
                                              thisNewsArticle.url,
                                              userDatabase,
                                              userIsPremium,
                                              appBarTitle:
                                                  thisNewsArticle.source),
                                        ),
                                      ),
                                thisGithubNotification == null
                                    ? const SizedBox.shrink()
                                    : Card(
                                        child: ListTile(
                                          dense: true,
                                          enabled: true,
                                          enableFeedback: true,
                                          // leading: CircleAvatar(
                                          //     maxRadius: 15,
                                          //     backgroundColor: Theme.of(context)
                                          //         .colorScheme
                                          //         .primary,
                                          //     backgroundImage: NetworkImage(
                                          //         thisNewsArticle.imageUrl)),
                                          title: Text(
                                              thisGithubNotification.title),
                                          subtitle: Text(
                                              thisGithubNotification.message),
                                          trailing: Text(
                                              githubNotifications.length
                                                  .toString(),
                                              style: Styles.googleStyle),
                                          // onTap: () => Functions.linkLaunch(
                                          //     context,
                                          //     thisNewsArticle.url,
                                          //     userDatabase,
                                          //     userIsPremium,
                                          //     appBarTitle:
                                          //         thisNewsArticle.source),
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                      // height: 200,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColorDark
                                              .withOpacity(0.5),
                                          border:
                                              Border.all(color: Colors.black),
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
                                              'SUBS: ${userDatabase.get('subscriptionAlertsList')}'),
                                          const SizedBox(height: 3),
                                          Text(
                                              'BACKUP: ${userDatabase.get('subscriptionAlertsListBackup')}'),
                                          const SizedBox(height: 3),
                                          Text(
                                              'ECWID ITEMS: ${ecwidStoreItems.map((e) => e.name)}'),
                                          // SizedBox(height: 3),
                                          // Text(
                                          //     'TWITTER API DATA: \n$twitterData'),
                                          const SizedBox(height: 3),
                                          Text(
                                              '${capitolBabbleNotificationsList.length} STORED BABBLE NOTIFICATIONS: \n${capitolBabbleNotificationsList.map((e) => e.toString().split('<|:|>')[1])}'),
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
            bottomNavigationBar: Container(
                height: 50,
                color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Bottom Navigation Bar',
                        style: Styles.googleStyle
                            .copyWith(color: darkThemeTextColor)),
                  ],
                )),
          ));
        });
  }
}
