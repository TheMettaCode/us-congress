// To parse this JSON data, do
//
//     final lobbyingSearch = lobbyingSearchFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

LobbyingSearch lobbyingSearchFromJson(String str) =>
    LobbyingSearch.fromJson(json.decode(str));

String lobbyingSearchToJson(LobbyingSearch data) => json.encode(data.toJson());

class LobbyingSearch {
  LobbyingSearch({
    @required this.status,
    @required this.copyright,
    @required this.results,
  });

  final String status;
  final String copyright;
  final List<LobbyingSearchResult> results;

  factory LobbyingSearch.fromJson(Map<String, dynamic> json) => LobbyingSearch(
        status: json["status"],
        copyright: json["copyright"],
        results: json["results"] == null
            ? null
            : List<LobbyingSearchResult>.from(
                json["results"].map((x) => LobbyingSearchResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class LobbyingSearchResult {
  LobbyingSearchResult({
    @required this.numResults,
    @required this.offset,
    @required this.query,
    @required this.lobbyingRepresentations,
  });

  final int numResults;
  final int offset;
  final String query;
  final List<LobbyingSearchRepresentation> lobbyingRepresentations;

  factory LobbyingSearchResult.fromJson(Map<String, dynamic> json) =>
      LobbyingSearchResult(
        numResults: json["num_results"],
        offset: json["offset"],
        query: json["query"],
        lobbyingRepresentations: json["lobbying_representations"] == null
            ? null
            : List<LobbyingSearchRepresentation>.from(
                json["lobbying_representations"]
                    .map((x) => LobbyingSearchRepresentation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "num_results": numResults,
        "offset": offset,
        "query": query,
        "lobbying_representations": lobbyingRepresentations == null
            ? null
            : List<dynamic>.from(
                lobbyingRepresentations.map((x) => x.toJson())),
      };
}

class LobbyingSearchRepresentation {
  LobbyingSearchRepresentation({
    @required this.lobbyingClient,
    @required this.lobbyingRegistrant,
    @required this.inhouse,
    @required this.signedDate,
    @required this.effectiveDate,
    @required this.xmlFilename,
    @required this.id,
    @required this.specificIssues,
    @required this.reportType,
    @required this.reportYear,
    @required this.senateId,
    @required this.houseId,
    @required this.lobbyists,
  });

  final Lobbying lobbyingClient;
  final Lobbying lobbyingRegistrant;
  final String inhouse;
  final String signedDate;
  final String effectiveDate;
  final String xmlFilename;
  final String id;
  final List<String> specificIssues;
  final String reportType;
  final String reportYear;
  final String senateId;
  final String houseId;
  final List<Lobbyist> lobbyists;

  factory LobbyingSearchRepresentation.fromJson(Map<String, dynamic> json) =>
      LobbyingSearchRepresentation(
        lobbyingClient: json["lobbying_client"] == null
            ? null
            : Lobbying.fromJson(json["lobbying_client"]),
        lobbyingRegistrant: json["lobbying_registrant"] == null
            ? null
            : Lobbying.fromJson(json["lobbying_registrant"]),
        inhouse: json["inhouse"],
        signedDate: json["signed_date"],
        effectiveDate: json["effective_date"],
        xmlFilename: json["xml_filename"],
        id: json["id"],
        specificIssues: json["specific_issues"] == null
            ? null
            : List<String>.from(json["specific_issues"].map((x) => x)),
        reportType: json["report_type"],
        reportYear: json["report_year"],
        senateId: json["senate_id"],
        houseId: json["house_id"],
        lobbyists: json["lobbyists"] == null
            ? null
            : List<Lobbyist>.from(
                json["lobbyists"].map((x) => Lobbyist.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "lobbying_client":
            lobbyingClient == null ? null : lobbyingClient.toJson(),
        "lobbying_registrant":
            lobbyingRegistrant == null ? null : lobbyingRegistrant.toJson(),
        "inhouse": inhouse,
        "signed_date": signedDate,
        "effective_date": effectiveDate,
        "xml_filename": xmlFilename,
        "id": id,
        "specific_issues": specificIssues == null
            ? null
            : List<dynamic>.from(specificIssues.map((x) => x)),
        "report_type": reportType,
        "report_year": reportYear,
        "senate_id": senateId,
        "house_id": houseId,
        "lobbyists": lobbyists == null
            ? null
            : List<dynamic>.from(lobbyists.map((x) => x.toJson())),
      };
}

class Lobbying {
  Lobbying({
    @required this.name,
    @required this.generalDescription,
  });

  final String name;
  final String generalDescription;

  factory Lobbying.fromJson(Map<String, dynamic> json) => Lobbying(
        name: json["name"],
        generalDescription: json["general_description"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "general_description": generalDescription,
      };
}

class Lobbyist {
  Lobbyist({
    @required this.name,
    @required this.coveredPosition,
  });

  final String name;
  final String coveredPosition;

  factory Lobbyist.fromJson(Map<String, dynamic> json) => Lobbyist(
        name: json["name"],
        coveredPosition: json["covered_position"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "covered_position": coveredPosition,
      };
}
