// To parse this JSON data, do
//
//     final newsArticle = newsArticleFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<NewsArticle> newsArticleFromJson(String str) => List<NewsArticle>.from(
    json.decode(str).map((x) => NewsArticle.fromJson(x)));

String newsArticleToJson(List<NewsArticle> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsArticle {
  NewsArticle({
    @required this.index,
    @required this.title,
    @required this.url,
    @required this.source,
    @required this.slug,
    @required this.imageUrl,
    @required this.date,
  });

  final int index;
  final String title;
  final String url;
  final String source;
  final String slug;
  final String imageUrl;
  final String date;

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
        index: json["index"] == null ? null : json["index"],
        title: json["title"] == null ? null : json["title"],
        url: json["url"] == null ? null : json["url"],
        source: json["source"] == null ? null : json["source"],
        slug: json["slug"] == null ? null : json["slug"],
        imageUrl: json["imageUrl"] == null || json["imageUrl"] == ''
            ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Capitol_at_Dusk_2.jpg/1200px-Capitol_at_Dusk_2.jpg'
            : json["imageUrl"],
        date: json['date'] == null ? DateTime.now().toString() : json['date'],
      );

  Map<String, dynamic> toJson() => {
        "index": index == null ? null : index,
        "title": title == null ? null : title,
        "url": url == null ? null : url,
        "source": source == null ? null : source,
        "slug": slug == null ? null : slug,
        "imageUrl": imageUrl == null || imageUrl == ''
            ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Capitol_at_Dusk_2.jpg/1200px-Capitol_at_Dusk_2.jpg'
            // : imageUrl.contains(';base64')
            //     // ? Uri.parse(imageUrl).data
            //     ? '${base64Decode(imageUrl.split(',').last)}'
            : imageUrl,
        "date": date == null || date == '' ? DateTime.now().toString() : date,
      };
}
