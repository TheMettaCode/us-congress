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
        status: json["status"] == null ? null : json["status"],
        copyright: json["copyright"] == null ? null : json["copyright"],
        memberId: json["member_id"] == null ? null : json["member_id"],
        name: json["name"] == null ? null : json["name"],
        memberUri: json["member_uri"] == null ? null : json["member_uri"],
        year: json["year"] == null ? null : json["year"],
        quarter: json["quarter"] == null ? null : json["quarter"],
        numResults: json["num_results"] == null ? null : json["num_results"],
        results: json["results"] == null
            ? null
            : List<MemberExpensesResult>.from(
                json["results"].map((x) => MemberExpensesResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "copyright": copyright == null ? null : copyright,
        "member_id": memberId == null ? null : memberId,
        "name": name == null ? null : name,
        "member_uri": memberUri == null ? null : memberUri,
        "year": year == null ? null : year,
        "quarter": quarter == null ? null : quarter,
        "num_results": numResults == null ? null : numResults,
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
        category: json["category"] == null ? null : json["category"],
        categorySlug:
            json["category_slug"] == null ? null : json["category_slug"],
        amount: json["amount"] == null ? null : json["amount"].toDouble(),
        yearToDate: json["year_to_date"] == null
            ? null
            : json["year_to_date"].toDouble(),
        changeFromPreviousQuarter: json["change_from_previous_quarter"] == null
            ? null
            : json["change_from_previous_quarter"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "category": category == null ? null : category,
        "category_slug": categorySlug == null ? null : categorySlug,
        "amount": amount == null ? null : amount,
        "year_to_date": yearToDate == null ? null : yearToDate,
        "change_from_previous_quarter": changeFromPreviousQuarter == null
            ? null
            : changeFromPreviousQuarter,
      };
}
