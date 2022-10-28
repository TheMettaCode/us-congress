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
      this.senateStockWatchList, this.marketActivityOverviewList, {Key key}) : super(key: key);

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
    List<HouseStockWatch> _houseList = [];
    List<SenateStockWatch> _senateList = [];
    List<TickerData> _tickerData = [];
    List<String> _allTrades = [];
    // List<String> _houseTickers = [];
    // List<String> _senateTickers = [];
    List<DollarData> _dollarData = [];
    List<MemberTradeData> _memberTradeData = [];
    List<MarketActivity> _marketActivityOverviewList = [];
    // List<CalendarData> _calendarData = [];
    int _maxTickerTrades = 0;
    int _maxMemberTrades = 0;
    int _maxRangeTrades = 0;

    _houseList = allHouseStockWatchList
        .where((element) => element.transactionDate
            .isAfter(DateTime.now().subtract(Duration(days: numDays))))
        .toList();

    _senateList = allSenateStockWatchList
        .where((element) => element.transactionDate
            .isAfter(DateTime.now().subtract(Duration(days: numDays))))
        .toList();

    _marketActivityOverviewList = allMarketActivityOverviewList
        .where((element) => element.tradeExecutionDate
            .isAfter(DateTime.now().subtract(Duration(days: numDays))))
        .toList();

    for (var trade in _marketActivityOverviewList) {
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

      ChamberMember _thisMember;

      try {
        _thisMember = allMembersList.firstWhere(
            (m) => m.id.toLowerCase() == thisTradeMemberId.toLowerCase());
      } catch (e) {
        _thisMember = null;
      }

      /// BUILD TICKER BUY/SALE DATA
      int _purchaseCount = _marketActivityOverviewList
          .where((element) =>
              element.tickerName.toLowerCase() ==
                  thisTradeTickerName.toLowerCase() &&
              element.tradeType.toLowerCase().contains('purchase'))
          .length;
      int _saleCount = _marketActivityOverviewList
          .where((element) =>
              element.tickerName.toLowerCase() ==
                  thisTradeTickerName.toLowerCase() &&
              element.tradeType.toLowerCase().contains('sale'))
          .length;

      if (_purchaseCount + _saleCount > _maxTickerTrades) {
        _maxTickerTrades = _purchaseCount + _saleCount;
      }

      if (_thisMember != null &&
          !_tickerData
              .any((element) => element.tickerName == thisTradeTickerName)) {
        _tickerData.add(TickerData(
          thisTradeTickerName,
          thisTradeTickerDescription,
          _purchaseCount,
          _saleCount,
          _purchaseCount + _saleCount,
        ));
      }

      /// BUILD DOLLAR RANGE DATA
      int _rangeBuyCount = _marketActivityOverviewList
          .where((element) =>
              element.dollarAmount.toLowerCase() ==
                  thisTradeDollarAmount.toLowerCase() &&
              element.tradeType.toLowerCase().contains('purchase'))
          .length;

      int _rangeSellCount = _marketActivityOverviewList
          .where((element) =>
              element.dollarAmount.toLowerCase() ==
                  thisTradeDollarAmount.toLowerCase() &&
              element.tradeType.toLowerCase().contains('sale'))
          .length;

      if (_rangeBuyCount + _rangeSellCount > _maxRangeTrades) {
        _maxRangeTrades = _rangeBuyCount + _rangeSellCount;
        debugPrint('^^^^^ MAX RANGE TRADES FOR THIS PERIOD: $_maxRangeTrades');
      }

      if (_thisMember != null &&
          !_dollarData
              .any((element) => element.dollarRange == thisTradeDollarAmount)) {
        _dollarData.add(DollarData(
          thisTradeDollarAmount,
          _rangeBuyCount,
          _rangeSellCount,
        ));
      }

      /// BUILD MEMBER TRADES DATA
      int _thisMemberBuyCount = _marketActivityOverviewList
          .where((element) =>
              element.memberFullName.toLowerCase() ==
                  thisTradeMemberName.toLowerCase() &&
              element.tradeType.toLowerCase().contains('purchase'))
          .length;

      int _thisMemberSellCount = _marketActivityOverviewList
          .where((element) =>
              element.memberFullName.toLowerCase() ==
                  thisTradeMemberName.toLowerCase() &&
              element.tradeType.toLowerCase().contains('sale'))
          .length;

      List<String> _thisMemberTickers = [];

      _marketActivityOverviewList
          .where((item) =>
              item.memberFullName.toLowerCase() ==
              thisTradeMemberName.toLowerCase())
          .forEach((ticker) {
        String _thisTicker = ticker.tickerName.toUpperCase();
        if (!_thisMemberTickers.contains(_thisTicker.toUpperCase())) {
          _thisMemberTickers.add(_thisTicker.toUpperCase());
        }
      });

      if (_thisMemberBuyCount + _thisMemberSellCount > _maxMemberTrades) {
        _maxMemberTrades = _thisMemberBuyCount + _thisMemberSellCount;
      }

      if (_thisMember != null &&
          !_memberTradeData
              .any((element) => element.memberName == thisTradeMemberName)) {
        _memberTradeData.add(MemberTradeData(
            thisTradeMemberName,
            _thisMemberBuyCount,
            _thisMemberSellCount,
            _thisMemberBuyCount + _thisMemberSellCount,
            _thisMemberTickers.length,
            _thisMember));
      }
    }

    /// TALLY ALL MEMBER DATA
    _memberTradeData.sort(
        (a, b) => b.memberTotalTradeCount.compareTo(a.memberTotalTradeCount));

    if (_memberTradeData.length > numMembersRetain) {
      _memberTradeData.removeRange(numMembersRetain, _memberTradeData.length);
    }

    /// TALLY ALL TICKER DATA
    _tickerData.sort((a, b) => b.totalCount.compareTo(a.totalCount));
    if (_tickerData.length > numMembersRetain) {
      _tickerData.removeRange(numMembersRetain, _tickerData.length);
    }

    /// TALLY ALL DOLLAR RANGE DATA
    _dollarData.retainWhere((element) => element.dollarRange.contains('\$'));
    _dollarData.sort((a, b) => int.parse(a.dollarRange
            .split(' - ')[0]
            .replaceFirst('\$', '')
            .replaceAll(',', ''))
        .compareTo(int.parse(b.dollarRange
            .split(' - ')[0]
            .replaceFirst('\$', '')
            .replaceAll(',', ''))));

    setState(() {
      tickerData = _tickerData;
      allTrades = _allTrades;
      thisMarketActivityOverviewList = _marketActivityOverviewList;
      dollarData = _dollarData;
      memberTradeData = _memberTradeData;
      thisHouseStockWatchList = _houseList;
      thisSenateStockWatchList = _senateList;
      maxMemberTrades =
          _maxMemberTrades > minTrades ? _maxMemberTrades : minTrades;
      maxTickerTrades =
          _maxTickerTrades > minTrades ? _maxMemberTrades : minTrades;
      maxRangeTrades =
          _maxRangeTrades > minTrades ? _maxRangeTrades : minTrades;
      _dataLoading = false;
    });
  }

  Future<List<CalendarData>> buildCalendarData(
      List<MarketActivity> allTrades, int daysOfData) async {
    List<CalendarData> _calendarData = [];
    DateTime _endOfRange = DateTime.now().subtract(const Duration(days: 1));
    DateTime _startOfRange = _endOfRange.subtract(Duration(days: daysOfData));
    int _maxDayTradeCount = maxDayTradeCount;

    for (var i = _endOfRange;
        i.isAfter(_startOfRange);
        i = i.subtract(const Duration(days: 1))) {
      // logger.i('THIS DATE: ${dateWithDayFormatter.format(i)}');
      List<MarketActivity> _thisTradeDateList = allTrades
          .where((element) =>
              i.month == element.tradeExecutionDate.month &&
              i.day == element.tradeExecutionDate.day &&
              i.year == element.tradeExecutionDate.year)
          .toList();

      if (_thisTradeDateList.length > maxDayTradeCount) {
        _maxDayTradeCount = _thisTradeDateList.length;
      }

      DateTime _date = i;

      List<String> _tickers =
          _thisTradeDateList.map((e) => e.tickerName.toUpperCase()).toList();

      List<String> _memberIds =
          _thisTradeDateList.map((e) => e.memberId).toList();

      _calendarData.add(CalendarData(
        _date,
        _tickers,
        _memberIds,
        _thisTradeDateList,
      ));

      _calendarData.removeWhere((element) =>
          dateWithDayFormatter.format(element.date).contains('Sat') ||
          dateWithDayFormatter.format(element.date).contains('Sun'));
    }

    setState(() => maxDayTradeCount = _maxDayTradeCount);

    return _calendarData;
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
                  ? AnimatedWidgets.circularProgressWatchtower(context, userDatabase, userIsPremium,
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
                                                                              _thisDay =
                                                                              calendarData[index];
                                                                          String
                                                                              _thisDate =
                                                                              dateWithDayFormatter.format(calendarData[index].date);
                                                                          double
                                                                              _thisBarHeightPercent =
                                                                              (_thisDay.trades.length / dailyTradeBarHeight);

                                                                          return BounceInDown(
                                                                            duration:
                                                                                Duration(milliseconds: index * 10),
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                // debugPrint('${_thisDay.trades.map((e) => e)}');
                                                                                if (_thisDay.trades.isNotEmpty) {
                                                                                  showModalBottomSheet(
                                                                                      backgroundColor: Colors.transparent,
                                                                                      context: context,
                                                                                      enableDrag: true,
                                                                                      builder: (context) {
                                                                                        return SharedWidgets.marketDailyTradesCalendar(context, _thisDay, allMembersList, userDatabase, userIsPremium, allHouseStockWatchList, allSenateStockWatchList);
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
                                                                                            colors: List.generate((_thisBarHeightPercent * 100).toInt() * 10, (_) => darkTheme ? Colors.purple : stockWatchColor) +
                                                                                                List.generate(
                                                                                                  (dailyTradeBarHeight - (dailyTradeBarHeight * _thisBarHeightPercent)).toInt() * 10,
                                                                                                  (_) => _thisDate.contains('Mon')
                                                                                                      ? darkTheme
                                                                                                          ? Theme.of(context).primaryColorDark.withOpacity(0.4)
                                                                                                          : stockWatchColor.withOpacity(0.15)
                                                                                                      : Colors.transparent,
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                        child: Column(
                                                                                          children: [
                                                                                            AnimatedWidgets.flashingEye(context, _thisDay.memberIds.any((id) => subscriptionAlertsList.toString().toLowerCase().contains(id.toLowerCase())), false, size: 6, sameColorBright: false),
                                                                                            RotatedBox(
                                                                                                quarterTurns: 3,
                                                                                                child: Text(
                                                                                                  _thisDate.toUpperCase(),
                                                                                                  textAlign: TextAlign.end,
                                                                                                  style: Styles.regularStyle.copyWith(
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                      color: Colors.grey.withOpacity(0.4), // darkThemeTextColor,
                                                                                                      fontSize: 11),
                                                                                                )),
                                                                                          ],
                                                                                        )),
                                                                                    Positioned(
                                                                                      bottom: (dailyTradeBarHeight * _thisBarHeightPercent).toDouble() - 4.75,
                                                                                      // left: 1,
                                                                                      child: CircleAvatar(radius: 9, backgroundColor: darkTheme ? Theme.of(context).primaryColorDark : stockWatchColor, child: Text(_thisDay.tickers.length.toString(), style: Styles.regularStyle.copyWith(color: darkThemeTextColor, fontSize: 8, fontWeight: FontWeight.bold))),
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
                                                                  .map((_thisTicker) =>
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
                                                                              List<String> _memberIds = [];

                                                                              thisMarketActivityOverviewList.where((element) => element.tickerName.toLowerCase() == _thisTicker.tickerName.toLowerCase() && element.memberId.toLowerCase() != 'noid').forEach((item) {
                                                                                _memberIds.add(item.memberId.toLowerCase());
                                                                              });

                                                                              List<ChamberMember> _tickerMembersList = [];

                                                                              _memberIds.toSet().forEach((memberId) {
                                                                                _tickerMembersList.add(allMembersList.firstWhere((element) => element.id.toLowerCase() == memberId.toLowerCase()));
                                                                              });

                                                                              debugPrint('${_thisTicker.tickerName} TICKER MEMBERS: ${_tickerMembersList.length}');

                                                                              if (_tickerMembersList.isNotEmpty) {
                                                                                showModalBottomSheet(
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    enableDrag: true,
                                                                                    builder: (context) {
                                                                                      return SharedWidgets.marketActivityTicker(context, _thisTicker.tickerName, _thisTicker.tickerDescription, _tickerMembersList.toSet().toList(), daysOfData, userDatabase, userIsPremium, userIsLegacy, allHouseStockWatchList, allSenateStockWatchList);
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
                                                                                    colors: List.generate(_thisTicker.tickerPurchaseCount * 10, (_) => alertIndicatorColorDarkGreen) + List.generate(_thisTicker.tickerSaleCount * 10, (_) => altHighlightAccentColorDarkRed) + List.generate((maxTickerTrades - (_thisTicker.tickerPurchaseCount + _thisTicker.tickerSaleCount)) + (maxTickerTrades ~/ 15) * 10, (_) => darkTheme ? Theme.of(context).primaryColorDark.withOpacity(0.75) : stockWatchColor.withOpacity(0.75)),
                                                                                  )),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                child: Row(
                                                                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(
                                                                                      _thisTicker.tickerName,
                                                                                      style: Styles.regularStyle.copyWith(fontSize: 13, color: darkThemeTextColor),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    AnimatedWidgets.flashingEye(context, thisMarketActivityOverviewList.any((element) => element.tickerName.toLowerCase() == _thisTicker.tickerName.toLowerCase() && subscriptionAlertsList.any((item) => item.toLowerCase().contains(element.memberId.toLowerCase()))), false, size: 8, sameColorBright: true),
                                                                                    const SizedBox(width: 5),
                                                                                    Text(
                                                                                      '${thisMarketActivityOverviewList.where((element) => element.tickerName.toLowerCase() == _thisTicker.tickerName.toLowerCase() && element.memberId.toLowerCase() != 'noid').map((e) => e.memberId).toSet().length} 🧑🏽‍💼 | ${_thisTicker.tickerPurchaseCount} ▲ | ${_thisTicker.tickerSaleCount} ▼',
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
                                                                          .all(0),
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
                                                                  .map((_thisMember) =>
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
                                                                                List<HouseStockWatch> _thisRepresentativeList = [];
                                                                                List<SenateStockWatch> _thisSenatorList = [];
                                                                                String _thisChamber = _thisMember.member.shortTitle.toLowerCase().startsWith('r') || _thisMember.member.shortTitle.toLowerCase().startsWith('h') ? 'house' : 'senate';

                                                                                debugPrint('^^^^^ CHAMBER IS: $_thisChamber');

                                                                                if (_thisChamber == 'house') {
                                                                                  try {
                                                                                    _thisRepresentativeList = thisHouseStockWatchList.where((element) => element.representative.toLowerCase().split(' ')[1][0] == _thisMember.member.firstName.toLowerCase()[0] && element.representative.toLowerCase().contains(_thisMember.member.lastName.toLowerCase()) && element.ticker != null && element.ticker != '--' && element.ticker != 'N/A').toList();
                                                                                    debugPrint('^^^^^ HOUSE STOCK LIST: ${_thisRepresentativeList.length}');
                                                                                  } catch (e) {
                                                                                    debugPrint('^^^^^ HOUSE STOCK LIST ERROR $e');
                                                                                    _thisRepresentativeList = [];
                                                                                  }
                                                                                } else if (_thisChamber == 'senate') {
                                                                                  try {
                                                                                    _thisSenatorList = thisSenateStockWatchList.where((element) => element.senator.toLowerCase().split(' ')[0][0] == _thisMember.member.firstName.toLowerCase()[0] && element.senator.toLowerCase().contains(_thisMember.member.lastName.toLowerCase()) && element.ticker != null && element.ticker != '--' && element.ticker != 'N/A').toList();
                                                                                    debugPrint('^^^^^ SENATE STOCK LIST: ${_thisSenatorList.length}');
                                                                                  } catch (e) {
                                                                                    debugPrint('^^^^^ SENATE STOCK LIST ERROR $e');
                                                                                    _thisSenatorList = [];
                                                                                  }
                                                                                }

                                                                                showModalBottomSheet(
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    enableDrag: true,
                                                                                    builder: (context) {
                                                                                      return SharedWidgets.marketActivityMember(context, _thisChamber, _thisMember.member, daysOfData, userDatabase, userIsPremium, userIsLegacy, _thisRepresentativeList, _thisSenatorList);
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
                                                                                    colors: List.generate(_thisMember.memberBuyCount * 10, (_) => alertIndicatorColorDarkGreen) + List.generate(_thisMember.memberSellCount * 10, (_) => altHighlightAccentColorDarkRed) + List.generate((maxMemberTrades - (_thisMember.memberBuyCount + _thisMember.memberSellCount)) + (maxMemberTrades ~/ 15) * 10, (_) => darkTheme ? Theme.of(context).primaryColorDark.withOpacity(0.75) : stockWatchColor.withOpacity(0.75)),
                                                                                  )),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(
                                                                                      _thisMember.memberName,
                                                                                      style: Styles.regularStyle.copyWith(fontSize: 13, color: darkThemeTextColor),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    AnimatedWidgets.flashingEye(context, _thisMember.member.id != null && _thisMember.member.id.toLowerCase() != 'noid' && subscriptionAlertsList.any((item) => item.toLowerCase().contains(_thisMember.member.id.toLowerCase())), false, size: 8, sameColorBright: true),
                                                                                    const SizedBox(width: 5),
                                                                                    Text(
                                                                                      '${_thisMember.memberTickerCount} STX | ${_thisMember.memberBuyCount} ▲ | ${_thisMember.memberSellCount} ▼',
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
                                                                          .all(0),
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
                                                                  .map((_thisDollarRange) =>
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
                                                                              List<String> _memberIds = [];

                                                                              thisMarketActivityOverviewList.where((element) => element.dollarAmount.toLowerCase() == _thisDollarRange.dollarRange.toLowerCase() && element.memberId.toLowerCase() != 'noid').forEach((item) {
                                                                                _memberIds.add(item.memberId.toLowerCase());
                                                                              });

                                                                              List<ChamberMember> _dollarRangeMembersList = [];

                                                                              _memberIds.toSet().forEach((memberId) {
                                                                                _dollarRangeMembersList.add(allMembersList.firstWhere((element) => element.id.toLowerCase() == memberId.toLowerCase()));
                                                                              });

                                                                              debugPrint('${_thisDollarRange.dollarRange} DOLLAR RANGE MEMBERS: ${_dollarRangeMembersList.length}');

                                                                              if (_dollarRangeMembersList.isNotEmpty) {
                                                                                showModalBottomSheet(
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    enableDrag: true,
                                                                                    builder: (context) {
                                                                                      return SharedWidgets.marketActivityDollarRange(context, _thisDollarRange.dollarRange, _dollarRangeMembersList.toSet().toList(), daysOfData, userDatabase, userIsPremium, userIsLegacy, allHouseStockWatchList, allSenateStockWatchList);
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
                                                                                    colors: List.generate(_thisDollarRange.rangeBuyCount * 10, (_) => alertIndicatorColorDarkGreen) + List.generate(_thisDollarRange.rangeSellCount * 10, (_) => altHighlightAccentColorDarkRed) + List.generate((maxRangeTrades - (_thisDollarRange.rangeBuyCount + _thisDollarRange.rangeSellCount)) + (maxRangeTrades ~/ 15) * 10, (_) => darkTheme ? Theme.of(context).primaryColorDark.withOpacity(0.75) : stockWatchColor.withOpacity(0.75)),
                                                                                  )),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                child: Row(
                                                                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(
                                                                                      _thisDollarRange.dollarRange,
                                                                                      style: Styles.regularStyle.copyWith(fontSize: 13, color: darkThemeTextColor),
                                                                                    ),
                                                                                    const Spacer(),
                                                                                    AnimatedWidgets.flashingEye(context, thisMarketActivityOverviewList.any((element) => element.dollarAmount.toLowerCase() == _thisDollarRange.dollarRange.toLowerCase() && subscriptionAlertsList.any((item) => item.toLowerCase().contains(element.memberId.toLowerCase()))), false, size: 8, sameColorBright: true),
                                                                                    const SizedBox(width: 5),
                                                                                    Text(
                                                                                      '${thisMarketActivityOverviewList.where((element) => element.dollarAmount.toLowerCase() == _thisDollarRange.dollarRange.toLowerCase() && element.memberId.toLowerCase() != 'noid').map((e) => e.memberId).toSet().length} 🧑🏽‍💼 | ${_thisDollarRange.rangeBuyCount} ▲ | ${_thisDollarRange.rangeSellCount} ▼',
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
                                                                          .all(0),
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
                                                      context, userDatabase, userIsPremium,
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
