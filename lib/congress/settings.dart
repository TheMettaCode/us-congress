import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/constants/widgets.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  bool _isLoading = true;
  List<bool> userIs = [false, false, false];
  bool userIsDev = false;
  bool userIsPremium = false;
  bool userIsSubscribed = false;
  bool userIsLegacy = false;

  bool darkTheme = false;
  bool showAlertOptions = false;
  bool floorAlerts = false;
  bool newsAlerts = false;
  bool memberAlerts = false;
  bool billAlerts = false;
  bool voteAlerts = false;
  bool lobbyingAlerts = false;
  bool privateTripAlerts = false;
  bool stockWatchAlerts = false;
  bool statementAlerts = false;
  bool videoAlerts = false;
  bool newProductAlerts = false;

  CustomerInfo customerInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });
      await setVariables();
      // await getData();

      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> setVariables() async {
    await Functions.getUserLevels().then(((status) => setState(() {
          userIs = status;
          userIsDev = status[0];
          userIsPremium = status[1];
          userIsLegacy = status[2];
        })));

    CustomerInfo tempCustomerInfo = await Purchases.getCustomerInfo();

    setState(() {
      userIsSubscribed = userDatabase.get('userIsSubscribed');
      customerInfo = tempCustomerInfo;
    });
  }

  Future<void> getData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Settings', style: GoogleFonts.bangers(fontSize: 25)),
        actions: const <Widget>[],
      ),
      body: _isLoading
          ? AnimatedWidgets.circularProgressWatchtower(context, userDatabase, userIsPremium,
              isFullScreen: true)
          : ValueListenableBuilder(
              valueListenable: Hive.box(appDatabase).listenable(keys: userDatabase.keys.toList()),
              builder: (context, box, widget) {
                userIsSubscribed = userDatabase.get('userIsSubscribed');
                darkTheme = userDatabase.get('darkTheme');
                floorAlerts = userDatabase.get('floorAlerts');
                newsAlerts = userDatabase.get('newsAlerts');
                memberAlerts = userDatabase.get('memberAlerts');
                billAlerts = userDatabase.get('billAlerts');
                voteAlerts = userDatabase.get('voteAlerts');
                lobbyingAlerts = userDatabase.get('lobbyingAlerts');
                privateTripAlerts = userDatabase.get('privateFundedTripsAlerts');
                stockWatchAlerts = userDatabase.get('stockWatchAlerts');
                statementAlerts = userDatabase.get('statementAlerts');
                videoAlerts = userDatabase.get('videoAlerts');
                newProductAlerts = userDatabase.get('newProductAlerts');

                return Container(
                  color: Theme.of(context).primaryColorDark,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            BounceInRight(
                              duration: const Duration(milliseconds: 200),
                              child: SwitchListTile(
                                  dense: true,
                                  activeColor: darkTheme
                                      ? alertIndicatorColorBrightGreen
                                      : altHighlightColor,
                                  secondary: AnimatedWidgets.starryNight(context, darkTheme, true,
                                      size: 13),
                                  title: Text('Dark Mode',
                                      style:
                                          Styles.regularStyle.copyWith(color: darkThemeTextColor)),
                                  value: userDatabase.get('darkTheme'),
                                  onChanged: (dark) async {
                                    setState(() => darkTheme = dark);
                                    userDatabase.put('darkTheme', dark);
                                    logger.d(
                                        '***** DBase Dark: ${userDatabase.get('darkTheme')} *****');

                                    await Functions.processCredits(true,
                                        isPermanent: false, creditsToAdd: 1);
                                  }),
                            ),
                            BounceInRight(
                              duration: const Duration(milliseconds: 600),
                              child: ListTile(
                                  enabled: true,
                                  enableFeedback: true,
                                  leading: Icon(
                                      floorAlerts ||
                                              newsAlerts ||
                                              memberAlerts ||
                                              billAlerts ||
                                              voteAlerts ||
                                              lobbyingAlerts ||
                                              privateTripAlerts ||
                                              stockWatchAlerts ||
                                              statementAlerts ||
                                              videoAlerts ||
                                              newProductAlerts
                                          ? Icons.notifications_active
                                          : Icons.notifications,
                                      size: 15,
                                      color: floorAlerts ||
                                              newsAlerts ||
                                              memberAlerts ||
                                              billAlerts ||
                                              voteAlerts ||
                                              lobbyingAlerts ||
                                              privateTripAlerts ||
                                              stockWatchAlerts ||
                                              statementAlerts ||
                                              videoAlerts ||
                                              newProductAlerts
                                          ? alertIndicatorColorBrightGreen
                                          : darkThemeTextColor),
                                  title: Text('Notifications',
                                      style:
                                          Styles.regularStyle.copyWith(color: darkThemeTextColor)),
                                  trailing: FaIcon(
                                      showAlertOptions
                                          ? FontAwesomeIcons.caretLeft
                                          : FontAwesomeIcons.caretDown,
                                      size: 20,
                                      color: darkThemeTextColor),
                                  onTap: () =>
                                      setState(() => showAlertOptions = !showAlertOptions)),
                            ),
                            !showAlertOptions
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Column(
                                      children: <Widget>[
                                        BounceInDown(
                                          duration: const Duration(milliseconds: 10),
                                          child: Theme(
                                            data: ThemeData(unselectedWidgetColor: Colors.grey),
                                            child: CheckboxListTile(
                                                dense: true,
                                                activeColor: darkTheme
                                                    ? alertIndicatorColorBrightGreen
                                                    : altHighlightColor,
                                                secondary: Icon(
                                                    floorAlerts
                                                        ? Icons.notifications_active
                                                        : Icons.notifications,
                                                    size: 15,
                                                    color: floorAlerts
                                                        ? alertIndicatorColorBrightGreen
                                                        : darkThemeTextColor),
                                                title: Text('Floor Alerts',
                                                    style: Styles.regularStyle
                                                        .copyWith(color: darkThemeTextColor)),
                                                value: userDatabase.get('floorAlerts'),
                                                onChanged: (floor) {
                                                  setState(() => floorAlerts = floor);
                                                  userDatabase.put('floorAlerts', floor);
                                                }),
                                          ),
                                        ),
                                        BounceInDown(
                                          duration: const Duration(milliseconds: 10),
                                          child: Theme(
                                            data: ThemeData(unselectedWidgetColor: Colors.grey),
                                            child: CheckboxListTile(
                                                dense: true,
                                                activeColor: darkTheme
                                                    ? alertIndicatorColorBrightGreen
                                                    : altHighlightColor,
                                                secondary: Icon(
                                                    newsAlerts
                                                        ? Icons.notifications_active
                                                        : Icons.notifications,
                                                    size: 15,
                                                    color: newsAlerts
                                                        ? alertIndicatorColorBrightGreen
                                                        : darkThemeTextColor),
                                                title: Text('News Alerts',
                                                    style: Styles.regularStyle
                                                        .copyWith(color: darkThemeTextColor)),
                                                value: userDatabase.get('newsAlerts'),
                                                onChanged: (news) {
                                                  setState(() => newsAlerts = news);
                                                  userDatabase.put('newsAlerts', news);
                                                }),
                                          ),
                                        ),
                                        !userIsPremium && !userIsLegacy
                                            ? const SizedBox.shrink()
                                            : BounceInDown(
                                                duration: const Duration(milliseconds: 100),
                                                child: Theme(
                                                  data:
                                                      ThemeData(unselectedWidgetColor: Colors.grey),
                                                  child: CheckboxListTile(
                                                      dense: true,
                                                      activeColor: darkTheme
                                                          ? alertIndicatorColorBrightGreen
                                                          : altHighlightColor,
                                                      secondary: Icon(
                                                          memberAlerts
                                                              ? Icons.notifications_active
                                                              : Icons.notifications,
                                                          size: 15,
                                                          color: memberAlerts
                                                              ? alertIndicatorColorBrightGreen
                                                              : darkThemeTextColor),
                                                      title: Text('Member Alerts',
                                                          style: Styles.regularStyle
                                                              .copyWith(color: darkThemeTextColor)),
                                                      value: userDatabase.get('memberAlerts'),
                                                      onChanged: (member) {
                                                        setState(() => memberAlerts = member);
                                                        userDatabase.put('memberAlerts', member);
                                                      }),
                                                ),
                                              ),
                                        BounceInDown(
                                          duration: const Duration(milliseconds: 200),
                                          child: Theme(
                                            data: ThemeData(unselectedWidgetColor: Colors.grey),
                                            child: CheckboxListTile(
                                                dense: true,
                                                activeColor: darkTheme
                                                    ? alertIndicatorColorBrightGreen
                                                    : altHighlightColor,
                                                secondary: Icon(
                                                    billAlerts
                                                        ? Icons.notifications_active
                                                        : Icons.notifications,
                                                    size: 15,
                                                    color: billAlerts
                                                        ? alertIndicatorColorBrightGreen
                                                        : darkThemeTextColor),
                                                title: Text('Bill Alerts',
                                                    style: Styles.regularStyle
                                                        .copyWith(color: darkThemeTextColor)),
                                                value: userDatabase.get('billAlerts'),
                                                onChanged: (bill) {
                                                  setState(() => billAlerts = bill);
                                                  userDatabase.put('billAlerts', bill);
                                                }),
                                          ),
                                        ),
                                        BounceInDown(
                                          duration: const Duration(milliseconds: 300),
                                          child: Theme(
                                            data: ThemeData(unselectedWidgetColor: Colors.grey),
                                            child: CheckboxListTile(
                                                dense: true,
                                                activeColor: darkTheme
                                                    ? alertIndicatorColorBrightGreen
                                                    : altHighlightColor,
                                                secondary: Icon(
                                                    voteAlerts
                                                        ? Icons.notifications_active
                                                        : Icons.notifications,
                                                    size: 15,
                                                    color: voteAlerts
                                                        ? alertIndicatorColorBrightGreen
                                                        : darkThemeTextColor),
                                                title: Text('Vote Alerts',
                                                    style: Styles.regularStyle
                                                        .copyWith(color: darkThemeTextColor)),
                                                value: userDatabase.get('voteAlerts'),
                                                onChanged: (vote) {
                                                  setState(() => voteAlerts = vote);
                                                  userDatabase.put('voteAlerts', vote);
                                                }),
                                          ),
                                        ),
                                        !userIsPremium && !userIsLegacy
                                            ? const SizedBox.shrink()
                                            : BounceInDown(
                                                duration: const Duration(milliseconds: 400),
                                                child: Theme(
                                                  data:
                                                      ThemeData(unselectedWidgetColor: Colors.grey),
                                                  child: CheckboxListTile(
                                                      dense: true,
                                                      activeColor: darkTheme
                                                          ? alertIndicatorColorBrightGreen
                                                          : altHighlightColor,
                                                      secondary: Icon(
                                                          lobbyingAlerts
                                                              ? Icons.notifications_active
                                                              : Icons.notifications,
                                                          size: 15,
                                                          color: lobbyingAlerts
                                                              ? alertIndicatorColorBrightGreen
                                                              : darkThemeTextColor),
                                                      title: Text('Lobbying Alerts',
                                                          style: Styles.regularStyle
                                                              .copyWith(color: darkThemeTextColor)),
                                                      value: userDatabase.get('lobbyingAlerts'),
                                                      onChanged: (lobby) {
                                                        setState(() => lobbyingAlerts = lobby);
                                                        userDatabase.put('lobbyingAlerts', lobby);
                                                      }),
                                                ),
                                              ),
                                        !userIsPremium && !userIsLegacy
                                            ? const SizedBox.shrink()
                                            : BounceInDown(
                                                duration: const Duration(milliseconds: 400),
                                                child: Theme(
                                                  data:
                                                      ThemeData(unselectedWidgetColor: Colors.grey),
                                                  child: CheckboxListTile(
                                                      dense: true,
                                                      activeColor: darkTheme
                                                          ? alertIndicatorColorBrightGreen
                                                          : altHighlightColor,
                                                      secondary: Icon(
                                                          privateTripAlerts
                                                              ? Icons.notifications_active
                                                              : Icons.notifications,
                                                          size: 15,
                                                          color: privateTripAlerts
                                                              ? alertIndicatorColorBrightGreen
                                                              : darkThemeTextColor),
                                                      title: Text('Funded Trip Alerts',
                                                          style: Styles.regularStyle
                                                              .copyWith(color: darkThemeTextColor)),
                                                      value: userDatabase
                                                          .get('privateFundedTripsAlerts'),
                                                      onChanged: (trip) {
                                                        setState(() => privateTripAlerts = trip);
                                                        userDatabase.put(
                                                            'privateFundedTripsAlerts', trip);
                                                      }),
                                                ),
                                              ),
                                        !userIsPremium
                                            ? const SizedBox.shrink()
                                            : BounceInDown(
                                                duration: const Duration(milliseconds: 500),
                                                child: Theme(
                                                  data:
                                                      ThemeData(unselectedWidgetColor: Colors.grey),
                                                  child: CheckboxListTile(
                                                      dense: true,
                                                      activeColor: darkTheme
                                                          ? alertIndicatorColorBrightGreen
                                                          : altHighlightColor,
                                                      secondary: Icon(
                                                          stockWatchAlerts
                                                              ? Icons.notifications_active
                                                              : Icons.notifications,
                                                          size: 15,
                                                          color: stockWatchAlerts
                                                              ? alertIndicatorColorBrightGreen
                                                              : darkThemeTextColor),
                                                      title: Text('Stock Trade Alerts',
                                                          style: Styles.regularStyle
                                                              .copyWith(color: darkThemeTextColor)),
                                                      value: userDatabase.get('stockWatchAlerts'),
                                                      onChanged: (stocks) {
                                                        setState(() => stockWatchAlerts = stocks);
                                                        userDatabase.put(
                                                            'stockWatchAlerts', stocks);
                                                      }),
                                                ),
                                              ),
                                        BounceInDown(
                                          duration: const Duration(milliseconds: 600),
                                          child: Theme(
                                            data: ThemeData(unselectedWidgetColor: Colors.grey),
                                            child: CheckboxListTile(
                                                dense: true,
                                                activeColor: darkTheme
                                                    ? alertIndicatorColorBrightGreen
                                                    : altHighlightColor,
                                                secondary: Icon(
                                                    statementAlerts
                                                        ? Icons.notifications_active
                                                        : Icons.notifications,
                                                    size: 15,
                                                    color: statementAlerts
                                                        ? alertIndicatorColorBrightGreen
                                                        : darkThemeTextColor),
                                                title: Text('Statement Alerts',
                                                    style: Styles.regularStyle
                                                        .copyWith(color: darkThemeTextColor)),
                                                value: userDatabase.get('statementAlerts'),
                                                onChanged: (statement) {
                                                  setState(() => statementAlerts = statement);
                                                  userDatabase.put('statementAlerts', statement);
                                                }),
                                          ),
                                        ),
                                        BounceInDown(
                                          duration: const Duration(milliseconds: 700),
                                          child: Theme(
                                            data: ThemeData(unselectedWidgetColor: Colors.grey),
                                            child: CheckboxListTile(
                                                dense: true,
                                                activeColor: darkTheme
                                                    ? alertIndicatorColorBrightGreen
                                                    : altHighlightColor,
                                                secondary: Icon(
                                                    videoAlerts
                                                        ? Icons.notifications_active
                                                        : Icons.notifications,
                                                    size: 15,
                                                    color: videoAlerts
                                                        ? alertIndicatorColorBrightGreen
                                                        : darkThemeTextColor),
                                                title: Text('Video Alerts',
                                                    style: Styles.regularStyle
                                                        .copyWith(color: darkThemeTextColor)),
                                                value: userDatabase.get('videoAlerts'),
                                                onChanged: (video) {
                                                  setState(() => videoAlerts = video);
                                                  userDatabase.put('videoAlerts', video);
                                                }),
                                          ),
                                        ),
                                        BounceInDown(
                                          duration: const Duration(milliseconds: 1000),
                                          child: Theme(
                                            data: ThemeData(unselectedWidgetColor: Colors.grey),
                                            child: CheckboxListTile(
                                                dense: true,
                                                activeColor: darkTheme
                                                    ? alertIndicatorColorBrightGreen
                                                    : altHighlightColor,
                                                secondary: Icon(
                                                    newProductAlerts
                                                        ? Icons.notifications_active
                                                        : Icons.notifications,
                                                    size: 15,
                                                    color: newProductAlerts
                                                        ? alertIndicatorColorBrightGreen
                                                        : darkThemeTextColor),
                                                title: Text('New Product Alerts',
                                                    style: Styles.regularStyle
                                                        .copyWith(color: darkThemeTextColor)),
                                                value: userDatabase.get('newProductAlerts'),
                                                onChanged: (product) {
                                                  setState(() => newProductAlerts = product);
                                                  userDatabase.put('newProductAlerts', product);
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            const Divider(),
                            BounceInRight(
                              duration: const Duration(milliseconds: 800),
                              child: ListTile(
                                enabled: true,
                                dense: true,
                                leading: AnimatedWidgets.spinningLocation(
                                    context, userDatabase.get('usageInfo'), true,
                                    disabledColor: Colors.white, size: 14, sameColorBright: true),
                                title: Text('Allow Location Data Collection',
                                    style: Styles.regularStyle.copyWith(color: darkThemeTextColor)),
                                subtitle: Text('Tap to update your selection',
                                    style: Styles.regularStyle
                                        .copyWith(color: darkThemeTextColor, fontSize: 12)),
                                // trailing: Icon(Icons.info,
                                //     size: 15, color: darkThemeTextColor),
                                onTap: () {
                                  Navigator.pop(context);
                                  Functions.requestUsageInfo(context);
                                },
                              ),
                            ),
                            // Divider(),
                            userIsSubscribed
                                ? BounceInRight(
                                    duration: const Duration(milliseconds: 1000),
                                    child: ListTile(
                                      enabled: true,
                                      dense: true,
                                      leading: const Icon(Icons.workspace_premium,
                                          size: 15, color: altHighlightColor),
                                      title: Text('Manage Subscription',
                                          style: Styles.regularStyle
                                              .copyWith(color: darkThemeTextColor)),
                                      subtitle: Text('Tap to manage your subscription',
                                          style: Styles.regularStyle
                                              .copyWith(color: darkThemeTextColor, fontSize: 12)),
                                      trailing: const Icon(Icons.launch,
                                          size: 15, color: darkThemeTextColor),
                                      onTap: () => Functions.linkLaunch(context,
                                          customerInfo.managementURL, userDatabase, userIsPremium,
                                          appBarTitle: 'Manage Subscription', interstitialAd: null),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            const Divider(),
                            BounceInRight(
                              duration: const Duration(milliseconds: 1200),
                              child: ListTile(
                                enabled: true,
                                dense: true,
                                leading:
                                    const Icon(Icons.policy, size: 15, color: darkThemeTextColor),
                                title: Text('Privacy Policy',
                                    style: Styles.regularStyle.copyWith(color: darkThemeTextColor)),
                                trailing:
                                    const Icon(Icons.launch, size: 15, color: darkThemeTextColor),
                                // onTap: () =>
                                //     showAboutDialog(context: context),
                                onTap: () => Functions.linkLaunch(
                                    context,
                                    'https://www.privacypolicies.com/live/8a2f59d2-beb1-48f1-afc0-7c7021389169',
                                    userDatabase,
                                    userIsPremium,
                                    appBarTitle: 'Privacy Policy',
                                    interstitialAd: null),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        subtitle: Text(
                          'Data Sources\nMettaCode Developers • Congress.gov • Propublica • Stock Watcher • Google Civic Info',
                          style: Styles.regularStyle.copyWith(
                            fontSize: 11,
                            color: userDatabase.get('darkTheme')
                                ? Colors.grey
                                : Colors.white.withOpacity(0.65),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SharedWidgets.createdByContainer(context, userIsPremium, userDatabase),
            ],
          ),
        ),
      ),
    );
  }
}
