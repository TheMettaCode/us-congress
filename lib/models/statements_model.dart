// To parse this JSON data, do
//
//     final statements = statementsFromJson(jsonString);

import 'dart:convert';

Statements statementsFromJson(String str) =>
    Statements.fromJson(json.decode(str));

String statementsToJson(Statements data) => json.encode(data.toJson());

class Statements {
  Statements({
    this.status,
    this.copyright,
    this.numResults,
    this.offset,
    this.results,
  });

  final String status;
  final String copyright;
  final int numResults;
  final int offset;
  final List<StatementsResults> results;

  factory Statements.fromJson(Map<String, dynamic> json) => Statements(
        status: json["status"],
        copyright: json["copyright"],
        numResults: json["num_results"],
        offset: json["offset"],
        results: json["results"] == null
            ? null
            : List<StatementsResults>.from(
                json["results"].map((x) => StatementsResults.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "num_results": numResults,
        "offset": offset,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class StatementsResults {
  StatementsResults({
    this.url,
    this.date,
    this.title,
    this.statementType,
    this.memberId,
    this.congress,
    this.memberUri,
    this.name,
    this.chamber,
    this.state,
    this.party,
    this.subjects,
  });

  final String url;
  final DateTime date;
  final String title;
  final StatementType statementType;
  final String memberId;
  final int congress;
  final String memberUri;
  final String name;
  final Chamber chamber;
  final String state;
  final Party party;
  final List<dynamic> subjects;

  factory StatementsResults.fromJson(Map<String, dynamic> json) =>
      StatementsResults(
        url: json["url"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        title: json["title"],
        statementType: json["statement_type"] == null
            ? null
            : statementTypeValues.map[json["statement_type"]],
        memberId: json["member_id"],
        congress: json["congress"],
        memberUri: json["member_uri"],
        name: json["name"],
        chamber:
            json["chamber"] == null ? null : chamberValues.map[json["chamber"]],
        state: json["state"],
        party: json["party"] == null ? null : partyValues.map[json["party"]],
        subjects: json["subjects"] == null
            ? null
            : List<dynamic>.from(json["subjects"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "date": date == null
            ? null
            : "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "title": title,
        "statement_type": statementType == null
            ? null
            : statementTypeValues.reverse[statementType],
        "member_id": memberId,
        "congress": congress,
        "member_uri": memberUri,
        "name": name,
        "chamber": chamber == null ? null : chamberValues.reverse[chamber],
        "state": state,
        "party": party == null ? null : partyValues.reverse[party],
        "subjects": subjects == null
            ? null
            : List<dynamic>.from(subjects.map((x) => x)),
      };
}

enum Chamber { SENATE, HOUSE }

final chamberValues =
    EnumValues({"House": Chamber.HOUSE, "Senate": Chamber.SENATE});

enum Party { D, R }

final partyValues = EnumValues({"D": Party.D, "R": Party.R});

enum StatementType { PRESS_RELEASE }

final statementTypeValues =
    EnumValues({"Press Release": StatementType.PRESS_RELEASE});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
