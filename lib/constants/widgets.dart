import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:us_congress_vote_tracker/congress/bill_details.dart';
import 'package:us_congress_vote_tracker/congress/bill_search.dart';
import 'package:us_congress_vote_tracker/congress/lobby_event_detail.dart';
import 'package:us_congress_vote_tracker/congress/lobby_search.dart';
import 'package:us_congress_vote_tracker/congress/market_activity_page.dart';
import 'package:us_congress_vote_tracker/congress/member_details.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/models/floor_actions_model.dart';
import 'package:us_congress_vote_tracker/models/lobby_event_model.dart';
import 'package:us_congress_vote_tracker/models/member_payload_model.dart';
import 'package:us_congress_vote_tracker/models/bill_recent_payload_model.dart';
import 'package:us_congress_vote_tracker/models/office_expenses_total.dart';
import 'package:us_congress_vote_tracker/models/order_detail.dart';
import 'package:us_congress_vote_tracker/models/private_funded_trips_model.dart';
import 'package:us_congress_vote_tracker/models/statements_model.dart';
import 'package:us_congress_vote_tracker/models/vote_payload_model.dart';
import 'package:us_congress_vote_tracker/models/vote_roll_call_model.dart';
import 'package:us_congress_vote_tracker/services/admob/admob_ad_library.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/house_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/senate_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/ecwid/ecwid_order_page.dart';
import 'package:us_congress_vote_tracker/services/ecwid/ecwid_store_model.dart';
import 'package:us_congress_vote_tracker/services/emailjs/emailjs_api.dart';
import 'package:us_congress_vote_tracker/services/propublica/propublica_api.dart';
import 'package:us_congress_vote_tracker/services/revenuecat/rc_purchase_api.dart';

