import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:congress_watcher/services/stripe/stripe_api.dart';
import '../constants/constants.dart';
import '../functions/functions.dart';

class AppUser {
  static final Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  static final bool stripeTestMode = userDatabase.get('stripeTestMode');
  static final bool googleTestMode = userDatabase.get('googleTestMode');
  static final bool amazonTestMode = userDatabase.get('amazonTestMode');
  static final bool testing = userDatabase.get('stripeTestMode') ||
      userDatabase.get('googleTestMode') ||
      userDatabase.get('amazonTestMode');

  static Future<UserProfile> initialize() async {
    UserProfile userProfile = await buildUserProfile();
    return userProfile;
  }

  static Future<UserProfile> buildUserProfile(
      {bool updateStripeServer = false}) async {
    UserPackageInfo packageInfo;
    UserDeviceInfo deviceInfo;

    await DeviceInfoPlugin().androidInfo.then((info) => deviceInfo =
        UserDeviceInfo(
            vendorName: info.manufacturer,
            id: info.id,
            deviceName: info.device,
            deviceModel: info.model,
            isPhysicalDevice: info.isPhysicalDevice,
            brand: info.brand,
            hardware: info.hardware,
            product: info.product,
            tags: info.tags,
            type: info.type,
            host: info.host,
            versionCodeName: info.version.codename,
            versionRelease: info.version.release,
            securityPatch: info.version.securityPatch,
            baseOS: info.version.baseOS));

    await PackageInfo.fromPlatform().then((info) {
      bool rcIapAvailable = info.installerStore != null &&
              (info.installerStore
                      .toLowerCase()
                      .contains(googleInstallerStoreExample) ||
                  info.installerStore
                      .toLowerCase()
                      .contains(amazonInstallerStoreExample))
          // || packageInfo.installerStore.contains('samsung')
          ;

      String installerStoreLink = dotenv.env["developerWebLink"];
      if (info.installerStore != null) {
        installerStoreLink =
            info.installerStore.contains(googleInstallerStoreExample)
                ? googleAppLink
                : info.installerStore.contains(amazonInstallerStoreExample)
                    ? amazonAppLink
                    : info.installerStore.contains(samsungInstallerStoreExample)
                        ? samsungAppLink
                        : dotenv.env["developerWebLink"];
      }

      debugPrint(
          '[USER PROFILE] INSTALLER STORE INFO: Store => ${info.installerStore}, Link => $installerStoreLink, IAP Available? $rcIapAvailable');

      packageInfo = UserPackageInfo(
          appName: info.appName,
          packageName: info.packageName,
          version: info.version,
          buildNumber: info.buildNumber,
          buildSignature: info.buildSignature,
          installerStore: info.installerStore ?? 'unknown',
          installerStoreLink: installerStoreLink,
          rcIapAvailable: rcIapAvailable);

      userDatabase.put('packageInfo', packageInfo.toJson());
    });

    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<String> userIdList = List<String>.from(userDatabase.get('userIdList'));
    String firstUserId = userIdList
        .firstWhere(
            (element) => element.split('<|:|>')[0].toLowerCase() == 'newuser')
        .split('<|:|>')[1];

    String latestUserId = userIdList.last.split('<|:|>')[1];

    List<String> emailList =
        List<String>.from(userDatabase.get('userEmailList'));
    List<String> emails = emailList.map((e) => e.split('<|:|>').first).toList();

    List<String> revenuecatCustomerIdList = List.from(userDatabase.get(
            googleTestMode || amazonTestMode
                ? 'revenuecatTestCustomerIdList'
                : 'revenuecatCustomerIdList')) ??
        [];
    debugPrint(
        '[USER PROFILE] CURRENT RC CUSTOMER ID LIST $revenuecatCustomerIdList');

    List<String> stripeCustomerIdList = List.from(userDatabase.get(
            stripeTestMode
                ? 'stripeTestCustomerIdList'
                : 'stripeCustomerIdList')) ??
        [];
    debugPrint(
        '[USER PROFILE] CURRENT STRIPE CUSTOMER ID LIST $stripeCustomerIdList');

    DateTime now = DateTime.now();
    DateTime lastSeen =
        DateTime.parse(userDatabase.get('lastRefresh') ?? DateTime.now());

    UserAddress currentLocation = UserAddress(
        street: '',
        city: '',
        state: '',
        country: '',
        zip: '',
        latitude: 0,
        longitude: 0);
    try {
      currentLocation =
          UserAddress.fromJson(userDatabase.get('currentLocation'));
      debugPrint('[USER PROFILE] CURRENT LOCATION SUCCESSFULLY RETRIEVED');
    } catch (e) {
      debugPrint('[USER PROFILE] CURRENT LOCATION RETRIEVAL ERROR: $e');
      // userDatabase.put('currentLocation', address.toJson());
    }

    UserAddress userAddress = UserAddress(
        street: '',
        city: '',
        state: '',
        country: '',
        zip: '',
        latitude: 0,
        longitude: 0);
    try {
      userAddress = UserAddress.fromJson(userDatabase.get('userAddress'));
      debugPrint('[USER PROFILE] ADDRESS SUCCESSFULLY RETRIEVED');
    } catch (e) {
      debugPrint('[USER PROFILE] ADDRESS RETRIEVAL ERROR: $e');
      // userDatabase.put('userAddress', address.toJson());
    }

    UserAddress representativesLocation = UserAddress(
        street: '',
        city: '',
        state: '',
        country: '',
        zip: '',
        latitude: 0,
        longitude: 0);
    try {
      representativesLocation =
          UserAddress.fromJson(userDatabase.get('representativesLocation'));
      debugPrint(
          '[USER PROFILE] REPRESENTATIVES LOCATION SUCCESSFULLY RETRIEVED');
    } catch (e) {
      debugPrint('[USER PROFILE] REPRESENTATIVES LOCATION RETRIEVAL ERROR: $e');
      // userDatabase.put('representativesLocation', representativesLocation.toJson());
    }

    UserProfile thisUser = UserProfile(
      dataLastRetrieved: now,
      userIdList: userIdList,
      userId: firstUserId,
      lastUserId: latestUserId,
      lastSeen: lastSeen,
      emails: emails,
      currentLocation: currentLocation,
      address: userAddress,
      representativesLocation: representativesLocation,
      packageInfo: packageInfo,
      deviceInfo: deviceInfo,
      premiumStatus: userIsPremium,
      developerStatus: userIsDev,
      legacyStatus: userIsLegacy,
      devUpgraded: userDatabase.get('devUpgraded'),
      appOpens: userDatabase.get('appOpens'),
      darkTheme: userDatabase.get('darkTheme'),
      grapeTheme: userDatabase.get('grapeTheme'),
      appRated: userDatabase.get('appRated'),
      temporaryCredits: userDatabase.get('credits'),
      supportCredits: userDatabase.get('permCredits'),
      purchasedCredits: userDatabase.get('purchCredits'),
      usageInfoGranted: userDatabase.get('usageInfo'),
      freeTrialUsed: userDatabase.get('freeTrialUsed'),
      installerStore: stripeTestMode
          ? 'Stripe Test [Unknown]'
          : googleTestMode
              ? googleInstallerStoreExample
              : amazonTestMode
                  ? amazonInstallerStoreExample
                  : packageInfo.installerStore,
      installerStoreLink: stripeTestMode
          ? dotenv.env["developerWebLink"]
          : googleTestMode
              ? googleAppLink
              : amazonTestMode
                  ? amazonAppLink
                  : packageInfo.installerStoreLink,
      revenueCatIapAvailable: stripeTestMode
          ? false
          : googleTestMode || amazonTestMode
              ? true
              : packageInfo.rcIapAvailable,
      revenueCatCustomerIdList: revenuecatCustomerIdList,
      stripeCustomerIdList: stripeCustomerIdList,
    );

    debugPrint(
        '[USER PROFILE] RETURNING USER PROFILE: ${userProfileToJson(thisUser).toString()}');

    try {
      userDatabase.put('userProfile', userProfileToJson(thisUser));
      debugPrint('[USER PROFILE] UPDATED USER PROFILE SAVED TO DBASE');
    } catch (e) {
      debugPrint('[USER PROFILE] ERROR SAVING USER PROFILE TO DBASE: $e');
      // userDatabase.put('userProfile', {});
    }

    /// IF STRIPE CUSTOMER, UPDATE STRIPE SERVER DATA
    if (!thisUser.revenueCatIapAvailable && updateStripeServer) {
      await StripeApi.updateStripeCustomer(forceUpdate: updateStripeServer);

      debugPrint(
          '[USER PROFILE] UPDATED USER PROFILE ALSO SAVED TO STRIPE SERVER');
    }

    return thisUser;
  }
}

