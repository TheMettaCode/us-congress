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
        status: json["status"] == null ? null : json["status"],
        copyright: json["copyright"] == null ? null : json["copyright"],
        results: json["results"] == null
            ? null
            : List<LobbyingSearchResult>.from(
                json["results"].map((x) => LobbyingSearchResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "copyright": copyright == null ? null : copyright,
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
        numResults: json["num_results"] == null ? null : json["num_results"],
        offset: json["offset"] == null ? null : json["offset"],
        query: json["query"] == null ? null : json["query"],
        lobbyingRepresentations: json["lobbying_representations"] == null
            ? null
            : List<LobbyingSearchRepresentation>.from(
                json["lobbying_representations"]
                    .map((x) => LobbyingSearchRepresentation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "num_results": numResults == null ? null : numResults,
        "offset": offset == null ? null : offset,
        "query": query == null ? null : query,
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
        inhouse: json["inhouse"] == null ? null : json["inhouse"],
        signedDate: json["signed_date"] == null ? null : json["signed_date"],
        effectiveDate:
            json["effective_date"] == null ? null : json["effective_date"],
        xmlFilename: json["xml_filename"] == null ? null : json["xml_filename"],
        id: json["id"] == null ? null : json["id"],
        specificIssues: json["specific_issues"] == null
            ? null
            : List<String>.from(json["specific_issues"].map((x) => x)),
        reportType: json["report_type"] == null ? null : json["report_type"],
        reportYear: json["report_year"] == null ? null : json["report_year"],
        senateId: json["senate_id"] == null ? null : json["senate_id"],
        houseId: json["house_id"] == null ? null : json["house_id"],
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
        "inhouse": inhouse == null ? null : inhouse,
        "signed_date": signedDate == null ? null : signedDate,
        "effective_date": effectiveDate == null ? null : effectiveDate,
        "xml_filename": xmlFilename == null ? null : xmlFilename,
        "id": id == null ? null : id,
        "specific_issues": specificIssues == null
            ? null
            : List<dynamic>.from(specificIssues.map((x) => x)),
        "report_type": reportType == null ? null : reportType,
        "report_year": reportYear == null ? null : reportYear,
        "senate_id": senateId == null ? null : senateId,
        "house_id": houseId == null ? null : houseId,
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
        name: json["name"] == null ? null : json["name"],
        generalDescription: json["general_description"] == null
            ? null
            : json["general_description"],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "general_description":
            generalDescription == null ? null : generalDescription,
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
        name: json["name"] == null ? null : json["name"],
        coveredPosition:
            json["covered_position"] == null ? null : json["covered_position"],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "covered_position": coveredPosition == null ? null : coveredPosition,
      };
}
