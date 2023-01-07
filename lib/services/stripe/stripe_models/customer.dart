// To parse this JSON data, do
//
//     final stripeCustomer = stripeCustomerFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

StripeCustomer stripeCustomerFromJson(String str) =>
    StripeCustomer.fromJson(json.decode(str));

String stripeCustomerToJson(StripeCustomer data) => json.encode(data.toJson());

class StripeCustomer {
  StripeCustomer({
    @required this.id,
    @required this.object,
    @required this.address,
    @required this.balance,
    @required this.created,
    @required this.currency,
    @required this.defaultSource,
    @required this.delinquent,
    @required this.description,
    @required this.discount,
    @required this.email,
    @required this.invoicePrefix,
    @required this.invoiceSettings,
    @required this.livemode,
    @required this.metadata,
    @required this.name,
    @required this.nextInvoiceSequence,
    @required this.phone,
    @required this.preferredLocales,
    @required this.shipping,
    // @required this.subscriptions,
    @required this.taxExempt,
    @required this.testClock,
  });

  final String id;
  final String object;
  // final String address;
  final CustomerAddress address;
  final int balance;
  final int created;
  final String currency;
  final String defaultSource;
  final bool delinquent;
  final String description;
  final dynamic discount;
  final String email;
  final String invoicePrefix;
  final CustomerInvoiceSettings invoiceSettings;
  final bool livemode;
  final CustomerMetadata metadata;
  final String name;
  final int nextInvoiceSequence;
  final String phone;
  final List<dynamic> preferredLocales;
  final dynamic shipping;
  // final CustomerSubscriptions subscriptions;
  final String taxExempt;
  final dynamic testClock;

  factory StripeCustomer.fromJson(Map<String, dynamic> json) => StripeCustomer(
        id: json["id"],
        object: json["object"],
        // address: json["address"],
        address: json["address"] == null
            ? null
            : CustomerAddress.fromJson(json["address"]),
        balance: json["balance"],
        created: json["created"],
        currency: json["currency"],
        defaultSource: json["default_source"],
        delinquent: json["delinquent"],
        description: json["description"],
        discount: json["discount"],
        email: json["email"],
        invoicePrefix: json["invoice_prefix"],
        invoiceSettings:
            CustomerInvoiceSettings.fromJson(json["invoice_settings"]),
        livemode: json["livemode"],
        metadata: CustomerMetadata.fromJson(json["metadata"]),
        name: json["name"],
        nextInvoiceSequence: json["next_invoice_sequence"],
        phone: json["phone"],
        preferredLocales:
            List<dynamic>.from(json["preferred_locales"].map((x) => x)),
        shipping: json["shipping"],
        // subscriptions: CustomerSubscriptions.fromJson(json["subscriptions"]),
        taxExempt: json["tax_exempt"],
        testClock: json["test_clock"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        // "address": address,
        "address": address == null ? null : address.toJson(),
        "balance": balance,
        "created": created,
        "currency": currency,
        "default_source": defaultSource,
        "delinquent": delinquent,
        "description": description,
        "discount": discount,
        "email": email,
        "invoice_prefix": invoicePrefix,
        "invoice_settings": invoiceSettings.toJson(),
        "livemode": livemode,
        "metadata": metadata.toJson(),
        "name": name,
        "next_invoice_sequence": nextInvoiceSequence,
        "phone": phone,
        "preferred_locales": List<dynamic>.from(preferredLocales.map((x) => x)),
        "shipping": shipping,
        // "subscriptions": subscriptions.toJson(),
        // "subscriptions": List<dynamic>.from(subscriptions.map((x) => x.toJson())),

        "tax_exempt": taxExempt,
        "test_clock": testClock,
      };
}

class CustomerAddress {
  CustomerAddress({
    @required this.city,
    @required this.country,
    @required this.line1,
    @required this.line2,
    @required this.postalCode,
    @required this.state,
  });

  final dynamic city;
  final String country;
  final dynamic line1;
  final dynamic line2;
  final String postalCode;
  final dynamic state;

