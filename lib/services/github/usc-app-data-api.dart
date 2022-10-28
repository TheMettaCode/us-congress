import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../constants/constants.dart';
import '../../functions/functions.dart';
import '../notifications/notification_api.dart';
import '../github/usc-app-data-model.dart';

class GithubApi {
  static Future<List<GithubNotifications>> getPromoMessages([BuildContext context]) async {
    Box userDatabase = Hive.box(appDatabase);

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
    List<String> currentGithubHashtags = [];
    List<GithubNotifications> currentGithubNotifications = [];
    bool newUserLevelMessagesRetrieved = false;

    try {
      currentGithubData = githubDataFromJson(userDatabase.get('githubData'));
      currentGithubNotifications = currentGithubData.notifications.toList();
      currentGithubHashtags = currentGithubData.hashtags;
      debugPrint('***** CURRENT GITHUB DATA LOADED SUCCESSFULLY');
    } catch (e) {
      currentGithubNotifications = [];
      currentGithubHashtags = [];
      debugPrint('***** CURRENT GITHUB DATA LOAD ERROR: $e');
    }

    List<GithubNotifications> newGithubNotifications = [];

    try {
      final Map headers = <String, String>{"Accept": "application/json"};
      final response = await http.get(
          Uri.parse("https://themettacode.github.io/us-congress-app-data-api/usc-app-data.json"),
          headers: headers);
      debugPrint('***** GITHUB MSG API RESPONSE CODE: ${response.statusCode} *****');
      if (response.statusCode == 200) {
        GithubData githubData = githubDataFromJson(response.body);

        /// CHECK FOR CURRENT AND NEW HASHTAG DATA EQUALITY & UPDATE LOCAL IF SO
        List<String> newGithubHashtags = githubData.hashtags;
        bool hashtagListsAreEqual = listEquals(newGithubHashtags, currentGithubHashtags);
        debugPrint("^^^ NEW & CURRENT HASHTAG LISTS ARE EQUAL? $hashtagListsAreEqual");
        if (!hashtagListsAreEqual) {
          debugPrint("^^^ HASHTAGS UPDATED: $newGithubHashtags");
          userDatabase.put('hashtags', newGithubHashtags);
        }

        /// CHECK FOR CURRENT AND NEW NOTIFICATION DATA EQUALITY
        bool notificationListsAreEqual = listEquals<String>(
            githubData.notifications.map((e) => e.title).toList(),
            currentGithubNotifications.map((e) => e.title).toList());
        debugPrint("^^^ NEW & CURRENT NOTIFICATION LISTS ARE EQUAL? $notificationListsAreEqual");

        if (githubData.status == "OK" &&
            githubData.app == 'us-congress' &&
            (!notificationListsAreEqual)) {
          debugPrint('***** NEW GITHUB DATA RETRIEVED');
          newGithubNotifications = githubData.notifications.toList();

          // /// CREATE LIST OF NOTIFICATIONS ADDED AFTER LAST UPDATE
          // List<GithubNotifications> _newNotifications = _newGithubNotifications
          //     .where((notification) => notification.startDate.isAfter(_lastPromoNotification))
          //     .toList();
          // if (_newNotifications.isNotEmpty) {
          //   debugPrint(
          //       '^^^^^ ${_newNotifications.length} NEW NOTIFICATIONS ADDED\n${_newNotifications.map((e) => e.title)}');
          // } else {
          //   debugPrint('^^^^^ ${_newNotifications.length} NEW NOTIFICATIONS ADDED');
          // }

          // if (_newGithubNotifications.isNotEmpty) {
          /// PRUNE AND SORT NOTIFICATIONS
          newGithubNotifications.sort((a, b) =>
              a.startDate.compareTo(b.startDate).compareTo(a.priority.compareTo(b.priority)));
          newGithubNotifications.retainWhere((element) =>
              element.startDate.isBefore(now) &&
              (element.expirationDate.toString() == "" || element.expirationDate.isAfter(now)) &&
              element.userLevels.contains(githubApiUserLevel));

          /// SET 'NEW NOTIFICATIONS RETRIEVED' FLAG TO TRUE
          if (newGithubNotifications.isNotEmpty &&
              newGithubNotifications.first.userLevels.contains(githubApiUserLevel)) {
            newUserLevelMessagesRetrieved = true;
          }
          // }

          currentGithubNotifications = newGithubNotifications;
          userDatabase.put('githubData', githubDataToJson(githubData));

          if (newGithubNotifications.isNotEmpty &&
              (newUserLevelMessagesRetrieved ||
                  lastPromoNotification.isBefore(now.subtract(const Duration(days: 3))))) {
            GithubNotifications thisPromotion = newUserLevelMessagesRetrieved
                ? newGithubNotifications.first
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
          }

          userDatabase.put('lastPromoNotification', DateTime.now().toIso8601String());
          return newGithubNotifications;
        } else {
          debugPrint('***** CURRENT GITHUB MESSAGES ARE UP TO DATE. NO NOTIFICATIONS TO SEND');
          return currentGithubNotifications;
        }
      } else {
        debugPrint('***** GITHUB MSG API CALL ERROR WITH RESPONSE CODE: ${response.statusCode}');
        return currentGithubNotifications.isNotEmpty ? currentGithubNotifications : [];
      }
    } catch (e) {
      debugPrint('***** GITHUB MSG API ERROR: $e');
      return currentGithubNotifications.isNotEmpty ? currentGithubNotifications : [];
    }
  }
}
