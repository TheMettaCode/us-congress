// import 'package:better_player/better_player.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:us_congress_vote_tracker/constants/constants.dart';
import 'package:us_congress_vote_tracker/constants/styles.dart';
import 'package:us_congress_vote_tracker/constants/themes.dart';
import 'package:us_congress_vote_tracker/functions/functions.dart';
import 'package:us_congress_vote_tracker/services/admob/admob_ad_library.dart';
import 'package:us_congress_vote_tracker/services/notifications/notification_api.dart';
import 'package:us_congress_vote_tracker/services/youtube/youtube_playlist_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart' as ytWeb;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Youtube {
  Widget videoPlayer(BuildContext context, List<PlaylistItem> _playlist,
      PlaylistItem thisVideo, List<bool> userLevels) {
    Box userDatabase = Hive.box<dynamic>(appDatabase);

    // List<bool> userLevels = await Functions.getUserLevels();
    // bool userIsDev = userLevels[0];
    bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];
    // ytWeb.YoutubePlayerController _webController;
    YoutubePlayerController _controller;
    // ignore: unused_local_variable
    bool _isPlayerReady = false;
    bool darkTheme = userDatabase.get('darkTheme');
    bool isCapitolBabble =
        thisVideo.snippet.videoOwnerChannelTitle == 'Capitol Babble';
    Color capitolBabbleDark = Color.fromARGB(255, 77, 0, 70);
    Color tileColor = isCapitolBabble
        ? capitolBabbleDark
        : darkTheme
            ? Theme.of(context).primaryColorDark
            : null;

    // if (kIsWeb) {
    //   _webController = ytWeb.YoutubePlayerController(
    //     initialVideoId: _playlist[0].id,
    //     params: ytWeb.YoutubePlayerParams(
    //       playlist: [
    //         thisVideo.snippet.resourceId.videoId
    //       ], // Defining custom playlist
    //       autoPlay: true,
    //       startAt: Duration(seconds: 0),
    //       // desktopMode: true,
    //       showControls: true,
    //       showFullscreenButton: true,
    //     ),
    //   );
    //
    //   ytWeb.YoutubePlayer(
    //     controller: _webController,
    //     aspectRatio: 16 / 9,
    //   );
    // } else {
      _controller = YoutubePlayerController(
        initialVideoId: thisVideo.snippet.resourceId.videoId,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: false,
          controlsVisibleAtStart: false,
          enableCaption: true,
        ),
      );
    // }

    ////////////////////////////////////////////////
    /// UNDER DEVELOPMENT               ////////////
    /// FULL PLAYLIST HORIZONTAL SCROLL ////////////
    ////////////////////////////////////////////////
    ///
    // return Container(
    //   height: 350,
    //   child: ListView.builder(
    //       scrollDirection: Axis.vertical,
    //       shrinkWrap: true,
    //       itemCount: _playlist.length,
    //       itemBuilder: (context, index) {
    //         return ListView(shrinkWrap: true, children: <Widget>[
    //           ListTile(
    //             dense: true,
    //             title: Text(
    //               _playlist[index]
    //                   .snippet
    //                   .title
    //                   .replaceAll('&amp;', '&')
    //                   .replaceAll("&quot;", "\"")
    //                   .replaceAll("&#39;", "'"),
    //               style: Styles.googleStyle,
    //             ),
    //             subtitle: Row(
    //               children: [
    //                 Text('${thisVideo.snippet.videoOwnerChannelTitle}',
    //                     style: Styles.regularStyle.copyWith(
    //                         fontWeight: FontWeight.bold, fontSize: 11)),
    //                 Text(
    //                     ' | ${dateWithTimeFormatter.format(DateTime.parse(thisVideo.snippet.publishedAt.toString()).toLocal())}',
    //                     style: Styles.regularStyle.copyWith(fontSize: 10))
    //               ],
    //             ),
    //             trailing: IconButton(
    //                 icon: Icon(Icons.close),
    //                 onPressed: () => Navigator.pop(context)),
    //           ),
    //           AspectRatio(
    //             aspectRatio: 16 / 9,
    //             child: Container(
    //               color: Theme.of(context).colorScheme.secondary,
    //               child: kIsWeb
    //                   ? ytWeb.YoutubePlayerIFrame(
    //                       controller: _webController,
    //                       aspectRatio: 16 / 9,
    //                     )
    //                   : YoutubePlayer(
    //                       controller: _controller,
    //                       showVideoProgressIndicator: true,
    //                       aspectRatio: 16 / 9,
    //                       progressIndicatorColor:
    //                           Theme.of(context).primaryColor,
    //                       progressColors: ProgressBarColors(
    //                           backgroundColor:
    //                               Theme.of(context).colorScheme.secondary,
    //                           playedColor: Theme.of(context).primaryColor,
    //                           handleColor: Theme.of(context).primaryColor,
    //                           bufferedColor:
    //                               Theme.of(context).primaryColorLight),
    //                       onReady: () {
    //                         _isPlayerReady = true;
    //                         // _controller.addListener(listener);
    //                       },
    //                       // onEnded: (youtubeMetaData) {},
    //                     ),
    //             ),
    //           ),
    //           TextButton(
    //             child: Padding(
    //               padding: const EdgeInsets.all(10.0),
    //               child: Text(
    //                 'Advertise Here',
    //                 style: Styles.googleStyle,
    //               ),
    //             ),
    //             onPressed: () => Functions.linkLaunch(
    //                 context, developerWebLink, developerWebLink),
    //           ),
    //         ]);
    //       }),
    // );

    return Container(
      color: isCapitolBabble
          ? capitolBabbleDark
          : Theme.of(context).colorScheme.background,
      child: ListView(shrinkWrap: true, children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          decoration: BoxDecoration(
            image: isCapitolBabble
                ? DecorationImage(
                    opacity: 0.3,
                    image: AssetImage('assets/capitol_babble_bg.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(tileColor, BlendMode.color))
                : DecorationImage(
                    opacity: 0.3,
                    image: AssetImage(
                        'assets/congress_pic_${random.nextInt(4)}.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(tileColor, BlendMode.color)),
          ),
          child: ListTile(
            tileColor: Colors.transparent,
            dense: true,
            title: Text(
              thisVideo.snippet.title
                  .replaceAll('&amp;', '&')
                  .replaceAll("&quot;", "\"")
                  .replaceAll("&#39;", "'"),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Styles.googleStyle
                  .copyWith(color: isCapitolBabble ? darkThemeTextColor : null),
            ),
            // subtitle: InkWell(
            //   // onTap: () => Functions.linkLaunch(
            //   //     context, 'https://www.youtube.com/watch?v=${thisVideo.id}'),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       FaIcon(FontAwesomeIcons.youtube,
            //           size: 9,
            //           color: isCapitolBabble ? darkThemeTextColor : null),
            //       Text(' ${thisVideo.snippet.videoOwnerChannelTitle}',
            //           style: Styles.regularStyle.copyWith(
            //               fontWeight: FontWeight.bold,
            //               fontSize: 11,
            //               color: isCapitolBabble ? darkThemeTextColor : null)),
            //       // Text(
            //       //     ' | ${dateWithTimeFormatter.format(DateTime.parse(thisVideo.snippet.publishedAt.toString()).toLocal())}',
            //       //     style: Styles.regularStyle.copyWith(fontSize: 10))
            //     ],
            //   ),
            // ),
            trailing: IconButton(
                icon: Icon(Icons.close,
                    color: isCapitolBabble ? darkThemeTextColor : null),
                onPressed: () => Navigator.pop(context)),
          ),
        ),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: isCapitolBabble
                ? capitolBabbleDark
                : Theme.of(context).primaryColor.withOpacity(0.15),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              aspectRatio: 16 / 9,
              progressIndicatorColor: Theme.of(context).primaryColor,
              progressColors: isCapitolBabble
                  ? ProgressBarColors(
                      backgroundColor: capitolBabbleDark.withOpacity(0.15),
                      playedColor: capitolBabbleDark,
                      handleColor: capitolBabbleDark,
                      bufferedColor: capitolBabbleDark.withOpacity(0.35))
                  : ProgressBarColors(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.15),
                      playedColor: Theme.of(context).primaryColorDark,
                      handleColor: Theme.of(context).primaryColor,
                      bufferedColor: Theme.of(context).primaryColorLight),
              onReady: () {
                _isPlayerReady = true;
                // _controller.addListener(listener);
              },
              onEnded: (youtubeMetaData) => Navigator.maybePop(context),
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          // height: 30,
          color: isCapitolBabble
              ? capitolBabbleDark
              : Theme.of(context).primaryColorDark,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: SizedBox(
              height: 30,
              child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Functions.linkLaunch(
                      context,
                      'https://www.youtube.com/channel/${thisVideo.snippet.videoOwnerChannelId}',
                      userDatabase,
                      userIsPremium,
                    );
                  },
                  icon: FaIcon(FontAwesomeIcons.youtube,
                      size: 10, color: darkThemeTextColor),
                  label: Text(
                    thisVideo.snippet.videoOwnerChannelTitle,
                    style: Styles.regularStyle
                        .copyWith(fontSize: 12, color: darkThemeTextColor),
                  )),
            ),
          ),
        )
      ]),
    );
  }

  Widget youTubeVideoTile(
      BuildContext context,
      List<PlaylistItem> _playlist,
      PlaylistItem _thisVideo,
      int index,
      Orientation orientation,
      InterstitialAd interstitialAd,
      bool randomImageActivated,
      List<bool> userLevels) {
    Box userDatabase = Hive.box<dynamic>(appDatabase);
    bool technicalDifficulties =
        _thisVideo.snippet.description.contains('technical difficulties')
            ? true
            : false;
    String technicalDifficultiesText =
        'Our video list is currently experiencing technical difficulties... Please stand by.';

    // bool darkTheme = userDatabase.get('darkTheme');
    bool isCapitolBabble =
        _thisVideo.snippet.videoOwnerChannelTitle == 'Capitol Babble';
    Color capitolBabbleDark = Color.fromARGB(255, 77, 0, 70);
    // Color capitolBabbleMainColor = Colors.purple;

    Color tileColor = isCapitolBabble
        ? capitolBabbleDark
        : Theme.of(context).primaryColorDark;
    Color textColor = darkThemeTextColor;

    // debugPrint(
    //     'Video No $index: ${_thisVideo.snippet.thumbnails.thumbnailsDefault.url}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
      child: InkWell(
        enableFeedback: true,
        onTap: technicalDifficulties
            ? null
            : () => showModalBottomSheet(
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
                    return BounceInUp(
                        child: videoPlayer(
                            context, _playlist, _thisVideo, userLevels));
                  },
                ).then((_) async {
                  userDatabase.put('newVideos', false);
                  await Functions.processCredits(true, isPermanent: false);
                  if (interstitialAd != null &&
                      interstitialAd.responseInfo.responseId !=
                          userDatabase.get('interstitialAdId'))
                    AdMobLibrary().interstitialAdShow(interstitialAd);
                }),
        child: ZoomIn(
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: tileColor,
              image: isCapitolBabble
                  ? DecorationImage(
                      opacity: 0.3,
                      image: AssetImage('assets/capitol_babble_bg.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(tileColor, BlendMode.color))
                  : DecorationImage(
                      opacity: 0.3,
                      image: AssetImage(
                          'assets/congress_pic_${randomImageActivated ? random.nextInt(4) : 0}.png'),
                      fit: BoxFit.cover,
                      colorFilter:
                          ColorFilter.mode(tileColor, BlendMode.color)),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: isCapitolBabble ? tileColor : Colors.transparent,
                  width: 2,
                  style: BorderStyle.solid),
              // boxShadow: [
              //   BoxShadow(
              //     color: isCapitolBabble
              //         ? darkThemeTextColor //  altHighlightColor
              //         : Colors.transparent,
              //     blurRadius: 3.5,
              //     spreadRadius: 0.5,
              //     blurStyle: BlurStyle.normal,
              //     offset: Offset(
              //       0.0,
              //       0.0,
              //     ),
              //   ),
              // ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: FadeInImage(
                          image: _thisVideo.snippet.thumbnails.thumbnailsDefault
                                          .url ==
                                      null ||
                                  _thisVideo.snippet.thumbnails
                                      .thumbnailsDefault.url.isEmpty
                              ? AssetImage(
                                  "assets/congress_pic_${random.nextInt(4)}.png")
                              : NetworkImage(_thisVideo
                                  .snippet.thumbnails.thumbnailsDefault.url),
                          placeholder: AssetImage(
                              "assets/congress_pic_${random.nextInt(4)}.png"),
                          // imageErrorBuilder: (context, error, stackTrace) {
                          //   return Image.asset(
                          //       'assets/congress_pic_${random.nextInt(4)}.png',
                          //       fit: BoxFit.fitWidth);
                          // },
                          fit: BoxFit.cover,
                          placeholderFit: BoxFit.cover,
                        )
                        // _thisVideo.snippet.thumbnails == null
                        //     ? Image.asset(
                        //         'assets/congress_pic_${random.nextInt(4)}.png',
                        //         fit: BoxFit.cover,
                        //         // filterQuality: FilterQuality.medium,
                        //       )
                        //     : Image.network(
                        //         _thisVideo.snippet.thumbnails.maxres.url ??
                        //             _thisVideo.snippet.thumbnails.high.url ??
                        //             _thisVideo.snippet.thumbnails.medium.url ??
                        //             _thisVideo.snippet.thumbnails.standard.url ??
                        //             _thisVideo
                        //                 .snippet.thumbnails.thumbnailsDefault.url,
                        //         fit: BoxFit.cover,
                        //         filterQuality: FilterQuality.high,
                        //         errorBuilder: (context, widget, error) {},
                        //       ),
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
                              technicalDifficulties
                                  ? technicalDifficultiesText
                                  : _thisVideo.snippet.title
                                      .replaceAll('&amp;', '&')
                                      .replaceAll("&quot;", "\"")
                                      .replaceAll("&#39;", "'"),
                              softWrap: true,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: Styles.regularStyle.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textColor),
                            ),
                            technicalDifficulties
                                ? SizedBox.shrink()
                                : Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            FaIcon(FontAwesomeIcons.youtube,
                                                size: 10,
                                                color: darkThemeTextColor),
                                            Text(
                                                ' ${_thisVideo.snippet.videoOwnerChannelTitle}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Styles.regularStyle
                                                    .copyWith(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: textColor)),
                                          ],
                                        ),
                                        // Text(
                                        //     '| ${dateWithTimeFormatter.format(DateTime.parse(_thisVideo.snippet.publishedAt.toString()).toLocal())}',
                                        //     style: Styles.regularStyle.copyWith(
                                        //         fontSize: 10,
                                        //         fontWeight: FontWeight.normal,
                                        //         color: textColor)),
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
                                  technicalDifficulties
                                      ? technicalDifficultiesText
                                      : _thisVideo.snippet.title
                                          .replaceAll('&amp;', '&')
                                          .replaceAll("&quot;", "\"")
                                          .replaceAll("&#39;", "'"),
                                  softWrap: true,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: Styles.regularStyle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textColor),
                                ),
                                technicalDifficulties
                                    ? SizedBox.shrink()
                                    : Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                FaIcon(FontAwesomeIcons.youtube,
                                                    size: 10,
                                                    color: darkThemeTextColor),
                                                Text(
                                                    ' ${_thisVideo.snippet.videoOwnerChannelTitle}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Styles.regularStyle
                                                        .copyWith(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: textColor)),
                                              ],
                                            ),
                                            // Text(
                                            //     '| ${dateWithTimeFormatter.format(DateTime.parse(_thisVideo.snippet.publishedAt.toString()).toLocal())}',
                                            //     style: Styles.regularStyle
                                            //         .copyWith(
                                            //             fontSize: 10,
                                            //             fontWeight:
                                            //                 FontWeight.normal,
                                            //             color: textColor)),
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

  static Future<List<PlaylistItem>> getYouTubePlaylistItems({
    BuildContext context,
  }) async {
    logger.d('***** RETRIEVING VIDEO PLAYLIST *****');
    Box<dynamic> userDatabase = Hive.box<dynamic>(appDatabase);

    List<bool> userLevels = await Functions.getUserLevels();
    bool userIsDev = userLevels[0];
    // bool userIsPremium = userLevels[1];
    // bool userIsLegacy = userLevels[2];

    List<PlaylistItem> _currentPlaylistItems = [];

    try {
      _currentPlaylistItems =
          youTubePlaylistFromJson(userDatabase.get('youTubePlaylist')).items;
    } catch (e) {
      logger.d('^^^^^ ERROR DURING YOUTUBE LIST (FUNCTION): $e ^^^^^');
      userDatabase.put('youTubePlaylist', {});
      _currentPlaylistItems = [];
    }

    List<PlaylistItem> _finalPlaylistItems = [];

    if (_currentPlaylistItems.isEmpty ||
        DateTime.parse(userDatabase.get('lastRefresh').toString()).isBefore(
            DateTime.now().subtract(context == null
                ? Duration(hours: 1)
                : Duration(minutes: 25)))) {
      debugPrint('***** GENERATING LIST OF YOUTUBE PLAYLIST ITEMS  *****');
      final response = await http.get(
        Uri.parse(
            "https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet&order=date&maxResults=15&playlistId=$playlistId&key=${dotenv.env['MettaCodeYouTubeApiKey']}"),
      );
      logger.d('***** YOUTUBE RESPONSE CODE: ${response.statusCode} *****');

      if (response.statusCode == 200) {
        debugPrint('***** YOUTUBE API RETRIEVAL SUCCESS! *****');
        final YouTubePlaylist youTubePlaylistResponse =
            youTubePlaylistFromJson(response.body);

        if (youTubePlaylistResponse.items.length > 0) {
          _finalPlaylistItems = youTubePlaylistResponse.items;

          _finalPlaylistItems.removeWhere((video) =>
              video.snippet.title.toLowerCase().contains('private') ||
              video.snippet.title.toLowerCase().contains('deleted') ||
              video.snippet.publishedAt
                  .isBefore(DateTime.now().subtract(const Duration(days: 7))));

          if (_currentPlaylistItems.isEmpty ||
              _finalPlaylistItems.first.id != _currentPlaylistItems.first.id) {
            userDatabase.put('newVideos', true);

            if (userIsDev) {
              final String messageBody =
                  '${_finalPlaylistItems.first.snippet.title.length > 175 ? _finalPlaylistItems.first.snippet.title.replaceRange(175, null, '...') : _finalPlaylistItems.first.snippet.title}';
              final String subject =
                  '${_finalPlaylistItems.first.snippet.title.length > 200 ? _finalPlaylistItems.first.snippet.title.replaceRange(200, null, '...') : _finalPlaylistItems.first.snippet.title}';

              List<String> capitolBabbleNotificationsList = List<String>.from(
                  userDatabase.get('capitolBabbleNotificationsList'));
              capitolBabbleNotificationsList.add(
                  '${DateTime.now()}<|:|>$subject<|:|>$messageBody<|:|>regular<|:|>https://www.youtube.com/watch?v=${_finalPlaylistItems.first.snippet.resourceId.videoId}');
              userDatabase.put('capitolBabbleNotificationsList',
                  capitolBabbleNotificationsList);
            }
          }

          if (_currentPlaylistItems.isEmpty)
            _currentPlaylistItems = _finalPlaylistItems;

          try {
            logger.d('***** SAVING NEW PLAYLIST TO DBASE *****');
            userDatabase.put('youTubePlaylist',
                youTubePlaylistToJson(youTubePlaylistResponse));
          } catch (e) {
            logger.w(
                '^^^^^ ERROR SAVING NEW VIDEOS TO DBASE (YOUTUBE FUNCTION): $e ^^^^^');
            userDatabase.put('youTubePlaylist', {});
          }
        }

        if (userDatabase.get('videoAlerts') &&
            _currentPlaylistItems.first.id != _finalPlaylistItems.first.id) {
          if (context == null || !ModalRoute.of(context).isCurrent) {
            await NotificationApi.showBigTextNotification(
                12,
                'videos',
                'Congressional Videos',
                'New congressional videos',
                'New videos',
                '📺 ${_finalPlaylistItems.first.snippet.videoOwnerChannelTitle}',
                _finalPlaylistItems.first.snippet.title,
                youTubePlaylistResponse);
          } else if (ModalRoute.of(context).isCurrent) {
            Messages.showMessage(
              context: context,
              message: 'New videos added',
              networkImageUrl: _finalPlaylistItems
                  .first.snippet.thumbnails.thumbnailsDefault.url,
              isAlert: false,
              removeCurrent: false,
            );
          }
        }
        return _finalPlaylistItems;
      } else {
        logger.d(
            '***** API ERROR: LOADING VIDEOS FROM DBASE: ${response.statusCode} *****');

        return _finalPlaylistItems = _currentPlaylistItems.isNotEmpty
            ? _currentPlaylistItems
            : youTubePlaylistPlaceholder;
      }
    } else {
      logger.d(
          '***** CURRENT PLAYLIST ITEMS: ${_currentPlaylistItems.map((e) => e.snippet.title)} *****');
      _finalPlaylistItems = _currentPlaylistItems;
      logger.d('***** VIDEOS NOT UPDATED: LIST IS CURRENT *****');
      userDatabase.put('newVideos', false);
      return _finalPlaylistItems;
    }
  }
}
