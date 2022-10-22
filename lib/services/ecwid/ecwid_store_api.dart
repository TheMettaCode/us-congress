import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/services/ecwid/ecwid_store_model.dart';
import 'package:us_congress_vote_tracker/services/notifications/notification_api.dart';

class EcwidStoreApi {
  static Future<List<EcwidStoreItem>> getEcwidStoreProducts(
      {BuildContext context}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    List<EcwidStoreItem> _currentEcwidProductsList = [];
    // EcwidStoreItem _firstCurrentCustomerProduct;

    try {
      _currentEcwidProductsList =
          ecwidStoreFromJson(userDatabase.get('ecwidProducts')).items;
      // _firstCurrentCustomerProduct = _currentEcwidProductsList.firstWhere(
      //     (element) => !element.name.toLowerCase().contains('[dev]'));
    } catch (e) {
      logger.w(
          '^^^^^ ERROR RETRIEVING ECWID STORE ITEMS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
      userDatabase.put('ecwidProducts', {});
      _currentEcwidProductsList = [];
    }

    List<EcwidStoreItem> _finalEcwidProductsList = [];
    // EcwidStoreItem _firstFinalCustomerProduct;

    if (_currentEcwidProductsList.isEmpty ||
        DateTime.parse(userDatabase.get('lastEcwidProductsRefresh'))
            .isBefore(DateTime.now().subtract(Duration(hours: 6))) ||
        (userIsDev &&
            DateTime.parse(userDatabase.get('lastEcwidProductsRefresh'))
                .isBefore(DateTime.now().subtract(Duration(hours: 1))))) {

      /// STORE INFO
      final String ecwidStoreId = dotenv.env["SGUSA_ECWID_STORE_ID"];
      final String ecwidPublicToken = dotenv.env["SGUSA_ECWID_PUBLIC_TOKEN"];
      final String categoryId = dotenv.env["SGUSA_CATEGORY_ID"];
      final Map headers = <String, String>{"Accept": "application/json"};

      final String apiUrl =
          'https://app.ecwid.com/api/v3/$ecwidStoreId/products?offset=0&token=$ecwidPublicToken&categories=$categoryId';

      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      logger.d('***** ECWID API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('***** ECWID PRODUCT RETRIEVAL SUCCESS! *****');
        EcwidStore ecwidStore = ecwidStoreFromJson(response.body);

        if (ecwidStore.items.length > 0) {
          _finalEcwidProductsList = ecwidStore.items;
          // _finalUserEcwidProductsList = _fullEcwidProductsList.where((item) => !item.name.toLowerCase().contains('[dev]'));

          /// PRUNE AND SORT FINAL PRODUCTS LIST
          _finalEcwidProductsList.removeWhere((item) => !item.enabled);
          if (!userIsDev) {
            _finalEcwidProductsList
                .removeWhere((item) => item.name.toLowerCase().contains('[dev]'));
          }

          _finalEcwidProductsList.sort((a, b) => a.showOnFrontpage
              .compareTo(b.showOnFrontpage)
              .compareTo(a.createTimestamp.compareTo(b.createTimestamp)));

          if (_currentEcwidProductsList.isEmpty ||
              _finalEcwidProductsList.first.id !=
                  _currentEcwidProductsList.first.id) {
            userDatabase.put("newEcwidProducts", true);

            if (userIsDev) {
              final subject =
                  'NOW AVAILABLE! ${_finalEcwidProductsList.first.name}';
              final messageBody =
                  'Check out our latest product! ${_finalEcwidProductsList.first.name} is now available in our affiliate SCAPEGOATS™ USA\'s online store! Get 10% OFF with coupon code [BABBLEON].Be one of the 1st to get your hands on one!';

              List<String> capitolBabbleNotificationsList = List<String>.from(
                  userDatabase.get('capitolBabbleNotificationsList'));
              capitolBabbleNotificationsList.add(
                  '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>regular<|:|>${_finalEcwidProductsList.first.url}');
              userDatabase.put('capitolBabbleNotificationsList',
                  capitolBabbleNotificationsList);
            }
          }

          if (_currentEcwidProductsList.isEmpty) {
            _currentEcwidProductsList = _finalEcwidProductsList;
            // _firstCurrentCustomerProduct = _currentEcwidProductsList.firstWhere(
            //     (element) => !element.name.toLowerCase().contains('[dev]'));
          }

          try {
            userDatabase.put("ecwidProducts", ecwidStoreToJson(ecwidStore));
            logger.i('***** NEW ECWID PRODUCTS SAVED TO DBASE *****');
          } catch (e) {
            logger.w(
                '^^^^^ ERROR SAVING ECWID STORE ITEMS DATA TO DBASE (ECWID_STORE_API): $e ^^^^^');
            userDatabase.put('ecwidProducts', {});
          }
        }

        if (userDatabase.get('newProductAlerts') &&
            _currentEcwidProductsList.first.name !=
                _finalEcwidProductsList.first.name) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                13,
                'products',
                'Store Product',
                'In-App Store Products',
                'New Product Available!',
                'NEW MERCH AVAILABLE!',
                'CHECK IT OUT! ${_finalEcwidProductsList.first.name} is now available from the In-App Market. Be one of the first to get yours!',
                'product');
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message:
                    'NEW MERCH AVAILABLE!\n${_finalEcwidProductsList.first.name} is now available in the shop! Check it out and be one of the first to get yours!',
                networkImageUrl: _finalEcwidProductsList.first.imageUrl,
                isAlert: false,
                removeCurrent: false);
          }
        }

        userDatabase.put('lastEcwidProductsRefresh', '${DateTime.now()}');
        return _finalEcwidProductsList;
      } else {
        userDatabase.put("newEcwidProducts", false);
        logger.w(
            '***** API ERROR: LOADING ECWID PRODUCTS FROM DBASE: ${response.statusCode} *****');

        return _finalEcwidProductsList = _currentEcwidProductsList.isNotEmpty
            ? _currentEcwidProductsList
            : [];
      }
    } else {
      userDatabase.put("newEcwidProducts", false);
      _finalEcwidProductsList = _currentEcwidProductsList;
      logger.d('***** ECWID PRODUCTS NOT UPDATED: CATALOG IS CURRENT *****');
      return _finalEcwidProductsList;
    }
  }
}
