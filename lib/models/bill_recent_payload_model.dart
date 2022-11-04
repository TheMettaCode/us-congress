// To parse this JSON data, do
//
//     final recentbills = recentbillsFromJson(jsonString);

import 'dart:convert';

Recentbills recentbillsFromJson(String str) =>
    Recentbills.fromJson(json.decode(str));

String recentbillsToJson(Recentbills data) => json.encode(data.toJson());

class Recentbills {
  Recentbills({
    this.status,
    this.copyright,
    this.results,
  });

  final String status;
  final String copyright;
  final List<RecentResult> results;

  factory Recentbills.fromJson(Map<String, dynamic> json) => Recentbills(
        status: json["status"],
        copyright: json["copyright"],
        results: json["results"] == null
            ? null
            : List<RecentResult>.from(
                json["results"].map((x) => RecentResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class RecentResult {
  RecentResult({
    this.congress,
    this.chamber,
    this.numResults,
    this.offset,
    this.bills,
  });

  final int congress;
  final String chamber;
  final int numResults;
  final int offset;
  final List<UpdatedBill> bills;

  factory RecentResult.fromJson(Map<String, dynamic> json) => RecentResult(
        congress: json["congress"],
        chamber: json["chamber"],
        numResults: json["num_results"],
        offset: json["offset"],
        bills: json["bills"] == null
            ? null
            : List<UpdatedBill>.from(
                json["bills"].map((x) => UpdatedBill.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "congress": congress,
        "chamber": chamber,
        "num_results": numResults,
        "offset": offset,
        "bills": bills == null
            ? null
            : List<dynamic>.from(bills.map((x) => x.toJson())),
      };
}

class UpdatedBill {
  UpdatedBill({
    this.billId,
    this.billSlug,
    this.billType,
    this.number,
    this.billUri,
    this.title,
    this.shortTitle,
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
    this.lastVote,
    this.housePassage,
    this.senatePassage,
    this.enacted,
    this.vetoed,
    this.cosponsors,
    this.cosponsorsByParty,
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
  final String billSlug;
  final BillType billType;
  final String number;
  final String billUri;
  final String title;
  final String shortTitle;
  final SponsorTitle sponsorTitle;
  final String sponsorId;
  final String sponsorName;
  final String sponsorState;
  final SponsorParty sponsorParty;
  final String sponsorUri;
  final dynamic gpoPdfUri;
  final String congressdotgovUrl;
  final String govtrackUrl;
  final DateTime introducedDate;
  final bool active;
  final DateTime lastVote;
  final DateTime housePassage;
  final DateTime senatePassage;
  final dynamic enacted;
  final dynamic vetoed;
  final int cosponsors;
  final CosponsorsByParty cosponsorsByParty;
  final String committees;
  final List<String> committeeCodes;
  final List<dynamic> subcommitteeCodes;
  final String primarySubject;
  final String summary;
  final String summaryShort;
  final DateTime latestMajorActionDate;
  final String latestMajorAction;

  factory UpdatedBill.fromJson(Map<String, dynamic> json) => UpdatedBill(
        billId: json["bill_id"],
        billSlug: json["bill_slug"],
        billType: json["bill_type"] == null
            ? null
            : billTypeValues.map[json["bill_type"]],
        number: json["number"],
        billUri: json["bill_uri"],
        title: json["title"],
        shortTitle: json["short_title"],
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
        lastVote: json["last_vote"] == null
            ? null
            : DateTime.parse(json["last_vote"]),
        housePassage: json["house_passage"] == null
            ? null
            : DateTime.parse(json["house_passage"]),
        senatePassage: json["senate_passage"] == null
            ? null
            : DateTime.parse(json["senate_passage"]),
        enacted: json["enacted"],
        vetoed: json["vetoed"],
        cosponsors: json["cosponsors"],
        cosponsorsByParty: json["cosponsors_by_party"] == null
            ? null
            : CosponsorsByParty.fromJson(json["cosponsors_by_party"]),
        committees: json["committees"],
        committeeCodes: json["committee_codes"] == null
            ? null
            : List<String>.from(json["committee_codes"].map((x) => x)),
        subcommitteeCodes: json["subcommittee_codes"] == null
            ? null
            : List<dynamic>.from(json["subcommittee_codes"].map((x) => x)),
        primarySubject: json["primary_subject"],
        summary: json["summary"],
        summaryShort: json["summary_short"],
        latestMajorActionDate: json["latest_major_action_date"] == null
            ? null
            : DateTime.parse(json["latest_major_action_date"]),
        latestMajorAction: json["latest_major_action"],
      );

  Map<String, dynamic> toJson() => {
        "bill_id": billId ?? 'noBillId',
        "bill_slug": billSlug,
        "bill_type": billType == null ? null : billTypeValues.reverse[billType],
        "number": number,
        "bill_uri": billUri,
        "title": title,
        "short_title": shortTitle,
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
        "last_vote": lastVote == null
            ? null
            : "${lastVote.year.toString().padLeft(4, '0')}-${lastVote.month.toString().padLeft(2, '0')}-${lastVote.day.toString().padLeft(2, '0')}",
        "house_passage": housePassage == null ? null : housePassage.toString(),
        "senate_passage":
            senatePassage == null ? null : senatePassage.toString(),
        "enacted": enacted,
        "vetoed": vetoed,
        "cosponsors": cosponsors,
        "cosponsors_by_party":
            cosponsorsByParty == null ? null : cosponsorsByParty.toJson(),
        "committees": committees,
        "committee_codes": committeeCodes == null
            ? null
            : List<dynamic>.from(committeeCodes.map((x) => x)),
        "subcommittee_codes": subcommitteeCodes == null
            ? null
            : List<dynamic>.from(subcommitteeCodes.map((x) => x)),
        "primary_subject": primarySubject,
        "summary": summary,
        "summary_short": summaryShort,
        "latest_major_action_date": latestMajorActionDate == null
            ? null
            : "${latestMajorActionDate.year.toString().padLeft(4, '0')}-${latestMajorActionDate.month.toString().padLeft(2, '0')}-${latestMajorActionDate.day.toString().padLeft(2, '0')}",
        "latest_major_action": latestMajorAction,
      };
}

enum BillType { HR, HRES }

final billTypeValues = EnumValues({"hr": BillType.HR, "hres": BillType.HRES});

class CosponsorsByParty {
  CosponsorsByParty({
    this.d,
    this.r,
  });

  final int d;
  final int r;

  factory CosponsorsByParty.fromJson(Map<String, dynamic> json) =>
      CosponsorsByParty(
        d: json["D"],
        r: json["R"],
      );

  Map<String, dynamic> toJson() => {
        "D": d,
        "R": r,
      };
}

enum SponsorParty { R, D }

final sponsorPartyValues =
    EnumValues({"D": SponsorParty.D, "R": SponsorParty.R});

enum SponsorTitle { REP }

final sponsorTitleValues = EnumValues({"Rep.": SponsorTitle.REP});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
