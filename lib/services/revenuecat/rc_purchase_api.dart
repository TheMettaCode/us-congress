import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/models/order_detail.dart';

class RcPurchaseApi {
  static final _apiKey = dotenv.env["RC_PURCHASE_API_KEY"];

  /// REVENUECAT SERVICE INITIALIZATION
  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);

    // Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    // final List<String> appUserId = List.from(userDatabase.get('userIdList'));

    await Purchases.configure(PurchasesConfiguration(_apiKey
        // ,appUserId: appUserId.first.split('<|:|>')[1]
        ));
  }

  /// USED TO RETRIEVE CURRENT LIST OF PRODUCT OFFERINGS
  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      return current == null ? [] : [current];
    } catch (e) {
      return [];
    }
  }

  /// USED TO RETRIEVE CURRENT LIST OF PRODUCTS
  static Future<List<StoreProduct>> fetchProducts(
      List<String> productIds) async {
    try {
      final products = await Purchases.getProducts(productIds);

      return products ?? [];
    } catch (e) {
      return [];
    }
  }

  /// USED TO OBTAIN USER'S ACTIVE SUBSCRIPTIONS STATUS
  static Future<void> getSubscriptionStatus() async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    bool devUpgraded = userDatabase.get('devUpgraded');
    bool userIsDev = List<String>.from(userDatabase.get('userIdList'))
        .last
        .contains(dotenv.env['dCode']);
    if (!userIsDev && !devUpgraded) {
      try {
        CustomerInfo purchaserInfo = await Purchases.getCustomerInfo();
        if (purchaserInfo.entitlements.active.isNotEmpty &&
            purchaserInfo.entitlements.all["all_features"].isActive) {
          if (!userDatabase.get('userIsPremium')) {
            userDatabase.put('userIsPremium', true);
            userDatabase.put('userIsSubscribed', true);
          }

          /// RESTORE SUBSCRIPTIONS IF USER HAS RESUBSCRIBED
          List<String> localBackupSubscriptions =
              List.from(userDatabase.get('subscriptionAlertsListBackup'));
          if (localBackupSubscriptions.isNotEmpty) {
            await userDatabase.put(
                'subscriptionAlertsList', localBackupSubscriptions);
            userDatabase.put('subscriptionAlertsListBackup', []);

            userDatabase.put('billAlerts', true);
            userDatabase.put('lobbyingAlerts', true);
            userDatabase.put('privateFundedTripsAlerts', true);
            userDatabase.put('stockWatchAlerts', true);

            logger.d(
                'USER HAS RE-SUBSCRIBED. SUBS HAVE BEEN RESTORED: ${List.from(userDatabase.get('subscriptionAlertsList'))}');
          }

          logger.d('USER IS SUBSCRIBED');
        } else {
          /// CLEAR AND BACKUP USER SUBSCRIPTIONS JUST IN CASE THE USER RESUBSCRIBES
          List<String> localCurrentSubscriptions =
              List.from(userDatabase.get('subscriptionAlertsList'));

          if (localCurrentSubscriptions.isNotEmpty) {
            await userDatabase.put(
                'subscriptionAlertsListBackup', localCurrentSubscriptions);

            userDatabase.put('subscriptionAlertsList', []);
            userDatabase.put('memberAlerts', false);
            userDatabase.put('billAlerts', false);
            userDatabase.put('lobbyingAlerts', false);
            userDatabase.put('privateFundedTripsAlerts', false);
            userDatabase.put('stockWatchAlerts', false);

            logger.d(
                'USER IS NOT UPGRADED. ANY CURRENT SUBS HAVE BEEN BACKED UP: ${List.from(userDatabase.get('subscriptionAlertsListBackup'))}');
          }

          userDatabase.put('userIsPremium', false);
          userDatabase.put('userIsSubscribed', false);
        }
      } on PlatformException catch (e) {
        logger.w(e);
      }
    } else {
      /// RESTORE WATCH LIST IF USER HAS RESUBSCRIBED
      List<String> localCurrentSubscriptions =
          List.from(userDatabase.get('subscriptionAlertsList'));
      List<String> localBackupSubscriptions =
          List.from(userDatabase.get('subscriptionAlertsListBackup'));

      if (localBackupSubscriptions.isNotEmpty) {
        localCurrentSubscriptions.addAll(localBackupSubscriptions);

        userDatabase.put('subscriptionAlertsList', localCurrentSubscriptions);
        userDatabase.put('subscriptionAlertsListBackup', []);

        logger.d(
            'BACKUP SUBS HAVE BEEN ADDED TO CURRENT SUBS: ${List.from(userDatabase.get('subscriptionAlertsList'))}');
      }
    }
  }

  // /// USED TO HANDLE PURCHASE STATUS UPDATES
  // static Future<void> updatePurchaseStatus() async {
  //   Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  //   final purchaserInfo = await Purchases.getPurchaserInfo();

  //   final _activeEntitlements =
  //       purchaserInfo.entitlements.active.values.toList();
  //   logger.d(_activeEntitlements);
  //   if (_activeEntitlements.isEmpty) {
  //     userDatabase.put('userIsPremium', false);
  //   }
  // }

  /// USED TO COMPLETE A PRODUCT PURCHASE EVENT.
  /// The purchase:package takes a package from the fetched Offering
  /// and processes the transaction with the respective app store.
  static Future<void> productPurchase(StoreProduct product, bool isCredits,
      {UpgradeInfo upgradeInfo}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    try {
      debugPrint('^^^^^ ATTEMPTING PURCHASE OF ${product.identifier}');
      CustomerInfo customerInfo = await Purchases.purchaseProduct(
          product.identifier,
          type: PurchaseType.inapp);
      StoreTransaction thisTransaction =
          customerInfo.nonSubscriptionTransactions.lastWhere(
              (element) => element.productIdentifier == product.identifier);
      bool purchaseVerified = DateTime.parse(thisTransaction.purchaseDate)
              .minute
              .compareTo(DateTime.now().minute) ==
          0;
      debugPrint(
          '^^^^^ PURCHASE VERIFIED: $purchaseVerified\nPURCHASER INFO: ${customerInfo.allPurchasedProductIdentifiers}');
      if (purchaseVerified && isCredits) {
        // int currentPurchCredits = userDatabase.get('purchCredits');
        int addCredits = int.parse(product.identifier.split('_')[0]);
        Functions.processCredits(true,
            creditsToAdd: addCredits, isPurchased: true);
        // userDatabase.put('purchCredits', currentPurchCredits + addCredits);

        /// USER INFORMATION
        String initialUserId = List<String>.from(userDatabase.get('userIdList'))
            .firstWhere((element) =>
                element.split('<|:|>')[0].toLowerCase() == 'newuser');
        String lastUserId =
            List<String>.from(userDatabase.get('userIdList')).last;
        // String orderId =
        //     'IAP${random.nextInt(999999)}-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}-${initialUserId.split('<|:|>')[1]}';
        // Map<String, dynamic> currentUserAddress =
        //     Map<String, dynamic>.from(userDatabase.get('currentAddress'));

        /// PRODUCT ORDERS LIST
        List<Order> productOrdersList = [];

        try {
          productOrdersList = orderDetailListFromJson(
                  userDatabase.get('ecwidProductOrdersList'))
              .orders;
        } catch (e) {
          logger.w(
              '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
        }

        productOrdersList.insert(
            0,
            Order(
                orderDate: DateTime.now(),
                orderId: 'REVCAT${thisTransaction.revenueCatIdentifier}',
                orderIdExtended: '',
                userName: lastUserId.split('<|:|>')[0],
                userId: initialUserId.split('<|:|>')[1],
                productId: product.identifier,
                productName: product.title.replaceAll('(US Congress)', ''),
                productOptions: 'No Options',
                productDescription: product.description,
                productPrice: product.priceString,
                productImageUrl: '',
                customerName: '',
                customerId: initialUserId.split('<|:|>')[1],
                customerPhone: '',
                customerShippingAddress: '',
                customerEmail: ''));

        userDatabase.put('ecwidProductOrdersList',
            orderDetailListToJson(OrderDetailList(orders: productOrdersList)));
      } else {
        debugPrint('^^^^^ PURCHASE WAS NOT VERIFIED');
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        logger.w(e);
      }
    }
  }

  /// USED TO COMPLETE A PACKAGE PURCHASE EVENT.
  /// The purchase:package takes a package from the fetched Offering
  /// and processes the transaction with the respective app store.
  static Future<void> packagePurchase(
      BuildContext context, Package packageToPurchase,
      {UpgradeInfo upgradeInfo}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    final Package localPackage = packageToPurchase;
    logger.i(localPackage.packageType.name);

    try {
      CustomerInfo customerInfo =
          await Purchases.purchasePackage(packageToPurchase);

      bool isPremium = customerInfo.entitlements.all['all_features'].isActive;
      logger.d(customerInfo);
      if (isPremium) {
        /// GRANT PREMIUM STATUS AND LOG PREMIUM ID TO DATABASE
        userDatabase.put('userIsPremium', true);
        userDatabase.put('userIsSubscribed', true);

        /// USER INFORMATION
        String initialUserId = List<String>.from(userDatabase.get('userIdList'))
            .firstWhere((element) =>
                element.split('<|:|>')[0].toLowerCase() == 'newuser');
        String lastUserId =
            List<String>.from(userDatabase.get('userIdList')).last;
        // String orderId =
        //     'IAP${random.nextInt(999999)}-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}-${initialUserId.split('<|:|>')[1]}';
        // Map<String, dynamic> currentUserAddress =
        //     Map<String, dynamic>.from(userDatabase.get('currentAddress'));

        /// PRODUCT ORDERS LIST
        List<Order> productOrdersList = [];

        try {
          productOrdersList = orderDetailListFromJson(
                  userDatabase.get('ecwidProductOrdersList'))
              .orders;
        } catch (e) {
          logger.w(
              '^^^^^ ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
        }

        productOrdersList.insert(
            0,
            Order(
                orderDate: DateTime.now(),
                orderId: 'GPIAP-${packageToPurchase.storeProduct.identifier}',
                orderIdExtended: '',
                userName: lastUserId.split('<|:|>')[0],
                userId: initialUserId.split('<|:|>')[1],
                productId: packageToPurchase.storeProduct.identifier,
                productName:
                    'Start of ${packageToPurchase.storeProduct.title.replaceAll('(US Congress)', '')}',
                productOptions: 'No Options',
                productDescription: packageToPurchase.storeProduct.description,
                productPrice: packageToPurchase.storeProduct.priceString,
                productImageUrl: '',
                customerName: '',
                customerId: initialUserId.split('<|:|>')[1],
                customerPhone: '',
                customerShippingAddress: '',
                customerEmail: ''));

        userDatabase.put('ecwidProductOrdersList',
            orderDetailListToJson(OrderDetailList(orders: productOrdersList)));
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        logger.w(e);
      }
    }
  }

  static Future<void> removePackage(
      BuildContext context, Package packageToRemove) async {
    // Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    final Package localPackage = packageToRemove;
    logger.i(localPackage.packageType.name);

    try {
      // PurchaserInfo purchaserInfo =
      //     await Purchases.purchasePackage(packageToRemove);
      // bool isPremium = purchaserInfo.entitlements.all['all_features'].isActive;
      // logger.d(purchaserInfo);
      // if (isPremium) {
      //   /// REMOVE PREMIUM STATUS AND LOG PREMIUM ID TO DATABASE
      //   userDatabase.put('userIsPremium', false);
      // }
    } on PlatformException catch (e) {
      // var errorCode = PurchasesErrorHelper.getErrorCode(e);
      // if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
      logger.w(e);
      // }
    }
  }

  /// RevenueCat enables your users to restore their in-app purchases,
  /// reactivating any content that they previously purchased from the same store account
  static Future<void> restorePurchases() async {
    try {
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      if (restoredInfo.entitlements.all['all_features'].isActive) {}
      // ... check restored purchaserInfo to see if entitlement is now active
    } on PlatformException catch (e) {
      logger.w(e);
    }
  }
}