  factory CustomerAddress.fromJson(Map<String, dynamic> json) =>
      CustomerAddress(
        city: json["city"],
        country: json["country"],
        line1: json["line1"],
        line2: json["line2"],
        postalCode: json["postal_code"],
        state: json["state"],
      );

  Map<String, dynamic> toJson() => {
        "city": city,
        "country": country,
        "line1": line1,
        "line2": line2,
        "postal_code": postalCode,
        "state": state,
      };
}

class CustomerInvoiceSettings {
  CustomerInvoiceSettings({
    @required this.customFields,
    @required this.defaultPaymentMethod,
    @required this.footer,
    @required this.renderingOptions,
  });

  final dynamic customFields;
  final dynamic defaultPaymentMethod;
  final dynamic footer;
  final dynamic renderingOptions;

  factory CustomerInvoiceSettings.fromJson(Map<String, dynamic> json) =>
      CustomerInvoiceSettings(
        customFields: json["custom_fields"],
        defaultPaymentMethod: json["default_payment_method"],
        footer: json["footer"],
        renderingOptions: json["rendering_options"],
      );

  Map<String, dynamic> toJson() => {
        "custom_fields": customFields,
        "default_payment_method": defaultPaymentMethod,
        "footer": footer,
        "rendering_options": renderingOptions,
      };
}

class CustomerMetadata {
  CustomerMetadata({
    @required this.appOpens,
    @required this.appRated,
    @required this.appUserId,
    @required this.appVersion,
    @required this.appZone,
    @required this.devUpgraded,
    @required this.freeTrialUsed,
    @required this.installerStore,
    @required this.totalCredits,
    @required this.userStatus,
  });

  final int appOpens;
  final bool appRated;
  final String appUserId;
  final String appVersion;
  final String appZone;
  final bool devUpgraded;
  final bool freeTrialUsed;
  final String installerStore;
  final int totalCredits;
  final String userStatus;

  factory CustomerMetadata.fromJson(Map<String, dynamic> json) =>
      CustomerMetadata(
        appOpens: int.parse(json["app_opens"]),
        appRated: json["app_rated"] == "true" ? true : false,
        appUserId: json["app_user_id"],
        appVersion: json["app_version"],
        appZone: json["app_zone"],
        devUpgraded: json["dev_upgraded"] == "true" ? true : false,
        freeTrialUsed: json["free_trial_used"] == "true" ? true : false,
        installerStore: json["installer_store"],
        totalCredits: int.parse(json["total_credits"]),
        userStatus: json["user_status"],
      );

  Map<String, dynamic> toJson() => {
        "app_opens": appOpens,
        "app_rated": appRated,
        "app_user_id": appUserId,
        "app_version": appVersion,
        "app_zone": appZone,
        "dev_upgraded": devUpgraded,
        "free_trial_used": freeTrialUsed,
        "installer_store": installerStore,
        "total_credits": totalCredits,
        "user_status": userStatus,
      };
}

// class CustomerSubscriptions {
//   CustomerSubscriptions({
//     @required this.object,
//     @required this.data,
//     @required this.hasMore,
//     @required this.totalCount,
//     @required this.url,
//   });

//   final String object;
//   final List<SubscriptionDatum> data;
//   final bool hasMore;
//   final int totalCount;
//   final String url;

//   factory CustomerSubscriptions.fromJson(Map<String, dynamic> json) =>
//       CustomerSubscriptions(
//         object: json["object"],
//         // data: List<dynamic>.from(json["data"].map((x) => x)),
//         data: List<SubscriptionDatum>.from(
//             json["data"].map((x) => SubscriptionDatum.fromJson(x))),
//         hasMore: json["has_more"],
//         totalCount: json["total_count"],
//         url: json["url"],
//       );

//   Map<String, dynamic> toJson() => {
//         "object": object,
//         // "data": List<dynamic>.from(data.map((x) => x)),
//         "data": List<SubscriptionDatum>.from(data.map((x) => x.toJson())),
//         "has_more": hasMore,
//         "total_count": totalCount,
//         "url": url,
//       };
// }
