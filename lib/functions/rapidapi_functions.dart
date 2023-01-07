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
import '../notifications_handler/notification_api.dart';
import 'functions.dart';

class RapidApiFunctions {
  static final Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);
  static final bool stripeTestMode = userDatabase.get('stripeTestMode');
  static final bool googleTestMode = userDatabase.get('googleTestMode');
  static final bool amazonTestMode = userDatabase.get('amazonTestMode');
  static final bool testing = userDatabase.get('stripeTestMode') ||
      userDatabase.get('googleTestMode') ||
      userDatabase.get('amazonTestMode');

  static Future<List<NewsArticle>> fetchNewsArticles(
      {BuildContext context}) async {
    List<String> subscriptionAlertsList =
        List.from(userDatabase.get('subscriptionAlertsList'));
    bool newUser = userDatabase.get('appOpens') < newUserThreshold;
    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    List<NewsArticle> currentNewsArticlesList = [];

    try {
      List<NewsArticle> tempArticleList =
          newsArticleFromJson(userDatabase.get('newsArticles'));
      currentNewsArticlesList = await processNewsArticleDates(tempArticleList);
    } catch (e) {
      logger.d(
          '[NEWS ARTICLES API] ERROR DURING NEWS ARTICLE LIST (FUNCTION): $e ^^^^^');
      userDatabase.put('newsArticles', {});
      currentNewsArticlesList = [];
    }
    logger.d(
        '[NEWS ARTICLES API] ${currentNewsArticlesList.length} CURRENT NEWS ARTICLES');

    List<NewsArticle> finalNewsArticlesList = [];

    if (currentNewsArticlesList.isEmpty ||
        DateTime.parse(userDatabase.get('lastNewsArticlesRefresh'))
            .isBefore(DateTime.now().subtract(const Duration(minutes: 30)))) {
      logger.d('[NEWS ARTICLES API] RETRIEVING LATEST NEWS... *****');

      final rapidApiKey = dotenv.env['RAPID_API_KEY'];
      final rapidApiHost = dotenv.env['USC_NEWS_API_HOST'];

      final url = Uri.parse(
          'https://us-congress-top-news.p.rapidapi.com/top_congressional_news.json');
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': rapidApiKey,
        'X-RapidAPI-Host': rapidApiHost,
      });
      logger.d(
          '[NEWS ARTICLES API] NEWS API RESPONSE CODE: ${response.statusCode} *****');

      // final Map headers = <String, String>{"Accept": "application/json"};
      // final response = await http.get(
      //     Uri.parse(
      //         "https://themettacode.github.io/us-congress-news-api/top_congressional_news.json"),
      //     headers: headers);
      // logger.d('[GITHUB TOP NEWS] API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d('[NEWS ARTICLES API] NEWS RETRIEVAL SUCCESS! *****');
        final List<NewsArticle> newsArticles =
            newsArticleFromJson(response.body);

        /// SAVE NEW DATA TO LOCAL DBASE
        try {
          logger.d('[NEWS ARTICLES API] SAVING NEW ARTICLES TO DBASE *****');
          userDatabase.put('newsArticles', newsArticleToJson(newsArticles));
        } catch (e) {
          logger.d(
              '[NEWS ARTICLES API] ERROR SAVING ARTICLES LIST TO DBASE (FUNCTION): $e ^^^^^');
          userDatabase.put('newsArticles', {});
        }

        List<ChamberMember> membersList = [];
        ChamberMember thisMember;
        NewsArticle thisMemberArticle;

        if (newsArticles.isNotEmpty) {
          List<NewsArticle> allArticles = newsArticles;

          /// CONVERT ALL DATE FIELDS TO STANDARD DATETIME FORMAT
          finalNewsArticlesList = await processNewsArticleDates(allArticles);

          /// IDENTIFY ALL NEWLY ADDED ARTICLES
          List<NewsArticle> newlyAddedArticles = [];
          for (NewsArticle article in finalNewsArticlesList) {
            if (!currentNewsArticlesList
                .map((e) => e.title)
                .contains(article.title)) {
              newlyAddedArticles.add(article);
            }
          }

          if (newlyAddedArticles.isNotEmpty) {
            userDatabase.put('newNewsArticles', true);
            logger.d(
                '[NEWS ARTICLES API] ${newlyAddedArticles.length} NEW ARTICLES RETRIEVED.');

            /// DETERMINE IF ANY TITLES CONTAIN MEMBERS THAT THE USER IS FOLLOWING
            try {
              logger.d(
                  '[NEWS ARTICLES API] CHECKING TITLES FOR MEMBERS AND NEW ITEMS');
              membersList = memberPayloadFromJson(
                          userDatabase.get('houseMembersList'))
                      .results
                      .first
                      .members +
                  memberPayloadFromJson(userDatabase.get('senateMembersList'))
                      .results
                      .first
                      .members;

              thisMember = membersList.firstWhere((element) =>
                  newlyAddedArticles.first.title
                      .toLowerCase()
                      .contains('${element.firstName.toLowerCase()} ') &&
                  newlyAddedArticles.first.title
                      .toLowerCase()
                      .contains(' ${element.lastName.toLowerCase()}'));

              if (thisMember != null) {
                thisMemberArticle = newlyAddedArticles.first;
              }
              logger.d(
                  '[NEWS ARTICLES API] MEMBER FOUND FOR NEWS ARTICLE RETRIEVAL FUNCTION: ${thisMember.firstName} ${thisMember.lastName}');
            } catch (e) {
              logger.w(
                  '[NEWS ARTICLES API] ERROR DURING RETRIEVAL OF MEMBERS LIST (News Articles Function): $e');
            }
          }

          if (userIsDev && newlyAddedArticles.isNotEmpty) {
            final NewsArticle thisArticle = thisMember == null
                ? newlyAddedArticles.first
                : thisMemberArticle;

            final subject = thisArticle.title.toUpperCase();
            final messageBody =
                '${thisMember == null ? '' : '.@${thisMember.twitterAccount} in the news:'} ${thisArticle.title.length > 150 ? thisArticle.title.replaceRange(150, null, '...') : thisArticle.title}';

            List<String> capitolBabbleNotificationsList = List<String>.from(
                userDatabase.get('capitolBabbleNotificationsList'));
            capitolBabbleNotificationsList.add(
                '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>medium<|:|>${thisArticle.url == null || thisArticle.url.isEmpty ? '' : thisArticle.url}');
            userDatabase.put('capitolBabbleNotificationsList',
                capitolBabbleNotificationsList);
          }

          bool memberWatched = thisMember != null &&
              subscriptionAlertsList.any((item) =>
                  item.toLowerCase().contains(thisMember.id.toLowerCase()));

          if (!newUser &&
              newlyAddedArticles.isNotEmpty &&
              (userDatabase.get('newsAlerts') || memberWatched)) {
            if (context == null || !ModalRoute.of(context).isCurrent) {
              await NotificationApi.showBigTextNotification(
                  15,
                  'news_articles',
                  'News Article',
                  '$appTitle News',
                  'Latest News',
                  '$appTitle News',
                  memberWatched
                      ? 'A member you\'re watching is in the news!'
                      : newlyAddedArticles.first.title,
                  'news');
            } else if (ModalRoute.of(context).isCurrent) {
              Messages.showMessage(
                  context: context,
                  message: memberWatched
                      ? '🧑🏽‍💼 A member you\'re watching is in the news!'
                      : newlyAddedArticles.first.title,
                  networkImageUrl: newlyAddedArticles.first.imageUrl,
                  isAlert: false,
                  removeCurrent: false);
            }
          }
        } else {
          logger.d('[NEWS ARTICLES API] NO NEW VIDEOS RETRIEVED.');
          return currentNewsArticlesList.isNotEmpty
              ? currentNewsArticlesList
              : [];
        }
        userDatabase.put('lastNewsArticlesRefresh', '${DateTime.now()}');
        return finalNewsArticlesList;
      } else {
        logger.w(
            '[NEWS ARTICLES API] API ERROR: RETRIEVING ARTICLES: ${response.statusCode} *****');
        userDatabase.put('newNewsArticles', false);
        return currentNewsArticlesList.isNotEmpty
            ? currentNewsArticlesList
            : [];
      }
    } else {
      logger.d(
          '[NEWS ARTICLES API] CURRENT ARTICLES LIST: ${currentNewsArticlesList.map((e) => e.title)} *****');
      logger
          .d('[NEWS ARTICLES API] ARTICLES NOT UPDATED: LIST IS CURRENT *****');
      userDatabase.put('newNewsArticles', false);
      return currentNewsArticlesList.isNotEmpty ? currentNewsArticlesList : [];
    }
  }

  static Future<List<ActionsList>> getFloorActions({
    BuildContext context,
    bool isHouseChamber = true,
  }) async {
    String chamber = isHouseChamber ? 'house' : 'senate';
    logger.d(
        '[NEW FLOOR ACTION FUNCTION] ${chamber[0].toUpperCase() + chamber.substring(1)} Floor Actions *****');
    bool newUser = userDatabase.get('appOpens') < newUserThreshold;
    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];
    bool floorActionsEqual = false;
    List<ActionsList> currentFloorActions = [];

    try {
      currentFloorActions = congressFloorActionFromJson(
              userDatabase.get('${chamber}FloorActions'))
          .actionsList;
    } catch (e) {
      logger.w(
          '[NEW FLOOR ACTION FUNCTION] CURRENT ${chamber.toUpperCase()} Actions ERROR: $e - Resetting... *****');
      userDatabase.put('${chamber}FloorActions', {});
      currentFloorActions = [];
    }

    List<ActionsList> finalFloorActions = [];

    if (isCongressFloorActive &&
        (currentFloorActions.isEmpty ||
            DateTime.parse(userDatabase.get(
                    'last${chamber[0].toUpperCase() + chamber.substring(1)}FloorRefresh'))
                .isBefore(
                    DateTime.now().subtract(const Duration(minutes: 15))))) {
      final rapidApiKey = dotenv.env['RAPID_API_KEY'];
      final rapidApiHost = dotenv.env['USC_FLOOR_ACTIONS_API_HOST'];

      final url = Uri.parse(
          'https://us-congress-top-news.p.rapidapi.com/floor_actions_$chamber.json');
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': rapidApiKey,
        'X-RapidAPI-Host': rapidApiHost,
      });
      logger.d(
          '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTION API RESPONSE CODE: ${response.statusCode}');

      // final Map headers = <String, String>{"Accept": "application/json"};
      // final response = await http.get(
      //     Uri.parse(
      //         "https://themettacode.github.io/congressional-floor-actions-api/floor_actions_$chamber.json"),
      //     headers: headers);
      // logger.d('[GITHUB FLOOR ACTIONS] API RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        logger.d(
            '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS RETRIEVAL SUCCESS!');
        CongressFloorAction congressFloorActions =
            congressFloorActionFromJson(response.body);
        try {
          logger.d(
              '[NEW FLOOR ACTION FUNCTION] SAVING ${chamber.toUpperCase()} FLOOR ACTIONS TO DBASE *****');
          userDatabase.put('${chamber}FloorActions',
              congressFloorActionToJson(congressFloorActions));
        } catch (e) {
          logger.d(
              '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS TO DBASE (RAPIDAPI FUNCTION): $e ^^^^^');
          userDatabase.put('${chamber}FloorActions', {});
        }

        if (congressFloorActions.actionsList.isNotEmpty) {
          floorActionsEqual = listEquals<String>(
              congressFloorActions.actionsList.map((e) => e.header).toList(),
              currentFloorActions.map((e) => e.header).toList());

          if (chamber == 'senate') {
            finalFloorActions =
                congressFloorActions.actionsList.reversed.toList();
          } else {
            finalFloorActions = congressFloorActions.actionsList;
          }

          logger.d(
              '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS EQUAL: $floorActionsEqual\n${currentFloorActions.length} CURRENT\n${finalFloorActions.length} NEW');

          logger.d(
              '[NEW FLOOR ACTION FUNCTION] CURRENT 1ST ${chamber.toUpperCase()} FLOOR ACTION: ${currentFloorActions.isEmpty ? 'No current $chamber floor actions' : finalFloorActions.first.actionItem}');
          logger.d(
              '[NEW FLOOR ACTION FUNCTION] NEW 1ST ${chamber.toUpperCase()} FLOOR ACTION: ${finalFloorActions.first.actionItem}');

          if (currentFloorActions.isEmpty || !floorActionsEqual) {
            logger.d(
                '[NEW FLOOR ACTION FUNCTION] KEY STRING IS: new${chamber[0].toUpperCase() + chamber.substring(1)}Floor');
            final String keyString =
                'new${chamber[0].toUpperCase() + chamber.substring(1)}Floor';

            logger.d(
                '[NEW FLOOR ACTION FUNCTION] SETTING NEW ${chamber.toUpperCase()} FLOOR ACTIONS FLAG TO TRUE');
            userDatabase.put(keyString, true);

            if (userIsDev) {
              // List<ActionsList> finalListReversed = finalFloorActions.reversed.toList();
              final subject = finalFloorActions.first.header.isNotEmpty
                  ? '${chamber.toUpperCase()} FLOOR: ${finalFloorActions.first.header}'
                  : '${chamber.toUpperCase()} FLOOR UPDATE';
              final messageBody =
                  '${chamber.toUpperCase()} Floor: ${finalFloorActions.first.header.isNotEmpty && finalFloorActions.first.header != '--' ? '${finalFloorActions.first.header}\n' : ''}${finalFloorActions.first.actionItem.length > 150 ? finalFloorActions.first.actionItem.replaceRange(150, null, '...') : finalFloorActions.first.actionItem}';

              List<String> capitolBabbleNotificationsList = List<String>.from(
                  userDatabase.get('capitolBabbleNotificationsList'));
              capitolBabbleNotificationsList.add(
                  '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>high');
              userDatabase.put('capitolBabbleNotificationsList',
                  capitolBabbleNotificationsList);
            }
          }

          // if (currentFloorActions.isEmpty) {
          //   currentFloorActions = finalFloorActions;
          // }
        }

        // bool billWatched = await Functions.hasSubscription(
        //     userIsPremium, userIsLegacy, finalFloorActions.first.billIds.asMap(), 'bill_',
        //     userIsDev: userIsDev);

        if (!newUser &&
            (userDatabase.get('floorAlerts') /*|| billWatched*/) &&
            !floorActionsEqual) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                9,
                '${chamber}floor',
                '${chamber[0].toUpperCase() + chamber.substring(1)} Floor',
                'Floor Actions from the ${chamber[0].toUpperCase() + chamber.substring(1)} of Representatives.',
                '${chamber[0].toUpperCase() + chamber.substring(1)} Floor',
                '${chamber[0].toUpperCase() + chamber.substring(1)} Floor Action',
                '${finalFloorActions.first.header.isNotEmpty && finalFloorActions.first.header != '--' ? '${finalFloorActions.first.header}\n' : ''}${finalFloorActions.first.actionItem}',
                'floor_actions');
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
                context: context,
                message:
                    '${chamber.toUpperCase()} FLOOR\n${finalFloorActions.first.actionItem}',
                isAlert: false,
                removeCurrent: false);
          }
        }

        // logger.d(
        //     '[NEW FLOOR ACTION FUNCTION] UPDATING... > last${chamber[0].toUpperCase() + chamber.substring(1)}Action < TO > ${finalFloorActions.first.actionItem} <');
        // userDatabase.put('last${chamber[0].toUpperCase() + chamber.substring(1)}Action',
        //     finalFloorActions.first.actionItem);
        userDatabase.put(
            'last${chamber[0].toUpperCase() + chamber.substring(1)}FloorRefresh',
            '${DateTime.now()}');

        return /* chamber == 'senate' ? finalFloorActions.reversed.toList() : */ finalFloorActions;
      } else {
        logger.d(
            '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS FROM DBASE: ${response.statusCode} *****');

        return chamber == 'house' && currentFloorActions.isNotEmpty
            ? currentFloorActions
            : chamber == 'senate' && currentFloorActions.isNotEmpty
                ? currentFloorActions.reversed.toList()
                : [];
      }
    } else {
      logger.d(
          '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS LIST: ${currentFloorActions.map((e) => e.actionItem)} *****');
      // finalFloorActions = currentFloorActions;
      logger.d(
          '[NEW FLOOR ACTION FUNCTION] ${chamber.toUpperCase()} FLOOR ACTIONS NOT UPDATED: LIST IS CURRENT *****');
      // return chamber == 'senate' ? finalFloorActions.reversed.toList() : finalFloorActions;
      return chamber == 'house' && currentFloorActions.isNotEmpty
          ? currentFloorActions
          : chamber == 'senate' && currentFloorActions.isNotEmpty
              ? currentFloorActions.reversed.toList()
              : [];
    }
  }

  static Future<List<NewsArticle>> processNewsArticleDates(
      List<NewsArticle> newsArticles) async {
    logger.d(
        '[PROCESS NEWS DATES FUNCTION] START WITH ${newsArticles.length} ITEMS: 1ST TITLE - ${newsArticles.first.title}');
    List<NewsArticle> articlesList = [];
    for (NewsArticle article in newsArticles) {
      switch (article.slug) {
        case "politico":
          {
            try {
              if (DateFormat('yyyy/MM/dd')
                  .parse(article.date.trim())
                  .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                articlesList.add(NewsArticle(
                    index: article.index,
                    title: article.title,
                    url: article.url,
                    source: article.source,
                    slug: article.slug,
                    imageUrl: article.imageUrl,
                    date: DateFormat('yyyy/MM/dd')
                        .parse(article.date)
                        .toIso8601String()));
              }
              logger.d("^^^ ARTICLE ${article.title} ADDED");
            } catch (e) {
              logger.d(
                  "^^^ ERROR PARSING POLITICO DATE FORMAT FOR ${article.date}: $e");
            }
          }
          break;

        case "usatoday":
          {
            try {
              if (DateFormat('yyyy/MM/dd')
                  .parse(article.date.trim())
                  .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                articlesList.add(NewsArticle(
                    index: article.index,
                    title: article.title,
                    url: article.url,
                    source: article.source,
                    slug: article.slug,
                    imageUrl: article.imageUrl,
                    date: DateFormat('yyyy/MM/dd')
                        .parse(article.date)
                        .toIso8601String()));
              }
              logger.d("^^^ ARTICLE ${article.title} ADDED");
            } catch (e) {
              logger.d(
                  "^^^ ERROR PARSING USA TODAY DATE FORMAT FOR ${article.date}: $e");
            }
          }
          break;

        case "nytimes":
          {
            try {
              if (DateFormat('yyyy/MM/dd')
                  .parse(article.date.trim())
                  .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                articlesList.add(NewsArticle(
                    index: article.index,
                    title: article.title,
                    url: article.url,
                    source: article.source,
                    slug: article.slug,
                    imageUrl: article.imageUrl,
                    date: DateFormat('yyyy/MM/dd')
                        .parse(article.date)
                        .toIso8601String()));
              }
              logger.d("^^^ ARTICLE ${article.title} ADDED");
            } catch (e) {
              logger.d(
                  "^^^ ERROR PARSING NY TIMES DATE FORMAT FOR ${article.date}: $e");
            }
          }
          break;

        case "propublica":
          {
            try {
              if (DateFormat('MMM dd')
                  .parse(article.date.replaceAll('.', '').trim())
                  .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                articlesList.add(NewsArticle(
                    index: article.index,
                    title: article.title,
                    url: article.url,
                    source: article.source,
                    slug: article.slug,
                    imageUrl: article.imageUrl,
                    date: DateFormat('MMM dd')
                        .parse(article.date)
                        .toIso8601String()));
              }
              logger.d("^^^ ARTICLE ${article.title} ADDED");
            } catch (e) {
              logger.d(
                  "^^^ ERROR PARSING PROPUBLICA DATE FORMAT FOR ${article.date}: $e");
            }
          }
          break;

        case "apnews":
          {
            try {
              if (DateFormat('MMMM dd, yyyy')
                  .parse(article.date.trim())
                  .isAfter(DateTime.now().subtract(const Duration(days: 14)))) {
                articlesList.add(NewsArticle(
                    index: article.index,
                    title: article.title,
                    url: article.url,
                    source: article.source,
                    slug: article.slug,
                    imageUrl: article.imageUrl,
                    date: DateFormat('MMMM dd, yyyy')
                        .parse(article.date)
                        .toIso8601String()));
              }
              logger.d("^^^ ARTICLE ${article.title} ADDED");
            } catch (e) {
              logger.d(
                  "^^^ ERROR PARSING AP NEWS DATE FORMAT FOR ${article.date}: $e");
            }
          }
          break;

        default:
          {
            logger.d("^^^^^ NO ACTION TAKEN FOR SLUG ${article.slug}");
          }
      }
    }

    if (articlesList.isNotEmpty) {
      articlesList.sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    }

    logger.d(
        '[PROCESS NEWS DATES FUNCTION] FINISH WITH ${articlesList.length}  ITEMS: NEW 1ST TITLE - ${articlesList.first.title}');
    return articlesList.length > 25
        ? articlesList.take(25).toList()
        : articlesList;
  }
}

class AllFloorActions {
  AllFloorActions({@required this.allActions, @required this.chamberActions});

  final CongressFloorAction allActions;
  final List<ActionsList> chamberActions;
}
