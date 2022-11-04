import 'dart:io';

// import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/constants/widgets.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/models/member_payload_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/house_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/market_activity_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/senate_stock_watch_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MarketActivityPage extends StatefulWidget {
  final List<ChamberMember> membersList;
  final List<HouseStockWatch> houseStockWatchList;
  final List<SenateStockWatch> senateStockWatchList;
  final List<MarketActivity> marketActivityOverviewList;
  const MarketActivityPage(this.membersList, this.houseStockWatchList,
      this.senateStockWatchList, this.marketActivityOverviewList,
      {Key key})
      : super(key: key);

  @override
  MarketActivityPageState createState() => MarketActivityPageState();
}

class MarketActivityPageState extends State<MarketActivityPage> {
  Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  bool _loading = false;
  bool darkTheme = false;
  List<String> subscriptionAlertsList = [];
  List<bool> userIs = [false, false, false];
  bool userIsDev = false;
  bool userIsPremium = false;
  bool userIsLegacy = false;
  bool appRated = false;
  bool devUpgraded = false;

  List<ChamberMember> allMembersList = [];
  List<HouseStockWatch> allHouseStockWatchList = [];
  List<SenateStockWatch> allSenateStockWatchList = [];
  List<MarketActivity> allMarketActivityOverviewList = [];

  List<ChamberMember> thisMembersList = [];
  List<HouseStockWatch> thisHouseStockWatchList = [];
  List<SenateStockWatch> thisSenateStockWatchList = [];
  List<MarketActivity> thisMarketActivityOverviewList = [];

  bool _dataLoading = false;
  int daysOfData = 90;
  int numTradesToRetain = 10;
  int numMembersRetain = 10;
  int maxMemberTrades = 0;
  int maxTickerTrades = 0;
  int maxRangeTrades = 0;
  int minTrades = 30;
  int maxDayTradeCount = 10;
  int dailyTradeNumDays = 90;
  double dailyTradeBarHeight = 75;
  List<TickerData> tickerData = [];
  List<String> allTrades = [];
  // List<MarketActivity> allTradesWithMembers = [];
  List<DollarData> dollarData = [];
  List<MemberTradeData> memberTradeData = [];
  List<CalendarData> calendarData = [];
  // List<ChamberMember> dollarRangeMembersList = [];
  // List<ChamberMember> tickerMembersList = [];

