// To parse this JSON data, do
//
//     final floorAction = congressFloorActionFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CongressFloorAction congressFloorActionFromJson(String str) => CongressFloorAction.fromJson(json.decode(str));

String congressFloorActionToJson(CongressFloorAction data) => json.encode(data.toJson());

class CongressFloorAction {
  CongressFloorAction({
    @required this.retrievedDate,
    @required this.actionsDate,
    @required this.actionsTitle,
    @required this.actionsCount,
    @required this.actionsList,
  });

  final String retrievedDate;
  final String actionsDate;
  final String actionsTitle;
  final int actionsCount;
  final List<ActionsList> actionsList;

  factory CongressFloorAction.fromJson(Map<String, dynamic> json) => CongressFloorAction(
    retrievedDate: json["retrieved-date"],
    actionsDate: json["actions-date"],
    actionsTitle: json["actions-title"],
    actionsCount: json["actions-count"],
    actionsList: List<ActionsList>.from(json["actions-list"].map((x) => ActionsList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "retrieved-date": retrievedDate,
    "actions-date": actionsDate,
    "actions-title": actionsTitle,
    "actions-count": actionsCount,
    "actions-list": List<dynamic>.from(actionsList.map((x) => x.toJson())),
  };
}

class ActionsList {
  ActionsList({
    @required this.index,
    @required this.header,
    @required this.actionItem,
  });

  final int index;
  final String header;
  final String actionItem;

  factory ActionsList.fromJson(Map<String, dynamic> json) => ActionsList(
    index: json["index"],
    header: json["header"],
    actionItem: json["actionItem"],
  );

  Map<String, dynamic> toJson() => {
    "index": index,
    "header": header,
    "actionItem": actionItem,
  };
}