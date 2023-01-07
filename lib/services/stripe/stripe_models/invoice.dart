// To parse this JSON data, do
//
//     final stripeInvoiceSearch = stripeInvoiceSearchFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

import 'charge.dart';
import 'customer.dart';
import 'subscription.dart';

StripeInvoiceSearch stripeInvoiceSearchFromJson(String str) =>
    StripeInvoiceSearch.fromJson(json.decode(str));

String stripeInvoiceSearchToJson(StripeInvoiceSearch data) =>
    json.encode(data.toJson());

class StripeInvoiceSearch {
  StripeInvoiceSearch({
    @required this.object,
    @required this.invoicesList,
    @required this.hasMore,
    @required this.nextPage,
    @required this.url,
  });

  final String object;
  final List<InvoiceDatum> invoicesList;
  final bool hasMore;
  final dynamic nextPage;
  final String url;

  factory StripeInvoiceSearch.fromJson(Map<String, dynamic> json) =>
      StripeInvoiceSearch(
        object: json["object"],
        invoicesList: List<InvoiceDatum>.from(
            json["data"].map((x) => InvoiceDatum.fromJson(x))),
        hasMore: json["has_more"],
        nextPage: json["next_page"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "object": object,
        "data": List<dynamic>.from(invoicesList.map((x) => x.toJson())),
        "has_more": hasMore,
        "next_page": nextPage,
        "url": url,
      };
}

class InvoiceDatum {
  InvoiceDatum({
    @required this.id,
    @required this.object,
    @required this.accountCountry,
    @required this.accountName,
    @required this.accountTaxIds,
    @required this.amountDue,
    @required this.amountPaid,
    @required this.amountRemaining,
    @required this.application,
    @required this.applicationFeeAmount,
    @required this.attemptCount,
    @required this.attempted,
    @required this.autoAdvance,
    @required this.automaticTax,
    @required this.billingReason,
    @required this.charge,
    @required this.collectionMethod,
    @required this.created,
    @required this.currency,
    @required this.customFields,
    @required this.customer,
    @required this.customerAddress,
    @required this.customerEmail,
    @required this.customerName,
    @required this.customerPhone,
    @required this.customerShipping,
    @required this.customerTaxExempt,
    @required this.customerTaxIds,
    @required this.defaultPaymentMethod,
    @required this.defaultSource,
    @required this.defaultTaxRates,
    @required this.description,
    @required this.discount,
    @required this.discounts,
    @required this.dueDate,
    @required this.endingBalance,
    @required this.footer,
    @required this.fromInvoice,
    @required this.hostedInvoiceUrl,
    @required this.invoicePdf,
    @required this.lastFinalizationError,
    @required this.latestRevision,
    @required this.lines,
    @required this.livemode,
    @required this.metadata,
    @required this.nextPaymentAttempt,
    @required this.number,
    @required this.onBehalfOf,
    @required this.paid,
    @required this.paidOutOfBand,
    @required this.paymentIntent,
    @required this.paymentSettings,
    @required this.periodEnd,
    @required this.periodStart,
    @required this.postPaymentCreditNotesAmount,
    @required this.prePaymentCreditNotesAmount,
    @required this.quote,
    @required this.receiptNumber,
    @required this.renderingOptions,
    @required this.startingBalance,
    @required this.statementDescriptor,
    @required this.status,
    @required this.statusTransitions,
    @required this.subscription,
    @required this.subtotal,
    @required this.subtotalExcludingTax,
    @required this.tax,
    @required this.testClock,
    @required this.total,
    @required this.totalDiscountAmounts,
    @required this.totalExcludingTax,
    @required this.totalTaxAmounts,
    @required this.transferData,
    @required this.webhooksDeliveredAt,
  });

  final String id;
  final String object;
  final String accountCountry;
  final String accountName;
  final dynamic accountTaxIds;
  final int amountDue;
  final int amountPaid;
  final int amountRemaining;
  final dynamic application;
  final dynamic applicationFeeAmount;
  final int attemptCount;
  final bool attempted;
  final bool autoAdvance;
  final InvoiceAutomaticTax automaticTax;
  final String billingReason;
  final StripeCharges charge;
  final String collectionMethod;
  final int created;
  final String currency;
  final dynamic customFields;
  final StripeCustomer customer;
  final InvoiceAddress customerAddress;
  final String customerEmail;
  final String customerName;
  final dynamic customerPhone;
  final dynamic customerShipping;
  final String customerTaxExempt;
  final List<dynamic> customerTaxIds;
  final dynamic defaultPaymentMethod;
  final dynamic defaultSource;
  final List<dynamic> defaultTaxRates;
  final dynamic description;
  final dynamic discount;
  final List<dynamic> discounts;
  final dynamic dueDate;
  final int endingBalance;
  final dynamic footer;
  final dynamic fromInvoice;
  final String hostedInvoiceUrl;
  final String invoicePdf;
  final dynamic lastFinalizationError;
  final dynamic latestRevision;
  final InvoiceLines lines;
  final bool livemode;
  final InvoiceMetadata metadata;
  final dynamic nextPaymentAttempt;
  final String number;
  final dynamic onBehalfOf;
  final bool paid;
  final bool paidOutOfBand;
  final String paymentIntent;
  final InvoicePaymentSettings paymentSettings;
  final int periodEnd;
  final int periodStart;
  final int postPaymentCreditNotesAmount;
  final int prePaymentCreditNotesAmount;
  final dynamic quote;
  final dynamic receiptNumber;
  final dynamic renderingOptions;
  final int startingBalance;
  final dynamic statementDescriptor;
  final String status;
  final InvoiceStatusTransitions statusTransitions;
  final SubscriptionDatum subscription;
  final int subtotal;
  final int subtotalExcludingTax;
  final dynamic tax;
  final dynamic testClock;
  final int total;
  final List<dynamic> totalDiscountAmounts;
  final int totalExcludingTax;
  final List<dynamic> totalTaxAmounts;
  final dynamic transferData;
  final int webhooksDeliveredAt;

