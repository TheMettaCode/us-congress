import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/constants/widgets.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/models/office_expenses_member.dart';
import 'package:us_congress_vote_tracker/models/private_funded_trips_by_member_model.dart';
import 'package:us_congress_vote_tracker/services/admob/admob_ad_library.dart';
import 'package:us_congress_vote_tracker/models/members_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/house_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/senate_stock_watch_model.dart';

import '../functions/propublica_api_functions.dart';

class MemberDetail extends StatefulWidget {
  const MemberDetail(this.memberId, this.memberHouseStockTrades, this.memberSenateStockTrades,
      {Key key})
      : super(key: key);
  final String memberId;
  final List<HouseStockWatch> memberHouseStockTrades;
  final List<SenateStockWatch> memberSenateStockTrades;

  @override
  MemberDetailState createState() => MemberDetailState();
}

class MemberDetailState extends State<MemberDetail> {
  bool _isLoading = true;
  String _loadingTextString = 'Fetching member data...';
  List<bool> userIs = [false, false, false];
  bool userIsDev = false;
  bool userIsPremium = false;
  bool userIsLegacy = false;

  double dataWindowHeight = 400;

  List<MemberTripsResult> memberPrivateTravel = [];
  bool showPrivateTravel = false;

  List<MemberExpensesResult> memberOfficeExpenses = [];
  double memberOfficeExpensesTotal = 0;
  int memberOfficeExpensesYear = 2022;
  int memberOfficeExpensesQuarter = 1;
  bool showOfficeExpenses = false;

  Container bannerAdContainer = Container();
  bool showBannerAd = true;
  bool adLoaded = false;
  String randomAssetImageUrl = 'assets/congress_pic_0.png';

  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  List<dynamic> subscriptionAlertsList = [];

  MemberResult thisMember;
  bool isHouseMember = false;

  List<HouseStockWatch> thisHouseMemberStockTrades = [];
  List<SenateStockWatch> thisSenateMemberStockTrades = [];
  bool showTradeActivity = false;

