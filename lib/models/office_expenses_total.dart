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
        status: json["status"] == null ? null : json["status"],
        copyright: json["copyright"] == null ? null : json["copyright"],
        category: json["category"] == null ? null : json["category"],
        numResults: json["num_results"] == null ? null : json["num_results"],
        offset: json["offset"] == null ? null : json["offset"],
        results: json["results"] == null
            ? null
            : List<TotalExpensesResult>.from(
                json["results"].map((x) => TotalExpensesResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "copyright": copyright == null ? null : copyright,
        "category": category == null ? null : category,
        "num_results": numResults == null ? null : numResults,
        "offset": offset == null ? null : offset,
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
        year: json["year"] == null ? null : json["year"],
        quarter: json["quarter"] == null ? null : json["quarter"],
        memberId: json["member_id"] == null ? null : json["member_id"],
        name: json["name"] == null ? null : json["name"],
        memberUri: json["member_uri"] == null ? null : json["member_uri"],
        amount: json["amount"] == null ? null : json["amount"].toDouble(),
        yearToDate: json["year_to_date"] == null
            ? null
            : json["year_to_date"].toDouble(),
        changeFromPreviousQuarter: json["change_from_previous_quarter"] == null
            ? null
            : json["change_from_previous_quarter"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "year": year == null ? null : year,
        "quarter": quarter == null ? null : quarter,
        "member_id": memberId == null ? null : memberId,
        "name": name == null ? null : name,
        "member_uri": memberUri == null ? null : memberUri,
        "amount": amount == null ? null : amount,
        "year_to_date": yearToDate == null ? null : yearToDate,
        "change_from_previous_quarter": changeFromPreviousQuarter == null
            ? null
            : changeFromPreviousQuarter,
      };
}
