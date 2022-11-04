// To parse this JSON data, do
//
//     final totalOfficeExpenses = totalOfficeExpensesFromJson(jsonString);

import 'dart:convert';

TotalOfficeExpenses totalOfficeExpensesFromJson(String str) =>
    TotalOfficeExpenses.fromJson(json.decode(str));

String totalOfficeExpensesToJson(TotalOfficeExpenses data) =>
    json.encode(data.toJson());

class TotalOfficeExpenses {
  TotalOfficeExpenses({
    this.status,
    this.copyright,
    this.category,
    this.numResults,
    this.offset,
    this.results,
  });

  final String status;
  final String copyright;
  final String category;
  final int numResults;
  final int offset;
  final List<TotalExpensesResult> results;

  factory TotalOfficeExpenses.fromJson(Map<String, dynamic> json) =>
      TotalOfficeExpenses(
        status: json["status"],
        copyright: json["copyright"],
        category: json["category"],
        numResults: json["num_results"],
        offset: json["offset"],
        results: json["results"] == null
            ? null
            : List<TotalExpensesResult>.from(
                json["results"].map((x) => TotalExpensesResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "category": category,
        "num_results": numResults,
        "offset": offset,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class TotalExpensesResult {
  TotalExpensesResult({
    this.year,
    this.quarter,
    this.memberId,
    this.name,
    this.memberUri,
    this.amount,
    this.yearToDate,
    this.changeFromPreviousQuarter,
  });

  final int year;
  final int quarter;
  final String memberId;
  final String name;
  final String memberUri;
  final double amount;
  final double yearToDate;
  final double changeFromPreviousQuarter;

  factory TotalExpensesResult.fromJson(Map<String, dynamic> json) =>
      TotalExpensesResult(
        year: json["year"],
        quarter: json["quarter"],
        memberId: json["member_id"],
        name: json["name"],
        memberUri: json["member_uri"],
        amount: json["amount"] == null ? null : json["amount"].toDouble(),
        yearToDate: json["year_to_date"] == null
            ? null
            : json["year_to_date"].toDouble(),
        changeFromPreviousQuarter: json["change_from_previous_quarter"] == null
            ? null
            : json["change_from_previous_quarter"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "year": year,
        "quarter": quarter,
        "member_id": memberId,
        "name": name,
        "member_uri": memberUri,
        "amount": amount,
        "year_to_date": yearToDate,
        "change_from_previous_quarter": changeFromPreviousQuarter,
      };
}
