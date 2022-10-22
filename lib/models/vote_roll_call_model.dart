// To parse this JSON data, do
//
//     final rollCall = rollCallFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

RollCall rollCallFromJson(String str) => RollCall.fromJson(json.decode(str));

String rollCallToJson(RollCall data) => json.encode(data.toJson());

class RollCall {
  RollCall({
    @required this.status,
    @required this.copyright,
    @required this.results,
  });

  final String status;
  final String copyright;
  final Results results;

  factory RollCall.fromJson(Map<String, dynamic> json) => RollCall(
        status: json["status"] == null ? null : json["status"],
        copyright: json["copyright"] == null ? null : json["copyright"],
        results:
            json["results"] == null ? null : Results.fromJson(json["results"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "copyright": copyright == null ? null : copyright,
        "results": results == null ? null : results.toJson(),
      };
}

class Results {
  Results({
    @required this.rcVotes,
  });

  final RCVotes rcVotes;

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        rcVotes: json["votes"] == null ? null : RCVotes.fromJson(json["votes"]),
      );

  Map<String, dynamic> toJson() => {
        "votes": rcVotes == null ? null : rcVotes.toJson(),
      };
}

class RCVotes {
  RCVotes({
    @required this.vote,
    @required this.vacantSeats,
  });

  final RcVote vote;
  final List<dynamic> vacantSeats;

