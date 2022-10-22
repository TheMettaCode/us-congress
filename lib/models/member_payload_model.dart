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
        status: json["status"] == null ? null : json["status"],
        copyright: json["copyright"] == null ? null : json["copyright"],
        results: json["results"] == null
            ? null
            : List<MembersListResult>.from(
                json["results"].map((x) => MembersListResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "copyright": copyright == null ? null : copyright,
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
        congress: json["congress"] == null ? null : json["congress"],
        chamber: json["chamber"] == null ? null : json["chamber"],
        numResults: json["num_results"] == null ? null : json["num_results"],
        offset: json["offset"] == null ? null : json["offset"],
        members: json["members"] == null
            ? null
            : List<ChamberMember>.from(
                json["members"].map((x) => ChamberMember.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "congress": congress == null ? null : congress,
        "chamber": chamber == null ? null : chamber,
        "num_results": numResults == null ? null : numResults,
        "offset": offset == null ? null : offset,
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
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        shortTitle: json["short_title"] == null ? null : json["short_title"],
        apiUri: json["api_uri"] == null ? null : json["api_uri"],
        firstName: json["first_name"] == null ? null : json["first_name"],
        middleName: json["middle_name"] == null ? null : json["middle_name"],
        lastName: json["last_name"] == null ? null : json["last_name"],
        suffix: json["suffix"] == null ? null : json["suffix"],
        dateOfBirth: json["date_of_birth"] == null
            ? null
            : DateTime.parse(json["date_of_birth"]),
        gender: json["gender"] == null ? null : json["gender"],
        party: json["party"] == null ? null : json["party"],
        leadershipRole:
            json["leadership_role"] == null ? null : json["leadership_role"],
        twitterAccount:
            json["twitter_account"] == null ? null : json["twitter_account"],
        facebookAccount:
            json["facebook_account"] == null ? null : json["facebook_account"],
        youtubeAccount:
            json["youtube_account"] == null ? null : json["youtube_account"],
        govtrackId: json["govtrack_id"] == null ? null : json["govtrack_id"],
        cspanId: json["cspan_id"] == null ? null : json["cspan_id"],
        votesmartId: json["votesmart_id"] == null ? null : json["votesmart_id"],
        icpsrId: json["icpsr_id"] == null ? null : json["icpsr_id"],
        crpId: json["crp_id"] == null ? null : json["crp_id"],
        googleEntityId:
            json["google_entity_id"] == null ? null : json["google_entity_id"],
        fecCandidateId:
            json["fec_candidate_id"] == null ? null : json["fec_candidate_id"],
        url: json["url"] == null ? null : json["url"],
        rssUrl: json["rss_url"] == null ? null : json["rss_url"],
        contactForm: json["contact_form"],
        inOffice: json["in_office"] == null ? null : json["in_office"],
        cookPvi: json["cook_pvi"] == null ? null : json["cook_pvi"],
        dwNominate:
            json["dw_nominate"] == null ? null : json["dw_nominate"].toDouble(),
        idealPoint: json["ideal_point"],
        seniority: json["seniority"] == null ? null : json["seniority"],
        nextElection:
            json["next_election"] == null ? null : json["next_election"],
        totalVotes: json["total_votes"] == null ? null : json["total_votes"],
        missedVotes: json["missed_votes"] == null ? null : json["missed_votes"],
        totalPresent:
            json["total_present"] == null ? null : json["total_present"],
        lastUpdated: json["last_updated"] == null ? null : json["last_updated"],
        ocdId: json["ocd_id"] == null ? null : json["ocd_id"],
        office: json["office"] == null ? 'Office not available' : json["office"],
        phone: json["phone"] == null ? 'Phone not available' : json["phone"],
        fax: json["fax"],
        state: json["state"] == null ? null : json["state"],
        district: json["district"] == null ? null : json["district"],
        atLarge: json["at_large"] == null ? null : json["at_large"],
        geoid: json["geoid"] == null ? null : json["geoid"],
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
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "short_title": shortTitle == null ? null : shortTitle,
        "api_uri": apiUri == null ? null : apiUri,
        "first_name": firstName == null ? null : firstName,
        "middle_name": middleName == null ? null : middleName,
        "last_name": lastName == null ? null : lastName,
        "suffix": suffix == null ? null : suffix,
        "date_of_birth": dateOfBirth == null
            ? null
            : "${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}",
        "gender": gender == null ? null : gender,
        "party": party == null ? null : party,
        "leadership_role": leadershipRole == null ? null : leadershipRole,
        "twitter_account": twitterAccount == null ? null : twitterAccount,
        "facebook_account": facebookAccount == null ? null : facebookAccount,
        "youtube_account": youtubeAccount == null ? null : youtubeAccount,
        "govtrack_id": govtrackId == null ? null : govtrackId,
        "cspan_id": cspanId == null ? null : cspanId,
        "votesmart_id": votesmartId == null ? null : votesmartId,
        "icpsr_id": icpsrId == null ? null : icpsrId,
        "crp_id": crpId == null ? null : crpId,
        "google_entity_id": googleEntityId == null ? null : googleEntityId,
        "fec_candidate_id": fecCandidateId == null ? null : fecCandidateId,
        "url": url == null ? null : url,
        "rss_url": rssUrl == null ? null : rssUrl,
        "contact_form": contactForm,
        "in_office": inOffice == null ? null : inOffice,
        "cook_pvi": cookPvi == null ? null : cookPvi,
        "dw_nominate": dwNominate == null ? null : dwNominate,
        "ideal_point": idealPoint,
        "seniority": seniority == null ? null : seniority,
        "next_election": nextElection == null ? null : nextElection,
        "total_votes": totalVotes == null ? null : totalVotes,
        "missed_votes": missedVotes == null ? null : missedVotes,
        "total_present": totalPresent == null ? null : totalPresent,
        "last_updated": lastUpdated == null ? null : lastUpdated,
        "ocd_id": ocdId == null ? null : ocdId,
        "office": office == null ? null : office,
        "phone": phone == null ? null : phone,
        "fax": fax,
        "state": state == null ? null : state,
        "district": district == null ? null : district,
        "at_large": atLarge == null ? null : atLarge,
        "geoid": geoid == null ? null : geoid,
        "missed_votes_pct": missedVotesPct == null ? null : missedVotesPct,
        "votes_with_party_pct":
            votesWithPartyPct == null ? null : votesWithPartyPct,
        "votes_against_party_pct":
            votesAgainstPartyPct == null ? null : votesAgainstPartyPct,
      };
}
