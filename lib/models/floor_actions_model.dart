// To parse this JSON data, do
//
//     final floorActions = floorActionsFromJson(jsonString);

import 'dart:convert';

FloorActions floorActionsFromJson(String str) =>
    FloorActions.fromJson(json.decode(str));

String floorActionsToJson(FloorActions data) => json.encode(data.toJson());

class FloorActions {
  FloorActions({
    this.status,
    this.copyright,
    this.results,
  });

  final String status;
  final String copyright;
  final List<Result> results;

  factory FloorActions.fromJson(Map<String, dynamic> json) => FloorActions(
        status: json["status"],
        copyright: json["copyright"],
        results: json["results"] == null
            ? null
            : List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class Result {
  Result({
    this.chamber,
    this.numResults,
    this.offset,
    this.floorActions,
  });

  final Chamber chamber;
  final int numResults;
  final int offset;
  final List<FloorAction> floorActions;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        chamber:
            json["chamber"] == null ? null : chamberValues.map[json["chamber"]],
        numResults: json["num_results"],
        offset: json["offset"],
        floorActions: json["floor_actions"] == null
            ? null
            : List<FloorAction>.from(
                json["floor_actions"].map((x) => FloorAction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "chamber": chamber == null ? null : chamberValues.reverse[chamber],
        "num_results": numResults,
        "offset": offset,
        "floor_actions": floorActions == null
            ? null
            : List<dynamic>.from(floorActions.map((x) => x.toJson())),
      };
}

enum Chamber { SENATE }

final chamberValues = EnumValues({"Senate": Chamber.SENATE});

class FloorAction {
  FloorAction({
    this.congress,
    this.chamber,
    this.timestamp,
    this.date,
    this.actionId,
    this.description,
    this.billIds,
  });

  final String congress;
  final Chamber chamber;
  final DateTime timestamp;
  final DateTime date;
  final String actionId;
  final String description;
  final List<String> billIds;

  factory FloorAction.fromJson(Map<String, dynamic> json) => FloorAction(
        congress: json["congress"],
        chamber:
            json["chamber"] == null ? null : chamberValues.map[json["chamber"]],
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        actionId: json["action_id"],
        description: json["description"],
        billIds: json["bill_ids"] == null
            ? null
            : List<String>.from(json["bill_ids"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "congress": congress,
        "chamber": chamber == null ? null : chamberValues.reverse[chamber],
        "timestamp": timestamp == null ? null : timestamp.toString(),
        "date": date == null
            ? null
            : "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "action_id": actionId,
        "description": description,
        "bill_ids":
            billIds == null ? null : List<dynamic>.from(billIds.map((x) => x)),
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