  factory RCVotes.fromJson(Map<String, dynamic> json) => RCVotes(
        vote: json["vote"] == null ? null : RcVote.fromJson(json["vote"]),
        vacantSeats: json["vacant_seats"] == null
            ? null
            : List<dynamic>.from(json["vacant_seats"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "vote": vote == null ? null : vote.toJson(),
        "vacant_seats": vacantSeats == null
            ? null
            : List<dynamic>.from(vacantSeats.map((x) => x)),
      };
}

class RcVote {
  RcVote({
    @required this.congress,
    @required this.session,
    @required this.chamber,
    @required this.rollCall,
    @required this.source,
    @required this.url,
    @required this.bill,
    @required this.question,
    @required this.description,
    @required this.voteType,
    @required this.date,
    @required this.time,
    @required this.result,
    @required this.tieBreaker,
    @required this.tieBreakerVote,
    @required this.documentNumber,
    @required this.documentTitle,
    @required this.democratic,
    @required this.republican,
    @required this.independent,
    @required this.total,
    @required this.positions,
  });

  final int congress;
  final int session;
  final String chamber;
  final int rollCall;
  final String source;
  final String url;
  final RcBill bill;
  final String question;
  final String description;
  final String voteType;
  final DateTime date;
  final String time;
  final String result;
  final String tieBreaker;
  final String tieBreakerVote;
  final String documentNumber;
  final String documentTitle;
  final Democratic democratic;
  final Democratic republican;
  final Democratic independent;
  final Democratic total;
  final List<RcPosition> positions;

  factory RcVote.fromJson(Map<String, dynamic> json) => RcVote(
        congress: json["congress"] == null ? null : json["congress"],
        session: json["session"] == null ? null : json["session"],
        chamber: json["chamber"] == null ? null : json["chamber"],
        rollCall: json["roll_call"] == null ? null : json["roll_call"],
        source: json["source"] == null ? null : json["source"],
        url: json["url"] == null ? null : json["url"],
        bill: json["bill"] == null ? null : RcBill.fromJson(json["bill"]),
        question: json["question"] == null ? null : json["question"],
        description: json["description"] == null ? null : json["description"],
        voteType: json["vote_type"] == null ? null : json["vote_type"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        time: json["time"] == null ? null : json["time"],
        result: json["result"] == null ? null : json["result"],
        tieBreaker: json["tie_breaker"] == null ? null : json["tie_breaker"],
        tieBreakerVote:
            json["tie_breaker_vote"] == null ? null : json["tie_breaker_vote"],
        documentNumber:
            json["document_number"] == null ? null : json["document_number"],
        documentTitle:
            json["document_title"] == null ? null : json["document_title"],
        democratic: json["democratic"] == null
            ? null
            : Democratic.fromJson(json["democratic"]),
        republican: json["republican"] == null
            ? null
            : Democratic.fromJson(json["republican"]),
        independent: json["independent"] == null
            ? null
            : Democratic.fromJson(json["independent"]),
        total:
            json["total"] == null ? null : Democratic.fromJson(json["total"]),
        positions: json["positions"] == null
            ? null
            : List<RcPosition>.from(
                json["positions"].map((x) => RcPosition.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "congress": congress == null ? null : congress,
        "session": session == null ? null : session,
        "chamber": chamber == null ? null : chamber,
        "roll_call": rollCall == null ? null : rollCall,
        "source": source == null ? null : source,
        "url": url == null ? null : url,
        "bill": bill == null ? null : bill.toJson(),
        "question": question == null ? null : question,
        "description": description == null ? null : description,
        "vote_type": voteType == null ? null : voteType,
        "date": date == null
            ? null
            : "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time == null ? null : time,
        "result": result == null ? null : result,
        "tie_breaker": tieBreaker == null ? null : tieBreaker,
        "tie_breaker_vote": tieBreakerVote == null ? null : tieBreakerVote,
        "document_number": documentNumber == null ? null : documentNumber,
        "document_title": documentTitle == null ? null : documentTitle,
        "democratic": democratic == null ? null : democratic.toJson(),
        "republican": republican == null ? null : republican.toJson(),
        "independent": independent == null ? null : independent.toJson(),
        "total": total == null ? null : total.toJson(),
        "positions": positions == null
            ? null
            : List<dynamic>.from(positions.map((x) => x.toJson())),
      };
}

class RcBill {
  RcBill({
    @required this.billId,
    @required this.number,
    @required this.apiUri,
    @required this.title,
    @required this.latestAction,
  });

  final String billId;
  final String number;
  final String apiUri;
  final String title;
  final String latestAction;

  factory RcBill.fromJson(Map<String, dynamic> json) => RcBill(
        billId: json["bill_id"] == null ? 'noBillId' : json["bill_id"],
        number: json["number"] == null ? null : json["number"],
        apiUri: json["api_uri"] == null ? null : json["api_uri"],
        title: json["title"] == null ? null : json["title"],
        latestAction:
            json["latest_action"] == null ? null : json["latest_action"],
      );

  Map<String, dynamic> toJson() => {
        "bill_id": billId == null ? 'noBillId' : billId,
        "number": number == null ? null : number,
        "api_uri": apiUri == null ? null : apiUri,
        "title": title == null ? null : title,
        "latest_action": latestAction == null ? null : latestAction,
      };
}

class Democratic {
  Democratic({
    @required this.yes,
    @required this.no,
    @required this.present,
    @required this.notVoting,
    @required this.majorityPosition,
  });

  final int yes;
  final int no;
  final int present;
  final int notVoting;
  final String majorityPosition;

  factory Democratic.fromJson(Map<String, dynamic> json) => Democratic(
        yes: json["yes"] == null ? null : json["yes"],
        no: json["no"] == null ? null : json["no"],
        present: json["present"] == null ? null : json["present"],
        notVoting: json["not_voting"] == null ? null : json["not_voting"],
        majorityPosition: json["majority_position"] == null
            ? null
            : json["majority_position"],
      );

  Map<String, dynamic> toJson() => {
        "yes": yes == null ? null : yes,
        "no": no == null ? null : no,
        "present": present == null ? null : present,
        "not_voting": notVoting == null ? null : notVoting,
        "majority_position": majorityPosition == null ? null : majorityPosition,
      };
}

class RcPosition {
  RcPosition({
    @required this.memberId,
    @required this.name,
    @required this.party,
    @required this.state,
    @required this.votePosition,
    @required this.dwNominate,
  });

  final String memberId;
  final String name;
  final String party;
  final String state;
  final String votePosition;
  final double dwNominate;

  factory RcPosition.fromJson(Map<String, dynamic> json) => RcPosition(
        memberId: json["member_id"] == null ? null : json["member_id"],
        name: json["name"] == null ? null : json["name"],
        party: json["party"] == null ? null : json["party"],
        state: json["state"] == null ? null : json["state"],
        votePosition:
            json["vote_position"] == null ? null : json["vote_position"],
        dwNominate:
            json["dw_nominate"] == null ? null : json["dw_nominate"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "member_id": memberId == null ? null : memberId,
        "name": name == null ? null : name,
        "party": party == null ? null : party,
        "state": state == null ? null : state,
        "vote_position": votePosition == null ? null : votePosition,
        "dw_nominate": dwNominate == null ? null : dwNominate,
      };
}