  factory InvoiceDatum.fromJson(Map<String, dynamic> json) => InvoiceDatum(
        id: json["id"],
        object: json["object"],
        accountCountry: json["account_country"],
        accountName: json["account_name"],
        accountTaxIds: json["account_tax_ids"],
        amountDue: json["amount_due"],
        amountPaid: json["amount_paid"],
        amountRemaining: json["amount_remaining"],
        application: json["application"],
        applicationFeeAmount: json["application_fee_amount"],
        attemptCount: json["attempt_count"],
        attempted: json["attempted"],
        autoAdvance: json["auto_advance"],
        automaticTax: InvoiceAutomaticTax.fromJson(json["automatic_tax"]),
        billingReason: json["billing_reason"],
        charge: StripeCharges.fromJson(json["charge"]),
        collectionMethod: json["collection_method"],
        created: json["created"],
        currency: json["currency"],
        customFields: json["custom_fields"],
        customer: StripeCustomer.fromJson(json["customer"]),
        customerAddress: InvoiceAddress.fromJson(json["customer_address"]),
        customerEmail: json["customer_email"],
        customerName: json["customer_name"],
        customerPhone: json["customer_phone"],
        customerShipping: json["customer_shipping"],
        customerTaxExempt: json["customer_tax_exempt"],
        customerTaxIds:
            List<dynamic>.from(json["customer_tax_ids"].map((x) => x)),
        defaultPaymentMethod: json["default_payment_method"],
        defaultSource: json["default_source"],
        defaultTaxRates:
            List<dynamic>.from(json["default_tax_rates"].map((x) => x)),
        description: json["description"],
        discount: json["discount"],
        discounts: List<dynamic>.from(json["discounts"].map((x) => x)),
        dueDate: json["due_date"],
        endingBalance: json["ending_balance"],
        footer: json["footer"],
        fromInvoice: json["from_invoice"],
        hostedInvoiceUrl: json["hosted_invoice_url"],
        invoicePdf: json["invoice_pdf"],
        lastFinalizationError: json["last_finalization_error"],
        latestRevision: json["latest_revision"],
        lines: InvoiceLines.fromJson(json["lines"]),
        livemode: json["livemode"],
        metadata: InvoiceMetadata.fromJson(json["metadata"]),
        nextPaymentAttempt: json["next_payment_attempt"],
        number: json["number"],
        onBehalfOf: json["on_behalf_of"],
        paid: json["paid"],
        paidOutOfBand: json["paid_out_of_band"],
        paymentIntent: json["payment_intent"],
        paymentSettings:
            InvoicePaymentSettings.fromJson(json["payment_settings"]),
        periodEnd: json["period_end"],
        periodStart: json["period_start"],
        postPaymentCreditNotesAmount: json["post_payment_credit_notes_amount"],
        prePaymentCreditNotesAmount: json["pre_payment_credit_notes_amount"],
        quote: json["quote"],
        receiptNumber: json["receipt_number"],
        renderingOptions: json["rendering_options"],
        startingBalance: json["starting_balance"],
        statementDescriptor: json["statement_descriptor"],
        status: json["status"],
        statusTransitions:
            InvoiceStatusTransitions.fromJson(json["status_transitions"]),
        subscription: SubscriptionDatum.fromJson(json["subscription"]),
        subtotal: json["subtotal"],
        subtotalExcludingTax: json["subtotal_excluding_tax"],
        tax: json["tax"],
        testClock: json["test_clock"],
        total: json["total"],
        totalDiscountAmounts:
            List<dynamic>.from(json["total_discount_amounts"].map((x) => x)),
        totalExcludingTax: json["total_excluding_tax"],
        totalTaxAmounts:
            List<dynamic>.from(json["total_tax_amounts"].map((x) => x)),
        transferData: json["transfer_data"],
        webhooksDeliveredAt: json["webhooks_delivered_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "account_country": accountCountry,
        "account_name": accountName,
        "account_tax_ids": accountTaxIds,
        "amount_due": amountDue,
        "amount_paid": amountPaid,
        "amount_remaining": amountRemaining,
        "application": application,
        "application_fee_amount": applicationFeeAmount,
        "attempt_count": attemptCount,
        "attempted": attempted,
        "auto_advance": autoAdvance,
        "automatic_tax": automaticTax.toJson(),
        "billing_reason": billingReason,
        "charge": charge.toJson(),
        "collection_method": collectionMethod,
        "created": created,
        "currency": currency,
        "custom_fields": customFields,
        "customer": customer.toJson(),
        "customer_address": customerAddress.toJson(),
        "customer_email": customerEmail,
        "customer_name": customerName,
        "customer_phone": customerPhone,
        "customer_shipping": customerShipping,
        "customer_tax_exempt": customerTaxExempt,
        "customer_tax_ids": List<dynamic>.from(customerTaxIds.map((x) => x)),
        "default_payment_method": defaultPaymentMethod,
        "default_source": defaultSource,
        "default_tax_rates": List<dynamic>.from(defaultTaxRates.map((x) => x)),
        "description": description,
        "discount": discount,
        "discounts": List<dynamic>.from(discounts.map((x) => x)),
        "due_date": dueDate,
        "ending_balance": endingBalance,
        "footer": footer,
        "from_invoice": fromInvoice,
        "hosted_invoice_url": hostedInvoiceUrl,
        "invoice_pdf": invoicePdf,
        "last_finalization_error": lastFinalizationError,
        "latest_revision": latestRevision,
        "lines": lines.toJson(),
        "livemode": livemode,
        "metadata": metadata.toJson(),
        "next_payment_attempt": nextPaymentAttempt,
        "number": number,
        "on_behalf_of": onBehalfOf,
        "paid": paid,
        "paid_out_of_band": paidOutOfBand,
        "payment_intent": paymentIntent,
        "payment_settings": paymentSettings.toJson(),
        "period_end": periodEnd,
        "period_start": periodStart,
        "post_payment_credit_notes_amount": postPaymentCreditNotesAmount,
        "pre_payment_credit_notes_amount": prePaymentCreditNotesAmount,
        "quote": quote,
        "receipt_number": receiptNumber,
        "rendering_options": renderingOptions,
        "starting_balance": startingBalance,
        "statement_descriptor": statementDescriptor,
        "status": status,
        "status_transitions": statusTransitions.toJson(),
        "subscription": subscription.toJson(),
        "subtotal": subtotal,
        "subtotal_excluding_tax": subtotalExcludingTax,
        "tax": tax,
        "test_clock": testClock,
        "total": total,
        "total_discount_amounts":
            List<dynamic>.from(totalDiscountAmounts.map((x) => x)),
        "total_excluding_tax": totalExcludingTax,
        "total_tax_amounts": List<dynamic>.from(totalTaxAmounts.map((x) => x)),
        "transfer_data": transferData,
        "webhooks_delivered_at": webhooksDeliveredAt,
      };
}

class InvoiceAutomaticTax {
  InvoiceAutomaticTax({
    @required this.enabled,
    @required this.status,
  });

