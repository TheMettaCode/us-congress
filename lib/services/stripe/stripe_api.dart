import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show HttpHeaders, Platform;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:congress_watcher/services/stripe/stripe_models/checkout_sessions.dart';
import 'package:congress_watcher/services/stripe/stripe_models/customer.dart';
import 'package:congress_watcher/services/stripe/stripe_models/product.dart';
import 'package:congress_watcher/services/stripe/stripe_purchase_page.dart';
import '../../app_user/user_profile.dart';
import '../../constants/constants.dart';
import '../../functions/functions.dart';
import '../../app_user/user_status.dart';
import '../../models/order_detail.dart';

class StripeApi {
  static final Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  static final bool stripeTestMode = userDatabase.get('stripeTestMode');
  static final bool googleTestMode = userDatabase.get('googleTestMode');
  static final bool amazonTestMode = userDatabase.get('amazonTestMode');
  static final bool testing = userDatabase.get('stripeTestMode') ||
      userDatabase.get('googleTestMode') ||
      userDatabase.get('amazonTestMode');
  static final String stripeSecretApiKey = dotenv
      .env[stripeTestMode ? "STRIPE_SECRET_TEST_KEY" : "STRIPE_SECRET_KEY"];

  static Future<void> stripePlatformInit() async {
    debugPrint('[STRIPE API INIT] CONFIGURING STRIPE DETAILS');

    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[STRIPE API INIT] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint('[STRIPE API INIT] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    if (Platform.isAndroid) {
      StripeCustomer currentStripeCustomer;
      bool newCustomerCreated = false;

      try {
        currentStripeCustomer = stripeCustomerFromJson(userDatabase
            .get(stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer'));
        debugPrint(
            '[STRIPE API INIT] ${stripeTestMode ? 'TEST' : ''} CUSTOMER RETRIEVED FROM DBASE: ${currentStripeCustomer.id}');
      } catch (e) {
        debugPrint(
            '[STRIPE API INIT] ERROR RETRIEVING STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER FROM DBASE: $e');
      }

      if (currentStripeCustomer == null) {
        try {
          currentStripeCustomer = await updateStripeCustomer();
          newCustomerCreated = true;
          debugPrint(
              '[STRIPE API INIT] ${stripeTestMode ? 'TEST' : ''} NEW CUSTOMER CREATED: ${currentStripeCustomer.id}');
        } catch (e) {
          debugPrint(
              '[STRIPE API INIT] ERROR CREATING NEW STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER: $e');
        }
      }

      if (currentStripeCustomer != null && !newCustomerCreated) {
        await getSubscriptionStatus(currentStripeCustomer);
      }

      await getAllStripeProducts();
    }
  }
  // else if (Platform.isIOS) {
  //   configuration = PurchasesConfiguration("public_ios_sdk_key")..appUserID = rootUserId;
  // }

  /// UPDATE OR CREATE NEW STRIPE CUSTOMER
  static Future<StripeCustomer> updateStripeCustomer(
      {
      // String stripeCustomerIdToUpdate = '',
      StripeCustomer customer,
      bool forceUpdate = false,
      // bool forceCreateNew = false,
      String name = '',
      String address = '',
      String description = ''}) async {
    StripeCustomer currentStripeCustomer;

    if (customer != null) {
      currentStripeCustomer = customer;
    } else {
      try {
        currentStripeCustomer = stripeCustomerFromJson(userDatabase
            .get(stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer'));
        debugPrint(
            '[STRIPE API CUSTOMER UPDATE] ${stripeTestMode ? 'TEST' : ''} CUSTOMER RETRIEVED FROM DBASE: ${currentStripeCustomer.id}');
      } catch (e) {
        debugPrint(
            '[STRIPE API CUSTOMER UPDATE] ERROR RETRIEVING STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER FROM DBASE: $e');
      }
    }

    // UserProfile thisUser = await AppUser.getUserProfile();
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[STRIPE API CUSTOMER UPDATE] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[STRIPE API CUSTOMER UPDATE] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    bool appUserIsNew = currentStripeCustomer == null && thisUser.appOpens <= 2;
    bool appUpdatedToStripeVersion =
        currentStripeCustomer == null && thisUser.appOpens > 2;
    bool updatingUserInfo = forceUpdate ||
        // stripeCustomerIdToUpdate.isNotEmpty ||
        (currentStripeCustomer != null &&
            (name.isNotEmpty || address.isNotEmpty || description.isNotEmpty));

    debugPrint(
        '[STRIPE API CUSTOMER UPDATE] APP USER IS NEW ? $appUserIsNew - APP UPGRADED TO STRIPE ? $appUpdatedToStripeVersion - UPDATING USER INFO? $updatingUserInfo... FORCED? $forceUpdate');

    if (appUserIsNew || appUpdatedToStripeVersion || updatingUserInfo) {
      var dio = Dio();

      final String stripeCustomerUrl = appUserIsNew || appUpdatedToStripeVersion
          ? 'https://api.stripe.com/v1/customers'
          : updatingUserInfo
              ? 'https://api.stripe.com/v1/customers/${currentStripeCustomer.id}'
              : null;

      final headers = {
        // "Accept": "application/json",
        HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
        // "X-Platform": "stripe",
        HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
      };

      final data = <String, dynamic>{
        // "expand[]": "subscriptions.data",
        "metadata[app_user_id]": thisUser.userId,
        "metadata[app_version]":
            "${thisUser.packageInfo.version} : ${thisUser.packageInfo.buildNumber}",
        "metadata[user_status]": thisUser.premiumStatus ? "premium" : "free",
        "metadata[installer_store]": thisUser.installerStore ?? "unknown",
        "metadata[total_credits]": thisUser.temporaryCredits +
            thisUser.supportCredits +
            thisUser.purchasedCredits,
        "metadata[app_opens]": thisUser.appOpens,
        "metadata[app_rated]": thisUser.appRated,
        "metadata[theme]": thisUser.darkTheme
            ? "dark"
            : thisUser.grapeTheme
                ? "grape"
                : "default",
        "metadata[app_zone]": thisUser.address.zip ?? "",
        "metadata[free_trial_used]": thisUser.freeTrialUsed,
        "metadata[dev_upgraded]": thisUser.devUpgraded,
        "metadata[last_seen]": thisUser.lastSeen,
        "name": updatingUserInfo && name.isNotEmpty
            ? name
            : appUserIsNew
                ? "New $appTitle App User ${thisUser.lastUserId}"
                : appUpdatedToStripeVersion
                    ? 'Stripe Updated $appTitle App User'
                    : currentStripeCustomer.name ?? "",
        "email": thisUser.emails.isNotEmpty
            ? thisUser.emails.last
            : currentStripeCustomer == null
                ? ""
                : currentStripeCustomer.email ?? "",
        "description": updatingUserInfo && description.isNotEmpty
            ? description
            : appUserIsNew || appUpdatedToStripeVersion
                ? "$appTitle App"
                : currentStripeCustomer.description ?? "",
      };

      if (stripeCustomerUrl != null) {
        try {
          final response = await dio.post(stripeCustomerUrl,
              queryParameters: data,
              options: Options(
                  headers: headers,
                  contentType: Headers.formUrlEncodedContentType));

          if (response.statusCode == 200) {
            debugPrint(
                '[STRIPE API CUSTOMER UPDATE] ${stripeTestMode ? 'TEST' : ''} CUSTOMER RETRIEVAL RESPONSE DATA: ${response.data}');

            try {
              userDatabase.put(
                  stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer',
                  jsonEncode(response.data));
              userDatabase.put(
                  'lastStripeCustomerRefresh', '${DateTime.now()}');
              debugPrint(
                  '[STRIPE API CUSTOMER UPDATE] NEW STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER SAVED TO DBASE');
            } catch (e) {
              debugPrint(
                  '[STRIPE API CUSTOMER UPDATE] ERROR SAVING STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER TO DBASE: $e');
            }

            debugPrint(
                '[STRIPE API CUSTOMER UPDATE] EXTRACTING ${stripeTestMode ? 'TEST' : ''} CUSTOMER FROM JSON');
            final thisStripeCustomer =
                stripeCustomerFromJson(jsonEncode(response.data));

            List<String> stripeCustomerIdList = List.from(userDatabase.get(
                    stripeTestMode
                        ? 'stripeTestCustomerIdList'
                        : 'stripeCustomerIdList')) ??
                [];

            if (!stripeCustomerIdList.contains(thisStripeCustomer.id)) {
              stripeCustomerIdList.insert(0, thisStripeCustomer.id);
              userDatabase.put(
                  stripeTestMode
                      ? 'stripeTestCustomerIdList'
                      : 'stripeCustomerIdList',
                  stripeCustomerIdList);
            }

            debugPrint(
                '[STRIPE API CUSTOMER UPDATE] RETURNING NEW ${stripeTestMode ? 'TEST' : ''} CUSTOMER DATA');
            return thisStripeCustomer;
          } else {
            debugPrint(
                '[STRIPE API CUSTOMER UPDATE] ${stripeTestMode ? 'TEST' : ''} CUSTOMER NOT CREATED: STATUS CODE = ${response.statusCode}');
            return currentStripeCustomer;
          }
        } catch (e) {
          debugPrint(
              '[STRIPE API CUSTOMER UPDATE] ${stripeTestMode ? 'TEST' : ''} CUSTOMER CREATE ERROR: $e');
          return currentStripeCustomer;
        }
      } else {
        debugPrint(
            '[STRIPE API CUSTOMER UPDATE] ${stripeTestMode ? 'TEST' : ''} CUSTOMER UPDATE URL IS NULL');
        return currentStripeCustomer;
      }
    } else {
      debugPrint(
          '[STRIPE API CUSTOMER UPDATE] CUSTOMER HAS ALREADY BEEN CREATED AND IS CURRENT: ${currentStripeCustomer.id}');
      return currentStripeCustomer;
    }
  }

  static Future<StripeCustomer> retrieveAndStoreLatestStripeCustomerFromServer(
    String stripeCustomerId,
  ) async {
    /// RETRIEVE STRIPE CUSTOMER INFORMATION
    var dio = Dio();

    final String getCustomerUrl =
        'https://api.stripe.com/v1/customers/$stripeCustomerId';

    final headers = {
      // "Accept": "application/json",
      HttpHeaders.contentTypeHeader:
          "application/x-www-form-urlencoded", // "application/json",
      // "X-Platform": "stripe",
      HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
    };

    // final body = <String, dynamic>{"expand[]": "subscriptions.data"};

    bool missingCustomerError = false;

    Response customerResponse = await dio
        .get(getCustomerUrl,
            // queryParameters: body,
            options: Options(
                receiveDataWhenStatusError: true,
                headers: headers,
                contentType: Headers.formUrlEncodedContentType))
        .catchError((err) async {
      if (err is DioError) {
        debugPrint(
            '[STRIPE API CUSTOMER RETRIEVAL ERROR] Status Code: ${err.response.statusCode}\n[STRIPE API CUSTOMER RETRIEVAL ERROR] Response: ${err.response.data}');
        if (err.response.statusCode == 404) {
          missingCustomerError = true;
        }
      }
    });

    if (customerResponse != null && customerResponse.statusCode == 200) {
      debugPrint(
          '[STRIPE API CUSTOMER RETRIEVAL] ${stripeTestMode ? 'TEST' : ''} CUSTOMER RETRIEVED: ${customerResponse.data}');

      try {
        userDatabase.put(
            stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer',
            jsonEncode(customerResponse.data));
        userDatabase.put('lastStripeCustomerRefresh', '${DateTime.now()}');
        debugPrint(
            '[STRIPE API CUSTOMER RETRIEVAL] RETRIEVED STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER SAVED TO DBASE');
      } catch (e) {
        debugPrint(
            '[STRIPE API CUSTOMER RETRIEVAL] ERROR SAVING RETRIEVED ${stripeTestMode ? 'TEST' : ''} STRIPE CUSTOMER TO DBASE: $e');
      }

      return stripeCustomerFromJson(jsonEncode(customerResponse.data));
    } else if (missingCustomerError) {
      debugPrint(
          '[STRIPE API CUSTOMER MISSING] ${stripeTestMode ? 'TEST' : ''} CUSTOMER MISSING OR REMOVED. CREATING NEW ${stripeTestMode ? 'TEST' : ''} CUSTOMER...');
      // final StripeCustomer thisNewCustomer =
      userDatabase
          .put(stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer', {});
      return await updateStripeCustomer();
      // return thisNewCustomer;
    } else {
      debugPrint(
          '[STRIPE API CUSTOMER RETRIEVAL] ${stripeTestMode ? 'TEST' : ''} CUSTOMER RETRIEVAL API CALL ERROR: ${customerResponse.statusCode}');
      return null;
    }
  }

  static Future<StripeCustomer> swapStripeServerAccounts(
      String newCustomerId, String oldCustomerId,
      {bool deleteOldFromServer = false}) async {
    /// RETRIEVE STRIPE CUSTOMER INFORMATION
    var dio = Dio();

    final String newCustomerUrl =
        'https://api.stripe.com/v1/customers/$newCustomerId';

    final String oldCustomerUrl =
        'https://api.stripe.com/v1/customers/$oldCustomerId';

    final headers = {
      // "Accept": "application/json",
      HttpHeaders.contentTypeHeader:
          "application/x-www-form-urlencoded", // "application/json",
      // "X-Platform": "stripe",
      HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
    };

    Response oldCustomerResponse = await dio.get(oldCustomerUrl,
        // queryParameters: body,
        options: Options(
            receiveDataWhenStatusError: true,
            headers: headers,
            contentType: Headers.formUrlEncodedContentType));

    if (oldCustomerResponse.statusCode == 200) {
      StripeCustomer oldCustomer =
          stripeCustomerFromJson(jsonEncode(oldCustomerResponse.data));

      final newCustomerUpdateData = <String, dynamic>{
        "metadata[app_opens]": oldCustomer.metadata.appOpens,
        "metadata[app_rated]": oldCustomer.metadata.appRated,
        "metadata[app_user_id]": oldCustomer.metadata.appUserId,
        "metadata[app_version]": oldCustomer.metadata.appVersion,
        "metadata[app_zone]": oldCustomer.metadata.appZone,
        "metadata[dev_upgraded]": oldCustomer.metadata.devUpgraded,
        "metadata[free_trial_used]": oldCustomer.metadata.freeTrialUsed,
        "metadata[installer_store]": oldCustomer.metadata.installerStore,
        "metadata[total_credits]": oldCustomer.metadata.totalCredits,
        "metadata[user_status]": oldCustomer.metadata.userStatus,
      };

      Response newCustomerResponse = await dio.post(newCustomerUrl,
          queryParameters: newCustomerUpdateData,
          options: Options(
              receiveDataWhenStatusError: true,
              headers: headers,
              contentType: Headers.formUrlEncodedContentType));

      if (newCustomerResponse.statusCode == 200) {
        debugPrint(
            '[STRIPE API SWAP STRIPE ACCOUNTS] NEW AND OLD ${stripeTestMode ? 'TEST' : ''} CUSTOMERS RETRIEVED: NEW => ${newCustomerResponse.data["id"]} & OLD => ${oldCustomerResponse.data["id"]}');

        try {
          userDatabase.put(
              stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer',
              jsonEncode(newCustomerResponse.data));

          userDatabase.put('lastStripeCustomerRefresh', '${DateTime.now()}');
          debugPrint(
              '[STRIPE API SWAP STRIPE ACCOUNTS] RETRIEVED STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER SAVED TO DBASE');
        } catch (e) {
          debugPrint(
              '[STRIPE API SWAP STRIPE ACCOUNTS] ERROR SAVING RETRIEVED ${stripeTestMode ? 'TEST' : ''} STRIPE CUSTOMER TO DBASE: $e');
        }

        /// DELETE OLD ACCOUNT FROM SERVER IS SWAPPING
        if (deleteOldFromServer) {
          // final String deleteCustomerUrl =
          //     'https://api.stripe.com/v1/customers/$oldCustomerId';

          final deleteCustomerResponse = await dio.delete(oldCustomerUrl,
              options: Options(
                  headers: headers,
                  contentType: Headers.formUrlEncodedContentType));
          debugPrint(
              '[STRIPE API SWAP STRIPE ACCOUNTS CUSTOMER DELETION] ${stripeTestMode ? 'TEST' : ''} CUSTOMER DELETION RESPONSE: ${oldCustomerResponse.data}');

          if (deleteCustomerResponse.statusCode == 200) {
            debugPrint(
                '[STRIPE API SWAP STRIPE ACCOUNTS CUSTOMER DELETION] ${stripeTestMode ? 'TEST' : ''} CUSTOMER DELETED: ${oldCustomerResponse.data}');
          }
        }

        return stripeCustomerFromJson(jsonEncode(newCustomerResponse.data));
      } else {
        debugPrint(
            '[STRIPE API SWAP STRIPE ACCOUNTS] ${stripeTestMode ? 'TEST' : ''} CUSTOMER RETRIEVAL API CALL ERROR:\n[STRIPE API SWAP STRIPE ACCOUNTS] ${stripeTestMode ? 'TEST' : ''} NEW CUSTOMER STATUS CODE: ${newCustomerResponse.statusCode}');
        return null;
      }
    } else {
      debugPrint(
          '[STRIPE API SWAP STRIPE ACCOUNTS] ${stripeTestMode ? 'TEST' : ''} CUSTOMER RETRIEVAL API CALL ERROR:\n[STRIPE API SWAP STRIPE ACCOUNTS] ${stripeTestMode ? 'TEST' : ''} OLD CUSTOMER STATUS CODE: ${oldCustomerResponse.statusCode}');
      return null;
    }
  }

  /// RETRIEVE ALL AVAILABLE STRIPE PRODUCTS AND SUBSCRIPTIONS
  static Future<List<StripeProduct>> getAllStripeProducts() async {
    List<StripeProduct> currentStripeProductsList = [];

    try {
      List<StripeProduct> unsortedCurrentStripeProductsList =
          stripeProductsListFromJson(userDatabase.get(stripeTestMode
                  ? 'stripeTestProductsList'
                  : 'stripeProductsList'))
              .products;

      currentStripeProductsList = unsortedCurrentStripeProductsList;
    } catch (e) {
      debugPrint(
          '[STRIPE API] ERROR RETRIEVING STRIPE ${stripeTestMode ? 'TEST' : ''} PRODUCTS FROM DBASE: $e');
      userDatabase.put(
          stripeTestMode ? 'stripeTestProductsList' : 'stripeProductsList', {});
    }

    if (stripeTestMode ||
        currentStripeProductsList.isEmpty ||
        DateTime.parse(userDatabase.get('lastStripeProductsRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
      var dio = Dio();

      const String productListUrl = 'https://api.stripe.com/v1/products';

      final headers = {
        // "Accept": "application/json",
        HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
        // "X-Platform": "stripe",
        HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
      };

      final data = <String, dynamic>{"active": true};

      try {
        final response = await dio.get(productListUrl,
            queryParameters: data,
            options: Options(
                headers: headers,
                contentType: Headers.formUrlEncodedContentType));

        if (response.statusCode == 200) {
          debugPrint(
              '[STRIPE API] ${stripeTestMode ? 'TEST' : ''} PRODUCT RETRIEVAL RESPONSE DATA: ${response.data}');

          try {
            userDatabase.put(
                stripeTestMode
                    ? 'stripeTestProductsList'
                    : 'stripeProductsList',
                jsonEncode(response.data));
            debugPrint(
                '[STRIPE API] NEW STRIPE ${stripeTestMode ? 'TEST' : ''} PRODUCTS SAVED TO DBASE');
          } catch (e) {
            debugPrint(
                '[STRIPE API] ERROR SAVING STRIPE ${stripeTestMode ? 'TEST' : ''} PRODUCTS TO DBASE: $e');
            userDatabase.put(
                stripeTestMode
                    ? 'stripeTestProductsList'
                    : 'stripeProductsList',
                {});
          }

          debugPrint(
              '[STRIPE API] EXTRACTING ${stripeTestMode ? 'TEST' : ''} PRODUCTS FROM JSON');
          final stripeProductsList =
              stripeProductsListFromJson(jsonEncode(response.data));

          userDatabase.put('lastStripeProductsRefresh', '${DateTime.now()}');

          debugPrint(
              '[STRIPE API] SORTING ${stripeTestMode ? 'TEST' : ''} PRODUCTS LIST');
          List<StripeProduct> finalProductsList = stripeProductsList.products;

          debugPrint(
              '[STRIPE API] RETURNING ${stripeTestMode ? 'TEST' : ''} PRODUCTS LIST');
          return finalProductsList;
        } else {
          debugPrint(
              '[STRIPE API] STRIPE ${stripeTestMode ? 'TEST' : ''} PRODUCTS API ERROR: STATUS CODE = ${response.statusCode}');
          return currentStripeProductsList.isNotEmpty
              ? currentStripeProductsList
              : [];
        }
      } catch (e) {
        debugPrint(
            '[STRIPE API] ${stripeTestMode ? 'TEST' : ''} PRODUCTS RETRIEVAL ERROR: $e');
        return currentStripeProductsList.isNotEmpty
            ? currentStripeProductsList
            : [];
      }
    } else {
      debugPrint(
          '[STRIPE API] ${stripeTestMode ? 'TEST' : ''} PRODUCTS ALREADY RETRIEVED: ${currentStripeProductsList.map((e) => e.name)}');
      return currentStripeProductsList;
    }
  }

  static Future<StripeProduct> getSingleStripeProduct(String productId) async {
    /// RETRIEVE STRIPE PRODUCT INFORMATION
    var dio = Dio();

    final String productUrl = "https://api.stripe.com/v1/products/$productId";

    final headers = {
      // "Accept": "application/json",
      HttpHeaders.contentTypeHeader:
          "application/x-www-form-urlencoded", // "application/json",
      // "X-Platform": "stripe",
      HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
    };

    final productResponse = await dio.get(productUrl,
        // queryParameters: body,
        options: Options(
            headers: headers, contentType: Headers.formUrlEncodedContentType));
    debugPrint(
        '[STRIPE API GET SINGLE PRODUCT] ${stripeTestMode ? 'TEST' : ''} PRODUCT RETRIEVAL RESPONSE: ${productResponse.data}');

    if (productResponse.statusCode == 200) {
      debugPrint(
          '[STRIPE API GET SINGLE PRODUCT] ${stripeTestMode ? 'TEST' : ''} PRODUCT FOUND: ${productResponse.data}');
      final StripeProduct thisProduct =
          stripeProductFromJson(jsonEncode(productResponse.data));
      return thisProduct;
    } else {
      debugPrint(
          '[STRIPE API GET SINGLE PRODUCT] ${stripeTestMode ? 'TEST' : ''} PRODUCT RETRIEVAL API CALL ERROR: ${productResponse.statusCode}');
      return null;
    }
  }

  // static Future<List<SubscriptionsDatum>> getAllStripeSubscriptions(
  //     {String productId = ''}) async {
  //   /// RETRIEVE STRIPE CUSTOMER SUBSCRIPTIONS
  //   var dio = Dio();

  //   const String subscriptionsUrl = "https://api.stripe.com/v1/subscriptions";

  //   final headers = {
  //     // "Accept": "application/json",
  //     HttpHeaders.contentTypeHeader:
  //         "application/x-www-form-urlencoded", // "application/json",
  //     // "X-Platform": "stripe",
  //     HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
  //   };

  //   final data = <String, dynamic>{
  //     "expand[]": "data.customer",
  //     "expand[]": "data.latest_invoice",
  //   };

  //   final subscriptionsResponse = await dio.get(subscriptionsUrl,
  //       queryParameters: data,
  //       options: Options(
  //           headers: headers, contentType: Headers.formUrlEncodedContentType));
  //   debugPrint(
  //       '[STRIPE API GET SUBSCRIPTIONS] ${stripeTestMode ? 'TEST' : ''} SUBSCRIPTIONS RETRIEVAL RESPONSE: ${subscriptionsResponse.data}');

  //   if (subscriptionsResponse.statusCode == 200) {
  //     debugPrint(
  //         '[STRIPE API GET SUBSCRIPTIONS] ${stripeTestMode ? 'TEST' : ''} SUBSCRIPTIONS FOUND: ${subscriptionsResponse.data}');
  //     final StripeSubscriptions subscriptions =
  //         stripeSubscriptionsFromJson(jsonEncode(subscriptionsResponse));
  //     final List<SubscriptionsDatum> subscriptionsDatum = subscriptions.data;

  //     if (subscriptionsDatum.isNotEmpty && productId.isNotEmpty) {
  //       return subscriptionsDatum
  //               .where((element) => element.plan.product == productId)
  //               .toList() ??
  //           [];
  //     } else {
  //       return subscriptionsDatum;
  //     }
  //   } else {
  //     debugPrint(
  //         '[STRIPE API GET SUBSCRIPTIONS] ${stripeTestMode ? 'TEST' : ''} SUBSCRIPTIONS RETRIEVAL API CALL ERROR: ${subscriptionsResponse.statusCode}');
  //     return null;
  //   }
  // }

  /// GET RECENT CHECKOUT SESSIONS
  static Future<List<CheckoutSessionsDatum>> getRecentCheckoutSessions({
    String stripeCustomerId = '',
  }) async {
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[STRIPE API PURCHASE ATTEMPT] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[STRIPE API PURCHASE ATTEMPT] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    // final String customerId = stripeCustomerId.isNotEmpty
    //     ? stripeCustomerId
    //     : stripeCustomerFromJson(userDatabase
    //             .get(stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer'))
    //         .id;

    var dio = Dio();

    const String checkoutSessionsUrl =
        "https://api.stripe.com/v1/checkout/sessions";

    final headers = {
      // "Accept": "application/json",
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      // "X-Platform": "stripe",
      HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
    };

    // final data = <String, dynamic>{
    //   "limit": 50,
    //   // "expand[]": "data.customer",
    //   // "expand[]": "data.invoice",
    //   // "expand[]": "data.subscription",
    // };

    try {
      final checkoutSessionsResponse = await dio.get(checkoutSessionsUrl,
          // queryParameters: data,
          options: Options(
              headers: headers,
              contentType: Headers.formUrlEncodedContentType));

      if (checkoutSessionsResponse.statusCode == 200) {
        debugPrint(
            '[STRIPE API GET CHECKOUT SESSIONS] ${stripeTestMode ? 'TEST' : ''} CUSTOMER CHECKOUT SESSIONS RESPONSE DATA : ${checkoutSessionsResponse.data}');

        // try {
        //   userDatabase.put('stripeChargesList', jsonEncode(chargesResponse.data));
        // } catch (e) {
        //   debugPrint('[STRIPE API GET CHECKOUT SESSIONS] ERROR SAVING STRIPE CHECKOUT SESSIONS TO DBASE: $e');
        //   userDatabase.put('stripeChargesList', {});
        // }

        final checkoutSessions =
            checkoutSessionsFromJson(jsonEncode(checkoutSessionsResponse.data));

        List<CheckoutSessionsDatum> stripeCheckoutSessionsList =
            checkoutSessions.data;

        debugPrint(
            '[STRIPE API GET CHECKOUT SESSIONS] SAMPLE CHECKOUT SESSION DATA:\n'
            '[STRIPE API GET ${stripeTestMode ? 'TEST' : ''} CHECKOUT SESSIONS] Customer => ${stripeCheckoutSessionsList.first.customer}\n'
            '[STRIPE API GET ${stripeTestMode ? 'TEST' : ''} CHECKOUT SESSIONS] Status => ${stripeCheckoutSessionsList.first.status}\n'
            '[STRIPE API GET ${stripeTestMode ? 'TEST' : ''} CHECKOUT SESSIONS] Metadata => ${stripeCheckoutSessionsList.first.metadata.toJson().toString()}\n'
            '[STRIPE API GET ${stripeTestMode ? 'TEST' : ''} CHECKOUT SESSIONS] Client Ref ID => ${stripeCheckoutSessionsList.first.clientReferenceId}');

        stripeCheckoutSessionsList.retainWhere((element) =>
            // element.clientReferenceId == customerId ||
            element.clientReferenceId == thisUser.userId ||
            element.metadata.appUserId == thisUser.userId);
        debugPrint(
            '[STRIPE API GET CHECKOUT SESSIONS] ${stripeCheckoutSessionsList.length} CHECKOUT SESSION RETURNED');

        return stripeCheckoutSessionsList;
      } else {
        debugPrint(
            '[STRIPE API GET CHECKOUT SESSIONS] NO ${stripeTestMode ? 'TEST' : ''} CHECKOUT SESSIONS FOUND: STATUS CODE = ${checkoutSessionsResponse.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint(
          '[STRIPE API GET CHECKOUT SESSIONS] ${stripeTestMode ? 'TEST' : ''} CHECKOUT SESSIONS RETRIEVAL ERROR: $e');
      return [];
    }
  }

  // /// GET RECENT STRIPE CHARGES
  // static Future<List<StripeCharges>> getRecentStripeCharges({
  //   String stripeCustomerId = '',
  //   /*DateTime chargeTime, String productId = '', String productAmount = ''*/
  // }) async {
  //   // UserProfile thisUser = await AppUser.getUserProfile();
  //
  //   // List<StripeCharges> currentStripeChargesList = [];
  //   //
  //   // try {
  //   //   currentStripeChargesList = stripeChargeFromJson(userDatabase.get('stripeChargesList')).data;
  //   // } catch (e) {
  //   //   debugPrint('[STRIPE API] ERROR RETRIEVING STRIPE CHARGES FROM DBASE: $e');
  //   // }
  //
  //   var dio = Dio();
  //
  //   const String chargesUrl = "https://api.stripe.com/v1/charges";
  //
  //   final headers = {
  //     // "Accept": "application/json",
  //     HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
  //     // "X-Platform": "stripe",
  //     HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
  //   };
  //
  //   final String customerId = stripeCustomerId.isNotEmpty
  //       ? stripeCustomerId
  //       : stripeCustomerFromJson(userDatabase.get('stripeCustomer')).id;
  //
  //   // final data = <String, dynamic>{
  //   //   "expand[]": "customer",
  //   // };
  //
  //   try {
  //     final chargesResponse = await dio.get(chargesUrl,
  //         // queryParameters: data,
  //         options: Options(headers: headers, contentType: Headers.formUrlEncodedContentType));
  //
  //     if (chargesResponse.statusCode == 200) {
  //       debugPrint('[STRIPE API] CUSTOMER CHARGES RESPONSE DATA : ${chargesResponse.data}');
  //
  //       try {
  //         userDatabase.put('stripeChargesList', jsonEncode(chargesResponse.data));
  //       } catch (e) {
  //         debugPrint('[STRIPE API] ERROR SAVING STRIPE CHARGES TO DBASE: $e');
  //         // userDatabase.put('stripeChargesList', {});
  //       }
  //
  //       final stripeCharges = stripeChargeFromJson(jsonEncode(chargesResponse.data));
  //
  //       List<StripeCharges> stripeChargesList = stripeCharges.data;
  //
  //       // debugPrint('[STRIPE API PURCHASE VERIFICATION] SAMPLE PRODUCT DATA:\n'
  //       //     '[STRIPE API PURCHASE VERIFICATION] Customer => ${stripeChargesList.first.customer}\n'
  //       //     '[STRIPE API PURCHASE VERIFICATION] Status => ${stripeChargesList.first.status}\n'
  //       //     '[STRIPE API PURCHASE VERIFICATION] Paid => ${stripeChargesList.first.paid}\n'
  //       //     '[STRIPE API PURCHASE VERIFICATION] Refunded => ${stripeChargesList.first.refunded}');
  //
  //       stripeChargesList.retainWhere((element) => element.customer == customerId);
  //
  //       return stripeChargesList;
  //     } else {
  //       debugPrint('[STRIPE API] NO CHARGES FOUND: STATUS CODE = ${chargesResponse.statusCode}');
  //       return [];
  //     }
  //   } catch (e) {
  //     debugPrint('[STRIPE API] CHARGES RETRIEVAL ERROR: $e');
  //     return [];
  //   }
  // }

  // /// SEARCH (FOR) CUSTOMER'S INVOICES
  // static Future<List<InvoiceSearchDatum>> searchStripeInvoices({
  //   String stripeProductId = '',
  //   int stripeProductPrice = 0,
  // }) async {
  //   bool productDataIncluded =
  //       stripeProductId.isNotEmpty && stripeProductPrice > 0;

  //   /// GET USER INFORMATION
  //   UserProfile thisUser;
  //   try {
  //     thisUser = userProfileFromJson(userDatabase.get('userProfile'));
  //     debugPrint(
  //         '[STRIPE API INVOICE SEARCH] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
  //   } catch (e) {
  //     debugPrint(
  //         '[STRIPE API INVOICE SEARCH] ERROR RETRIEVING USER PROFILE FROM DBASE');
  //   }

  //   StripeCustomer currentStripeCustomer;
  //   try {
  //     currentStripeCustomer = stripeCustomerFromJson(userDatabase
  //         .get(stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer'));
  //   } catch (e) {
  //     debugPrint(
  //         '[STRIPE API INVOICE SEARCH] ERROR RETRIEVING STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER FROM DBASE: $e');
  //   }

  //   List<InvoiceSearchDatum> lastStripeSearchInvoicesList = [];

  //   try {
  //     lastStripeSearchInvoicesList = stripeInvoiceSearchFromJson(
  //             userDatabase.get('lastStripeSearchInvoicesList'))
  //         .invoicesList;
  //   } catch (e) {
  //     debugPrint(
  //         '[STRIPE API INVOICE SEARCH] ERROR RETRIEVING STRIPE ${stripeTestMode ? 'TEST' : ''} INVOICE(S) LIST FROM DBASE: $e');
  //   }

  //   var dio = Dio();

  //   final String invoiceSearchUrl = productDataIncluded
  //       // ? "https://api.stripe.com/v1/invoices/search?query=customer:'${currentStripeCustomer.id}' AND total:$stripeProductPrice"
  //       ? "https://api.stripe.com/v1/invoices/search?query=total:$stripeProductPrice"
  //       : "https://api.stripe.com/v1/invoices/search?query=customer:'${currentStripeCustomer.id}'";

  //   final headers = {
  //     // "Accept": "application/json",
  //     HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
  //     // "X-Platform": "stripe",
  //     HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
  //   };

  //   final data = <String, dynamic>{
  //     "expand[]": "data.customer",
  //     "expand[]": "data.charge",
  //     "expand[]": "data.subscription",
  //   };

  //   try {
  //     final response = await dio
  //         .get(invoiceSearchUrl,
  //             queryParameters: data,
  //             options: Options(
  //                 headers: headers,
  //                 contentType: Headers.formUrlEncodedContentType))
  //         .catchError((err) async {
  //       if (err is DioError) {
  //         debugPrint(
  //             '[STRIPE API INVOICE SEARCH DIO ERROR] Status Code: ${err.response.statusCode}\n[STRIPE API INVOICE SEARCH DIO ERROR] Response: ${err.response.data}');
  //       }
  //     });

  //     if (response.statusCode == 200) {
  //       debugPrint(
  //           '[STRIPE API INVOICE SEARCH] CUSTOMER ${stripeTestMode ? 'TEST' : ''} INVOICE(S) RETRIEVAL RESPONSE DATA FOR ${currentStripeCustomer.id.toUpperCase()}: ${response.data}');

  //       try {
  //         userDatabase.put('lastStripeSearchInvoicesList',
  //             stripeInvoiceSearchToJson(response.data));
  //       } catch (e) {
  //         debugPrint(
  //             '[STRIPE API INVOICE SEARCH] ERROR SAVING STRIPE ${stripeTestMode ? 'TEST' : ''} INVOICE(S) TO DBASE: $e');
  //         userDatabase.put('lastStripeSearchInvoicesList', {});
  //       }

  //       return stripeInvoiceSearchFromJson(jsonEncode(response.data))
  //           .invoicesList;
  //     } else {
  //       debugPrint(
  //           '[STRIPE API INVOICE SEARCH] NO INVOICE(S) ${stripeTestMode ? 'TEST' : ''} INVOICES FOUND: STATUS CODE = ${response.statusCode}');
  //       return lastStripeSearchInvoicesList.isNotEmpty
  //           ? lastStripeSearchInvoicesList
  //           : [];
  //     }
  //   } catch (e) {
  //     debugPrint(
  //         '[STRIPE API INVOICE SEARCH] ${stripeTestMode ? 'TEST' : ''} INVOICE(S) RETRIEVAL ERROR: $e');
  //     return lastStripeSearchInvoicesList.isNotEmpty
  //         ? lastStripeSearchInvoicesList
  //         : [];
  //   }
  // }

  /// USE STRIPE TO PURCHASE PRODUCT OR PACKAGE
  static Future<void> purchaseWithStripe(
    BuildContext context,
    // Box userDatabase,
    String stripeProductId,
  ) async {
    debugPrint(
        '[STRIPE API PURCHASE ATTEMPT] STRIPE ${stripeTestMode ? 'TEST' : ''} ITEM ID RECEIVED: $stripeProductId');

    // UserProfile thisUser = await AppUser.getUserProfile();
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[STRIPE API PURCHASE ATTEMPT] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[STRIPE API PURCHASE ATTEMPT] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    StripeProduct thisStripeProduct =
        await getSingleStripeProduct(stripeProductId);
    // bool isSubscription = thisStripeProduct.metadata.productType.contains('subscription');

    // String thisStripeProductPaymentLink =
    await createStripePaymentLink(thisUser, thisStripeProduct).then(
        (stripePaymentLink) => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StripePurchasePage(
                      thisStripeUser: thisUser,
                      thisStripeProduct: thisStripeProduct,
                      thisStripePaymentLink: stripePaymentLink,
                    ))).then((_) async => stripeProductId.isNotEmpty
            ? await StripeApi.verifyStripeNoCodePayment(
                DateTime.now(), stripeProductId)
            : null));
  }

  static Future<String> createStripePaymentLink(
      UserProfile thisUser, StripeProduct stripeProduct) async {
    /// CREATE PURCHASE PAYMENT LINK
    var dio = Dio();

    const String createPaymentLinkUrl =
        "https://api.stripe.com/v1/payment_links";

    // final String stripeCustomerId = stripeCustomerFromJson(userDatabase
    //         .get(stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer'))
    //     .id;

    final bool isSubscription =
        stripeProduct.metadata.productType.contains('subscription');

    final headers = {
      // "Accept": "application/json",
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      // "X-Platform": "stripe",
      HttpHeaders.authorizationHeader: "Bearer $stripeSecretApiKey",
    };

    final subscriptionData = <String, dynamic>{
      "line_items[0][price]": stripeProduct.defaultPrice,
      "line_items[0][quantity]": 1,
      "metadata[app_user_id]": thisUser.userId,
      "metadata[app_version]":
          "${thisUser.packageInfo.version} : ${thisUser.packageInfo.buildNumber}",
      "metadata[stripe_customer_id]":
          thisUser.stripeCustomerIdList.map((e) => e).toString(),
    };

    final productData = <String, dynamic>{
      "line_items[0][price]": stripeProduct.defaultPrice,
      "line_items[0][quantity]": 1,
      "metadata[app_user_id]": thisUser.userId,
      "metadata[app_version]":
          "${thisUser.packageInfo.version} : ${thisUser.packageInfo.buildNumber}",
      "metadata[stripe_customer_id]":
          thisUser.stripeCustomerIdList.map((e) => e).toString(),
    };

    final data = isSubscription ? subscriptionData : productData;

    final paymentLinkResponse = await dio.post(createPaymentLinkUrl,
        queryParameters: data,
        options: Options(
            headers: headers, contentType: Headers.formUrlEncodedContentType));
    debugPrint(
        '[STRIPE API CREATE PAYMENT LINK] PAYMENT LINK RESPONSE: ${paymentLinkResponse.data}');

    if (paymentLinkResponse.statusCode == 200) {
      final String rootPaymentLink = paymentLinkResponse.data['url'];
      debugPrint(
          '[STRIPE API CREATE PAYMENT LINK] PAYMENT LINK ROOT: $rootPaymentLink');
      final String customerPaymentLink =
          "$rootPaymentLink?client_reference_id=${thisUser.userId}";
      debugPrint(
          '[STRIPE API CREATE PAYMENT LINK] PAYMENT LINK RETURNED: $customerPaymentLink');
      // return rootPaymentLink;
      return customerPaymentLink;
    } else {
      debugPrint(
          '[STRIPE API CREATE PAYMENT LINK] CREATE PAYMENT LINK API CALL ERROR: ${paymentLinkResponse.statusCode}');
      return null;
    }
  }

  /// VERIFICATION METHOD => https://stripe.com/docs/api/payment_intents/search?lang=curl
  static Future<bool> verifyStripeNoCodePayment(
      DateTime purchaseAttemptTime, String stripeProductId,
      {bool isDevTest = false}) async {
    /// GET USER INFORMATION
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[STRIPE API PURCHASE VERIFICATION] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[STRIPE API PURCHASE VERIFICATION] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    StripeCustomer currentStripeCustomer;

    try {
      currentStripeCustomer = stripeCustomerFromJson(userDatabase
          .get(stripeTestMode ? 'stripeTestCustomer' : 'stripeCustomer'));
      debugPrint(
          '[STRIPE API PURCHASE VERIFICATION] STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER RETRIEVED FROM DBASE: ${currentStripeCustomer.id}');
    } catch (e) {
      debugPrint(
          '[STRIPE API PURCHASE VERIFICATION] ERROR RETRIEVING STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER FROM DBASE: $e');
    }

    /// RETRIEVE PRODUCT INFORMATION
    final StripeProduct thisProduct =
        await getSingleStripeProduct(stripeProductId);

    final bool thisProductIsSubscription =
        thisProduct.metadata.productType.contains('subscription');

    /// RETRIEVE RECENT CHECKOUT SESSIONS
    List<CheckoutSessionsDatum> checkoutSessionsList =
        await getRecentCheckoutSessions();
    debugPrint(
        '[STRIPE API PURCHASE VERIFICATION] ${checkoutSessionsList.length} CHECKOUT SESSIONS RECEIVED');

    /// SET PURCHASE TIMEFRAME

    DateTime now = DateTime.now();

    final int nowUnixTimestampSeconds =
        now.toUtc().millisecondsSinceEpoch ~/ 1000;

    // final int purchaseAttemptUnixTimestamp =
    //     purchaseAttemptTime.toUtc().millisecondsSinceEpoch ~/ 1000;

    debugPrint(
        '[STRIPE API PURCHASE VERIFICATION] ${stripeTestMode ? 'TEST' : ''} NOW DATETIME = ${dateWithTimeAndSecondsFormatter.format(purchaseAttemptTime)}. CONVERTED = $nowUnixTimestampSeconds');

    final DateTime verificationWindowTimeframe = now.subtract(const Duration(
        minutes: stripePurchaseVerificationWindowMinutes)); // 5 minutes

    final int verificationWindowUnixTimestamp =
        verificationWindowTimeframe.toUtc().millisecondsSinceEpoch ~/ 1000;

    debugPrint(
        '[STRIPE API PURCHASE VERIFICATION] ${stripeTestMode ? 'TEST' : ''} PURCHASE VERIFICATION WINDOW DATETIME = ${dateWithTimeAndSecondsFormatter.format(verificationWindowTimeframe)}. CONVERTED = $verificationWindowUnixTimestamp');

    checkoutSessionsList.retainWhere((session) =>
        session.amountSubtotal ==
            int.parse(thisProduct.metadata.productPrice) &&
        session.created < nowUnixTimestampSeconds &&
        session.created > verificationWindowUnixTimestamp);

    /// START PURCHASE VERIFICATION
    if (thisUser != null &&
        currentStripeCustomer != null &&
        thisProduct != null &&
        checkoutSessionsList.isNotEmpty) {
      debugPrint(
          '[STRIPE API PURCHASE VERIFICATION] THIS USER: ${thisUser.userId} - CURRENT STRIPE CUSTOMER: ${currentStripeCustomer.id} - THIS PRODUCT: ${thisProduct.name} - ${checkoutSessionsList.length} CHECKOUT SESSIONS - SUBSCRIPTION OR PRODUCT: ${thisProductIsSubscription ? 'SUBSCRIPTION' : 'PRODUCT'}');

      if (thisProductIsSubscription) {
        checkoutSessionsList.retainWhere((session) =>
            // session.customer != null &&
            session.mode == 'subscription');

        if (checkoutSessionsList.isNotEmpty) {
          debugPrint(
              '[STRIPE API SUBSCRIPTION VERIFICATION] ${checkoutSessionsList.length} ${stripeTestMode ? 'TEST' : ''} INVOICES REMAIN: ${checkoutSessionsList.map((ses) => 'CUST: ${ses.customer} => STATUS: ${ses.status} => PAYMENT STATUS ${ses.paymentStatus} => CREATED: ${ses.created}')}');

          final bool subscriptionIsValid = checkoutSessionsList.any((element) =>
              element.status == "complete" && element.paymentStatus == "paid");

          if (subscriptionIsValid) {
            final CheckoutSessionsDatum thisSession =
                checkoutSessionsList.firstWhere((_) => subscriptionIsValid);

            debugPrint(
                '[STRIPE API SUBSCRIPTION VERIFICATION] ${stripeTestMode ? 'TEST' : ''} SUBSCRIPTION PURCHASE VERIFIED');

            /// GRANT SUBSCRIPTION ACCESS HERE...
            await UserStatus.grantPremium();

            if (thisSession.customer != null &&
                thisSession.customer != currentStripeCustomer.id) {
              await swapStripeServerAccounts(
                  thisSession.customer, currentStripeCustomer.id,
                  deleteOldFromServer: testing ? false : true);
              // .then((_) async => await AppUser.buildUserProfile()
              //     .then((newUser) => thisUser = newUser));
            }

            if (!stripeTestMode) {
              /// UPDATE USER'S PRODUCT ORDERS LIST
              List<Order> productOrdersList = [];

              try {
                productOrdersList = orderDetailListFromJson(
                        userDatabase.get('ecwidProductOrdersList'))
                    .orders;
              } catch (e) {
                logger.w(
                    '[STRIPE API: SUBSCRIPTION VERIFICATION] ERROR RETRIEVING PAST ORDERS DATA FROM DBASE: $e ^^^^^');
              }

              productOrdersList.insert(
                  0,
                  Order(
                      orderDate: DateTime.now(),
                      orderId: 'STRP_${thisSession.subscription}',
                      orderIdExtended: '',
                      userName: thisUser.lastUserId,
                      userId: thisUser.userId,
                      productId: thisProduct.id,
                      productName: thisProduct.name,
                      productOptions: 'No Options',
                      productDescription: thisProduct.description,
                      productPrice:
                          '${double.parse(thisProduct.metadata.productPrice) / 100}',
                      productImageUrl: '',
                      customerName: '',
                      customerId: thisUser.userId,
                      customerPhone: '',
                      customerShippingAddress: '',
                      customerEmail: ''));

              userDatabase.put(
                  'ecwidProductOrdersList',
                  orderDetailListToJson(
                      OrderDetailList(orders: productOrdersList)));
            }

            return Future<bool>.value(true);
          } else {
            debugPrint(
                '[STRIPE API SUBSCRIPTION VERIFICATION] SUBSCRIPTION PURCHASE IS NOT VERIFIED');
            return Future<bool>.value(false);
          }
        } else {
          debugPrint(
              '[STRIPE API SUBSCRIPTION VERIFICATION] NO RECENT ${stripeTestMode ? 'TEST' : ''} SUBSCRIPTION FOUND FOR THIS CUSTOMER');
          return Future<bool>.value(false);
        }
      } else {
        if (!thisProductIsSubscription) {
          // if (checkoutSessionsList.isNotEmpty) {
          checkoutSessionsList
              .retainWhere((session) => session.mode != 'subscription'
                  // &&
                  // session.amountSubtotal ==
                  //     int.parse(thisProduct.metadata.productPrice)
                  );

          if (checkoutSessionsList.isNotEmpty) {
            debugPrint(
                '[STRIPE API PURCHASE VERIFICATION] ${checkoutSessionsList.length} ${stripeTestMode ? 'TEST' : ''} SESSIONS REMAIN: ${checkoutSessionsList.map((sess) => 'CUST: ${sess.customer} => CLIENT ID: ${sess.clientReferenceId} => CREATED: ${sess.created}')}');

            final bool purchaseIsValid = checkoutSessionsList.any((element) =>
                element.status == "complete" &&
                element.paymentStatus == "paid");

            if (purchaseIsValid) {
              final CheckoutSessionsDatum thisPurchase =
                  checkoutSessionsList.firstWhere((_) => purchaseIsValid);

              debugPrint(
                  '[STRIPE API PURCHASE VERIFICATION] ${stripeTestMode ? 'TEST' : ''} PRODUCT PURCHASE VERIFIED');

              if (thisProduct.metadata.entitlements == "all_features") {
                /// GRANT PRODUCT REWARDS HERE...
                UserStatus.grantPremium();
              } else if (int.parse(thisProduct.metadata.credits) > 0) {
                int addCredits = int.parse(thisProduct.metadata.credits);
                Functions.processCredits(true,
                    creditsToAdd: addCredits, isPurchased: true);
                await AppUser.buildUserProfile(updateStripeServer: true);
              }

              if (!stripeTestMode) {
                /// UPDATE USER'S PRODUCT ORDERS LIST
                List<Order> productOrdersList = [];

                try {
                  productOrdersList = orderDetailListFromJson(
                          userDatabase.get('ecwidProductOrdersList'))
                      .orders;
                } catch (e) {
                  logger.w(
                      '[STRIPE API: PURCHASE VERIFICATION] ERROR RETRIEVING PAST PRODUCT ORDERS DATA FROM DBASE: $e ^^^^^');
                }

                productOrdersList.insert(
                    0,
                    Order(
                        orderDate: DateTime.now(),
                        orderId: 'STRP_${thisPurchase.id}',
                        orderIdExtended: '',
                        userName: thisUser.lastUserId,
                        userId: thisUser.userId,
                        productId: thisProduct.id,
                        productName: thisProduct.name,
                        productOptions: 'No Options',
                        productDescription: thisProduct.description,
                        productPrice:
                            '${double.parse(thisProduct.metadata.productPrice) / 100}',
                        productImageUrl: '',
                        customerName: '',
                        customerId: thisUser.userId,
                        customerPhone: '',
                        customerShippingAddress: '',
                        customerEmail: ''));

                userDatabase.put(
                    'ecwidProductOrdersList',
                    orderDetailListToJson(
                        OrderDetailList(orders: productOrdersList)));
              }

              return Future<bool>.value(true);
            } else {
              debugPrint(
                  '[STRIPE API PURCHASE VERIFICATION] NO RECENT ${stripeTestMode ? 'TEST' : ''} PURCHASES FOUND MATCHING CUSTOMER DATA OR CRITERIA');
              return Future<bool>.value(false);
            }
          } else {
            debugPrint(
                '[STRIPE API SUBSCRIPTION VERIFICATION] NO RECENT ${stripeTestMode ? 'TEST' : ''} PURCHASE FOUND FOR THIS CUSTOMER');
            return Future<bool>.value(false);
          }
          // } else {
          //   debugPrint(
          //       '[STRIPE API PURCHASE VERIFICATION] NO RECENT ${stripeTestMode ? 'TEST' : ''} CHECKOUT SESSIONS FOUND FOR THIS CUSTOMER');
          //   return Future<bool>.value(false);
          // }
        } else {
          debugPrint(
              '[STRIPE API PURCHASE VERIFICATION] STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER INFO IS NULL OR NO ${stripeTestMode ? 'TEST' : ''} PRODUCT INFORMATION GIVEN TO VERIFY PURCHASE');
          return Future<bool>.value(false);
        }
      }
    } else {
      debugPrint(
          '[STRIPE API PURCHASE VERIFICATION] THERE DOESN\'T SEEM TO BE A VALID ${stripeTestMode ? 'TEST' : ''} PRODUCT OR ${stripeTestMode ? 'TEST' : ''} SUBSCRIPTION PURCHASE MADE');
      return Future<bool>.value(false);
    }
  }

  /// USED TO OBTAIN USER'S ACTIVE SUBSCRIPTIONS STATUS
  static Future<bool> getSubscriptionStatus(
      StripeCustomer currentStripeCustomer) async {
    // UserProfile thisUser = await AppUser.getUserProfile();
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[STRIPE API SUBSCRIPTION STATUS] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[STRIPE API SUBSCRIPTION STATUS] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    final DateTime freeTrialStartDate =
        DateTime.parse(userDatabase.get('freeTrialStartDate'));

    bool inFreeTrialPeriod = thisUser.premiumStatus &&
        thisUser.freeTrialUsed &&
        freeTrialStartDate.isAfter(DateTime.now()
            .subtract(Duration(days: freeTrialPromoDurationDays)));

    if (!thisUser.devUpgraded &&
        thisUser.appOpens > 2 &&
        !inFreeTrialPeriod &&
        currentStripeCustomer != null) {
      debugPrint(
          '[STRIPE API SUBSCRIPTION STATUS] STRIPE USER SUBSCRIPTION STATUS CHECK STARTED FOR ${stripeTestMode ? 'TEST' : ''} CUSTOMER ID ${currentStripeCustomer.id}...');

      StripeCustomer newlyRetrievedCustomer =
          await retrieveAndStoreLatestStripeCustomerFromServer(
              currentStripeCustomer.id);

      if (!thisUser.premiumStatus &&
          newlyRetrievedCustomer.metadata.userStatus.contains('premium')) {
        debugPrint(
            '[STRIPE API SUBSCRIPTION STATUS] UPGRADING USER TO PREMIUM STATUS');
        await UserStatus.grantPremium();
        return Future<bool>.value(true);
      } else if (thisUser.premiumStatus &&
          !newlyRetrievedCustomer.metadata.userStatus.contains('premium')) {
        debugPrint(
            '[STRIPE API SUBSCRIPTION STATUS] DOWNGRADING USER TO FREE STATUS');
        await UserStatus.removePremium();
        return Future<bool>.value(false);
      } else {
        debugPrint(
            '[STRIPE API SUBSCRIPTION STATUS] USER STATUS UNCHANGED: PREMIUM STATUS IS ${thisUser.premiumStatus}');
        return Future<bool>.value(thisUser.premiumStatus);
      }
    } else {
      debugPrint(
          '[STRIPE API SUBSCRIPTION STATUS] STRIPE ${stripeTestMode ? 'TEST' : ''} CUSTOMER IS ${currentStripeCustomer == null ? 'NULL' : currentStripeCustomer.id}\n[STRIPE API] USER IS DEV UPGRADED? ${thisUser.devUpgraded}\n[STRIPE API] APP OPENS: ${thisUser.appOpens}');

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
            '[STRIPE API SUBSCRIPTION STATUS] BACKUP SUBS HAVE BEEN ADDED TO CURRENT SUBS: $localCurrentSubscriptions');
      }
      debugPrint(
          '[STRIPE API SUBSCRIPTION STATUS] STRIPE USER SUBSCRIPTION STATUS CHECK COMPLETE. ${stripeTestMode ? 'TEST' : ''} CUSTOMER IS ${currentStripeCustomer.metadata.userStatus} STATUS'
              .toUpperCase());
      return Future<bool>.value(thisUser.premiumStatus);
    }
  }
}
