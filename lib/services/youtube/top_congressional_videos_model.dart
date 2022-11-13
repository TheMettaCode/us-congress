// To parse this JSON data, do
//
//     final topCongressionalVideos = topCongressionalVideosFromJson(jsonString);

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

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

Future<void> youtubeVideoTest() async {
  List<String> allVideosList = [];
  TopCongressionalVideos data =
      topCongressionalVideosFromJson(jsonEncode(topCongressionalTestVideos));
  data.videos.map((e) => e.channelVideos).forEach((element) => allVideosList.addAll(element));

  debugPrint('[YOUTUBE VIDEO TEST] ALL VIDEOS:\n$allVideosList');
}

Widget youtubeTestWidget(List<String> videoIds) {
  return Container();
}

const Map<String, dynamic> topCongressionalTestVideos = {
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
