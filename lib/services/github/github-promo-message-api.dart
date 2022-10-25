import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../constants/constants.dart';
import '../../functions/functions.dart';
import '../notifications/notification_api.dart';
import '../github/github-promo-message-model.dart';

class GithubApi {
  static Future<List<GithubNotifications>> getPromoMessages() async {
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

    final DateTime _now = DateTime.now();

    final DateTime _lastPromoNotification =
        DateTime.parse(userDatabase.get('lastPromoNotification'));

    debugPrint('LAST PROMO NOTIFICATION WAS: $_lastPromoNotification');

    GithubMessages _currentGithubMessages;
    List<GithubNotifications> _currentGithubNotifications = [];
    bool _newUserLevelMessagesRetrieved = false;

    try {
      _currentGithubMessages = githubMessagesFromJson(userDatabase.get('githubNotifications'));
      _currentGithubNotifications = _currentGithubMessages.notifications;
      debugPrint('***** CURRENT GITHUB NOTIFICATIONS LOADED SUCCESSFULLY');
    } catch (e) {
      _currentGithubNotifications = [];
      debugPrint('***** CURRENT GITHUB NOTIFICATIONS LOAD ERROR: $e');
    }

    List<GithubNotifications> _newGithubNotifications = [];

    try {
      final Map headers = <String, String>{"Accept": "application/json"};
      final response = await http.get(
          Uri.parse("https://themettacode.github.io/us-congress-app-message-api/messageData.json"),
          headers: headers);
      debugPrint('***** GITHUB MSG API RESPONSE CODE: ${response.statusCode} *****');
      if (response.statusCode == 200) {
        GithubMessages _githubMessages = githubMessagesFromJson(response.body);
        if (_githubMessages.status == "OK" &&
            _githubMessages.app == 'us-congress' &&
            (_currentGithubNotifications.isEmpty ||
                _githubMessages.notifications.any((msg) => msg.startDate.isAfter(
                    _lastPromoNotification)) /* || _githubMessages.updated.isAfter(_currentGithubMessages.updated)*/)) {
          debugPrint('***** NEW GITHUB MESSAGES RETRIEVED');
          _newGithubNotifications = _githubMessages.notifications;

          // if (_newGithubNotifications.isNotEmpty) {
          _newGithubNotifications.sort((a, b) => a.startDate.compareTo(b.startDate));
          _newGithubNotifications.retainWhere((element) =>
              element.startDate.isBefore(_now) &&
              (element.expirationDate.toString() == "" || element.expirationDate.isAfter(_now)) &&
              element.userLevels.contains(githubApiUserLevel));
          if (_newGithubNotifications.isNotEmpty &&
              _newGithubNotifications.first.userLevels.contains(githubApiUserLevel)) {
            _newUserLevelMessagesRetrieved = true;
          }
          // }

          _currentGithubNotifications = _newGithubNotifications;
          userDatabase.put('githubNotifications', githubMessagesToJson(_githubMessages));

          if (_newGithubNotifications.isNotEmpty &&
              (_newUserLevelMessagesRetrieved ||
                  _lastPromoNotification.isBefore(_now.subtract(Duration(days: 3))))) {
            GithubNotifications _thisPromotion = _newUserLevelMessagesRetrieved
                ? _newGithubNotifications.first
                : _newGithubNotifications[random.nextInt(_newGithubNotifications.length)];
            String _title = _thisPromotion.title;
            String _messageBody = _thisPromotion.message;
            String _additionalData = _thisPromotion.additionalData;

            debugPrint('SENDING NEW PROMO NOTIFICATION: $_thisPromotion');

            await NotificationApi.showBigTextNotification(
                0,
                'promotions',
                'App Promotions',
                'US Congress App Promotional Notifications',
                'Just So You Know...',
                _title,
                _messageBody,
                _additionalData);

            _newGithubNotifications.forEach((notification) => debugPrint('''
          -----
          Title: ${notification.title}
          Message: ${notification.message}
          Priority: ${notification.priority}
          User Levels: ${notification.userLevels}
          Start: ${notification.startDate}
          Exp: ${notification.expirationDate}
          Url: ${notification.url}
          Additional Data: ${notification.additionalData}
          '''));
          }

          userDatabase.put('lastPromoNotification', DateTime.now().toIso8601String());
          return _newGithubNotifications;
        } else {
          debugPrint('***** CURRENT GITHUB MESSAGES ARE UP TO DATE. NO NOTIFICATIONS TO SEND');
          return _currentGithubNotifications;
        }
      } else {
        debugPrint('***** GITHUB MSG API CALL ERROR WITH RESPONSE CODE: ${response.statusCode}');
        return _currentGithubNotifications.isNotEmpty ? _currentGithubNotifications : [];
      }
    } catch (e) {
      debugPrint('***** GITHUB MSG API ERROR: $e');
      return _currentGithubNotifications.isNotEmpty ? _currentGithubNotifications : [];
    }
  }
}
