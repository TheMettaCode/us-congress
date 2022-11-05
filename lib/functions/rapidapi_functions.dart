import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import '../models/floor_action_model.dart';
import '../models/member_payload_model.dart';
import '../models/news_article_model.dart';
import '../services/notifications/notification_api.dart';
import 'functions.dart';

class RapidApiFunctions {
  static Future<List<NewsArticle>> fetchNewsArticles({BuildContext context}) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    List<String> subscriptionAlertsList = List.from(userDatabase.get('subscriptionAlertsList'));
    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    bool sendNotifications = false;

    List<NewsArticle> currentNewsArticlesList = [];

    try {
      currentNewsArticlesList = newsArticleFromJson(userDatabase.get('newsArticles'));
      debugPrint('^^^^^ CURRENT NEWS ARTICLE LIST RETRIEVED (FUNCTION) ^^^^^');
    } catch (e) {
      debugPrint('^^^^^ ERROR DURING NEWS ARTICLE LIST (FUNCTION): $e ^^^^^');
      userDatabase.put('newsArticles', {});
      currentNewsArticlesList = [];
    }

    List<NewsArticle> finalNewsArticlesList = [];

    if (currentNewsArticlesList.isEmpty ||
        DateTime.parse(userDatabase.get('lastNewsArticlesRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(minutes: 30)))) {
      logger.d('***** RETRIEVING LATEST NEWS... *****');

      final rapidApiKey = dotenv.env['RAPID_API_KEY'];
      final rapidApiHost = dotenv.env['USC_NEWS_API_HOST'];

      final url = Uri.parse('https://us-congress-top-news.p.rapidapi.com/news');
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': rapidApiKey,
        'X-RapidAPI-Host': rapidApiHost,
      });
      debugPrint('***** NEWS API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('***** NEWS RETRIEVAL SUCCESS! *****');
        final List<NewsArticle> newsArticles = newsArticleFromJson(response.body);
        List<ChamberMember> membersList = [];
        ChamberMember thisMember;

        if (newsArticles.isNotEmpty) {
          for (NewsArticle article in newsArticles) {
            switch (article.slug) {
              case "politico":
                {
                  try {
                    if (DateFormat('yyyy/MM/dd')
                        .parse(article.date.trim())
                        .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                  } catch (e) {
                    debugPrint("^^^ ERROR PARSING POLITICO DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              case "usatoday":
                {
                  try {
                    if (DateFormat('yyyy/MM/dd')
                        .parse(article.date.trim())
                        .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                  } catch (e) {
                    debugPrint("^^^ ERROR PARSING USA TODAY DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              case "nytimes":
                {
                  try {
                    if (DateFormat('yyyy/MM/dd')
                        .parse(article.date.trim())
                        .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                  } catch (e) {
                    debugPrint("^^^ ERROR PARSING NY TIMES DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              case "propublica":
                {
                  try {
                    if (DateFormat('MMM dd')
                        .parse(article.date.replaceAll('.', '').trim())
                        .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                  } catch (e) {
                    debugPrint("^^^ ERROR PARSING PROPUBLICA DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              case "apnews":
                {
                  try {
                    if (DateFormat('MMMM dd, yyyy')
                        .parse(article.date.trim())
                        .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                      finalNewsArticlesList.add(article);
                    }
                    debugPrint("^^^ ARTICLE ${article.title} ADDED");
                  } catch (e) {
                    debugPrint("^^^ ERROR PARSING AP NEWS DATE FORMAT FOR ${article.date}: $e");
                  }
                }
                break;

              default:
                {
                  debugPrint("^^^^^ NO ACTION TAKEN FOR SLUG ${article.slug}");
                }
            }
          }

          if (finalNewsArticlesList.isNotEmpty) {
            finalNewsArticlesList.sort((a, b) => a.index.compareTo(b.index));
            if (currentNewsArticlesList.isEmpty ||
                !currentNewsArticlesList
                    .any((element) => element.title == finalNewsArticlesList.first.title)) {
              debugPrint('^^^^^ CHECKING TITLES FOR MEMBERS AND NEW ITEMS');
              sendNotifications = true;
              userDatabase.put('newNewsArticles', true);

              try {
                membersList = memberPayloadFromJson(userDatabase.get('houseMembersList'))
                        .results
                        .first
                        .members +
                    memberPayloadFromJson(userDatabase.get('senateMembersList'))
                        .results
                        .first
                        .members;

                thisMember = membersList.firstWhere((element) =>
                    finalNewsArticlesList.first.title
                        .toLowerCase()
                        .contains(element.firstName.toLowerCase()) &&
                    finalNewsArticlesList.first.title
                        .toLowerCase()
                        .contains(element.lastName.toLowerCase()));
                debugPrint(
                    '^^^^^ MEMBER FOUND FOR NEWS ARTICLE RETRIEVAL FUNCTION: ${thisMember.firstName} ${thisMember.lastName}');
              } catch (e) {
                logger.w('ERROR DURING RETRIEVAL OF MEMBERS LIST (News Articles Function): $e');
              }

              if (userIsDev) {
                final NewsArticle thisArticle = finalNewsArticlesList.first;

                final subject = thisArticle.title.toUpperCase();
                final messageBody =
                    '${thisMember == null ? '' : '.@${thisMember.twitterAccount} in the news:'} ${thisArticle.title.length > 150 ? thisArticle.title.replaceRange(150, null, '...') : thisArticle.title}';

                List<String> capitolBabbleNotificationsList =
                    List<String>.from(userDatabase.get('capitolBabbleNotificationsList'));
                capitolBabbleNotificationsList.add(
                    '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>medium<|:|>${thisArticle.url == null || thisArticle.url.isEmpty ? '' : thisArticle.url}');
                userDatabase.put('capitolBabbleNotificationsList', capitolBabbleNotificationsList);
              }
            }

            if (currentNewsArticlesList.isEmpty) {
              currentNewsArticlesList = finalNewsArticlesList;
            }

            try {
              logger.d('***** SAVING NEW ARTICLES TO DBASE *****');
              userDatabase.put('newsArticles', newsArticleToJson(finalNewsArticlesList));
            } catch (e) {
              logger.w('^^^^^ ERROR SAVING ARTICLES LIST TO DBASE (FUNCTION): $e ^^^^^');
              userDatabase.put('newsArticles', {});
            }
          } else {
            logger.w('NEW ARTICLES LIST IS EMPTY AFTER PRUNING');
            return [];
          }
        }

        bool memberWatched = thisMember != null &&
            subscriptionAlertsList
                .any((item) => item.toLowerCase().contains(thisMember.id.toLowerCase()));

        // bool memberWatched = await hasSubscription(
        //     userIsPremium,
        //     userIsLegacy,
        //     (_finalNewsArticlesList.map((e) => e.memberId)).toList().asMap(),
        //     'member_',
        //     userIsDev: userIsDev);

        if ((userDatabase.get('newsAlerts') || memberWatched) && sendNotifications) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                15,
                'news_articles',
                'News Article',
                'US Congress News',
                'Latest News',
                'US Congress News',
                memberWatched
                    ? 'A member you\'re watching is in the news!'
                    : finalNewsArticlesList.first.title,
                'news');
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message: memberWatched
                    ? '🧑🏽‍💼 A member you\'re watching is in the news!'
                    : finalNewsArticlesList.first.title,
                networkImageUrl: finalNewsArticlesList.first.imageUrl,
                isAlert: false,
                removeCurrent: false);
          }
        }

        userDatabase.put('lastNewsArticlesRefresh', '${DateTime.now()}');

        return finalNewsArticlesList;
      } else {
        logger.w('***** API ERROR: LOADING ARTICLES FROM DBASE: ${response.statusCode} *****');

        return finalNewsArticlesList =
            currentNewsArticlesList.isNotEmpty ? currentNewsArticlesList : [];
      }
    } else {
      logger.d('***** CURRENT ARTICLES LIST: ${currentNewsArticlesList.map((e) => e.title)} *****');
      finalNewsArticlesList = currentNewsArticlesList;
      logger.d('***** ARTICLES NOT UPDATED: LIST IS CURRENT *****');
      return finalNewsArticlesList;
    }
  }

  static Future<List<ActionsList>> getFloorActions({
    BuildContext context,
    bool isHouseChamber = true,
  }) async {
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
    String chamber = isHouseChamber ? 'house' : 'senate';
    debugPrint('[NEW FLOOR ACTION FUNCTION] ${chamber[0].toUpperCase() + chamber.substring(1)} Floor Actions *****');
    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    bool userIsLegacy = userLevels[2];

    List<ActionsList> currentFloorActions = [];

    // try {
    //   currentFloorActions =
    //       floorActionFromJson(userDatabase.get('${chamber}FloorActionsList')).actionsList;
    // } catch (e) {
    //   logger.w('***** CURRENT ${chamber.toUpperCase()} Actions ERROR: $e - Resetting... *****');
    //   userDatabase.put('${chamber}FloorActionsList', {});
    //   currentFloorActions = [];
    // }

    List<ActionsList> finalFloorActions = [];

    if (currentFloorActions.isEmpty
        // ||
        // DateTime.parse(userDatabase.get('last${chamber}FloorActionsRefresh'))
        //     .isBefore(DateTime.now().subtract(const Duration(minutes: 30)))
    ) {
      final rapidApiKey = dotenv.env['RAPID_API_KEY'];
      final rapidApiHost = dotenv.env['USC_FLOOR_ACTIONS_API_HOST'];

      final url = Uri.parse('https://us-congress-top-news.p.rapidapi.com/$chamber');
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': rapidApiKey,
        'X-RapidAPI-Host': rapidApiHost,
      });

      // final url = PropublicaApi().houseFloorUpdatesApi;
      // final headers = PropublicaApi().apiHeaders;
      // final authority = PropublicaApi().authority;
      // final response =
      // await http.get(Uri.https(authority, url), headers: headers);
      debugPrint(
          '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTION API RESPONSE CODE: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS RETRIEVAL SUCCESS!');
        CongressFloorAction floorActions = congressFloorActionFromJson(response.body);

        if (floorActions.actionsList.isNotEmpty) {
          finalFloorActions = floorActions.actionsList;

          debugPrint(
              '[NEW FLOOR ACTION FUNCTION] CURRENT 1ST ${chamber.toUpperCase()} FLOOR ACTION: ${currentFloorActions.isEmpty ? 'No current $chamber floor actions' : finalFloorActions.first.actionItem}');
          debugPrint(
              '[NEW FLOOR ACTION FUNCTION] NEW 1ST ${chamber.toUpperCase()} FLOOR ACTION: ${finalFloorActions.first.actionItem}');

          if (currentFloorActions.isEmpty ||
              finalFloorActions.first.actionItem != currentFloorActions.first.actionItem) {
            debugPrint('[NEW FLOOR ACTION FUNCTION] KEY STRING IS: new${chamber[0].toUpperCase() + chamber.substring(1)}Floor');
            final String keyString = 'new${chamber[0].toUpperCase() + chamber.substring(1)}Floor';
            userDatabase.put(keyString, true);

            if (userIsDev) {
              final subject = finalFloorActions.first.header.isNotEmpty
                  ? '${chamber.toUpperCase()} FLOOR: ${finalFloorActions.first.header}'
                  : '${chamber.toUpperCase()} FLOOR UPDATE';
              final messageBody =
                  '${chamber.toUpperCase()} FLOOR: ${finalFloorActions.first.actionItem.length > 150 ? finalFloorActions.first.actionItem.replaceRange(150, null, '...') : finalFloorActions.first.actionItem}';

              // List<String> capitolBabbleNotificationsList =
              //     List<String>.from(userDatabase.get('capitolBabbleNotificationsList'));
              // capitolBabbleNotificationsList
              //     .add('${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>high');
              // userDatabase.put('capitolBabbleNotificationsList', capitolBabbleNotificationsList);
            }
          }

          if (currentFloorActions.isEmpty) {
            currentFloorActions = finalFloorActions;
          }

          try {
           debugPrint('[NEW FLOOR ACTION FUNCTION] SAVING ${chamber.toUpperCase()} FLOOR ACTIONS TO DBASE *****');
            // userDatabase.put('${chamber}FloorActionsList', congressFloorActionToJson(floorActions));
          } catch (e) {
            debugPrint(
                '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS TO DBASE (RAPIDAPI FUNCTION): $e ^^^^^');
            // userDatabase.put('houseFloorActionsList', {});
          }
        }

        // bool billWatched = await Functions.hasSubscription(
        //     userIsPremium, userIsLegacy, finalFloorActions.first.billIds.asMap(), 'bill_',
        //     userIsDev: userIsDev);

        if ((userDatabase.get('floorAlerts') /*|| billWatched*/) &&
            !listEquals(currentFloorActions, finalFloorActions)) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                9,
                '${chamber}floor',
                '${chamber[0].toUpperCase() + chamber.substring(1)} Floor',
                'Floor Actions from the ${chamber[0].toUpperCase() + chamber.substring(1)} of Representatives.',
                '${chamber[0].toUpperCase() + chamber.substring(1)} Floor',
                '${chamber[0].toUpperCase() + chamber.substring(1)} Floor Action',
                finalFloorActions.first.actionItem,
                'floor_actions');
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message: '${chamber.toUpperCase()} FLOOR\n${finalFloorActions.first.actionItem}',
                isAlert: false,
                removeCurrent: false);
          }
        }

        debugPrint(
            '[NEW FLOOR ACTION FUNCTION] UPDATING... > last${chamber[0].toUpperCase() + chamber.substring(1)}Action < TO > ${finalFloorActions.first.actionItem} <');
        // userDatabase.put('last${chamber[0].toUpperCase() + chamber.substring(1)}Action',
        //     finalFloorActions.first.actionItem);
        // userDatabase.put(
        //     'last${chamber[0].toUpperCase() + chamber.substring(1)}FloorActionsRefresh',
        //     '${DateTime.now()}');
        return finalFloorActions;
      } else {
        debugPrint(
            '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS FROM DBASE: ${response.statusCode} *****');

        return finalFloorActions = currentFloorActions.isNotEmpty ? currentFloorActions : [];
      }
    } else {
      debugPrint(
          '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS LIST: ${currentFloorActions.map((e) => e.actionItem)} *****');
      finalFloorActions = currentFloorActions;
      debugPrint('[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS NOT UPDATED: LIST IS CURRENT *****');
      return finalFloorActions;
    }
  }
}
