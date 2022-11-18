// To parse this JSON data, do
//
//     final topCongressionalVideos = topCongressionalVideosFromJson(jsonString);

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:us_congress_vote_tracker/constants/animated_widgets.dart';
import 'package:us_congress_vote_tracker/services/youtube/youtube_playlist_model.dart';
import 'dart:convert';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../constants/constants.dart';
import '../../functions/functions.dart';

TopCongressionalVideos topCongressionalVideosFromJson(String str) =>
    TopCongressionalVideos.fromJson(json.decode(str));

String topCongressionalVideosToJson(TopCongressionalVideos data) => json.encode(data.toJson());

class TopCongressionalVideos {
  TopCongressionalVideos({
    @required this.retrievedDate,
    @required this.videos,
  });

  final DateTime retrievedDate;
  final List<Video> videos;

  factory TopCongressionalVideos.fromJson(Map<String, dynamic> json) => TopCongressionalVideos(
        retrievedDate: DateTime.parse(json["retrieved-date"]),
        videos: List<Video>.from(json["videos"].map((x) => Video.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "retrieved-date": retrievedDate.toIso8601String(),
        "videos": List<dynamic>.from(videos.map((x) => x.toJson())),
      };
}

class Video {
  Video({
    @required this.channelName,
    @required this.channelId,
    @required this.channelVideos,
  });

  final String channelName;
  final String channelId;
  final List<String> channelVideos;

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        channelName: json["channel-name"],
        channelId: json["channel-id"],
        channelVideos: List<String>.from(json["channel-videos"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "channel-name": channelName,
        "channel-id": channelId,
        "channel-videos": List<dynamic>.from(channelVideos.map((x) => x)),
      };
}

List<YoutubePlaylistItem> youtubePlaylistItemFromJson(String str) =>
    List<YoutubePlaylistItem>.from(json.decode(str).map((x) => YoutubePlaylistItem.fromJson(x)));

String youtubePlaylistItemToJson(List<YoutubePlaylistItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class YoutubePlaylistItem {
  YoutubePlaylistItem({
    @required this.videoId,
    @required this.title,
    @required this.author,
    @required this.duration,
  });

  final String videoId;
  final String title;
  final String author;
  final Duration duration;

  factory YoutubePlaylistItem.fromJson(Map<String, dynamic> json) => YoutubePlaylistItem(
        videoId: json["video-id"],
        title: json["title"],
        author: json["author"],
        duration: Duration(seconds: json['duration']),
      );

  Map<String, dynamic> toJson() => {
        "video-id": videoId,
        "title": title,
        "author": author,
        "duration": duration.inSeconds,
      };

  @override
  String toString() {
    return "VIDEO ID: $videoId - TITLE: $title - AUTHOR: $author - DURATION (SEC): $duration";
  }
}

class YouTubeVideosApi {
  /// RETRIEVE YOUTUBE VIDEO IDs AND SAVE THEM TO DBASE
  static Future<List<String>> getYoutubeVideoIds({BuildContext context}) async {
    Box userDatabase = Hive.box(appDatabase);
    List<String> retrievedVideosList = [];
    // List<YoutubePlaylistItem> finalPlaylist = [];
    List<String> currentVideoListIds = [];
    // List<YoutubePlaylistItem> currentPlaylist = [];

    try {
      currentVideoListIds = List.from(userDatabase.get('youtubeVideoIds'));
      // currentPlaylist = youtubePlaylistItemFromJson(userDatabase.get('youtubeVideoList'));
    } catch (e) {
      debugPrint('YouTube Videos API] ERROR:$e');
    }

    List<String> finalVideoListIds = [];

    if (currentVideoListIds.isEmpty ||
        DateTime.parse(userDatabase.get('lastRefresh')).isBefore(DateTime.now()
            .subtract(context == null ? const Duration(hours: 1) : const Duration(minutes: 10)))) {
      /// API CALL WILL GO HERE
      TopCongressionalVideos retrievedData =
          topCongressionalVideosFromJson(jsonEncode(topCongressionalTestVideos));

      /// EXTRACT ALL VIDEO URLs FROM EACH ELEMENT AND CREATE ONE LIST
      retrievedData.videos
          .map((e) => e.channelVideos)
          .forEach((element) => retrievedVideosList.addAll(element));

      /// STRIP EACH URL DOWN AND LEAVE ONLY THE VIDEO IDs
      for (String link in retrievedVideosList) {
        // final String thisId = link.split('v=').last;

        // YoutubePlayerController controller = YoutubePlayerController(
        //   initialVideoId: thisId,
        //   // flags: const YoutubePlayerFlags(
        //   //   mute: false,
        //   //   autoPlay: true,
        //   //   disableDragSeek: false,
        //   //   loop: false,
        //   //   isLive: false,
        //   //   forceHD: false,
        //   //   enableCaption: true,
        //   // ),
        // );
        // YoutubeMetaData thisMetaData = YoutubeMetaData(
        //     videoId: controller.metadata.videoId,
        //     title: controller.metadata.title,
        //     author: controller.metadata.author,
        //     duration: controller.metadata.duration);

        // final String videoId = controller.metadata.videoId;
        // final String title = controller.metadata.title;
        // final String author = controller.metadata.author;
        // final Duration duration = controller.metadata.duration;

        // finalPlaylist.add(YoutubePlaylistItem(
        //     videoId: videoId, title: title, author: author, duration: duration));
        // debugPrint(
        //     'YouTube Videos API] THIS VIDEO ID: $videoId TITLE: $title AUTHOR: $author DURATION: $duration');

        finalVideoListIds.add(link.split('v=').last);
      }

      debugPrint('YouTube Videos API] ALL VIDEO IDs:\n$finalVideoListIds');
      // debugPrint('YouTube Videos API] PLAYLIST ITEMS:\n${finalPlaylist.map((e) => e.toString())}');

      /// SAVE LISTS TO DBASE
      userDatabase.put('youtubeVideoIds', finalVideoListIds);
      // userDatabase.put('youtubeVideoList', youtubePlaylistItemToJson(finalPlaylist));
      return finalVideoListIds;
    } else {
      debugPrint('YouTube Videos API] CURRENT VIDEO IDs: $currentVideoListIds *****');
      // debugPrint(
      //     'YouTube Videos API] CURRENT PLAYLIST ITEMS: ${currentPlaylist.map((e) => e.toString())} *****');
      finalVideoListIds = currentVideoListIds;
      // finalPlaylist = currentPlaylist;
      debugPrint('[YouTube Videos API] VIDEOS NOT UPDATED: LIST IS CURRENT *****');
      userDatabase.put('newVideos', false);
      return finalVideoListIds;
    }
  }

  // static Widget youtubeTestWidget(List<String> videoIds) {
  //   return Row(children: [
  //     ListView.builder(
  //         shrinkWrap: true,
  //         scrollDirection: Axis.horizontal,
  //         itemCount: 3,
  //         itemBuilder: (context, index) {
  //           return const Card();
  //         })
  //   ]);
  // }

  /// SAMPLE API CALL DATA FOR TESTING
  static const Map<String, dynamic> topCongressionalTestVideos = {
    "retrieved-date": "2022-11-12T05:23:34.558Z",
    "videos": [
      {
        "channel-name": "Capitol Babble",
        "channel-id": "UC4X_dh5dgyC0d6T3KkjFTTQ",
        "channel-videos": [
          "https://www.youtube.com/watch?v=iwjljRYrgnU",
          "https://www.youtube.com/watch?v=NLPadGQ9pxE",
          "https://www.youtube.com/watch?v=haB4AmJRRjI",
          "https://www.youtube.com/watch?v=lPKDYlfRsIU",
          "https://www.youtube.com/watch?v=_umNNqKTiPE"
        ]
      },
      {
        "channel-name": "C-SPAN",
        "channel-id": "UCb--64Gl51jIEVE-GLDAVTg",
        "channel-videos": [
          "https://www.youtube.com/watch?v=6TmYAV5STiY",
          "https://www.youtube.com/watch?v=eU7RcFzdpRI",
          "https://www.youtube.com/watch?v=50XDq4oTFBg",
          "https://www.youtube.com/watch?v=ZTl7HW1fRvE",
          "https://www.youtube.com/watch?v=86N-E2uixHk"
        ]
      },
      {
        "channel-name": "Politico",
        "channel-id": "UCgjtvMmHXbutALaw9XzRkAg",
        "channel-videos": [
          "https://www.youtube.com/watch?v=k7O38bJemHY",
          "https://www.youtube.com/watch?v=mLsCaXQ25Gg",
          "https://www.youtube.com/watch?v=g96f_O26WLo",
          "https://www.youtube.com/watch?v=PTKII4lsqCQ",
          "https://www.youtube.com/watch?v=BJ1hR44Mys0"
        ]
      }
    ]
  };
}

/// Creates [YoutubePlayerDemoApp] widget.
class YoutubePlayerDemoApp extends StatelessWidget {
  const YoutubePlayerDemoApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'US Congress Video Player',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   appBarTheme: const AppBarTheme(
      //     color: Colors.blueAccent,
      //     titleTextStyle: TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.w300,
      //       fontSize: 20,
      //     ),
      //   ),
      //   iconTheme: const IconThemeData(
      //     color: Colors.blue,
      //   ),
      // ),
      home: NewVideoPage(),
    );
  }
}

/// Homepage
class NewVideoPage extends StatefulWidget {
  const NewVideoPage({Key key}) : super(key: key);

  @override
  NewVideoPageState createState() => NewVideoPageState();
}

class NewVideoPageState extends State<NewVideoPage> {
  Box userDatabase = Hive.box(appDatabase);

  YoutubePlayerController controller;
  TextEditingController idController;
  TextEditingController seekToController;

  PlayerState playerState;
  YoutubeMetaData videoMetaData;
  double volume = 100;
  bool muted = false;
  bool isPlayerReady = false;

  List<bool> userLevels = [false, false, false];
  bool userIsPremium = false;
  bool userIsLegacy = false;
  bool userIsDev = false;

  List<String> ids = [
    // 'nPt8bK2gbaU',
    // 'gQDByCdjUXw',
    // 'iLnmTe5Q2Qw',
    // '_WoCV4c6XOE',
    // 'KmzdUe0RSJo',
    // '6jZDSSZZxjQ',
    // 'p2lYr3vM_1w',
    // '7QUtEmBT_-w',
    // '34_PXCzGw1M',
  ];

  @override
  void initState() async {
    super.initState();
    setInitialVariables();
  }

  Future<void> setInitialVariables() async {
    // setState(() async => ids = await YouTubeApiTest.youtubeVideosList());
    // await YouTubeApi.getYoutubeVideoIdsList(userDatabase).then((value) {
    // setState(() => ids = value);
    setState(() => ids = List.from(userDatabase.get('youtubeVideoIds')));
    controller = YoutubePlayerController(
      initialVideoId: ids.first,
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

    await Functions.getUserLevels().then((levels) => setState(() {
          userLevels = levels;
          userIsDev = levels[0];
          userIsPremium = levels[1];
          userIsLegacy = levels[2];
        }));
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
        : YoutubePlayerBuilder(
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
                controller.load(ids[(ids.indexOf(data.videoId) + 1) % ids.length]);
                _showSnackBar('Next Video Started!');
              },
            ),
            builder: (context, player) => Scaffold(
              appBar: AppBar(
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Image.asset(
                    'assets/ypf.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                title: const Text(
                  'Youtube Player Flutter',
                  style: TextStyle(color: Colors.white),
                ),
                // actions: [
                // IconButton(
                //   icon: const Icon(Icons.video_library),
                //   onPressed: () => Navigator.push(
                //     context,
                //     CupertinoPageRoute(
                //       builder: (context) => VideoList(),
                //     ),
                //   ),
                // ),
                // ],
              ),
              body: ListView(
                children: [
                  player,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _space,
                        _text('Title', videoMetaData.title),
                        _space,
                        _text('Channel', videoMetaData.author),
                        _space,
                        _text('Video Id', videoMetaData.videoId),
                        _space,
                        Row(
                          children: [
                            _text(
                              'Playback Quality',
                              controller.value.playbackQuality ?? '',
                            ),
                            const Spacer(),
                            _text(
                              'Playback Rate',
                              '${controller.value.playbackRate}x  ',
                            ),
                          ],
                        ),
                        _space,
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
                        // _space,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous),
                              onPressed: isPlayerReady
                                  ? () => controller.load(ids[
                                      (ids.indexOf(controller.metadata.videoId) - 1) % ids.length])
                                  : null,
                            ),
                            IconButton(
                              icon: Icon(
                                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
                              icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
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
                              color: Colors.blueAccent,
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next),
                              onPressed: isPlayerReady
                                  ? () => controller.load(ids[
                                      (ids.indexOf(controller.metadata.videoId) + 1) % ids.length])
                                  : null,
                            ),
                          ],
                        ),
                        _space,
                        Row(
                          children: <Widget>[
                            const Text(
                              "Volume",
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                            Expanded(
                              child: Slider(
                                inactiveColor: Colors.transparent,
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
                          duration: const Duration(milliseconds: 800),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: _getStateColor(playerState),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            playerState.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700];
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900];
      default:
        return Colors.blue;
    }
  }

  Widget get _space => const SizedBox(height: 10);

  Widget _loadCueButton(String action) {
    return Expanded(
      child: MaterialButton(
        color: Colors.blueAccent,
        onPressed: isPlayerReady
            ? () {
                if (idController.text.isNotEmpty) {
                  var id = YoutubePlayer.convertUrlToId(
                        idController.text,
                      ) ??
                      '';
                  if (action == 'LOAD') controller.load(id);
                  if (action == 'CUE') controller.cue(id);
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  _showSnackBar('Source can\'t be empty!');
                }
              }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
