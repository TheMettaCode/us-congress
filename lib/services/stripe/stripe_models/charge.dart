// To parse this JSON data, do
//
//     final stripeCharge = stripeChargeFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

StripeCharge stripeChargeFromJson(String str) => StripeCharge.fromJson(json.decode(str));

String stripeChargeToJson(StripeCharge data) => json.encode(data.toJson());

class StripeCharge {
  StripeCharge({
    @required this.object,
    @required this.data,
    @required this.hasMore,
    @required this.url,
  });

  final String object;
  final List<StripeCharges> data;
  final bool hasMore;
  final String url;

  factory StripeCharge.fromJson(Map<String, dynamic> json) => StripeCharge(
    object: json["object"],
    data: List<StripeCharges>.from(json["data"].map((x) => StripeCharges.fromJson(x))),
    hasMore: json["has_more"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "object": object,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "has_more": hasMore,
    "url": url,
  };
}

// To parse this JSON data, do
//
//     final stripeChargeSearch = stripeChargeSearchFromJson(jsonString);

StripeChargeSearch stripeChargeSearchFromJson(String str) => StripeChargeSearch.fromJson(json.decode(str));

String stripeChargeSearchToJson(StripeChargeSearch data) => json.encode(data.toJson());

class StripeChargeSearch {
  StripeChargeSearch({
    @required this.object,
    @required this.data,
    @required this.hasMore,
    @required this.nextPage,
    @required this.url,
  });

  final String object;
  final List<StripeCharges> data;
  final bool hasMore;
  final dynamic nextPage;
  final String url;

  factory StripeChargeSearch.fromJson(Map<String, dynamic> json) => StripeChargeSearch(
    object: json["object"],
    data: List<StripeCharges>.from(json["data"].map((x) => StripeCharges.fromJson(x))),
    hasMore: json["has_more"],
    nextPage: json["next_page"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "object": object,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "has_more": hasMore,
    "next_page": nextPage,
    "url": url,
  };
}

class StripeCharges {
  StripeCharges({
    @required this.id,
    @required this.object,
    @required this.amount,
    @required this.amountCaptured,
    @required this.amountRefunded,
    @required this.application,
    @required this.applicationFee,
    @required this.applicationFeeAmount,
    @required this.balanceTransaction,
    @required this.billingDetails,
    @required this.calculatedStatementDescriptor,
    @required this.captured,
    @required this.created,
    @required this.currency,
    @required this.customer,
    @required this.description,
    @required this.destination,
    @required this.dispute,
    @required this.disputed,
    @required this.failureBalanceTransaction,
    @required this.failureCode,
    @required this.failureMessage,
    @required this.fraudDetails,
    @required this.invoice,
    @required this.livemode,
    @required this.metadata,
    @required this.onBehalfOf,
    @required this.order,
    @required this.outcome,
    @required this.paid,
    @required this.paymentIntent,
    @required this.paymentMethod,
    @required this.paymentMethodDetails,
    @required this.receiptEmail,
    @required this.receiptNumber,
    @required this.receiptUrl,
    @required this.refunded,
    @required this.review,
    @required this.shipping,
    @required this.source,
    @required this.sourceTransfer,
    @required this.statementDescriptor,
    @required this.statementDescriptorSuffix,
    @required this.status,
    @required this.transferData,
    @required this.transferGroup,
  });

  final String id;
  final String object;
  final int amount;
  final int amountCaptured;
  final int amountRefunded;
  final dynamic application;
  final dynamic applicationFee;
  final dynamic applicationFeeAmount;
  final String balanceTransaction;
  final BillingDetails billingDetails;
  final String calculatedStatementDescriptor;
  final bool captured;
  final int created;
  final String currency;
  final String customer;
  final String description;
  final dynamic destination;
  final dynamic dispute;
  final bool disputed;
  final dynamic failureBalanceTransaction;
  final dynamic failureCode;
  final dynamic failureMessage;
  final FraudDetails fraudDetails;
  final String invoice;
  final bool livemode;
  final FraudDetails metadata;
  final dynamic onBehalfOf;
  final dynamic order;
  final Outcome outcome;
  final bool paid;
  final String paymentIntent;
  final String paymentMethod;
  final PaymentMethodDetails paymentMethodDetails;
  final dynamic receiptEmail;
  final dynamic receiptNumber;
  final String receiptUrl;
  final bool refunded;
  final dynamic review;
  final dynamic shipping;
  final dynamic source;
  final dynamic sourceTransfer;
  final String statementDescriptor;
  final dynamic statementDescriptorSuffix;
  final String status;
  final dynamic transferData;
  final dynamic transferGroup;