  ScrollController tradeCalendarScrollController =
      ScrollController(initialScrollOffset: 800);

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
    await setInitialValues();
    await processChartData(daysOfData);
    await buildCalendarData(allMarketActivityOverviewList, dailyTradeNumDays)
        .then((value) => calendarData = value);
    setState(() {
      _loading = false;
    });
    tradeCalendarScrollController.animateTo(0,
        duration: const Duration(seconds: 30), curve: Curves.linear);
  }

  Future<void> setInitialValues() async {
    await Functions.getUserLevels().then(((status) => setState(() {
          userIs = status;
          userIsDev = status[0];
          userIsPremium = status[1];
          userIsLegacy = status[2];
        })));

    await getCurrentOverviewData();

    setState(() {
      allMembersList = widget.membersList;
      allHouseStockWatchList = widget.houseStockWatchList;
      allSenateStockWatchList = widget.senateStockWatchList;
      allMarketActivityOverviewList = widget.marketActivityOverviewList;
    });
  }

  Future<void> getCurrentOverviewData() async {
    // bool _newMarketOverview = userDatabase.get('newMarketOverview');
    // Map<String, dynamic> _currentAllMarketOverview = {};

    /// HOUSE STOCK ACTIVITY LIST
    if (allHouseStockWatchList.isEmpty) {
      try {
        setState(() {
          allHouseStockWatchList =
              houseStockWatchFromJson(userDatabase.get('houseStockWatchList'));
          logger.i(
              '^^^^^ HOUSE STOCK TRADE INITIAL VARIABLES SETUP SUCCESS ^^^^^');
        });
      } catch (e) {
        logger.w(
            '^^^^^ ERROR DURING HOUSE STOCK TRADE INITIAL VARIABLES SETUP: $e ^^^^^');
        // userDatabase.put('houseStockWatchList', []);
      }
    }

    /// SENATE STOCK ACTIVITY LIST
    if (allSenateStockWatchList.isEmpty) {
      try {
        setState(() {
          allSenateStockWatchList = senateStockWatchFromJson(
              userDatabase.get('senateStockWatchList'));
          logger.i(
              '^^^^^ SENATE STOCK TRADE INITIAL VARIABLES SETUP SUCCESS ^^^^^');
        });
      } catch (e) {
        logger.w(
            '^^^^^ ERROR DURING SENATE STOCK TRADE INITIAL VARIABLES SETUP: $e ^^^^^');
        // userDatabase.put('senateStockWatchList', []);
      }
    }

    /// MARKET ACTIVITY OVERVIEW LIST
    if (allMarketActivityOverviewList.isEmpty) {
      try {
        setState(() {
          allMarketActivityOverviewList = marketActivityFromJson(
              userDatabase.get('marketActivityOverview'));
        });
      } catch (e) {
        logger.w(
            '^^^^^ ERROR RETRIEVING MARKET ACTIVITY OVERVIEW DATA TO DBASE (MARKET_ACTIVITY_PAGE): $e ^^^^^');
        userDatabase.put('marketActivityOverview', {});
      }
    }
  }

  Future<void> processChartData(int numDays) async {
    setState(() {
      _dataLoading = true;
      maxMemberTrades = minTrades;
      maxTickerTrades = minTrades;
      maxRangeTrades = minTrades;
    });
    List<HouseStockWatch> localHouseList = [];
    List<SenateStockWatch> localSenateList = [];
    List<TickerData> localTickerData = [];
    List<String> localAllTrades = [];
    // List<String> _houseTickers = [];
    // List<String> _senateTickers = [];
    List<DollarData> localDollarData = [];
    List<MemberTradeData> localMemberTradeData = [];
    List<MarketActivity> localMarketActivityOverviewList = [];
    // List<CalendarData> _calendarData = [];
    int localMaxTickerTrades = 0;
    int localMaxMemberTrades = 0;
    int localMaxRangeTrades = 0;

    localHouseList = allHouseStockWatchList
        .where((element) => element.transactionDate
            .isAfter(DateTime.now().subtract(Duration(days: numDays))))
        .toList();

    localSenateList = allSenateStockWatchList
        .where((element) => element.transactionDate
            .isAfter(DateTime.now().subtract(Duration(days: numDays))))
        .toList();

    localMarketActivityOverviewList = allMarketActivityOverviewList
        .where((element) => element.tradeExecutionDate
            .isAfter(DateTime.now().subtract(Duration(days: numDays))))
        .toList();

    for (var trade in localMarketActivityOverviewList) {
      String thisTradeTickerName = trade.tickerName;
      String thisTradeTickerDescription = trade.tickerDescription;
      // String thisTradeTradeType = trade.tradeType;
      String thisTradeDollarAmount = trade.dollarAmount;
      String thisTradeMemberName = trade.memberFullName;
      // String _thisTradeShortTitle = trade.memberTitle;
      // String _thisTradeFirstName = trade.memberFirstName;
      // DateTime thisTradeExecutionDate = trade.tradeExecutionDate;
      // DateTime thisTradeDisclosureDate = trade.tradeDisclosureDate;
      // String thisTradeChamber = trade.memberChamber;
      // String thisTradeOwner = trade.tradeOwner;
      String thisTradeMemberId = trade.memberId;

      ChamberMember localThisMember;

      try {
        localThisMember = allMembersList.firstWhere(
            (m) => m.id.toLowerCase() == thisTradeMemberId.toLowerCase());
      } catch (e) {
        localThisMember = null;
      }

      /// BUILD TICKER BUY/SALE DATA
      int localPurchaseCount = localMarketActivityOverviewList
          .where((element) =>
              element.tickerName.toLowerCase() ==
                  thisTradeTickerName.toLowerCase() &&
              element.tradeType.toLowerCase().contains('purchase'))
          .length;
      int localSaleCount = localMarketActivityOverviewList
          .where((element) =>
              element.tickerName.toLowerCase() ==
                  thisTradeTickerName.toLowerCase() &&
              element.tradeType.toLowerCase().contains('sale'))
          .length;

      if (localPurchaseCount + localSaleCount > localMaxTickerTrades) {
        localMaxTickerTrades = localPurchaseCount + localSaleCount;
      }

      if (localThisMember != null &&
          !localTickerData
              .any((element) => element.tickerName == thisTradeTickerName)) {
        localTickerData.add(TickerData(
          thisTradeTickerName,
          thisTradeTickerDescription,
          localPurchaseCount,
          localSaleCount,
          localPurchaseCount + localSaleCount,
        ));
      }

      /// BUILD DOLLAR RANGE DATA
      int localRangeBuyCount = localMarketActivityOverviewList
          .where((element) =>
              element.dollarAmount.toLowerCase() ==
                  thisTradeDollarAmount.toLowerCase() &&
              element.tradeType.toLowerCase().contains('purchase'))
          .length;

      int localRangeSellCount = localMarketActivityOverviewList
          .where((element) =>
              element.dollarAmount.toLowerCase() ==
                  thisTradeDollarAmount.toLowerCase() &&
              element.tradeType.toLowerCase().contains('sale'))
          .length;

      if (localRangeBuyCount + localRangeSellCount > localMaxRangeTrades) {
        localMaxRangeTrades = localRangeBuyCount + localRangeSellCount;
        debugPrint(
            '^^^^^ MAX RANGE TRADES FOR THIS PERIOD: $localMaxRangeTrades');
      }

      if (localThisMember != null &&
          !localDollarData
              .any((element) => element.dollarRange == thisTradeDollarAmount)) {
        localDollarData.add(DollarData(
          thisTradeDollarAmount,
          localRangeBuyCount,
          localRangeSellCount,
        ));
      }

      /// BUILD MEMBER TRADES DATA
      int localThisMemberBuyCount = localMarketActivityOverviewList
          .where((element) =>
              element.memberFullName.toLowerCase() ==
                  thisTradeMemberName.toLowerCase() &&
              element.tradeType.toLowerCase().contains('purchase'))
          .length;

      int localThisMemberSellCount = localMarketActivityOverviewList
          .where((element) =>
              element.memberFullName.toLowerCase() ==
                  thisTradeMemberName.toLowerCase() &&
              element.tradeType.toLowerCase().contains('sale'))
          .length;

      List<String> localThisMemberTickers = [];

      localMarketActivityOverviewList
          .where((item) =>
              item.memberFullName.toLowerCase() ==
              thisTradeMemberName.toLowerCase())
          .forEach((ticker) {
        String localThisTicker = ticker.tickerName.toUpperCase();
        if (!localThisMemberTickers.contains(localThisTicker.toUpperCase())) {
          localThisMemberTickers.add(localThisTicker.toUpperCase());
        }
      });

      if (localThisMemberBuyCount + localThisMemberSellCount >
          localMaxMemberTrades) {
        localMaxMemberTrades =
            localThisMemberBuyCount + localThisMemberSellCount;
      }

      if (localThisMember != null &&
          !localMemberTradeData
              .any((element) => element.memberName == thisTradeMemberName)) {
        localMemberTradeData.add(MemberTradeData(
            thisTradeMemberName,
            localThisMemberBuyCount,
            localThisMemberSellCount,
            localThisMemberBuyCount + localThisMemberSellCount,
            localThisMemberTickers.length,
            localThisMember));
      }
    }

    /// TALLY ALL MEMBER DATA
    localMemberTradeData.sort(
        (a, b) => b.memberTotalTradeCount.compareTo(a.memberTotalTradeCount));

    if (localMemberTradeData.length > numMembersRetain) {
      localMemberTradeData.removeRange(
          numMembersRetain, localMemberTradeData.length);
    }

    /// TALLY ALL TICKER DATA
    localTickerData.sort((a, b) => b.totalCount.compareTo(a.totalCount));
    if (localTickerData.length > numMembersRetain) {
      localTickerData.removeRange(numMembersRetain, localTickerData.length);
    }

    /// TALLY ALL DOLLAR RANGE DATA
    localDollarData
        .retainWhere((element) => element.dollarRange.contains('\$'));
    localDollarData.sort((a, b) => int.parse(a.dollarRange
            .split('-')[0]
            .trim()
            .replaceFirst('\$', '')
            .replaceAll(',', ''))
        .compareTo(int.parse(b.dollarRange
            .split('-')[0]
            .trim()
            .replaceFirst('\$', '')
            .replaceAll(',', ''))));

    setState(() {
      tickerData = localTickerData;
      allTrades = localAllTrades;
      thisMarketActivityOverviewList = localMarketActivityOverviewList;
      dollarData = localDollarData;
      memberTradeData = localMemberTradeData;
      thisHouseStockWatchList = localHouseList;
      thisSenateStockWatchList = localSenateList;
      maxMemberTrades =
          localMaxMemberTrades > minTrades ? localMaxMemberTrades : minTrades;
      maxTickerTrades =
          localMaxTickerTrades > minTrades ? localMaxMemberTrades : minTrades;
      maxRangeTrades =
          localMaxRangeTrades > minTrades ? localMaxRangeTrades : minTrades;
      _dataLoading = false;
    });
  }

  Future<List<CalendarData>> buildCalendarData(
      List<MarketActivity> allTrades, int daysOfData) async {
    List<CalendarData> localCalendarData = [];
    DateTime localEndOfRange = DateTime.now().subtract(const Duration(days: 1));
    DateTime localStartOfRange =
        localEndOfRange.subtract(Duration(days: daysOfData));
    int localMaxDayTradeCount = maxDayTradeCount;

    for (var i = localEndOfRange;
        i.isAfter(localStartOfRange);
        i = i.subtract(const Duration(days: 1))) {
      // logger.i('THIS DATE: ${dateWithDayFormatter.format(i)}');
      List<MarketActivity> localThisTradeDateList = allTrades
          .where((element) =>
              i.month == element.tradeExecutionDate.month &&
              i.day == element.tradeExecutionDate.day &&
              i.year == element.tradeExecutionDate.year)
          .toList();

      if (localThisTradeDateList.length > maxDayTradeCount) {
        localMaxDayTradeCount = localThisTradeDateList.length;
      }

      DateTime localDate = i;

      List<String> localTickers = localThisTradeDateList
          .map((e) => e.tickerName.toUpperCase())
          .toList();

      List<String> localMemberIds =
          localThisTradeDateList.map((e) => e.memberId).toList();

      localCalendarData.add(CalendarData(
        localDate,
        localTickers,
        localMemberIds,
        localThisTradeDateList,
      ));

      localCalendarData.removeWhere((element) =>
          dateWithDayFormatter.format(element.date).contains('Sat') ||
          dateWithDayFormatter.format(element.date).contains('Sun'));
    }

    setState(() => maxDayTradeCount = localMaxDayTradeCount);

    return localCalendarData;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable:
            Hive.box(appDatabase).listenable(keys: userDatabase.keys.toList()),
        builder: (context, box, widget) {
          return OrientationBuilder(builder: (context, orientation) {
            userIsPremium = userDatabase.get('userIsPremium');
            userIsLegacy = !userDatabase.get('userIsPremium') &&
                    List.from(userDatabase.get('userIdList')).any((element) =>
                        element.toString().startsWith(oldUserIdPrefix))
                ? true
                : false;
            appRated = userDatabase.get('appRated');
            devUpgraded = userDatabase.get('devUpgraded');
            darkTheme = userDatabase.get('darkTheme');
            subscriptionAlertsList =
                List<String>.from(userDatabase.get('subscriptionAlertsList'));

            return SafeArea(
                child: Scaffold(
              appBar: AppBar(
                title: const Text('Stock Activity Overview'),
                backgroundColor: darkTheme
                    ? Theme.of(context).primaryColorDark
                    : stockWatchColor,
              ),
              body: _loading
                  ? AnimatedWidgets.circularProgressWatchtower(
                      context, userDatabase, userIsPremium,
                      isMarket: true, isFullScreen: true)
                  : Padding(
                      padding: const EdgeInsets.all(0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            image: DecorationImage(
                                opacity: 0.15,
                                image: AssetImage(
                                    'assets/stock${random.nextInt(3)}.png'),
                                // fit: BoxFit.fitWidth,
                                repeat: ImageRepeat.repeat,
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.background,
                                    BlendMode.color)),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: darkTheme
                                          ? Theme.of(context).primaryColorDark
                                          : stockWatchColor,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Daily Trade Activity Overview',
                                          style: Styles.googleStyle.copyWith(
                                              fontSize: 20,
                                              color: darkThemeTextColor)),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Scrollbar(
                                  child: ListView(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Wrap(
                                            alignment: WrapAlignment.center,
                                            children: [
                                              BounceInDown(
                                                child: Stack(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  children: [
                                                    Card(
                                                        child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            opacity: 0.15,
                                                            image: AssetImage(
                                                                'assets/stock${random.nextInt(3)}.png'),
                                                            fit: BoxFit.cover,
                                                            colorFilter: ColorFilter.mode(
                                                                darkTheme
                                                                    ? Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .background
                                                                    : Colors
                                                                        .white,
                                                                BlendMode
                                                                    .color)),
                                                        border: Border.all(
                                                            color: darkTheme
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColorDark
                                                                : stockWatchColor,
                                                            width: 2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Text(
                                                                  'Trade Executions ($dailyTradeNumDays Days)'
                                                                      .toUpperCase(),
                                                                  style: Styles
                                                                      .regularStyle
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.bold))),
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      5,
                                                                      0,
                                                                      5,
                                                                      5),
                                                              height: 80,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: ListView.builder(
                                                                        reverse: true,
                                                                        controller: tradeCalendarScrollController,
                                                                        scrollDirection: Axis.horizontal,
                                                                        physics: const BouncingScrollPhysics(),
                                                                        shrinkWrap: true,
                                                                        itemCount: calendarData.length,
                                                                        itemBuilder: (context, index) {
                                                                          CalendarData
                                                                              localThisDay =
                                                                              calendarData[index];
                                                                          String
                                                                              localThisDate =
                                                                              dateWithDayFormatter.format(calendarData[index].date);
                                                                          double
                                                                              localThisBarHeightPercent =
                                                                              (localThisDay.trades.length / dailyTradeBarHeight);

                                                                          return BounceInDown(
                                                                            duration:
                                                                                Duration(milliseconds: index * 10),
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                // debugPrint('${_thisDay.trades.map((e) => e)}');
                                                                                if (localThisDay.trades.isNotEmpty) {
                                                                                  showModalBottomSheet(
                                                                                      backgroundColor: Colors.transparent,
                                                                                      context: context,
                                                                                      enableDrag: true,
                                                                                      builder: (context) {
                                                                                        return SharedWidgets.marketDailyTradesCalendar(context, localThisDay, allMembersList, userDatabase, userIsPremium, allHouseStockWatchList, allSenateStockWatchList);
                                                                                      });
                                                                                }
                                                                              },
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                                                                child: Stack(
                                                                                  alignment: Alignment.topCenter,
                                                                                  children: [
                                                                                    Container(
                                                                                        padding: const EdgeInsets.only(top: 3),
                                                                                        alignment: Alignment.topCenter,
                                                                                        height: dailyTradeBarHeight,
                                                                                        width: 18,
                                                                                        foregroundDecoration: BoxDecoration(
                                                                                          gradient: LinearGradient(
                                                                                            begin: Alignment.bottomCenter,
                                                                                            end: Alignment.topCenter,
                                                                                            colors: List.generate((localThisBarHeightPercent * 100).toInt() * 10, (_) => darkTheme ? Colors.purple : stockWatchColor) +
                                                                                                List.generate(
                                                                                                  (dailyTradeBarHeight - (dailyTradeBarHeight * localThisBarHeightPercent)).toInt() * 10,
                                                                                                  (_) => localThisDate.contains('Mon')
                                                                                                      ? darkTheme
                                                                                                          ? Theme.of(context).primaryColorDark.withOpacity(0.4)
                                                                                                          : stockWatchColor.withOpacity(0.15)
                                                                                                      : Colors.transparent,
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          children: [
                                                                                            AnimatedWidgets.flashingEye(context, localThisDay.memberIds.any((id) => subscriptionAlertsList.toString().toLowerCase().contains(id.toLowerCase())), false, size: 6, sameColorBright: false),
                                                                                            RotatedBox(
                                                                                                quarterTurns: 3,
                                                                                                child: Text(
                                                                                                  localThisDate.toUpperCase(),
                                                                                                  textAlign: TextAlign.end,
                                                                                                  style: Styles.regularStyle.copyWith(
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                      color: Colors.grey.withOpacity(0.4), // darkThemeTextColor,
                                                                                                      fontSize: 11),
                                                                                                )),
                                                                                          ],
                                                                                        )),
                                                                                    Positioned(
                                                                                      bottom: (dailyTradeBarHeight * localThisBarHeightPercent).toDouble() - 4.75,
                                                                                      // left: 1,
                                                                                      child: CircleAvatar(radius: 9, backgroundColor: darkTheme ? Theme.of(context).primaryColorDark : stockWatchColor, child: Text(localThisDay.tickers.length.toString(), style: Styles.regularStyle.copyWith(color: darkThemeTextColor, fontSize: 8, fontWeight: FontWeight.bold))),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }),
                                                                  ),
                                                                ],
                                                              )),
                                                        ],
                                                      ),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: orientation ==
                                                        Orientation.landscape
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2.1
                                                    : MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                child: Card(
                                                  child: tickerData.isEmpty
                                                      ? const SizedBox.shrink()
                                                      : Column(
                                                          children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(0),
                                                                  child: Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              5),
                                                                      child: Text(
                                                                          _dataLoading
                                                                              ? 'Updating Traded Stocks...'
                                                                              : '$numTradesToRetain Most Traded Stocks ($daysOfData Days)'
                                                                                  .toUpperCase(),
                                                                          style: Styles.regularStyle.copyWith(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.bold))),
                                                                )
                                                              ] +
                                                              tickerData
                                                                  .map((localThisTicker) =>
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                5,
                                                                            vertical:
                                                                                1),
                                                                        child:
                                                                            BounceInRight(
                                                                          duration:
                                                                              const Duration(milliseconds: 500),
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              List<String> localMemberIds = [];

                                                                              thisMarketActivityOverviewList.where((element) => element.tickerName.toLowerCase() == localThisTicker.tickerName.toLowerCase() && element.memberId.toLowerCase() != 'noid').forEach((item) {
                                                                                localMemberIds.add(item.memberId.toLowerCase());
                                                                              });

                                                                              List<ChamberMember> localTickerMembersList = [];

                                                                              localMemberIds.toSet().forEach((memberId) {
                                                                                localTickerMembersList.add(allMembersList.firstWhere((element) => element.id.toLowerCase() == memberId.toLowerCase()));
                                                                              });

                                                                              debugPrint('${localThisTicker.tickerName} TICKER MEMBERS: ${localTickerMembersList.length}');

                                                                              if (localTickerMembersList.isNotEmpty) {
                                                                                showModalBottomSheet(
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    enableDrag: true,
                                                                                    builder: (context) {
                                                                                      return SharedWidgets.marketActivityTicker(context, localThisTicker.tickerName, localThisTicker.tickerDescription, localTickerMembersList.toSet().toList(), daysOfData, userDatabase, userIsPremium, userIsLegacy, allHouseStockWatchList, allSenateStockWatchList);
                                                                                    });
                                                                              }
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.symmetric(vertical: 3),
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(3),
                                                                                  gradient: LinearGradient(
                                                                                    begin: Alignment.centerLeft,
                                                                                    end: Alignment.centerRight,
                                                                                    colors: List.generate(localThisTicker.tickerPurchaseCount * 10, (_) => alertIndicatorColorDarkGreen) + List.generate(localThisTicker.tickerSaleCount * 10, (_) => altHighlightAccentColorDarkRed) + List.generate((maxTickerTrades - (localThisTicker.tickerPurchaseCount + localThisTicker.tickerSaleCount)) + (maxTickerTrades ~/ 15) * 10, (_) => darkTheme ? Theme.of(context).primaryColorDark.withOpacity(0.75) : stockWatchColor.withOpacity(0.75)),
                                                                                  )),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                child: Row(
                                                                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(
                                                                                      localThisTicker.tickerName,
                                                                                      style: Styles.regularStyle.copyWith(fontSize: 13, color: darkThemeTextColor),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    AnimatedWidgets.flashingEye(context, thisMarketActivityOverviewList.any((element) => element.tickerName.toLowerCase() == localThisTicker.tickerName.toLowerCase() && subscriptionAlertsList.any((item) => item.toLowerCase().contains(element.memberId.toLowerCase()))), false, size: 8, sameColorBright: true),
                                                                                    const SizedBox(width: 5),
                                                                                    Text(
                                                                                      '${thisMarketActivityOverviewList.where((element) => element.tickerName.toLowerCase() == localThisTicker.tickerName.toLowerCase() && element.memberId.toLowerCase() != 'noid').map((e) => e.memberId).toSet().length} 🧑🏽‍💼 | ${localThisTicker.tickerPurchaseCount} ▲ | ${localThisTicker.tickerSaleCount} ▼',
                                                                                      style: Styles.regularStyle.copyWith(fontSize: 11, color: darkThemeTextColor),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ))
                                                                  .toList() +
                                                              [
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                  child: SizedBox(
                                                                      height:
                                                                          5),
                                                                )
                                                              ],
                                                        ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: orientation ==
                                                        Orientation.landscape
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2.1
                                                    : MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                child: Card(
                                                  child: memberTradeData.isEmpty
                                                      ? const SizedBox.shrink()
                                                      : Column(
                                                          children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(0),
                                                                  child: Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              5),
                                                                      child: Text(
                                                                          _dataLoading
                                                                              ? 'Updating Most Active Members...'
                                                                              : '$numMembersRetain Most Active Members ($daysOfData Days)'
                                                                                  .toUpperCase(),
                                                                          style: Styles.regularStyle.copyWith(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.bold))),
                                                                )
                                                              ] +
                                                              memberTradeData
                                                                  // .take(
                                                                  //     memberTradesToRetain)
                                                                  .map((localThisMember) =>
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                5,
                                                                            vertical:
                                                                                1),
                                                                        child:
                                                                            BounceInRight(
                                                                          duration:
                                                                              const Duration(milliseconds: 750),
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              if (thisHouseStockWatchList.isNotEmpty && thisSenateStockWatchList.isNotEmpty) {
                                                                                List<HouseStockWatch> localThisRepresentativeList = [];
                                                                                List<SenateStockWatch> localThisSenatorList = [];
                                                                                String localThisChamber = localThisMember.member.shortTitle.toLowerCase().startsWith('r') || localThisMember.member.shortTitle.toLowerCase().startsWith('h') ? 'house' : 'senate';

                                                                                debugPrint('^^^^^ CHAMBER IS: $localThisChamber');

                                                                                if (localThisChamber == 'house') {
                                                                                  try {
                                                                                    localThisRepresentativeList = thisHouseStockWatchList.where((element) => element.representative.toLowerCase().split(' ')[1][0] == localThisMember.member.firstName.toLowerCase()[0] && element.representative.toLowerCase().contains(localThisMember.member.lastName.toLowerCase()) && element.ticker != null && element.ticker != '--' && element.ticker != 'N/A').toList();
                                                                                    debugPrint('^^^^^ HOUSE STOCK LIST: ${localThisRepresentativeList.length}');
                                                                                  } catch (e) {
                                                                                    debugPrint('^^^^^ HOUSE STOCK LIST ERROR $e');
                                                                                    localThisRepresentativeList = [];
                                                                                  }
                                                                                } else if (localThisChamber == 'senate') {
                                                                                  try {
                                                                                    localThisSenatorList = thisSenateStockWatchList.where((element) => element.senator.toLowerCase().split(' ')[0][0] == localThisMember.member.firstName.toLowerCase()[0] && element.senator.toLowerCase().contains(localThisMember.member.lastName.toLowerCase()) && element.ticker != null && element.ticker != '--' && element.ticker != 'N/A').toList();
                                                                                    debugPrint('^^^^^ SENATE STOCK LIST: ${localThisSenatorList.length}');
                                                                                  } catch (e) {
                                                                                    debugPrint('^^^^^ SENATE STOCK LIST ERROR $e');
                                                                                    localThisSenatorList = [];
                                                                                  }
                                                                                }

                                                                                showModalBottomSheet(
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    enableDrag: true,
                                                                                    builder: (context) {
                                                                                      return SharedWidgets.marketActivityMember(context, localThisChamber, localThisMember.member, daysOfData, userDatabase, userIsPremium, userIsLegacy, localThisRepresentativeList, localThisSenatorList);
                                                                                    });
                                                                              }
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.symmetric(vertical: 3),
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(3),
                                                                                  gradient: LinearGradient(
                                                                                    begin: Alignment.centerLeft,
                                                                                    end: Alignment.centerRight,
                                                                                    colors: List.generate(localThisMember.memberBuyCount * 10, (_) => alertIndicatorColorDarkGreen) + List.generate(localThisMember.memberSellCount * 10, (_) => altHighlightAccentColorDarkRed) + List.generate((maxMemberTrades - (localThisMember.memberBuyCount + localThisMember.memberSellCount)) + (maxMemberTrades ~/ 15) * 10, (_) => darkTheme ? Theme.of(context).primaryColorDark.withOpacity(0.75) : stockWatchColor.withOpacity(0.75)),
                                                                                  )),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(
                                                                                      localThisMember.memberName,
                                                                                      style: Styles.regularStyle.copyWith(fontSize: 13, color: darkThemeTextColor),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    AnimatedWidgets.flashingEye(context, localThisMember.member.id != null && localThisMember.member.id.toLowerCase() != 'noid' && subscriptionAlertsList.any((item) => item.toLowerCase().contains(localThisMember.member.id.toLowerCase())), false, size: 8, sameColorBright: true),
                                                                                    const SizedBox(width: 5),
                                                                                    Text(
                                                                                      '${localThisMember.memberTickerCount} STX | ${localThisMember.memberBuyCount} ▲ | ${localThisMember.memberSellCount} ▼',
                                                                                      style: Styles.regularStyle.copyWith(fontSize: 11, color: darkThemeTextColor),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ))
                                                                  .toList() +
                                                              [
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                  child: SizedBox(
                                                                      height:
                                                                          5),
                                                                )
                                                              ],
                                                        ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: orientation ==
                                                        Orientation.landscape
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2.1
                                                    : MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                child: Card(
                                                  child: dollarData.isEmpty
                                                      ? const SizedBox.shrink()
                                                      : Column(
                                                          children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(0),
                                                                  child: Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              5),
                                                                      child: Text(
                                                                          _dataLoading
                                                                              ? 'Updating Dollar Ranges...'
                                                                              : 'Dollar Ranges Traded in USD ($daysOfData Days)'
                                                                                  .toUpperCase(),
                                                                          style: Styles.regularStyle.copyWith(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.bold))),
                                                                )
                                                              ] +
                                                              dollarData
                                                                  .map((localThisDollarRange) =>
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                5,
                                                                            vertical:
                                                                                1),
                                                                        child:
                                                                            BounceInRight(
                                                                          duration:
                                                                              const Duration(milliseconds: 1000),
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              List<String> localMemberIds = [];

                                                                              thisMarketActivityOverviewList.where((element) => element.dollarAmount.toLowerCase() == localThisDollarRange.dollarRange.toLowerCase() && element.memberId.toLowerCase() != 'noid').forEach((item) {
                                                                                localMemberIds.add(item.memberId.toLowerCase());
                                                                              });

                                                                              List<ChamberMember> localDollarRangeMembersList = [];

                                                                              localMemberIds.toSet().forEach((memberId) {
                                                                                localDollarRangeMembersList.add(allMembersList.firstWhere((element) => element.id.toLowerCase() == memberId.toLowerCase()));
                                                                              });

                                                                              debugPrint('${localThisDollarRange.dollarRange} DOLLAR RANGE MEMBERS: ${localDollarRangeMembersList.length}');

                                                                              if (localDollarRangeMembersList.isNotEmpty) {
                                                                                showModalBottomSheet(
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    enableDrag: true,
                                                                                    builder: (context) {
                                                                                      return SharedWidgets.marketActivityDollarRange(context, localThisDollarRange.dollarRange, localDollarRangeMembersList.toSet().toList(), daysOfData, userDatabase, userIsPremium, userIsLegacy, allHouseStockWatchList, allSenateStockWatchList);
                                                                                    });
                                                                              }
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.symmetric(vertical: 3),
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(3),
                                                                                  gradient: LinearGradient(
                                                                                    begin: Alignment.centerLeft,
                                                                                    end: Alignment.centerRight,
                                                                                    colors: List.generate(localThisDollarRange.rangeBuyCount * 10, (_) => alertIndicatorColorDarkGreen) + List.generate(localThisDollarRange.rangeSellCount * 10, (_) => altHighlightAccentColorDarkRed) + List.generate((maxRangeTrades - (localThisDollarRange.rangeBuyCount + localThisDollarRange.rangeSellCount)) + (maxRangeTrades ~/ 15) * 10, (_) => darkTheme ? Theme.of(context).primaryColorDark.withOpacity(0.75) : stockWatchColor.withOpacity(0.75)),
                                                                                  )),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                child: Row(
                                                                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(
                                                                                      localThisDollarRange.dollarRange,
                                                                                      style: Styles.regularStyle.copyWith(fontSize: 13, color: darkThemeTextColor),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    AnimatedWidgets.flashingEye(context, thisMarketActivityOverviewList.any((element) => element.dollarAmount.toLowerCase() == localThisDollarRange.dollarRange.toLowerCase() && subscriptionAlertsList.any((item) => item.toLowerCase().contains(element.memberId.toLowerCase()))), false, size: 8, sameColorBright: true),
                                                                                    const SizedBox(width: 5),
                                                                                    Text(
                                                                                      '${thisMarketActivityOverviewList.where((element) => element.dollarAmount.toLowerCase() == localThisDollarRange.dollarRange.toLowerCase() && element.memberId.toLowerCase() != 'noid').map((e) => e.memberId).toSet().length} 🧑🏽‍💼 | ${localThisDollarRange.rangeBuyCount} ▲ | ${localThisDollarRange.rangeSellCount} ▼',
                                                                                      style: Styles.regularStyle.copyWith(fontSize: 11, color: darkThemeTextColor),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ))
                                                                  .toList() +
                                                              [
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0),
                                                                  child: SizedBox(
                                                                      height:
                                                                          5),
                                                                )
                                                              ],
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          _dataLoading
                                              ? AnimatedWidgets
                                                  .circularProgressWatchtower(
                                                      context,
                                                      userDatabase,
                                                      userIsPremium,
                                                      isMarket: true,
                                                      isFullScreen: true)
                                              : const SizedBox.shrink()
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
              // bottomSheet: ,
              bottomNavigationBar: Container(
                  color: darkTheme ? null : stockWatchColor.withOpacity(0.3),
                  padding: const EdgeInsets.all(5),
                  child: SizedBox(
                      height: 20,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Text(
                              'Days Reported',
                              style: Styles.regularStyle.copyWith(
                                  fontSize: 14,
                                  color: darkTheme ? null : stockWatchColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: OutlinedButton(
                            onPressed: () async {
                              setState(() => daysOfData = 30);
                              setState(() => _dataLoading = true);
                              await processChartData(30);
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(daysOfData != 30
                                        ? darkTheme
                                            ? Theme.of(context).primaryColor
                                            : null // Theme.of(context).disabledColor
                                        : darkTheme
                                            ? Theme.of(context).primaryColorDark
                                            : stockWatchColor)),
                            child: _dataLoading
                                ? AnimatedWidgets.circularProgressWatchtower(
                                    context, userDatabase, userIsPremium,
                                    isMarket: true,
                                    widthAndHeight: 10,
                                    strokeWidth: 2,
                                    isFullScreen: false)
                                : Text(
                                    '30',
                                    style: Styles.regularStyle.copyWith(
                                        fontSize: 14,
                                        color: daysOfData != 30
                                            ? Theme.of(context).disabledColor
                                            : darkThemeTextColor),
                                  ),
                          )),
                          const SizedBox(width: 5),
                          Expanded(
                              child: OutlinedButton(
                            onPressed: () async {
                              setState(() => daysOfData = 60);
                              setState(() => _dataLoading = true);
                              await processChartData(
                                  // _allHouseStockWatchList,
                                  // _allSenateStockWatchList,
                                  60);
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(daysOfData != 60
                                        ? darkTheme
                                            ? Theme.of(context).primaryColor
                                            : null // Theme.of(context).disabledColor
                                        : darkTheme
                                            ? Theme.of(context).primaryColorDark
                                            : stockWatchColor)),
                            child: _dataLoading
                                ? AnimatedWidgets.circularProgressWatchtower(
                                    context, userDatabase, userIsPremium,
                                    isMarket: true,
                                    widthAndHeight: 10,
                                    strokeWidth: 2,
                                    isFullScreen: false)
                                : Text(
                                    '60',
                                    style: Styles.regularStyle.copyWith(
                                        fontSize: 14,
                                        color: daysOfData != 60
                                            ? Theme.of(context).disabledColor
                                            : darkThemeTextColor),
                                  ),
                          )),
                          const SizedBox(width: 5),
                          Expanded(
                              child: OutlinedButton(
                            onPressed: () async {
                              setState(() => daysOfData = 90);
                              setState(() => _dataLoading = true);
                              await processChartData(90);
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(daysOfData != 90
                                        ? darkTheme
                                            ? Theme.of(context).primaryColor
                                            : null // Theme.of(context).disabledColor
                                        : darkTheme
                                            ? Theme.of(context).primaryColorDark
                                            : stockWatchColor)),
                            child: _dataLoading
                                ? AnimatedWidgets.circularProgressWatchtower(
                                    context, userDatabase, userIsPremium,
                                    isMarket: true,
                                    widthAndHeight: 10,
                                    strokeWidth: 2,
                                    isFullScreen: false)
                                : Text(
                                    '90',
                                    style: Styles.regularStyle.copyWith(
                                        fontSize: 14,
                                        color: daysOfData != 90
                                            ? Theme.of(context).disabledColor
                                            : darkThemeTextColor),
                                  ),
                          )),
                        ],
                      ))),
            ));
          });
        });
  }
}

class TickerData {
  TickerData(
    this.tickerName,
    this.tickerDescription,
    this.tickerPurchaseCount,
    this.tickerSaleCount,
    this.totalCount,
    /*this.memberCount&*/
  );
  final String tickerName;
  final String tickerDescription;
  final int tickerPurchaseCount;
  final int tickerSaleCount;
  final int totalCount;
  // final int memberCount;
}

class MemberTradeData {
  MemberTradeData(this.memberName, this.memberBuyCount, this.memberSellCount,
      this.memberTotalTradeCount, this.memberTickerCount, this.member);
  final String memberName;
  final int memberBuyCount;
  final int memberSellCount;
  final int memberTotalTradeCount;
  final int memberTickerCount;
  final ChamberMember member;
}

class DollarData {
  DollarData(
    this.dollarRange,
    this.rangeBuyCount,
    this.rangeSellCount,
  );
  final String dollarRange;
  final int rangeBuyCount;
  final int rangeSellCount;
}

class CalendarData {
  CalendarData(
    this.date,
    this.tickers,
    this.memberIds,
    this.trades,
  );
  final DateTime date;
  final List<String> tickers;
  final List<String> memberIds;
  final List<MarketActivity> trades;
}
