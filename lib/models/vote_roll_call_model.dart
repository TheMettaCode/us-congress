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
        status: json["status"],
        copyright: json["copyright"],
        results:
            json["results"] == null ? null : Results.fromJson(json["results"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
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
        congress: json["congress"],
        session: json["session"],
        chamber: json["chamber"],
        rollCall: json["roll_call"],
        source: json["source"],
        url: json["url"],
        bill: json["bill"] == null ? null : RcBill.fromJson(json["bill"]),
        question: json["question"],
        description: json["description"],
        voteType: json["vote_type"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        time: json["time"],
        result: json["result"],
        tieBreaker: json["tie_breaker"],
        tieBreakerVote: json["tie_breaker_vote"],
        documentNumber: json["document_number"],
        documentTitle: json["document_title"],
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
        "congress": congress,
        "session": session,
        "chamber": chamber,
        "roll_call": rollCall,
        "source": source,
        "url": url,
        "bill": bill == null ? null : bill.toJson(),
        "question": question,
        "description": description,
        "vote_type": voteType,
        "date": date == null
            ? null
            : "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time,
        "result": result,
        "tie_breaker": tieBreaker,
        "tie_breaker_vote": tieBreakerVote,
        "document_number": documentNumber,
        "document_title": documentTitle,
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
        billId: json["bill_id"] ?? 'noBillId',
        number: json["number"],
        apiUri: json["api_uri"],
        title: json["title"],
        latestAction: json["latest_action"],
      );

  Map<String, dynamic> toJson() => {
        "bill_id": billId ?? 'noBillId',
        "number": number,
        "api_uri": apiUri,
        "title": title,
        "latest_action": latestAction,
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
        yes: json["yes"],
        no: json["no"],
        present: json["present"],
        notVoting: json["not_voting"],
        majorityPosition: json["majority_position"],
      );

  Map<String, dynamic> toJson() => {
        "yes": yes,
        "no": no,
        "present": present,
        "not_voting": notVoting,
        "majority_position": majorityPosition,
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
        memberId: json["member_id"],
        name: json["name"],
        party: json["party"],
        state: json["state"],
        votePosition: json["vote_position"],
        dwNominate:
            json["dw_nominate"] == null ? null : json["dw_nominate"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "member_id": memberId,
        "name": name,
        "party": party,
        "state": state,
        "vote_position": votePosition,
        "dw_nominate": dwNominate,
      };
}
