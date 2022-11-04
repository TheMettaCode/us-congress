// To parse this JSON data, do
//
//     final memberOfficeExpenses = memberOfficeExpensesFromJson(jsonString);

import 'dart:convert';

MemberOfficeExpenses memberOfficeExpensesFromJson(String str) =>
    MemberOfficeExpenses.fromJson(json.decode(str));

String memberOfficeExpensesToJson(MemberOfficeExpenses data) =>
    json.encode(data.toJson());

class MemberOfficeExpenses {
  MemberOfficeExpenses({
    this.status,
    this.copyright,
    this.memberId,
    this.name,
    this.memberUri,
    this.year,
    this.quarter,
    this.numResults,
    this.results,
  });

  final String status;
  final String copyright;
  final String memberId;
  final String name;
  final String memberUri;
  final int year;
  final int quarter;
  final int numResults;
  final List<MemberExpensesResult> results;

  factory MemberOfficeExpenses.fromJson(Map<String, dynamic> json) =>
      MemberOfficeExpenses(
        status: json["status"],
        copyright: json["copyright"],
        memberId: json["member_id"],
        name: json["name"],
        memberUri: json["member_uri"],
        year: json["year"],
        quarter: json["quarter"],
        numResults: json["num_results"],
        results: json["results"] == null
            ? null
            : List<MemberExpensesResult>.from(
                json["results"].map((x) => MemberExpensesResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "copyright": copyright,
        "member_id": memberId,
        "name": name,
        "member_uri": memberUri,
        "year": year,
        "quarter": quarter,
        "num_results": numResults,
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class MemberExpensesResult {
  MemberExpensesResult({
    this.category,
    this.categorySlug,
    this.amount,
    this.yearToDate,
    this.changeFromPreviousQuarter,
  });

  final String category;
  final String categorySlug;
  final double amount;
  final double yearToDate;
  final double changeFromPreviousQuarter;

  factory MemberExpensesResult.fromJson(Map<String, dynamic> json) =>
      MemberExpensesResult(
        category: json["category"],
        categorySlug: json["category_slug"],
        amount: json["amount"] == null ? null : json["amount"].toDouble(),
        yearToDate: json["year_to_date"] == null
            ? null
            : json["year_to_date"].toDouble(),
        changeFromPreviousQuarter: json["change_from_previous_quarter"] == null
            ? null
            : json["change_from_previous_quarter"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "category_slug": categorySlug,
        "amount": amount,
        "year_to_date": yearToDate,
        "change_from_previous_quarter": changeFromPreviousQuarter,
      };
}