  Color memberContainerColor;
  Color memberContainerTextColor;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setInitialVariables();
      await getData();
    });
    super.initState();
    setState(() {
      _isLoading = false;
      // _loadingTextString = 'Fetching member data...';
    });
  }

  Future<void> setInitialVariables() async {
    await Functions.getUserLevels().then(((status) => setState(() {
          userIs = status;
          userIsDev = status[0];
          userIsPremium = status[1];
          userIsLegacy = status[2];
        })));

    // ADMOB INFORMATION HERE
    if (!userIsPremium) {
      final BannerAd thisBanner = AdMobLibrary().defaultBanner();

      await thisBanner.load();

      if (thisBanner != null) {
        setState(() {
          adLoaded = true;
          bannerAdContainer = AdMobLibrary().bannerContainer(thisBanner, context);
        });
      }
    }

    setState(() => randomAssetImageUrl = 'assets/congress_pic_${random.nextInt(4)}.png');
  }

  Future<void> getData() async {
    setState(() => _isLoading = true);

    // setState(() => _loadingTextString = 'Fetching member data...');
    await PropublicaApi.fetchMember(widget.memberId.toLowerCase())
        .then((value) => setState(() => thisMember = value.first));

    setState(() =>
        _loadingTextString = 'Fetching data for ${thisMember.firstName} ${thisMember.lastName}...');
    if (thisMember.roles.first.chamber.toLowerCase() == 'house') {
      setState(() {
        isHouseMember = true;
        // _loadingTextString = 'Fetching house member market trades...';
      });
      thisHouseMemberStockTrades = widget.memberHouseStockTrades
          .where((element) =>
              element.representative
                      .toLowerCase()
                      // .replaceFirst('robert', 'bob')
                      .replaceFirst('earl l.', 'buddy')
                      .split(' ')[1][0] ==
                  thisMember.firstName.toLowerCase()[0] &&
              element.representative.toLowerCase().contains(thisMember.lastName.toLowerCase()))
          .toList();
    } else {
      // setState(
      //     () => _loadingTextString = 'Fetching senate member market trades...');
      thisSenateMemberStockTrades = widget.memberSenateStockTrades
          .where((element) =>
              element.senator
                      .toLowerCase()
                      .replaceFirst('a. mitchell', 'mitch')
                      .replaceFirst('william', 'bill')[0] ==
                  thisMember.firstName[0].toLowerCase() &&
              element.senator.toLowerCase().contains(thisMember.lastName.toLowerCase()))
          .toList();
    }

    // if (userIsPremium) {
    setState(() => _loadingTextString = 'Fetching privately funded travel data...');
    await PropublicaApi.fetchPrivateFundedTravelByMember(context, widget.memberId)
        .then((value) => setState(() => memberPrivateTravel = value));
    if (userIsPremium && thisMember.roles.first.chamber.toLowerCase() == 'house') {
      await determineExpenses();
    }
    // }

    setState(() {
      subscriptionAlertsList = List.from(userDatabase.get('subscriptionAlertsList'));
      memberContainerColor = Theme.of(context).primaryColor.withOpacity(0.15);
      memberContainerTextColor = darkThemeTextColor;
    });

    setState(() => _isLoading = false);
  }

  Future<void> determineExpenses() async {
    /// DETERMINING VALID EXPENSES PERIOD HERE
    setState(() => _loadingTextString = 'Fetching office expenses...');
    List<MemberExpensesResult> tempMemberOfficeExpenses = [];
    int attempts = 0;
    int thisYear = DateTime.now().year;
    int thisMonth = DateTime.now().month;
    int thisQuarter = thisMonth >= 1 && thisMonth < 4
        ? 1
        : thisMonth >= 4 && thisMonth < 7
            ? 2
            : thisMonth >= 7 && thisMonth < 10
                ? 3
                : 4;

    while (tempMemberOfficeExpenses.isEmpty && attempts < 4) {
      logger.i('ATTEMPT $attempts for  Q$thisQuarter $thisYear');
      await PropublicaApi.fetchMemberOfficeExpenses(
              widget.memberId.toLowerCase(), thisYear, thisQuarter)
          .then((value) {
        setState(() {
          tempMemberOfficeExpenses = value;
          memberOfficeExpensesYear = thisYear;
          memberOfficeExpensesQuarter = thisQuarter;
        });
        thisYear = thisQuarter - 1 == 0 ? thisYear - 1 : thisYear;
        thisQuarter = thisQuarter - 1 == 0 ? 4 : thisQuarter - 1;
        attempts++;
      });
      setState(() {
        memberOfficeExpenses = tempMemberOfficeExpenses;
      });
    }

    logger.i('CALCULATING TOTAL EXPENSES');
    setState(() => _loadingTextString = 'Calculating total expenses for most recent quarter...');
    List<double> memberOfficeExpensesAmounts =
        tempMemberOfficeExpenses.map((e) => e.amount).toList();
    double expensesTotal = memberOfficeExpensesAmounts.fold<double>(
        0.0, (previousValue, element) => previousValue + element);
    memberOfficeExpensesTotal = expensesTotal;
    logger.i('TOTAL EXPENSES $expensesTotal');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Member Details', style: GoogleFonts.bangers(fontSize: 25)),
        // systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _isLoading || thisMember == null
          ? Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 500),
                child: Pulse(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 500),
                  // infinite: true,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      image: DecorationImage(
                          opacity: 0.15,
                          image: AssetImage(randomAssetImageUrl),
                          repeat: ImageRepeat.repeat,
                          // fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.background, BlendMode.color)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const CircularProgressIndicator(
                                strokeWidth: 5,
                                color: republicanColor,
                                backgroundColor: democratColor,
                              ),
                              SpinPerfect(
                                  infinite: true,
                                  animate: true,
                                  spins: 2,
                                  child: Image.asset('assets/watchtower_icon.png')),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(_loadingTextString, style: GoogleFonts.bangers(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : ValueListenableBuilder(
              valueListenable:
                  Hive.box(appDatabase).listenable(keys: ['darkTheme', 'subscriptionAlertsList']),
              builder: (context, box, widget) {
                String thisMemberString = 'member_${thisMember.id}_member';
                return Container(
                  color: Theme.of(context).colorScheme.background,
                  child: ListView(
                    primary: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      FadeIn(
                        child: Image.asset('assets/congress_pic_${random.nextInt(4)}.png',
                            color: Theme.of(context).primaryColor,
                            height: 125,
                            fit: BoxFit.cover,
                            colorBlendMode: BlendMode.softLight),
                      ),
                      Container(
                        // elevation: 0.0,

                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.15),
                          // color: Theme.of(context).colorScheme.background,
                          image: DecorationImage(
                              opacity: 0.15,
                              image: AssetImage(randomAssetImageUrl),
                              fit: BoxFit.cover,
                              // repeat: ImageRepeat.repeat,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.background, BlendMode.color)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              // decoration: BoxDecoration(
                              //   color: Theme.of(context).primaryColor.withOpacity(0.15),
                              //   // color: Theme.of(context).colorScheme.background,
                              //   image: DecorationImage(
                              //       opacity: 0.15,
                              //       image: AssetImage(randomAssetImageUrl),
                              //       fit: BoxFit.cover,
                              //       // repeat: ImageRepeat.repeat,
                              //       colorFilter: ColorFilter.mode(
                              //           Theme.of(context).colorScheme.background, BlendMode.color)),
                              // ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${thisMember.roles.first.shortTitle.replaceFirst('Rep.', 'Hon.')} ${thisMember.firstName} ${thisMember.lastName} ${thisMember.suffix == null || thisMember.suffix.isEmpty ? '' : thisMember.suffix}'
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  userIsPremium || userIsLegacy
                                      ? SizedBox(
                                          height: 20,
                                          child: ElevatedButton.icon(
                                            icon: AnimatedWidgets.flashingEye(
                                                context,
                                                List<String>.from(
                                                        userDatabase.get('subscriptionAlertsList'))
                                                    .any((element) => element
                                                        .toLowerCase()
                                                        .startsWith('member_${thisMember.memberId}'
                                                            .toLowerCase())),
                                                true,
                                                size: 11,
                                                sameColorBright: true),
                                            label: Text(
                                              List<String>.from(userDatabase
                                                          .get('subscriptionAlertsList'))
                                                      .any((element) => element
                                                          .toLowerCase()
                                                          .startsWith(
                                                              'member_${thisMember.memberId}'
                                                                  .toLowerCase()))
                                                  ? 'ON'
                                                  : 'OFF',
                                              style: GoogleFonts.bangers(
                                                  color: Colors.white, fontSize: 17),
                                            ),
                                            onPressed: () async {
                                              if (!List.from(
                                                      userDatabase.get('subscriptionAlertsList'))
                                                  .any((element) => element
                                                      .toString()
                                                      .toLowerCase()
                                                      .startsWith('member_${thisMember.memberId}'
                                                          .toLowerCase()))) {
                                                subscriptionAlertsList.add(thisMemberString);
                                                userDatabase.put('subscriptionAlertsList',
                                                    subscriptionAlertsList);

                                                // if (!userDatabase
                                                //     .get('memberAlerts'))
                                                //   userDatabase.put(
                                                //       'memberAlerts', true);

                                                await Functions.processCredits(true);
                                              } else {
                                                subscriptionAlertsList.removeWhere((element) =>
                                                    element.toString().toLowerCase().startsWith(
                                                        'member_${thisMember.memberId}'
                                                            .toLowerCase()));
                                                userDatabase.put('subscriptionAlertsList',
                                                    subscriptionAlertsList);
                                              }
                                            },
                                            style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all<Color>(
                                                    Theme.of(context).primaryColorDark)),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                            // Divider(),
                            Container(
                              color: userDatabase.get('darkTheme')
                                  ? memberContainerColor
                                  : thisMember.currentParty.toLowerCase() == 'd'
                                      ? democratColor
                                      : thisMember.currentParty.toLowerCase() == 'r'
                                          ? republicanColor
                                          : thisMember.currentParty.toLowerCase() == 'i'
                                              ? independentColor
                                              : memberContainerColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 130,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/congress_pic_${random.nextInt(4)}.png'),
                                                    fit: BoxFit.cover,
                                                    colorFilter: ColorFilter.mode(
                                                        userDatabase.get('darkTheme')
                                                            ? Theme.of(context).colorScheme.primary
                                                            : Colors.transparent,
                                                        BlendMode.color))),
                                            foregroundDecoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        'https://www.congress.gov/img/member/${thisMember.memberId.toLowerCase()}.jpg'),
                                                    fit: BoxFit.cover)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                thisMember.currentParty == 'D'
                                                    ? 'Democrat'
                                                    : thisMember.currentParty == 'R'
                                                        ? 'Republican'
                                                        : 'Independent',
                                                style: TextStyle(
                                                    color: memberContainerTextColor,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${thisMember.roles.first.chamber} - ${thisMember.roles.first.title}',
                                            style: TextStyle(
                                                color: memberContainerTextColor,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Congress: ${thisMember.roles.first.congress}',
                                            style: TextStyle(
                                                color: memberContainerTextColor,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'State: ',
                                                style: TextStyle(
                                                    color: memberContainerTextColor,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              thisMember.roles.first.state == null
                                                  ? const Text('No State Information')
                                                  : Text(
                                                      thisMember.roles.first.state,
                                                      style: TextStyle(
                                                          color: memberContainerTextColor,
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.normal),
                                                    ),
                                              thisMember.roles.first.chamber == 'Senate'
                                                  ? const Text('')
                                                  : Row(
                                                      children: [
                                                        Text(
                                                          ', Dist: ',
                                                          style: TextStyle(
                                                              color: memberContainerTextColor,
                                                              fontSize: 12.0,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        thisMember.roles.first.district == null
                                                            ? const Text('No District Information')
                                                            : Text(
                                                                thisMember.roles.first.district,
                                                                style: TextStyle(
                                                                    color: memberContainerTextColor,
                                                                    fontSize: 12.0,
                                                                    fontWeight: FontWeight.normal),
                                                              ),
                                                      ],
                                                    ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'Start Date: ',
                                                style: TextStyle(
                                                    color: memberContainerTextColor,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                              thisMember.roles.first.startDate == null
                                                  ? const Text('No Information')
                                                  : Text(
                                                      formatter
                                                          .format(thisMember.roles.first.startDate),
                                                      style: TextStyle(
                                                          color: memberContainerTextColor,
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.normal),
                                                    ),
                                            ],
                                          ),
                                          // new SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'End Date: ',
                                                style: TextStyle(
                                                    color: memberContainerTextColor,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                              thisMember.roles.first.endDate == null
                                                  ? const Text('No Information')
                                                  : Text(
                                                      formatter
                                                          .format(thisMember.roles.first.endDate),
                                                      style: TextStyle(
                                                          color: memberContainerTextColor,
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.normal),
                                                    ),
                                            ],
                                          ),
                                          // new SizedBox(height: 8),
                                          thisMember.roles.first.nextElection == null
                                              ? const SizedBox.shrink()
                                              : Row(
                                                  children: [
                                                    Text(
                                                      'Next Election: ',
                                                      style: TextStyle(
                                                          color: memberContainerTextColor,
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.normal),
                                                    ),
                                                    Text(
                                                      thisMember.roles.first.nextElection,
                                                      style: TextStyle(
                                                          color: memberContainerTextColor,
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.normal),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 25,
                                child: Row(
                                  children: <Widget>[
                                    thisMember.roles.first.phone == null
                                        ? const SizedBox.shrink()
                                        : Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                              child: ElevatedButton.icon(
                                                  icon: const Icon(Icons.phone,
                                                      color: darkThemeTextColor, size: 15),
                                                  label: const Text('Call',
                                                      style: TextStyle(color: darkThemeTextColor)),
                                                  onPressed: () async => await launchUrl(Uri.parse(
                                                      'tel://${thisMember.roles.first.phone}')),
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all<Color>(
                                                              Theme.of(context).primaryColorDark))),
                                            ),
                                          ),
                                    thisMember.twitterAccount == null
                                        ? const SizedBox.shrink()
                                        : Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                              child: ElevatedButton.icon(
                                                  icon: const Icon(Icons.launch,
                                                      color: darkThemeTextColor, size: 15),
                                                  label: const Text('Twitter',
                                                      style: TextStyle(color: darkThemeTextColor)),
                                                  onPressed: () async => await Functions.linkLaunch(
                                                      context,
                                                      'https://twitter.com/${thisMember.twitterAccount}',
                                                      userDatabase,
                                                      userIsPremium,
                                                      appBarTitle: '@${thisMember.twitterAccount}'),
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all<Color>(
                                                              Theme.of(context).primaryColorDark))),
                                            ),
                                          ),
                                    thisMember.url == null
                                        // || thisMember.url.isEmpty
                                        ? const SizedBox.shrink()
                                        : Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                              child: ElevatedButton.icon(
                                                  icon: const Icon(Icons.web,
                                                      color: darkThemeTextColor, size: 15),
                                                  label: const Text('Website',
                                                      style: TextStyle(color: darkThemeTextColor)),
                                                  onPressed: () async => await Functions.linkLaunch(
                                                      context,
                                                      thisMember.url,
                                                      userDatabase,
                                                      userIsPremium,
                                                      appBarTitle:
                                                          '${thisMember.firstName} ${thisMember.lastName}'),
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all<Color>(
                                                              Theme.of(context).primaryColorDark))),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 25,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                        child: ElevatedButton.icon(
                                          icon: FaIcon(FontAwesomeIcons.planeDeparture,
                                              size: 12,
                                              color: userIsPremium || userIsLegacy
                                                  ? darkThemeTextColor
                                                  : null),
                                          label: Text('Funded Travel',
                                              style: TextStyle(
                                                  color: userIsPremium || userIsLegacy
                                                      ? darkThemeTextColor
                                                      : null)),
                                          onPressed: () async => !userIsPremium && !userIsLegacy
                                              ? Functions.requestInAppPurchase(
                                                  context, null, userIsPremium,
                                                  whatToShow: 'upgrades')
                                              : memberPrivateTravel.isEmpty
                                                  ? null
                                                  : setState(() {
                                                      showPrivateTravel = !showPrivateTravel;
                                                      showOfficeExpenses = false;
                                                      showTradeActivity = false;
                                                    }),
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(
                                                  (!userIsPremium && !userIsLegacy) ||
                                                          memberPrivateTravel.isEmpty
                                                      ? Theme.of(context).disabledColor
                                                      : Theme.of(context).primaryColorDark)),
                                        ),
                                      ),
                                    ),
                                    thisMember.roles.first.chamber.toLowerCase() == 'senate'
                                        ? const SizedBox.shrink()
                                        : Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                              child: ElevatedButton.icon(
                                                icon: FaIcon(FontAwesomeIcons.moneyCheckDollar,
                                                    size: 12,
                                                    color: (userIsPremium || userIsLegacy) &&
                                                            memberOfficeExpenses.isNotEmpty
                                                        ? darkThemeTextColor
                                                        : null),
                                                label: Text(
                                                    (!userIsPremium && !userIsLegacy) ||
                                                            memberOfficeExpenses.isEmpty
                                                        ? 'Office Expenses'
                                                        : '${formatCurrency.format(memberOfficeExpensesTotal)} (Q$memberOfficeExpensesQuarter)',
                                                    style: TextStyle(
                                                        color: (userIsPremium || userIsLegacy) &&
                                                                memberOfficeExpenses.isNotEmpty
                                                            ? darkThemeTextColor
                                                            : null)),
                                                onPressed: () async =>
                                                    !userIsPremium && !userIsLegacy
                                                        ? Functions.requestInAppPurchase(
                                                            context, null, userIsPremium,
                                                            whatToShow: 'upgrades')
                                                        : memberOfficeExpenses.isEmpty
                                                            ? null
                                                            : setState(() {
                                                                showOfficeExpenses =
                                                                    !showOfficeExpenses;
                                                                showPrivateTravel = false;
                                                                showTradeActivity = false;
                                                              }),
                                                style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all(
                                                        (!userIsPremium && !userIsLegacy) ||
                                                                memberOfficeExpenses.isEmpty
                                                            ? Theme.of(context).disabledColor
                                                            : Theme.of(context).primaryColorDark)),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 25,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                        child: ElevatedButton.icon(
                                          icon: FaIcon(FontAwesomeIcons.chartLine,
                                              size: 12,
                                              color: userIsPremium ? darkThemeTextColor : null),
                                          label: Text('Recent Market Trade Activity (Reported)',
                                              style: TextStyle(
                                                  color:
                                                      userIsPremium ? darkThemeTextColor : null)),
                                          onPressed: () async => !userIsPremium
                                              ? Functions.requestInAppPurchase(
                                                  context, null, userIsPremium,
                                                  whatToShow: 'upgrades')
                                              : thisHouseMemberStockTrades.isEmpty &&
                                                      thisSenateMemberStockTrades.isEmpty
                                                  ? null
                                                  : setState(() {
                                                      showPrivateTravel = false;
                                                      showOfficeExpenses = false;
                                                      showTradeActivity = !showTradeActivity;
                                                    }),
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(
                                                  !userIsPremium ||
                                                          (thisHouseMemberStockTrades.isEmpty &&
                                                              thisSenateMemberStockTrades.isEmpty)
                                                      ? Theme.of(context).disabledColor
                                                      : Theme.of(context).primaryColorDark)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            !showPrivateTravel
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.fromLTRB(2.5, 0, 2.5, 2.5),
                                    child: Container(
                                      height: dataWindowHeight,
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).primaryColorDark.withOpacity(0.15),
                                          border: Border.all(
                                              width: 2, color: Theme.of(context).primaryColorDark),
                                          borderRadius: BorderRadius.circular(5)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Scrollbar(
                                        // trackVisibility: true,
                                        // thumbVisibility: true,
                                        thickness: 5,
                                        radius: const Radius.circular(5),
                                        child: SingleChildScrollView(
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                      child: Text('Privately Funded Travel',
                                                          style: Styles.googleStyle.copyWith(
                                                              fontSize: 24.0,
                                                              fontWeight: FontWeight.normal)),
                                                    )
                                                  ] +
                                                  [
                                                    const Divider(),
                                                  ] +
                                                  memberPrivateTravel
                                                      .map(
                                                        (thisTrip) => Stack(
                                                          alignment: Alignment.topRight,
                                                          children: [
                                                            ListTile(
                                                              dense: true,
                                                              title: Text(
                                                                thisTrip.traveler.toUpperCase(),
                                                                style: const TextStyle(
                                                                    fontSize: 14.0,
                                                                    fontWeight: FontWeight.bold),
                                                              ),
                                                              subtitle: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    'Destination: ${thisTrip.destination}\nSponsor: ${thisTrip.sponsor}\nDeparture Date: ${dateWithDayAndYearFormatter.format(thisTrip.departureDate)}\nReturn Date: ${dateWithDayAndYearFormatter.format(thisTrip.returnDate)}',
                                                                    style: const TextStyle(
                                                                        fontSize: 14.0,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            IconButton(
                                                                icon: const FaIcon(
                                                                  FontAwesomeIcons.solidFileLines,
                                                                  size: 13,
                                                                ),
                                                                onPressed: () => Functions.linkLaunch(
                                                                    context,
                                                                    thisTrip.pdfUrl,
                                                                    userDatabase,
                                                                    userIsPremium,
                                                                    appBarTitle:
                                                                        'Privately Funded Travel',
                                                                    source: 'travel',
                                                                    isPdf: true))
                                                          ],
                                                        ),
                                                      )
                                                      .toList()),
                                        ),
                                      ),
                                    ),
                                  ),
                            !showOfficeExpenses
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.fromLTRB(2.5, 0, 2.5, 2.5),
                                    child: Container(
                                      height: dataWindowHeight,
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).primaryColorDark.withOpacity(0.15),
                                          border: Border.all(
                                              width: 2, color: Theme.of(context).primaryColorDark),
                                          borderRadius: BorderRadius.circular(5)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Scrollbar(
                                        // trackVisibility: true,
                                        // thumbVisibility: true,
                                        thickness: 5,
                                        radius: const Radius.circular(5),
                                        child: SingleChildScrollView(
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                              'Total Office Expenses ${formatCurrency.format(memberOfficeExpensesTotal)}',
                                                              style: Styles.googleStyle.copyWith(
                                                                  fontSize: 24.0,
                                                                  fontWeight: FontWeight.normal)),
                                                          Text(
                                                              'Q$memberOfficeExpensesQuarter $memberOfficeExpensesYear',
                                                              style: Styles.regularStyle.copyWith(
                                                                  fontSize: 14.0,
                                                                  fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                    )
                                                  ] +
                                                  [const Divider()] +
                                                  memberOfficeExpenses
                                                      .map(
                                                        (thisExpense) => Stack(
                                                          alignment: Alignment.bottomRight,
                                                          children: [
                                                            ListTile(
                                                              dense: true,
                                                              title: Text(
                                                                thisExpense.category,
                                                                style: const TextStyle(
                                                                    fontSize: 14.0,
                                                                    fontWeight: FontWeight.bold),
                                                              ),
                                                              subtitle: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    'Amount: ${formatCurrency.format(thisExpense.amount)}\nYTD: ${formatCurrency.format(thisExpense.yearToDate)}\nChange From Prev Qtr: ${formatCurrency.format(thisExpense.changeFromPreviousQuarter)}',
                                                                    style: const TextStyle(
                                                                        fontSize: 14.0,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                  ),
                                                                ],
                                                              ),
                                                              // trailing: FaIcon(
                                                              //     FontAwesomeIcons
                                                              //         .solidFileLines,
                                                              //     size: 13),
                                                              // onTap: () => Functions
                                                              //     .linkLaunch(
                                                              //         context,
                                                              //         _thisTrip
                                                              //             .pdfUrl,
                                                              //         '${_thisTrip.filingType.name} FILING',
                                                              //         source:
                                                              //             'travel',
                                                              //         isPdf: true),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                      .toList()),
                                        ),
                                      ),
                                    ),
                                  ),
                            !showTradeActivity
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.fromLTRB(2.5, 0, 2.5, 2.5),
                                    child: Container(
                                      height: dataWindowHeight,
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).primaryColorDark.withOpacity(0.15),
                                          border: Border.all(
                                              width: 2, color: Theme.of(context).primaryColorDark),
                                          borderRadius: BorderRadius.circular(5)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Scrollbar(
                                        // trackVisibility: true,
                                        // thumbVisibility: true,
                                        thickness: 5,
                                        radius: const Radius.circular(5),
                                        child: SingleChildScrollView(
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                  child: Text(
                                                      'Recently Reported Market Trade Activity',
                                                      style: Styles.googleStyle.copyWith(
                                                          fontSize: 24.0,
                                                          fontWeight: FontWeight.normal)),
                                                ),
                                                const Divider(),
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                  child: Column(
                                                    children: isHouseMember
                                                        ? thisHouseMemberStockTrades
                                                            .map((e) => !isHouseMember
                                                                ? const SizedBox.shrink()
                                                                : Stack(
                                                                    alignment:
                                                                        Alignment.bottomRight,
                                                                    children: [
                                                                      ListTile(
                                                                        dense: true,
                                                                        contentPadding:
                                                                            const EdgeInsets.all(0),
                                                                        title: Container(
                                                                          padding:
                                                                              const EdgeInsets.all(
                                                                                  3),
                                                                          decoration: BoxDecoration(
                                                                              color: Theme.of(
                                                                                      context)
                                                                                  .primaryColorDark
                                                                                  .withOpacity(
                                                                                      0.25),
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(3)),
                                                                          child: Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment
                                                                                    .spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                '\$${e.ticker == '--' ? 'N/A' : e.ticker}',
                                                                                style: Styles
                                                                                    .regularStyle
                                                                                    .copyWith(
                                                                                        fontSize:
                                                                                            14,
                                                                                        fontWeight:
                                                                                            FontWeight
                                                                                                .bold),
                                                                              ),
                                                                              // Spacer(),
                                                                              Text(
                                                                                  'E: ${dateWithDayAndYearFormatter.format(e.transactionDate)}',
                                                                                  style: Styles
                                                                                      .regularStyle
                                                                                      .copyWith(
                                                                                          fontSize:
                                                                                              12,
                                                                                          fontWeight:
                                                                                              FontWeight
                                                                                                  .normal)),
                                                                              Text(
                                                                                  'D: ${dateWithDayAndYearFormatter.format(e.disclosureDate)}',
                                                                                  style: Styles
                                                                                      .regularStyle
                                                                                      .copyWith(
                                                                                          fontSize:
                                                                                              12,
                                                                                          fontWeight:
                                                                                              FontWeight
                                                                                                  .normal)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        subtitle: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment
                                                                                  .start,
                                                                          children: [
                                                                            Text(
                                                                                '${e.assetDescription.replaceAll(RegExp(r'<(.*)>'), '')}\nTrade Type: ${e.type.replaceFirst('_', ' ').toUpperCase()}\nOwner: ${e.owner == null || e.owner == '--' ? 'Not Provided' : e.owner.toUpperCase()}',
                                                                                style: Styles
                                                                                    .regularStyle
                                                                                    .copyWith(
                                                                                        fontSize:
                                                                                            14,
                                                                                        fontWeight:
                                                                                            FontWeight
                                                                                                .normal)),
                                                                            !e.capGainsOver200Usd
                                                                                ? const SizedBox
                                                                                    .shrink()
                                                                                : Text(
                                                                                    'Capital gains reported',
                                                                                    style: Styles
                                                                                        .regularStyle
                                                                                        .copyWith(
                                                                                            fontSize:
                                                                                                14,
                                                                                            fontWeight:
                                                                                                FontWeight.normal)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                          icon: const FaIcon(
                                                                            FontAwesomeIcons
                                                                                .solidFileLines,
                                                                            size: 13,
                                                                          ),
                                                                          onPressed: () =>
                                                                              Functions.linkLaunch(
                                                                                  context,
                                                                                  e.ptrLink,
                                                                                  userDatabase,
                                                                                  userIsPremium,
                                                                                  appBarTitle: e
                                                                                      .representative,
                                                                                  source:
                                                                                      'stock_trade',
                                                                                  isPdf: true))
                                                                    ],
                                                                  ))
                                                            .toList()
                                                        : thisSenateMemberStockTrades
                                                            .map((e) => isHouseMember
                                                                ? const SizedBox.shrink()
                                                                : ListTile(
                                                                    dense: true,
                                                                    contentPadding:
                                                                        const EdgeInsets.all(0),
                                                                    title: Container(
                                                                      padding:
                                                                          const EdgeInsets.all(3),
                                                                      decoration: BoxDecoration(
                                                                          color: Theme.of(context)
                                                                              .primaryColorDark
                                                                              .withOpacity(0.25),
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  3)),
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            e.ticker == '--'
                                                                                ? 'N/A'
                                                                                : e.ticker,
                                                                            style: Styles
                                                                                .regularStyle
                                                                                .copyWith(
                                                                                    fontSize: 14,
                                                                                    fontWeight:
                                                                                        FontWeight
                                                                                            .bold),
                                                                          ),
                                                                          // Spacer(),
                                                                          Text(
                                                                              'E: ${dateWithDayAndYearFormatter.format(e.transactionDate)}',
                                                                              style: Styles
                                                                                  .regularStyle
                                                                                  .copyWith(
                                                                                      fontSize: 12,
                                                                                      fontWeight:
                                                                                          FontWeight
                                                                                              .normal)),
                                                                          Text(
                                                                              'D: ${dateWithDayAndYearFormatter.format(e.disclosureDate)}',
                                                                              style: Styles
                                                                                  .regularStyle
                                                                                  .copyWith(
                                                                                      fontSize: 12,
                                                                                      fontWeight:
                                                                                          FontWeight
                                                                                              .normal)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    subtitle: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                            '${e.assetDescription.replaceAll(RegExp(r'<(.*)>'), '')}\nAsset Type: ${e.assetType}\nTrade Type: ${e.type.toUpperCase()}\nOwner: ${e.owner == null || e.owner == '--' ? 'Not Provided' : e.owner.toUpperCase()}\nAmount: ${e.amount}\nComments: ${e.comment == null || e.comment == '--' ? 'None' : e.comment}',
                                                                            style: Styles
                                                                                .regularStyle
                                                                                .copyWith(
                                                                                    fontSize: 14,
                                                                                    fontWeight:
                                                                                        FontWeight
                                                                                            .normal)),
                                                                        // Text(e.assetDescription.contains('scanned PDF') ? 'PDF Link: ${e.ptrLink}' : '', style: Styles.regularStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal))
                                                                      ],
                                                                    ),
                                                                    trailing: !e.assetDescription
                                                                            .toLowerCase()
                                                                            .contains('scanned PDF')
                                                                        ? const SizedBox.shrink()
                                                                        : const FaIcon(
                                                                            FontAwesomeIcons
                                                                                .solidFileLines,
                                                                            size: 13),
                                                                    onTap: () =>
                                                                        Functions.linkLaunch(
                                                                            context,
                                                                            e.ptrLink,
                                                                            userDatabase,
                                                                            userIsPremium,
                                                                            appBarTitle:
                                                                                'Senate Trade',
                                                                            source: 'stock_trade',
                                                                            isPdf: false),
                                                                  ))
                                                            .toList(),
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ),
                                    ),
                                  ),
                            Container(
                              margin: const EdgeInsets.only(top: 10, left: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Latest Vote: ',
                                    style: TextStyle(
                                        // color: Colors.blue[900],
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    child: thisMember.mostRecentVote == null ||
                                            thisMember.mostRecentVote == ''
                                        ? const Text('No Vote Information')
                                        : Text(
                                            formatter
                                                .format(DateTime.parse(thisMember.mostRecentVote)),
                                            style: const TextStyle(
                                                // color: Colors.blue[900],
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.normal),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10, left: 10.0),
                                    child: const Text(
                                      'Votes: ',
                                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: thisMember.roles.first.votesWithPartyPct == null
                                      ? Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: const Text('Total: No Information'))
                                      : Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: Text(
                                            'Total: ${thisMember.roles.first.totalVotes.toString()}',
                                            style: const TextStyle(
                                                fontSize: 14.0, fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: thisMember.roles.first.votesWithPartyPct == null
                                      ? Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: const Text('Missed: No Information'))
                                      : Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: Text(
                                            'Missed: ${thisMember.roles.first.missedVotes.toString()} (${thisMember.roles.first.missedVotesPct}%)',
                                            style: const TextStyle(
                                                fontSize: 14.0, fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: thisMember.roles.first.votesWithPartyPct == null
                                      ? Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: const Text('Present: No Information'))
                                      : Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: Text(
                                            'Present: ${thisMember.roles.first.totalPresent.toString()} (${thisMember.roles.first.totalPresent}%)',
                                            style: const TextStyle(
                                                fontSize: 14.0, fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: thisMember.roles.first.votesWithPartyPct == null
                                      ? Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: const Text('With Party: No Information'))
                                      : Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: Text(
                                            'With Party: ${thisMember.roles.first.votesWithPartyPct}%',
                                            style: const TextStyle(
                                                fontSize: 14.0, fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: thisMember.roles.first.votesAgainstPartyPct == null
                                      ? Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: const Text('Against Party: No Information'))
                                      : Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: Text(
                                            'Against Party: ${thisMember.roles.first.votesAgainstPartyPct}%',
                                            style: const TextStyle(
                                                fontSize: 14.0, fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10, left: 10.0),
                                    child: const Text(
                                      'Bills',
                                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: thisMember.roles.first.billsSponsored == null
                                      ? const Text('Sponsored: No Information')
                                      : Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: Text(
                                            'Sponsored: ${thisMember.roles.first.billsSponsored}',
                                            style: const TextStyle(
                                                fontSize: 14.0, fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: thisMember.roles.first.billsCosponsored == null
                                      ? const Text('Co-Sponsored: No Information')
                                      : Container(
                                          margin: const EdgeInsets.only(top: 1, left: 10.0),
                                          child: Text(
                                            'Co-Sponsored: ${thisMember.roles.first.billsCosponsored}',
                                            style: const TextStyle(
                                                fontSize: 14.0, fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10, left: 10.0),
                                    child: const Text(
                                      'Committees: ',
                                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 1, left: 10.0),
                              alignment: Alignment.topLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  thisMember.roles.first.committees.isEmpty
                                      ? const Text('- No Committees Listed')
                                      : ListView.builder(
                                          primary: false,
                                          shrinkWrap: true,
                                          itemCount: thisMember.roles.first.committees.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Text(
                                                '- ${thisMember.roles.first.committees[index].name}');
                                          },
                                        ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10, left: 10.0),
                                    child: const Text(
                                      'Sub-Committees: ',
                                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 1, left: 10.0),
                              alignment: Alignment.topLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  thisMember.roles.first.subcommittees.isEmpty
                                      ? const Text('- No Sub-Committees Listed')
                                      : ListView.builder(
                                          primary: false,
                                          shrinkWrap: true,
                                          itemCount: thisMember.roles.first.subcommittees.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Text(
                                              '- ${thisMember.roles.first.subcommittees[index].name}',
                                            );
                                          },
                                        ),
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10, left: 10.0),
                                    child: const Text(
                                      'Office Address',
                                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 1, left: 10.0),
                                    child: Text(
                                      thisMember.roles.first.office ?? 'Office: No Information',
                                      style: const TextStyle(
                                          fontSize: 14.0, fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
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
              !showBannerAd || userIsPremium ? const SizedBox.shrink() : bannerAdContainer,
              SharedWidgets.createdByContainer(context, userIsPremium, userDatabase),
            ],
          ),
        ),
      ),
    );
  }
}
