import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:congress_watcher/app_user/user_profile.dart';

import '../constants/constants.dart';

class UserStatus {
  static Future<void> grantPremium() async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    // UserProfile thisUser = await AppUser.getUserProfile();
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[USER STATUS GRAND PREMIUM] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[USER STATUS GRANT PREMIUM] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    if (!thisUser.premiumStatus) {
      userDatabase.put('userIsPremium', true);
      await AppUser.buildUserProfile(updateStripeServer: true);
      // !thisUser.revenueCatIapAvailable
      //     ? await StripeApi.updateStripeCustomer(forceUpdate: true)
      //     : null;
    }

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
          'BACKUP SUBS HAVE BEEN ADDED TO CURRENT SUBS: $localCurrentSubscriptions');
    }

    logger.d('USER IS UPGRADED');
  }

  static Future<void> removePremium() async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    // UserProfile thisUser = await AppUser.getUserProfile();
    UserProfile thisUser;
    try {
      thisUser = userProfileFromJson(userDatabase.get('userProfile'));
      debugPrint(
          '[USER STATUS REMOVE PREMIUM] USER PROFILE RETRIEVED FROM DBASE: ${thisUser.userId}');
    } catch (e) {
      debugPrint(
          '[USER STATUS REMOVE PREMIUM] ERROR RETRIEVING USER PROFILE FROM DBASE');
    }

    List<String> localCurrentSubscriptions =
        List.from(userDatabase.get('subscriptionAlertsList'));

    if (localCurrentSubscriptions.isNotEmpty) {
      await userDatabase.put(
          'subscriptionAlertsListBackup', localCurrentSubscriptions);

      userDatabase.put('subscriptionAlertsList', []);
      userDatabase.put('memberAlerts', false);
      // userDatabase.put('billAlerts', false);
      userDatabase.put('lobbyingAlerts', false);
      userDatabase.put('privateFundedTripsAlerts', false);
      userDatabase.put('stockWatchAlerts', false);

      debugPrint(
          'USER IS NOT UPGRADED. ANY CURRENT SUBS HAVE BEEN BACKED UP: ${List.from(userDatabase.get('subscriptionAlertsListBackup'))}');
    }

    if (thisUser.premiumStatus) {
      userDatabase.put('userIsPremium', false);
      await AppUser.buildUserProfile(updateStripeServer: true);
      // !thisUser.revenueCatIapAvailable
      //     ? await StripeApi.updateStripeCustomer(forceUpdate: true)
      //     : null;
    }

    logger.d('USER IS DOWNGRADED');
  }
}
