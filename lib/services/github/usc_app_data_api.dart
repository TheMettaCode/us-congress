import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../constants/constants.dart';
import '../../functions/functions.dart';
import '../../notifications_handler/notification_api.dart';
import 'usc_app_data_model.dart';

class GithubApi {
  static final Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  static final bool stripeTestMode = userDatabase.get('stripeTestMode');
  static final bool googleTestMode = userDatabase.get('googleTestMode');
  static final bool amazonTestMode = userDatabase.get('amazonTestMode');
  static final bool testing = userDatabase.get('stripeTestMode') ||
      userDatabase.get('googleTestMode') ||
      userDatabase.get('amazonTestMode');

  static Future<List<GithubNotifications>> getGithubNotifications(
      [BuildContext context]) async {
    bool appRated = userDatabase.get('appRated');

    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    String githubApiUserLevel = userIsDev
        ? "developer"
        : userIsPremium
            ? "premium"
            : userIsLegacy
                ? "legacy"
                : "free";

    final DateTime now = DateTime.now();

    final DateTime lastPromoNotification =
        DateTime.parse(userDatabase.get('lastPromoNotification'));

    logger.d(
        '[GITHUB NOTIFICATIONS API] LAST PROMO NOTIFICATION WAS: $lastPromoNotification');

    GithubData currentGithubData;
    List<GithubNotifications> currentGithubNotifications = [];

    try {
      currentGithubData = githubDataFromJson(userDatabase.get('githubData'));
      currentGithubNotifications = await pruneAndSortPromoNotifications(
          currentGithubData.notifications.toList(), githubApiUserLevel, now);
      logger.d(
          '[GITHUB NOTIFICATIONS API] CURRENT GITHUB DATA LOADED SUCCESSFULLY');
    } catch (e) {
      currentGithubNotifications = [];
      logger.d('[GITHUB NOTIFICATIONS API] CURRENT GITHUB DATA LOAD ERROR: $e');
    }

    List<GithubNotifications> newGithubNotifications = [];

    if (testing ||
        currentGithubNotifications.isEmpty ||
        lastPromoNotification.isBefore(now
            .subtract(const Duration(days: promoNotificationIntervalDays)))) {
      try {
        final Map headers = <String, String>{"Accept": "application/json"};
        final response = await http.get(
            Uri.parse(
                "https://themettacode.github.io/us-congress-app-data-api/cw-app-data.json"),
            headers: headers);
        logger.d(
            '[GITHUB NOTIFICATIONS API] GITHUB MSG API RESPONSE CODE: ${response.statusCode} *****');
        if (response.statusCode == 200) {
          GithubData githubData = githubDataFromJson(response.body);
          userDatabase.put('githubData', githubDataToJson(githubData));

          /// CHECK FOR CURRENT AND NEW NOTIFICATION DATA EQUALITY
          bool notificationListsAreEqual = listEquals<String>(
              githubData.notifications.map((e) => e.title).toList(),
              currentGithubNotifications.map((e) => e.title).toList());
          logger.d(
              "[GITHUB NOTIFICATIONS API] NEW & CURRENT NOTIFICATION LISTS ARE EQUAL? $notificationListsAreEqual");

          if (githubData.status == "OK" &&
              githubData.app == 'congress-watcher' &&
              !notificationListsAreEqual) {
            debugPrint('[GITHUB NOTIFICATIONS API] NEW GITHUB DATA RETRIEVED');
            List<GithubNotifications> rawGithubNotifications =
                githubData.notifications;

            /// CREATE LIST OF NOTIFICATIONS ADDED AFTER LAST UPDATE
            List<GithubNotifications> newNotifications = rawGithubNotifications
                    .where((notification) =>
                        notification.startDate.isAfter(lastPromoNotification) &&
                        notification.userLevels
                            .any((element) => element == githubApiUserLevel))
                    .toList() ??
                [];

            debugPrint(
                '[GITHUB NOTIFICATIONS API] ${newNotifications.length} NEW NOTIFICATIONS ADDED');

            /// PRUNE AND SORT
            List<GithubNotifications> sortedGithubNotifications =
                await pruneAndSortPromoNotifications(
                    rawGithubNotifications, githubApiUserLevel, now);

            if (appRated) {
              sortedGithubNotifications
                  .removeWhere((element) => element.additionalData == 'rating');
            }

            if (newGithubNotifications.isNotEmpty ||
                lastPromoNotification.isBefore(now.subtract(
                    const Duration(days: promoNotificationIntervalDays)))) {
              GithubNotifications thisPromotion =
                  newGithubNotifications.isNotEmpty
                      ? newNotifications.first
                      : sortedGithubNotifications[
                          random.nextInt(sortedGithubNotifications.length)];
              String title = thisPromotion.title;
              String messageBody = thisPromotion.message;
              String additionalData = thisPromotion.additionalData;

              if (context == null || !ModalRoute.of(context).isCurrent) {
                logger.d(
                    '[GITHUB NOTIFICATIONS API] SENDING NEW PROMO NOTIFICATION: $thisPromotion');

                await NotificationApi.showBigTextNotification(
                    0,
                    'promotions',
                    'App Promotions',
                    '$appTitle App Promotional Notifications',
                    'Just So You Know...',
                    title,
                    messageBody,
                    additionalData);
              }

              userDatabase.put(
                  'lastPromoNotification', DateTime.now().toIso8601String());
            }
            return sortedGithubNotifications;
          } else {
            logger.d(
                '[GITHUB NOTIFICATIONS API] CURRENT GITHUB MESSAGES ARE UP TO DATE');
            return currentGithubNotifications.isNotEmpty
                ? currentGithubNotifications
                : [];
          }
        } else {
          logger.d(
              '[GITHUB NOTIFICATIONS API] GITHUB MSG API CALL ERROR WITH RESPONSE CODE: ${response.statusCode}');
          return currentGithubNotifications.isNotEmpty
              ? currentGithubNotifications
              : []; // githubNotificationsPlaceholder;
        }
      } catch (e) {
        logger.d('[GITHUB NOTIFICATIONS API] GITHUB MSG API ERROR: $e');
        return currentGithubNotifications.isNotEmpty
            ? currentGithubNotifications
            : []; // githubNotificationsPlaceholder;
      }
    } else {
      logger.d(
          '[GITHUB NOTIFICATIONS API] CURRENT GITHUB PROMO NOTIFICATIONS LIST: ${currentGithubNotifications.map((e) => e.title)} *****');
      // newGithubNotifications = currentGithubNotifications;
      logger.d(
          '[GITHUB NOTIFICATIONS API] GITHUB PROMO NOTIFICATIONS LIST NOT UPDATED: LIST IS CURRENT *****');
      // userDatabase.put('lastGithubPromoNotificationsRefresh', '${DateTime.now()}');
      return currentGithubNotifications.isNotEmpty
          ? currentGithubNotifications
          : [];
    }
  }

  /// PRUNE AND SORT NOTIFICATIONS
  static Future<List<GithubNotifications>> pruneAndSortPromoNotifications(
      List<GithubNotifications> list,
      String githubApiUserLevel,
      DateTime now) async {
    logger.d(
        '[GITHUB NOTIFICATIONS API] [PRUNE & SORT] PRUNING ${list.length} GITHUB PROMO NOTIFICATIONS');

    list.retainWhere((element) =>
        element.startDate.isBefore(now) &&
        (element.expirationDate.toString().isEmpty ||
            element.expirationDate.isAfter(now)) &&
        element.userLevels.contains(githubApiUserLevel));

    // list.sort((a, b) =>
    //     a.startDate.compareTo(b.startDate).compareTo(a.priority.compareTo(b.priority)));

    list.sort((a, b) => a.priority.compareTo(b.priority));

    logger.d(
        '[GITHUB NOTIFICATIONS API] [PRUNE & SORT] ${list.length} GITHUB PROMO NOTIFICATIONS REMAIN');
    return list;
  }
}
