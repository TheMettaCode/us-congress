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
        kind: json["kind"] == null ? null : json["kind"],
        etag: json["etag"] == null ? null : json["etag"],
        nextPageToken:
            json["nextPageToken"] == null ? null : json["nextPageToken"],
        items: json["items"] == null
            ? null
            : List<PlaylistItem>.from(
                json["items"].map((x) => PlaylistItem.fromJson(x))),
        pageInfo: json["pageInfo"] == null
            ? null
            : PageInfo.fromJson(json["pageInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "kind": kind == null ? null : kind,
        "etag": etag == null ? null : etag,
        "nextPageToken": nextPageToken == null ? null : nextPageToken,
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
        "pageInfo": pageInfo == null ? null : pageInfo.toJson(),
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
        kind: json["kind"] == null ? null : json["kind"],
        etag: json["etag"] == null ? null : json["etag"],
        id: json["id"] == null ? null : json["id"],
        snippet:
            json["snippet"] == null ? null : Snippet.fromJson(json["snippet"]),
      );

  Map<String, dynamic> toJson() => {
        "kind": kind == null ? null : kind,
        "etag": etag == null ? null : etag,
        "id": id == null ? null : id,
        "snippet": snippet == null ? null : snippet.toJson(),
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
        channelId: json["channelId"] == null ? null : json["channelId"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        thumbnails: json["thumbnails"] == null
            ? null
            : Thumbnails.fromJson(json["thumbnails"]),
        channelTitle:
            json["channelTitle"] == null ? null : json["channelTitle"],
        playlistId: json["playlistId"] == null ? null : json["playlistId"],
        position: json["position"] == null ? null : json["position"],
        resourceId: json["resourceId"] == null
            ? null
            : ResourceId.fromJson(json["resourceId"]),
        videoOwnerChannelTitle: json["videoOwnerChannelTitle"] == null
            ? null
            : json["videoOwnerChannelTitle"],
        videoOwnerChannelId: json["videoOwnerChannelId"] == null
            ? null
            : json["videoOwnerChannelId"],
      );

  Map<String, dynamic> toJson() => {
        "publishedAt":
            publishedAt == null ? null : publishedAt.toIso8601String(),
        "channelId": channelId == null ? null : channelId,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "thumbnails": thumbnails == null ? null : thumbnails.toJson(),
        "channelTitle": channelTitle == null ? null : channelTitle,
        "playlistId": playlistId == null ? null : playlistId,
        "position": position == null ? null : position,
        "resourceId": resourceId == null ? null : resourceId.toJson(),
        "videoOwnerChannelTitle":
            videoOwnerChannelTitle == null ? null : videoOwnerChannelTitle,
        "videoOwnerChannelId":
            videoOwnerChannelId == null ? null : videoOwnerChannelId,
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
        kind: json["kind"] == null ? null : json["kind"],
        videoId: json["videoId"] == null ? null : json["videoId"],
      );

  Map<String, dynamic> toJson() => {
        "kind": kind == null ? null : kind,
        "videoId": videoId == null ? null : videoId,
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
        "default":
            thumbnailsDefault == null ? null : thumbnailsDefault.toJson(),
        "medium": medium == null ? null : medium.toJson(),
        "high": high == null ? null : high.toJson(),
        "standard": standard == null ? null : standard.toJson(),
        "maxres": maxres == null ? null : maxres.toJson(),
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
        url: json["url"] == null ? null : json["url"],
        width: json["width"] == null ? null : json["width"],
        height: json["height"] == null ? null : json["height"],
      );

  Map<String, dynamic> toJson() => {
        "url": url == null ? null : url,
        "width": width == null ? null : width,
        "height": height == null ? null : height,
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
        totalResults:
            json["totalResults"] == null ? null : json["totalResults"],
        resultsPerPage:
            json["resultsPerPage"] == null ? null : json["resultsPerPage"],
      );

  Map<String, dynamic> toJson() => {
        "totalResults": totalResults == null ? null : totalResults,
        "resultsPerPage": resultsPerPage == null ? null : resultsPerPage,
      };
}
