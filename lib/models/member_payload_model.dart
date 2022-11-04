// To parse this JSON data, do
//
//     final memberPayload = memberPayloadFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

MemberPayload memberPayloadFromJson(String str) =>
    MemberPayload.fromJson(json.decode(str));

String memberPayloadToJson(MemberPayload data) => json.encode(data.toJson());

class MemberPayload {
  MemberPayload({
    @required this.status,
    @required this.copyright,
    @required this.results,
  });

  final String status;
  final String copyright;
  final List<MembersListResult> results;

  factory MemberPayload.fromJson(Map<String, dynamic> json) => MemberPayload(
        status: json["status"],
        copyright: json["copyright"],
        results: json["results"] == null
            ? null
            : List<MembersListResult>.from(
                json["results"].map((x) => MembersListResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class MembersListResult {
  MembersListResult({
    @required this.congress,
    @required this.chamber,
    @required this.numResults,
    @required this.offset,
    @required this.members,
  });

  final String congress;
  final String chamber;
  final int numResults;
  final int offset;
  final List<ChamberMember> members;

  factory MembersListResult.fromJson(Map<String, dynamic> json) =>
      MembersListResult(
        congress: json["congress"],
        chamber: json["chamber"],
        numResults: json["num_results"],
        offset: json["offset"],
        members: json["members"] == null
            ? null
            : List<ChamberMember>.from(
                json["members"].map((x) => ChamberMember.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "congress": congress,
        "chamber": chamber,
        "num_results": numResults,
        "offset": offset,
        "members": members == null
            ? null
            : List<dynamic>.from(members.map((x) => x.toJson())),
      };
}

class ChamberMember {
  ChamberMember({
    @required this.id,
    @required this.title,
    @required this.shortTitle,
    @required this.apiUri,
    @required this.firstName,
    @required this.middleName,
    @required this.lastName,
    @required this.suffix,
    @required this.dateOfBirth,
    @required this.gender,
    @required this.party,
    @required this.leadershipRole,
    @required this.twitterAccount,
    @required this.facebookAccount,
    @required this.youtubeAccount,
    @required this.govtrackId,
    @required this.cspanId,
    @required this.votesmartId,
    @required this.icpsrId,
    @required this.crpId,
    @required this.googleEntityId,
    @required this.fecCandidateId,
    @required this.url,
    @required this.rssUrl,
    @required this.contactForm,
    @required this.inOffice,
    @required this.cookPvi,
    @required this.dwNominate,
    @required this.idealPoint,
    @required this.seniority,
    @required this.nextElection,
    @required this.totalVotes,
    @required this.missedVotes,
    @required this.totalPresent,
    @required this.lastUpdated,
    @required this.ocdId,
    @required this.office,
    @required this.phone,
    @required this.fax,
    @required this.state,
    @required this.district,
    @required this.atLarge,
    @required this.geoid,
    @required this.missedVotesPct,
    @required this.votesWithPartyPct,
    @required this.votesAgainstPartyPct,
  });

  final String id;
  final String title;
  final String shortTitle;
  final String apiUri;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final DateTime dateOfBirth;
  final String gender;
  final String party;
  final String leadershipRole;
  final String twitterAccount;
  final String facebookAccount;
  final String youtubeAccount;
  final String govtrackId;
  final String cspanId;
  final String votesmartId;
  final String icpsrId;
  final String crpId;
  final String googleEntityId;
  final String fecCandidateId;
  final String url;
  final String rssUrl;
  final dynamic contactForm;
  final bool inOffice;
  final String cookPvi;
  final double dwNominate;
  final dynamic idealPoint;
  final String seniority;
  final String nextElection;
  final int totalVotes;
  final int missedVotes;
  final int totalPresent;
  final String lastUpdated;
  final String ocdId;
  final String office;
  final String phone;
  final dynamic fax;
  final String state;
  final String district;
  final bool atLarge;
  final String geoid;
  final double missedVotesPct;
  final double votesWithPartyPct;
  final double votesAgainstPartyPct;

  factory ChamberMember.fromJson(Map<String, dynamic> json) => ChamberMember(
        id: json["id"],
        title: json["title"],
        shortTitle: json["short_title"],
        apiUri: json["api_uri"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        suffix: json["suffix"],
        dateOfBirth: json["date_of_birth"] == null
            ? null
            : DateTime.parse(json["date_of_birth"]),
        gender: json["gender"],
        party: json["party"],
        leadershipRole: json["leadership_role"],
        twitterAccount: json["twitter_account"],
        facebookAccount: json["facebook_account"],
        youtubeAccount: json["youtube_account"],
        govtrackId: json["govtrack_id"],
        cspanId: json["cspan_id"],
        votesmartId: json["votesmart_id"],
        icpsrId: json["icpsr_id"],
        crpId: json["crp_id"],
        googleEntityId: json["google_entity_id"],
        fecCandidateId: json["fec_candidate_id"],
        url: json["url"],
        rssUrl: json["rss_url"],
        contactForm: json["contact_form"],
        inOffice: json["in_office"],
        cookPvi: json["cook_pvi"],
        dwNominate:
            json["dw_nominate"] == null ? null : json["dw_nominate"].toDouble(),
        idealPoint: json["ideal_point"],
        seniority: json["seniority"],
        nextElection: json["next_election"],
        totalVotes: json["total_votes"],
        missedVotes: json["missed_votes"],
        totalPresent: json["total_present"],
        lastUpdated: json["last_updated"],
        ocdId: json["ocd_id"],
        office: json["office"] ?? 'Office not available',
        phone: json["phone"] ?? 'Phone not available',
        fax: json["fax"],
        state: json["state"],
        district: json["district"],
        atLarge: json["at_large"],
        geoid: json["geoid"],
        missedVotesPct: json["missed_votes_pct"] == null
            ? null
            : json["missed_votes_pct"].toDouble(),
        votesWithPartyPct: json["votes_with_party_pct"] == null
            ? null
            : json["votes_with_party_pct"].toDouble(),
        votesAgainstPartyPct: json["votes_against_party_pct"] == null
            ? null
            : json["votes_against_party_pct"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "short_title": shortTitle,
        "api_uri": apiUri,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "suffix": suffix,
        "date_of_birth": dateOfBirth == null
            ? null
            : "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
        "gender": gender,
        "party": party,
        "leadership_role": leadershipRole,
        "twitter_account": twitterAccount,
        "facebook_account": facebookAccount,
        "youtube_account": youtubeAccount,
        "govtrack_id": govtrackId,
        "cspan_id": cspanId,
        "votesmart_id": votesmartId,
        "icpsr_id": icpsrId,
        "crp_id": crpId,
        "google_entity_id": googleEntityId,
        "fec_candidate_id": fecCandidateId,
        "url": url,
        "rss_url": rssUrl,
        "contact_form": contactForm,
        "in_office": inOffice,
        "cook_pvi": cookPvi,
        "dw_nominate": dwNominate,
        "ideal_point": idealPoint,
        "seniority": seniority,
        "next_election": nextElection,
        "total_votes": totalVotes,
        "missed_votes": missedVotes,
        "total_present": totalPresent,
        "last_updated": lastUpdated,
        "ocd_id": ocdId,
        "office": office,
        "phone": phone,
        "fax": fax,
        "state": state,
        "district": district,
        "at_large": atLarge,
        "geoid": geoid,
        "missed_votes_pct": missedVotesPct,
        "votes_with_party_pct": votesWithPartyPct,
        "votes_against_party_pct": votesAgainstPartyPct,
      };
}
