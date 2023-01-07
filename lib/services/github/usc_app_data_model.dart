// To parse this JSON data, do
//
//     final githubMessages = githubMessagesFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

GithubData githubDataFromJson(String str) => GithubData.fromJson(json.decode(str));

String githubDataToJson(GithubData data) => json.encode(data.toJson());

class GithubData {
  GithubData({
    @required this.app,
    @required this.status,
    @required this.notifications,
  });

  final String app;
  final String status;
  final List<GithubNotifications> notifications;

  factory GithubData.fromJson(Map<String, dynamic> json) => GithubData(
        app: json["app"] ?? 'us-congress',
        status: json["status"] ?? "ERR",
        notifications: List<GithubNotifications>.from(
                json["notifications"].map((x) => GithubNotifications.fromJson(x))) ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "app": app,
        "status": status ?? "ERR",
        "notifications": List<dynamic>.from(notifications.map((x) => x.toJson())),
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
    @required this.market,
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
  final List<String> market;
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
        market: List<String>.from(json["market"].map((x) => x)) ?? [],
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
        "user-levels": userLevels == null ? [] : List<dynamic>.from(userLevels.map((x) => x)),
        "market": market == null ? [] : List<dynamic>.from(market.map((x) => x)),
        "url": url ?? "",
        "icon": icon ?? "handshake",
        "support-option": supportOption ?? false,
        "additional-data": additionalData ?? "",
      };
}