  final bool enabled;
  final dynamic status;

  factory InvoiceAutomaticTax.fromJson(Map<String, dynamic> json) =>
      InvoiceAutomaticTax(
        enabled: json["enabled"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
        "status": status,
      };
}

// class Charge {
//   Charge({
//     @required this.id,
//     @required this.object,
//     @required this.amount,
//     @required this.amountCaptured,
//     @required this.amountRefunded,
//     @required this.application,
//     @required this.applicationFee,
//     @required this.applicationFeeAmount,
//     @required this.balanceTransaction,
//     @required this.billingDetails,
//     @required this.calculatedStatementDescriptor,
//     @required this.captured,
//     @required this.created,
//     @required this.currency,
//     @required this.customer,
//     @required this.description,
//     @required this.destination,
//     @required this.dispute,
//     @required this.disputed,
//     @required this.failureBalanceTransaction,
//     @required this.failureCode,
//     @required this.failureMessage,
//     @required this.fraudDetails,
//     @required this.invoice,
//     @required this.livemode,
//     @required this.metadata,
//     @required this.onBehalfOf,
//     @required this.order,
//     @required this.outcome,
//     @required this.paid,
//     @required this.paymentIntent,
//     @required this.paymentMethod,
//     @required this.paymentMethodDetails,
//     @required this.receiptEmail,
//     @required this.receiptNumber,
//     @required this.receiptUrl,
//     @required this.refunded,
//     @required this.review,
//     @required this.shipping,
//     @required this.source,
//     @required this.sourceTransfer,
//     @required this.statementDescriptor,
//     @required this.statementDescriptorSuffix,
//     @required this.status,
//     @required this.transferData,
//     @required this.transferGroup,
//   });

//   final String id;
//   final String object;
//   final int amount;
//   final int amountCaptured;
//   final int amountRefunded;
//   final dynamic application;
//   final dynamic applicationFee;
//   final dynamic applicationFeeAmount;
//   final String balanceTransaction;
//   final BillingDetails billingDetails;
//   final String calculatedStatementDescriptor;
//   final bool captured;
//   final int created;
//   final String currency;
//   final String customer;
//   final String description;
//   final dynamic destination;
//   final dynamic dispute;
//   final bool disputed;
//   final dynamic failureBalanceTransaction;
//   final dynamic failureCode;
//   final dynamic failureMessage;
//   final Metadata fraudDetails;
//   final String invoice;
//   final bool livemode;
//   final Metadata metadata;
//   final dynamic onBehalfOf;
//   final dynamic order;
//   final Outcome outcome;
//   final bool paid;
//   final String paymentIntent;
//   final String paymentMethod;
//   final PaymentMethodDetails paymentMethodDetails;
//   final dynamic receiptEmail;
//   final dynamic receiptNumber;
//   final String receiptUrl;
//   final bool refunded;
//   final dynamic review;
//   final dynamic shipping;
//   final dynamic source;
//   final dynamic sourceTransfer;
//   final String statementDescriptor;
//   final dynamic statementDescriptorSuffix;
//   final String status;
//   final dynamic transferData;
//   final dynamic transferGroup;

//   factory Charge.fromJson(Map<String, dynamic> json) => Charge(
//         id: json["id"],
//         object: json["object"],
//         amount: json["amount"],
//         amountCaptured: json["amount_captured"],
//         amountRefunded: json["amount_refunded"],
//         application: json["application"],
//         applicationFee: json["application_fee"],
//         applicationFeeAmount: json["application_fee_amount"],
//         balanceTransaction: json["balance_transaction"],
//         billingDetails: BillingDetails.fromJson(json["billing_details"]),
//         calculatedStatementDescriptor: json["calculated_statement_descriptor"],
//         captured: json["captured"],
//         created: json["created"],
//         currency: json["currency"],
//         customer: json["customer"],
//         description: json["description"],
//         destination: json["destination"],
//         dispute: json["dispute"],
//         disputed: json["disputed"],
//         failureBalanceTransaction: json["failure_balance_transaction"],
//         failureCode: json["failure_code"],
//         failureMessage: json["failure_message"],
//         fraudDetails: Metadata.fromJson(json["fraud_details"]),
//         invoice: json["invoice"],
//         livemode: json["livemode"],
//         metadata: Metadata.fromJson(json["metadata"]),
//         onBehalfOf: json["on_behalf_of"],
//         order: json["order"],
//         outcome: Outcome.fromJson(json["outcome"]),
//         paid: json["paid"],
//         paymentIntent: json["payment_intent"],
//         paymentMethod: json["payment_method"],
//         paymentMethodDetails:
//             PaymentMethodDetails.fromJson(json["payment_method_details"]),
//         receiptEmail: json["receipt_email"],
//         receiptNumber: json["receipt_number"],
//         receiptUrl: json["receipt_url"],
//         refunded: json["refunded"],
//         review: json["review"],
//         shipping: json["shipping"],
//         source: json["source"],
//         sourceTransfer: json["source_transfer"],
//         statementDescriptor: json["statement_descriptor"],
//         statementDescriptorSuffix: json["statement_descriptor_suffix"],
//         status: json["status"],
//         transferData: json["transfer_data"],
//         transferGroup: json["transfer_group"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "object": object,
//         "amount": amount,
//         "amount_captured": amountCaptured,
//         "amount_refunded": amountRefunded,
//         "application": application,
//         "application_fee": applicationFee,
//         "application_fee_amount": applicationFeeAmount,
//         "balance_transaction": balanceTransaction,
//         "billing_details": billingDetails.toJson(),
//         "calculated_statement_descriptor": calculatedStatementDescriptor,
//         "captured": captured,
//         "created": created,
//         "currency": currency,
//         "customer": customer,
//         "description": description,
//         "destination": destination,
//         "dispute": dispute,
//         "disputed": disputed,
//         "failure_balance_transaction": failureBalanceTransaction,
//         "failure_code": failureCode,
//         "failure_message": failureMessage,
//         "fraud_details": fraudDetails.toJson(),
//         "invoice": invoice,
//         "livemode": livemode,
//         "metadata": metadata.toJson(),
//         "on_behalf_of": onBehalfOf,
//         "order": order,
//         "outcome": outcome.toJson(),
//         "paid": paid,
//         "payment_intent": paymentIntent,
//         "payment_method": paymentMethod,
//         "payment_method_details": paymentMethodDetails.toJson(),
//         "receipt_email": receiptEmail,
//         "receipt_number": receiptNumber,
//         "receipt_url": receiptUrl,
//         "refunded": refunded,
//         "review": review,
//         "shipping": shipping,
//         "source": source,
//         "source_transfer": sourceTransfer,
//         "statement_descriptor": statementDescriptor,
//         "statement_descriptor_suffix": statementDescriptorSuffix,
//         "status": status,
//         "transfer_data": transferData,
//         "transfer_group": transferGroup,
//       };
// }

class InvoiceBillingDetails {
  InvoiceBillingDetails({
    @required this.address,
    @required this.email,
    @required this.name,
    @required this.phone,
  });

