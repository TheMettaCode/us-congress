// To parse this JSON data, do
//
//     final marketActivity = marketActivityFromJson(jsonString);

import 'dart:convert';

List<MarketActivity> marketActivityFromJson(String str) =>
    List<MarketActivity>.from(
        json.decode(str).map((x) => MarketActivity.fromJson(x)));

String marketActivityToJson(List<MarketActivity> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MarketActivity {
  MarketActivity(
      {this.tickerName,
      this.tickerDescription,
      this.tradeType,
      this.dollarAmount,
      this.memberTitle,
      this.memberFirstName,
      this.memberFullName,
      this.tradeExecutionDate,
      this.tradeDisclosureDate,
      this.memberChamber,
      this.tradeOwner,
      this.memberId});

  final String tickerName;
  final String tickerDescription;
  final String tradeType;
  final String dollarAmount;
  final String memberTitle;
  final String memberFirstName;
  final String memberFullName;
  final DateTime tradeExecutionDate;
  final DateTime tradeDisclosureDate;
  final String memberChamber;
  final String tradeOwner;
  final String memberId;

  factory MarketActivity.fromJson(Map<String, dynamic> json) => MarketActivity(
        tickerName: json["ticker_name"],
        tickerDescription: json["ticker_description"],
        tradeType: json["trade_type"],
        dollarAmount: json["dollar_amount"],
        memberTitle: json["member_title"],
        memberFirstName: json["member_first_name"],
        memberFullName: json["member_full_name"],
        tradeExecutionDate: DateTime.parse(json["trade_execution_date"]),
        tradeDisclosureDate: DateTime.parse(json["trade_disclosure_date"]),
        memberChamber: json["member_chamber"],
        tradeOwner: json["trade_owner"],
        memberId: json["member_id"],
      );

  Map<String, dynamic> toJson() => {
        "ticker_name": tickerName,
        "ticker_description": tickerDescription,
        "trade_type": tradeType,
        "dollar_amount": dollarAmount,
        "member_title": memberTitle,
        "member_first_name": memberFirstName,
        "member_full_name": memberFullName,
        "trade_execution_date": tradeExecutionDate.toString(),
        "trade_disclosure_date": tradeDisclosureDate.toString(),
        "member_chamber": memberChamber,
        "trade_owner": tradeOwner,
        "member_id": memberId,
      };
}