UserProfile userProfileFromJson(String str) =>
    UserProfile.fromJson(json.decode(str));
String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  UserProfile({
    @required this.dataLastRetrieved,
    @required this.userIdList,
    @required this.userId,
    @required this.lastUserId,
    @required this.lastSeen,
    @required this.emails,
    @required this.currentLocation,
    @required this.address,
    @required this.representativesLocation,
    @required this.packageInfo,
    @required this.deviceInfo,
    @required this.premiumStatus,
    @required this.developerStatus,
    @required this.legacyStatus,
    @required this.devUpgraded,
    @required this.appOpens,
    @required this.darkTheme,
    @required this.grapeTheme,
    @required this.appRated,
    @required this.temporaryCredits,
    @required this.supportCredits,
    @required this.purchasedCredits,
    @required this.usageInfoGranted,
    @required this.freeTrialUsed,
    @required this.installerStore,
    @required this.installerStoreLink,
    @required this.revenueCatIapAvailable,
    @required this.revenueCatCustomerIdList,
    @required this.stripeCustomerIdList,
  });

  final DateTime dataLastRetrieved;
  final List<String> userIdList;
  final String userId;
  final String lastUserId;
  final DateTime lastSeen;
  final List<String> emails;
  final UserAddress currentLocation;
  final UserAddress address;
  final UserAddress representativesLocation;
  final UserPackageInfo packageInfo;
  final UserDeviceInfo deviceInfo;
  final bool premiumStatus;
  final bool developerStatus;
  final bool legacyStatus;
  final bool devUpgraded;
  final int appOpens;
  final bool darkTheme;
  final bool grapeTheme;
  final bool appRated;
  final int temporaryCredits;
  final int supportCredits;
  final int purchasedCredits;
  final bool usageInfoGranted;
  final bool freeTrialUsed;
  final String installerStore;
  final String installerStoreLink;
  final bool revenueCatIapAvailable;
  final List<String> revenueCatCustomerIdList;
  final List<String> stripeCustomerIdList;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        dataLastRetrieved: json["data_last_retrieved"] == null
            ? DateTime.now()
            : DateTime.parse(json["data_last_retrieved"]),
        userIdList: List<String>.from(json["user_id_list"].map((x) => x)),
        userId: json["user_id"],
        lastUserId: json["last_user_id"],
        lastSeen: json["last_seen"] == null
            ? DateTime.now()
            : DateTime.parse(json["last_seen"]),
        emails: List<String>.from(json["emails"].map((x) => x)),
        currentLocation: UserAddress.fromJson(json["current_location"]),
        address: UserAddress.fromJson(json["address"]),
        representativesLocation:
            UserAddress.fromJson(json["representatives_location"]),
        packageInfo: UserPackageInfo.fromJson(json["package_info"]),
        deviceInfo: UserDeviceInfo.fromJson(json["device_info"]),
        premiumStatus: json["premium_status"],
        developerStatus: json["developer_status"],
        legacyStatus: json["legacy_status"],
        devUpgraded: json['dev_upgraded'],
        appOpens: json["app_opens"],
        darkTheme: json["dark_theme"],
        grapeTheme: json["grape_theme"],
        appRated: json["app_rated"],
        temporaryCredits: json["temporary_credits"],
        supportCredits: json["support_credits"],
        purchasedCredits: json["purchased_credits"],
        usageInfoGranted: json["usage_info_granted"],
        freeTrialUsed: json["free_trial_used"],
        installerStore: json["installer_store"],
        installerStoreLink: json["installer_store_link"],
        revenueCatIapAvailable: json["revenuecat_iap_available"],
        revenueCatCustomerIdList: List<String>.from(
            json["revenuecat_customer_id_list"].map((x) => x)),
        stripeCustomerIdList:
            List<String>.from(json["stripe_customer_id_list"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "data_last_retrieved": dataLastRetrieved.toIso8601String(),
        "user_id_list": List<String>.from(userIdList.map((x) => x)),
        "user_id": userId,
        "last_user_id": lastUserId,
        "last_seen": lastSeen.toIso8601String(),
        "emails": List<String>.from(emails.map((x) => x)),
        "current_location": currentLocation.toJson(),
        "address": address.toJson(),
        "representatives_location": representativesLocation.toJson(),
        "package_info": packageInfo.toJson(),
        "device_info": deviceInfo.toJson(),
        "premium_status": premiumStatus,
        "developer_status": developerStatus,
        "legacy_status": legacyStatus,
        "dev_upgraded": devUpgraded,
        "app_opens": appOpens,
        "dark_theme": darkTheme,
        "grape_theme": grapeTheme,
        "app_rated": appRated,
        "temporary_credits": temporaryCredits,
        "support_credits": supportCredits,
        "purchased_credits": purchasedCredits,
        "usage_info_granted": usageInfoGranted,
        "free_trial_used": freeTrialUsed,
        "installer_store": installerStore,
        "installer_store_link": installerStoreLink,
        "revenuecat_iap_available": revenueCatIapAvailable,
        "revenuecat_customer_id_list": revenueCatCustomerIdList,
        "stripe_customer_id_list": stripeCustomerIdList,
      };
}

