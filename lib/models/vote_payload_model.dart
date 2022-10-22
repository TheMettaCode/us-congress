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
        offset: json["offset"] == null ? null : json["offset"],
        numResults: json["num_results"] == null ? null : json["num_results"],
        votes: json["votes"] == null
            ? null
            : List<Vote>.from(json["votes"].map((x) => Vote.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "chamber": chamber == null ? null : chamberValues.reverse[chamber],
        "offset": offset == null ? null : offset,
        "num_results": numResults == null ? null : numResults,
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
        congress: json["congress"] == null ? 'No Data' : json["congress"],
        chamber: json["chamber"] == null
            ? 'No Chamber'
            : chamberValues.map[json["chamber"]],
        session: json["session"] == null ? 'No Session' : json["session"],
        rollCall:
            json["roll_call"] == null ? 'No Roll Call' : json["roll_call"],
        source: json["source"] == null ? 'No Source' : json["source"],
        url: json["url"] == null ? 'No URL' : json["url"],
        voteUri: json["vote_uri"] == null ? 'No URI' : json["vote_uri"],
        bill:
            json["bill"] == null ? 'No Bill Data' : Bill.fromJson(json["bill"]),
        amendment: json["amendment"] == null
            ? 'No Amendment Data'
            : Amendment.fromJson(json["amendment"]),
        question: json["question"] == null ? 'No Question' : json["question"],
        description: json["description"] == null
            ? 'No Description'
            : json["description"],
        voteType: json["vote_type"] == null
            ? 'No Type Data'
            : voteTypeValues.map[json["vote_type"]],
        date: json["date"] == null ? 'No Date' : DateTime.parse(json["date"]),
        time: json["time"] == null ? 'No Time' : json["time"],
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
        "congress": congress == null ? 'No Data' : congress,
        "chamber":
            chamber == null ? 'No Chamber' : chamberValues.reverse[chamber],
        "session": session == null ? 'No Session' : session,
        "roll_call": rollCall == null ? 'No Roll Call' : rollCall,
        "source": source == null ? 'No Source' : source,
        "url": url == null ? 'No URL' : url,
        "vote_uri": voteUri == null ? 'No URI' : voteUri,
        "bill": bill == null ? 'No Data' : bill.toJson(),
        "amendment":
            amendment == null ? 'No Amendment Data' : amendment.toJson(),
        "question": question == null ? 'No Question' : question,
        "description": description == null ? 'No Description' : description,
        "vote_type": voteType == null
            ? 'No Type Data'
            : voteTypeValues.reverse[voteType],
        "date": date == null
            ? 'No Date'
            : "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time == null ? 'No Time' : time,
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
        number: json["number"] == null ? 'Not Available' : json["number"],
        billId: json["bill_id"] == null ? 'noBillId' : json["bill_id"],
        apiUri: json["api_uri"] == null ? 'No URI' : json["api_uri"],
        title: json["title"] == null
            ? 'No additional information available.'
            : json["title"],
        latestAction: json["latest_action"] == null
            ? 'No recent actions listed'
            : json["latest_action"],
      );

  Map<String, dynamic> toJson() => {
        "number": number == null ? 'No Bill No.' : number,
        "bill_id": billId == null ? 'noBillId' : billId,
        "api_uri": apiUri == null ? 'No URI' : apiUri,
        "title": title == null ? 'No Title' : title,
        "latest_action": latestAction == null ? 'No Actions' : latestAction,
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
        yes: json["yes"] == null ? null : json["yes"],
        no: json["no"] == null ? null : json["no"],
        present: json["present"] == null ? null : json["present"],
        notVoting: json["not_voting"] == null ? null : json["not_voting"],
        majorityPosition: json["majority_position"] == null
            ? null
            : majorityPositionValues.map[json["majority_position"]],
      );

  Map<String, dynamic> toJson() => {
        "yes": yes == null ? null : yes,
        "no": no == null ? null : no,
        "present": present == null ? null : present,
        "not_voting": notVoting == null ? null : notVoting,
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
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