  factory StripeCharges.fromJson(Map<String, dynamic> json) => StripeCharges(
    id: json["id"],
    object: json["object"],
    amount: json["amount"],
    amountCaptured: json["amount_captured"],
    amountRefunded: json["amount_refunded"],
    application: json["application"],
    applicationFee: json["application_fee"],
    applicationFeeAmount: json["application_fee_amount"],
    balanceTransaction: json["balance_transaction"],
    billingDetails: BillingDetails.fromJson(json["billing_details"]),
    calculatedStatementDescriptor: json["calculated_statement_descriptor"],
    captured: json["captured"],
    created: json["created"],
    currency: json["currency"],
    customer: json["customer"],
    description: json["description"],
    destination: json["destination"],
    dispute: json["dispute"],
    disputed: json["disputed"],
    failureBalanceTransaction: json["failure_balance_transaction"],
    failureCode: json["failure_code"],
    failureMessage: json["failure_message"],
    fraudDetails: FraudDetails.fromJson(json["fraud_details"]),
    invoice: json["invoice"],
    livemode: json["livemode"],
    metadata: FraudDetails.fromJson(json["metadata"]),
    onBehalfOf: json["on_behalf_of"],
    order: json["order"],
    outcome: Outcome.fromJson(json["outcome"]),
    paid: json["paid"],
    paymentIntent: json["payment_intent"],
    paymentMethod: json["payment_method"],
    paymentMethodDetails: PaymentMethodDetails.fromJson(json["payment_method_details"]),
    receiptEmail: json["receipt_email"],
    receiptNumber: json["receipt_number"],
    receiptUrl: json["receipt_url"],
    refunded: json["refunded"],
    review: json["review"],
    shipping: json["shipping"],
    source: json["source"],
    sourceTransfer: json["source_transfer"],
    statementDescriptor: json["statement_descriptor"],
    statementDescriptorSuffix: json["statement_descriptor_suffix"],
    status: json["status"],
    transferData: json["transfer_data"],
    transferGroup: json["transfer_group"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "object": object,
    "amount": amount,
    "amount_captured": amountCaptured,
    "amount_refunded": amountRefunded,
    "application": application,
    "application_fee": applicationFee,
    "application_fee_amount": applicationFeeAmount,
    "balance_transaction": balanceTransaction,
    "billing_details": billingDetails.toJson(),
    "calculated_statement_descriptor": calculatedStatementDescriptor,
    "captured": captured,
    "created": created,
    "currency": currency,
    "customer": customer,
    "description": description,
    "destination": destination,
    "dispute": dispute,
    "disputed": disputed,
    "failure_balance_transaction": failureBalanceTransaction,
    "failure_code": failureCode,
    "failure_message": failureMessage,
    "fraud_details": fraudDetails.toJson(),
    "invoice": invoice,
    "livemode": livemode,
    "metadata": metadata.toJson(),
    "on_behalf_of": onBehalfOf,
    "order": order,
    "outcome": outcome.toJson(),
    "paid": paid,
    "payment_intent": paymentIntent,
    "payment_method": paymentMethod,
    "payment_method_details": paymentMethodDetails.toJson(),
    "receipt_email": receiptEmail,
    "receipt_number": receiptNumber,
    "receipt_url": receiptUrl,
    "refunded": refunded,
    "review": review,
    "shipping": shipping,
    "source": source,
    "source_transfer": sourceTransfer,
    "statement_descriptor": statementDescriptor,
    "statement_descriptor_suffix": statementDescriptorSuffix,
    "status": status,
    "transfer_data": transferData,
    "transfer_group": transferGroup,
  };
}

class BillingDetails {
  BillingDetails({
    @required this.address,
    @required this.email,
    @required this.name,
    @required this.phone,
  });