  final InvoiceAddress address;
  final String email;
  final String name;
  final dynamic phone;

  factory InvoiceBillingDetails.fromJson(Map<String, dynamic> json) =>
      InvoiceBillingDetails(
        address: InvoiceAddress.fromJson(json["address"]),
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

class InvoiceAddress {
  InvoiceAddress({
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

  factory InvoiceAddress.fromJson(Map<String, dynamic> json) => InvoiceAddress(
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

class InvoiceMetadata {
  InvoiceMetadata();

  factory InvoiceMetadata.fromJson(Map<String, dynamic> json) =>
      InvoiceMetadata();

  Map<String, dynamic> toJson() => {};
}

class InvoiceOutcome {
  InvoiceOutcome({
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

  factory InvoiceOutcome.fromJson(Map<String, dynamic> json) => InvoiceOutcome(
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

class InvoicePaymentMethodDetails {
  InvoicePaymentMethodDetails({
    @required this.card,
    @required this.type,
  });

  final InvoiceCard card;
  final String type;

  factory InvoicePaymentMethodDetails.fromJson(Map<String, dynamic> json) =>
      InvoicePaymentMethodDetails(
        card: InvoiceCard.fromJson(json["card"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "card": card.toJson(),
        "type": type,
      };
}

class InvoiceCard {
  InvoiceCard({
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
  final InvoiceChecks checks;
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

  factory InvoiceCard.fromJson(Map<String, dynamic> json) => InvoiceCard(
        brand: json["brand"],
        checks: InvoiceChecks.fromJson(json["checks"]),
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

class InvoiceChecks {
  InvoiceChecks({
    @required this.addressLine1Check,
    @required this.addressPostalCodeCheck,
    @required this.cvcCheck,
  });

  final dynamic addressLine1Check;
  final String addressPostalCodeCheck;
  final String cvcCheck;

  factory InvoiceChecks.fromJson(Map<String, dynamic> json) => InvoiceChecks(
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

class InvoiceLines {
  InvoiceLines({
    @required this.object,
    @required this.data,
    @required this.hasMore,
    @required this.totalCount,
    @required this.url,
  });

  final String object;
  final List<InvoiceLinesDatum> data;
  final bool hasMore;
  final int totalCount;
  final String url;

  factory InvoiceLines.fromJson(Map<String, dynamic> json) => InvoiceLines(
        object: json["object"],
        data: List<InvoiceLinesDatum>.from(
            json["data"].map((x) => InvoiceLinesDatum.fromJson(x))),
        hasMore: json["has_more"],
        totalCount: json["total_count"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "object": object,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "has_more": hasMore,
        "total_count": totalCount,
        "url": url,
      };
}

class InvoiceLinesDatum {
  InvoiceLinesDatum({
    @required this.id,
    @required this.object,
    @required this.amount,
    @required this.amountExcludingTax,
    @required this.currency,
    @required this.description,
    @required this.discountAmounts,
    @required this.discountable,
    @required this.discounts,
    @required this.livemode,
    // @required this.metadata,
    @required this.period,
    @required this.plan,
    @required this.price,
    @required this.proration,
    @required this.prorationDetails,
    @required this.quantity,
    @required this.subscription,
    @required this.subscriptionItem,
    @required this.taxAmounts,
    @required this.taxRates,
    @required this.type,
    @required this.unitAmountExcludingTax,
  });

  final String id;
  final String object;
  final int amount;
  final int amountExcludingTax;
  final String currency;
  final String description;
  final List<dynamic> discountAmounts;
  final bool discountable;
  final List<dynamic> discounts;
  final bool livemode;
  // final InvoiceLinesMetadata metadata;
  final InvoicePeriod period;
  final InvoicePlan plan;
  final InvoicePrice price;
  final bool proration;
  final InvoiceProrationDetails prorationDetails;
  final int quantity;
  final String subscription;
  final String subscriptionItem;
  final List<dynamic> taxAmounts;
  final List<dynamic> taxRates;
  final String type;
  final String unitAmountExcludingTax;

  factory InvoiceLinesDatum.fromJson(Map<String, dynamic> json) =>
      InvoiceLinesDatum(
        id: json["id"],
        object: json["object"],
        amount: json["amount"],
        amountExcludingTax: json["amount_excluding_tax"],
        currency: json["currency"],
        description: json["description"],
        discountAmounts:
            List<dynamic>.from(json["discount_amounts"].map((x) => x)),
        discountable: json["discountable"],
        discounts: List<dynamic>.from(json["discounts"].map((x) => x)),
        livemode: json["livemode"],
        // metadata: InvoiceLinesMetadata.fromJson(json["metadata"]),
        period: InvoicePeriod.fromJson(json["period"]),
        plan: InvoicePlan.fromJson(json["plan"]),
        price: InvoicePrice.fromJson(json["price"]),
        proration: json["proration"],
        prorationDetails:
            InvoiceProrationDetails.fromJson(json["proration_details"]),
        quantity: json["quantity"],
        subscription: json["subscription"],
        subscriptionItem: json["subscription_item"],
        taxAmounts: List<dynamic>.from(json["tax_amounts"].map((x) => x)),
        taxRates: List<dynamic>.from(json["tax_rates"].map((x) => x)),
        type: json["type"],
        unitAmountExcludingTax: json["unit_amount_excluding_tax"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "amount": amount,
        "amount_excluding_tax": amountExcludingTax,
        "currency": currency,
        "description": description,
        "discount_amounts": List<dynamic>.from(discountAmounts.map((x) => x)),
        "discountable": discountable,
        "discounts": List<dynamic>.from(discounts.map((x) => x)),
        "livemode": livemode,
        // "metadata": metadata.toJson(),
        "period": period.toJson(),
        "plan": plan.toJson(),
        "price": price.toJson(),
        "proration": proration,
        "proration_details": prorationDetails.toJson(),
        "quantity": quantity,
        "subscription": subscription,
        "subscription_item": subscriptionItem,
        "tax_amounts": List<dynamic>.from(taxAmounts.map((x) => x)),
        "tax_rates": List<dynamic>.from(taxRates.map((x) => x)),
        "type": type,
        "unit_amount_excluding_tax": unitAmountExcludingTax,
      };
}

class InvoicePeriod {
  InvoicePeriod({
    @required this.end,
    @required this.start,
  });

  final int end;
  final int start;

  factory InvoicePeriod.fromJson(Map<String, dynamic> json) => InvoicePeriod(
        end: json["end"],
        start: json["start"],
      );

  Map<String, dynamic> toJson() => {
        "end": end,
        "start": start,
      };
}

class InvoicePlan {
  InvoicePlan({
    @required this.id,
    @required this.object,
    @required this.active,
    @required this.aggregateUsage,
    @required this.amount,
    @required this.amountDecimal,
    @required this.billingScheme,
    @required this.created,
    @required this.currency,
    @required this.interval,
    @required this.intervalCount,
    @required this.livemode,
    // @required this.metadata,
    @required this.nickname,
    @required this.product,
    @required this.tiersMode,
    @required this.transformUsage,
    @required this.trialPeriodDays,
    @required this.usageType,
  });

  final String id;
  final String object;
  final bool active;
  final dynamic aggregateUsage;
  final int amount;
  final String amountDecimal;
  final String billingScheme;
  final int created;
  final String currency;
  final String interval;
  final int intervalCount;
  final bool livemode;
  // final InvoicePlanMetadata metadata;
  final dynamic nickname;
  final String product;
  final dynamic tiersMode;
  final dynamic transformUsage;
  final dynamic trialPeriodDays;
  final String usageType;

  factory InvoicePlan.fromJson(Map<String, dynamic> json) => InvoicePlan(
        id: json["id"],
        object: json["object"],
        active: json["active"],
        aggregateUsage: json["aggregate_usage"],
        amount: json["amount"],
        amountDecimal: json["amount_decimal"],
        billingScheme: json["billing_scheme"],
        created: json["created"],
        currency: json["currency"],
        interval: json["interval"],
        intervalCount: json["interval_count"],
        livemode: json["livemode"],
        // metadata: InvoicePlanMetadata.fromJson(json["metadata"]),
        nickname: json["nickname"],
        product: json["product"],
        tiersMode: json["tiers_mode"],
        transformUsage: json["transform_usage"],
        trialPeriodDays: json["trial_period_days"],
        usageType: json["usage_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "active": active,
        "aggregate_usage": aggregateUsage,
        "amount": amount,
        "amount_decimal": amountDecimal,
        "billing_scheme": billingScheme,
        "created": created,
        "currency": currency,
        "interval": interval,
        "interval_count": intervalCount,
        "livemode": livemode,
        // "metadata": metadata.toJson(),
        "nickname": nickname,
        "product": product,
        "tiers_mode": tiersMode,
        "transform_usage": transformUsage,
        "trial_period_days": trialPeriodDays,
        "usage_type": usageType,
      };
}

class InvoicePrice {
  InvoicePrice({
    @required this.id,
    @required this.object,
    @required this.active,
    @required this.billingScheme,
    @required this.created,
    @required this.currency,
    @required this.customUnitAmount,
    @required this.livemode,
    @required this.lookupKey,
    // @required this.metadata,
    @required this.nickname,
    @required this.product,
    @required this.recurring,
    @required this.taxBehavior,
    @required this.tiersMode,
    @required this.transformQuantity,
    @required this.type,
    @required this.unitAmount,
    @required this.unitAmountDecimal,
  });

  final String id;
  final String object;
  final bool active;
  final String billingScheme;
  final int created;
  final String currency;
  final dynamic customUnitAmount;
  final bool livemode;
  final dynamic lookupKey;
  // final InvoicePriceMetadata metadata;
  final dynamic nickname;
  final String product;
  final InvoiceRecurring recurring;
  final String taxBehavior;
  final dynamic tiersMode;
  final dynamic transformQuantity;
  final String type;
  final int unitAmount;
  final String unitAmountDecimal;

  factory InvoicePrice.fromJson(Map<String, dynamic> json) => InvoicePrice(
        id: json["id"],
        object: json["object"],
        active: json["active"],
        billingScheme: json["billing_scheme"],
        created: json["created"],
        currency: json["currency"],
        customUnitAmount: json["custom_unit_amount"],
        livemode: json["livemode"],
        lookupKey: json["lookup_key"],
        // metadata: InvoicePriceMetadata.fromJson(json["metadata"]),
        nickname: json["nickname"],
        product: json["product"],
        recurring: InvoiceRecurring.fromJson(json["recurring"]),
        taxBehavior: json["tax_behavior"],
        tiersMode: json["tiers_mode"],
        transformQuantity: json["transform_quantity"],
        type: json["type"],
        unitAmount: json["unit_amount"],
        unitAmountDecimal: json["unit_amount_decimal"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "active": active,
        "billing_scheme": billingScheme,
        "created": created,
        "currency": currency,
        "custom_unit_amount": customUnitAmount,
        "livemode": livemode,
        "lookup_key": lookupKey,
        // "metadata": metadata.toJson(),
        "nickname": nickname,
        "product": product,
        "recurring": recurring.toJson(),
        "tax_behavior": taxBehavior,
        "tiers_mode": tiersMode,
        "transform_quantity": transformQuantity,
        "type": type,
        "unit_amount": unitAmount,
        "unit_amount_decimal": unitAmountDecimal,
      };
}

class InvoiceRecurring {
  InvoiceRecurring({
    @required this.aggregateUsage,
    @required this.interval,
    @required this.intervalCount,
    @required this.trialPeriodDays,
    @required this.usageType,
  });

  final dynamic aggregateUsage;
  final String interval;
  final int intervalCount;
  final dynamic trialPeriodDays;
  final String usageType;

  factory InvoiceRecurring.fromJson(Map<String, dynamic> json) =>
      InvoiceRecurring(
        aggregateUsage: json["aggregate_usage"],
        interval: json["interval"],
        intervalCount: json["interval_count"],
        trialPeriodDays: json["trial_period_days"],
        usageType: json["usage_type"],
      );

  Map<String, dynamic> toJson() => {
        "aggregate_usage": aggregateUsage,
        "interval": interval,
        "interval_count": intervalCount,
        "trial_period_days": trialPeriodDays,
        "usage_type": usageType,
      };
}

class InvoiceProrationDetails {
  InvoiceProrationDetails({
    @required this.creditedItems,
  });

  final dynamic creditedItems;

  factory InvoiceProrationDetails.fromJson(Map<String, dynamic> json) =>
      InvoiceProrationDetails(
        creditedItems: json["credited_items"],
      );

  Map<String, dynamic> toJson() => {
        "credited_items": creditedItems,
      };
}

class InvoicePaymentSettings {
  InvoicePaymentSettings({
    @required this.defaultMandate,
    @required this.paymentMethodOptions,
    @required this.paymentMethodTypes,
  });

  final dynamic defaultMandate;
  final dynamic paymentMethodOptions;
  final dynamic paymentMethodTypes;

  factory InvoicePaymentSettings.fromJson(Map<String, dynamic> json) =>
      InvoicePaymentSettings(
        defaultMandate: json["default_mandate"],
        paymentMethodOptions: json["payment_method_options"],
        paymentMethodTypes: json["payment_method_types"],
      );

  Map<String, dynamic> toJson() => {
        "default_mandate": defaultMandate,
        "payment_method_options": paymentMethodOptions,
        "payment_method_types": paymentMethodTypes,
      };
}

class InvoiceStatusTransitions {
  InvoiceStatusTransitions({
    @required this.finalizedAt,
    @required this.markedUncollectibleAt,
    @required this.paidAt,
    @required this.voidedAt,
  });

  final int finalizedAt;
  final dynamic markedUncollectibleAt;
  final int paidAt;
  final dynamic voidedAt;

  factory InvoiceStatusTransitions.fromJson(Map<String, dynamic> json) =>
      InvoiceStatusTransitions(
        finalizedAt: json["finalized_at"],
        markedUncollectibleAt: json["marked_uncollectible_at"],
        paidAt: json["paid_at"],
        voidedAt: json["voided_at"],
      );

  Map<String, dynamic> toJson() => {
        "finalized_at": finalizedAt,
        "marked_uncollectible_at": markedUncollectibleAt,
        "paid_at": paidAt,
        "voided_at": voidedAt,
      };
}

// class Subscription {
//   Subscription({
//     @required this.id,
//     @required this.object,
//     @required this.application,
//     @required this.applicationFeePercent,
//     @required this.automaticTax,
//     @required this.billingCycleAnchor,
//     @required this.billingThresholds,
//     @required this.cancelAt,
//     @required this.cancelAtPeriodEnd,
//     @required this.canceledAt,
//     @required this.collectionMethod,
//     @required this.created,
//     @required this.currency,
//     @required this.currentPeriodEnd,
//     @required this.currentPeriodStart,
//     @required this.customer,
//     @required this.daysUntilDue,
//     @required this.defaultPaymentMethod,
//     @required this.defaultSource,
//     @required this.defaultTaxRates,
//     @required this.description,
//     @required this.discount,
//     @required this.endedAt,
//     @required this.items,
//     @required this.latestInvoice,
//     @required this.livemode,
//     @required this.metadata,
//     @required this.nextPendingInvoiceItemInvoice,
//     @required this.onBehalfOf,
//     // @required this.pauseCollection,
//     @required this.paymentSettings,
//     @required this.pendingInvoiceItemInterval,
//     @required this.pendingSetupIntent,
//     @required this.pendingUpdate,
//     @required this.plan,
//     @required this.quantity,
//     @required this.schedule,
//     @required this.startDate,
//     @required this.status,
//     @required this.testClock,
//     @required this.transferData,
//     @required this.trialEnd,
//     @required this.trialStart,
//   });

//   final String id;
//   final String object;
//   final dynamic application;
//   final dynamic applicationFeePercent;
//   final SubscriptionAutomaticTax automaticTax;
//   final int billingCycleAnchor;
//   final dynamic billingThresholds;
//   final dynamic cancelAt;
//   final bool cancelAtPeriodEnd;
//   final int canceledAt;
//   final String collectionMethod;
//   final int created;
//   final String currency;
//   final int currentPeriodEnd;
//   final int currentPeriodStart;
//   final String customer;
//   final dynamic daysUntilDue;
//   final String defaultPaymentMethod;
//   final dynamic defaultSource;
//   final List<dynamic> defaultTaxRates;
//   final dynamic description;
//   final dynamic discount;
//   final int endedAt;
//   final Items items;
//   final String latestInvoice;
//   final bool livemode;
//   final Metadata metadata;
//   final dynamic nextPendingInvoiceItemInvoice;
//   final dynamic onBehalfOf;
//   // final PauseCollection pauseCollection;
//   final SubscriptionPaymentSettings paymentSettings;
//   final dynamic pendingInvoiceItemInterval;
//   final dynamic pendingSetupIntent;
//   final dynamic pendingUpdate;
//   final Plan plan;
//   final int quantity;
//   final dynamic schedule;
//   final int startDate;
//   final String status;
//   final dynamic testClock;
//   final dynamic transferData;
//   final dynamic trialEnd;
//   final dynamic trialStart;

//   factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
//         id: json["id"],
//         object: json["object"],
//         application: json["application"],
//         applicationFeePercent: json["application_fee_percent"],
//         automaticTax: SubscriptionAutomaticTax.fromJson(json["automatic_tax"]),
//         billingCycleAnchor: json["billing_cycle_anchor"],
//         billingThresholds: json["billing_thresholds"],
//         cancelAt: json["cancel_at"],
//         cancelAtPeriodEnd: json["cancel_at_period_end"],
//         canceledAt: json["canceled_at"],
//         collectionMethod: json["collection_method"],
//         created: json["created"],
//         currency: json["currency"],
//         currentPeriodEnd: json["current_period_end"],
//         currentPeriodStart: json["current_period_start"],
//         customer: json["customer"],
//         daysUntilDue: json["days_until_due"],
//         defaultPaymentMethod: json["default_payment_method"],
//         defaultSource: json["default_source"],
//         defaultTaxRates:
//             List<dynamic>.from(json["default_tax_rates"].map((x) => x)),
//         description: json["description"],
//         discount: json["discount"],
//         endedAt: json["ended_at"],
//         items: Items.fromJson(json["items"]),
//         latestInvoice: json["latest_invoice"],
//         livemode: json["livemode"],
//         metadata: Metadata.fromJson(json["metadata"]),
//         nextPendingInvoiceItemInvoice:
//             json["next_pending_invoice_item_invoice"],
//         onBehalfOf: json["on_behalf_of"],
//         // pauseCollection: json["pause_collection"] == null
//         //     ? null
//         //     : PauseCollection.fromJson(json["pause_collection"]),
//         paymentSettings:
//             SubscriptionPaymentSettings.fromJson(json["payment_settings"]),
//         pendingInvoiceItemInterval: json["pending_invoice_item_interval"],
//         pendingSetupIntent: json["pending_setup_intent"],
//         pendingUpdate: json["pending_update"],
//         plan: Plan.fromJson(json["plan"]),
//         quantity: json["quantity"],
//         schedule: json["schedule"],
//         startDate: json["start_date"],
//         status: json["status"],
//         testClock: json["test_clock"],
//         transferData: json["transfer_data"],
//         trialEnd: json["trial_end"],
//         trialStart: json["trial_start"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "object": object,
//         "application": application,
//         "application_fee_percent": applicationFeePercent,
//         "automatic_tax": automaticTax.toJson(),
//         "billing_cycle_anchor": billingCycleAnchor,
//         "billing_thresholds": billingThresholds,
//         "cancel_at": cancelAt,
//         "cancel_at_period_end": cancelAtPeriodEnd,
//         "canceled_at": canceledAt,
//         "collection_method": collectionMethod,
//         "created": created,
//         "currency": currency,
//         "current_period_end": currentPeriodEnd,
//         "current_period_start": currentPeriodStart,
//         "customer": customer,
//         "days_until_due": daysUntilDue,
//         "default_payment_method": defaultPaymentMethod,
//         "default_source": defaultSource,
//         "default_tax_rates": List<dynamic>.from(defaultTaxRates.map((x) => x)),
//         "description": description,
//         "discount": discount,
//         "ended_at": endedAt,
//         "items": items.toJson(),
//         "latest_invoice": latestInvoice,
//         "livemode": livemode,
//         "metadata": metadata.toJson(),
//         "next_pending_invoice_item_invoice": nextPendingInvoiceItemInvoice,
//         "on_behalf_of": onBehalfOf,
//         // "pause_collection":
//         //     pauseCollection == null ? null : pauseCollection.toJson(),
//         "payment_settings": paymentSettings.toJson(),
//         "pending_invoice_item_interval": pendingInvoiceItemInterval,
//         "pending_setup_intent": pendingSetupIntent,
//         "pending_update": pendingUpdate,
//         "plan": plan.toJson(),
//         "quantity": quantity,
//         "schedule": schedule,
//         "start_date": startDate,
//         "status": status,
//         "test_clock": testClock,
//         "transfer_data": transferData,
//         "trial_end": trialEnd,
//         "trial_start": trialStart,
//       };
// }

class InvoiceItems {
  InvoiceItems({
    @required this.object,
    @required this.data,
    @required this.hasMore,
    @required this.totalCount,
    @required this.url,
  });

  final String object;
  final List<InvoiceItemsDatum> data;
  final bool hasMore;
  final int totalCount;
  final String url;

  factory InvoiceItems.fromJson(Map<String, dynamic> json) => InvoiceItems(
        object: json["object"],
        data: List<InvoiceItemsDatum>.from(
            json["data"].map((x) => InvoiceItemsDatum.fromJson(x))),
        hasMore: json["has_more"],
        totalCount: json["total_count"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "object": object,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "has_more": hasMore,
        "total_count": totalCount,
        "url": url,
      };
}

class InvoiceItemsDatum {
  InvoiceItemsDatum({
    @required this.id,
    @required this.object,
    @required this.billingThresholds,
    @required this.created,
    // @required this.metadata,
    @required this.plan,
    @required this.price,
    @required this.quantity,
    @required this.subscription,
    @required this.taxRates,
  });

  final String id;
  final String object;
  final dynamic billingThresholds;
  final int created;
  // final InvoiceItemsMetadata metadata;
  final InvoicePlan plan;
  final InvoicePrice price;
  final int quantity;
  final String subscription;
  final List<dynamic> taxRates;

  factory InvoiceItemsDatum.fromJson(Map<String, dynamic> json) =>
      InvoiceItemsDatum(
        id: json["id"],
        object: json["object"],
        billingThresholds: json["billing_thresholds"],
        created: json["created"],
        // metadata: InvoiceItemsMetadata.fromJson(json["metadata"]),
        plan: InvoicePlan.fromJson(json["plan"]),
        price: InvoicePrice.fromJson(json["price"]),
        quantity: json["quantity"],
        subscription: json["subscription"],
        taxRates: List<dynamic>.from(json["tax_rates"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "billing_thresholds": billingThresholds,
        "created": created,
        // "metadata": metadata.toJson(),
        "plan": plan.toJson(),
        "price": price.toJson(),
        "quantity": quantity,
        "subscription": subscription,
        "tax_rates": List<dynamic>.from(taxRates.map((x) => x)),
      };
}

class InvoicePauseCollection {
  InvoicePauseCollection({
    @required this.behavior,
    @required this.resumesAt,
  });

  final String behavior;
  final dynamic resumesAt;

  factory InvoicePauseCollection.fromJson(Map<String, dynamic> json) =>
      InvoicePauseCollection(
        behavior: json["behavior"],
        resumesAt: json["resumes_at"],
      );

  Map<String, dynamic> toJson() => {
        "behavior": behavior,
        "resumes_at": resumesAt,
      };
}

// class SubscriptionPaymentSettings {
//   SubscriptionPaymentSettings({
//     @required this.paymentMethodOptions,
//     @required this.paymentMethodTypes,
//     @required this.saveDefaultPaymentMethod,
//   });

//   final dynamic paymentMethodOptions;
//   final dynamic paymentMethodTypes;
//   final String saveDefaultPaymentMethod;

//   factory SubscriptionPaymentSettings.fromJson(Map<String, dynamic> json) =>
//       SubscriptionPaymentSettings(
//         paymentMethodOptions: json["payment_method_options"],
//         paymentMethodTypes: json["payment_method_types"],
//         saveDefaultPaymentMethod: json["save_default_payment_method"],
//       );

//   Map<String, dynamic> toJson() => {
//         "payment_method_options": paymentMethodOptions,
//         "payment_method_types": paymentMethodTypes,
//         "save_default_payment_method": saveDefaultPaymentMethod,
//       };
// }