class UserAddress {
  UserAddress({
    @required this.street,
    @required this.city,
    @required this.state,
    @required this.country,
    @required this.zip,
    @required this.latitude,
    @required this.longitude,
  });

  final String street;
  final String city;
  final String state;
  final String country;
  final String zip;
  final double latitude;
  final double longitude;

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
      street: json["street"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      zip: json["zip"],
      latitude: json["latitude"],
      longitude: json["longitude"]);

  Map<String, dynamic> toJson() => {
        "street": street,
        "city": city,
        "state": state,
        "country": country,
        "zip": zip,
        "latitude": latitude,
        "longitude": longitude,
      };

  // @override
  // String toString() =>
  //     "User Address: $street, $city, $state, $zip, $country ($latitude : $longitude)";
}

class UserPackageInfo {
  UserPackageInfo({
    @required this.appName,
    @required this.packageName,
    @required this.version,
    @required this.buildNumber,
    @required this.buildSignature,
    @required this.installerStore,
    @required this.installerStoreLink,
    @required this.rcIapAvailable,
  });

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String buildSignature;
  final String installerStore;
  final String installerStoreLink;
  final bool rcIapAvailable;

  factory UserPackageInfo.fromJson(Map<String, dynamic> json) =>
      UserPackageInfo(
          appName: json["app_name"],
          packageName: json["package_name"],
          version: json["version"],
          buildNumber: json["build_number"],
          buildSignature: json["build_signature"],
          installerStore: json["installer_store"],
          installerStoreLink: json["installer_store_link"],
          rcIapAvailable: json["rc_iap_available"]);

