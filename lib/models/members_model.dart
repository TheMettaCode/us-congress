// To parse this JSON data, do
//
//     final members = membersFromJson(jsonString);

import 'dart:convert';

Members membersFromJson(String str) => Members.fromJson(json.decode(str));

String membersToJson(Members data) => json.encode(data.toJson());

class Members {
  Members({
    this.status,
    this.copyright,
    this.results,
  });

  final String status;
  final String copyright;
  final List<MemberResult> results;

  factory Members.fromJson(Map<String, dynamic> json) => Members(
        status: json["status"],
        copyright: json["copyright"],
        results: json["results"] == null
            ? null
            : List<MemberResult>.from(
                json["results"].map((x) => MemberResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class MemberResult {
  MemberResult({
    this.id,
    this.memberId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    this.dateOfBirth,
    this.gender,
    this.url,
    this.timesTopicsUrl,
    this.timesTag,
    this.govtrackId,
    this.cspanId,
    this.votesmartId,
    this.icpsrId,
    this.twitterAccount,
    this.facebookAccount,
    this.youtubeAccount,
    this.crpId,
    this.googleEntityId,
    this.rssUrl,
    this.inOffice,
    this.currentParty,
    this.mostRecentVote,
    this.lastUpdated,
    this.roles,
  });

  final String id;
  final String memberId;
  final String firstName;
  final String middleName;
  final String lastName;
  final dynamic suffix;
  final DateTime dateOfBirth;
  final String gender;
  final String url;
  final String timesTopicsUrl;
  final String timesTag;
  final String govtrackId;
  final String cspanId;
  final String votesmartId;
  final String icpsrId;
  final String twitterAccount;
  final String facebookAccount;
  final dynamic youtubeAccount;
  final String crpId;
  final String googleEntityId;
  final dynamic rssUrl;
  final bool inOffice;
  final String currentParty;
  final String mostRecentVote;
  final String lastUpdated;
  final List<Role> roles;

  factory MemberResult.fromJson(Map<String, dynamic> json) => MemberResult(
        id: json["id"],
        memberId: json["member_id"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        suffix: json["suffix"],
        dateOfBirth: json["date_of_birth"] == null
            ? null
            : DateTime.parse(json["date_of_birth"]),
        gender: json["gender"],
        url: json["url"],
        timesTopicsUrl: json["times_topics_url"],
        timesTag: json["times_tag"],
        govtrackId: json["govtrack_id"],
        cspanId: json["cspan_id"],
        votesmartId: json["votesmart_id"],
        icpsrId: json["icpsr_id"],
        twitterAccount: json["twitter_account"],
        facebookAccount: json["facebook_account"],
        youtubeAccount: json["youtube_account"],
        crpId: json["crp_id"],
        googleEntityId: json["google_entity_id"],
        rssUrl: json["rss_url"],
        inOffice: json["in_office"],
        currentParty: json["current_party"],
        mostRecentVote: json["most_recent_vote"],
        lastUpdated: json["last_updated"],
        roles: json["roles"] == null
            ? null
            : List<Role>.from(json["roles"].map((x) => Role.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "member_id": memberId,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "suffix": suffix,
        "date_of_birth": dateOfBirth == null
            ? null
            : "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
        "gender": gender,
        "url": url,
        "times_topics_url": timesTopicsUrl,
        "times_tag": timesTag,
        "govtrack_id": govtrackId,
        "cspan_id": cspanId,
        "votesmart_id": votesmartId,
        "icpsr_id": icpsrId,
        "twitter_account": twitterAccount,
        "facebook_account": facebookAccount,
        "youtube_account": youtubeAccount,
        "crp_id": crpId,
        "google_entity_id": googleEntityId,
        "rss_url": rssUrl,
        "in_office": inOffice,
        "current_party": currentParty,
        "most_recent_vote": mostRecentVote,
        "last_updated": lastUpdated,
        "roles": roles == null
            ? null
            : List<dynamic>.from(roles.map((x) => x.toJson())),
      };
}

class Role {
  Role({
    this.congress,
    this.chamber,
    this.title,
    this.shortTitle,
    this.state,
    this.party,
    this.leadershipRole,
    this.fecCandidateId,
    this.seniority,
    this.district,
    this.atLarge,
    this.ocdId,
    this.startDate,
    this.endDate,
    this.office,
    this.phone,
    this.fax,
    this.contactForm,
    this.cookPvi,
    this.dwNominate,
    this.idealPoint,
    this.nextElection,
    this.totalVotes,
    this.missedVotes,
    this.totalPresent,
    this.senateClass,
    this.stateRank,
    this.lisId,
    this.billsSponsored,
    this.billsCosponsored,
    this.missedVotesPct,
    this.votesWithPartyPct,
    this.votesAgainstPartyPct,
    this.committees,
    this.subcommittees,
  });

  final String congress;
  final String chamber;
  final String title;
  final String shortTitle;
  final String state;
  final String party;
  final dynamic leadershipRole;
  final String fecCandidateId;
  final String seniority;
  final String district;
  final bool atLarge;
  final String ocdId;
  final DateTime startDate;
  final DateTime endDate;
  final String office;
  final String phone;
  final dynamic fax;
  final dynamic contactForm;
  final String cookPvi;
  final double dwNominate;
  final dynamic idealPoint;
  final String nextElection;
  final int totalVotes;
  final int missedVotes;
  final int totalPresent;
  final String senateClass;
  final String stateRank;
  final String lisId;
  final int billsSponsored;
  final int billsCosponsored;
  final double missedVotesPct;
  final double votesWithPartyPct;
  final double votesAgainstPartyPct;
  final List<Committee> committees;
  final List<Committee> subcommittees;

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        congress: json["congress"],
        chamber: json["chamber"],
        title: json["title"],
        shortTitle: json["short_title"],
        state: json["state"],
        party: json["party"],
        leadershipRole: json["leadership_role"],
        fecCandidateId: json["fec_candidate_id"],
        seniority: json["seniority"],
        district: json["district"],
        atLarge: json["at_large"],
        ocdId: json["ocd_id"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        office: json["office"],
        phone: json["phone"],
        fax: json["fax"],
        contactForm: json["contact_form"],
        cookPvi: json["cook_pvi"],
        dwNominate:
            json["dw_nominate"] == null ? null : json["dw_nominate"].toDouble(),
        idealPoint: json["ideal_point"],
        nextElection: json["next_election"],
        totalVotes: json["total_votes"],
        missedVotes: json["missed_votes"],
        totalPresent: json["total_present"],
        senateClass: json["senate_class"],
        stateRank: json["state_rank"],
        lisId: json["lis_id"],
        billsSponsored: json["bills_sponsored"],
        billsCosponsored: json["bills_cosponsored"],
        missedVotesPct: json["missed_votes_pct"] == null
            ? null
            : json["missed_votes_pct"].toDouble(),
        votesWithPartyPct: json["votes_with_party_pct"] == null
            ? null
            : json["votes_with_party_pct"].toDouble(),
        votesAgainstPartyPct: json["votes_against_party_pct"] == null
            ? null
            : json["votes_against_party_pct"].toDouble(),
        committees: json["committees"] == null
            ? null
            : List<Committee>.from(
                json["committees"].map((x) => Committee.fromJson(x))),
        subcommittees: json["subcommittees"] == null
            ? null
            : List<Committee>.from(
                json["subcommittees"].map((x) => Committee.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "congress": congress,
        "chamber": chamber,
        "title": title,
        "short_title": shortTitle,
        "state": state,
        "party": party,
        "leadership_role": leadershipRole,
        "fec_candidate_id": fecCandidateId,
        "seniority": seniority,
        "district": district,
        "at_large": atLarge,
        "ocd_id": ocdId,
        "start_date": startDate == null
            ? null
            : "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date": endDate == null
            ? null
            : "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "office": office,
        "phone": phone,
        "fax": fax,
        "contact_form": contactForm,
        "cook_pvi": cookPvi,
        "dw_nominate": dwNominate,
        "ideal_point": idealPoint,
        "next_election": nextElection,
        "total_votes": totalVotes,
        "missed_votes": missedVotes,
        "total_present": totalPresent,
        "senate_class": senateClass,
        "state_rank": stateRank,
        "lis_id": lisId,
        "bills_sponsored": billsSponsored,
        "bills_cosponsored": billsCosponsored,
        "missed_votes_pct": missedVotesPct,
        "votes_with_party_pct": votesWithPartyPct,
        "votes_against_party_pct": votesAgainstPartyPct,
        "committees": committees == null
            ? null
            : List<dynamic>.from(committees.map((x) => x.toJson())),
        "subcommittees": subcommittees == null
            ? null
            : List<dynamic>.from(subcommittees.map((x) => x.toJson())),
      };
}

class Committee {
  Committee({
    this.name,
    this.code,
    this.apiUri,
    this.side,
    this.title,
    this.rankInParty,
    // this.beginDate,
    // this.endDate,
    this.parentCommitteeId,
  });

  final String name;
  final String code;
  final String apiUri;
  final Side side;
  final Title title;
  final int rankInParty;
  // final DateTime beginDate;
  // final DateTime endDate;
  final ParentCommitteeId parentCommitteeId;

  factory Committee.fromJson(Map<String, dynamic> json) => Committee(
        name: json["name"],
        code: json["code"],
        apiUri: json["api_uri"],
        side: json["side"] == null ? null : sideValues.map[json["side"]],
        title: json["title"] == null ? null : titleValues.map[json["title"]],
        rankInParty: json["rank_in_party"],
        // beginDate: json["begin_date"] == null ? null : DateTime.parse(json["begin_date"]),
        // endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        parentCommitteeId: json["parent_committee_id"] == null
            ? null
            : parentCommitteeIdValues.map[json["parent_committee_id"]],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
        "api_uri": apiUri,
        "side": side == null ? null : sideValues.reverse[side],
        "title": title == null ? null : titleValues.reverse[title],
        "rank_in_party": rankInParty,
        // "begin_date": beginDate == null ? null : "${beginDate.year.toString().padLeft(4, '0')}-${beginDate.month.toString().padLeft(2, '0')}-${beginDate.day.toString().padLeft(2, '0')}",
        // "end_date": endDate == null ? null : "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "parent_committee_id": parentCommitteeId == null
            ? null
            : parentCommitteeIdValues.reverse[parentCommitteeId],
      };
}

enum ParentCommitteeId { HSAG, HSAS, HSSM }

final parentCommitteeIdValues = EnumValues({
  "HSAG": ParentCommitteeId.HSAG,
  "HSAS": ParentCommitteeId.HSAS,
  "HSSM": ParentCommitteeId.HSSM
});

enum Side { MINORITY, MAJORITY }

final sideValues =
    EnumValues({"majority": Side.MAJORITY, "minority": Side.MINORITY});

enum Title { MEMBER, RANKING_MEMBER, CHAIR }

final titleValues = EnumValues({
  "Chair": Title.CHAIR,
  "Member": Title.MEMBER,
  "Ranking Member": Title.RANKING_MEMBER
});

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
