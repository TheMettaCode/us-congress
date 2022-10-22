// To parse this JSON data, do
//
//     final senateStockWatch = senateStockWatchFromJson(jsonString);

import 'dart:convert';

List<SenateStockWatch> senateStockWatchFromJson(String str) =>
    List<SenateStockWatch>.from(
        json.decode(str).map((x) => SenateStockWatch.fromJson(x)));

String senateStockWatchToJson(List<SenateStockWatch> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SenateStockWatch {
  SenateStockWatch({
    this.transactionDate,
    this.owner,
    this.ticker,
    this.assetDescription,
    this.assetType,
    this.type,
    this.amount,
    this.comment,
    this.senator,
    this.ptrLink,
    this.disclosureDate,
  });

  final DateTime transactionDate;
  final String owner;
  final String ticker;
  final String assetDescription;
  final String assetType;
  final String type;
  final String amount;
  final String comment;
  final String senator;
  final String ptrLink;
  final DateTime disclosureDate;

  factory SenateStockWatch.fromJson(Map<String, dynamic> json) =>
      SenateStockWatch(
        transactionDate: json["transaction_date"] == null
            ? null
            : DateTime.parse(
                "${json["transaction_date"].toString().split('/')[2].padLeft(4, '0')}-${json["transaction_date"].toString().split('/')[0].padLeft(2, '0')}-${json["transaction_date"].toString().split('/')[1].padLeft(2, '0')}"),
        owner: json["owner"] == null ? null : json["owner"],
        ticker: json["ticker"] == null ? null : json["ticker"],
        assetDescription: json["asset_description"] == null
            ? null
            : json["asset_description"],
        assetType: json["asset_type"] == null ? null : json["asset_type"],
        type: json["type"] == null ? null : json["type"],
        amount: json["amount"] == null ? null : json["amount"],
        comment: json["comment"] == null ? null : json["comment"],
        senator: json["senator"] == null ? null : json["senator"],
        ptrLink: json["ptr_link"] == null ? null : json["ptr_link"],
        disclosureDate: json["disclosure_date"] == null
            ? null
            : DateTime.parse(
                "${json["disclosure_date"].toString().split('/')[2].padLeft(4, '0')}-${json["disclosure_date"].toString().split('/')[0].padLeft(2, '0')}-${json["disclosure_date"].toString().split('/')[1].padLeft(2, '0')}"),
      );

  Map<String, dynamic> toJson() => {
        "transaction_date": transactionDate == null
            ? null
            : "${transactionDate.month.toString().padLeft(2, '0')}/${transactionDate.day.toString().padLeft(2, '0')}/${transactionDate.year.toString().padLeft(4, '0')}",
        "owner": owner == null ? null : owner,
        "ticker": ticker == null ? null : ticker,
        "asset_description": assetDescription == null ? null : assetDescription,
        "asset_type": assetType == null ? null : assetType,
        "type": type == null ? null : type,
        "amount": amount == null ? null : amount,
        "comment": comment == null ? null : comment,
        "senator": senator == null ? null : senator,
        "ptr_link": ptrLink == null ? null : ptrLink,
        "disclosure_date": disclosureDate == null
            ? null
            : "${disclosureDate.month.toString().padLeft(2, '0')}/${disclosureDate.day.toString().padLeft(2, '0')}/${disclosureDate.year.toString().padLeft(4, '0')}",
      };
}
