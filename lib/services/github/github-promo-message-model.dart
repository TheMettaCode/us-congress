// To parse this JSON data, do
//
//     final githubMessages = githubMessagesFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

GithubMessages githubMessagesFromJson(String str) => GithubMessages.fromJson(json.decode(str));

String githubMessagesToJson(GithubMessages data) => json.encode(data.toJson());

class GithubMessages {
  GithubMessages({
    @required this.app,
    // @required this.updated,
    @required this.status,
    @required this.notifications,
  });

  final String app;
  // final DateTime updated;
  final String status;
  final List<GithubNotifications> notifications;

  factory GithubMessages.fromJson(Map<String, dynamic> json) => GithubMessages(
        app: json["app"] == null ? 'us-congress' : json["app"],
        // updated: json["updated"] == null ? DateTime.now() : DateTime.parse(json["updated"]),
        status: json["status"] == null ? "ERR" : json["status"],
        notifications: json["notifications"] == null
            ? []
            : List<GithubNotifications>.from(
                json["notifications"].map((x) => GithubNotifications.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "app": app == null ? null : app,
        // "updated": updated == null
        //     ? null
        //     : "${updated.year.toString().padLeft(4, '0')}-${updated.month.toString().padLeft(2, '0')}-${updated.day.toString().padLeft(2, '0')}",
        "status": status == null ? "ERR" : status,
        "notifications":
            notifications == null ? null : List<dynamic>.from(notifications.map((x) => x.toJson())),
      };
}

class GithubNotifications {
  GithubNotifications({
    @required this.startDate,
    @required this.expirationDate,
    @required this.title,
    @required this.message,
    @required this.priority,
    @required this.userLevels,
    @required this.url,
    @required this.additionalData,
  });

  final DateTime startDate;
  final DateTime expirationDate;
  final String title;
  final String message;
  final int priority;
  final List<String> userLevels;
  final String url;
  final String additionalData;

  factory GithubNotifications.fromJson(Map<String, dynamic> json) => GithubNotifications(
        startDate: json["start-date"] == null || json["start-date"] == ""
            ? DateTime.now()
            : DateTime.parse(json["start-date"]),
        expirationDate: json["expiration-date"] == null || json["expiration-date"] == ""
            ? DateTime.now().add(Duration(days: 1))
            : DateTime.parse(json["expiration-date"]),
        title: json["title"] == null ? "" : json["title"],
        message: json["message"] == null ? "" : json["message"],
        priority: json["priority"] == null ? null : json["priority"],
        userLevels:
            json["user-levels"] == null ? [] : List<String>.from(json["user-levels"].map((x) => x)),
        url: json["url"] == null ? null : json["url"],
        additionalData: json["additional-data"] == null ? "" : json["additional-data"],
      );

  Map<String, dynamic> toJson() => {
        "start-date":
            startDate == null ? DateTime.now().toIso8601String() : startDate.toIso8601String(),
        "expiration-date": expirationDate == null
            ? DateTime.now().toIso8601String()
            : expirationDate.toIso8601String(),
        "title": title == null ? "" : title,
        "message": message == null ? "" : message,
        "priority": priority == null ? 10 : priority,
        "user-levels": userLevels == null ? null : List<dynamic>.from(userLevels.map((x) => x)),
        "url": url == null ? "" : url,
        "additional-data": additionalData == null ? "" : additionalData,
      };
}
