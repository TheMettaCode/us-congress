import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../constants/constants.dart';
import '../../functions/functions.dart';
import '../../notifications_handler/notification_api.dart';
import 'usc_app_data_model.dart';

class GithubApi {
  static Future<List<GithubNotifications>> getPromoMessages([BuildContext context]) async {
    Box userDatabase = Hive.box(appDatabase);
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

    debugPrint('LAST PROMO NOTIFICATION WAS: $lastPromoNotification');

    GithubData currentGithubData;
    List<GithubNotifications> currentGithubNotifications = [];
    bool newUserLevelMessagesRetrieved = false;

    try {
      currentGithubData = githubDataFromJson(userDatabase.get('githubData'));
      currentGithubNotifications = await pruneAndSortPromoNotifications(
          currentGithubData.notifications.toList(), githubApiUserLevel, now);
      debugPrint('***** CURRENT GITHUB DATA LOADED SUCCESSFULLY');
    } catch (e) {
      currentGithubNotifications = [];
      debugPrint('***** CURRENT GITHUB DATA LOAD ERROR: $e');
    }

    List<GithubNotifications> newGithubNotifications = [];

    if (currentGithubNotifications.isEmpty ||
        lastPromoNotification // DateTime.parse(userDatabase.get('lastGithubPromoNotificationsRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(hours: 4)))) {
      try {
        final Map headers = <String, String>{"Accept": "application/json"};
        final response = await http.get(
            Uri.parse("https://themettacode.github.io/us-congress-app-data-api/usc-app-data.json"),
            headers: headers);
        debugPrint('***** GITHUB MSG API RESPONSE CODE: ${response.statusCode} *****');
        if (response.statusCode == 200) {
          GithubData githubData = githubDataFromJson(response.body);
          userDatabase.put('githubData', githubDataToJson(githubData));

          /// CHECK FOR CURRENT AND NEW NOTIFICATION DATA EQUALITY
          bool notificationListsAreEqual = listEquals<String>(
              githubData.notifications.map((e) => e.title).toList(),
              currentGithubNotifications.map((e) => e.title).toList());
          debugPrint("^^^ NEW & CURRENT NOTIFICATION LISTS ARE EQUAL? $notificationListsAreEqual");

          if (githubData.status == "OK" &&
              githubData.app == 'us-congress' &&
              !notificationListsAreEqual) {
            debugPrint('***** NEW GITHUB DATA RETRIEVED');
            List<GithubNotifications> rawGithubNotifications = githubData.notifications;

            /// CREATE LIST OF NOTIFICATIONS ADDED AFTER LAST UPDATE
            List<GithubNotifications> newNotifications = rawGithubNotifications
                    .where((notification) => notification.startDate.isAfter(lastPromoNotification))
                    .toList() ??
                [];
            if (newNotifications.isNotEmpty) {
              debugPrint(
                  '^^^^^ ${newNotifications.length} NEW NOTIFICATIONS ADDED\n${newNotifications.map((e) => e.title)}');
            } else {
              debugPrint('^^^^^ ${newNotifications.length} NEW NOTIFICATIONS ADDED');
            }

            /// PRUNE AND SORT
            newGithubNotifications = await pruneAndSortPromoNotifications(
                rawGithubNotifications, githubApiUserLevel, now);

            if (appRated) {
              newGithubNotifications.removeWhere((element) => element.additionalData == 'rating');
            }

            /// SET 'NEW NOTIFICATIONS RETRIEVED' FLAG TO TRUE
            if (newNotifications.isNotEmpty &&
                newNotifications.any(
                    (item) => item.userLevels.any((element) => element == githubApiUserLevel))) {
              newUserLevelMessagesRetrieved = true;
            }
            // }

            currentGithubNotifications = newGithubNotifications;

            if (newGithubNotifications.isNotEmpty &&
                (newUserLevelMessagesRetrieved ||
                    lastPromoNotification.isBefore(now.subtract(const Duration(days: 3))))) {
              GithubNotifications thisPromotion = newUserLevelMessagesRetrieved
                  ? newNotifications.firstWhere(
                      (item) => item.userLevels.any((element) => element == githubApiUserLevel))
                  : newGithubNotifications[random.nextInt(newGithubNotifications.length)];
              String title = thisPromotion.title;
              String messageBody = thisPromotion.message;
              String additionalData = thisPromotion.additionalData;

              if (context == null || !ModalRoute.of(context).isCurrent) {
                debugPrint('SENDING NEW PROMO NOTIFICATION: $thisPromotion');

                await NotificationApi.showBigTextNotification(
                    0,
                    'promotions',
                    'App Promotions',
                    'US Congress App Promotional Notifications',
                    'Just So You Know...',
                    title,
                    messageBody,
                    additionalData);
              }

              //   for (var notification in newGithubNotifications) {
              //     debugPrint('''
              // -----
              // Title: ${notification.title}
              // Message: ${notification.message}
              // Priority: ${notification.priority}
              // User Levels: ${notification.userLevels}
              // Start: ${notification.startDate}
              // Exp: ${notification.expirationDate}
              // Url: ${notification.url}
              // Icon: ${notification.icon}
              // Additional Data: ${notification.additionalData}
              // ''');
              //   }

              userDatabase.put('lastPromoNotification', DateTime.now().toIso8601String());
              // userDatabase.put('lastGithubPromoNotificationsRefresh', '${DateTime.now()}');
            }
            return newGithubNotifications;
          } else {
            debugPrint('***** CURRENT GITHUB MESSAGES ARE UP TO DATE. NO NOTIFICATIONS TO SEND');
            return currentGithubNotifications;
          }
        } else {
          debugPrint('***** GITHUB MSG API CALL ERROR WITH RESPONSE CODE: ${response.statusCode}');
          return currentGithubNotifications.isNotEmpty
              ? currentGithubNotifications
              : []; // githubNotificationsPlaceholder;
        }
      } catch (e) {
        debugPrint('***** GITHUB MSG API ERROR: $e');
        return currentGithubNotifications.isNotEmpty
            ? currentGithubNotifications
            : []; // githubNotificationsPlaceholder;
      }
    } else {
      logger.d(
          '***** CURRENT GITHUB PROMO NOTIFICATIONS LIST: ${currentGithubNotifications.map((e) => e.title)} *****');
      newGithubNotifications = currentGithubNotifications;
      logger.d('***** GITHUB PROMO NOTIFICATIONS LIST NOT UPDATED: LIST IS CURRENT *****');
      // userDatabase.put('lastGithubPromoNotificationsRefresh', '${DateTime.now()}');
      return newGithubNotifications;
    }
  }

  /// PRUNE AND SORT NOTIFICATIONS
  static Future<List<GithubNotifications>> pruneAndSortPromoNotifications(
      List<GithubNotifications> list, String githubApiUserLevel, DateTime now) async {
    debugPrint('[PRUNE & SORT] PRUNING ${list.length} GITHUB PROMO NOTIFICATIONS');

    list.retainWhere((element) =>
        element.startDate.isBefore(now) &&
        (element.expirationDate.toString() == "" || element.expirationDate.isAfter(now)) &&
        element.userLevels.contains(githubApiUserLevel));

    // list.sort((a, b) =>
    //     a.startDate.compareTo(b.startDate).compareTo(a.priority.compareTo(b.priority)));

    list.sort((a, b) => a.priority.compareTo(b.priority));

    debugPrint('[PRUNE & SORT] ${list.length} GITHUB PROMO NOTIFICATIONS REMAIN');
    return list;
  }
}
