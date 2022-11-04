// To parse this JSON data, do
//
//     final youTubePlaylist = youTubePlaylistFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

YouTubePlaylist youTubePlaylistFromJson(String str) =>
    YouTubePlaylist.fromJson(json.decode(str));

String youTubePlaylistToJson(YouTubePlaylist data) =>
    json.encode(data.toJson());

class YouTubePlaylist {
  YouTubePlaylist({
    @required this.kind,
    @required this.etag,
    @required this.nextPageToken,
    @required this.items,
    @required this.pageInfo,
  });

  final String kind;
  final String etag;
  final String nextPageToken;
  final List<PlaylistItem> items;
  final PageInfo pageInfo;

  factory YouTubePlaylist.fromJson(Map<String, dynamic> json) =>
      YouTubePlaylist(
        kind: json["kind"],
        etag: json["etag"],
        nextPageToken: json["nextPageToken"],
        items: json["items"] == null
            ? null
            : List<PlaylistItem>.from(
                json["items"].map((x) => PlaylistItem.fromJson(x))),
        pageInfo: json["pageInfo"] == null
            ? null
            : PageInfo.fromJson(json["pageInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "kind": kind,
        "etag": etag,
        "nextPageToken": nextPageToken,
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
        "pageInfo": pageInfo.toJson(),
      };
}

class PlaylistItem {
  PlaylistItem({
    @required this.kind,
    @required this.etag,
    @required this.id,
    @required this.snippet,
  });

  final String kind;
  final String etag;
  final String id;
  final Snippet snippet;

  factory PlaylistItem.fromJson(Map<String, dynamic> json) => PlaylistItem(
        kind: json["kind"],
        etag: json["etag"],
        id: json["id"],
        snippet:
            json["snippet"] == null ? null : Snippet.fromJson(json["snippet"]),
      );

  Map<String, dynamic> toJson() => {
        "kind": kind,
        "etag": etag,
        "id": id,
        "snippet": snippet.toJson(),
      };
}

class Snippet {
  Snippet({
    @required this.publishedAt,
    @required this.channelId,
    @required this.title,
    @required this.description,
    @required this.thumbnails,
    @required this.channelTitle,
    @required this.playlistId,
    @required this.position,
    @required this.resourceId,
    @required this.videoOwnerChannelTitle,
    @required this.videoOwnerChannelId,
  });

  final DateTime publishedAt;
  final String channelId;
  final String title;
  final String description;
  final Thumbnails thumbnails;
  final String channelTitle;
  final String playlistId;
  final int position;
  final ResourceId resourceId;
  final String videoOwnerChannelTitle;
  final String videoOwnerChannelId;

  factory Snippet.fromJson(Map<String, dynamic> json) => Snippet(
        publishedAt: json["publishedAt"] == null
            ? null
            : DateTime.parse(json["publishedAt"]),
        channelId: json["channelId"],
        title: json["title"],
        description: json["description"],
        thumbnails: json["thumbnails"] == null
            ? null
            : Thumbnails.fromJson(json["thumbnails"]),
        channelTitle: json["channelTitle"],
        playlistId: json["playlistId"],
        position: json["position"],
        resourceId: json["resourceId"] == null
            ? null
            : ResourceId.fromJson(json["resourceId"]),
        videoOwnerChannelTitle: json["videoOwnerChannelTitle"],
        videoOwnerChannelId: json["videoOwnerChannelId"],
      );

  Map<String, dynamic> toJson() => {
        "publishedAt": publishedAt.toIso8601String(),
        "channelId": channelId,
        "title": title,
        "description": description,
        "thumbnails": thumbnails.toJson(),
        "channelTitle": channelTitle,
        "playlistId": playlistId,
        "position": position,
        "resourceId": resourceId.toJson(),
        "videoOwnerChannelTitle": videoOwnerChannelTitle,
        "videoOwnerChannelId": videoOwnerChannelId,
      };
}

class ResourceId {
  ResourceId({
    @required this.kind,
    @required this.videoId,
  });

  final String kind;
  final String videoId;

  factory ResourceId.fromJson(Map<String, dynamic> json) => ResourceId(
        kind: json["kind"],
        videoId: json["videoId"],
      );

  Map<String, dynamic> toJson() => {
        "kind": kind,
        "videoId": videoId,
      };
}

class Thumbnails {
  Thumbnails({
    @required this.thumbnailsDefault,
    @required this.medium,
    @required this.high,
    @required this.standard,
    @required this.maxres,
  });

  final Default thumbnailsDefault;
  final Default medium;
  final Default high;
  final Default standard;
  final Default maxres;

  factory Thumbnails.fromJson(Map<String, dynamic> json) => Thumbnails(
        thumbnailsDefault:
            json["default"] == null ? null : Default.fromJson(json["default"]),
        medium:
            json["medium"] == null ? null : Default.fromJson(json["medium"]),
        high: json["high"] == null ? null : Default.fromJson(json["high"]),
        standard: json["standard"] == null
            ? null
            : Default.fromJson(json["standard"]),
        maxres:
            json["maxres"] == null ? null : Default.fromJson(json["maxres"]),
      );

  Map<String, dynamic> toJson() => {
        "default": thumbnailsDefault.toJson(),
        "medium": medium.toJson(),
        "high": high.toJson(),
        "standard": standard.toJson(),
        "maxres": maxres.toJson(),
      };
}

class Default {
  Default({
    @required this.url,
    @required this.width,
    @required this.height,
  });

  final String url;
  final int width;
  final int height;

  factory Default.fromJson(Map<String, dynamic> json) => Default(
        url: json["url"],
        width: json["width"],
        height: json["height"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "width": width,
        "height": height,
      };
}

class PageInfo {
  PageInfo({
    @required this.totalResults,
    @required this.resultsPerPage,
  });

  final int totalResults;
  final int resultsPerPage;

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        totalResults: json["totalResults"],
        resultsPerPage: json["resultsPerPage"],
      );

  Map<String, dynamic> toJson() => {
        "totalResults": totalResults,
        "resultsPerPage": resultsPerPage,
      };
}
