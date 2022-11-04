// To parse this JSON data, do
//
//     final specificLobbyingEvent = specificLobbyingEventFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

SpecificLobbyingEvent specificLobbyingEventFromJson(String str) =>
    SpecificLobbyingEvent.fromJson(json.decode(str));

String specificLobbyingEventToJson(SpecificLobbyingEvent data) =>
    json.encode(data.toJson());

class SpecificLobbyingEvent {
  SpecificLobbyingEvent({
    @required this.status,
    @required this.copyright,
    @required this.results,
  });

  final String status;
  final String copyright;
  final List<SpecificLobbyResult> results;

  factory SpecificLobbyingEvent.fromJson(Map<String, dynamic> json) =>
      SpecificLobbyingEvent(
        status: json["status"],
        copyright: json["copyright"],
        results: json["results"] == null
            ? null
            : List<SpecificLobbyResult>.from(
                json["results"].map((x) => SpecificLobbyResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class SpecificLobbyResult {
  SpecificLobbyResult({
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
    @required this.filings,
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
  final List<Filing> filings;
  final List<Lobbyist> lobbyists;

  factory SpecificLobbyResult.fromJson(Map<String, dynamic> json) =>
      SpecificLobbyResult(
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
        filings: json["filings"] == null
            ? null
            : List<Filing>.from(json["filings"].map((x) => Filing.fromJson(x))),
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
        "filings": filings == null
            ? null
            : List<dynamic>.from(filings.map((x) => x.toJson())),
        "lobbyists": lobbyists == null
            ? null
            : List<dynamic>.from(lobbyists.map((x) => x.toJson())),
      };
}

class Filing {
  Filing({
    @required this.filingDate,
    @required this.reportYear,
    @required this.reportType,
    @required this.pdfUrl,
  });

  final DateTime filingDate;
  final String reportYear;
  final String reportType;
  final String pdfUrl;

  factory Filing.fromJson(Map<String, dynamic> json) => Filing(
        filingDate: json["filing_date"] == null
            ? null
            : DateTime.parse(json["filing_date"]),
        reportYear: json["report_year"],
        reportType: json["report_type"],
        pdfUrl: json["pdf_url"],
      );

  Map<String, dynamic> toJson() => {
        "filing_date": filingDate == null
            ? null
            : "${filingDate.year.toString().padLeft(4, '0')}-${filingDate.month.toString().padLeft(2, '0')}-${filingDate.day.toString().padLeft(2, '0')}",
        "report_year": reportYear,
        "report_type": reportType,
        "pdf_url": pdfUrl,
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
