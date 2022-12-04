// To parse this JSON data, do
//
//     final topCongressionalVideos = topCongressionalVideosFromJson(jsonString);

import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../constants/constants.dart';
import '../../constants/styles.dart';
import '../../constants/themes.dart';
import '../../functions/functions.dart';
import '../../notifications_handler/notification_api.dart';
import '../admob/admob_ad_library.dart';

// To parse this JSON data, do
//
//     final topCongressionalVideos = topCongressionalVideosFromJson(jsonString);

TopCongressionalVideos topCongressionalVideosFromJson(String str) =>
    TopCongressionalVideos.fromJson(json.decode(str));

String topCongressionalVideosToJson(TopCongressionalVideos data) => json.encode(data.toJson());

class TopCongressionalVideos {
  TopCongressionalVideos({
    @required this.retrievedDate,
    @required this.channels,
  });

  final DateTime retrievedDate;
  final List<Channel> channels;

  factory TopCongressionalVideos.fromJson(Map<String, dynamic> json) => TopCongressionalVideos(
        retrievedDate: DateTime.parse(json["retrieved-date"]),
        channels: List<Channel>.from(json["videos"].map((x) => Channel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "retrieved-date": retrievedDate.toIso8601String(),
        "videos": List<dynamic>.from(channels.map((x) => x.toJson())),
      };
}

class Channel {
  Channel({
    @required this.channelName,
    @required this.channelId,
    @required this.channelSlug,
    @required this.channelUrl,
    @required this.channelVideos,
  });

  final String channelName;
  final String channelId;
  final String channelSlug;
  final String channelUrl;
  final List<ChannelVideos> channelVideos;

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        channelName: json["channel-name"],
        channelId: json["channel-id"],
        channelSlug: json["channel-slug"],
        channelUrl: json["channel-url"],
        channelVideos:
            List<ChannelVideos>.from(json["channel-videos"].map((x) => ChannelVideos.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "channel-name": channelName,
        "channel-id": channelId,
        "channel-slug": channelSlug,
        "channel-url": channelUrl,
        "channel-videos": List<dynamic>.from(channelVideos.map((x) => x.toJson())),
      };
}

class ChannelVideos {
  ChannelVideos({
    @required this.channel,
    @required this.title,
    @required this.url,
    @required this.id,
    @required this.date,
    @required this.thumbnail,
  });

  final String channel;
  final String title;
  final String url;
  final String id;
  final String date;
  final String thumbnail;

  factory ChannelVideos.fromJson(Map<String, dynamic> json) => ChannelVideos(
        channel: json["channel"],
        title: json["title"],
        url: json["url"],
        id: json["id"],
        date: json["date"],
        thumbnail: json["thumbnail"],
      );

  Map<String, dynamic> toJson() => {
        "channel": channel,
        "title": title,
        "url": url,
        "id": id,
        "date": date,
        "thumbnail": thumbnail,
      };
}

class YouTubeVideosApi {
  /// RETRIEVE YOUTUBE VIDEO IDs AND SAVE THEM TO DBASE
  static Future<List<ChannelVideos>> getYoutubeVideos({BuildContext context}) async {
    debugPrint('[YOUTUBE VIDEOS API] RETRIEVING VIDEOS');
    Box userDatabase = Hive.box(appDatabase);
    bool newUser = userDatabase.get('appOpens') < newUserThreshold;
    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    List<ChannelVideos> currentVideosList = [];

    try {
      List<ChannelVideos> xVideosList =
          topCongressionalVideosFromJson(userDatabase.get('youtubeVideosList'))
              .channels
              .map((e) => e.channelVideos)
              .expand((element) => element)
              .toList();
      currentVideosList = await convertAllDates(xVideosList);
      debugPrint(
          '[YouTube Videos API] ${currentVideosList.length} CURRENT VIDEOS RETRIEVED SUCCESSFULLY');
    } catch (e) {
      debugPrint('[YouTube Videos API] CURRENT VIDEO RETRIEVAL ERROR:$e');
      userDatabase.put('youtubeVideosList', {});
    }

    List<ChannelVideos> finalVideosList = [];

    if (currentVideosList.isEmpty ||
        DateTime.parse(userDatabase.get('lastVideosRefresh')).isBefore(DateTime.now()
            .subtract(context == null ? const Duration(hours: 1) : const Duration(minutes: 20)))) {
      debugPrint('[YOUTUBE VIDEOS API] GENERATING LIST OF YOUTUBE VIDEO ITEMS');

      final rapidApiKey = dotenv.env['RAPID_API_KEY'];
      final rapidApiHost = dotenv.env['USC_VIDEOS_API_HOST'];

      final url = Uri.parse('https://us-congress-latest-videos.p.rapidapi.com/latest_videos.json');
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': rapidApiKey,
        'X-RapidAPI-Host': rapidApiHost,
      });
      debugPrint('[YOUTUBE VIDEOS API] TOP VIDEOS API RESPONSE CODE: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('[YOUTUBE VIDEOS API] TOP VIDEOS YOUTUBE API RETRIEVAL SUCCESS! *****');

        final TopCongressionalVideos newRetrievedData =
            topCongressionalVideosFromJson(response.body);

        /// SAVE NEW DATA TO LOCAL DBASE
        try {
          debugPrint('[YOUTUBE VIDEOS API] SAVING NEWLY RETRIEVED DATA TO DBASE');
          userDatabase.put('youtubeVideosList', topCongressionalVideosToJson(newRetrievedData));
        } catch (e) {
          debugPrint('[YOUTUBE VIDEOS API] NEW DATA RETRIEVAL ERROR: $e');
        }

        List<Channel> allChannelsList = newRetrievedData.channels;

        List<ChannelVideos> allVideosList = allChannelsList
            .where((element) => element.channelVideos.isNotEmpty)
            .map((e) => e.channelVideos)
            .expand((element) => element)
            .toList();

        if (allVideosList.isNotEmpty) {
          finalVideosList = await convertAllDates(allVideosList);

          /// IDENTIFY ALL NEWLY ADDED VIDEOS
          List<ChannelVideos> newVideos = [];
          for (ChannelVideos video in finalVideosList) {
            if (!currentVideosList.map((e) => e.id).contains(video.id)) {
              newVideos.add(video);
            }
          }

          if (newVideos.isNotEmpty) {
            userDatabase.put('newVideos', true);
            debugPrint('[YOUTUBE VIDEOS API] ${newVideos.length} NEW VIDEOS RETRIEVED.');
          }

          if (userIsDev && newVideos.isNotEmpty) {
            final String messageBody = newVideos.first.title.length > 175
                ? newVideos.first.title.replaceRange(175, null, '...')
                : newVideos.first.title;
            final String subject = newVideos.first.title.length > 200
                ? newVideos.first.title.replaceRange(200, null, '...')
                : newVideos.first.title;

            List<String> capitolBabbleNotificationsList =
                List<String>.from(userDatabase.get('capitolBabbleNotificationsList'));
            capitolBabbleNotificationsList.add(
                '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>regular<|:|>https://www.youtube.com/watch?v=${newVideos.first.id}');
            userDatabase.put('capitolBabbleNotificationsList', capitolBabbleNotificationsList);
          }

          if (!newUser && userDatabase.get('videoAlerts') && newVideos.isNotEmpty) {
            if (context == null || !ModalRoute.of(context).isCurrent) {
              await NotificationApi.showBigTextNotification(
                  12,
                  'videos',
                  'Congressional Videos',
                  'New congressional videos',
                  'New video',
                  'From ${newVideos.first.channel}',
                  newVideos.first.title,
                  'videos');
            } else if (ModalRoute.of(context).isCurrent) {
              Messages.showMessage(
                context: context,
                message: 'New video added',
                networkImageUrl: newVideos.first.thumbnail,
                isAlert: false,
                removeCurrent: false,
              );
            }
          }
        } else {
          debugPrint('[YOUTUBE VIDEOS API] NO NEW VIDEOS RETRIEVED.');
          return currentVideosList.isNotEmpty ? currentVideosList : [];
        }
        userDatabase.put('lastVideosRefresh', '${DateTime.now()}');
        return finalVideosList;
      } else {
        debugPrint('[YOUTUBE VIDEOS API] VIDEOS NOT UPDATED: API CALL ERROR');
        userDatabase.put('newVideos', false);
        return currentVideosList.isNotEmpty ? currentVideosList : [];
      }
    } else {
      debugPrint(
          '[YOUTUBE VIDEOS API] CURRENT VIDEO IDs: ${currentVideosList.map((e) => e.id)} *****');
      debugPrint('[YOUTUBE VIDEOS API] VIDEOS NOT UPDATED: LIST IS CURRENT *****');
      userDatabase.put('newVideos', false);
      return currentVideosList.isNotEmpty ? currentVideosList : [];
    }
  }

  static Future<List<ChannelVideos>> convertAllDates(allVideos) async {
    List<ChannelVideos> allDateCorrectedVideosList = [];
    for (ChannelVideos video in allVideos) {
      int amount = int.parse(video.date.split(' ')[0]);
      String period = video.date.split(' ')[1];
      Duration duration = period == 'second' || period == 'seconds'
          ? Duration(seconds: amount)
          : period == 'minute' || period == 'minutes'
              ? Duration(minutes: amount)
              : period == 'day' || period == 'days'
                  ? Duration(days: amount)
                  : period == 'hour' || period == 'hours'
                      ? Duration(hours: amount)
                      : const Duration(days: 0);
      DateTime convertedDateTime = DateTime.now().subtract(duration);
      allDateCorrectedVideosList.add(ChannelVideos(
          channel: video.channel,
          title: video.title,
          url: video.url,
          id: video.id,
          date: convertedDateTime.toIso8601String(),
          thumbnail: video.thumbnail));
      debugPrint(
          '[YouTube Videos API] [${video.id}] OLD DATE: ${video.date} -> NEW DATE: $convertedDateTime');
    }
    allDateCorrectedVideosList.sort((a, b) => b.date.compareTo(a.date));
    debugPrint(
        '[YouTube Videos API] SORTED => First Date: ${allDateCorrectedVideosList.first.date} - Last Date: ${allDateCorrectedVideosList.last.date}');
    return allDateCorrectedVideosList;
  }

  static Widget videoTile(
      BuildContext context,
      List<ChannelVideos> channelVideos,
      ChannelVideos thisChannelVideo,
      int index,
      Orientation orientation,
      InterstitialAd interstitialAd,
      bool randomImageActivated,
      List<bool> userLevels) {
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    // bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    // bool darkTheme = userDatabase.get('darkTheme');
    bool isCapitolBabble = thisChannelVideo.channel == 'Capitol Babble';
    Color capitolBabbleDark = const Color.fromARGB(255, 77, 0, 70);
    // Color capitolBabbleMainColor = Colors.purple;

    Color tileColor = isCapitolBabble ? capitolBabbleDark : Theme.of(context).primaryColorDark;
    Color textColor = darkThemeTextColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
      child: InkWell(
        enableFeedback: true,
        onTap: () => showModalBottomSheet(
          backgroundColor: Colors.transparent,
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.333,
              maxWidth: !kIsWeb && orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.width * 0.55
                  : kIsWeb && orientation == Orientation.landscape
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width,
              maxHeight: !kIsWeb && orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.height * 0.9
                  : MediaQuery.of(context).size.height),
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return BounceInUp(child: NewVideoPlayer(thisChannelVideo, channelVideos));
            // child: videoPlayer(context, channelVideos, thisChannelVideo, userLevels));
          },
        ).then((_) async {
          userDatabase.put('newVideos', false);
          await Functions.processCredits(true, isPermanent: false);
          AdMobLibrary.interstitialAdShow(interstitialAd);
        }),
        child: ZoomIn(
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: tileColor,
              image: isCapitolBabble
                  ? DecorationImage(
                      opacity: 0.3,
                      image: const AssetImage('assets/capitol_babble_bg.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(tileColor, BlendMode.color))
                  : DecorationImage(
                      opacity: 0.3,
                      image: AssetImage(
                          'assets/congress_pic_${randomImageActivated ? random.nextInt(4) : 0}.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(tileColor, BlendMode.color)),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: isCapitolBabble ? tileColor : Colors.transparent,
                  width: 2,
                  style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                            aspectRatio: 16 / 9,
                            child: FadeInImage(
                              image: thisChannelVideo.thumbnail == null ||
                                      thisChannelVideo.thumbnail.isEmpty
                                  ? AssetImage("assets/congress_pic_${random.nextInt(4)}.png")
                                  : NetworkImage(thisChannelVideo.thumbnail),
                              placeholder:
                                  AssetImage("assets/congress_pic_${random.nextInt(4)}.png"),
                              fit: BoxFit.cover,
                              placeholderFit: BoxFit.cover,
                            )),
                        CircleAvatar(
                            radius: 20,
                            backgroundColor: isCapitolBabble
                                ? capitolBabbleDark.withOpacity(0.5)
                                : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            child: Icon(Icons.play_arrow,
                                size: 30, color: darkThemeTextColor.withOpacity(0.75))),
                      ],
                    ),
                  ),
                ),
                orientation == Orientation.portrait
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                        width: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              thisChannelVideo.title
                                  .replaceAll('&amp;', '&')
                                  .replaceAll("&quot;", "\"")
                                  .replaceAll("&#39;", "'"),
                              softWrap: true,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: Styles.regularStyle.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('${thisChannelVideo.channel}  ',
                                          style: Styles.regularStyle.copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal,
                                              color: textColor)),
                                      const FaIcon(FontAwesomeIcons.calendar,
                                          size: 8, color: darkThemeTextColor),
                                      Text(
                                          '  ${dateWithDayFormatter.format(DateTime.parse(thisChannelVideo.date))}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Styles.regularStyle.copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal,
                                              color: textColor)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ))
                    : Flexible(
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                            // width: 170,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thisChannelVideo.title
                                      .replaceAll('&amp;', '&')
                                      .replaceAll("&quot;", "\"")
                                      .replaceAll("&#39;", "'"),
                                  softWrap: true,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: Styles.regularStyle.copyWith(
                                      fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('${thisChannelVideo.channel}  ',
                                              style: Styles.regularStyle.copyWith(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.normal,
                                                  color: textColor)),
                                          const FaIcon(FontAwesomeIcons.calendar,
                                              size: 8, color: darkThemeTextColor),
                                          Text(
                                              '  ${dateWithDayFormatter.format(DateTime.parse(thisChannelVideo.date))}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Styles.regularStyle.copyWith(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.normal,
                                                  color: textColor)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

//  /// SAMPLE API CALL DATA FOR TESTING
//   static const Map<String, dynamic> topCongressionalTestVideos = {
//     "retrieved-date": "2022-11-24T09:08:42.231Z",
//     "videos": [
//       {
//         "channel-name": "Bloomberg Politics",
//         "channel-id": "UCV61VqLMr2eIhH4f51PV0gA",
//         "channel-slug": "bloomberg",
//         "channel-url": "https://www.youtube.com/channel/UCV61VqLMr2eIhH4f51PV0gA/videos",
//         "channel-videos": [
//           {
//             "channel": "UPDATE CONGRESSIONAL-VIDEOS-API",
//             "title": "SOT Trump announces 2024 Run EXTENDED CUT",
//             "url": "https://www.youtube.com/watch?v=wJyl6zBspE8",
//             "id": "wJyl6zBspE8",
//             "date": "7 days ago",
//             "thumbnail": "https://i.ytimg.com/vi/wJyl6zBspE8/hqdefault.jpg"
//           }
//         ]
//       },
//       {
//         "channel-name": "Capitol Babble",
//         "channel-id": "UC4X_dh5dgyC0d6T3KkjFTTQ",
//         "channel-slug": "capitolbabble",
//         "channel-url": "https://www.youtube.com/channel/UC4X_dh5dgyC0d6T3KkjFTTQ/videos",
//         "channel-videos": []
//       },
//       {
//         "channel-name": "C-SPAN",
//         "channel-id": "UCb--64Gl51jIEVE-GLDAVTg",
//         "channel-slug": "cspan",
//         "channel-url": "https://www.youtube.com/channel/UCb--64Gl51jIEVE-GLDAVTg/videos",
//         "channel-videos": [
//           {
//             "channel": "UPDATE CONGRESSIONAL-VIDEOS-API",
//             "title":
//                 "Washington Today (11-22-22): Dr. Fauci at last WH briefing: before retirement ‘I gave it all I got’",
//             "url": "https://www.youtube.com/watch?v=AdUV6KPTQ6I",
//             "id": "AdUV6KPTQ6I",
//             "date": "1 day ago",
//             "thumbnail": "https://i.ytimg.com/vi/AdUV6KPTQ6I/hqdefault.jpg"
//           },
//           {
//             "channel": "UPDATE CONGRESSIONAL-VIDEOS-API",
//             "title": "Kevin McCarthy Calls for Resignation of Secretary Mayorkas",
//             "url": "https://www.youtube.com/watch?v=Xou3C1WTVbo",
//             "id": "Xou3C1WTVbo",
//             "date": "1 day ago",
//             "thumbnail": "https://i.ytimg.com/vi/Xou3C1WTVbo/hqdefault.jpg"
//           },
//           {
//             "channel": "UPDATE CONGRESSIONAL-VIDEOS-API",
//             "title": "CLIPS: Dr. Anthony Fauci Final White House Briefing",
//             "url": "https://www.youtube.com/watch?v=VR8qJaT9tQs",
//             "id": "VR8qJaT9tQs",
//             "date": "1 day ago",
//             "thumbnail": "https://i.ytimg.com/vi/VR8qJaT9tQs/hqdefault.jpg"
//           },
//           {
//             "channel": "UPDATE CONGRESSIONAL-VIDEOS-API",
//             "title":
//                 "The Weekly Podcast: Thanksgiving: Seven Things You Didn't Know About Dulles Airport",
//             "url": "https://www.youtube.com/watch?v=onicB3dKP1Y",
//             "id": "onicB3dKP1Y",
//             "date": "1 day ago",
//             "thumbnail": "https://i.ytimg.com/vi/onicB3dKP1Y/hqdefault.jpg"
//           },
//           {
//             "channel": "UPDATE CONGRESSIONAL-VIDEOS-API",
//             "title":
//                 "Booknotes+ : Mark Dimunation, Library of Congress Rare Book & Special Collections Division Chief",
//             "url": "https://www.youtube.com/watch?v=KNgS3sNhJFY",
//             "id": "KNgS3sNhJFY",
//             "date": "2 days ago",
//             "thumbnail": "https://i.ytimg.com/vi/KNgS3sNhJFY/hqdefault.jpg"
//           }
//         ]
//       },
//       {
//         "channel-name": "Politico",
//         "channel-id": "UCgjtvMmHXbutALaw9XzRkAg",
//         "channel-slug": "politico",
//         "channel-url": "https://www.youtube.com/channel/UCgjtvMmHXbutALaw9XzRkAg/videos",
//         "channel-videos": [
//           {
//             "channel": "UPDATE CONGRESSIONAL-VIDEOS-API",
//             "title": "Trump announces he’s running for president again, in 180 seconds",
//             "url": "https://www.youtube.com/watch?v=BQrKGpCzAvA",
//             "id": "BQrKGpCzAvA",
//             "date": "8 days ago",
//             "thumbnail": "https://i.ytimg.com/vi/BQrKGpCzAvA/hqdefault.jpg"
//           },
//           {
//             "channel": "UPDATE CONGRESSIONAL-VIDEOS-API",
//             "title": "These 10 people just made congressional history",
//             "url": "https://www.youtube.com/watch?v=k7O38bJemHY",
//             "id": "k7O38bJemHY",
//             "date": "13 days ago",
//             "thumbnail": "https://i.ytimg.com/vi/k7O38bJemHY/hqdefault.jpg"
//           }
//         ]
//       },
//       {
//         "channel-name": "Propublica",
//         "channel-id": "UCtCL58_DaVdVRmev3yHK7pg",
//         "channel-slug": "propublica",
//         "channel-url": "https://www.youtube.com/channel/UCtCL58_DaVdVRmev3yHK7pg/videos",
//         "channel-videos": [
//           {
//             "channel": "UPDATE CONGRESSIONAL-VIDEOS-API",
//             "title": "Honorary Consuls Trailer",
//             "url": "https://www.youtube.com/watch?v=t6oBc-5Mxyk",
//             "id": "t6oBc-5Mxyk",
//             "date": "8 days ago",
//             "thumbnail": "https://i.ytimg.com/vi/t6oBc-5Mxyk/hqdefault.jpg"
//           }
//         ]
//       }
//     ]
//   };

}

class NewVideoPlayer extends StatefulWidget {
  const NewVideoPlayer(this.selectedVideo, this.videoList, {Key key}) : super(key: key);
  final ChannelVideos selectedVideo;
  final List<ChannelVideos> videoList;

  @override
  NewVideoPlayerState createState() => NewVideoPlayerState();
}

class NewVideoPlayerState extends State<NewVideoPlayer> {
  Box userDatabase = Hive.box(appDatabase);

  List<bool> userLevels = [false, false, false];
  bool userIsPremium = false;
  bool userIsLegacy = false;
  bool userIsDev = false;

  bool darkTheme = false;
  bool isCapitolBabble = false;
  Color capitolBabbleDark = const Color.fromARGB(255, 77, 0, 70);
  Color tileColor;

  YoutubePlayerController controller;
  TextEditingController idController;
  TextEditingController seekToController;

  PlayerState playerState;
  YoutubeMetaData videoMetaData;
  double volume = 100;
  bool muted = false;
  bool isPlayerReady = false;

  List<String> ids = [];

  int headerImageCounter = 0;

  bool videoAlerts = false;
  List<ChannelVideos> youtubeVideosList = [];
  DateTime lastVideosRefresh = DateTime.now();
  bool newVideos = false;

  @override
  void initState() async {
    super.initState();
    setInitialVariables();
  }

  Future<void> setInitialVariables() async {
    await Functions.getUserLevels().then((levels) => setState(() {
          userLevels = levels;
          userIsDev = levels[0];
          userIsPremium = levels[1];
          userIsLegacy = levels[2];
        }));

    if (widget.videoList.isEmpty || widget.videoList == null) {
      try {
        List<ChannelVideos> xVideosList =
            topCongressionalVideosFromJson(userDatabase.get('youtubeVideosList'))
                .channels
                .map((e) => e.channelVideos)
                .expand((element) => element)
                .toList();
        await YouTubeVideosApi.convertAllDates(xVideosList)
            .then((value) => setState(() => youtubeVideosList = value));
      } catch (e) {
        logger.w('^^^^^ ERROR DURING YOUTUBE PLAYLIST INITIAL VARIABLES SETUP: $e ^^^^^');
        setState(() => youtubeVideosList = []);
        userDatabase.put('youtubeVideosList', {});
      }
    }

    setState(() => youtubeVideosList = widget.videoList);

    controller = YoutubePlayerController(
      initialVideoId: widget.selectedVideo.id,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);

    idController = TextEditingController();
    seekToController = TextEditingController();
    videoMetaData = const YoutubeMetaData();
    playerState = PlayerState.unknown;
    // });

    setState(() {
      headerImageCounter = random.nextInt(4);
      ids = widget.videoList.map((e) => e.id).toList();
      videoAlerts = userDatabase.get("videoAlerts");
      darkTheme = userDatabase.get('darkTheme');
      lastVideosRefresh = DateTime.parse(userDatabase.get("lastVideosRefresh"));
      newVideos = userDatabase.get("newVideos");
      darkTheme = userDatabase.get('darkTheme');
      isCapitolBabble = widget.selectedVideo.channel == 'Capitol Babble';
      capitolBabbleDark = const Color.fromARGB(255, 77, 0, 70);
      tileColor = isCapitolBabble
          ? capitolBabbleDark
          : darkTheme
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).primaryColorDark.withOpacity(0.25);
    });
  }

  void listener() {
    if (isPlayerReady && mounted && !controller.value.isFullScreen) {
      setState(() {
        playerState = controller.value.playerState;
        videoMetaData = controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    controller.dispose();
    idController.dispose();
    seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ids.isEmpty
        ? AnimatedWidgets.circularProgressWatchtower(context, userDatabase, userIsPremium,
            isFullScreen: true)
        : Container(
            decoration: BoxDecoration(
              color: isCapitolBabble ? capitolBabbleDark : Theme.of(context).colorScheme.background,
              image: isCapitolBabble
                  ? DecorationImage(
                      opacity: 0.3,
                      image: const AssetImage('assets/capitol_babble_bg.png'),
                      repeat: ImageRepeat.repeat,
                      // fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(tileColor, BlendMode.color))
                  : DecorationImage(
                      opacity: 0.3,
                      image: AssetImage('assets/congress_pic_$headerImageCounter.png'),
                      repeat: ImageRepeat.repeat,
                      // fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(tileColor, BlendMode.color)),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  decoration: BoxDecoration(
                    image: isCapitolBabble
                        ? DecorationImage(
                            opacity: 0.3,
                            image: const AssetImage('assets/capitol_babble_bg.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(tileColor, BlendMode.color))
                        : DecorationImage(
                            opacity: 0.3,
                            image: AssetImage('assets/congress_pic_$headerImageCounter.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(tileColor, BlendMode.color)),
                  ),
                  child: ListTile(
                    tileColor: Colors.transparent,
                    dense: true,
                    title: Text(
                      videoMetaData == null || videoMetaData.title.isEmpty
                          ? 'YOUR VIDEO IS LOADING.\nPLEASE STAND BY...'
                          : videoMetaData.title
                              .replaceAll('&amp;', '&')
                              .replaceAll("&quot;", "\"")
                              .replaceAll("&#39;", "'"),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.googleStyle.copyWith(color: darkThemeTextColor),
                    ),
                    trailing: IconButton(
                        icon: const Icon(Icons.close, color: darkThemeTextColor),
                        onPressed: () => Navigator.pop(context)),
                  ),
                ),
                YoutubePlayerBuilder(
                  onExitFullScreen: () {
                    // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
                    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
                  },
                  player: YoutubePlayer(
                    controller: controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
                    topActions: <Widget>[
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          controller.metadata.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 25.0,
                        ),
                        onPressed: () {
                          debugPrint('Settings Tapped!');
                        },
                      ),
                    ],
                    onReady: () {
                      isPlayerReady = true;
                    },
                    onEnded: (data) {
                      controller.load(ids[(ids.indexOf(data.videoId) + 1)]); // % ids.length]);
                      // _showSnackBar('Next Video Started!');
                    },
                  ),
                  builder: (context, player) => ListView(
                    shrinkWrap: true,
                    children: [
                      player,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // _space,
                            // _text('Title', videoMetaData.title),
                            _space,
                            _text('Channel', videoMetaData.author),
                            // _space,
                            // _text('Video Id', videoMetaData.videoId),
                            // _space,
                            // Row(
                            //   children: [
                            //     _text(
                            //       'Playback Quality',
                            //       controller.value.playbackQuality ?? '',
                            //     ),
                            //     const Spacer(),
                            //     _text(
                            //       'Playback Rate',
                            //       '${controller.value.playbackRate}x  ',
                            //     ),
                            //   ],
                            // ),
                            // _space,
                            // TextField(
                            //   enabled: isPlayerReady,
                            //   controller: idController,
                            //   decoration: InputDecoration(
                            //     border: InputBorder.none,
                            //     hintText: 'Enter youtube <video id> or <link>',
                            //     fillColor: Colors.blueAccent.withAlpha(20),
                            //     filled: true,
                            //     hintStyle: const TextStyle(
                            //       fontWeight: FontWeight.w300,
                            //       color: Colors.blueAccent,
                            //     ),
                            //     suffixIcon: IconButton(
                            //       icon: const Icon(Icons.clear),
                            //       onPressed: () => idController.clear(),
                            //     ),
                            //   ),
                            // ),
                            // _space,
                            // Row(
                            //   children: [
                            //     _loadCueButton('LOAD'),
                            //     const SizedBox(width: 10.0),
                            //     _loadCueButton('CUE'),
                            //   ],
                            // ),
                            _space,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.skip_previous,
                                    color: ids.indexOf(controller.metadata.videoId) > 0
                                        ? darkThemeTextColor
                                        : null,
                                  ),
                                  onPressed:
                                      isPlayerReady && ids.indexOf(controller.metadata.videoId) > 0
                                          ? () => controller.load(ids[
                                              (ids.indexOf(controller.metadata.videoId) -
                                                  1)]) //  % ids.length])
                                          : null,
                                ),
                                IconButton(
                                  icon: Icon(
                                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: darkThemeTextColor,
                                  ),
                                  onPressed: isPlayerReady
                                      ? () {
                                          controller.value.isPlaying
                                              ? controller.pause()
                                              : controller.play();
                                          setState(() {});
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(
                                    muted ? Icons.volume_off : Icons.volume_up,
                                    color: darkThemeTextColor,
                                  ),
                                  onPressed: isPlayerReady
                                      ? () {
                                          muted ? controller.unMute() : controller.mute();
                                          setState(() {
                                            muted = !muted;
                                          });
                                        }
                                      : null,
                                ),
                                FullScreenButton(
                                  controller: controller,
                                  color: darkThemeTextColor,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.skip_next,
                                    color: darkThemeTextColor,
                                  ),
                                  onPressed: isPlayerReady &&
                                          ids.indexOf(controller.metadata.videoId) < ids.length
                                      ? () => controller.load(ids[
                                          (ids.indexOf(controller.metadata.videoId) +
                                              1)]) //  % ids.length])
                                      : null,
                                ),
                              ],
                            ),
                            _space,
                            Row(
                              children: <Widget>[
                                Text(
                                  "Volume",
                                  style: Styles.googleStyle.copyWith(color: darkThemeTextColor),
                                  // style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                Expanded(
                                  child: Slider(
                                    inactiveColor: Colors.transparent,
                                    activeColor: darkThemeTextColor,
                                    thumbColor: darkThemeTextColor,
                                    value: volume,
                                    min: 0.0,
                                    max: 100.0,
                                    divisions: 10,
                                    label: '${(volume).round()}',
                                    onChanged: isPlayerReady
                                        ? (value) {
                                            setState(() {
                                              volume = value;
                                            });
                                            controller.setVolume(volume.round());
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            _space,
                            AnimatedContainer(
                              height: 4,
                              duration: const Duration(milliseconds: 800),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: _getStateColor(playerState),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              // child: Text(
                              //   playerState.toString(),
                              //   style: const TextStyle(
                              //     fontWeight: FontWeight.w300,
                              //     color: Colors.white,
                              //   ),
                              //   textAlign: TextAlign.center,
                              // ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '', // '''$title : ',
        style: Styles.googleStyle.copyWith(color: darkThemeTextColor),
        // style: const TextStyle(
        //   color: darkThemeTextColor ,
        //   fontWeight: FontWeight.bold,
        // ),
        children: [
          TextSpan(
            text: value,
            style: Styles.googleStyle.copyWith(color: darkThemeTextColor),
            // style: const TextStyle(
            //   color: darkThemeTextColor,
            //   fontWeight: FontWeight.w300,
            // ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Theme.of(context).primaryColorDark; // Colors.grey[700];
      case PlayerState.unStarted:
        return Theme.of(context).primaryColorDark; // Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return darkTheme
            ? alertIndicatorColorBrightGreen
            : alertIndicatorColorDarkGreen; // Colors.blueAccent;
      case PlayerState.paused:
        return altHighlightColor; // Colors.orange;
      case PlayerState.buffering:
        return Colors.white;
      case PlayerState.cued:
        return altHighlightColor; // Colors.blue[900];
      default:
        return Theme.of(context).primaryColorDark; // Colors.blue;
    }
  }

  Widget get _space => const SizedBox(height: 10);
//
//   // Widget _loadCueButton(String action) {
//   //   return Expanded(
//   //     child: MaterialButton(
//   //       color: Colors.blueAccent,
//   //       onPressed: isPlayerReady
//   //           ? () {
//   //               if (idController.text.isNotEmpty) {
//   //                 var id = YoutubePlayer.convertUrlToId(
//   //                       idController.text,
//   //                     ) ??
//   //                     '';
//   //                 if (action == 'LOAD') controller.load(id);
//   //                 if (action == 'CUE') controller.cue(id);
//   //                 FocusScope.of(context).requestFocus(FocusNode());
//   //               } else {
//   //                 _showSnackBar('Source can\'t be empty!');
//   //               }
//   //             }
//   //           : null,
//   //       disabledColor: Colors.grey,
//   //       disabledTextColor: Colors.black,
//   //       child: Padding(
//   //         padding: const EdgeInsets.symmetric(vertical: 14.0),
//   //         child: Text(
//   //           action,
//   //           style: const TextStyle(
//   //             fontSize: 18.0,
//   //             color: Colors.white,
//   //             fontWeight: FontWeight.w300,
//   //           ),
//   //           textAlign: TextAlign.center,
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   // void _showSnackBar(String message) {
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content: Text(
//   //         message,
//   //         textAlign: TextAlign.center,
//   //         style: const TextStyle(
//   //           fontWeight: FontWeight.w300,
//   //           fontSize: 16.0,
//   //         ),
//   //       ),
//   //       backgroundColor: Colors.blueAccent,
//   //       behavior: SnackBarBehavior.floating,
//   //       elevation: 1.0,
//   //       shape: RoundedRectangleBorder(
//   //         borderRadius: BorderRadius.circular(50.0),
//   //       ),
//   //     ),
//   //   );
//   // }
}
