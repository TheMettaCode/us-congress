// To parse this JSON data, do
//
//     final payload = payloadFromJson(jsonString);

import 'dart:convert';

Payload payloadFromJson(String str) => Payload.fromJson(json.decode(str));

String payloadToJson(Payload data) => json.encode(data.toJson());

class Payload {
  Payload({
    this.status,
    this.copyright,
    this.results,
  });

  final String status;
  final String copyright;
  final Results results;

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
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
    this.chamber,
    this.offset,
    this.numResults,
    this.votes,
  });

  final Chamber chamber;
  final int offset;
  final int numResults;
  final List<Vote> votes;

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        chamber:
            json["chamber"] == null ? null : chamberValues.map[json["chamber"]],
        offset: json["offset"],
        numResults: json["num_results"],
        votes: json["votes"] == null
            ? null
            : List<Vote>.from(json["votes"].map((x) => Vote.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "chamber": chamber == null ? null : chamberValues.reverse[chamber],
        "offset": offset,
        "num_results": numResults,
        "votes": votes == null
            ? null
            : List<dynamic>.from(votes.map((x) => x.toJson())),
      };
}

enum Chamber { HOUSE }

final chamberValues = EnumValues({"House": Chamber.HOUSE});

class Vote {
  Vote({
    this.congress,
    this.chamber,
    this.session,
    this.rollCall,
    this.source,
    this.url,
    this.voteUri,
    this.bill,
    this.amendment,
    this.question,
    this.description,
    this.voteType,
    this.date,
    this.time,
    this.result,
    this.democratic,
    this.republican,
    this.independent,
    this.total,
  });

  final int congress;
  final Chamber chamber;
  final int session;
  final int rollCall;
  final String source;
  final String url;
  final String voteUri;
  final Bill bill;
  final Amendment amendment;
  final String question;
  final String description;
  final VoteType voteType;
  final DateTime date;
  final String time;
  final Result result;
  final Democratic democratic;
  final Democratic republican;
  final Democratic independent;
  final Democratic total;

  factory Vote.fromJson(Map<String, dynamic> json) => Vote(
        congress: json["congress"] ?? 'No Data',
        chamber: json["chamber"] == null
            ? 'No Chamber'
            : chamberValues.map[json["chamber"]],
        session: json["session"] ?? 'No Session',
        rollCall: json["roll_call"] ?? 'No Roll Call',
        source: json["source"] ?? 'No Source',
        url: json["url"] ?? 'No URL',
        voteUri: json["vote_uri"] ?? 'No URI',
        bill:
            json["bill"] == null ? 'No Bill Data' : Bill.fromJson(json["bill"]),
        amendment: json["amendment"] == null
            ? 'No Amendment Data'
            : Amendment.fromJson(json["amendment"]),
        question: json["question"] ?? 'No Question',
        description: json["description"] ?? 'No Description',
        voteType: json["vote_type"] == null
            ? 'No Type Data'
            : voteTypeValues.map[json["vote_type"]],
        date: json["date"] == null ? 'No Date' : DateTime.parse(json["date"]),
        time: json["time"] ?? 'No Time',
        result: json["result"] == null
            ? 'No Results'
            : resultValues.map[json["result"]],
        democratic: json["democratic"] == null
            ? 'No Data'
            : Democratic.fromJson(json["democratic"]),
        republican: json["republican"] == null
            ? 'No Data'
            : Democratic.fromJson(json["republican"]),
        independent: json["independent"] == null
            ? 'No Data'
            : Democratic.fromJson(json["independent"]),
        total: json["total"] == null
            ? 'No Total'
            : Democratic.fromJson(json["total"]),
      );

  Map<String, dynamic> toJson() => {
        "congress": congress ?? 'No Data',
        "chamber":
            chamber == null ? 'No Chamber' : chamberValues.reverse[chamber],
        "session": session ?? 'No Session',
        "roll_call": rollCall ?? 'No Roll Call',
        "source": source ?? 'No Source',
        "url": url ?? 'No URL',
        "vote_uri": voteUri ?? 'No URI',
        "bill": bill == null ? 'No Data' : bill.toJson(),
        "amendment":
            amendment == null ? 'No Amendment Data' : amendment.toJson(),
        "question": question ?? 'No Question',
        "description": description ?? 'No Description',
        "vote_type": voteType == null
            ? 'No Type Data'
            : voteTypeValues.reverse[voteType],
        "date": date == null
            ? 'No Date'
            : "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time ?? 'No Time',
        "result": result == null ? 'No Results' : resultValues.reverse[result],
        "democratic": democratic == null ? 'No Data' : democratic.toJson(),
        "republican": republican == null ? 'No Data' : republican.toJson(),
        "independent": independent == null ? 'No Data' : independent.toJson(),
        "total": total == null ? 'No Total' : total.toJson(),
      };
}

class Amendment {
  Amendment();

  factory Amendment.fromJson(Map<String, dynamic> json) => Amendment();

  Map<String, dynamic> toJson() => {};
}

class Bill {
  Bill({
    this.number,
    this.billId,
    this.apiUri,
    this.title,
    this.latestAction,
  });

  final String number;
  final String billId;
  final String apiUri;
  final String title;
  final String latestAction;

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        number: json["number"] ?? 'Not Available',
        billId: json["bill_id"] ?? 'noBillId',
        apiUri: json["api_uri"] ?? 'No URI',
        title: json["title"] ?? 'No additional information available.',
        latestAction: json["latest_action"] ?? 'No recent actions listed',
      );

  Map<String, dynamic> toJson() => {
        "number": number ?? 'No Bill No.',
        "bill_id": billId ?? 'noBillId',
        "api_uri": apiUri ?? 'No URI',
        "title": title ?? 'No Title',
        "latest_action": latestAction ?? 'No Actions',
      };
}

class Democratic {
  Democratic({
    this.yes,
    this.no,
    this.present,
    this.notVoting,
    this.majorityPosition,
  });

  final int yes;
  final int no;
  final int present;
  final int notVoting;
  final MajorityPosition majorityPosition;

  factory Democratic.fromJson(Map<String, dynamic> json) => Democratic(
        yes: json["yes"],
        no: json["no"],
        present: json["present"],
        notVoting: json["not_voting"],
        majorityPosition: json["majority_position"] == null
            ? null
            : majorityPositionValues.map[json["majority_position"]],
      );

  Map<String, dynamic> toJson() => {
        "yes": yes,
        "no": no,
        "present": present,
        "not_voting": notVoting,
        "majority_position": majorityPosition == null
            ? null
            : majorityPositionValues.reverse[majorityPosition],
      };
}

enum MajorityPosition { YES, NO }

final majorityPositionValues =
    EnumValues({"No": MajorityPosition.NO, "Yes": MajorityPosition.YES});

enum Result { PASSED, FAILED, AGREED_TO }

final resultValues = EnumValues({
  "Agreed to": Result.AGREED_TO,
  "Failed": Result.FAILED,
  "Passed": Result.PASSED
});

enum VoteType { YEA_AND_NAY, RECORDED_VOTE }

final voteTypeValues = EnumValues({
  "RECORDED VOTE": VoteType.RECORDED_VOTE,
  "YEA-AND-NAY": VoteType.YEA_AND_NAY
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
