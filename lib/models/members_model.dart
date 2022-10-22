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
        status: json["status"] == null ? null : json["status"],
        copyright: json["copyright"] == null ? null : json["copyright"],
        results: json["results"] == null
            ? null
            : List<MemberResult>.from(
                json["results"].map((x) => MemberResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "copyright": copyright == null ? null : copyright,
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
        id: json["id"] == null ? null : json["id"],
        memberId: json["member_id"] == null ? null : json["member_id"],
        firstName: json["first_name"] == null ? null : json["first_name"],
        middleName: json["middle_name"] == null ? null : json["middle_name"],
        lastName: json["last_name"] == null ? null : json["last_name"],
        suffix: json["suffix"],
        dateOfBirth: json["date_of_birth"] == null
            ? null
            : DateTime.parse(json["date_of_birth"]),
        gender: json["gender"] == null ? null : json["gender"],
        url: json["url"] == null ? null : json["url"],
        timesTopicsUrl:
            json["times_topics_url"] == null ? null : json["times_topics_url"],
        timesTag: json["times_tag"] == null ? null : json["times_tag"],
        govtrackId: json["govtrack_id"] == null ? null : json["govtrack_id"],
        cspanId: json["cspan_id"] == null ? null : json["cspan_id"],
        votesmartId: json["votesmart_id"] == null ? null : json["votesmart_id"],
        icpsrId: json["icpsr_id"] == null ? null : json["icpsr_id"],
        twitterAccount:
            json["twitter_account"] == null ? null : json["twitter_account"],
        facebookAccount:
            json["facebook_account"] == null ? null : json["facebook_account"],
        youtubeAccount: json["youtube_account"],
        crpId: json["crp_id"] == null ? null : json["crp_id"],
        googleEntityId:
            json["google_entity_id"] == null ? null : json["google_entity_id"],
        rssUrl: json["rss_url"],
        inOffice: json["in_office"] == null ? null : json["in_office"],
        currentParty:
            json["current_party"] == null ? null : json["current_party"],
        mostRecentVote:
            json["most_recent_vote"] == null ? null : json["most_recent_vote"],
        lastUpdated: json["last_updated"] == null ? null : json["last_updated"],
        roles: json["roles"] == null
            ? null
            : List<Role>.from(json["roles"].map((x) => Role.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "member_id": memberId == null ? null : memberId,
        "first_name": firstName == null ? null : firstName,
        "middle_name": middleName == null ? null : middleName,
        "last_name": lastName == null ? null : lastName,
        "suffix": suffix,
        "date_of_birth": dateOfBirth == null
            ? null
            : "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
        "gender": gender == null ? null : gender,
        "url": url == null ? null : url,
        "times_topics_url": timesTopicsUrl == null ? null : timesTopicsUrl,
        "times_tag": timesTag == null ? null : timesTag,
        "govtrack_id": govtrackId == null ? null : govtrackId,
        "cspan_id": cspanId == null ? null : cspanId,
        "votesmart_id": votesmartId == null ? null : votesmartId,
        "icpsr_id": icpsrId == null ? null : icpsrId,
        "twitter_account": twitterAccount == null ? null : twitterAccount,
        "facebook_account": facebookAccount == null ? null : facebookAccount,
        "youtube_account": youtubeAccount,
        "crp_id": crpId == null ? null : crpId,
        "google_entity_id": googleEntityId == null ? null : googleEntityId,
        "rss_url": rssUrl,
        "in_office": inOffice == null ? null : inOffice,
        "current_party": currentParty == null ? null : currentParty,
        "most_recent_vote": mostRecentVote == null ? null : mostRecentVote,
        "last_updated": lastUpdated == null ? null : lastUpdated,
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
        congress: json["congress"] == null ? null : json["congress"],
        chamber: json["chamber"] == null ? null : json["chamber"],
        title: json["title"] == null ? null : json["title"],
        shortTitle: json["short_title"] == null ? null : json["short_title"],
        state: json["state"] == null ? null : json["state"],
        party: json["party"] == null ? null : json["party"],
        leadershipRole: json["leadership_role"],
        fecCandidateId:
            json["fec_candidate_id"] == null ? null : json["fec_candidate_id"],
        seniority: json["seniority"] == null ? null : json["seniority"],
        district: json["district"] == null ? null : json["district"],
        atLarge: json["at_large"] == null ? null : json["at_large"],
        ocdId: json["ocd_id"] == null ? null : json["ocd_id"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        office: json["office"] == null ? null : json["office"],
        phone: json["phone"] == null ? null : json["phone"],
        fax: json["fax"],
        contactForm: json["contact_form"],
        cookPvi: json["cook_pvi"] == null ? null : json["cook_pvi"],
        dwNominate:
            json["dw_nominate"] == null ? null : json["dw_nominate"].toDouble(),
        idealPoint: json["ideal_point"],
        nextElection:
            json["next_election"] == null ? null : json["next_election"],
        totalVotes: json["total_votes"] == null ? null : json["total_votes"],
        missedVotes: json["missed_votes"] == null ? null : json["missed_votes"],
        totalPresent:
            json["total_present"] == null ? null : json["total_present"],
        senateClass: json["senate_class"] == null ? null : json["senate_class"],
        stateRank: json["state_rank"] == null ? null : json["state_rank"],
        lisId: json["lis_id"] == null ? null : json["lis_id"],
        billsSponsored:
            json["bills_sponsored"] == null ? null : json["bills_sponsored"],
        billsCosponsored: json["bills_cosponsored"] == null
            ? null
            : json["bills_cosponsored"],
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
        "congress": congress == null ? null : congress,
        "chamber": chamber == null ? null : chamber,
        "title": title == null ? null : title,
        "short_title": shortTitle == null ? null : shortTitle,
        "state": state == null ? null : state,
        "party": party == null ? null : party,
        "leadership_role": leadershipRole,
        "fec_candidate_id": fecCandidateId == null ? null : fecCandidateId,
        "seniority": seniority == null ? null : seniority,
        "district": district == null ? null : district,
        "at_large": atLarge == null ? null : atLarge,
        "ocd_id": ocdId == null ? null : ocdId,
        "start_date": startDate == null
            ? null
            : "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date": endDate == null
            ? null
            : "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "office": office == null ? null : office,
        "phone": phone == null ? null : phone,
        "fax": fax,
        "contact_form": contactForm,
        "cook_pvi": cookPvi == null ? null : cookPvi,
        "dw_nominate": dwNominate == null ? null : dwNominate,
        "ideal_point": idealPoint,
        "next_election": nextElection == null ? null : nextElection,
        "total_votes": totalVotes == null ? null : totalVotes,
        "missed_votes": missedVotes == null ? null : missedVotes,
        "total_present": totalPresent == null ? null : totalPresent,
        "senate_class": senateClass == null ? null : senateClass,
        "state_rank": stateRank == null ? null : stateRank,
        "lis_id": lisId == null ? null : lisId,
        "bills_sponsored": billsSponsored == null ? null : billsSponsored,
        "bills_cosponsored": billsCosponsored == null ? null : billsCosponsored,
        "missed_votes_pct": missedVotesPct == null ? null : missedVotesPct,
        "votes_with_party_pct":
            votesWithPartyPct == null ? null : votesWithPartyPct,
        "votes_against_party_pct":
            votesAgainstPartyPct == null ? null : votesAgainstPartyPct,
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
        name: json["name"] == null ? null : json["name"],
        code: json["code"] == null ? null : json["code"],
        apiUri: json["api_uri"] == null ? null : json["api_uri"],
        side: json["side"] == null ? null : sideValues.map[json["side"]],
        title: json["title"] == null ? null : titleValues.map[json["title"]],
        rankInParty:
            json["rank_in_party"] == null ? null : json["rank_in_party"],
        // beginDate: json["begin_date"] == null ? null : DateTime.parse(json["begin_date"]),
        // endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        parentCommitteeId: json["parent_committee_id"] == null
            ? null
            : parentCommitteeIdValues.map[json["parent_committee_id"]],
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "code": code == null ? null : code,
        "api_uri": apiUri == null ? null : apiUri,
        "side": side == null ? null : sideValues.reverse[side],
        "title": title == null ? null : titleValues.reverse[title],
        "rank_in_party": rankInParty == null ? null : rankInParty,
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
