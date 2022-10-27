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
        app: json["app"] ?? 'us-congress',
        // updated: json["updated"] == null ? DateTime.now() : DateTime.parse(json["updated"]),
        status: json["status"] ?? "ERR",
        notifications: json["notifications"] == null
            ? []
            : List<GithubNotifications>.from(
                json["notifications"].map((x) => GithubNotifications.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "app": app,
        // "updated": updated == null
        //     ? null
        //     : "${updated.year.toString().padLeft(4, '0')}-${updated.month.toString().padLeft(2, '0')}-${updated.day.toString().padLeft(2, '0')}",
        "status": status ?? "ERR",
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
    @required this.icon,
    @required this.supportOption,
    @required this.additionalData,
  });

  final DateTime startDate;
  final DateTime expirationDate;
  final String title;
  final String message;
  final int priority;
  final List<String> userLevels;
  final String url;
  final String icon;
  final bool supportOption;
  final String additionalData;

  factory GithubNotifications.fromJson(Map<String, dynamic> json) => GithubNotifications(
        startDate: json["start-date"] == null || json["start-date"] == ""
            ? DateTime.now()
            : DateTime.parse(json["start-date"]),
        expirationDate: json["expiration-date"] == null || json["expiration-date"] == ""
            ? DateTime.now().add(const Duration(days: 1))
            : DateTime.parse(json["expiration-date"]),
        title: json["title"] ?? "",
        message: json["message"] ?? "",
        priority: json["priority"],
        userLevels: List<String>.from(json["user-levels"].map((x) => x)) ?? [],
        url: json["url"] ?? "",
        icon: json["icon"] ?? "handshake",
        supportOption: json['support-option'] ?? false,
        additionalData: json["additional-data"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "start-date":
            startDate == null ? DateTime.now().toIso8601String() : startDate.toIso8601String(),
        "expiration-date": expirationDate == null
            ? DateTime.now().toIso8601String()
            : expirationDate.toIso8601String(),
        "title": title ?? "",
        "message": message ?? "",
        "priority": priority ?? 10,
        "user-levels": userLevels == null ? null : List<dynamic>.from(userLevels.map((x) => x)),
        "url": url ?? "",
        "icon": icon ?? "handshake",
        "support-option": supportOption ?? false,
        "additional-data": additionalData ?? "",
      };

  @override
  String toString() {
    // TODO: implement toString
    "$startDate $expirationDate $title $message $priority $userLevels $url $icon $supportOption $additionalData)";
    return super.toString();
  }
}
