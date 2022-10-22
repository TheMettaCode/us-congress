// To parse this JSON data, do
//
//     final privateTripsByMember = privateTripsByMemberFromJson(jsonString);

// HTTP Request: https://api.propublica.org/congress/v1/members/{member-id}/private-trips.json

import 'package:meta/meta.dart';
import 'dart:convert';

PrivateTripsByMember privateTripsByMemberFromJson(String str) =>
    PrivateTripsByMember.fromJson(json.decode(str));

String privateTripsByMemberToJson(PrivateTripsByMember data) =>
    json.encode(data.toJson());

class PrivateTripsByMember {
  PrivateTripsByMember({
    @required this.status,
    @required this.copyright,
    @required this.numResults,
    @required this.offset,
    @required this.memberId,
    @required this.apiUri,
    @required this.displayName,
    @required this.results,
  });

  final String status;
  final String copyright;
  final int numResults;
  final int offset;
  final String memberId;
  final String apiUri;
  final String displayName;
  final List<MemberTripsResult> results;

  factory PrivateTripsByMember.fromJson(Map<String, dynamic> json) =>
      PrivateTripsByMember(
        status: json["status"] == null ? null : json["status"],
        copyright: json["copyright"] == null ? null : json["copyright"],
        numResults: json["num_results"] == null ? null : json["num_results"],
        offset: json["offset"] == null ? null : json["offset"],
        memberId: json["member_id"] == null ? null : json["member_id"],
        apiUri: json["api_uri"] == null ? null : json["api_uri"],
        displayName: json["display_name"] == null ? null : json["display_name"],
        results: json["results"] == null
            ? null
            : List<MemberTripsResult>.from(
                json["results"].map((x) => MemberTripsResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "copyright": copyright == null ? null : copyright,
        "num_results": numResults == null ? null : numResults,
        "offset": offset == null ? null : offset,
        "member_id": memberId == null ? null : memberId,
        "api_uri": apiUri == null ? null : apiUri,
        "display_name": displayName == null ? null : displayName,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class MemberTripsResult {
  MemberTripsResult({
    @required this.filingType,
    @required this.traveler,
    @required this.isMember,
    @required this.congress,
    @required this.departureDate,
    @required this.returnDate,
    @required this.chamber,
    @required this.destination,
    @required this.sponsor,
    @required this.documentId,
    @required this.pdfUrl,
  });

  final FilingType filingType;
  final String traveler;
  final int isMember;
  final int congress;
  final DateTime departureDate;
  final DateTime returnDate;
  final Chamber chamber;
  final String destination;
  final String sponsor;
  final String documentId;
  final String pdfUrl;

  factory MemberTripsResult.fromJson(Map<String, dynamic> json) =>
      MemberTripsResult(
        filingType: json["filing_type"] == null
            ? null
            : filingTypeValues.map[json["filing_type"]],
        traveler: json["traveler"] == null ? null : json["traveler"],
        isMember: json["is_member"] == null ? null : json["is_member"],
        congress: json["congress"] == null ? null : json["congress"],
        departureDate: json["departure_date"] == null
            ? null
            : DateTime.parse(json["departure_date"]),
        returnDate: json["return_date"] == null
            ? null
            : DateTime.parse(json["return_date"]),
        chamber:
            json["chamber"] == null ? null : chamberValues.map[json["chamber"]],
        destination: json["destination"] == null ? null : json["destination"],
        sponsor: json["sponsor"] == null ? null : json["sponsor"],
        documentId: json["document_id"] == null ? null : json["document_id"],
        pdfUrl: json["pdf_url"] == null ? null : json["pdf_url"],
      );

  Map<String, dynamic> toJson() => {
        "filing_type":
            filingType == null ? null : filingTypeValues.reverse[filingType],
        "traveler": traveler == null ? null : traveler,
        "is_member": isMember == null ? null : isMember,
        "congress": congress == null ? null : congress,
        "departure_date": departureDate == null
            ? null
            : "${departureDate.year.toString().padLeft(4, '0')}-${departureDate.month.toString().padLeft(2, '0')}-${departureDate.day.toString().padLeft(2, '0')}",
        "return_date": returnDate == null
            ? null
            : "${returnDate.year.toString().padLeft(4, '0')}-${returnDate.month.toString().padLeft(2, '0')}-${returnDate.day.toString().padLeft(2, '0')}",
        "chamber": chamber == null ? null : chamberValues.reverse[chamber],
        "destination": destination == null ? null : destination,
        "sponsor": sponsor == null ? null : sponsor,
        "document_id": documentId == null ? null : documentId,
        "pdf_url": pdfUrl == null ? null : pdfUrl,
      };
}

enum Chamber { HOUSE }

final chamberValues = EnumValues({"House": Chamber.HOUSE});

enum FilingType { ORIGINAL }

final filingTypeValues = EnumValues({"Original": FilingType.ORIGINAL});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
