import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/models/member_payload_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/house_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/market_activity_model.dart';
import 'package:us_congress_vote_tracker/services/congress_stock_watch/senate_stock_watch_model.dart';
import 'package:us_congress_vote_tracker/services/notifications/notification_api.dart';
import 'package:us_congress_vote_tracker/services/propublica/propublica_api.dart';

class CongressStockWatchApi {
  static Future<List<HouseStockWatch>> fetchHouseStockDisclosures({
    BuildContext context,
  }) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<HouseStockWatch> _currentHouseStockWatchList = [];

    if (userIsPremium) {
      try {
        _currentHouseStockWatchList =
            houseStockWatchFromJson(userDatabase.get('houseStockWatchList'));
      } catch (e) {
        logger.d('***** CURRENT HOUSE STOCK WATCH ERROR: $e - Resetting... *****');
        userDatabase.put('houseStockWatchList', []);
        _currentHouseStockWatchList = [];
      }

      List<HouseStockWatch> _finalHouseStockWatchList = [];

      if (_currentHouseStockWatchList.isEmpty ||
          DateTime.parse(userDatabase.get('lastHouseStockWatchListRefresh'))
              .isBefore(DateTime.now().subtract(const Duration(hours: 3)))) {
        logger.d('***** Retrieving House Stock Watch Data... *****');

        const String houseStockWatchUrl =
            'https://house-stock-watcher-data.s3-us-west-2.amazonaws.com/data/all_transactions.json';

        final response = await http.get(Uri.parse(houseStockWatchUrl));
        logger.d('***** HOUSE STOCK WATCH RESPONSE CODE: ${response.statusCode} *****');

        if (response.statusCode == 200) {
          logger.d('***** HOUSE STOCK WATCH RETRIEVAL SUCCESS! *****');
          List<HouseStockWatch> houseStockWatchList = houseStockWatchFromJson(response.body);

          List<ChamberMember> membersList = [];
          ChamberMember thisMember;

          if (houseStockWatchList.isNotEmpty) {
            logger.d(houseStockWatchList.map((e) => e.transactionDate));

            _finalHouseStockWatchList = houseStockWatchList;

            _finalHouseStockWatchList
                .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

            _finalHouseStockWatchList.removeWhere((element) =>
                element.transactionDate.isAfter(DateTime.now()) ||
                element.transactionDate.isBefore(DateTime.now().subtract(const Duration(days: 365))));

            if (_currentHouseStockWatchList.isEmpty ||
                _finalHouseStockWatchList.first.representative !=
                    _currentHouseStockWatchList.first.representative) {
              userDatabase.put('newHouseStock', true);
              userDatabase.put('newMarketOverview', true);

              try {
                membersList = memberPayloadFromJson(userDatabase.get('houseMembersList'))
                        .results
                        .first
                        .members +
                    memberPayloadFromJson(userDatabase.get('senateMembersList'))
                        .results
                        .first
                        .members;

                thisMember = membersList.firstWhere((element) =>
                    _finalHouseStockWatchList.first.representative
                        .toLowerCase()
                        .contains(element.firstName.toLowerCase()) &&
                    _finalHouseStockWatchList.first.representative
                        .toLowerCase()
                        .contains(element.lastName.toLowerCase()));
              } catch (e) {
                logger.w('ERROR DURING RETRIEVAL OF MEMBERS LIST (House Stock Watch Function): $e');
              }

              if (userIsDev) {
                final String subject =
                    'MARKET TRADE REPORT FOR ${_finalHouseStockWatchList.first.representative}';
                final String messageBody =
                    'HOUSE TRADE REPORT: ${thisMember == null ? _finalHouseStockWatchList.first.representative : '@${thisMember.twitterAccount}'} ${_finalHouseStockWatchList.first.type.toUpperCase().replaceFirst('_', ' ')} of ${_finalHouseStockWatchList.first.ticker == 'N/A' || _finalHouseStockWatchList.first.ticker == '--' || _finalHouseStockWatchList.first.ticker == null ? '' : '\$${_finalHouseStockWatchList.first.ticker}'} ${_finalHouseStockWatchList.first.assetDescription.replaceAll(RegExp(r'<(.*)>'), '')} nasdaq nyse trading stock market commodities';

                List<String> capitolBabbleNotificationsList =
                    List<String>.from(userDatabase.get('capitolBabbleNotificationsList'));
                capitolBabbleNotificationsList.insert(
                    0, '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>medium');
                userDatabase.put('capitolBabbleNotificationsList', capitolBabbleNotificationsList);
              }
            }

            if (_currentHouseStockWatchList.isEmpty) {
              _currentHouseStockWatchList = _finalHouseStockWatchList;
            }

            try {
              logger.i('***** SAVING NEW HOUSE STOCK DATA TO DBASE *****');
              userDatabase.put('houseStockWatchList', houseStockWatchToJson(houseStockWatchList));
            } catch (e) {
              logger.w('^^^^^ ERROR SAVING HOUSE STOCK DATA TO DBASE (FUNCTION): $e ^^^^^');
              userDatabase.put('houseStockWatchList', []);
            }

            try {
              List<String> houseStockMarketActivityList = [];
              for (var item in _finalHouseStockWatchList) {
                if (item.ticker != null && item.ticker != '--' && item.ticker != 'N/A') {
                  houseStockMarketActivityList.add(
                      '${item.ticker}<|:|>${item.assetDescription.replaceAll(RegExp(r'<(.*)>'), '')}_${item.type.replaceFirst('_', ' ')}_${item.amount}_${item.representative}_${item.transactionDate}_${item.disclosureDate}_house_${item.owner}');
                }
              }
              userDatabase.put('houseStockMarketActivityList', houseStockMarketActivityList);
            } catch (e) {
              logger
                  .w('^^^^^ ERROR SAVING HOUSE MARKET ACTIVITY LIST TO DBASE (FUNCTION): $e ^^^^^');
              userDatabase.put('houseStockMarketActivityList', []);
            }
          }

          bool memberWatched = await Functions.hasSubscription(
              userIsPremium,
              userIsLegacy,
              (_finalHouseStockWatchList.map((e) => e.representative.split(' ')[1]))
                  .toList()
                  .asMap(),
              'member_',
              userIsDev: userIsDev);

          if (userIsPremium &&
              (userDatabase.get('stockWatchAlerts') || memberWatched) &&
              (_currentHouseStockWatchList.first.representative.toLowerCase() !=
                  _finalHouseStockWatchList.first.representative.toLowerCase()
              /*  ||
                userDatabase
                        .get('lastHouseStockWatchItem')
                        .toString()
                        .toLowerCase() !=
                    _finalHouseStockWatchList.first.representative
                        .toLowerCase()*/
              )) {
            if (context == null || !ModalRoute.of(context).isCurrent) {
              await NotificationApi.showBigTextNotification(
                  10,
                  'house_stock_watch',
                  'House Stock Disclosures',
                  'House Stock Trade Activity',
                  'House Stock Trade Activity',
                  '💸 ${_finalHouseStockWatchList.first.representative}',
                  memberWatched
                      ? 'A member you\'re watching has new stock trade activity'
                      : '${_finalHouseStockWatchList.first.ticker == 'N/A' || _finalHouseStockWatchList.first.ticker == '--' || _finalHouseStockWatchList.first.ticker == null ? _finalHouseStockWatchList.first.assetDescription.replaceAll(RegExp(r'<(.*)>'), '') : '\$${_finalHouseStockWatchList.first.ticker}'} ${_finalHouseStockWatchList.first.type.replaceFirst('_', ' ')}',
                  houseStockWatchList);
            } else if (ModalRoute.of(context).isCurrent) {
              Messages.showMessage(
                context: context,
                message: memberWatched
                    ? 'A member you\'re watching has new stock trade activity'
                    : 'New House Stock Trade Activity',
                networkImageUrl: thisMember == null
                    ? ''
                    : '${PropublicaApi().memberImageRootUrl}${thisMember.id}.jpg',
                isAlert: false,
                removeCurrent: false,
              );
            }
          }

          userDatabase.put('lastHouseStockWatchItem',
              _finalHouseStockWatchList.first.representative.toLowerCase());
          userDatabase.put('lastHouseStockWatchListRefresh', '${DateTime.now()}');
          return _finalHouseStockWatchList;
        } else {
          logger.w(
              '***** API ERROR: LOADING HOUSE STOCK WATCH DATA FROM DBASE: ${response.statusCode} *****');

          return _finalHouseStockWatchList =
              _currentHouseStockWatchList.isNotEmpty ? _currentHouseStockWatchList : [];
        }
      } else {
        logger.d(
            '***** CURRENT HOUSE STOCK DATA LIST: ${_currentHouseStockWatchList.map((e) => e.representative)} *****');
        _finalHouseStockWatchList = _currentHouseStockWatchList;
        logger.d('***** HOUSE STOCK DATA NOT UPDATED: LIST IS CURRENT *****');
        return _finalHouseStockWatchList;
      }
    } else {
      return _currentHouseStockWatchList;
    }
  }

  static Future<List<SenateStockWatch>> fetchSenateStockDisclosures({
    BuildContext context,
  }) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<SenateStockWatch> _currentSenateStockWatchList = [];

    if (userIsPremium) {
      try {
        _currentSenateStockWatchList =
            senateStockWatchFromJson(userDatabase.get('senateStockWatchList'));
      } catch (e) {
        logger.d('***** CURRENT SENATE STOCK WATCH ERROR: $e - Resetting... *****');
        userDatabase.put('senateStockWatchList', []);
        _currentSenateStockWatchList = [];
      }

      List<SenateStockWatch> _finalSenateStockWatchList = [];

      if (_currentSenateStockWatchList.isEmpty ||
          DateTime.parse(userDatabase.get('lastSenateStockWatchListRefresh'))
              .isBefore(DateTime.now().subtract(const Duration(hours: 4)))) {
        logger.d('***** Retrieving Senate Stock Watch Data... *****');

        const String senateStockWatchUrl =
            'https://senate-stock-watcher-data.s3-us-west-2.amazonaws.com/aggregate/all_transactions.json';

        final response = await http.get(Uri.parse(senateStockWatchUrl));
        logger.d('***** SENATE STOCK WATCH RESPONSE CODE: ${response.statusCode} *****');

        if (response.statusCode == 200) {
          logger.d('***** SENATE STOCK WATCH RETRIEVAL SUCCESS! *****');
          List<SenateStockWatch> senateStockWatchList = senateStockWatchFromJson(response.body);

          List<ChamberMember> membersList = [];
          ChamberMember thisMember;

          if (senateStockWatchList.isNotEmpty) {
            logger.d(senateStockWatchList.map((e) => e.transactionDate));

            _finalSenateStockWatchList = senateStockWatchList;

            _finalSenateStockWatchList
                .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

            _finalSenateStockWatchList.removeWhere((element) =>
                element.transactionDate.isAfter(DateTime.now()) ||
                element.transactionDate.isBefore(DateTime.now().subtract(const Duration(days: 365))));

            if (_currentSenateStockWatchList.isEmpty ||
                _finalSenateStockWatchList.first.senator !=
                    _currentSenateStockWatchList.first.senator) {
              userDatabase.put('newSenateStock', true);
              userDatabase.put('newMarketOverview', true);

              try {
                membersList = memberPayloadFromJson(userDatabase.get('houseMembersList'))
                        .results
                        .first
                        .members +
                    memberPayloadFromJson(userDatabase.get('senateMembersList'))
                        .results
                        .first
                        .members;

                thisMember = membersList.firstWhere((element) =>
                    _finalSenateStockWatchList.first.senator
                        .toLowerCase()
                        .contains(element.firstName.toLowerCase()) &&
                    _finalSenateStockWatchList.first.senator
                        .toLowerCase()
                        .contains(element.lastName.toLowerCase()));
              } catch (e) {
                logger.w('ERROR DURING RETRIEVAL OF MEMBERS LIST (House Stock Watch Function): $e');
              }

              if (userIsDev) {
                final String subject =
                    'MARKET TRADE REPORT FOR SEN. ${_finalSenateStockWatchList.first.senator}';
                final String messageBody =
                    'SENATE TRADE REPORT: ${thisMember == null ? 'Sen. ${_finalSenateStockWatchList.first.senator}' : '@${thisMember.twitterAccount}'} ${_finalSenateStockWatchList.first.type} of ${_finalSenateStockWatchList.first.ticker == 'N/A' || _finalSenateStockWatchList.first.ticker == null || _finalSenateStockWatchList.first.ticker == '--' ? '' : '\$${_finalSenateStockWatchList.first.ticker}'} ${_finalSenateStockWatchList.first.assetDescription.replaceAll(RegExp(r'<(.*)>'), '')} nasdaq nyse trading stock market commodities';

                List<String> capitolBabbleNotificationsList =
                    List<String>.from(userDatabase.get('capitolBabbleNotificationsList'));
                capitolBabbleNotificationsList.insert(
                    0, '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>medium');
                userDatabase.put('capitolBabbleNotificationsList', capitolBabbleNotificationsList);
              }
            }

            if (_currentSenateStockWatchList.isEmpty) {
              _currentSenateStockWatchList = _finalSenateStockWatchList;
            }

            try {
              logger.i('***** SAVING NEW SENATE STOCK DATA TO DBASE *****');
              userDatabase.put(
                  'senateStockWatchList', senateStockWatchToJson(senateStockWatchList));
            } catch (e) {
              logger.w('^^^^^ ERROR SAVING SENATE STOCK DATA TO DBASE (FUNCTION): $e ^^^^^');
              userDatabase.put('senateStockWatchList', []);
            }

            try {
              List<String> senateStockMarketActivityList = [];
              for (var item in _finalSenateStockWatchList) {
                if (item.ticker != null && item.ticker != '--' && item.ticker != 'N/A') {
                  senateStockMarketActivityList.add(
                      '${item.ticker}<|:|>${item.assetDescription.replaceAll(RegExp(r'<(.*)>'), '')}_${item.type}_${item.amount}_Sen. ${item.senator}_${item.transactionDate}_${item.disclosureDate}_senate_${item.owner}');
                }
              }
              userDatabase.put('senateStockMarketActivityList', senateStockMarketActivityList);
            } catch (e) {
              logger.w(
                  '^^^^^ ERROR SAVING SENATE STOCK MARKET ACTIVITY LIST TO DBASE (FUNCTION): $e ^^^^^');
              userDatabase.put('senateStockMarketActivityList', []);
            }
          }

          bool memberWatched = await Functions.hasSubscription(
              userIsPremium,
              userIsLegacy,
              (_finalSenateStockWatchList.map((e) => e.senator.split(' ')[0])).toList().asMap(),
              'member_',
              userIsDev: userIsDev);

          if (userIsPremium &&
              (userDatabase.get('stockWatchAlerts') || memberWatched) &&
              (_currentSenateStockWatchList.first.senator.toLowerCase() !=
                  _finalSenateStockWatchList.first.senator.toLowerCase()
              /*  ||
                userDatabase
                        .get('lastSenateStockWatchItem')
                        .toString()
                        .toLowerCase() !=
                    _finalSenateStockWatchList.first.senator
                        .toLowerCase()*/
              )) {
            if (context == null || !ModalRoute.of(context).isCurrent) {
              await NotificationApi.showBigTextNotification(
                  11,
                  'senate_stock_watch',
                  'Senate Stock Disclosures',
                  'Senate Stock Trade Activity',
                  'Senate Stock Trade Activity',
                  '💸 Sen. ${_finalSenateStockWatchList.first.senator}',
                  memberWatched
                      ? 'A member you\'re watching has new stock trade activity'
                      : '${_finalSenateStockWatchList.first.ticker == 'N/A' || _finalSenateStockWatchList.first.ticker == '--' || _finalSenateStockWatchList.first.ticker == null ? _finalSenateStockWatchList.first.assetDescription.replaceAll(RegExp(r'<(.*)>'), '') : '\$${_finalSenateStockWatchList.first.ticker}'} ${_finalSenateStockWatchList.first.type}',
                  senateStockWatchList);
            } else if (ModalRoute.of(context).isCurrent) {
              Messages.showMessage(
                context: context,
                message: memberWatched
                    ? 'A member you\'re watching has new stock trade activity'
                    : 'New Senate Stock Trade Activity',
                networkImageUrl: thisMember == null
                    ? ''
                    : '${PropublicaApi().memberImageRootUrl}${thisMember.id}.jpg',
                isAlert: false,
                removeCurrent: false,
              );
            }
          }

          userDatabase.put(
              'lastSenateStockWatchItem', _finalSenateStockWatchList.first.senator.toLowerCase());
          userDatabase.put('lastSenateStockWatchListRefresh', '${DateTime.now()}');
          return _finalSenateStockWatchList;
        } else {
          logger.w(
              '***** API ERROR: LOADING SENATE STOCK WATCH DATA FROM DBASE: ${response.statusCode} *****');

          return _finalSenateStockWatchList =
              _currentSenateStockWatchList.isNotEmpty ? _currentSenateStockWatchList : [];
        }
      } else {
        logger.d(
            '***** CURRENT SENATE STOCK DATA LIST: ${_currentSenateStockWatchList.map((e) => e.senator)} *****');
        _finalSenateStockWatchList = _currentSenateStockWatchList;
        logger.d('***** HOUSE STOCK DATA NOT UPDATED: LIST IS CURRENT *****');
        return _finalSenateStockWatchList;
      }
    } else {
      return _currentSenateStockWatchList;
    }
  }

  static Future<List<MarketActivity>> updateMarketActivityOverview(
      {BuildContext context, List<ChamberMember> allChamberMembers}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    List<bool> userLevels = await Functions.getUserLevels();
    // bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    bool newMarketOverview = userDatabase.get('newMarketOverview');

    List<MarketActivity> _currentMarketActivityList = [];
    List<String> _houseStockMarketActivityList = [];
    List<String> _senateStockMarketActivityList = [];

    /// MARKET ACTIVITY OVERVIEW LIST
    try {
      _currentMarketActivityList =
          marketActivityFromJson(userDatabase.get('marketActivityOverview'));
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING MARKET ACTIVITY OVERVIEW DATA FROM DBASE (CONGRESS_STOCK_WATCH_API): $e ^^^^^');
      userDatabase.put('marketActivityOverview', {});
    }

    if ((userIsPremium && newMarketOverview) || _currentMarketActivityList.isEmpty
        // ||
        // DateTime.parse(userDatabase.get('lastMarketOverviewRefresh'))
        //     .isBefore(DateTime.now().subtract(Duration(hours: 12)))
        ) {
      try {
        _houseStockMarketActivityList = List.from(userDatabase.get('houseStockMarketActivityList'));
      } catch (e) {
        logger.w(
            '^^^^^ ERROR RETRIEVING HOUSE STOCK ACTIVITY DATA FROM DBASE (CONGRESS_STOCK_WATCH_API): $e ^^^^^');
        userDatabase.put('houseStockMarketActivityList', []);
      }

      try {
        _senateStockMarketActivityList =
            List.from(userDatabase.get('senateStockMarketActivityList'));
      } catch (e) {
        logger.w(
            '^^^^^ ERROR RETRIEVING SENATE STOCK ACTIVITY DATA FROM DBASE (CONGRESS_STOCK_WATCH_API): $e ^^^^^');
        userDatabase.put('senateStockMarketActivityList', []);
      }

      List<String> _allStockMarketActivityList =
          _houseStockMarketActivityList + _senateStockMarketActivityList;

      /// ADD MEMBER IDS TO ALL STOCK MARKET TRADES
      List<String> _newMarketTradesList = [];

      for (var trade in _allStockMarketActivityList) {
        String thisTradeMemberName = trade.split('_')[3];
        String _thisTradeFirstName = thisTradeMemberName.split(' ')[1];

        ChamberMember _thisMember;

        try {
          _thisMember = allChamberMembers.firstWhere((m) =>
              m.firstName[0].toLowerCase() ==
                  _thisTradeFirstName
                      .toLowerCase()
                      .replaceFirst('a.', 'mitch')
                      // .replaceFirst('robert', 'bob')
                      .replaceFirst('william', 'bill')
                      .replaceFirst('earl l.', 'buddy')[0] &&
              thisTradeMemberName.toLowerCase().contains(m.lastName.toLowerCase()));
        } catch (e) {
          // debugPrint('NO MEMBER FOUND NAMED $_fName $_lName');
          _thisMember = null;
        }

        if (_thisMember != null) {
          _newMarketTradesList.add('${trade}_${_thisMember.id.toLowerCase()}');
          // logger.i('MEMBER ${_thisMember.id.toUpperCase()} IS VALID');
        } else {
          _newMarketTradesList.add('${trade}_noId');
          // logger.i('MEMBER IS NULL');
        }
      }

      _newMarketTradesList.retainWhere((element) => DateTime.parse(element.split('_')[4])
          .isAfter(DateTime.now().subtract(const Duration(days: 365))));

      _newMarketTradesList.sort(
          (a, b) => DateTime.parse(a.split('_')[4]).compareTo(DateTime.parse(b.split('_')[4])));

      List<MarketActivity> _finalMarketActivityList = [];

      for (var trade in _newMarketTradesList) {
        String tickerInfo = trade.split('_')[0];
        String tickerName = tickerInfo.split('<|:|>')[0];
        String tickerDescription = tickerInfo.split('<|:|>')[1];
        String tradeType = trade.split('_')[1];
        String dollarAmount = trade.split('_')[2];
        String memberFullName = trade.split('_')[3];
        String memberTitle = memberFullName.split(' ')[0];
        String memberFirstName = memberFullName.split(' ')[1];
        DateTime tradeExecutionDate = DateTime.parse(trade.split('_')[4]);
        DateTime tradeDisclosureDate = DateTime.parse(trade.split('_')[5]);
        String memberChamber = trade.split('_')[6];
        String tradeOwner = trade.split('_')[7];
        String memberId = trade.split('_')[8];

        MarketActivity _thisTrade = MarketActivity(
            tickerName: tickerName,
            tickerDescription: tickerDescription,
            tradeType: tradeType,
            dollarAmount: dollarAmount,
            memberTitle: memberTitle,
            memberFirstName: memberFirstName,
            memberFullName: memberFullName,
            tradeExecutionDate: tradeExecutionDate,
            tradeDisclosureDate: tradeDisclosureDate,
            memberChamber: memberChamber,
            tradeOwner: tradeOwner,
            memberId: memberId);

        _finalMarketActivityList.add(_thisTrade);
      }

      try {
        userDatabase.put('marketActivityOverview', marketActivityToJson(_finalMarketActivityList));
        logger.i('^^^^^ MARKET ACTIVITY OVERVIEW DATA SAVED TO DATABASE ^^^^^');
      } catch (e) {
        logger.w(
            '^^^^^ ERROR SAVING MARKET ACTIVITY OVERVIEW DATA TO DBASE (CONGRESS_STOCK_WATCH_API): $e ^^^^^');
        userDatabase.put('marketActivityOverview', {});
      }

      userDatabase.put('lastMarketOverviewRefresh', '${DateTime.now()}');
      return _finalMarketActivityList;
    } else {
      return _currentMarketActivityList;
    }
  }
}