class SharedWidgets {
  static Widget createdByContainer(
      BuildContext context, bool userIsPremium, Box userDatabase) {
    return Container(
      alignment: Alignment.center,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Created by MettaCode',
            style: Styles.regularStyle.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(width: 8),
          InkWell(
              onTap: () async => await Functions.linkLaunch(context,
                  dotenv.env['developerWebLink'], userDatabase, userIsPremium,
                  appBarTitle: dotenv.env['developerName']),
              child: FaIcon(FontAwesomeIcons.earthAmericas,
                  size: 13,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.75))),
          SizedBox(width: 8),
          InkWell(
            onTap: () async => await Functions.linkLaunch(context,
                dotenv.env['devTwitterUrl'], userDatabase, userIsPremium,
                appBarTitle: dotenv.env['@MettaCodeDev']),
            child: Image(
              image: AssetImage('assets/twitter.png'),
              height: 14,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
            ),
          ),
          SizedBox(width: 8),
          InkWell(
            onTap: () async => await Functions.linkLaunch(context,
                dotenv.env['devGitHubUrl'], userDatabase, userIsPremium,
                appBarTitle: dotenv.env['devGitHubUrl']),
            child: Image(
              image: AssetImage('assets/github.png'),
              height: 14,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  static Widget requestUsageInfoSelector(
      BuildContext context, Box userDatabase) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase).listenable(
            keys: ['darkTheme', 'usageInfo', 'subscriptionAlertsList']),
        builder: (context, box, widget) {
          bool darkTheme = userDatabase.get('darkTheme');
          return BounceInUp(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  new Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Expanded(
                          child: new Text('Location Data',
                              style: GoogleFonts.bangers(
                                  color: Colors.white, fontSize: 25)),
                        ),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: darkThemeTextColor))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Text(
                        'The US Congress App does not collect personal information. Activating this option '
                        'will only collect data that will improve app and user experience and '
                        'allow you to use location based features such as local representatives retrieval. You can always '
                        'deactivate this option from the settings menu.',
                        style: Styles.regularStyle.copyWith(fontSize: 14)),
                  ),
                  // Divider(),
                  Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.grey),
                    child: CheckboxListTile(
                      activeColor: darkTheme
                          ? alertIndicatorColorBrightGreen
                          : altHighlightColor,
                      dense: true,
                      enableFeedback: true,
                      secondary: AnimatedWidgets.spinningLocation(
                          context, userDatabase.get('usageInfo'), true,
                          size: 20),
                      title: Text('Allow Data Collection?',
                          style: Styles.regularStyle.copyWith(
                              color: darkTheme ? darkThemeTextColor : null,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      value: userDatabase.get('usageInfo'),
                      onChanged: (usage) async {
                        if (usage) {
                          userDatabase.put('usageInfo', true);
                          userDatabase.put('usageInfoSelected', true);

                          await Functions.getDeviceInfo().then((_) async =>
                              await Functions.getPackageInfo().then(
                                  (_) async => await Functions.getPosition()));

                          await Functions.processCredits(true,
                              isPermanent: false, creditsToAdd: 5);

                          Future.delayed(Duration(milliseconds: 750), () async {
                            // Do something
                            Navigator.pop(context);
                            Messages.showMessage(
                                context: context,
                                message:
                                    'Usage logging has been enabled. You may now use additional app features.',
                                isAlert: false);
                          });

                          logger.d(
                              '***** DBase Usage Info: ${userDatabase.get('usageInfo')} *****');
                        } else {
                          userDatabase.put('usageInfo', false);
                          userDatabase.put('usageInfoSelected', true);
                          // userDatabase.put('packageInfo', {});
                          // userDatabase.put('deviceInfo', {});
                          userDatabase.put('representativesLocation',
                              initialUserData['representativesLocation']);

                          Future.delayed(Duration(milliseconds: 750), () async {
                            // Do something
                            Navigator.maybePop(context);
                            Messages.showMessage(
                                context: context,
                                message:
                                    'Usage logging has been disabled. Some app features have been removed.',
                                isAlert: false);
                          });
                          logger.d(
                              '***** DBase Usage Info: ${userDatabase.get('usageInfo')} *****');
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Container(
                      height: 22,
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                          onPressed: () {
                            userDatabase.put('usageInfoSelected', true);
                            Navigator.pop(context);
                          },
                          child: Text(
                              userDatabase.get('usageInfo')
                                  ? 'Activated'.toUpperCase()
                                  : 'Maybe Later'.toUpperCase(),
                              style: TextStyle(fontSize: 12))),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Widget appUpgradeDialog(BuildContext context, Box userDatabase,
      List<Offering> offers, bool userIsPremium,
      {String whatToShow = 'all'}) {
    List<Package> creditPackages = offers.first.availablePackages
            .where((element) => element.identifier.contains('credits'))
            .toList() ??
        [];
    List<Package> upgradePackages = offers.first.availablePackages
            .where((element) => !element.identifier.contains('credits'))
            .toList() ??
        [];
    bool darkTheme = userDatabase.get('darkTheme');
    List<Package> userPackages = userIsPremium || whatToShow == 'credits'
        ? creditPackages
        : whatToShow == 'upgrades'
            ? upgradePackages
            : offers.first.availablePackages;

    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase).listenable(keys: [
          'darkTheme',
          'credits',
          'permCredits',
          'purchCredits',
          'subscriptionAlertsList'
        ]),
        builder: (context, box, widget) {
          return BounceInUp(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                image: DecorationImage(
                    opacity: 0.15,
                    image: AssetImage(
                        'assets/congress_pic_${random.nextInt(4)}.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.background,
                        BlendMode.color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  new Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.all(5),
                    color: Theme.of(context).primaryColorDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                  userIsPremium || whatToShow == 'credits'
                                      ? Icons.payments
                                      : whatToShow == 'upgrades'
                                          ? Icons.workspace_premium
                                          : Icons.store,
                                  color: altHighlightColor,
                                  size: 20),
                              SizedBox(width: 5),
                              Text(
                                  userIsPremium || whatToShow == 'credits'
                                      ? 'Purchase Credits'
                                      : whatToShow == 'upgrades'
                                          ? 'Premium Options'
                                          : 'Credits & Upgrades',
                                  style: GoogleFonts.bangers(
                                      color: Colors.white, fontSize: 25)),
                              Spacer(),
                              Container(
                                height: 22,
                                alignment: Alignment.centerRight,
                                child: OutlinedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Theme.of(context)
                                                    .primaryColorDark)),
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Maybe Later'.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: darkThemeTextColor))),
                              ),
                            ],
                          ),
                        ),
                        whatToShow == 'credits'
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child: Text(
                                    'Bank ➭ ${userDatabase.get('credits')} App Use | ${userDatabase.get('permCredits')} Support | ${userDatabase.get('purchCredits')} Purchased',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: darkThemeTextColor,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12)),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),

                  SizedBox(height: 5),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          children: userPackages
                              .map(
                                (package) => Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: InkWell(
                                    child: Card(
                                      elevation: 0,
                                      color: darkTheme
                                          ? Theme.of(context)
                                              .highlightColor
                                              .withOpacity(0.5)
                                          : Colors.white.withOpacity(0.5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                      package.storeProduct.title
                                                          .replaceAll(
                                                              ' (US Congress)',
                                                              ''),
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                  Text(
                                                      package
                                                          .storeProduct.description,
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                                package.storeProduct.priceString,
                                                style: Styles.regularStyle
                                                    .copyWith(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () async {
                                      logger.d('MAKING PURCHASE HERE');
                                      Navigator.pop(context);
                                      package.storeProduct.identifier
                                              .contains('credits')
                                          ? await RcPurchaseApi.productPurchase(
                                              package.storeProduct, true)
                                          : await RcPurchaseApi.packagePurchase(
                                              context, package);
                                    },
                                  ),
                                ),
                              )
                              .toList()),
                    ),
                  ),
                  //   ),
                  // ),
                  // SizedBox(height: 5)
                ],
              ),
            ),
          );
        });
  }

  static Widget premiumUpgradeContainer(
      BuildContext context,
      bool userIsPremium,
      bool userIsLegacy,
      bool devUpgraded,
      bool freeTrialUsed,
      Box userDatabase,
      {color = const Color.fromARGB(255, 30, 150, 0)}) {
    return !freeTrialUsed && (freePremiumDaysActive || userDatabase.get('appOpens') < 5)
        ? freeTrialContainer(context, userIsPremium, userIsLegacy, devUpgraded,
            freeTrialUsed, userDatabase)
        : Container(
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            child: Card(
              elevation: 2,
              color: alertIndicatorColorDarkGreen,
              child: new ListTile(
                enabled: true,
                // dense: true,
                leading: AnimatedWidgets.jumpingingPremium(
                    context, !userIsPremium, true,
                    animate: true,
                    infinite: true,
                    disabledColor: altHighlightColor,
                    size: 25),
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text('Premium Upgrade',
                          style: Styles.regularStyle.copyWith(
                              color: darkThemeTextColor,
                              fontWeight: FontWeight.bold)),
                      Text('• Remove advertisements\n• Enable all features',
                          style: Styles.regularStyle.copyWith(
                              color: darkThemeTextColor, fontSize: 12)),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.maybePop(context);
                  Functions.requestInAppPurchase(context, userIsPremium,
                      whatToShow: 'upgrades');
                },
              ),
            ),
          );
  }

  static Widget freePremiumDaysDialog(BuildContext context, Box userDatabase,
      bool userIsPremium, bool userIsLegacy) {
    // final bool _darkTheme = userDatabase.get('darkTheme');
    final bool devUpgraded = userDatabase.get('devUpgraded');
    final bool freeTrialUsed = userDatabase.get('freeTrialUsed');

    return BounceInUp(
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        color: Theme.of(context).colorScheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            new Container(
              alignment: Alignment.centerLeft,
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: Theme.of(context).primaryColorDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Expanded(
                    child: new Text('Premium Days Are Here!',
                        style: GoogleFonts.bangers(
                            color: Colors.white, fontSize: 25)),
                  ),
                  Container(
                    height: 22,
                    alignment: Alignment.centerRight,
                    child: userDatabase.get('userIsPremium')
                        ? SizedBox.shrink()
                        : OutlinedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColorDark)),
                            onPressed: () {
                              Navigator.pop(context);
                              userDatabase.put('freeTrialDismissed', true);
                            },
                            child: Text('Maybe Later'.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 12, color: darkThemeTextColor))),
                  ),
                ],
              ),
            ),
            FlipInX(
              child: ListTile(
                title: Text(
                    'Try $freeTrialPromoDurationDays days of Premium Status on us!',
                    style: Styles.regularStyle
                        .copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'During Premium Days, you get to try out all app features to help decide if you would like to upgrade. Take advantage of this one-time offer!',
                ),
              ),
            ),
            BounceInUp(
                child: freeTrialContainer(context, userIsPremium, userIsLegacy,
                    devUpgraded, freeTrialUsed, userDatabase)),
          ],
        ),
      ),
    );
  }

  static Widget freeTrialEndedDialog(BuildContext context, Box userDatabase,
      bool userIsPremium, bool userIsLegacy) {
    // final bool _darkTheme = userDatabase.get('darkTheme');
    final bool devUpgraded = userDatabase.get('devUpgraded');
    final bool freeTrialUsed = userDatabase.get('freeTrialUsed');

    return BounceInUp(
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        color: Theme.of(context).colorScheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: Theme.of(context).primaryColorDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: new Text('Free Trial Expired',
                        style: GoogleFonts.bangers(
                            color: Colors.white, fontSize: 25)),
                  ),
                  Container(
                    height: 22,
                    alignment: Alignment.centerRight,
                    child: userDatabase.get('userIsPremium')
                        ? SizedBox.shrink()
                        : OutlinedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColorDark)),
                            onPressed: () {
                              Navigator.pop(context);
                              userDatabase.put('freeTrialDismissed', true);
                            },
                            child: Text('Maybe Later'.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 12, color: darkThemeTextColor))),
                  ),
                ],
              ),
            ),
            FlipInX(
              child: ListTile(
                title: Text('Keep Premium Status',
                    style: Styles.regularStyle
                        .copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Upgrade now to continue premium user status and keep all app features active!',
                ),
              ),
            ),
            BounceInUp(
                child: premiumUpgradeContainer(context, userIsPremium,
                    userIsLegacy, devUpgraded, freeTrialUsed, userDatabase)),
          ],
        ),
      ),
    );
  }

  static Widget freeTrialContainer(
      BuildContext context,
      bool userIsPremium,
      bool userIsLegacy,
      bool devUpgraded,
      bool freeTrialUsed,
      Box userDatabase) {
    final userIdList = List.from(userDatabase.get('userIdList'));
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Card(
        elevation: 2,
        color: altHighlightAccentColorDarkRed,
        child: new ListTile(
          enabled: true,
          dense: true,
          leading: AnimatedWidgets.jumpingingPremium(
              context, !userIsPremium, true,
              animate: true,
              infinite: true,
              disabledColor: altHighlightColor,
              size: 20),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text('Claim Premium Trial',
                    style: Styles.regularStyle.copyWith(
                        color: darkThemeTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(
                    'Try $freeTrialPromoDurationDays days of free premium status!',
                    style: Styles.regularStyle
                        .copyWith(color: darkThemeTextColor, fontSize: 12)),
              ],
            ),
          ),
          trailing: FaIcon(FontAwesomeIcons.solidHandPointer,
              size: 16, color: darkThemeTextColor),
          onTap: () async {
            userDatabase.put('userIsPremium', true);
            userDatabase.put('freeTrialUsed', true);
            userDatabase.put('freeTrialStartDate', '${DateTime.now()}');
            userDatabase.put('memberAlerts', true);
            userDatabase.put('billAlerts', true);
            userDatabase.put('lobbyingAlerts', true);
            userDatabase.put('privateFundedTripsAlerts', true);
            userDatabase.put('stockWatchAlerts', true);
            Navigator.maybePop(context);

            /// SHOW POP UP CONFIRMATION MESSAGE
            Messages.showMessage(
                context: context,
                message:
                    '$freeTrialPromoDurationDays days of Premium status has been activated!',
                isAlert: false);

            /// EMAIL TRIAL STARTED NOTIFICATION TO DEVELOPER EMAIL ADDRESS
            try {
              await EmailjsApi.sendFreeTrialEmail(
                'Free trial started by user ${userIdList.last.toString().split('<|:|>')[1]}',
                'USER DETAILS:',
                additionalData1:
                    'USER STATUS => ${userIsPremium ? 'Premium' : userIsLegacy ? 'Legacy' : 'Free'} :: USER IDs => ${userIdList.map((e) => '${e.split('<|:|>')[0]} ${e.split('<|:|>')[1]} created ${dateWithTimeFormatter.format(DateTime.parse(e.split('<|:|>')[2]).toUtc())} UTC')} :: DLC => ${userDatabase.get('devLegacyCode')} - DPC => ${userDatabase.get('devPremiumCode')} - FTC => ${userDatabase.get('freeTrialCode')}',
                additionalData2:
                    'USER EMAILs => ${List.from(userDatabase.get('userEmailList')).map((e) => '${e.split('<|:|>')[0]} added ${dateWithTimeFormatter.format(DateTime.parse(e.split('<|:|>')[1]).toUtc())} UTC')}',
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
          },
        ),
      ),
    );
  }

  static Widget latestUpdates(BuildContext context, Box userDatabase) {
    final bool _darkTheme = userDatabase.get('darkTheme');
    final List<String> appUpdatesList =
        List.from(userDatabase.get('appUpdatesList'));
    appUpdatesList
        .sort((a, b) => a.split('<|:|>')[2].compareTo(b.split('<|:|>')[2]));
    logger.d('***** APP UPDATES LIST: $appUpdatesList *****');
    return BounceInUp(
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        color: Theme.of(context).colorScheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            new Container(
              alignment: Alignment.centerLeft,
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: Theme.of(context).primaryColorDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Expanded(
                    child: new Text('Recently Updated',
                        style: GoogleFonts.bangers(
                            color: Colors.white, fontSize: 25)),
                  ),
                  Container(
                    height: 22,
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).primaryColorDark)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Okay'.toUpperCase(),
                            style: TextStyle(
                                fontSize: 12, color: darkThemeTextColor))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                child: ListView(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    children: appUpdatesList
                        .map(
                          (update) => FlipInX(
                            child: ListTile(
                              leading: Icon(Icons.update,
                                  color: _darkTheme
                                      ? altHighlightColor
                                      : Theme.of(context).primaryColorDark,
                                  size: 20),
                              title: Text(update.split('<|:|>')[0],
                                  style: Styles.regularStyle
                                      .copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                update.split('<|:|>')[1],
                              ),
                              trailing: Icon(Icons.circle,
                                  size: 15,
                                  color: update.split('<|:|>')[2] == 'high'
                                      ? Theme.of(context).colorScheme.error
                                      : update.split('<|:|>')[2] == 'medium'
                                          ? altHighlightColor
                                          : Theme.of(context).disabledColor),
                            ),
                          ),
                        )
                        .toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget ratingOptions(
      BuildContext context, Box userDatabase, bool userIsPremium) {
    return BounceInUp(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            new Container(
              alignment: Alignment.centerLeft,
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: Theme.of(context).primaryColorDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Expanded(
                    child: new Text('Enjoying the app?',
                        style: GoogleFonts.bangers(
                            color: Colors.white, fontSize: 25)),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: darkThemeTextColor))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                  'Please give us a rating and let us know what you think!',
                  style: Styles.regularStyle.copyWith(fontSize: 16)),
            ),
            // Expanded(
            //   child: Scrollbar(
            //     thumbVisibility: true,
            //     trackVisibility: true,
            //     child:
            ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              // crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                FlipInX(
                  child: ratingOptionsListTile(
                      userDatabase,
                      context,
                      'google_play_icon.png',
                      googleAppLink,
                      'Google Play',
                      userIsPremium),
                ),
                // FlipInX(
                //   duration: Duration(milliseconds: 500),
                //   child: ratingOptionsListTile(
                //       userDatabase,
                //       context,
                //       'samsung_galaxy_icon.png',
                //       samsungAppLink,
                //       'Samsung Galaxy'),
                // ),
                // FlipInX(
                //   duration: Duration(milliseconds: 1000),
                //   child: ratingOptionsListTile(userDatabase, context,
                //       'amazon_icon.png', amazonAppLink, 'Amazon'),
                // ),
              ],
            ),
            //   ),
            // ),
            SizedBox(height: 5)
          ],
        ),
      ),
    );
  }

  static Widget ratingOptionsListTile(
      Box<dynamic> userDatabase,
      BuildContext context,
      String imageFileName,
      String appLink,
      String appStore,
      bool userIsPremium) {
    return FlipInX(
      child: Card(
        elevation: 0,
        color: Theme.of(context).highlightColor.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
              leading: Image.asset('assets/$imageFileName', height: 20),
              trailing: const Icon(Icons.launch, size: 16),
              title: Text('$appStore App Store'),
              onTap: () {
                Navigator.pop(context);
                Functions.linkLaunch(
                        context, appLink, userDatabase, userIsPremium,
                        appBarTitle: 'Thank you for your opinions!')
                    .then((_) async {
                  userDatabase.put('appRated', true);
                  await Functions.processCredits(true,
                      isPermanent: true, creditsToAdd: 100);
                });
              }),
        ),
      ),
    );
  }

  static Widget supportOptions(BuildContext context, Box userDatabase,
      RewardedAd ad, List<bool> userLevels) {
    // bool userIsDev = userLevels[0];
    bool userIsPremium = userDatabase.get('userIsPremium');
    bool userIsLegacy = userLevels[2];

    final bool devUpgraded = userDatabase.get('devUpgraded');
    final bool freeTrialUsed = userDatabase.get('freeTrialUsed');
    final bool darkTheme = userDatabase.get('darkTheme');
    final bool appRated = userDatabase.get('appRated');

    return BounceInUp(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              opacity: 0.15,
              image: AssetImage('assets/congress_pic_${random.nextInt(4)}.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.background, BlendMode.color)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            new Container(
              alignment: Alignment.centerLeft,
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: Theme.of(context).primaryColorDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Expanded(
                    child: new Text('Your support is appreciated',
                        style: GoogleFonts.bangers(
                            color: Colors.white, fontSize: 25)),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: darkThemeTextColor))
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            //   child: Text('Please consider...',
            //       style: Styles.regularStyle.copyWith(fontSize: 16)),
            // ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                child: ListView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    !userIsPremium /*&& !userIsLegacy*/
                        ? FlipInY(
                            child: premiumUpgradeContainer(
                                context,
                                userIsPremium,
                                userIsLegacy,
                                devUpgraded,
                                freeTrialUsed,
                                userDatabase))
                        : SizedBox.shrink(),
                    ad != null &&
                            ad.responseInfo.responseId !=
                                userDatabase.get('rewardedAdId')
                        ? FlipInX(
                            child: Card(
                              elevation: 0,
                              color: darkTheme
                                  ? Theme.of(context)
                                      .highlightColor
                                      .withOpacity(0.5)
                                  : Colors.white.withOpacity(0.5),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: ListTile(
                                  leading: Icon(Icons.live_tv,
                                      color: userDatabase.get('darkTheme') ==
                                              true
                                          ? altHighlightColor
                                          : Theme.of(context).primaryColorDark,
                                      size: 20),
                                  trailing:
                                      const Icon(Icons.touch_app, size: 20),
                                  title: const Text('Watch a short ad'),
                                  subtitle: const Text(
                                      'Receive additional PERMANENT credits for watching!'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    AdMobLibrary().rewardedAdShow(ad);
                                  },
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    FlipInX(
                      duration: Duration(milliseconds: 1000),
                      child: Card(
                        elevation: 0,
                        color: darkTheme
                            ? Theme.of(context).highlightColor.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            enabled: true,
                            enableFeedback: true,
                            leading: Icon(Icons.handshake,
                                size: 20,
                                color: userDatabase.get('darkTheme') == true
                                    ? altHighlightColor
                                    : Theme.of(context).primaryColorDark),
                            title: Text('Share The App'),
                            subtitle: const Text(
                                'Receive additional PERMANENT credits for sharing the app with family, friends and colleagues!'),
                            trailing: Icon(Icons.share, size: 16),
                            onTap: () => Messages.shareContent(true),
                          ),
                        ),
                      ),
                    ),
                    appRated
                        ? SizedBox.shrink()
                        : FlipInX(
                            duration: Duration(milliseconds: 500),
                            child: Card(
                              elevation: 0,
                              color: darkTheme
                                  ? Theme.of(context)
                                      .highlightColor
                                      .withOpacity(0.5)
                                  : Colors.white.withOpacity(0.5),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: ListTile(
                                  enabled: true,
                                  enableFeedback: true,
                                  leading: Icon(Icons.star,
                                      size: 20,
                                      color: userDatabase.get('darkTheme') ==
                                              true
                                          ? altHighlightColor
                                          : Theme.of(context).primaryColorDark),
                                  title: Text('Rate The App'),
                                  subtitle: const Text(
                                      'Let us know how we\'re doing, and if there is something we can improve on.'),
                                  trailing: Icon(Icons.launch, size: 16),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: false,
                                        enableDrag: true,
                                        context: context,
                                        // constraints: BoxConstraints(
                                        //     maxWidth: MediaQuery.of(context)
                                        //         .size
                                        //         .width),
                                        builder: (context) {
                                          return BounceInUp(
                                              child: ratingOptions(context,
                                                  userDatabase, userIsPremium));
                                        });
                                  },
                                ),
                              ),
                            ),
                          ),
                    FlipInX(
                      duration: Duration(milliseconds: 500),
                      child: Card(
                        elevation: 0,
                        color: darkTheme
                            ? Theme.of(context).highlightColor.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            enabled: true,
                            enableFeedback: true,
                            leading: Icon(Icons.star,
                                size: 20,
                                color: userDatabase.get('darkTheme') == true
                                    ? altHighlightColor
                                    : Theme.of(context).primaryColorDark),
                            title: Text('Get App Credits'),
                            subtitle: const Text(
                                'Use app credits to buy in-app merchandise.'),
                            trailing: Icon(Icons.launch, size: 16),
                            onTap: () async {
                              Navigator.pop(context);
                              Functions.requestInAppPurchase(
                                  context, userIsPremium,
                                  whatToShow: 'credits');
                            },
                          ),
                        ),
                      ),
                    ),
                    FlipInX(
                      duration: Duration(milliseconds: 1000),
                      child: Card(
                        elevation: 0,
                        color: darkTheme
                            ? Theme.of(context).highlightColor.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            enabled: true,
                            enableFeedback: true,
                            leading: Icon(Icons.campaign,
                                size: 20,
                                color: userDatabase.get('darkTheme') == true
                                    ? altHighlightColor
                                    : Theme.of(context).primaryColorDark),
                            title: Text('iOS GoFundMe'),
                            subtitle: const Text(
                                'Help us with development for an iPhone version of US Congress App by donating to our GoFundMe campaign'),
                            trailing: Icon(Icons.launch, size: 16),
                            onTap: () => Functions.linkLaunch(
                                context,
                                'https://gofund.me/4e761be9',
                                userDatabase,
                                userIsPremium,
                                appBarTitle: 'iOS App GoFundMe Campaign'),
                          ),
                        ),
                      ),
                    ),
                    FlipInX(
                      duration: Duration(milliseconds: 1000),
                      child: Card(
                        elevation: 0,
                        color: darkTheme
                            ? Theme.of(context).highlightColor.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            enabled: true,
                            enableFeedback: true,
                            leading: Icon(Icons.volunteer_activism,
                                size: 20,
                                color: userDatabase.get('darkTheme') == true
                                    ? altHighlightColor
                                    : Theme.of(context).primaryColorDark),
                            title: Text('Developer Support Options'),
                            subtitle: const Text(
                                'Additional support options can be found on our humble website'),
                            trailing: Icon(Icons.launch, size: 16),
                            onTap: () => Functions.linkLaunch(
                                context,
                                dotenv.env['developerWebLink'],
                                userDatabase,
                                userIsPremium,
                                appBarTitle: dotenv.env['developerWebLink']),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  static Widget recentBillsList(
      BuildContext context,
      Box userDatabase,
      List<UpdatedBill> recentBills,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    logger.d('***** ALL BILLS: ${recentBills.map((e) => e.billId)} *****');

    // bool viewMore = false;
    Color _thisPanelColor = Theme.of(context).primaryColorDark;
    String _queryString = '';

    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase)
            .listenable(keys: ['darkTheme', 'subscriptionAlertsList']),
        builder: (context, box, widget) {
          logger.d(
              '***** ALL SUBSCRIPTIONS (recent bills page): ${userDatabase.get('subscriptionAlertsList')} *****');

          bool _darkTheme = userDatabase.get('darkTheme');

          recentBills = recentBills
                  .where((bill) =>
                      List.from(userDatabase.get('subscriptionAlertsList')).any(
                          (element) => element
                              .toString()
                              .toLowerCase()
                              .startsWith('bill_${bill.billId}'.toLowerCase())))
                  .toList() +
              recentBills
                  .where((event) => !List.from(
                          userDatabase.get('subscriptionAlertsList'))
                      .any((element) => element
                          .toString()
                          .toLowerCase()
                          .startsWith('bill_${event.billId}'.toLowerCase())))
                  .toList();

          return BounceInUp(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                image: DecorationImage(
                    opacity: 0.15,
                    image: AssetImage(
                        'assets/congress_pic_${random.nextInt(4)}.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.background,
                        BlendMode.color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: _thisPanelColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Expanded(
                          child: new Text('Recent Bills',
                              style: GoogleFonts.bangers(
                                  color: Colors.white, fontSize: 25)),
                        ),
                        SizedBox(
                          height: 20,
                          child: OutlinedButton.icon(
                              icon: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 12,
                              ),
                              label: Text('Search',
                                  style: Styles.regularStyle.copyWith(
                                      color: Colors.white, fontSize: 12)),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  enableDrag: true,
                                  builder: (context) => Container(
                                    color: Colors.transparent,
                                    margin: const EdgeInsets.only(
                                        top: 5, left: 15, right: 15),
                                    height: 400,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: TextField(
                                            keyboardType: TextInputType.text,
                                            textAlign: TextAlign.center,
                                            autocorrect: true,
                                            autofocus: true,
                                            enableSuggestions: true,
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText: 'Enter your search',
                                            ),
                                            onChanged: (val) {
                                              _queryString = val;
                                            },
                                          ),
                                        ),
                                        new ElevatedButton.icon(
                                          icon: Icon(Icons.search),
                                          onPressed: () {
                                            Navigator.pop(context);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BillSearch(
                                                        _queryString,
                                                        houseStockWatchList,
                                                        senateStockWatchList),
                                              ),
                                            );
                                          },
                                          label: Text(
                                            'Search',
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                        // new Text('${_finalLobbyingEvents.length} Label 1 | ',
                        //     // '${_finalLobbyingEvents.where((element) => element.toString().startsWith('lobby_')).length} Label 1 | ',
                        //     // '${_finalLobbyingEvents.where((element) => element.toString().startsWith('bill_')).length} Label 2',
                        //     style: TextStyle(
                        //         color: Color(0xffffffff),
                        //         fontStyle: FontStyle.italic,
                        //         fontSize: 12)),
                      ],
                    ),
                  ),
                  // Divider(
                  //   color: Colors.transparent,
                  // ),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                          physics: BouncingScrollPhysics(),
                          primary: false,
                          shrinkWrap: true,
                          children: recentBills
                              .map(
                                (_thisRecentBill) => StatefulBuilder(
                                    builder: (context, setState) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FlipInX(
                                        child: Card(
                                          elevation: 0,
                                          color: _darkTheme
                                              ? Theme.of(context)
                                                  .highlightColor
                                                  .withOpacity(0.5)
                                              : Colors.white.withOpacity(0.5),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: ListTile(
                                              dense: true,
                                              leading: _thisRecentBill.billId
                                                              .isNotEmpty !=
                                                          null &&
                                                      _thisRecentBill
                                                          .billId.isNotEmpty &&
                                                      List.from(userDatabase.get('subscriptionAlertsList'))
                                                          .any((element) => element
                                                              .toString()
                                                              .toLowerCase()
                                                              .toString()
                                                              .startsWith(
                                                                  'bill_${_thisRecentBill.billId}'
                                                                      .toLowerCase()))
                                                  ? AnimatedWidgets.flashingEye(
                                                      context, true, false,
                                                      size: 16)
                                                  : FaIcon(FontAwesomeIcons.scroll,
                                                      size: 15),
                                              title: billSimpleTextGroup(
                                                  context,
                                                  _thisPanelColor,
                                                  _darkTheme,
                                                  'BILL ID: ${_thisRecentBill.billId}',
                                                  _thisRecentBill.shortTitle),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 3),
                                                  Text(
                                                      'Last Action: ${dateWithDayFormatter.format(_thisRecentBill.latestMajorActionDate)}\nLast Vote: ${_thisRecentBill.lastVote == null ? 'Unavailable' : dateWithDayFormatter.format(_thisRecentBill.lastVote)}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                  SizedBox(height: 3),
                                                  Text(
                                                      '${_thisRecentBill.latestMajorAction}',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                ],
                                              ),
                                              trailing: FaIcon(
                                                  FontAwesomeIcons.binoculars,
                                                  size: 15),
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BillDetail(
                                                          _thisRecentBill
                                                              .billUri,
                                                          houseStockWatchList,
                                                          senateStockWatchList),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              )
                              .toList()),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  static Widget billSimpleTextGroup(BuildContext context, Color headerColor,
      bool darkTheme, String headerText, String contentText,
      {int maxLines = 2,
      double contentFontSize = 14,
      FontWeight contentFontWeight = FontWeight.bold}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headerText.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Styles.regularStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: darkTheme ? Colors.grey : headerColor,
            )),
        Text(
          contentText,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: Styles.regularStyle
              .copyWith(fontSize: 14, fontWeight: contentFontWeight),
        ),
      ],
    );
  }

  static Widget recentVotesList(
      BuildContext context,
      Box userDatabase,
      List<Vote> recentVotes,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    logger.d('***** ALL VOTES: ${recentVotes.map((e) => e.bill.billId)} *****');
    List<RcPosition> positions = [];
    // bool viewMore = false;
    bool gettingRollCall = false;
    Color _thisPanelColor = Theme.of(context).primaryColorDark;

    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase)
            .listenable(keys: ['darkTheme', 'subscriptionAlertsList']),
        builder: (context, box, widget) {
          logger.d(
              '***** ALL SUBSCRIPTIONS (recent votes page): ${List.from(userDatabase.get('subscriptionAlertsList')).map((e) => e.toString().split('_')[1])} *****');

          bool _darkTheme = userDatabase.get('darkTheme');
          List<Vote> _subscribed = recentVotes
              .where((vote) =>
                  List.from(userDatabase.get('subscriptionAlertsList')).any(
                      (element) => element.toString().toLowerCase().startsWith(
                          'bill_${vote.bill.billId}'.toLowerCase())))
              .toList();

          List<Vote> _notSubscribed = recentVotes
              .where((vote) =>
                  !List.from(userDatabase.get('subscriptionAlertsList')).any(
                      (element) => element.toString().toLowerCase().startsWith(
                          'bill_${vote.bill.billId}'.toLowerCase())))
              .toList();

          _subscribed.sort((a, b) => b.rollCall.compareTo(a.rollCall));
          _notSubscribed.sort((a, b) => b.rollCall.compareTo(a.rollCall));

          recentVotes = _subscribed + _notSubscribed;

          return BounceInUp(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                image: DecorationImage(
                    opacity: 0.15,
                    image: AssetImage(
                        'assets/congress_pic_${random.nextInt(4)}.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.background,
                        BlendMode.color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: _thisPanelColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: new Text('Recent Votes',
                              style: GoogleFonts.bangers(
                                  color: Colors.white, fontSize: 25)),
                        ),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: darkThemeTextColor))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                          physics: BouncingScrollPhysics(),
                          primary: false,
                          shrinkWrap: true,
                          children: recentVotes
                              .map(
                                (_thisRecentVote) => StatefulBuilder(
                                    builder: (context, setState) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FlipInX(
                                        child: Card(
                                          elevation: 0,
                                          color: _darkTheme
                                              ? Theme.of(context)
                                                  .highlightColor
                                                  .withOpacity(0.5)
                                              : Colors.white.withOpacity(0.5),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: ListTile(
                                              dense: true,
                                              leading: _thisRecentVote.bill
                                                          .billId.isNotEmpty &&
                                                      List.from(userDatabase.get('subscriptionAlertsList'))
                                                          .any((element) => element
                                                              .toString()
                                                              .toLowerCase()
                                                              .startsWith(
                                                                  'bill_${_thisRecentVote.bill.billId}'
                                                                      .toLowerCase()))
                                                  ? AnimatedWidgets.flashingEye(
                                                      context, true, false,
                                                      size: 13)
                                                  : FaIcon(
                                                      FontAwesomeIcons.gavel,
                                                      size: 15),
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  voteSimpleTextGroup(
                                                      context,
                                                      _thisPanelColor,
                                                      _darkTheme,
                                                      '${_thisRecentVote.bill.billId} : ROLL CALL# ${_thisRecentVote.rollCall}',
                                                      _thisRecentVote.question),
                                                ],
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      '${_thisRecentVote.description}',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                        child: OutlinedButton(
                                                            onPressed: () {},
                                                            child: Text(
                                                                _thisRecentVote
                                                                        .result
                                                                        .toString()
                                                                        .toLowerCase()
                                                                        .contains(
                                                                            'result.')
                                                                    ? _thisRecentVote.result.toString().toUpperCase() ==
                                                                            'RESULT.AGREED_TO'
                                                                        ? 'AGREED'
                                                                        : _thisRecentVote
                                                                            .result
                                                                            .toString()
                                                                            .toUpperCase()
                                                                            .replaceFirst('RESULT.',
                                                                                '')
                                                                    : 'RECORDED',
                                                                style: Styles
                                                                    .regularStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            14)),
                                                            style: ButtonStyle(
                                                                foregroundColor:
                                                                    darkThemeTextMSPColor,
                                                                backgroundColor: _thisRecentVote.result.toString().toUpperCase() ==
                                                                            'RESULT.PASSED' ||
                                                                        _thisRecentVote.result.toString().toUpperCase() ==
                                                                            'RESULT.AGREED_TO'
                                                                    ? alertIndicatorMSPColorDarkGreen
                                                                    : _thisRecentVote.result.toString().toUpperCase() ==
                                                                            'RESULT.FAILED'
                                                                        ? errorMSPColor
                                                                        : disabledMSPColorGray)),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                          '${dateWithDayFormatter.format(_thisRecentVote.date)} ${timeFormatter.format(DateTime.parse('0000-00-00 ${_thisRecentVote.time}'))}',
                                                          style: Styles
                                                              .regularStyle
                                                              .copyWith(
                                                                  fontSize: 11))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              trailing: FaIcon(
                                                  FontAwesomeIcons.binoculars,
                                                  size: 15),
                                              onTap: () async {
                                                setState(() =>
                                                    gettingRollCall = true);
                                                bool positionsAvailable = false;
                                                positions = await Functions
                                                    .getRollCallPositions(
                                                        _thisRecentVote
                                                            .congress,
                                                        _thisRecentVote.chamber ==
                                                                    null ||
                                                                _thisRecentVote
                                                                        .chamber
                                                                        .name
                                                                        .toLowerCase() ==
                                                                    'chamber.senate'
                                                            ? 'senate'
                                                            : 'house',
                                                        _thisRecentVote.session,
                                                        _thisRecentVote
                                                            .rollCall);
                                                positionsAvailable =
                                                    positions.isEmpty
                                                        ? false
                                                        : true;
                                                setState(() {
                                                  gettingRollCall = false;
                                                });

                                                Navigator.maybePop(context);

                                                await showModalBottomSheet(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isScrollControlled: true,
                                                  enableDrag: true,
                                                  context: context,
                                                  builder: (context) =>
                                                      SingleChildScrollView(
                                                    child: getVoteTile(
                                                        userDatabase,
                                                        _thisRecentVote,
                                                        positionsAvailable,
                                                        houseStockWatchList,
                                                        senateStockWatchList),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      gettingRollCall
                                          ? LinearProgressIndicator()
                                          : SizedBox.shrink(),
                                    ],
                                  );
                                }),
                              )
                              .toList()),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Widget voteSimpleTextGroup(BuildContext context, Color headerColor,
      bool darkTheme, String headerText, String contentText,
      {int maxLines = 3,
      double contentFontSize = 14,
      FontWeight contentFontWeight = FontWeight.bold}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headerText.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Styles.regularStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: darkTheme ? Colors.grey : headerColor,
            )),
        Text(
          contentText,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: Styles.regularStyle
              .copyWith(fontSize: 14, fontWeight: contentFontWeight),
        ),
      ],
    );
  }

  /// VOTE TILE
  static Widget getVoteTile(
      Box userDatabase,
      Vote thisVote,
      bool rollCallAvailable,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    bool darkTheme = userDatabase.get('darkTheme');
    bool _validUri = Uri.parse(thisVote.bill.apiUri).isAbsolute;
    bool _gettingPositions = false;

    logger.d('^^^^^ VOTE TILE INFORMATION: ${thisVote.toJson()} ^^^^^');
    debugPrint('^^^^^ THIS VOTE RESULT: ${thisVote.result.toString()}');

    // return new ValueListenableBuilder(
    //     valueListenable:
    //         Hive.box(appDatabase).listenable(keys: userDatabase.keys.toList()),
    //     builder: (context, box, widget) {
    return StatefulBuilder(builder: (context, setState) {
      return new Card(
        elevation: 3.0,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            image: DecorationImage(
                opacity: 0.15,
                image:
                    AssetImage('assets/congress_pic_${random.nextInt(4)}.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.background, BlendMode.color)),
          ),
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(5),
              ),
              SizedBox(
                height: 30,
                child: Row(
                  children: <Widget>[
                    thisVote.bill.billId.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text('CONSIDERING',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                          )
                        : TextButton.icon(
                            icon: FaIcon(
                              FontAwesomeIcons.scroll,
                              size: 12,
                              color: darkTheme ? Colors.white : Colors.black,
                            ),
                            onPressed: () {},
                            label: new Text(thisVote.bill.billId.toUpperCase(),
                                style: Styles.voteTileTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      darkTheme ? Colors.white : Colors.black,
                                ))),
                  ],
                ),
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Container(
                      margin: new EdgeInsets.symmetric(
                          vertical: 2.5, horizontal: 10.0),
                      child: new Text(thisVote.description,
                          style:
                              Styles.voteTileTextStyle.copyWith(fontSize: 14)),
                    ),
                  ),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Container(
                      margin: new EdgeInsets.symmetric(
                          vertical: 2.5, horizontal: 10.0),
                      child: new Text('Latest Action:',
                          style: Styles.voteTileTextStyle.copyWith(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Container(
                      margin: new EdgeInsets.symmetric(
                          vertical: 2.5, horizontal: 10.0),
                      child: new Text(thisVote.bill.latestAction,
                          style:
                              Styles.voteTileTextStyle.copyWith(fontSize: 14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              new Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: new Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3)),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                        flex: 3,
                        child: new Container(
                          margin: new EdgeInsets.all(10.0),
                          // width: 150.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              new Text('Question',
                                  style: Styles.voteTileTextStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              new Text(thisVote.question.toString(),
                                  style: Styles.voteTileTextStyle
                                      .copyWith(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      new Expanded(
                        flex: 2,
                        child: new Container(
                          margin: new EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FaIcon(
                                      thisVote.result
                                                  .toString()
                                                  .toUpperCase() ==
                                              'RESULT.FAILED'
                                          ? FontAwesomeIcons.xmark
                                          : FontAwesomeIcons.checkToSlot,
                                      size: 13,
                                      color: thisVote.result
                                                  .toString()
                                                  .toUpperCase() ==
                                              'RESULT.FAILED'
                                          ? const Color.fromARGB(
                                              255, 255, 17, 0)
                                          : thisVote.result
                                                          .toString()
                                                          .toUpperCase() ==
                                                      'RESULT.PASSED' ||
                                                  thisVote.result
                                                          .toString()
                                                          .toUpperCase() ==
                                                      'RESULT.AGREED_TO'
                                              ? darkTheme
                                                  ? alertIndicatorColorBrightGreen
                                                  : alertIndicatorColorDarkGreen
                                              : const Color.fromRGBO(
                                                  158, 158, 158, 1)),
                                  SizedBox(width: 5),
                                  Text(
                                    thisVote.result == null
                                        ? 'RECORDED'
                                        : thisVote.result
                                                    .toString()
                                                    .toUpperCase() ==
                                                'RESULT.AGREED_TO'
                                            ? 'AGREED'
                                            : '${thisVote.result.toString().replaceFirst('Result.', '')}',
                                    style: new TextStyle(
                                        color: thisVote.result
                                                        .toString()
                                                        .toUpperCase() ==
                                                    'RESULT.PASSED' ||
                                                thisVote.result
                                                        .toString()
                                                        .toUpperCase() ==
                                                    'RESULT.AGREED_TO'
                                            ? darkTheme
                                                ? alertIndicatorColorBrightGreen
                                                : alertIndicatorColorDarkGreen
                                            : thisVote.result
                                                        .toString()
                                                        .toUpperCase() ==
                                                    'RESULT.FAILED'
                                                ? const Color.fromARGB(
                                                    255, 255, 17, 0)
                                                : const Color.fromRGBO(
                                                    158, 158, 158, 1),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              new Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  new Text(
                                      '${formatter.format(thisVote.date.toLocal())}\n${timeFormatter.format(DateTime.parse('${thisVote.date.toLocal().toString().split(' ')[0]} ${thisVote.time}.000'))} ET',
                                      textAlign: TextAlign.end,
                                      style: Styles.voteTileTextStyle
                                          .copyWith(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      !_validUri
                          ? const SizedBox.shrink()
                          : Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: OutlinedButton.icon(
                                  icon: AnimatedWidgets.flashingEye(
                                      context,
                                      List.from(userDatabase
                                              .get('subscriptionAlertsList'))
                                          .any((element) => element
                                              .toString()
                                              .contains(thisVote.bill.billId
                                                  .toLowerCase())),
                                      false,
                                      size: 10,
                                      reverseContrast: false),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.15)),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Theme.of(context)
                                                  .highlightColor)),
                                  label: new Text('Bill Detail',
                                      style: TextStyle(
                                          color: userDatabase.get('darkTheme')
                                              ? darkThemeTextColor
                                              : Color(0xff000000))),
                                  onPressed: () => Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => new BillDetail(
                                          thisVote.bill.apiUri,
                                          houseStockWatchList,
                                          senateStockWatchList),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      new Expanded(
                        child: new OutlinedButton.icon(
                            icon: rollCallAvailable
                                ? _gettingPositions
                                    ? AnimatedWidgets.circularProgressWatchtower(
                                        context,
                                        widthAndHeight: 10,
                                        strokeWidth: 2,
                                        isFullScreen: false)
                                    : Pulse(
                                        infinite: true,
                                        delay: Duration(milliseconds: 1000),
                                        duration: Duration(milliseconds: 500),
                                        child: Icon(Icons.check_circle,
                                            size: 10,
                                            color: userDatabase.get('darkTheme')
                                                ? alertIndicatorColorBrightGreen
                                                : alertIndicatorColorDarkGreen),
                                      )
                                : Icon(Icons.remove_circle,
                                    size: 12,
                                    color: Theme.of(context).colorScheme.error),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.15)),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).highlightColor)),
                            label: Text('Roll Call #${thisVote.rollCall}',
                                style: TextStyle(
                                    color: darkTheme
                                        ? darkThemeTextColor
                                        : Color(0xff000000))),
                            onPressed: rollCallAvailable
                                ? () async {
                                    // if (rollCallAvailable) {
                                    setState(() => _gettingPositions = true);
                                    final List<RcPosition> thisVotepositions =
                                        await Functions.getRollCallPositions(
                                            thisVote.congress,
                                            thisVote.chamber == null ||
                                                    thisVote.chamber.name
                                                            .toLowerCase() ==
                                                        'chamber.senate'
                                                ? 'senate'
                                                : 'house',
                                            thisVote.session,
                                            thisVote.rollCall);
                                    setState(() => _gettingPositions = false);
                                    await showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      enableDrag: true,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) => SafeArea(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 100),
                                          child: rollCallList(
                                              context,
                                              userDatabase,
                                              thisVote,
                                              thisVotepositions,
                                              houseStockWatchList,
                                              senateStockWatchList),
                                        ),
                                      ),
                                    );
                                  }
                                : null),
                      ),
                    ],
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3)),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsetsDirectional.only(end: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                  color: Colors.grey[350], width: 0.5),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              new Text('Party',
                                  style: Styles.voteTileTextStyle
                                      .copyWith(fontWeight: FontWeight.bold)),
                              new Text('Yeas',
                                  style: Styles.voteTileTextStyle
                                      .copyWith(fontWeight: FontWeight.bold)),
                              new Text('Nays',
                                  style: Styles.voteTileTextStyle
                                      .copyWith(fontWeight: FontWeight.bold)),
                              new Text('No Vote',
                                  style: Styles.voteTileTextStyle
                                      .copyWith(fontWeight: FontWeight.bold)),
                              new Text('Present',
                                  style: Styles.voteTileTextStyle
                                      .copyWith(fontWeight: FontWeight.bold)),
                              new Text('Majority?',
                                  style: Styles.voteTileTextStyle
                                      .copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            new Text(
                              'Democrat',
                              style: new TextStyle(
                                  color:
                                      darkTheme == true ? null : democratColor,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            thisVote.democratic.yes == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(thisVote.democratic.yes.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.democratic.no == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(thisVote.democratic.no.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.democratic.notVoting == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(
                                    thisVote.democratic.notVoting.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.democratic.present == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(
                                    thisVote.democratic.present.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.democratic.majorityPosition == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(
                                    '${thisVote.democratic.majorityPosition.toString().replaceFirst('MajorityPosition.', '')}',
                                    style: Styles.voteTileTextStyle),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            new Text(
                              'Republican',
                              style: new TextStyle(
                                  color: darkTheme == true
                                      ? null
                                      : republicanColor,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            thisVote.republican.yes == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(thisVote.republican.yes.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.republican.no == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(thisVote.republican.no.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.republican.notVoting == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(
                                    thisVote.republican.notVoting.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.republican.present == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(
                                    thisVote.republican.present.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.republican.majorityPosition == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(
                                    '${thisVote.republican.majorityPosition.toString().replaceFirst('MajorityPosition.', '')}',
                                    style: Styles.voteTileTextStyle),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            new Text(
                              'Independent',
                              style: Styles.voteTileTextStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: darkTheme == true
                                      ? null
                                      : independentColor),
                            ),
                            thisVote.independent.yes == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(thisVote.independent.yes.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.independent.no == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(thisVote.independent.no.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.independent.notVoting == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(
                                    thisVote.independent.notVoting.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.independent.present == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(
                                    thisVote.independent.present.toString(),
                                    style: Styles.voteTileTextStyle),
                            thisVote.independent.majorityPosition == null
                                ? new Text('N/A',
                                    style: Styles.voteTileTextStyle)
                                : new Text(
                                    '${thisVote.independent.majorityPosition.toString().replaceFirst('null', 'N/A')}',
                                    style: Styles.voteTileTextStyle),
                          ],
                        ),
                      ),
                    ],
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

  static Widget rollCallList(
      BuildContext context,
      Box userDatabase,
      Vote vote,
      List<RcPosition> positions,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    logger.d('***** ALL MEMBERS: ${positions.length} *****');
    final List<String> following =
        List.from(userDatabase.get('subscriptionAlertsList'));
    logger.d('***** FOLLOWING: ${following.map((e) => e)} *****');
    List<RcPosition> followed = positions
            .where((member) => following.any((element) => element
                .toLowerCase()
                .startsWith('member_${member.memberId.toLowerCase()}')))
            .toList() ??
        [];
    logger.d(
        '***** FOLLOWED MEMBERS: ${followed.length} => ${followed.map((e) => e.name)} *****');
    positions.removeWhere((member) => followed.contains(member));
    logger.d('***** ALL MEMBERS REDUCED: ${positions.length} *****');
    List<RcPosition> sortedPositions = followed + positions;
    logger.d('***** FINAL MEMBERS: ${sortedPositions.length} *****');
    Color _thisPanelColor = Theme.of(context).primaryColor;

    return BounceInUp(
      child: Card(
          child:
              // ValueListenableBuilder(
              //     valueListenable: Hive.box(appDatabase)
              //         .listenable(keys: userDatabase.keys.toList()),
              //     builder: (context, box, widget) {
              //       return
              new Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              opacity: 0.15,
              image: AssetImage('assets/congress_pic_${random.nextInt(4)}.png'),
              // fit: BoxFit.fitWidth,
              repeat: ImageRepeat.repeat,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.background, BlendMode.color)),
        ),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: _thisPanelColor,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      new Expanded(
                        child: new Text(
                            '${vote.bill.billId.toLowerCase() == 'nobillid' ? 'Vote Results' : vote.bill.billId}',
                            style: GoogleFonts.bangers(
                                color: Colors.white, fontSize: 25)),
                      ),
                      SizedBox(
                        height: 22,
                        child: OutlinedButton(
                            onPressed: () {},
                            child: Text(vote.result
                                    .toString()
                                    .toLowerCase()
                                    .contains('result.')
                                ? vote.result.toString().toUpperCase() ==
                                        'RESULT.AGREED_TO'
                                    ? 'AGREED'
                                    : vote.result
                                        .toString()
                                        .toUpperCase()
                                        .replaceFirst('RESULT.', '')
                                : 'VOTE RECORDED'),
                            style: ButtonStyle(
                                foregroundColor: darkThemeTextMSPColor,
                                backgroundColor: vote.result
                                                .toString()
                                                .toUpperCase() ==
                                            'RESULT.PASSED' ||
                                        vote.result.toString().toUpperCase() ==
                                            'RESULT.AGREED_TO'
                                    ? alertIndicatorMSPColorDarkGreen
                                    : vote.result.toString().toUpperCase() ==
                                            'RESULT.FAILED'
                                        ? errorMSPColor
                                        : null)),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                        child: new Text(vote.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xffffffff),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.normal,
                                fontSize: 12)),
                      ),
                    )
                  ]),
                  Row(children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                        child: new Text('Question: ${vote.question}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xffffffff),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    )
                  ]),
                  // SizedBox(height: 3),
                  Row(children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                        child: new Text(
                            'Yea: ${vote.total.yes} | Nay: ${vote.total.no} | Present: ${vote.total.present} | No Vote: ${vote.total.notVoting}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xffffffff),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    )
                  ]),
                ],
              ),
            ),
            new Expanded(
              child: new GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.6, crossAxisCount: 5),
                  physics: BouncingScrollPhysics(),
                  primary: false,
                  // controller: scrollController,
                  shrinkWrap: true,
                  itemCount: sortedPositions.length,
                  itemBuilder: (context, index) {
                    final thisMember = sortedPositions[index];
                    final String thisMemberImageUrl =
                        '${PropublicaApi().memberImageRootUrl}${thisMember.memberId}.jpg'
                            .toLowerCase();
                    final Color thisMemberColor =
                        thisMember.party.toLowerCase() == 'd'
                            ? democratColor
                            : thisMember.party.toLowerCase() == 'r'
                                ? republicanColor
                                : independentColor;
                    return FlipInY(
                      duration: Duration(milliseconds: 5 * index),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: new GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MemberDetail(
                                      thisMember.memberId.toLowerCase(),
                                      houseStockWatchList,
                                      senateStockWatchList),
                                ),
                              ),
                              child: new Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  new CircleAvatar(
                                      backgroundColor: thisMemberColor,
                                      radius: 29,
                                      child: new Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/congress_pic_${random.nextInt(4)}.png'),
                                                fit: BoxFit.cover)),
                                        foregroundDecoration: BoxDecoration(
                                            border: Border.all(
                                              width: 3,
                                              color: userDatabase
                                                          .get('darkTheme') ==
                                                      true
                                                  ? Color(0xffffffff)
                                                  : thisMemberColor,
                                            ),
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    thisMemberImageUrl),
                                                fit: BoxFit.cover)),
                                      )),
                                  new Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      List.from(userDatabase.get(
                                                  'subscriptionAlertsList'))
                                              .any((element) => element
                                                  .toString()
                                                  .toLowerCase()
                                                  .startsWith(
                                                      'member_${thisMember.memberId}'
                                                          .toLowerCase()))
                                          ? new Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                AnimatedWidgets.flashingEye(
                                                    context, true, false,
                                                    size: 10,
                                                    sameColorBright: true),
                                              ],
                                            )
                                          : const SizedBox.shrink(),
                                      new Text(
                                          '${thisMember.votePosition.toLowerCase() == 'not voting' ? 'DNV' : thisMember.votePosition.toLowerCase() == 'present' ? 'PSNT' : thisMember.votePosition}',
                                          style: GoogleFonts.bangers(
                                              fontSize: 20,
                                              shadows:
                                                  Styles.shadowStrokeTextWhite,
                                              color: thisMemberColor)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3.0),
                            child: new Text(
                              '${thisMember.name}\n(${thisMember.state})',
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      )
          // }),
          ),
    );
  }

  static Widget lobbyingList(BuildContext context, Box userDatabase,
      List<LobbyingRepresentation> lobbyEvents) {
    logger.d('***** ALL EVENTS: ${lobbyEvents.map((e) => e.id)} *****');

    // bool viewMore = false;
    Color _thisPanelColor = alertIndicatorColorDarkGreen;
    bool _darkTheme = userDatabase.get('darkTheme');

    String queryString = '';

    return ValueListenableBuilder(
        valueListenable:
            Hive.box(appDatabase).listenable(keys: ['subscriptionAlertsList']),
        builder: (context, box, widget) {
          logger.d(
              '***** ALL LOBBIES (recent lobbying page): ${userDatabase.get('subscriptionAlertsList')} *****');

          lobbyEvents = lobbyEvents
                  .where((event) =>
                      List.from(userDatabase.get('subscriptionAlertsList')).any(
                          (element) => element
                              .toString()
                              .toLowerCase()
                              .startsWith('lobby_${event.id}'.toLowerCase())))
                  .toList() +
              lobbyEvents
                  .where((event) =>
                      !List.from(userDatabase.get('subscriptionAlertsList'))
                          .any((element) => element
                              .toString()
                              .toLowerCase()
                              .startsWith('lobby_${event.id}'.toLowerCase())))
                  .toList();

          return BounceInUp(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                image: DecorationImage(
                    opacity: 0.15,
                    image:
                        AssetImage('assets/lobbying${random.nextInt(2)}.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.background,
                        BlendMode.color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: _thisPanelColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Expanded(
                          child: new Text('Recent Lobbying Filings',
                              style: GoogleFonts.bangers(
                                  color: Colors.white, fontSize: 25)),
                        ),
                        SizedBox(
                          height: 20,
                          child: OutlinedButton.icon(
                              icon: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 12,
                              ),
                              label: Text('Search',
                                  style: Styles.regularStyle.copyWith(
                                      color: Colors.white, fontSize: 12)),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  enableDrag: true,
                                  builder: (context) => Container(
                                    color: Colors.transparent,
                                    margin: const EdgeInsets.only(
                                        top: 5, left: 15, right: 15),
                                    height: 400,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                              color:
                                                  alertIndicatorColorDarkGreen
                                                      .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: TextField(
                                            keyboardType: TextInputType.text,
                                            textAlign: TextAlign.center,
                                            autocorrect: true,
                                            autofocus: true,
                                            enableSuggestions: true,
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText: 'Enter your search',
                                            ),
                                            onChanged: (val) {
                                              queryString = val;
                                            },
                                          ),
                                        ),
                                        new ElevatedButton.icon(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  alertIndicatorMSPColorDarkGreen),
                                          icon: Icon(Icons.search),
                                          onPressed: () {
                                            Navigator.pop(context);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LobbyingSearchList(
                                                        queryString),
                                              ),
                                            );
                                          },
                                          label: Text(
                                            'Search',
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                        // new Text('${_finalLobbyingEvents.length} Label 1 | ',
                        //     // '${_finalLobbyingEvents.where((element) => element.toString().startsWith('lobby_')).length} Label 1 | ',
                        //     // '${_finalLobbyingEvents.where((element) => element.toString().startsWith('bill_')).length} Label 2',
                        //     style: TextStyle(
                        //         color: Color(0xffffffff),
                        //         fontStyle: FontStyle.italic,
                        //         fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                          physics: BouncingScrollPhysics(),
                          primary: false,
                          shrinkWrap: true,
                          children: lobbyEvents
                              .map(
                                (_thisLobbyEvent) => StatefulBuilder(
                                    builder: (context, setState) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FlipInX(
                                        child: Card(
                                          elevation: 0,
                                          color: _darkTheme
                                              ? Theme.of(context)
                                                  .highlightColor
                                                  .withOpacity(0.5)
                                              : Colors.white.withOpacity(0.5),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: ListTile(
                                              dense: true,
                                              leading: List.from(userDatabase.get(
                                                          'subscriptionAlertsList'))
                                                      .any((element) => element
                                                          .toString()
                                                          .startsWith(
                                                              'lobby_${_thisLobbyEvent.id}'
                                                                  .toLowerCase()))
                                                  ? AnimatedWidgets.flashingEye(
                                                      context, true, false,
                                                      size: 15)
                                                  : FaIcon(
                                                      FontAwesomeIcons
                                                          .moneyBills,
                                                      size: 15),
                                              title: lobbySimpleTextGroup(
                                                  context,
                                                  _thisPanelColor,
                                                  _darkTheme,
                                                  'CLIENT: ${_thisLobbyEvent.lobbyingClient.name}',
                                                  _thisLobbyEvent.specificIssues ==
                                                              null ||
                                                          _thisLobbyEvent
                                                              .specificIssues
                                                              .isEmpty
                                                      ? 'No specific issues listed'
                                                      : _thisLobbyEvent
                                                          .specificIssues
                                                          .first),
                                              subtitle: Text(
                                                  'FILED: ${dateWithDayFormatter.format(_thisLobbyEvent.latestFiling.filingDate)}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Styles.regularStyle
                                                      .copyWith(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.normal)),
                                              trailing: FaIcon(
                                                  FontAwesomeIcons.binoculars,
                                                  size: 15),
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LobbyEventDetail(
                                                    thisLobbyEventId:
                                                        _thisLobbyEvent.id,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              )
                              .toList()),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  static Widget lobbySimpleTextGroup(BuildContext context, Color headerColor,
      bool darkTheme, String headerText, String contentText,
      {int maxLines = 3,
      double contentFontSize = 14,
      FontWeight contentFontWeight = FontWeight.bold}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headerText.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Styles.regularStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: darkTheme ? Colors.grey : headerColor,
            )),
        Text(
          contentText,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: Styles.regularStyle
              .copyWith(fontSize: 14, fontWeight: contentFontWeight),
        ),
      ],
    );
  }

  static Widget stockWatchList(
      BuildContext context,
      bool isHouse,
      Box userDatabase,
      List<HouseStockWatch> houseTradesList,
      List<SenateStockWatch> senateTradesList,
      List<ChamberMember> allMembersList,
      bool userIsPremium) {
    Color _thisPanelColor = stockWatchColor;
    bool _darkTheme = userDatabase.get('darkTheme');

    // isHouse
    //     ? userDatabase.put('newHouseStock', false)
    //     : userDatabase.put('newSenateStock', false);

    return ValueListenableBuilder(
        valueListenable:
            Hive.box(appDatabase).listenable(keys: ['subscriptionAlertsList']),
        builder: (context, box, widget) {
          logger.d(
              '***** ALL TRADES (recent trades page): ${userDatabase.get('subscriptionAlertsList')} *****');

          // lobbyEvents = lobbyEvents
          //         .where((event) =>
          //             List.from(userDatabase.get('subscriptionAlertsList')).any(
          //                 (element) => element
          //                     .toString()
          //                     .toLowerCase()
          //                     .startsWith('lobby_${event.id}'.toLowerCase())))
          //         .toList() +
          //     lobbyEvents
          //         .where((event) =>
          //             !List.from(userDatabase.get('subscriptionAlertsList'))
          //                 .any((element) => element
          //                     .toString()
          //                     .toLowerCase()
          //                     .startsWith('lobby_${event.id}'.toLowerCase())))
          //         .toList();

          return BounceInUp(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                image: DecorationImage(
                    opacity: 0.15,
                    image: AssetImage('assets/stock${random.nextInt(3)}.png'),
                    fit: BoxFit.cover,
                    colorFilter:
                        ColorFilter.mode(stockWatchColor, BlendMode.color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: _thisPanelColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Expanded(
                          child: new Text(
                              'Recent ${isHouse ? 'House' : 'Senate'} Trade Activity',
                              style: GoogleFonts.bangers(
                                  color: Colors.white, fontSize: 25)),
                        ),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: darkThemeTextColor))
                        // new Text('${_finalLobbyingEvents.length} Label 1 | ',
                        //     // '${_finalLobbyingEvents.where((element) => element.toString().startsWith('lobby_')).length} Label 1 | ',
                        //     // '${_finalLobbyingEvents.where((element) => element.toString().startsWith('bill_')).length} Label 2',
                        //     style: TextStyle(
                        //         color: Color(0xffffffff),
                        //         fontStyle: FontStyle.italic,
                        //         fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                          physics: BouncingScrollPhysics(),
                          primary: false,
                          shrinkWrap: true,
                          children: isHouse
                              ? houseTradesList
                                  .map(
                                    (_thisTrade) => StatefulBuilder(
                                        builder: (context, setState) {
                                      ChamberMember _thisMember;
                                      try {
                                        _thisMember = allMembersList.firstWhere(
                                            (element) =>
                                                _thisTrade.representative
                                                        .toLowerCase()
                                                        // .replaceFirst('robert',
                                                        //     'bob')
                                                        .replaceFirst(
                                                            'earl l.', 'buddy')
                                                        .split(' ')[1][0] ==
                                                    element.firstName
                                                        .toLowerCase()[0] &&
                                                _thisTrade.representative
                                                    .toLowerCase()
                                                    .contains(element.lastName
                                                        .toLowerCase()));
                                      } catch (e) {
                                        logger.i('ERROR: $e');
                                      }
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FlipInX(
                                            child: Card(
                                              elevation: 0,
                                              color: _darkTheme
                                                  ? Theme.of(context)
                                                      .highlightColor
                                                      .withOpacity(0.75)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .background
                                                      .withOpacity(0.75),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                    ListTile(
                                                      dense: true,
                                                      leading: FaIcon(
                                                          FontAwesomeIcons
                                                              .chartLine,
                                                          size: 15,
                                                          color: _darkTheme
                                                              ? null
                                                              : _thisPanelColor),
                                                      title: simpleTextGroup(
                                                          context,
                                                          _thisPanelColor,
                                                          _darkTheme,
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  'E: ${dateWithDayAndYearFormatter.format(_thisTrade.transactionDate)}',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: Styles
                                                                      .regularStyle
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: _darkTheme
                                                                        ? Colors
                                                                            .grey
                                                                        : _thisPanelColor,
                                                                  )),
                                                              Spacer(),
                                                              Text(
                                                                  'D: ${dateWithDayAndYearFormatter.format((_thisTrade.disclosureDate))}',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: Styles
                                                                      .regularStyle
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: _darkTheme
                                                                        ? Colors
                                                                            .grey
                                                                        : _thisPanelColor,
                                                                  )),
                                                            ],
                                                          ),
                                                          _thisTrade
                                                              .representative),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'Transaction: ${_thisTrade.type.toUpperCase().replaceFirst('_', ' ')}\nTicker: ${_thisTrade.ticker == null ? '--' : _thisTrade.ticker}\nDescription: ${_thisTrade.assetDescription.replaceAll(RegExp(r'<(.*)>'), '').replaceAll('&amp;', '&')}\nAmount: ${_thisTrade.amount}',
                                                              style: Styles
                                                                  .regularStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                          !_thisTrade.capGainsOver200Usd
                                                              ? const SizedBox
                                                                  .shrink()
                                                              : Text(
                                                                  'Capital gains reported',
                                                                  style: Styles
                                                                      .regularStyle
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                        ],
                                                      ),
                                                      trailing: _thisMember ==
                                                              null
                                                          ? const SizedBox
                                                              .shrink()
                                                          : FaIcon(
                                                              FontAwesomeIcons
                                                                  .userTie,
                                                              size: 15),
                                                      onTap: () =>
                                                          _thisMember == null
                                                              ? null
                                                              : Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            MemberDetail(
                                                                      _thisMember
                                                                          .id,
                                                                      houseTradesList,
                                                                      senateTradesList,
                                                                    ),
                                                                  ),
                                                                ),
                                                    ),
                                                    IconButton(
                                                      icon: FaIcon(
                                                        FontAwesomeIcons
                                                            .solidFileLines,
                                                        size: 15,
                                                      ),
                                                      onPressed: () =>
                                                          Functions.linkLaunch(
                                                              context,
                                                              _thisTrade
                                                                  .ptrLink,
                                                              userDatabase,
                                                              userIsPremium,
                                                              appBarTitle:
                                                                  'House Trade',
                                                              isPdf: true,
                                                              source:
                                                                  'stock_trade'),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  )
                                  .toList()
                              : senateTradesList
                                  .map(
                                    (_thisTrade) => StatefulBuilder(
                                        builder: (context, setState) {
                                      ChamberMember _thisMember;
                                      try {
                                        _thisMember = allMembersList
                                            .firstWhere(
                                                (element) =>
                                                    _thisTrade
                                                            .senator
                                                            .toLowerCase()[0] ==
                                                        element
                                                            .firstName
                                                            .toLowerCase()
                                                            .replaceFirst(
                                                                'mitch',
                                                                'a. mitchell')
                                                            .replaceFirst(
                                                                'bill',
                                                                'william')[0] &&
                                                    _thisTrade.senator
                                                        .toLowerCase()
                                                        .contains(element
                                                            .lastName
                                                            .toLowerCase()));
                                      } catch (e) {
                                        logger.i(
                                            'ERROR WITH MEMBER $_thisMember: $e');
                                      }
                                      // return _thisMember == null
                                      //     ? const SizedBox.shrink()
                                      //     :
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FlipInX(
                                            child: Card(
                                              elevation: 0,
                                              color: _darkTheme
                                                  ? Theme.of(context)
                                                      .highlightColor
                                                      .withOpacity(0.75)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .background
                                                      .withOpacity(0.75),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                    ListTile(
                                                      dense: true,
                                                      leading: FaIcon(
                                                          FontAwesomeIcons
                                                              .chartLine,
                                                          size: 15),
                                                      title: simpleTextGroup(
                                                          context,
                                                          _thisPanelColor,
                                                          _darkTheme,
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  'E: ${dateWithDayAndYearFormatter.format(_thisTrade.transactionDate)}',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: Styles
                                                                      .regularStyle
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: _darkTheme
                                                                        ? Colors
                                                                            .grey
                                                                        : _thisPanelColor,
                                                                  )),
                                                              Spacer(),
                                                              Text(
                                                                  'D: ${dateWithDayAndYearFormatter.format(_thisTrade.disclosureDate)}',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: Styles
                                                                      .regularStyle
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: _darkTheme
                                                                        ? Colors
                                                                            .grey
                                                                        : _thisPanelColor,
                                                                  )),
                                                            ],
                                                          ),
                                                          'Sen. ${_thisTrade.senator}'),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'Transaction: ${_thisTrade.type.toUpperCase()}\n${_thisTrade.ticker == null || _thisTrade.ticker == '--' || _thisTrade.ticker == 'N/A' ? 'Type: ${_thisTrade.assetType == null ? 'Unknown' : _thisTrade.assetType.replaceAll(RegExp(r'<(.*)>'), '')}' : 'Ticker: ${_thisTrade.ticker}'}\nDescription: ${_thisTrade.assetDescription.replaceAll(RegExp(r'<(.*)>'), '').replaceAll('&amp;', '&')}\nAmount: ${_thisTrade.amount}',
                                                              style: Styles
                                                                  .regularStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                        ],
                                                      ),
                                                      trailing: _thisMember ==
                                                              null
                                                          ? const SizedBox
                                                              .shrink()
                                                          : FaIcon(
                                                              FontAwesomeIcons
                                                                  .userTie,
                                                              size: 15),
                                                      onTap: () =>
                                                          _thisMember == null
                                                              ? null
                                                              : Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => MemberDetail(
                                                                        _thisMember
                                                                            .id,
                                                                        houseTradesList,
                                                                        senateTradesList),
                                                                  ),
                                                                ),
                                                    ),
                                                    !_thisTrade.assetDescription
                                                            .toLowerCase()
                                                            .contains(
                                                                'scanned pdf')
                                                        ? SizedBox.shrink()
                                                        : IconButton(
                                                            icon: FaIcon(
                                                              FontAwesomeIcons
                                                                  .solidFileLines,
                                                              size: 15,
                                                            ),
                                                            onPressed: () =>
                                                                Functions.linkLaunch(
                                                                    context,
                                                                    _thisTrade
                                                                        .ptrLink,
                                                                    userDatabase,
                                                                    userIsPremium,
                                                                    appBarTitle:
                                                                        'Senate Trade',
                                                                    isPdf:
                                                                        false,
                                                                    source:
                                                                        'stock_trade'),
                                                          )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  )
                                  .toList()),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  static Widget simpleTextGroup(BuildContext context, Color headerColor,
      bool darkTheme, Widget headerRow, String contentText,
      {int maxLines = 3,
      double contentFontSize = 14,
      FontWeight contentFontWeight = FontWeight.bold}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerRow,
        Text(
          contentText,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: Styles.regularStyle
              .copyWith(fontSize: 14, fontWeight: contentFontWeight),
        ),
      ],
    );
  }

  static Widget marketDailyTradesCalendar(
    BuildContext context,
    CalendarData thisDay,
    List<ChamberMember> membersList,
    Box userDatabase,
    bool userIsLegacy,
    List<HouseStockWatch> houseStockWatchList,
    List<SenateStockWatch> senateStockWatchList,
  ) {
    final bool darkTheme = userDatabase.get('darkTheme');

    Color _thisPanelColor = stockWatchColor;
    final List<String> subscriptionAlertsList =
        List.from(userDatabase.get('subscriptionAlertsList'));

    // String thisTradeTickerInfo = trade.split('_')[0];
    // String thisTradeTickerName = thisTradeTickerInfo.split('<|:|>')[0];
    // String thisTradeTickerDescription = thisTradeTickerInfo.split('<|:|>')[1];
    // // String thisTradeTradeType = trade.split('_')[1];
    // String thisTradeDollarAmount = trade.split('_')[2];
    // String thisTradeMemberName = trade.split('_')[3];
    // // String _thisTradeShortTitle = thisTradeMemberName.split(' ')[0];
    // // String _thisTradeFirstName = thisTradeMemberName.split(' ')[1];
    // DateTime thisTradeExecutionDate = DateTime.parse(trade.split('_')[4]);
    // // DateTime thisTradeDisclosureDate = DateTime.parse(trade.split('_')[5]);
    // // String thisTradeChamber = trade.split('_')[6];
    // // String thisTradeOwner = trade.split('_')[7];
    // String thisTradeMemberId = trade.split('_')[8];

    List<ChamberMember> thisDayMembersList = membersList
        .where((member) => thisDay.memberIds
            .toString()
            .toLowerCase()
            .contains(member.id.toLowerCase()))
        .toSet()
        .toList();

    // List<ChamberMember> _sortedMembersList = [];
    // thisDayMembersList.forEach((member) {
    //   if (subscriptionAlertsList.any((element) =>
    //       element.toLowerCase().contains(member.id.toLowerCase()))) {
    //     _sortedMembersList.insert(0, member);
    //   } else {
    //     _sortedMembersList.add(member);
    //   }
    // });

    return BounceInUp(
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              opacity: 0.15,
              image: AssetImage('assets/stock${random.nextInt(3)}.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(stockWatchColor, BlendMode.color)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: darkTheme
                    ? Theme.of(context).primaryColorDark
                    : stockWatchColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Executed ${dateWithDayAndYearFormatter.format(thisDay.date)}',
                              style: GoogleFonts.bangers(
                                  color: darkThemeTextColor, fontSize: 25)),
                          new Text(
                              '${thisDay.trades.length} Trades | ${thisDay.tickers.toSet().length} Tickers | ${thisDayMembersList.length} Members',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: darkThemeTextColor,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: darkThemeTextColor))
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      children: thisDay.trades
                          .map((_thisTrade) => FlipInX(
                                child: Card(
                                  elevation: 0,
                                  color: darkTheme
                                      ? Theme.of(context)
                                          .highlightColor
                                          .withOpacity(0.75)
                                      : Theme.of(context)
                                          .colorScheme
                                          .background
                                          .withOpacity(0.75),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: new ListTile(
                                      dense: false,
                                      title: simpleTextGroup(
                                          context,
                                          _thisPanelColor,
                                          darkTheme,
                                          Row(
                                            children: [
                                              Text(
                                                  '${_thisTrade.memberFullName}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Styles.regularStyle
                                                      .copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: darkTheme
                                                        ? Colors.grey
                                                        : _thisPanelColor,
                                                  )),
                                              Spacer(),
                                            ],
                                          ),
                                          '${_thisTrade.tickerName == null || _thisTrade.tickerName == '--' ? '' : '\$${_thisTrade.tickerName}'} ${_thisTrade.tradeType.toUpperCase().replaceFirst('_', ' ')}'),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${_thisTrade.tickerDescription.replaceAll(RegExp(r'<(.*)>'), '').replaceAll('&amp;', '&')}\nAmount: ${_thisTrade.dollarAmount}',
                                              style: Styles.regularStyle
                                                  .copyWith(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ],
                                      ),
                                      trailing: ZoomIn(
                                        child: Stack(
                                          alignment: Alignment.topLeft,
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              height: 45,
                                              width: 45,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 1,
                                                      color:
                                                          darkThemeTextColor),
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/stock${random.nextInt(3)}.png'),
                                                      fit: BoxFit.cover)),
                                              foregroundDecoration:
                                                  BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: darkThemeTextColor),
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                      '${PropublicaApi().memberImageRootUrl}${_thisTrade.memberId}.jpg'
                                                          .toLowerCase(),
                                                    ),
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            AnimatedWidgets.flashingEye(
                                                context,
                                                subscriptionAlertsList.any(
                                                    (item) => item
                                                        .toLowerCase()
                                                        .contains(_thisTrade
                                                            .memberId
                                                            .toLowerCase())),
                                                false,
                                                size: 10,
                                                sameColorBright: false),
                                          ],
                                        ),
                                      ),
                                      onTap: () =>
                                          _thisTrade.memberId.toLowerCase() ==
                                                  'noid'
                                              ? null
                                              : Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MemberDetail(
                                                      _thisTrade.memberId
                                                          .toLowerCase(),
                                                      houseStockWatchList,
                                                      senateStockWatchList,
                                                    ),
                                                  ),
                                                ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList()),
                ),
              )
            ]),
      ),
    );
  }

  static Widget marketActivityTicker(
      BuildContext context,
      String tickerName,
      String tickerDescription,
      List<ChamberMember> membersList,
      int period,
      Box userDatabase,
      bool userIsPremium,
      bool userIsLegacy,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    final bool darkTheme = userDatabase.get('darkTheme');
    final List<String> subscriptionAlertsList =
        List.from(userDatabase.get('subscriptionAlertsList'));
    // final bool devUpgraded = userDatabase.get('devUpgraded');
    // final bool freeTrialUsed = userDatabase.get('freeTrialUsed');

    List<ChamberMember> _sortedMembersList = [];
    membersList.forEach((member) {
      if (subscriptionAlertsList.any((element) =>
          element.toLowerCase().contains(member.id.toLowerCase()))) {
        _sortedMembersList.insert(0, member);
      } else {
        _sortedMembersList.add(member);
      }
    });

    return BounceInUp(
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              opacity: 0.15,
              image: AssetImage('assets/stock${random.nextInt(3)}.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(stockWatchColor, BlendMode.color)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: darkTheme
                    ? Theme.of(context).primaryColorDark
                    : stockWatchColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${membersList.length} - \$$tickerName ${membersList.length == 1 ? 'Trader' : 'Traders'} ($period Day)',
                              style: GoogleFonts.bangers(
                                  color: darkThemeTextColor, fontSize: 25)),

                          // const SizedBox(height: 3),
                          new Text(
                              !tickerDescription.contains(' - ')
                                  ? tickerDescription
                                  : tickerDescription.split(' - ')[0],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              // textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: darkThemeTextColor,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12)),
                          // Text('$tickerDescription',
                          //     style: Styles.regularStyle.copyWith(
                          //         color: darkThemeTextColor, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: darkThemeTextColor))
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView(
                      // primary: true,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      children: _sortedMembersList
                          .map((_thisMember) => FlipInX(
                                child: Card(
                                  elevation: 0,
                                  color: darkTheme
                                      ? Theme.of(context)
                                          .highlightColor
                                          .withOpacity(0.75)
                                      : Theme.of(context)
                                          .colorScheme
                                          .background
                                          .withOpacity(0.75),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: new ListTile(
                                      dense: false,
                                      leading: ZoomIn(
                                        child: Container(
                                          alignment: Alignment.topCenter,
                                          // height: 55,
                                          width: 45,
                                          decoration: BoxDecoration(
                                              // shape: BoxShape.circle,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/congress_pic_${random.nextInt(4)}.png'),
                                                  fit: BoxFit.cover)),
                                          foregroundDecoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: _thisMember.party
                                                          .toLowerCase() ==
                                                      'd'
                                                  ? democratColor
                                                  : _thisMember.party
                                                              .toLowerCase() ==
                                                          'r'
                                                      ? republicanColor
                                                      : independentColor,
                                            ),
                                            // shape: BoxShape.circle,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    '${PropublicaApi().memberImageRootUrl}${_thisMember.id}.jpg'
                                                        .toLowerCase()),
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                      ),
                                      trailing: new Text('${_thisMember.state}',
                                          style: GoogleFonts.bangers(
                                              fontSize: 30,
                                              color: darkTheme
                                                  ? Color(0xffffffff)
                                                  : _thisMember.party
                                                              .toLowerCase() ==
                                                          'd'
                                                      ? democratColor
                                                      : _thisMember.party
                                                                  .toLowerCase() ==
                                                              'r'
                                                          ? republicanColor
                                                          : independentColor)),
                                      title: new Row(
                                        children: [
                                          new Text(
                                              '${_thisMember.shortTitle.replaceFirst('Rep.', 'Hon.')} ${_thisMember.firstName} ${_thisMember.lastName}'),
                                          _thisMember.suffix != null
                                              ? new Text(
                                                  '  ${_thisMember.suffix}')
                                              : const SizedBox.shrink(),
                                          const SizedBox(width: 5),
                                          AnimatedWidgets.flashingEye(
                                              context,
                                              List.from(userDatabase.get(
                                                      'subscriptionAlertsList'))
                                                  .any((element) => element
                                                      .toString()
                                                      .toLowerCase()
                                                      .startsWith(
                                                          'member_${_thisMember.id.toLowerCase()}')),
                                              false,
                                              size: 12)
                                        ],
                                      ),
                                      subtitle: new Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _thisMember.leadershipRole != null &&
                                                  _thisMember
                                                      .leadershipRole.isNotEmpty
                                              ? new Text(
                                                  '${_thisMember.leadershipRole}')
                                              : const SizedBox.shrink(),
                                          _thisMember.phone != null
                                              ? new Text('${_thisMember.phone}')
                                              : const SizedBox.shrink(),
                                          _thisMember.twitterAccount != null
                                              ? new Text(
                                                  '@${_thisMember.twitterAccount}')
                                              : _thisMember.youtubeAccount !=
                                                      null
                                                  ? new Text(
                                                      '📺 ${_thisMember.youtubeAccount}')
                                                  : _thisMember.title != null
                                                      ? new Text(
                                                          '${_thisMember.title}')
                                                      : const SizedBox.shrink(),
                                        ],
                                      ),
                                      onTap: () async {
                                        // Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MemberDetail(
                                                _thisMember.id,
                                                houseStockWatchList,
                                                senateStockWatchList),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ))
                          .toList()),
                ),
              )
            ]),
      ),
    );
  }

  static Widget marketActivityMember(
      BuildContext context,
      String chamber,
      ChamberMember member,
      int period,
      Box userDatabase,
      bool userIsPremium,
      bool userIsLegacy,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    final bool darkTheme = userDatabase.get('darkTheme');
    final List<String> subscriptionAlertsList =
        List.from(userDatabase.get('subscriptionAlertsList'));

    String _thisTitle = chamber == 'house' ? 'Hon.' : 'Sen.';
    String _thisMemberImageUrl =
        '${PropublicaApi().memberImageRootUrl}${member.id}.jpg'.toLowerCase();
    Color _thisPanelColor = stockWatchColor;

    debugPrint(
        '^^^^^ MEMBER: ${member.firstName} ${member.lastName} ${member.id} $_thisMemberImageUrl\nDATA:\nChamber $chamber - Number of Days $period - House List Length ${houseStockWatchList.length} - Senate List Length ${senateStockWatchList.length}');

    return BounceInUp(
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              opacity: 0.15,
              image: AssetImage('assets/stock${random.nextInt(3)}.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(_thisPanelColor, BlendMode.color)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.maybePop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberDetail(
                        member.id,
                        houseStockWatchList,
                        senateStockWatchList,
                      ),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 60,
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  color: darkTheme
                      ? Theme.of(context).primaryColorDark
                      : _thisPanelColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ZoomIn(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 1, color: darkThemeTextColor),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/stock${random.nextInt(3)}.png'),
                                      fit: BoxFit.cover)),
                              foregroundDecoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: darkThemeTextColor),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: NetworkImage(_thisMemberImageUrl),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            AnimatedWidgets.flashingEye(
                                context,
                                subscriptionAlertsList.any((item) => item
                                    .toLowerCase()
                                    .contains(member.id.toLowerCase())),
                                false,
                                size: 10,
                                sameColorBright: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                '$_thisTitle ${member.firstName} ${member.lastName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.bangers(
                                    color: darkThemeTextColor, fontSize: 25)),
                            // const SizedBox(height: 3),
                            new Text(
                                'Stock Trade Executions ($period Days)\nSee Member Details For Other Securities',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: darkThemeTextColor,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: darkThemeTextColor))
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      children: chamber == 'house'
                          ? houseStockWatchList
                              .map((_thisTrade) => FlipInX(
                                    child: Card(
                                      elevation: 0,
                                      color: darkTheme
                                          ? Theme.of(context)
                                              .highlightColor
                                              .withOpacity(0.75)
                                          : Theme.of(context)
                                              .colorScheme
                                              .background
                                              .withOpacity(0.75),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: new ListTile(
                                          dense: false,
                                          title: simpleTextGroup(
                                              context,
                                              _thisPanelColor,
                                              darkTheme,
                                              Row(
                                                children: [
                                                  Text(
                                                      'Executed: ${dateWithDayAndYearFormatter.format(_thisTrade.transactionDate)}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: darkTheme
                                                            ? Colors.grey
                                                            : _thisPanelColor,
                                                      )),
                                                  Spacer(),
                                                ],
                                              ),
                                              '${_thisTrade.ticker == null || _thisTrade.ticker == '--' ? '' : '\$${_thisTrade.ticker}'} ${_thisTrade.type.toUpperCase().replaceFirst('_', ' ')}'),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${_thisTrade.assetDescription.replaceAll(RegExp(r'<(.*)>'), '')}\nAmount: ${_thisTrade.amount}',
                                                  style: Styles.regularStyle
                                                      .copyWith(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              !_thisTrade.capGainsOver200Usd
                                                  ? const SizedBox.shrink()
                                                  : Text(
                                                      'Capital gains reported',
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                            ],
                                          ),
                                          trailing: FaIcon(
                                              FontAwesomeIcons.userTie,
                                              size: 15),
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MemberDetail(
                                                member.id,
                                                houseStockWatchList,
                                                senateStockWatchList,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList()
                          : senateStockWatchList
                              .map((_thisTrade) => FlipInX(
                                    child: Card(
                                      elevation: 0,
                                      color: darkTheme
                                          ? Theme.of(context)
                                              .highlightColor
                                              .withOpacity(0.75)
                                          : Theme.of(context)
                                              .colorScheme
                                              .background
                                              .withOpacity(0.75),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: new ListTile(
                                          dense: false,
                                          title: simpleTextGroup(
                                              context,
                                              _thisPanelColor,
                                              darkTheme,
                                              Row(
                                                children: [
                                                  Text(
                                                      'Executed: ${dateWithDayAndYearFormatter.format(_thisTrade.transactionDate)}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: darkTheme
                                                            ? Colors.grey
                                                            : _thisPanelColor,
                                                      )),
                                                  Spacer(),
                                                  // Text(
                                                  //     'D: ${dateWithDayAndYearFormatter.format((_thisTrade.disclosureDate))}',
                                                  //     maxLines: 1,
                                                  //     overflow:
                                                  //         TextOverflow.ellipsis,
                                                  //     style: Styles.regularStyle
                                                  //         .copyWith(
                                                  //       fontSize: 12,
                                                  //       fontWeight:
                                                  //           FontWeight.bold,
                                                  //       color: darkTheme
                                                  //           ? Colors.grey
                                                  //           : _thisPanelColor,
                                                  //     )),
                                                ],
                                              ),
                                              '${_thisTrade.ticker == null || _thisTrade.ticker == '--' ? '' : '\$${_thisTrade.ticker}'} ${_thisTrade.type.toUpperCase().replaceFirst('_', ' ')}'),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${_thisTrade.assetDescription.replaceAll(RegExp(r'<(.*)>'), '')}\nAmount: ${_thisTrade.amount}',
                                                  style: Styles.regularStyle
                                                      .copyWith(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                            ],
                                          ),
                                          trailing: FaIcon(
                                              FontAwesomeIcons.userTie,
                                              size: 15),
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MemberDetail(
                                                member.id,
                                                houseStockWatchList,
                                                senateStockWatchList,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList()),
                ),
              )
            ]),
      ),
    );
  }

  static Widget marketActivityDollarRange(
      BuildContext context,
      String dollarRange,
      List<ChamberMember> membersList,
      int period,
      Box userDatabase,
      bool userIsPremium,
      bool userIsLegacy,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    final bool darkTheme = userDatabase.get('darkTheme');
    final List<String> subscriptionAlertsList =
        List.from(userDatabase.get('subscriptionAlertsList'));
    // final bool devUpgraded = userDatabase.get('devUpgraded');
    // final bool freeTrialUsed = userDatabase.get('freeTrialUsed');

    List<ChamberMember> _sortedMembersList = [];
    membersList.forEach((member) {
      if (subscriptionAlertsList.any((element) =>
          element.toLowerCase().contains(member.id.toLowerCase()))) {
        _sortedMembersList.insert(0, member);
      } else {
        _sortedMembersList.add(member);
      }
    });

    return BounceInUp(
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              opacity: 0.15,
              image: AssetImage('assets/stock${random.nextInt(3)}.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(stockWatchColor, BlendMode.color)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: darkTheme
                    ? Theme.of(context).primaryColorDark
                    : stockWatchColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: new Text(
                          '${membersList.length} - ${dollarRange.split(' - ')[0]}+ ${membersList.length == 1 ? 'Trader' : 'Traders'} ($period Day)',
                          style: GoogleFonts.bangers(
                              color: Colors.white, fontSize: 25)),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: darkThemeTextColor))
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      children: _sortedMembersList
                          .map((_thisMember) => FlipInX(
                                child: Card(
                                  elevation: 0,
                                  color: darkTheme
                                      ? Theme.of(context)
                                          .highlightColor
                                          .withOpacity(0.75)
                                      : Theme.of(context)
                                          .colorScheme
                                          .background
                                          .withOpacity(0.75),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: new ListTile(
                                      dense: false,
                                      leading: ZoomIn(
                                        child: Container(
                                          alignment: Alignment.topCenter,
                                          width: 45,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/congress_pic_${random.nextInt(4)}.png'),
                                                  fit: BoxFit.cover)),
                                          foregroundDecoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: _thisMember.party
                                                          .toLowerCase() ==
                                                      'd'
                                                  ? democratColor
                                                  : _thisMember.party
                                                              .toLowerCase() ==
                                                          'r'
                                                      ? republicanColor
                                                      : independentColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    '${PropublicaApi().memberImageRootUrl}${_thisMember.id}.jpg'
                                                        .toLowerCase()),
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                      ),
                                      trailing: new Text('${_thisMember.state}',
                                          style: GoogleFonts.bangers(
                                              fontSize: 30,
                                              color: darkTheme
                                                  ? Color(0xffffffff)
                                                  : _thisMember.party
                                                              .toLowerCase() ==
                                                          'd'
                                                      ? democratColor
                                                      : _thisMember.party
                                                                  .toLowerCase() ==
                                                              'r'
                                                          ? republicanColor
                                                          : independentColor)),
                                      title: new Row(
                                        children: [
                                          new Text(
                                              '${_thisMember.shortTitle.replaceFirst('Rep.', 'Hon.')} ${_thisMember.firstName} ${_thisMember.lastName}'),
                                          _thisMember.suffix != null
                                              ? new Text(
                                                  '  ${_thisMember.suffix}')
                                              : const SizedBox.shrink(),
                                          const SizedBox(width: 5),
                                          AnimatedWidgets.flashingEye(
                                              context,
                                              List.from(userDatabase.get(
                                                      'subscriptionAlertsList'))
                                                  .any((element) => element
                                                      .toString()
                                                      .toLowerCase()
                                                      .startsWith(
                                                          'member_${_thisMember.id.toLowerCase()}')),
                                              false,
                                              size: 12)
                                        ],
                                      ),
                                      subtitle: new Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _thisMember.leadershipRole != null &&
                                                  _thisMember
                                                      .leadershipRole.isNotEmpty
                                              ? new Text(
                                                  '${_thisMember.leadershipRole}')
                                              : const SizedBox.shrink(),
                                          _thisMember.phone != null
                                              ? new Text('${_thisMember.phone}')
                                              : const SizedBox.shrink(),
                                          _thisMember.twitterAccount != null
                                              ? new Text(
                                                  '@${_thisMember.twitterAccount}')
                                              : _thisMember.youtubeAccount !=
                                                      null
                                                  ? new Text(
                                                      '📺 ${_thisMember.youtubeAccount}')
                                                  : _thisMember.title != null
                                                      ? new Text(
                                                          '${_thisMember.title}')
                                                      : const SizedBox.shrink(),
                                        ],
                                      ),
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MemberDetail(
                                                _thisMember.id,
                                                houseStockWatchList,
                                                senateStockWatchList),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ))
                          .toList()),
                ),
              )
            ]),
      ),
    );
  }

  static Widget privateFundedTripsList(
      BuildContext context,
      Box userDatabase,
      List<PrivateTripResult> privateFundedTrips,
      List<ChamberMember> membersList,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList,
      bool userIsPremium) {
    logger.d(
        '***** ALL TRIPS: ${privateFundedTrips.map((e) => e.documentId)} *****');

    // bool viewMore = false;
    Color _thisPanelColor = Color.fromARGB(255, 0, 80, 100);
    bool _darkTheme = userDatabase.get('darkTheme');

    return ValueListenableBuilder(
        valueListenable:
            Hive.box(appDatabase).listenable(keys: ['subscriptionAlertsList']),
        builder: (context, box, widget) {
          privateFundedTrips = privateFundedTrips
                  .where((event) =>
                      List.from(userDatabase.get('subscriptionAlertsList')).any(
                          (element) => element
                              .toString()
                              .toLowerCase()
                              .startsWith(
                                  'member_${event.memberId}'.toLowerCase())))
                  .toList() +
              privateFundedTrips
                  .where((event) =>
                      !List.from(userDatabase.get('subscriptionAlertsList'))
                          .any((element) => element
                              .toString()
                              .toLowerCase()
                              .startsWith('member_${event.memberId}'.toLowerCase())))
                  .toList();

          return BounceInUp(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                image: DecorationImage(
                    opacity: 0.15,
                    image: AssetImage('assets/travel${random.nextInt(2)}.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.background,
                        BlendMode.color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: _thisPanelColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Expanded(
                          child: new Text('Recent Privately Funded Travel',
                              style: GoogleFonts.bangers(
                                  color: Colors.white, fontSize: 25)),
                        ),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: darkThemeTextColor))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                          physics: BouncingScrollPhysics(),
                          primary: false,
                          shrinkWrap: true,
                          children: privateFundedTrips
                              .map(
                                (_thisTrip) => StatefulBuilder(
                                    builder: (context, setState) {
                                  final ChamberMember _thisMember =
                                      membersList.firstWhere(((element) =>
                                          element.id.toLowerCase() ==
                                          _thisTrip.memberId.toLowerCase()));
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FlipInX(
                                        child: Card(
                                          elevation: 0,
                                          color: _darkTheme
                                              ? Theme.of(context)
                                                  .highlightColor
                                                  .withOpacity(0.5)
                                              : Colors.white.withOpacity(0.5),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                ListTile(
                                                  dense: true,
                                                  leading: List.from(userDatabase.get(
                                                              'subscriptionAlertsList'))
                                                          .any((element) => element
                                                              .toString()
                                                              .startsWith(
                                                                  'member_${_thisTrip.memberId}'
                                                                      .toLowerCase()))
                                                      ? AnimatedWidgets.flashingEye(
                                                          context, true, false,
                                                          size: 15)
                                                      : FaIcon(
                                                          FontAwesomeIcons
                                                              .planeDeparture,
                                                          size: 15),
                                                  title: privateFundedTripTextGroup(
                                                      context,
                                                      _thisPanelColor,
                                                      _darkTheme,
                                                      'Dep. ${dateWithDayFormatter.format(_thisTrip.departureDate)}',
                                                      'Ret. ${dateWithDayFormatter.format(_thisTrip.returnDate)}',
                                                      'Traveler: ${_thisTrip.traveler}'),
                                                  subtitle: Text(
                                                      'Sponsor: ${_thisTrip.sponsor}\nDestination: ${_thisTrip.destination}\nMember Name: ${_thisMember.firstName} ${_thisMember.lastName}', //\nChamber: ${_thisTrip.chamber.name}',
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                  trailing: FaIcon(
                                                      FontAwesomeIcons.userTie,
                                                      size: 15),
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MemberDetail(
                                                              _thisMember.id,
                                                              houseStockWatchList,
                                                              senateStockWatchList),
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: FaIcon(
                                                    FontAwesomeIcons
                                                        .solidFileLines,
                                                    size: 15,
                                                  ),
                                                  onPressed: () =>
                                                      Functions.linkLaunch(
                                                          context,
                                                          _thisTrip.pdfUrl,
                                                          userDatabase,
                                                          userIsPremium,
                                                          appBarTitle:
                                                              'Privately Funded Travel',
                                                          isPdf: true,
                                                          source: 'travel'),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              )
                              .toList()),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  static Widget privateFundedTripTextGroup(
      BuildContext context,
      Color headerColor,
      bool darkTheme,
      String headerText1,
      String headerText2,
      String contentText,
      {int maxLines = 3,
      double contentFontSize = 14,
      FontWeight contentFontWeight = FontWeight.bold}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 3, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(headerText1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.regularStyle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.grey : headerColor,
                  )),
              Spacer(),
              Text(headerText2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.regularStyle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.grey : headerColor,
                  )),
            ],
          ),
          Text(
            contentText,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: Styles.regularStyle
                .copyWith(fontSize: 14, fontWeight: contentFontWeight),
          ),
        ],
      ),
    );
  }

  static Widget officeExpensesList(
      BuildContext context,
      Box userDatabase,
      List<TotalExpensesResult> officeExpenses,
      List<ChamberMember> membersList,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    logger.d(
        '***** ALL EXPENSES: ${officeExpenses.map((e) => e.amount.toString())} *****');

    // bool viewMore = false;
    Color _thisPanelColor = stockWatchColor;
    bool _darkTheme = userDatabase.get('darkTheme');

    return ValueListenableBuilder(
        valueListenable:
            Hive.box(appDatabase).listenable(keys: ['subscriptionAlertsList']),
        builder: (context, box, widget) {
          officeExpenses = officeExpenses
                  .where((expense) =>
                      List.from(userDatabase.get('subscriptionAlertsList')).any(
                          (element) => element
                              .toString()
                              .toLowerCase()
                              .startsWith(
                                  'member_${expense.memberId}'.toLowerCase())))
                  .toList() +
              officeExpenses
                  .where((expense) =>
                      !List.from(userDatabase.get('subscriptionAlertsList'))
                          .any((element) => element
                              .toString()
                              .toLowerCase()
                              .startsWith('member_${expense.memberId}'.toLowerCase())))
                  .toList();

          return BounceInUp(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: _thisPanelColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Expanded(
                          child: new Text('Past Office Expenses',
                              style: GoogleFonts.bangers(
                                  color: Colors.white, fontSize: 25)),
                        ),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: darkThemeTextColor))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                          physics: BouncingScrollPhysics(),
                          primary: false,
                          shrinkWrap: true,
                          children: officeExpenses
                              .map(
                                (_thisExpense) => StatefulBuilder(
                                    builder: (context, setState) {
                                  final ChamberMember _thisMember =
                                      membersList.firstWhere(((element) =>
                                          element.id.toLowerCase() ==
                                          _thisExpense.memberId.toLowerCase()));
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FlipInX(
                                        child: Card(
                                          elevation: 0,
                                          color: Theme.of(context)
                                              .highlightColor
                                              .withOpacity(0.15),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: ListTile(
                                              dense: true,
                                              leading: List.from(userDatabase.get(
                                                          'subscriptionAlertsList'))
                                                      .any((element) => element
                                                          .toString()
                                                          .startsWith(
                                                              'member_${_thisExpense.memberId}'
                                                                  .toLowerCase()))
                                                  ? AnimatedWidgets.flashingEye(
                                                      context, true, false,
                                                      size: 15)
                                                  : FaIcon(
                                                      FontAwesomeIcons
                                                          .moneyCheckDollar,
                                                      size: 15),
                                              title: officeExpensesTextGroup(
                                                  context,
                                                  _thisPanelColor,
                                                  _darkTheme,
                                                  'Q${_thisExpense.quarter} ${_thisExpense.year}',
                                                  '${_thisExpense.name}'
                                                      .toUpperCase()),
                                              subtitle: Text(
                                                  'Amount: ${formatCurrency.format(_thisExpense.amount)}\nYTD: ${formatCurrency.format(_thisExpense.yearToDate)}\nChange from Prev Qtr: ${formatCurrency.format(_thisExpense.changeFromPreviousQuarter)}',
                                                  style: Styles.regularStyle
                                                      .copyWith(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              // trailing: FaIcon(
                                              //     FontAwesomeIcons.binoculars,
                                              //     size: 15),
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MemberDetail(
                                                          _thisMember.id,
                                                          houseStockWatchList,
                                                          senateStockWatchList),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              )
                              .toList()),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  static Widget officeExpensesTextGroup(BuildContext context, Color headerColor,
      bool darkTheme, String headerText, String contentText,
      {int maxLines = 3,
      double contentFontSize = 14,
      FontWeight contentFontWeight = FontWeight.bold}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 3, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(headerText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.regularStyle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.grey : headerColor,
                  )),
            ],
          ),
          Text(
            contentText,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: Styles.regularStyle
                .copyWith(fontSize: 14, fontWeight: contentFontWeight),
          ),
        ],
      ),
    );
  }

  static Widget subscriptionsList(
      BuildContext context,
      Box userDatabase,
      List<ChamberMember> members,
      List<UpdatedBill> bills,
      List<LobbyingRepresentation> lobbies,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList
      // List<dynamic> activeSubscriptions
      ) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase)
            .listenable(keys: ['darkTheme', 'subscriptionAlertsList']),
        builder: (context, box, widget) {
          List<dynamic> allSubscriptions = [];
          List<dynamic> activeSubscriptions =
              List.from(userDatabase.get('subscriptionAlertsList'));
          List<dynamic> inactiveSubscriptions = [];

          Color _thisPanelColor = altHighlightAccentColorDarkRed;
          bool _darkTheme = userDatabase.get('darkTheme');

          logger.d('***** ALL SUBSCRIPTIONS: $activeSubscriptions *****');

          if (activeSubscriptions.length > 0) {
            List<dynamic> _activeSubs = [];
            List<dynamic> _inactiveSubs = [];
            activeSubscriptions.forEach((sub) {
              if (sub.toString().startsWith('member_') &&
                  members.map((e) => e.id.toLowerCase()).toList().contains(
                      '${sub.toString().split('_')[1].toLowerCase()}')) {
                _activeSubs.add(sub);
                logger.d('***** NEW MEMBER SUB: $sub *****');
              } else if (sub.toString().startsWith('bill_') &&
                  bills.map((e) => e.billId).toList().contains(
                      '${sub.toString().split('_')[1].toLowerCase()}')) {
                _activeSubs.add(sub);
                logger.d('***** NEW BILL SUB: $sub *****');
              } else if (sub.toString().startsWith('lobby_') &&
                  lobbies.map((e) => e.id).toList().contains(
                      '${sub.toString().split('_')[1].toLowerCase()}')) {
                _activeSubs.add(sub);
                logger.d('***** NEW LOBBY SUB: $sub *****');
              } else {
                _inactiveSubs.add(sub);
              }
            });

            activeSubscriptions = _activeSubs;
            logger.d('***** FINAL ACTIVE SUBS: $activeSubscriptions *****');
            inactiveSubscriptions = _inactiveSubs;
            logger.d('***** FINAL INACTIVE SUBS: $inactiveSubscriptions *****');
            allSubscriptions = _activeSubs + _inactiveSubs;

            logger.d('***** FINAL ALL SUBS: $allSubscriptions *****');
          } else if (activeSubscriptions.length == 0) Navigator.pop(context);

          return BounceInUp(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                image: DecorationImage(
                    opacity: 0.15,
                    image: AssetImage(
                        'assets/congress_pic_${random.nextInt(4)}.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.background,
                        BlendMode.color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  new Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: _thisPanelColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           Expanded(
                            child: new Text(
                                'Watching ${allSubscriptions.length} Items',
                                style: GoogleFonts.bangers(
                                    color: Colors.white, fontSize: 25),),
                          ),

                        ],
                      ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                          Expanded(
                            child:  Text(
                              '${allSubscriptions.where((element) => element.toString().startsWith('bill_')).length} Bills | '
                                  '${allSubscriptions.where((element) => element.toString().startsWith('lobby_')).length} Lobbies | '
                                  '${allSubscriptions.where((element) => element.toString().startsWith('member_')).length} Members | '
                                  '${allSubscriptions.where((element) => element.toString().startsWith('other_')).length} Other Items',
                              style: TextStyle(
                                  color: Color(0xffffffff),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12),),)
                        ]),
                    ],),
                  ),
                  // new Container(
                  //   // height: 30,
                  //   // alignment: Alignment.center,
                  //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                  //   color: Theme.of(context).primaryColorDark,

                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       new Expanded(
                  //           child: new TextFormField(
                  //         autofocus: false,
                  //         onChanged: (val) => setState(() {
                  //         searchString = val;
                  //         }),
                  //         decoration: InputDecoration(
                  //           filled: true,
                  //           isDense: true,
                  //           isCollapsed: true,
                  //           fillColor: Color(0xaaffffff),
                  //           hintText: 'Search',
                  //           hintStyle: TextStyle(
                  //               fontSize: 14,
                  //               // color: thisPartyColor,
                  //               fontWeight: FontWeight.bold),
                  //           contentPadding:
                  //               EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  //           icon: Icon(Icons.search,
                  //               color: Color(0xffffffff), size: 20),
                  //         ),
                  //       )),
                  //     ],
                  //   ),
                  // ),
                  // Divider(
                  //   color: Colors.transparent,
                  // ),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        primary: false,
                        shrinkWrap: true,
                        children: activeSubscriptions
                                .map(
                                  (_thisActiveSubscription) => FlipInX(
                                    duration: Duration(milliseconds: 1000),
                                    child: Card(
                                      elevation: 0,
                                      color: _darkTheme
                                          ? Theme.of(context)
                                              .highlightColor
                                              .withOpacity(0.5)
                                          : Colors.white.withOpacity(0.5),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: ListTile(
                                            dense: true,
                                            leading: _thisActiveSubscription
                                                    .toString()
                                                    .startsWith('bill_')
                                                ? FaIcon(FontAwesomeIcons.scroll,
                                                    size: 15)
                                                : _thisActiveSubscription
                                                        .toString()
                                                        .startsWith('member_')
                                                    ? Icon(Icons.person,
                                                        size: 20)
                                                    : _thisActiveSubscription
                                                            .toString()
                                                            .startsWith(
                                                                'lobby_')
                                                        ? FaIcon(FontAwesomeIcons.moneyBills,
                                                            size: 15)
                                                        : _thisActiveSubscription
                                                                .toString()
                                                                .startsWith(
                                                                    'other_')
                                                            ? FaIcon(FontAwesomeIcons.featherPointed,
                                                                size: 15)
                                                            : FaIcon(FontAwesomeIcons.ghost,
                                                                size: 15),
                                            title:
                                                _thisActiveSubscription
                                                        .toString()
                                                        .startsWith('member_')
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'Member'
                                                                  .toUpperCase(),
                                                              style: Styles
                                                                  .regularStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color: _darkTheme
                                                                          ? null
                                                                          : _thisPanelColor)),
                                                          Text(
                                                            '${members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).shortTitle} ${members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).firstName} ${members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).lastName} (${members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).party})',
                                                            style: Styles
                                                                .regularStyle
                                                                .copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ],
                                                      )
                                                    : _thisActiveSubscription
                                                            .toString()
                                                            .startsWith('bill_')
                                                        ? Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                        'Bill'
                                                                            .toUpperCase(),
                                                                        style: Styles.regularStyle.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color: _darkTheme
                                                                                ? null
                                                                                : _thisPanelColor)),
                                                                  ),
                                                                  Text(
                                                                      '${dateWithDayFormatter.format(bills.firstWhere((b) => _thisActiveSubscription.toString().toLowerCase().contains('bill_${b.billId.toLowerCase()}')).latestMajorActionDate)}',
                                                                      style: Styles
                                                                          .regularStyle
                                                                          .copyWith(
                                                                              fontSize: 10))
                                                                ],
                                                              ),
                                                              Text(
                                                                '${bills.firstWhere((b) => _thisActiveSubscription.toString().toLowerCase().contains('bill_${b.billId.toLowerCase()}')).billSlug.toUpperCase()}',
                                                                style: Styles
                                                                    .regularStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                              ),
                                                            ],
                                                          )
                                                        : _thisActiveSubscription
                                                                .toString()
                                                                .startsWith(
                                                                    'lobby_')
                                                            ? Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Text(
                                                                            'Lobbying'
                                                                                .toUpperCase(),
                                                                            style:
                                                                                Styles.regularStyle.copyWith(fontSize: 12, color: _darkTheme ? null : _thisPanelColor)),
                                                                      ),
                                                                      Text(
                                                                          '${dateWithDayFormatter.format(lobbies.firstWhere((l) => _thisActiveSubscription.toString().toLowerCase().contains('lobby_${l.id.toLowerCase()}')).latestFiling.filingDate)}',
                                                                          style: Styles
                                                                              .regularStyle
                                                                              .copyWith(fontSize: 10))
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    '${lobbies.firstWhere((l) => _thisActiveSubscription.toString().toLowerCase().contains('lobby_${l.id.toLowerCase()}')).lobbyingClient.name}',
                                                                    style: Styles
                                                                        .regularStyle
                                                                        .copyWith(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                  ),
                                                                ],
                                                              )
                                                            : Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'Unknown Subscription',
                                                                    style: Styles
                                                                        .regularStyle
                                                                        .copyWith(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                            subtitle: _thisActiveSubscription
                                                    .toString()
                                                    .startsWith('member_')
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).state} ${members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).title}\n'
                                                        '${members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).phone}\n${members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).leadershipRole == null ? members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).office : members.firstWhere((m) => _thisActiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).leadershipRole}',
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Styles
                                                            .regularStyle
                                                            .copyWith(
                                                                fontSize: 13),
                                                      ),
                                                    ],
                                                  )
                                                : _thisActiveSubscription.toString().startsWith('bill_')
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${bills.firstWhere((b) => _thisActiveSubscription.toString().toLowerCase().contains('bill_${b.billId.toLowerCase()}')).shortTitle}\n'
                                                            '${dateWithDayFormatter.format(bills.firstWhere((b) => _thisActiveSubscription.toString().toLowerCase().contains('bill_${b.billId.toLowerCase()}')).latestMajorActionDate)}',
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: Styles
                                                                .regularStyle
                                                                .copyWith(
                                                                    fontSize:
                                                                        13),
                                                          ),
                                                        ],
                                                      )
                                                    : _thisActiveSubscription.toString().startsWith('lobby_')
                                                        ? Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${lobbies.firstWhere((l) => _thisActiveSubscription.toString().toLowerCase().contains('lobby_${l.id.toLowerCase()}')).specificIssues.first}',
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: Styles
                                                                    .regularStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            13),
                                                              ),
                                                            ],
                                                          )
                                                        : Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Unknown Details',
                                                                style: Styles
                                                                    .regularStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            13),
                                                              ),
                                                            ],
                                                          ),
                                            trailing: new Switch(
                                              inactiveThumbColor:
                                                  Theme.of(context)
                                                      .disabledColor,
                                              activeColor: _thisPanelColor,
                                              value: true,
                                              onChanged: (_) async {
                                                if (allSubscriptions.contains(
                                                    _thisActiveSubscription)) {
                                                  allSubscriptions.remove(
                                                      _thisActiveSubscription);
                                                  userDatabase.put(
                                                      'subscriptionAlertsList',
                                                      allSubscriptions);
                                                  await Functions
                                                      .processCredits(true,
                                                          isPermanent: false);
                                                  logger.d(
                                                      '***** DBase $_thisActiveSubscription Subscription removed from ${userDatabase.get('subscriptionAlertsList')} *****');
                                                } else if (!allSubscriptions
                                                    .contains(
                                                        _thisActiveSubscription)) {
                                                  allSubscriptions.add(
                                                      _thisActiveSubscription);
                                                  userDatabase.put(
                                                      'subscriptionAlertsList',
                                                      allSubscriptions);
                                                  await Functions
                                                      .processCredits(true,
                                                          isPermanent: false);
                                                  logger.d(
                                                      '***** DBase $_thisActiveSubscription Subscription added to ${userDatabase.get('subscriptionAlertsList')} *****');
                                                } else {
                                                  logger.d(
                                                      '***** COULD NOT PROCESS SUBSCRIPTION $_thisActiveSubscription... NOTHING DONE HERE. *****');
                                                }
                                              },
                                            ),
                                            onTap: () {
                                              // logger.d(lobbies
                                              //     .firstWhere((l) =>
                                              //         _thisActiveSubscription
                                              //             .toString()
                                              //             .toLowerCase()
                                              //             .contains(
                                              //                 'lobby_${l.id.toLowerCase()}'))
                                              //     .id);
                                              // Navigator.pop(context);
                                              _thisActiveSubscription
                                                      .toString()
                                                      .startsWith('member_')
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => MemberDetail(
                                                            members
                                                                .firstWhere((m) => _thisActiveSubscription
                                                                    .toString()
                                                                    .toLowerCase()
                                                                    .contains(m
                                                                        .id
                                                                        .toLowerCase()))
                                                                .id
                                                                .toLowerCase(),
                                                            houseStockWatchList,
                                                            senateStockWatchList),
                                                      ),
                                                    )
                                                  : _thisActiveSubscription
                                                          .toString()
                                                          .startsWith('bill_')
                                                      ? Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => BillDetail(
                                                                bills
                                                                    .firstWhere((b) => _thisActiveSubscription
                                                                        .toString()
                                                                        .toLowerCase()
                                                                        .contains(
                                                                            'bill_${b.billId.toLowerCase()}'))
                                                                    .billUri,
                                                                houseStockWatchList,
                                                                senateStockWatchList),
                                                          ),
                                                        )
                                                      : _thisActiveSubscription
                                                              .toString()
                                                              .startsWith(
                                                                  'lobby_')
                                                          ? Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        LobbyEventDetail(
                                                                  thisLobbyEventId: lobbies
                                                                      .firstWhere((l) => _thisActiveSubscription
                                                                          .toString()
                                                                          .toLowerCase()
                                                                          .contains(
                                                                              'lobby_${l.id.toLowerCase()}'))
                                                                      .id,
                                                                ),
                                                              ),
                                                            )
                                                          : logger.d(
                                                              '***** THERE IS NO WHERE TO GO FROM HERE... (subscriptions pop-up) *****');
                                            }),
                                      ),
                                    ),
                                  ),
                                )
                                .toList() +
                            [
                              FlipInX(
                                child: inactiveSubscriptions.isEmpty
                                    ? SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Archived'.toUpperCase(),
                                                style: Styles.regularStyle
                                                    .copyWith(
                                                        fontSize: 10,
                                                        color: _darkTheme
                                                            ? null
                                                            : _thisPanelColor)),
                                            // Divider(),
                                          ],
                                        ),
                                      ),
                              ),
                            ] +
                            inactiveSubscriptions
                                .map(
                                  (_inactiveSubscription) => FlipInX(
                                    child: Card(
                                      elevation: 0,
                                      color: _darkTheme
                                          ? Theme.of(context)
                                              .highlightColor
                                              .withOpacity(0.5)
                                          : Colors.white.withOpacity(0.5),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: ListTile(
                                          dense: true,
                                          leading: FaIcon(
                                              FontAwesomeIcons.boxArchive,
                                              size: 15),
                                          title: _inactiveSubscription
                                                  .toString()
                                                  .startsWith('member_')
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Member'.toUpperCase(),
                                                        style: Styles
                                                            .regularStyle
                                                            .copyWith(
                                                                fontSize: 12,
                                                                color:
                                                                    _thisPanelColor)),
                                                    Text(
                                                      '${members.firstWhere((m) => _inactiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).shortTitle} ${members.firstWhere((m) => _inactiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).firstName} ${members.firstWhere((m) => _inactiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).lastName} (${members.firstWhere((m) => _inactiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).party})',
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  ],
                                                )
                                              : _inactiveSubscription
                                                      .toString()
                                                      .startsWith('bill_')
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                  'Bill'
                                                                      .toUpperCase(),
                                                                  style: Styles
                                                                      .regularStyle
                                                                      .copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color: _darkTheme
                                                                              ? null
                                                                              : _thisPanelColor)),
                                                            ),
                                                            Text(
                                                                '${dateWithDayFormatter.format(DateTime.parse(_inactiveSubscription.toString().split('_')[4]))}',
                                                                style: Styles
                                                                    .regularStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            10))
                                                          ],
                                                        ),
                                                        Text(
                                                          '${_inactiveSubscription.toString().split('_')[1].toUpperCase()}',
                                                          style: Styles
                                                              .regularStyle
                                                              .copyWith(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ],
                                                    )
                                                  : _inactiveSubscription
                                                          .toString()
                                                          .startsWith('lobby_')
                                                      ? Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                      'Lobbying'
                                                                          .toUpperCase(),
                                                                      style: Styles.regularStyle.copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color: _darkTheme
                                                                              ? null
                                                                              : _thisPanelColor)),
                                                                ),
                                                                Text(
                                                                    '${dateWithDayFormatter.format(DateTime.parse(_inactiveSubscription.toString().split('_')[5]))}',
                                                                    style: Styles
                                                                        .regularStyle
                                                                        .copyWith(
                                                                            fontSize:
                                                                                10))
                                                              ],
                                                            ),
                                                            Text(
                                                              '${_inactiveSubscription.toString().split('_')[2]}'
                                                                  .toUpperCase(),
                                                              style: Styles
                                                                  .regularStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                          ],
                                                        )
                                                      : Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                'Unknown'
                                                                    .toUpperCase(),
                                                                style: Styles
                                                                    .regularStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            12)),
                                                            Text(
                                                              'Unknown Subscription',
                                                              style: Styles
                                                                  .regularStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                          ],
                                                        ),
                                          subtitle:
                                              // _inactiveSubscription
                                              //         .toString()
                                              //         .startsWith('member_')
                                              //     ? Text(
                                              //         '${members.firstWhere((m) => _inactiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).state} ${members.firstWhere((m) => _inactiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).title}\n'
                                              //         '${members.firstWhere((m) => _inactiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).leadershipRole == null ? members.firstWhere((m) => _inactiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).id : members.firstWhere((m) => _inactiveSubscription.toString().toLowerCase().contains(m.id.toLowerCase())).leadershipRole}',
                                              //         maxLines: 3,
                                              //         overflow: TextOverflow.ellipsis,
                                              //         style: Styles.regularStyle
                                              //             .copyWith(fontSize: 13),
                                              //       )
                                              //     :
                                              _inactiveSubscription
                                                      .toString()
                                                      .startsWith('bill_')
                                                  ? Text(
                                                      '${_inactiveSubscription.toString().split('_')[2]}',
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Styles.regularStyle
                                                          .copyWith(
                                                              fontSize: 13),
                                                    )
                                                  : _inactiveSubscription
                                                          .toString()
                                                          .startsWith('lobby_')
                                                      ? Text(
                                                          '${_inactiveSubscription.toString().split('_')[3]}',
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Styles
                                                              .regularStyle
                                                              .copyWith(
                                                                  fontSize: 13),
                                                        )
                                                      : Text(
                                                          'Unknown Details',
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Styles
                                                              .regularStyle
                                                              .copyWith(
                                                                  fontSize: 13),
                                                        ),
                                          trailing: new Switch(
                                            inactiveThumbColor:
                                                Theme.of(context).disabledColor,
                                            activeColor: _thisPanelColor,
                                            value: true,
                                            onChanged: (_) async {
                                              if (allSubscriptions.contains(
                                                  _inactiveSubscription)) {
                                                allSubscriptions.remove(
                                                    _inactiveSubscription);
                                                userDatabase.put(
                                                    'subscriptionAlertsList',
                                                    allSubscriptions);

                                                await Functions.processCredits(
                                                    true);
                                                logger.d(
                                                    '***** DBase $_inactiveSubscription Subscription removed from ${userDatabase.get('subscriptionAlertsList')} *****');
                                              } else if (!allSubscriptions
                                                  .contains(
                                                      _inactiveSubscription)) {
                                                allSubscriptions
                                                    .add(_inactiveSubscription);
                                                userDatabase.put(
                                                    'subscriptionAlertsList',
                                                    allSubscriptions);
                                                await Functions.processCredits(
                                                    true);
                                                logger.d(
                                                    '***** DBase $_inactiveSubscription Subscription added to ${userDatabase.get('subscriptionAlertsList')} *****');
                                              } else {
                                                logger.d(
                                                    '***** COULD NOT PROCESS SUBSCRIPTION $_inactiveSubscription... NOTHING DONE HERE. *****');
                                              }
                                            },
                                          ),
                                          onTap: () {
                                            _inactiveSubscription
                                                    .toString()
                                                    .startsWith('member_')
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => MemberDetail(
                                                          _inactiveSubscription
                                                              .toString()
                                                              .split('_')[1],
                                                          houseStockWatchList,
                                                          senateStockWatchList),
                                                    ),
                                                  )
                                                : _inactiveSubscription
                                                        .toString()
                                                        .startsWith('bill_')
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => BillDetail(
                                                                _inactiveSubscription
                                                                    .toString()
                                                                    .split(
                                                                        '_')[3],
                                                                houseStockWatchList,
                                                                senateStockWatchList)))
                                                    : _inactiveSubscription
                                                            .toString()
                                                            .startsWith(
                                                                'lobby_')
                                                        ? Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LobbyEventDetail(
                                                                // null,
                                                                thisLobbyEventId:
                                                                    _inactiveSubscription
                                                                        .toString()
                                                                        .split(
                                                                            '_')[1],
                                                              ),
                                                            ),
                                                          )
                                                        : logger.d(
                                                            '***** THERE IS NO WHERE TO GO FROM HERE... (subscriptions pop-up) *****');
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  static Widget floorActionsList(
      BuildContext context,
      String chamber,
      List<FloorAction> floorActionsList,
      Box userDatabase,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    logger.d(
        '***** ALL ${chamber.toUpperCase()} FLOOR ACTIONS: ${floorActionsList.map((e) => e.actionId)} *****');

    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase).listenable(keys: ['darkTheme']),
        builder: (context, box, widget) {
          // final actionKey = GlobalKey();
          // final thisContext = actionKey.currentContext;
          // Scrollable.ensureVisible(thisContext,
          //     duration: Duration(milliseconds: 1000));

          logger.i(chamber);

          Color _thisPanelColor = Theme.of(context).primaryColorDark;
          bool _darkTheme = userDatabase.get('darkTheme');

          return BounceInUp(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                image: DecorationImage(
                    opacity: 0.15,
                    image: AssetImage(
                        'assets/congress_pic_${random.nextInt(4)}.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.background,
                        BlendMode.color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    color: _thisPanelColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Expanded(
                          child: new Text('$chamber Floor Actions',
                              style: GoogleFonts.bangers(
                                  color: Colors.white, fontSize: 25)),
                        ),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: darkThemeTextColor))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        primary: false,
                        // shrinkWrap: true,
                        child: Column(
                            children: floorActionsList
                                .map(
                                  (_thisFloorAction) => Container(
                                    // key: actionKey,
                                    child: FlipInX(
                                      child: Card(
                                        elevation: 0,
                                        color: _darkTheme
                                            ? Theme.of(context)
                                                .highlightColor
                                                .withOpacity(0.5)
                                            : Colors.white.withOpacity(0.5),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: ListTile(
                                            dense: true,
                                            leading: FaIcon(
                                                FontAwesomeIcons.bullhorn,
                                                size: 15),
                                            title: floorActionsSimpleTextGroup(
                                                context,
                                                _thisPanelColor,
                                                _darkTheme,
                                                '${dateWithTimeFormatter.format(_thisFloorAction.timestamp)}',
                                                _thisFloorAction.description),
                                            trailing: _thisFloorAction
                                                    .billIds.isEmpty
                                                ? SizedBox.shrink()
                                                : FaIcon(
                                                    FontAwesomeIcons.binoculars,
                                                    size: 15),
                                            onTap: () =>
                                                _thisFloorAction.billIds.isEmpty
                                                    ? null
                                                    : Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => BillSearch(
                                                              _thisFloorAction
                                                                  .billIds.first
                                                                  .split(
                                                                      '-')[0],
                                                              houseStockWatchList,
                                                              senateStockWatchList),
                                                        ),
                                                      ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList()),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  static Widget floorActionsSimpleTextGroup(BuildContext context,
      Color headerColor, bool darkTheme, String headerText, String contentText,
      {int maxLines = 3,
      double contentFontSize = 14,
      FontWeight contentFontWeight = FontWeight.bold}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headerText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Styles.regularStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: darkTheme ? Colors.grey : headerColor,
            )),
        Text(
          contentText,
          // maxLines: maxLines,
          // overflow: TextOverflow.ellipsis,
          style: Styles.regularStyle
              .copyWith(fontSize: 14, fontWeight: contentFontWeight),
        ),
      ],
    );
  }

  static Widget statementTile(
      BuildContext context,
      int profileDefaultNumber,
      StatementsResults statement,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList,
      bool userIsPremium) {
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    final party = statement.party.toString().replaceFirst('Party.', '');
    final chamber = statement.chamber.toString().replaceFirst('Chamber.', '');
    final memberId = statement.memberId.toLowerCase();
    return StatefulBuilder(builder: (context, setState) {
      dynamic thisMemberImage =
          NetworkImage('https://www.congress.gov/img/member/$memberId.jpg');
      return FlipInX(
        animate: true,
        child: new Container(
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(5),
            border: Border(
                left: BorderSide(
              width: 4,
              color: party.toLowerCase() == 'd'
                  ? democratColor
                  : party.toLowerCase() == 'r'
                      ? republicanColor
                      : independentColor,
            )),
          ),
          alignment: Alignment.center,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                splashColor: party.toLowerCase() == 'd'
                    ? democratColor
                    : party.toLowerCase() == 'r'
                        ? republicanColor
                        : independentColor,
                onTap: () async {
                  Functions.linkLaunch(
                          context, statement.url, userDatabase, userIsPremium,
                          appBarTitle: statement.title)
                      .then((value) async =>
                          await Functions.processCredits(true));
                },
                child: new Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(5),
                        topRight: Radius.circular(5)),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(5),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemberDetail(
                                  statement.memberId,
                                  houseStockWatchList,
                                  senateStockWatchList),
                            ),
                          );
                        },
                        child: new Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            new Container(
                              height: 55,
                              width: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: new DecorationImage(
                                    image: AssetImage(
                                        'assets/congress_pic_$profileDefaultNumber.png'),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                        userDatabase.get('darkTheme')
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.transparent,
                                        BlendMode.color)),
                              ),
                              foregroundDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: new DecorationImage(
                                    image: thisMemberImage,
                                    fit: BoxFit.cover,
                                    onError: (error, stackTrace) => setState(
                                        () => thisMemberImage = AssetImage(
                                            'assets/intro_background.png'))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    // color: Theme.of(context)
                                    //     .primaryColor
                                    //     .withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(3)),
                                child: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(width: 3),
                                    new FaIcon(
                                      FontAwesomeIcons.solidIdCard,
                                      size: 9,
                                      color: Color(0xffffffff),
                                    ),
                                    SizedBox(width: 3),
                                    AnimatedWidgets.flashingEye(
                                        context,
                                        List.from(userDatabase
                                                .get('subscriptionAlertsList'))
                                            .any((element) => element
                                                .toString()
                                                .toLowerCase()
                                                .startsWith(
                                                    'member_${memberId.toLowerCase()}')),
                                        false,
                                        size: 9,
                                        sameColorBright: true),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: new Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              new Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  Text(
                                    statement.title
                                        .replaceAll('&amp;', '&')
                                        .replaceAll("&quot;", "\"")
                                        .replaceAll("&#39;", "'"),
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: new TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    '${chamber.toLowerCase() == 'house' ? 'Hon.' : 'Sen.'} ${statement.name}  of  ${statement.state}',
                                    style: new TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  const Spacer(),
                                  Text(
                                    formatter.format(statement.date),
                                    style: new TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.launch,
                                      size: 10, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget congressionalMemberCard(
      Color thisMemberColor,
      String thisMemberImageUrl,
      ChamberMember thisMember,
      BuildContext context,
      int index,
      List<HouseStockWatch> houseStockWatchList,
      List<SenateStockWatch> senateStockWatchList) {
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    bool _darkTheme = userDatabase.get('darkTheme');
    return FlipInX(
      duration: Duration(milliseconds: 800),
      child: Card(
        elevation: 0,
        color: _darkTheme
            ? Theme.of(context).highlightColor.withOpacity(0.5)
            : Colors.white.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: new ListTile(
            dense: false,
            leading: ZoomIn(
              child: Container(
                alignment: Alignment.topCenter,
                // height: 55,
                width: 45,
                decoration: BoxDecoration(
                    // shape: BoxShape.circle,
                    borderRadius: BorderRadius.circular(3),
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/congress_pic_${random.nextInt(4)}.png'),
                        fit: BoxFit.cover)),
                foregroundDecoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: thisMemberColor,
                  ),
                  // shape: BoxShape.circle,
                  borderRadius: BorderRadius.circular(3),
                  image: DecorationImage(
                      image: NetworkImage(thisMemberImageUrl),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            trailing: new Text('${thisMember.state}',
                style: GoogleFonts.bangers(
                    fontSize: 30,
                    color: _darkTheme ? Color(0xffffffff) : thisMemberColor)),
            title: new Row(
              children: [
                new Text(
                    '${thisMember.shortTitle.replaceFirst('Rep.', 'Hon.')} ${thisMember.firstName} ${thisMember.lastName}'),
                thisMember.suffix != null
                    ? new Text('  ${thisMember.suffix}')
                    : const SizedBox.shrink(),
                const SizedBox(width: 5),
                AnimatedWidgets.flashingEye(
                    context,
                    List.from(userDatabase.get('subscriptionAlertsList')).any(
                        (element) => element
                            .toString()
                            .toLowerCase()
                            .startsWith(
                                'member_${thisMember.id.toLowerCase()}')),
                    false,
                    size: 11)
              ],
            ),
            subtitle: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                thisMember.leadershipRole != null &&
                        thisMember.leadershipRole.isNotEmpty
                    ? new Text('${thisMember.leadershipRole}')
                    : const SizedBox.shrink(),
                thisMember.phone != null
                    ? new Text('${thisMember.phone}')
                    : const SizedBox.shrink(),
                thisMember.twitterAccount != null
                    ? new Text('@${thisMember.twitterAccount}')
                    : thisMember.youtubeAccount != null
                        ? new Text('📺 ${thisMember.youtubeAccount}')
                        : thisMember.title != null
                            ? new Text('${thisMember.title}')
                            : const SizedBox.shrink(),
              ],
            ),
            onTap: () async {
              // Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberDetail(
                      thisMember.id, houseStockWatchList, senateStockWatchList),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget ecwidProductsListing(
    BuildContext context,
    List<EcwidStoreItem> ecwidProductsList,
    Box userDatabase,
    List<bool> userLevels,
    List<Order> productOrdersList,
  ) {
    // List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    final bool darkTheme = userDatabase.get('darkTheme');
    final Color _thisPanelColor = Theme.of(context).primaryColorDark;
    // final int productIndex = random.nextInt(ecwidProductsList.length);
    // userDatabase.put('newEcwidProducts', false);

    debugPrint('^^^^^ USER LEVELS: $userLevels');

    /// PRUNE AND SORT LIST (REDUNDANT SINCE THIS IS DONE DURING INITIAL API CALL
    /// LEAVING HERE TO MAKE SURE ANY INSTALLS BEFORE 10/14/22 GET UPDATED STORE DATA
    /// SHOULD BE ABLE TO REMOVE 10/15/22 TODO
    ecwidProductsList.removeWhere((item) => !item.enabled);
    if (!userIsDev) {
      ecwidProductsList
          .removeWhere((item) => item.name.toLowerCase().contains('[dev]'));
    }

    ecwidProductsList.sort((a, b) => a.showOnFrontpage
        .compareTo(b.showOnFrontpage)
        .compareTo(a.createTimestamp.compareTo(b.createTimestamp)));

    return BounceInUp(
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              opacity: 0.15,
              image: AssetImage('assets/congress_pic_${random.nextInt(4)}.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.background, BlendMode.color)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: _thisPanelColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('US Congress App Merch',
                              style: GoogleFonts.bangers(
                                  color: darkThemeTextColor, fontSize: 25)),
                          new Text(
                              '${ecwidProductsList.length} Products Provided By SCAPEGOATS™ USA',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: darkThemeTextColor,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    productOrdersList.isEmpty
                        ? SizedBox.shrink()
                        : SizedBox(
                            width: 30,
                            child: IconButton(
                                onPressed: () => showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: false,
                                    enableDrag: true,
                                    context: context,
                                    builder: (context) {
                                      return SharedWidgets.pastProductOrders(
                                        context,
                                        userDatabase,
                                        userLevels,
                                        darkTheme,
                                      );
                                    }),
                                icon: Icon(Icons.history,
                                    color: darkThemeTextColor)),
                          ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: darkThemeTextColor))
                  ],
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                  child: Scrollbar(
                child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: ecwidProductsList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    itemBuilder: (context, index) {
                      EcwidStoreItem _thisItem = ecwidProductsList[index];
                      int _daysListed = DateTime.now()
                          .difference(DateTime.parse(_thisItem.created))
                          .inDays
                          .abs();
                      bool _itemIsNew = _daysListed <= 14;
                      bool _itemIsFeatured =
                          _thisItem.showOnFrontpage != null &&
                              _thisItem.showOnFrontpage >= 0 &&
                              _thisItem.showOnFrontpage < maxEcwidProductCount;
                      debugPrint(
                          '^^^^^ NAME: ${_thisItem.name}\nCREATED: ${_thisItem.created}\nUPDATED: ${_thisItem.updated}\nDAYS LISTED: $_daysListed\nITEM IS NEW: $_itemIsNew\nSKU: ${_thisItem.sku}\nATTRIBUTES: ${_thisItem.attributes}\nCATEGORIES: ${_thisItem.categories.map((e) => e.id)}\nCOMBINATIONS: ${_thisItem.combinations}\nCHOICES: ${_thisItem.options.map((e) => e.choices.map((c) => c.text))}\nFAV COUNT: ${_thisItem.favorites.count}\nFAV DISPLAYED: ${_thisItem.favorites.displayedCount}');

                      debugPrint(
                          '^^^^^ OPTIONS: ${_thisItem.options.map((e) => e.name.toString())}');
                      return FadeIn(
                          child: InkWell(
                              onTap: () async => await showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    enableDrag: true,
                                    isScrollControlled: false,
                                    context: context,
                                    builder: (context) => ecwidProductDetail(
                                        context,
                                        userDatabase,
                                        darkTheme,
                                        _thisItem,
                                        userLevels),
                                  ),
                              child: Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  GridTile(
                                    header: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            color: darkTheme
                                                ? Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.5)
                                                : Colors.white
                                                    .withOpacity(0.75),
                                            borderRadius:
                                                BorderRadius.circular(3)),
                                        child: Text(
                                            _thisItem.inStock
                                                ? _thisItem.unlimited
                                                    ? 'In Stock'
                                                    : 'In Stock'
                                                : 'Out Of Stock',
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Styles.regularStyle.copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: darkTheme
                                                  ? null
                                                  : _thisPanelColor,
                                            )),
                                      ),
                                    ),
                                    child: Container(
                                      // padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background
                                            .withOpacity(0.75),
                                        // image: DecorationImage(
                                        //     opacity: 0.5,
                                        //     image: AssetImage(
                                        //         'assets/intro_background.png'),
                                        //     fit: BoxFit.cover,
                                        //     colorFilter: ColorFilter.mode(
                                        //         darkTheme
                                        //             ? Theme.of(context)
                                        //                 .primaryColor
                                        //             : Colors.white,
                                        //         BlendMode.color)),
                                      ),
                                      child: FadeInImage(
                                        placeholder: AssetImage(darkTheme
                                            ? 'assets/app_icon_gray.png'
                                            : 'assets/app_icon.png'),
                                        fit: BoxFit.cover,
                                        placeholderFit: BoxFit.cover,
                                        image: NetworkImage(
                                            '${_thisItem.imageUrl}'),
                                      ),
                                      //   child: ZoomIn(
                                      //     // from: 10,
                                      //     // duration: Duration(milliseconds: 250),
                                      //     delay:
                                      //         Duration(milliseconds: 250 * index),
                                      //     child: Container(
                                      //       padding: const EdgeInsets.all(10),
                                      //       alignment: Alignment.center,
                                      //       decoration: BoxDecoration(
                                      //         borderRadius:
                                      //             BorderRadius.circular(3),
                                      //         image: DecorationImage(
                                      //             image: NetworkImage(
                                      //               '${_thisItem.imageUrl}',
                                      //             ),
                                      //             fit: BoxFit.cover),
                                      //       ),
                                      //     ),
                                      //   ),
                                    ),
                                    footer: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                            color: darkTheme
                                                ? Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.5)
                                                : Colors.white
                                                    .withOpacity(0.75),
                                            borderRadius:
                                                BorderRadius.circular(3)),
                                        child: Text(
                                          '${_thisItem.name}',
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Styles.regularStyle.copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: darkTheme
                                                ? null
                                                : _thisPanelColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    child: Row(
                                      children: [
                                        AnimatedWidgets.flashingText(
                                            context, 'New!', _itemIsNew, false,
                                            animate: true,
                                            size: 14,
                                            color: altHighlightColor,
                                            sameColor: true),
                                        Spacer(),
                                        _itemIsFeatured
                                            ? Icon(
                                                FontAwesomeIcons.solidStar,
                                                size: 10,
                                                color: altHighlightColor,
                                              )
                                            : SizedBox.shrink()
                                      ],
                                    ),
                                  ),
                                ],
                              )));
                    }),
              ))
            ]),
      ),
    );
  }

  static Widget ecwidProductDetail(
    BuildContext context,
    Box userDatabase,
    bool darkTheme,
    EcwidStoreItem thisEcwidProduct,
    List<bool> userLevels,
  ) {
    // List<bool> userLevels = await Functions.getUserLevels();
    // bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];
    return ValueListenableBuilder(
        valueListenable: Hive.box(appDatabase).listenable(
            keys: ['usageInfo', 'credits', 'permCredits', 'purchCredits']),
        builder: (context, box, widget) {
          Color _thisPanelColor = Theme.of(context).primaryColorDark;
          NetworkImage _thisProductImageUrl =
              NetworkImage(thisEcwidProduct.imageUrl);
          bool usageInfo = userDatabase.get('usageInfo');
          int credits = userDatabase.get('credits');
          int permCredits = userDatabase.get('permCredits');
          int purchCredits = userDatabase.get('purchCredits');
          int totalCredits = credits + permCredits + purchCredits;
          int creditsRequired =
              (thisEcwidProduct.price * ecwidProductCreditMultiplier).toInt();
          bool canBuy = totalCredits >= creditsRequired;

          return BounceInUp(
            child: Card(
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.background,
                  image: DecorationImage(
                      opacity: 0.5,
                      image: AssetImage('assets/intro_background.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.background,
                          BlendMode.color)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: new Column(
                    children: <Widget>[
                      Container(
                        height: 125,
                        width: MediaQuery.of(context).size.width,
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(3),
                        //   color: darkTheme ? Colors.white.withOpacity(0.4) : null,
                        // ),
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 10, 10),
                                      child: ZoomIn(
                                        child: Pulse(
                                          duration: Duration(milliseconds: 400),
                                          delay: Duration(milliseconds: 1500),
                                          child: GestureDetector(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: _thisProductImageUrl,
                                                    fit: BoxFit.cover),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            onTap: () => showModalBottomSheet(
                                                backgroundColor:
                                                    Colors.transparent,
                                                isScrollControlled: true,
                                                enableDrag: false,
                                                context: context,
                                                builder: (context) {
                                                  return BounceInUp(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        InteractiveViewer(
                                                          constrained: true,
                                                          child: FadeInImage(
                                                            placeholder: AssetImage(
                                                                darkTheme
                                                                    ? 'assets/app_icon_gray.png'
                                                                    : 'assets/app_icon.png'),
                                                            fit: BoxFit.cover,
                                                            placeholderFit:
                                                                BoxFit.cover,
                                                            image:
                                                                _thisProductImageUrl,
                                                          ),
                                                        ),
                                                        SizedBox(height: 10),
                                                        IconButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            icon: Icon(
                                                                Icons
                                                                    .cancel_outlined,
                                                                color:
                                                                    darkThemeTextColor)),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ),
                                      ),
                                    )),
                                Flexible(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            thisEcwidProduct.name.toUpperCase(),
                                            // softWrap: true,
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                            style: Styles.regularStyle.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          'Price: $creditsRequired Credits',
                                          style: Styles.regularStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Credits Available: $totalCredits',
                                              style: Styles.regularStyle
                                                  .copyWith(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: !canBuy
                                                          ? darkTheme
                                                              ? null
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error
                                                          : darkTheme
                                                              ? alertIndicatorColorBrightGreen
                                                              : alertIndicatorColorDarkGreen),
                                            ),
                                            SizedBox(width: 20),
                                            Tooltip(
                                              preferBelow: true,
                                              enableFeedback: true,
                                              showDuration:
                                                  Duration(seconds: 3),
                                              triggerMode:
                                                  TooltipTriggerMode.tap,
                                              message:
                                                  'Get credits fast by sharing & rating the app, or purchase them directly!',
                                              margin: const EdgeInsets.only(
                                                  left: 100, right: 30),
                                              child: Icon(Icons.info,
                                                  size: 14,
                                                  color: darkThemeTextColor),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                    child: Stack(
                                      children: [
                                        Icon(FontAwesomeIcons.share,
                                            size: 16,
                                            color: darkTheme
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Colors.white),
                                        Icon(FontAwesomeIcons.share,
                                            size: 15,
                                            color: darkTheme
                                                ? alertIndicatorColorBrightGreen
                                                : Theme.of(context)
                                                    .primaryColorDark),
                                      ],
                                    ),
                                    onTap: () => Messages.shareContent(false,
                                        subject: thisEcwidProduct.name,
                                        message:
                                            'I thought you might be interested in this awesome product! Check it out at ${thisEcwidProduct.url}'),
                                  ),
                                  SizedBox(width: 5),
                                  AnimatedWidgets.flashingText(
                                      context,
                                      'New!',
                                      DateTime.now()
                                              .difference(DateTime.parse(
                                                  thisEcwidProduct.created))
                                              .inDays <=
                                          18,
                                      false,
                                      sameColor: true,
                                      size: 16,
                                      color: altHighlightColor),
                                  // SizedBox(width: 15),
                                  // Stack(
                                  //   children: [
                                  //     Icon(
                                  //         Icons
                                  //             .photo_size_select_actual_rounded,
                                  //         size: 16,
                                  //         color: darkTheme
                                  //             ? Theme.of(context)
                                  //                 .colorScheme
                                  //                 .primary
                                  //             : Colors.white),
                                  //     Icon(
                                  //         Icons
                                  //             .photo_size_select_actual_rounded,
                                  //         size: 15,
                                  //         color: darkTheme
                                  //             ? alertIndicatorColorBrightGreen
                                  //             : Theme.of(context)
                                  //                 .primaryColorDark),
                                  //   ],
                                  // ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      // SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                                width: 1,
                                color: _thisPanelColor.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Text(
                                thisEcwidProduct.description
                                    .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                                // maxLines: 5,
                                // overflow: TextOverflow.ellipsis,
                                style: Styles.regularStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          height: 25,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    child: Text(
                                      'Maybe Later',
                                      style: Styles.regularStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: darkTheme
                                              ? darkThemeTextColor
                                              : _thisPanelColor),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.transparent),
                                    ),
                                    onPressed: () =>
                                        Navigator.maybePop(context),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    child: Text(
                                      thisEcwidProduct.inStock
                                          ? canBuy
                                              ? 'I Need This'
                                              : 'Purchase Credits'
                                          : 'Out Of Stock',
                                      style: Styles.regularStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: darkThemeTextColor),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              thisEcwidProduct.inStock
                                                  ? _thisPanelColor
                                                  : _thisPanelColor
                                                      .withOpacity(0.25)),
                                    ),
                                    onPressed: thisEcwidProduct.inStock
                                        ? canBuy
                                            ? !usageInfo
                                                ? () =>
                                                    Functions.requestUsageInfo(
                                                        context)
                                                : () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EcwidOrderPage(
                                                            title:
                                                                'Product Order Details',
                                                            creditsToBuy:
                                                                creditsRequired,
                                                            productId:
                                                                thisEcwidProduct
                                                                    .id,
                                                            product:
                                                                thisEcwidProduct,
                                                          ),
                                                        ));
                                                  }
                                            : () =>
                                                Functions.requestInAppPurchase(
                                                    context, userIsPremium,
                                                    whatToShow: 'credits')
                                        : () => null,
                                  ),
                                )
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  static Widget pastProductOrders(
    BuildContext context,
    Box userDatabase,
    List<bool> userLevels,
    bool darkTheme,
    // List<Order> orders,
  ) {
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];
    Color _thisPanelColor = Theme.of(context).primaryColorDark;
    // final List<String> subscriptionAlertsList =
    //     List.from(userDatabase.get('subscriptionAlertsList'));

    /// PRODUCT ORDERS LIST
    List<Order> orders = [];
    try {
      orders =
          orderDetailListFromJson(userDatabase.get('ecwidProductOrdersList'))
              .orders;
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
    }

    return BounceInUp(
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          image: DecorationImage(
              opacity: 0.4,
              image: AssetImage('assets/intro_background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.background, BlendMode.color)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: _thisPanelColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('In-App Product Purchases',
                              style: GoogleFonts.bangers(
                                  color: darkThemeTextColor, fontSize: 25)),
                          new Text(
                              '${orders.length} ${orders.length == 1 ? 'Purchase' : 'Purchases'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: darkThemeTextColor,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: darkThemeTextColor))
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      children: orders
                          .map((_thisOrder) => FlipInX(
                                child: Card(
                                  elevation: 0,
                                  color: darkTheme
                                      ? Theme.of(context)
                                          .highlightColor
                                          .withOpacity(0.75)
                                      : Theme.of(context)
                                          .colorScheme
                                          .background
                                          .withOpacity(0.75),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Dismissible(
                                      key: ValueKey(_thisOrder.orderId),
                                      secondaryBackground: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 20),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Spacer(),
                                                Icon(
                                                    Icons
                                                        .delete_forever_rounded,
                                                    color: darkThemeTextColor)
                                              ])),
                                      background: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 20),
                                          color: alertIndicatorColorDarkGreen,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Icon(Icons.agriculture_rounded,
                                                    color: darkThemeTextColor),
                                                Spacer(),
                                              ])),
                                      onDismissed: userIsDev
                                          ? (direction) {
                                              if (direction ==
                                                  DismissDirection.endToStart) {
                                                orders.removeWhere((item) =>
                                                    item.orderId ==
                                                    _thisOrder.orderId);
                                                try {
                                                  userDatabase.put(
                                                      'ecwidProductOrdersList',
                                                      orderDetailListToJson(
                                                          OrderDetailList(
                                                              orders: orders)));
                                                  Messages.showMessage(
                                                      context: context,
                                                      message:
                                                          'DAMN! You swiped left... List item has been removed.',
                                                      isAlert: false);
                                                } catch (e) {
                                                  debugPrint(
                                                      'ERROR SAVING UPDATES ORDERS LIST TO DBASE (widgets): $e');
                                                }
                                              } else if (direction ==
                                                  DismissDirection.startToEnd) {
                                                Messages.showMessage(
                                                    context: context,
                                                    message:
                                                        'You swiped right!!!',
                                                    isAlert: false);
                                              }
                                            }
                                          : null,
                                      child: ListTile(
                                        dense: false,
                                        title: simpleTextGroup(
                                            context,
                                            _thisPanelColor,
                                            darkTheme,
                                            Row(
                                              children: [
                                                Text(
                                                    'ID: ${_thisOrder.orderId}_ms:${_thisOrder.orderDate.millisecond}'
                                                        .toUpperCase(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Styles.regularStyle
                                                        .copyWith(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: darkTheme
                                                          ? Colors.grey
                                                          : _thisPanelColor,
                                                    )),
                                                Spacer(),
                                              ],
                                            ),
                                            '${_thisOrder.productName}'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Order Date: ${dateWithTimeFormatter.format(_thisOrder.orderDate)}\nOptions: ${_thisOrder.productOptions}\nPrice: ${_thisOrder.productPrice}',
                                                style: Styles.regularStyle
                                                    .copyWith(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          ],
                                        ),
                                        trailing: ZoomIn(
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 45,
                                            width: 45,
                                            // decoration: BoxDecoration(
                                            //   shape: BoxShape.rectangle,
                                            //   border: Border.all(
                                            //       width: 1,
                                            //       color: darkThemeTextColor),
                                            //   image: DecorationImage(
                                            //       opacity: 4,
                                            //       image: AssetImage(
                                            //           'assets/intro_background.png'),
                                            //       fit: BoxFit.cover,
                                            //       colorFilter:
                                            //           ColorFilter.mode(
                                            //               stockWatchColor,
                                            //               BlendMode.color)),
                                            // ),
                                            foregroundDecoration: BoxDecoration(
                                              // border: Border.all(
                                              //     width: 1,
                                              //     color: darkThemeTextColor),
                                              // shape: BoxShape.circle,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              image: DecorationImage(
                                                  image: _thisOrder.orderId
                                                          .startsWith('EPO')
                                                      ? NetworkImage(_thisOrder
                                                          .productImageUrl)
                                                      : AssetImage(
                                                          'assets/app_icon.png'),
                                                  fit: BoxFit.fitWidth),
                                            ),
                                          ),
                                        ),
                                        onTap: () => null,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList()),
                ),
              )
            ]),
      ),
    );
  }
}
