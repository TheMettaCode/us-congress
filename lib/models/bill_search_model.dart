// To parse this JSON data, do
//
//     final query = queryFromJson(jsonString);

import 'dart:convert';

Query queryFromJson(String str) => Query.fromJson(json.decode(str));

String queryToJson(Query data) => json.encode(data.toJson());

class Query {
  Query({
    this.status,
    this.copyright,
    this.results,
  });

  final String status;
  final String copyright;
  final List<BillSearchResult> results;

  factory Query.fromJson(Map<String, dynamic> json) => Query(
        status: json["status"],
        copyright: json["copyright"],
        results: json["results"] == null
            ? null
            : List<BillSearchResult>.from(
                json["results"].map((x) => BillSearchResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class BillSearchResult {
  BillSearchResult({
    this.numResults,
    this.offset,
    this.bills,
  });

  final int numResults;
  final int offset;
  final List<Bill> bills;

  factory BillSearchResult.fromJson(Map<String, dynamic> json) =>
      BillSearchResult(
        numResults: json["num_results"],
        offset: json["offset"],
        bills: json["bills"] == null
            ? null
            : List<Bill>.from(json["bills"].map((x) => Bill.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "num_results": numResults,
        "offset": offset,
        "bills": bills == null
            ? null
            : List<dynamic>.from(bills.map((x) => x.toJson())),
      };
}

class Bill {
  Bill({
    this.billId,
    this.billType,
    this.number,
    this.billUri,
    this.title,
    this.sponsorTitle,
    this.sponsorId,
    this.sponsorName,
    this.sponsorState,
    this.sponsorParty,
    this.sponsorUri,
    this.gpoPdfUri,
    this.congressdotgovUrl,
    this.govtrackUrl,
    this.introducedDate,
    this.active,
    this.housePassage,
    this.senatePassage,
    this.enacted,
    this.vetoed,
    this.cosponsors,
    this.committees,
    this.committeeCodes,
    this.subcommitteeCodes,
    this.primarySubject,
    this.summary,
    this.summaryShort,
    this.latestMajorActionDate,
    this.latestMajorAction,
  });

  final String billId;
  final BillType billType;
  final String number;
  final String billUri;
  final String title;
  final SponsorTitle sponsorTitle;
  final String sponsorId;
  final String sponsorName;
  final String sponsorState;
  final SponsorParty sponsorParty;
  final String sponsorUri;
  final String gpoPdfUri;
  final String congressdotgovUrl;
  final String govtrackUrl;
  final DateTime introducedDate;
  final bool active;
  final DateTime housePassage;
  final DateTime senatePassage;
  final DateTime enacted;
  final dynamic vetoed;
  final int cosponsors;
  final Committees committees;
  final List<String> committeeCodes;
  final List<String> subcommitteeCodes;
  final PrimarySubject primarySubject;
  final String summary;
  final String summaryShort;
  final DateTime latestMajorActionDate;
  final String latestMajorAction;

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        billId: json["bill_id"],
        billType: json["bill_type"] == null
            ? null
            : billTypeValues.map[json["bill_type"]],
        number: json["number"],
        billUri: json["bill_uri"],
        title: json["title"],
        sponsorTitle: json["sponsor_title"] == null
            ? null
            : sponsorTitleValues.map[json["sponsor_title"]],
        sponsorId: json["sponsor_id"],
        sponsorName: json["sponsor_name"],
        sponsorState: json["sponsor_state"],
        sponsorParty: json["sponsor_party"] == null
            ? null
            : sponsorPartyValues.map[json["sponsor_party"]],
        sponsorUri: json["sponsor_uri"],
        gpoPdfUri: json["gpo_pdf_uri"],
        congressdotgovUrl: json["congressdotgov_url"],
        govtrackUrl: json["govtrack_url"],
        introducedDate: json["introduced_date"] == null
            ? null
            : DateTime.parse(json["introduced_date"]),
        active: json["active"],
        housePassage: json["house_passage"] == null
            ? null
            : DateTime.parse(json["house_passage"]),
        senatePassage: json["senate_passage"] == null
            ? null
            : DateTime.parse(json["senate_passage"]),
        enacted:
            json["enacted"] == null ? null : DateTime.parse(json["enacted"]),
        vetoed: json["vetoed"],
        cosponsors: json["cosponsors"],
        committees: json["committees"] == null
            ? null
            : committeesValues.map[json["committees"]],
        committeeCodes: json["committee_codes"] == null
            ? null
            : List<String>.from(json["committee_codes"].map((x) => x)),
        subcommitteeCodes: json["subcommittee_codes"] == null
            ? null
            : List<String>.from(json["subcommittee_codes"].map((x) => x)),
        primarySubject: json["primary_subject"] == null
            ? null
            : primarySubjectValues.map[json["primary_subject"]],
        summary: json["summary"],
        summaryShort: json["summary_short"],
        latestMajorActionDate: json["latest_major_action_date"] == null
            ? null
            : DateTime.parse(json["latest_major_action_date"]),
        latestMajorAction: json["latest_major_action"],
      );

  Map<String, dynamic> toJson() => {
        "bill_id": billId ?? 'noBillId',
        "bill_type": billType == null ? null : billTypeValues.reverse[billType],
        "number": number,
        "bill_uri": billUri,
        "title": title,
        "sponsor_title": sponsorTitle == null
            ? null
            : sponsorTitleValues.reverse[sponsorTitle],
        "sponsor_id": sponsorId,
        "sponsor_name": sponsorName,
        "sponsor_state": sponsorState,
        "sponsor_party": sponsorParty == null
            ? null
            : sponsorPartyValues.reverse[sponsorParty],
        "sponsor_uri": sponsorUri,
        "gpo_pdf_uri": gpoPdfUri,
        "congressdotgov_url": congressdotgovUrl,
        "govtrack_url": govtrackUrl,
        "introduced_date": introducedDate == null
            ? null
            : "${introducedDate.year.toString().padLeft(4, '0')}-${introducedDate.month.toString().padLeft(2, '0')}-${introducedDate.day.toString().padLeft(2, '0')}",
        "active": active,
        "house_passage": housePassage == null
            ? null
            : "${housePassage.year.toString().padLeft(4, '0')}-${housePassage.month.toString().padLeft(2, '0')}-${housePassage.day.toString().padLeft(2, '0')}",
        "senate_passage": senatePassage == null
            ? null
            : "${senatePassage.year.toString().padLeft(4, '0')}-${senatePassage.month.toString().padLeft(2, '0')}-${senatePassage.day.toString().padLeft(2, '0')}",
        "enacted": enacted == null
            ? null
            : "${enacted.year.toString().padLeft(4, '0')}-${enacted.month.toString().padLeft(2, '0')}-${enacted.day.toString().padLeft(2, '0')}",
        "vetoed": vetoed,
        "cosponsors": cosponsors,
        "committees":
            committees == null ? null : committeesValues.reverse[committees],
        "committee_codes": committeeCodes == null
            ? null
            : List<dynamic>.from(committeeCodes.map((x) => x)),
        "subcommittee_codes": subcommitteeCodes == null
            ? null
            : List<dynamic>.from(subcommitteeCodes.map((x) => x)),
        "primary_subject": primarySubject == null
            ? null
            : primarySubjectValues.reverse[primarySubject],
        "summary": summary,
        "summary_short": summaryShort,
        "latest_major_action_date": latestMajorActionDate == null
            ? null
            : "${latestMajorActionDate.year.toString().padLeft(4, '0')}-${latestMajorActionDate.month.toString().padLeft(2, '0')}-${latestMajorActionDate.day.toString().padLeft(2, '0')}",
        "latest_major_action": latestMajorAction,
      };
}

enum BillType { HR, S }

final billTypeValues = EnumValues({"hr": BillType.HR, "s": BillType.S});

enum Committees {
  HOUSE_ARMED_SERVICES_COMMITTEE,
  SENATE_COMMERCE_SCIENCE_AND_TRANSPORTATION_COMMITTEE,
  HOUSE_WAYS_AND_MEANS_COMMITTEE
}

final committeesValues = EnumValues({
  "House Armed Services Committee": Committees.HOUSE_ARMED_SERVICES_COMMITTEE,
  "House Ways and Means Committee": Committees.HOUSE_WAYS_AND_MEANS_COMMITTEE,
  "Senate Commerce, Science, and Transportation Committee":
      Committees.SENATE_COMMERCE_SCIENCE_AND_TRANSPORTATION_COMMITTEE
});

enum PrimarySubject {
  SCIENCE_TECHNOLOGY_COMMUNICATIONS,
  ECONOMICS_AND_PUBLIC_FINANCE,
  PUBLIC_LANDS_AND_NATURAL_RESOURCES
}

final primarySubjectValues = EnumValues({
  "Economics and Public Finance": PrimarySubject.ECONOMICS_AND_PUBLIC_FINANCE,
  "Public Lands and Natural Resources":
      PrimarySubject.PUBLIC_LANDS_AND_NATURAL_RESOURCES,
  "Science, Technology, Communications":
      PrimarySubject.SCIENCE_TECHNOLOGY_COMMUNICATIONS
});

enum SponsorParty { D, R }

final sponsorPartyValues =
    EnumValues({"D": SponsorParty.D, "R": SponsorParty.R});

enum SponsorTitle { REP, SEN }

final sponsorTitleValues =
    EnumValues({"Rep.": SponsorTitle.REP, "Sen.": SponsorTitle.SEN});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