  Map<String, dynamic> toJson() => {
        "app_name": appName,
        "package_name": packageName,
        "version": version,
        "build_number": buildNumber,
        "build_signature": buildSignature,
        "installer_store": installerStore,
        "rc_iap_available": rcIapAvailable,
      };
}

class UserDeviceInfo {
  UserDeviceInfo({
    @required this.vendorName,
    @required this.id,
    @required this.deviceName,
    @required this.deviceModel,
    @required this.isPhysicalDevice,
    @required this.brand,
    @required this.hardware,
    @required this.product,
    @required this.tags,
    @required this.type,
    @required this.host,
    @required this.versionCodeName,
    @required this.versionRelease,
    @required this.securityPatch,
    @required this.baseOS,
  });

  final String vendorName;
  final String id;
  final String deviceName;
  final String deviceModel;
  final bool isPhysicalDevice;
  final String brand;
  final String hardware;
  final String product;
  final String tags;
  final String type;
  final String host;
  final String versionCodeName;
  final String versionRelease;
  final String securityPatch;
  final String baseOS;

  factory UserDeviceInfo.fromJson(Map<String, dynamic> json) => UserDeviceInfo(
        vendorName: json["vendor_name"],
        id: json["id"],
        deviceName: json["device_name"],
        deviceModel: json["device_model"],
        isPhysicalDevice: json["is_physical_device"],
        brand: json["brand"],
        hardware: json["hardware"],
        product: json["product"],
        tags: json["tags"],
        type: json["type"],
        host: json["host"],
        versionCodeName: json["version_code_name"],
        versionRelease: json["version_release"],
        securityPatch: json["security_patch"],
        baseOS: json["base_os"],
      );

  Map<String, dynamic> toJson() => {
        "vendor_name": vendorName,
        "id": id,
        "device_name": deviceName,
        "device_model": deviceModel,
        "is_physical_device": isPhysicalDevice,
        "brand": brand,
        "hardware": hardware,
        "product": product,
        "tags": tags,
        "type": type,
        "host": host,
        "version_code_name": versionCodeName,
        "version_release": versionRelease,
        "security_patch": securityPatch,
        "base_os": baseOS,
      };
}

class UserLocationInfo {
  UserLocationInfo({
    @required this.latitude,
    @required this.longitude,
    @required this.speed,
    @required this.speedAccuracy,
    @required this.timestamp,
    @required this.isMock,
    @required this.heading,
    @required this.accuracy,
    @required this.altitude,
    @required this.floor,
  });

  final double latitude;
  final double longitude;
  final double speed;
  final double speedAccuracy;
  final DateTime timestamp;
  final bool isMock;
  final double heading;
  final double accuracy;
  final double altitude;
  final int floor;

  factory UserLocationInfo.fromJson(Map<String, dynamic> json) =>
      UserLocationInfo(
        latitude: json["latitude"],
        longitude: json["longitude"],
        speed: json["speed"],
        speedAccuracy: json["speed_accuracy"],
        timestamp: json["timestamp"],
        isMock: json["is_mock"],
        heading: json["heading"],
        accuracy: json["accuracy"],
        altitude: json["altitude"],
        floor: json["floor"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "speed": speed,
        "speed_accuracy": speedAccuracy,
        "timestamp": timestamp,
        "is_mock": latitude,
        "heading": longitude,
        "accuracy": longitude,
        "altitude": altitude,
        "floor": floor,
      };
}
