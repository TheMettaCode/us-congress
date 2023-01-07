import 'dart:convert';
import 'dart:io' show HttpHeaders, Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:congress_watcher/constants/constants.dart';
import 'package:congress_watcher/functions/functions.dart';
import 'package:congress_watcher/models/order_detail.dart';

import '../../app_user/user_profile.dart';
import '../../app_user/user_status.dart';

class RcPurchaseApi {
  static final Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  static final bool googleTestMode = userDatabase.get('googleTestMode');
  static final bool amazonTestMode = userDatabase.get('amazonTestMode');
  static final bool testing = userDatabase.get('stripeTestMode') ||
      userDatabase.get('googleTestMode') ||
      userDatabase.get('amazonTestMode');

  /// REVENUECAT SERVICE INITIALIZATION
  static Future revenuecatPlatformInit() async {
    debugPrint('[RC PURCHASE API] CONFIGURING REVENUECAT SDK');
    // Box<dynamic userDatabase = Hive.box<dynamic>(appDatabase);
    // final List<String> appUserId = List.from(userDatabase.get('userIdList'));

    /// USER INFORMATION
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[RC API INIT] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint('[RC API INIT] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    // String rootUserId = List<String>.from(userDatabase.get('userIdList'))
    //     .firstWhere(
    //         (element) => element.split('<|:|>')[0].toLowerCase() == 'newuser')
    //     .split('<|:|>')[1];

    // List<bool> userLevels = await Functions.getUserLevels();
    // bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    // final String installerStore = userDatabase.get('installerStore');

    await Purchases.setDebugLogsEnabled(true);

    PurchasesConfiguration configuration =
        PurchasesConfiguration(dotenv.env["RC_GOOGLE_PUBLIC_API_KEY"])
          ..appUserID = thisUser.userId;
    if (amazonTestMode ||
        thisUser.installerStore.contains(amazonInstallerStoreExample)) {
      // use your preferred way to determine if this build is for Amazon store
      // checkout our MagicWeather sample for a suggestion
      configuration =
          AmazonConfiguration(dotenv.env["RC_AMAZON_PUBLIC_API_KEY"])
            ..appUserID = thisUser.userId;
    }
    // else if (installerStore == 'samsung') {
    //   // use your preferred way to determine if this build is for Samsung store
    //   // create mothod to use for Samsung IAP
    //   configuration = AmazonConfiguration(dotenv.env["RC_AMAZON_PUBLIC_API_KEY"])
    //     ..appUserID = rootUserId;
    // }

    if (configuration != null) {
      await Purchases.configure(configuration).then((_) => debugPrint(
          '[RC PURCHASE API] REVENUECAT CONFIGURATION COMPLETE WITH ${configuration.apiKey}'));
    }

    await updateRcCustomer();
    Purchases.addCustomerInfoUpdateListener((purchaserInfo) async => {
          // handle any changes to purchaserInfo
          await getSubscriptionStatus()
          // await RcPurchaseApi.getSubscriptionStatus()
        });
    // await getSubscriptionStatus();
  }

  /// UPDATE OR CREATE NEW REVENUECAT CUSTOMER
  static Future<CustomerInfo> updateRcCustomer(
      {bool forceUpdate = false,
      String name,
      String address,
      String description}) async {
    // Box<dynamic userDatabase = Hive.box<dynamic>(appDatabase);

    // UserProfile thisUser = await AppUser.getUserProfile();
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[REVENUECAT API CUSTOMER UPDATE] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[REVENUECAT API CUSTOMER UPDATE] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    CustomerInfo currentCustomerInfo = await Purchases.getCustomerInfo();

    List<String> revenuecatCustomerIdList = List.from(userDatabase.get(
            googleTestMode || amazonTestMode
                ? 'revenuecatTestCustomerIdList'
                : 'revenuecatCustomerIdList')) ??
        [];

    if (!revenuecatCustomerIdList
        .contains(currentCustomerInfo.originalAppUserId)) {
      revenuecatCustomerIdList.insert(0, currentCustomerInfo.originalAppUserId);
      userDatabase.put(
          googleTestMode || amazonTestMode
              ? 'revenuecatTestCustomerIdList'
              : 'revenuecatCustomerIdList',
          revenuecatCustomerIdList);
    }

    bool updatingUserInfo = forceUpdate ||
        (currentCustomerInfo != null &&
            (name != null || address != null || description != null));

    if (updatingUserInfo) {
      final attributes = <String, dynamic>{
        "installer_store": thisUser.installerStore,
        "app_user_id": thisUser.userId,
        // "user_status": userIsPremium ? "premium" : "free",
        // "name": updatingUserInfo && name != null ? name : "unknown",
        // "email": userEmailList.isNotEmpty ? userEmailList.last.split('<|:|>')[0] : "unknown",
        // "description": updatingUserInfo && description != null ? description : "none",
      };
      await Purchases.setAttributes(attributes);
      return await Purchases.getCustomerInfo();
    } else {
      debugPrint(
          '[REVENUECAT API CUSTOMER UPDATE] RC CUSTOMER INFO UNCHANGED: ${currentCustomerInfo..originalAppUserId}');
      return currentCustomerInfo;
    }
  }

  /// USED TO OBTAIN USER'S ACTIVE SUBSCRIPTIONS STATUS
  static Future<bool> getSubscriptionStatus() async {
    // Box<dynamic userDatabase = Hive.box<dynamic>(appDatabase);

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    // UserProfile thisUser = await AppUser.getUserProfile();
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[RC PURCHASE API SUBSCRIPTION STATUS] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[RC PURCHASE API SUBSCRIPTION STATUS] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    final DateTime freeTrialStartDate =
        DateTime.parse(userDatabase.get('freeTrialStartDate'));

    bool inFreeTrialPeriod = thisUser.premiumStatus &&
        thisUser.freeTrialUsed &&
        freeTrialStartDate.isAfter(DateTime.now()
            .subtract(Duration(days: freeTrialPromoDurationDays)));

    if (!thisUser.devUpgraded && !inFreeTrialPeriod) {
      try {
        if (!thisUser.premiumStatus &&
            customerInfo.entitlements.active.isNotEmpty &&
            customerInfo.entitlements.all["all_features"].isActive) {
          /// GRANT PREMIUM STATUS FOR USER
          await UserStatus.grantPremium();
          return Future<bool>.value(true);
        } else if (thisUser.premiumStatus) {
          /// CLEAR AND BACKUP USER SUBSCRIPTIONS JUST IN CASE THE USER RESUBSCRIBES
          await UserStatus.removePremium();
          return Future<bool>.value(false);
        } else {
          return Future<bool>.value(thisUser.premiumStatus);
        }
      } on PlatformException catch (e) {
        debugPrint(e.toString());
        return Future<bool>.value(thisUser.premiumStatus);
      }
    } else {
      debugPrint('[RC PURCHASE API] USER IS DEV UPGRADED TO PREMIUM STATUS');

      /// RESTORE WATCH LIST IF USER HAS RESUBSCRIBED
      List<String> localCurrentSubscriptions =
          List.from(userDatabase.get('subscriptionAlertsList'));
      List<String> localBackupSubscriptions =
          List.from(userDatabase.get('subscriptionAlertsListBackup'));

      if (localBackupSubscriptions.isNotEmpty) {
        localCurrentSubscriptions.addAll(localBackupSubscriptions);

        userDatabase.put('subscriptionAlertsList', localCurrentSubscriptions);
        userDatabase.put('subscriptionAlertsListBackup', []);

        // userDatabase.put('billAlerts', true);
        userDatabase.put('lobbyingAlerts', true);
        userDatabase.put('privateFundedTripsAlerts', true);
        userDatabase.put('stockWatchAlerts', true);

        debugPrint(
            '[RC PURCHASE API] BACKUP SUBS HAVE BEEN ADDED TO CURRENT SUBS: $localCurrentSubscriptions');
      }

      return Future<bool>.value(thisUser.premiumStatus);
    }
  }

  /// USED TO RETRIEVE CURRENT LIST OF PRODUCT OFFERINGS
  static Future<List<Offering>> fetchOffers() async {
    debugPrint('[RC PURCHASE API] FETCHING OFFERS');
    try {
      final Offerings offerings = await Purchases.getOfferings();
      final Offering current = offerings.current;

      debugPrint('[RC PURCHASE API] OFFERS FOUND');
      return current == null ? [] : [current];
    } catch (e) {
      debugPrint('[RC PURCHASE API] OFFERS FETCH ERROR: $e');
      return [];
    }
  }

  /// USED TO RETRIEVE CURRENT LIST OF PRODUCTS
  static Future<List<StoreProduct>> fetchProducts(
      List<String> productIds) async {
    debugPrint('[RC PURCHASE API] FETCHING PRODUCTS');
    try {
      final List<StoreProduct> products =
          await Purchases.getProducts(productIds);

      debugPrint('[RC PURCHASE API] PRODUCTS FOUND');
      return products ?? [];
    } catch (e) {
      debugPrint('[RC PURCHASE API] PRODUCT FETCH ERROR: $e');
      return [];
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
  static Future<void> productPurchase(
      BuildContext context, StoreProduct product, bool isCredits,
      {UpgradeInfo upgradeInfo}) async {
    // UserProfile thisUser = await AppUser.getUserProfile();
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[RC PURCHASE API PRODUCT PURCHASE] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[RC PURCHASE PRODUCT PURCHASE] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    StoreTransaction thisTransaction;
    bool purchaseVerified = false;

    try {
      debugPrint(
          '[RC PURCHASE API: PRODUCT PURCHASE] ATTEMPTING PURCHASE OF ${product.identifier}');

      debugPrint('[PRODUCT PURCHASE] PROCESSING IN-APP PRODUCT PURCHASE...');
      await Purchases.purchaseProduct(product.identifier,
              type: PurchaseType.inapp)
          .then((value) {
        customerInfo = value;
        thisTransaction = value.nonSubscriptionTransactions.lastWhere(
            (element) => element.productIdentifier == product.identifier);
        purchaseVerified = DateTime.parse(thisTransaction.purchaseDate)
                .minute
                .compareTo(DateTime.now().minute) ==
            0;
      });

      debugPrint(
          '[RC PURCHASE API: PRODUCT PURCHASE] PURCHASE VERIFIED: $purchaseVerified\nPURCHASER INFO: ${customerInfo.allPurchasedProductIdentifiers}');

      if (purchaseVerified && isCredits) {
        // int currentPurchCredits = userDatabase.get('purchCredits');
        int addCredits = int.parse(product.identifier.split('_')[0]);
        Functions.processCredits(true,
            creditsToAdd: addCredits, isPurchased: true);
        // userDatabase.put('purchCredits', currentPurchCredits + addCredits);

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
              '[RC PURCHASE API: PRODUCT PURCHASE] ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE (ECWID_STORE_API): $e ^^^^^');
        }

        productOrdersList.insert(
            0,
            Order(
                orderDate: DateTime.now(),
                orderId: 'REVCAT${thisTransaction.revenueCatIdentifier}',
                orderIdExtended: '',
                userName: thisUser.lastUserId,
                userId: thisUser.userId,
                productId: product.identifier,
                productName: product.title.replaceAll('($appTitle)', ''),
                productOptions: 'No Options',
                productDescription: product.description,
                productPrice: product.priceString,
                productImageUrl: '',
                customerName: '',
                customerId: thisUser.userId,
                customerPhone: '',
                customerShippingAddress: '',
                customerEmail: ''));

        userDatabase.put('ecwidProductOrdersList',
            orderDetailListToJson(OrderDetailList(orders: productOrdersList)));
      } else {
        debugPrint('[PRODUCT PURCHASE] PURCHASE WAS NOT VERIFIED');
      }
      debugPrint('[PRODUCT PURCHASE] IN-APP PURCHASE COMPLETE');
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
    // UserProfile thisUser = await AppUser.getUserProfile();
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[RC PURCHASE API PACKAGE PURCHASE] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[RC PURCHASE API PACKAGE PURCHASE] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    final Package localPackage = packageToPurchase;
    logger.i(localPackage.packageType.name);

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    try {
      debugPrint(
          '[RC PURCHASE API PACKAGE PURCHASE] PROCESSING IN-APP PACKAGE PURCHASE...');
      customerInfo = await Purchases.purchasePackage(packageToPurchase);
      bool isSubscribed =
          customerInfo.entitlements.all['all_features'].isActive;

      // bool isPremium = customerInfo.entitlements.all['all_features'].isActive;
      debugPrint(
          '[RC PURCHASE API PACKAGE PURCHASE] ${customerInfo.activeSubscriptions}');
      if (isSubscribed) {
        /// GRANT PREMIUM STATUS AND LOG PREMIUM ID TO DATABASE
        // userDatabase.put('userIsPremium', true);
        UserStatus.grantPremium();
        // userDatabase.put('userIsSubscribed', true);

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
                userName: thisUser.lastUserId,
                userId: thisUser.userId,
                productId: packageToPurchase.storeProduct.identifier,
                productName:
                    'Start of ${packageToPurchase.storeProduct.title.replaceAll('($appTitle)', '')}',
                productOptions: 'No Options',
                productDescription: packageToPurchase.storeProduct.description,
                productPrice: packageToPurchase.storeProduct.priceString,
                productImageUrl: '',
                customerName: '',
                customerId: thisUser.userId,
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
