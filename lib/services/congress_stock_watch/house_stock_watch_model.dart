// To parse this JSON data, do
//
//     final houseStockWatch = houseStockWatchFromJson(jsonString);

import 'dart:convert';

List<HouseStockWatch> houseStockWatchFromJson(String str) =>
    List<HouseStockWatch>.from(
        json.decode(str).map((x) => HouseStockWatch.fromJson(x)));

String houseStockWatchToJson(List<HouseStockWatch> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HouseStockWatch {
  HouseStockWatch({
    this.disclosureYear,
    this.disclosureDate,
    this.transactionDate,
    this.owner,
    this.ticker,
    this.assetDescription,
    this.type,
    this.amount,
    this.representative,
    this.district,
    this.ptrLink,
    this.capGainsOver200Usd,
  });

  final int disclosureYear;
  final DateTime disclosureDate;
  final DateTime transactionDate;
  final String owner;
  final String ticker;
  final String assetDescription;
  final String type;
  final String amount;
  final String representative;
  final String district;
  final String ptrLink;
  final bool capGainsOver200Usd;

  factory HouseStockWatch.fromJson(Map<String, dynamic> json) =>
      HouseStockWatch(
        disclosureYear:
            json["disclosure_year"] == null ? null : json["disclosure_year"],
        disclosureDate: json["disclosure_date"] == null
            ? null
            : DateTime.parse(
                "${json["disclosure_date"].toString().split('/')[2].padLeft(4, '0')}-${json["disclosure_date"].toString().split('/')[0].padLeft(2, '0')}-${json["disclosure_date"].toString().split('/')[1].padLeft(2, '0')}"),
        transactionDate: json["transaction_date"] == null
            ? null
            : DateTime.parse(json["transaction_date"]),
        owner: json["owner"] == null ? null : json["owner"],
        ticker: json["ticker"] == null ? null : json["ticker"],
        assetDescription: json["asset_description"] == null
            ? null
            : json["asset_description"],
        type: json["type"] == null ? null : json["type"],
        amount: json["amount"] == null ? null : json["amount"],
        representative:
            json["representative"] == null ? null : json["representative"],
        district: json["district"] == null ? null : json["district"],
        ptrLink: json["ptr_link"] == null ? null : json["ptr_link"],
        capGainsOver200Usd: json["cap_gains_over_200_usd"] == null
            ? null
            : json["cap_gains_over_200_usd"],
      );

  Map<String, dynamic> toJson() => {
        "disclosure_year": disclosureYear == null ? null : disclosureYear,
        "disclosure_date": disclosureDate == null
            ? null
            : "${disclosureDate.month.toString().padLeft(2, '0')}/${disclosureDate.day.toString().padLeft(2, '0')}/${disclosureDate.year.toString().padLeft(4, '0')}",
        "transaction_date": transactionDate == null
            ? null
            : "${transactionDate.year.toString().padLeft(4, '0')}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}",
        "owner": owner == null ? null : owner,
        "ticker": ticker == null ? null : ticker,
        "asset_description": assetDescription == null ? null : assetDescription,
        "type": type == null ? null : type,
        "amount": amount == null ? null : amount,
        "representative": representative == null ? null : representative,
        "district": district == null ? null : district,
        "ptr_link": ptrLink == null ? null : ptrLink,
        "cap_gains_over_200_usd":
            capGainsOver200Usd == null ? null : capGainsOver200Usd,
      };
}