  final StripeChargeAddress address;
  final String email;
  final String name;
  final dynamic phone;

  factory BillingDetails.fromJson(Map<String, dynamic> json) => BillingDetails(
    address: StripeChargeAddress.fromJson(json["address"]),
    email: json["email"],
    name: json["name"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "address": address.toJson(),
    "email": email,
    "name": name,
    "phone": phone,
  };
}

class StripeChargeAddress {
  StripeChargeAddress({
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

  factory StripeChargeAddress.fromJson(Map<String, dynamic> json) => StripeChargeAddress(
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

class FraudDetails {
  FraudDetails();

  factory FraudDetails.fromJson(Map<String, dynamic> json) => FraudDetails();

  Map<String, dynamic> toJson() => {};
}

class Outcome {
  Outcome({
    @required this.networkStatus,
    @required this.reason,
    @required this.riskLevel,
    @required this.sellerMessage,
    @required this.type,
  });

  final String networkStatus;
  final dynamic reason;
  final String riskLevel;
  final String sellerMessage;
  final String type;

  factory Outcome.fromJson(Map<String, dynamic> json) => Outcome(
    networkStatus: json["network_status"],
    reason: json["reason"],
    riskLevel: json["risk_level"],
    sellerMessage: json["seller_message"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "network_status": networkStatus,
    "reason": reason,
    "risk_level": riskLevel,
    "seller_message": sellerMessage,
    "type": type,
  };
}

class PaymentMethodDetails {
  PaymentMethodDetails({
    @required this.card,
    @required this.type,
  });

  final StripeChargeCard card;
  final String type;

  factory PaymentMethodDetails.fromJson(Map<String, dynamic> json) => PaymentMethodDetails(
    card: StripeChargeCard.fromJson(json["card"]),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "card": card.toJson(),
    "type": type,
  };
}

class StripeChargeCard {
  StripeChargeCard({
    @required this.brand,
    @required this.checks,
    @required this.country,
    @required this.expMonth,
    @required this.expYear,
    @required this.fingerprint,
    @required this.funding,
    @required this.installments,
    @required this.last4,
    @required this.mandate,
    @required this.network,
    @required this.threeDSecure,
    @required this.wallet,
  });

  final String brand;
  final StripeChargeChecks checks;
  final String country;
  final int expMonth;
  final int expYear;
  final String fingerprint;
  final String funding;
  final dynamic installments;
  final String last4;
  final dynamic mandate;
  final String network;
  final dynamic threeDSecure;
  final dynamic wallet;

  factory StripeChargeCard.fromJson(Map<String, dynamic> json) => StripeChargeCard(
    brand: json["brand"],
    checks: StripeChargeChecks.fromJson(json["checks"]),
    country: json["country"],
    expMonth: json["exp_month"],
    expYear: json["exp_year"],
    fingerprint: json["fingerprint"],
    funding: json["funding"],
    installments: json["installments"],
    last4: json["last4"],
    mandate: json["mandate"],
    network: json["network"],
    threeDSecure: json["three_d_secure"],
    wallet: json["wallet"],
  );

  Map<String, dynamic> toJson() => {
    "brand": brand,
    "checks": checks.toJson(),
    "country": country,
    "exp_month": expMonth,
    "exp_year": expYear,
    "fingerprint": fingerprint,
    "funding": funding,
    "installments": installments,
    "last4": last4,
    "mandate": mandate,
    "network": network,
    "three_d_secure": threeDSecure,
    "wallet": wallet,
  };
}

class StripeChargeChecks {
  StripeChargeChecks({
    @required this.addressLine1Check,
    @required this.addressPostalCodeCheck,
    @required this.cvcCheck,
  });

  final dynamic addressLine1Check;
  final String addressPostalCodeCheck;
  final String cvcCheck;

  factory StripeChargeChecks.fromJson(Map<String, dynamic> json) => StripeChargeChecks(
    addressLine1Check: json["address_line1_check"],
    addressPostalCodeCheck: json["address_postal_code_check"],
    cvcCheck: json["cvc_check"],
  );

  Map<String, dynamic> toJson() => {
    "address_line1_check": addressLine1Check,
    "address_postal_code_check": addressPostalCodeCheck,
    "cvc_check": cvcCheck,
  };
}