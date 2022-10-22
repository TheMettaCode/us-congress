// To parse this JSON data, do
//
//     final bills = billsFromJson(jsonString);

import 'dart:convert';

Bills billsFromJson(String str) => Bills.fromJson(json.decode(str));

String billsToJson(Bills data) => json.encode(data.toJson());

class Bills {
  Bills({
    this.status,
    this.copyright,
    this.results,
  });

  final String status;
  final String copyright;
  final List<Result> results;

  factory Bills.fromJson(Map<String, dynamic> json) => Bills(
        status: json["status"] == null ? null : json["status"],
        copyright: json["copyright"] == null ? null : json["copyright"],
        results: json["results"] == null
            ? null
            : List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "copyright": copyright == null ? null : copyright,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class Result {
  Result({
    this.billId,
    this.billSlug,
    this.congress,
    this.bill,
    this.billType,
    this.number,
    this.billUri,
    this.title,
    this.shortTitle,
    this.sponsorTitle,
    this.sponsor,
    this.sponsorId,
    this.sponsorUri,
    this.sponsorParty,
    this.sponsorState,
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
    this.withdrawnCosponsors,
    this.primarySubject,
    this.committees,
    this.committeeCodes,
    this.subcommitteeCodes,
    this.latestMajorActionDate,
    this.latestMajorAction,
    this.housePassageVote,
    this.senatePassageVote,
    this.summary,
    this.summaryShort,
    this.versions,
    this.actions,
    this.votes,
  });

  final String billId;
  final String billSlug;
  final String congress;
  final String bill;
  final String billType;
  final String number;
  final String billUri;
  final String title;
  final String shortTitle;
  final String sponsorTitle;
  final String sponsor;
  final String sponsorId;
  final String sponsorUri;
  final String sponsorParty;
  final String sponsorState;
  final dynamic gpoPdfUri;
  final String congressdotgovUrl;
  final String govtrackUrl;
  final DateTime introducedDate;
  final bool active;
  final dynamic lastVote;
  final DateTime housePassage;
  final DateTime senatePassage;
  final dynamic enacted;
  final dynamic vetoed;
  final int cosponsors;
  final CosponsorsByParty cosponsorsByParty;
  final int withdrawnCosponsors;
  final String primarySubject;
  final String committees;
  final List<String> committeeCodes;
  final List<dynamic> subcommitteeCodes;
  final DateTime latestMajorActionDate;
  final String latestMajorAction;
  final DateTime housePassageVote;
  final DateTime senatePassageVote;
  final String summary;
  final String summaryShort;
  final List<Version> versions;
  final List<Action> actions;
  final List<dynamic> votes;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        billId: json["bill_id"] == null ? null : json["bill_id"],
        billSlug: json["bill_slug"] == null ? null : json["bill_slug"],
        congress: json["congress"] == null ? null : json["congress"],
        bill: json["bill"] == null ? null : json["bill"],
        billType: json["bill_type"] == null ? null : json["bill_type"],
        number: json["number"] == null ? null : json["number"],
        billUri: json["bill_uri"] == null ? null : json["bill_uri"],
        title: json["title"] == null ? null : json["title"],
        shortTitle: json["short_title"] == null ? null : json["short_title"],
        sponsorTitle:
            json["sponsor_title"] == null ? null : json["sponsor_title"],
        sponsor: json["sponsor"] == null ? null : json["sponsor"],
        sponsorId: json["sponsor_id"] == null ? null : json["sponsor_id"],
        sponsorUri: json["sponsor_uri"] == null ? null : json["sponsor_uri"],
        sponsorParty:
            json["sponsor_party"] == null ? null : json["sponsor_party"],
        sponsorState:
            json["sponsor_state"] == null ? null : json["sponsor_state"],
        gpoPdfUri: json["gpo_pdf_uri"],
        congressdotgovUrl: json["congressdotgov_url"] == null
            ? null
            : json["congressdotgov_url"],
        govtrackUrl: json["govtrack_url"] == null ? null : json["govtrack_url"],
        introducedDate: json["introduced_date"] == null
            ? null
            : DateTime.parse(json["introduced_date"]),
        active: json["active"] == null ? null : json["active"],
        lastVote: json["last_vote"],
        housePassage: json["house_passage"] == null
            ? null
            : DateTime.parse(json["house_passage"]),
        senatePassage: json["senate_passage"] == null
            ? null
            : DateTime.parse(json["senate_passage"]),
        enacted: json["enacted"],
        vetoed: json["vetoed"],
        cosponsors: json["cosponsors"] == null ? null : json["cosponsors"],
        cosponsorsByParty: json["cosponsors_by_party"] == null
            ? null
            : CosponsorsByParty.fromJson(json["cosponsors_by_party"]),
        withdrawnCosponsors: json["withdrawn_cosponsors"] == null
            ? null
            : json["withdrawn_cosponsors"],
        primarySubject:
            json["primary_subject"] == null ? null : json["primary_subject"],
        committees: json["committees"] == null ? null : json["committees"],
        committeeCodes: json["committee_codes"] == null
            ? null
            : List<String>.from(json["committee_codes"].map((x) => x)),
        subcommitteeCodes: json["subcommittee_codes"] == null
            ? null
            : List<dynamic>.from(json["subcommittee_codes"].map((x) => x)),
        latestMajorActionDate: json["latest_major_action_date"] == null
            ? null
            : DateTime.parse(json["latest_major_action_date"]),
        latestMajorAction: json["latest_major_action"] == null
            ? null
            : json["latest_major_action"],
        housePassageVote: json["house_passage_vote"] == null
            ? null
            : DateTime.parse(json["house_passage_vote"]),
        senatePassageVote: json["senate_passage_vote"] == null
            ? null
            : DateTime.parse(json["senate_passage_vote"]),
        summary: json["summary"] == null ? null : json["summary"],
        summaryShort:
            json["summary_short"] == null ? null : json["summary_short"],
        versions: json["versions"] == null
            ? null
            : List<Version>.from(
                json["versions"].map((x) => Version.fromJson(x))),
        actions: json["actions"] == null
            ? null
            : List<Action>.from(json["actions"].map((x) => Action.fromJson(x))),
        votes: json["votes"] == null
            ? null
            : List<dynamic>.from(json["votes"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "bill_id": billId == null ? 'noBillId' : billId,
        "bill_slug": billSlug == null ? null : billSlug,
        "congress": congress == null ? null : congress,
        "bill": bill == null ? null : bill,
        "bill_type": billType == null ? null : billType,
        "number": number == null ? null : number,
        "bill_uri": billUri == null ? null : billUri,
        "title": title == null ? null : title,
        "short_title": shortTitle == null ? null : shortTitle,
        "sponsor_title": sponsorTitle == null ? null : sponsorTitle,
        "sponsor": sponsor == null ? null : sponsor,
        "sponsor_id": sponsorId == null ? null : sponsorId,
        "sponsor_uri": sponsorUri == null ? null : sponsorUri,
        "sponsor_party": sponsorParty == null ? null : sponsorParty,
        "sponsor_state": sponsorState == null ? null : sponsorState,
        "gpo_pdf_uri": gpoPdfUri,
        "congressdotgov_url":
            congressdotgovUrl == null ? null : congressdotgovUrl,
        "govtrack_url": govtrackUrl == null ? null : govtrackUrl,
        "introduced_date": introducedDate == null
            ? null
            : "${introducedDate.year.toString().padLeft(4, '0')}-${introducedDate.month.toString().padLeft(2, '0')}-${introducedDate.day.toString().padLeft(2, '0')}",
        "active": active == null ? null : active,
        "last_vote": lastVote,
        "house_passage": housePassage == null
            ? null
            : "${housePassage.year.toString().padLeft(4, '0')}-${housePassage.month.toString().padLeft(2, '0')}-${housePassage.day.toString().padLeft(2, '0')}",
        "senate_passage": senatePassage,
        "enacted": enacted,
        "vetoed": vetoed,
        "cosponsors": cosponsors == null ? null : cosponsors,
        "cosponsors_by_party":
            cosponsorsByParty == null ? null : cosponsorsByParty.toJson(),
        "withdrawn_cosponsors":
            withdrawnCosponsors == null ? null : withdrawnCosponsors,
        "primary_subject": primarySubject == null ? null : primarySubject,
        "committees": committees == null ? null : committees,
        "committee_codes": committeeCodes == null
            ? null
            : List<dynamic>.from(committeeCodes.map((x) => x)),
        "subcommittee_codes": subcommitteeCodes == null
            ? null
            : List<dynamic>.from(subcommitteeCodes.map((x) => x)),
        "latest_major_action_date": latestMajorActionDate == null
            ? null
            : "${latestMajorActionDate.year.toString().padLeft(4, '0')}-${latestMajorActionDate.month.toString().padLeft(2, '0')}-${latestMajorActionDate.day.toString().padLeft(2, '0')}",
        "latest_major_action":
            latestMajorAction == null ? null : latestMajorAction,
        "house_passage_vote": housePassageVote == null
            ? null
            : "${housePassageVote.year.toString().padLeft(4, '0')}-${housePassageVote.month.toString().padLeft(2, '0')}-${housePassageVote.day.toString().padLeft(2, '0')}",
        "senate_passage_vote": senatePassageVote,
        "summary": summary == null ? null : summary,
        "summary_short": summaryShort == null ? null : summaryShort,
        "versions": versions == null
            ? null
            : List<dynamic>.from(versions.map((x) => x.toJson())),
        "actions": actions == null
            ? null
            : List<dynamic>.from(actions.map((x) => x.toJson())),
        "votes": votes == null ? null : List<dynamic>.from(votes.map((x) => x)),
      };
}

class Action {
  Action({
    this.id,
    this.chamber,
    this.actionType,
    this.datetime,
    this.description,
  });

  final int id;
  final Chamber chamber;
  final ActionType actionType;
  final DateTime datetime;
  final String description;

  factory Action.fromJson(Map<String, dynamic> json) => Action(
        id: json["id"] == null ? null : json["id"],
        chamber:
            json["chamber"] == null ? null : chamberValues.map[json["chamber"]],
        actionType: json["action_type"] == null
            ? null
            : actionTypeValues.map[json["action_type"]],
        datetime:
            json["datetime"] == null ? null : DateTime.parse(json["datetime"]),
        description: json["description"] == null ? null : json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "chamber": chamber == null ? null : chamberValues.reverse[chamber],
        "action_type":
            actionType == null ? null : actionTypeValues.reverse[actionType],
        "datetime": datetime == null
            ? null
            : "${datetime.year.toString().padLeft(4, '0')}-${datetime.month.toString().padLeft(2, '0')}-${datetime.day.toString().padLeft(2, '0')}",
        "description": description == null ? null : description,
      };
}

enum ActionType { INTRO_REFERRAL, FLOOR }

final actionTypeValues = EnumValues(
    {"Floor": ActionType.FLOOR, "IntroReferral": ActionType.INTRO_REFERRAL});

enum Chamber { SENATE, HOUSE }

final chamberValues =
    EnumValues({"House": Chamber.HOUSE, "Senate": Chamber.SENATE});

class CosponsorsByParty {
  CosponsorsByParty({
    this.r,
    this.d,
  });

  final int r;
  final int d;

  factory CosponsorsByParty.fromJson(Map<String, dynamic> json) =>
      CosponsorsByParty(
        r: json["R"] == null ? null : json["R"],
        d: json["D"] == null ? null : json["D"],
      );

  Map<String, dynamic> toJson() => {
        "R": r == null ? null : r,
        "D": d == null ? null : d,
      };
}

class Version {
  Version({
    this.status,
    this.title,
    this.url,
    this.congressdotgovUrl,
  });

  final String status;
  final String title;
  final String url;
  final String congressdotgovUrl;

  factory Version.fromJson(Map<String, dynamic> json) => Version(
        status: json["status"] == null ? null : json["status"],
        title: json["title"] == null ? null : json["title"],
        url: json["url"] == null ? null : json["url"],
        congressdotgovUrl: json["congressdotgov_url"] == null
            ? null
            : json["congressdotgov_url"],
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "title": title == null ? null : title,
        "url": url == null ? null : url,
        "congressdotgov_url":
            congressdotgovUrl == null ? null : congressdotgovUrl,
      };
}

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
