// To parse this JSON data, do
//
//     final stripeSubscriptions = stripeSubscriptionsFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

import 'customer.dart';
import 'invoice.dart';

StripeSubscriptions stripeSubscriptionsFromJson(String str) =>
    StripeSubscriptions.fromJson(json.decode(str));

String stripeSubscriptionsToJson(StripeSubscriptions data) =>
    json.encode(data.toJson());

class StripeSubscriptions {
  StripeSubscriptions({
    @required this.object,
    @required this.data,
    @required this.hasMore,
    @required this.url,
  });

  final String object;
  final List<SubscriptionDatum> data;
  final bool hasMore;
  final String url;

  factory StripeSubscriptions.fromJson(Map<String, dynamic> json) =>
      StripeSubscriptions(
        object: json["object"],
        data: List<SubscriptionDatum>.from(
            json["data"].map((x) => SubscriptionDatum.fromJson(x))),
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

class SubscriptionDatum {
  SubscriptionDatum({
    @required this.id,
    @required this.object,
    @required this.application,
    @required this.applicationFeePercent,
    @required this.automaticTax,
    @required this.billingCycleAnchor,
    @required this.billingThresholds,
    @required this.cancelAt,
    @required this.cancelAtPeriodEnd,
    @required this.canceledAt,
    @required this.collectionMethod,
    @required this.created,
    @required this.currency,
    @required this.currentPeriodEnd,
    @required this.currentPeriodStart,
    @required this.customer,
    @required this.daysUntilDue,
    @required this.defaultPaymentMethod,
    @required this.defaultSource,
    @required this.defaultTaxRates,
    @required this.description,
    @required this.discount,
    @required this.endedAt,
    @required this.items,
    @required this.latestInvoice,
    @required this.livemode,
    @required this.metadata,
    @required this.nextPendingInvoiceItemInvoice,
    @required this.onBehalfOf,
    // @required this.pauseCollection,
    @required this.paymentSettings,
    @required this.pendingInvoiceItemInterval,
    @required this.pendingSetupIntent,
    @required this.pendingUpdate,
    @required this.plan,
    @required this.quantity,
    @required this.schedule,
    @required this.startDate,
    @required this.status,
    @required this.testClock,
    @required this.transferData,
    @required this.trialEnd,
    @required this.trialStart,
  });

  final String id;
  final String object;
  final dynamic application;
  final dynamic applicationFeePercent;
  final SubscriptionAutomaticTax automaticTax;
  final int billingCycleAnchor;
  final dynamic billingThresholds;
  final dynamic cancelAt;
  final bool cancelAtPeriodEnd;
  final int canceledAt;
  final String collectionMethod;
  final int created;
  final String currency;
  final int currentPeriodEnd;
  final int currentPeriodStart;
  final StripeCustomer customer;
  final dynamic daysUntilDue;
  final String defaultPaymentMethod;
  final dynamic defaultSource;
  final List<dynamic> defaultTaxRates;
  final dynamic description;
  final dynamic discount;
  final int endedAt;
  final SubscriptionItems items;
  final InvoiceDatum latestInvoice;
  final bool livemode;
  final SubscriptionMetadata metadata;
  final dynamic nextPendingInvoiceItemInvoice;
  final dynamic onBehalfOf;
  // final PauseCollection pauseCollection;
  final SubscriptionPaymentSettings paymentSettings;
  final dynamic pendingInvoiceItemInterval;
  final dynamic pendingSetupIntent;
  final dynamic pendingUpdate;
  final SubscriptionPlan plan;
  final int quantity;
  final dynamic schedule;
  final int startDate;
  final String status;
  final dynamic testClock;
  final dynamic transferData;
  final dynamic trialEnd;
  final dynamic trialStart;

  factory SubscriptionDatum.fromJson(Map<String, dynamic> json) =>
      SubscriptionDatum(
        id: json["id"],
        object: json["object"],
        application: json["application"],
        applicationFeePercent: json["application_fee_percent"],
        automaticTax: SubscriptionAutomaticTax.fromJson(json["automatic_tax"]),
        billingCycleAnchor: json["billing_cycle_anchor"],
        billingThresholds: json["billing_thresholds"],
        cancelAt: json["cancel_at"],
        cancelAtPeriodEnd: json["cancel_at_period_end"],
        canceledAt: json["canceled_at"],
        collectionMethod: json["collection_method"],
        created: json["created"],
        currency: json["currency"],
        currentPeriodEnd: json["current_period_end"],
        currentPeriodStart: json["current_period_start"],
        customer: json["customer"],
        daysUntilDue: json["days_until_due"],
        defaultPaymentMethod: json["default_payment_method"],
        defaultSource: json["default_source"],
        defaultTaxRates:
            List<dynamic>.from(json["default_tax_rates"].map((x) => x)),
        description: json["description"],
        discount: json["discount"],
        endedAt: json["ended_at"],
        items: SubscriptionItems.fromJson(json["items"]),
        latestInvoice: json["latest_invoice"],
        livemode: json["livemode"],
        metadata: SubscriptionMetadata.fromJson(json["metadata"]),
        nextPendingInvoiceItemInvoice:
            json["next_pending_invoice_item_invoice"],
        onBehalfOf: json["on_behalf_of"],
        // pauseCollection: PauseCollection.fromJson(json["pause_collection"]),
        paymentSettings:
            SubscriptionPaymentSettings.fromJson(json["payment_settings"]),
        pendingInvoiceItemInterval: json["pending_invoice_item_interval"],
        pendingSetupIntent: json["pending_setup_intent"],
        pendingUpdate: json["pending_update"],
        plan: SubscriptionPlan.fromJson(json["plan"]),
        quantity: json["quantity"],
        schedule: json["schedule"],
        startDate: json["start_date"],
        status: json["status"],
        testClock: json["test_clock"],
        transferData: json["transfer_data"],
        trialEnd: json["trial_end"],
        trialStart: json["trial_start"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "application": application,
        "application_fee_percent": applicationFeePercent,
        "automatic_tax": automaticTax.toJson(),
        "billing_cycle_anchor": billingCycleAnchor,
        "billing_thresholds": billingThresholds,
        "cancel_at": cancelAt,
        "cancel_at_period_end": cancelAtPeriodEnd,
        "canceled_at": canceledAt,
        "collection_method": collectionMethod,
        "created": created,
        "currency": currency,
        "current_period_end": currentPeriodEnd,
        "current_period_start": currentPeriodStart,
        "customer": customer,
        "days_until_due": daysUntilDue,
        "default_payment_method": defaultPaymentMethod,
        "default_source": defaultSource,
        "default_tax_rates": List<dynamic>.from(defaultTaxRates.map((x) => x)),
        "description": description,
        "discount": discount,
        "ended_at": endedAt,
        "items": items.toJson(),
        "latest_invoice": latestInvoice,
        "livemode": livemode,
        "metadata": metadata.toJson(),
        "next_pending_invoice_item_invoice": nextPendingInvoiceItemInvoice,
        "on_behalf_of": onBehalfOf,
        // "pause_collection": pauseCollection.toJson(),
        "payment_settings": paymentSettings.toJson(),
        "pending_invoice_item_interval": pendingInvoiceItemInterval,
        "pending_setup_intent": pendingSetupIntent,
        "pending_update": pendingUpdate,
        "plan": plan.toJson(),
        "quantity": quantity,
        "schedule": schedule,
        "start_date": startDate,
        "status": status,
        "test_clock": testClock,
        "transfer_data": transferData,
        "trial_end": trialEnd,
        "trial_start": trialStart,
      };
}

class SubscriptionAutomaticTax {
  SubscriptionAutomaticTax({
    @required this.enabled,
  });

  final bool enabled;

  factory SubscriptionAutomaticTax.fromJson(Map<String, dynamic> json) =>
      SubscriptionAutomaticTax(
        enabled: json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
      };
}

class SubscriptionItems {
  SubscriptionItems({
    @required this.object,
    @required this.data,
    @required this.hasMore,
    @required this.totalCount,
    @required this.url,
  });

  final String object;
  final List<SubscriptionItemsDatum> data;
  final bool hasMore;
  final int totalCount;
  final String url;

  factory SubscriptionItems.fromJson(Map<String, dynamic> json) =>
      SubscriptionItems(
        object: json["object"],
        data: List<SubscriptionItemsDatum>.from(
            json["data"].map((x) => SubscriptionItemsDatum.fromJson(x))),
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

class SubscriptionItemsDatum {
  SubscriptionItemsDatum({
    @required this.id,
    @required this.object,
    @required this.billingThresholds,
    @required this.created,
    @required this.metadata,
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
  final SubscriptionMetadata metadata;
  final SubscriptionPlan plan;
  final SubscriptionPrice price;
  final int quantity;
  final String subscription;
  final List<dynamic> taxRates;

  factory SubscriptionItemsDatum.fromJson(Map<String, dynamic> json) =>
      SubscriptionItemsDatum(
        id: json["id"],
        object: json["object"],
        billingThresholds: json["billing_thresholds"],
        created: json["created"],
        metadata: SubscriptionMetadata.fromJson(json["metadata"]),
        plan: SubscriptionPlan.fromJson(json["plan"]),
        price: SubscriptionPrice.fromJson(json["price"]),
        quantity: json["quantity"],
        subscription: json["subscription"],
        taxRates: List<dynamic>.from(json["tax_rates"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "billing_thresholds": billingThresholds,
        "created": created,
        "metadata": metadata.toJson(),
        "plan": plan.toJson(),
        "price": price.toJson(),
        "quantity": quantity,
        "subscription": subscription,
        "tax_rates": List<dynamic>.from(taxRates.map((x) => x)),
      };
}

class SubscriptionMetadata {
  SubscriptionMetadata();

  factory SubscriptionMetadata.fromJson(Map<String, dynamic> json) =>
      SubscriptionMetadata();

  Map<String, dynamic> toJson() => {};
}

class SubscriptionPlan {
  SubscriptionPlan({
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
    @required this.metadata,
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
  final SubscriptionMetadata metadata;
  final dynamic nickname;
  final String product;
  final dynamic tiersMode;
  final dynamic transformUsage;
  final dynamic trialPeriodDays;
  final String usageType;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
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
        metadata: SubscriptionMetadata.fromJson(json["metadata"]),
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
        "metadata": metadata.toJson(),
        "nickname": nickname,
        "product": product,
        "tiers_mode": tiersMode,
        "transform_usage": transformUsage,
        "trial_period_days": trialPeriodDays,
        "usage_type": usageType,
      };
}

class SubscriptionPrice {
  SubscriptionPrice({
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
  // final PriceMetadata metadata;
  final dynamic nickname;
  final String product;
  final RecurringSubscriptions recurring;
  final String taxBehavior;
  final dynamic tiersMode;
  final dynamic transformQuantity;
  final String type;
  final int unitAmount;
  final String unitAmountDecimal;

  factory SubscriptionPrice.fromJson(Map<String, dynamic> json) =>
      SubscriptionPrice(
        id: json["id"],
        object: json["object"],
        active: json["active"],
        billingScheme: json["billing_scheme"],
        created: json["created"],
        currency: json["currency"],
        customUnitAmount: json["custom_unit_amount"],
        livemode: json["livemode"],
        lookupKey: json["lookup_key"],
        // metadata: PriceMetadata.fromJson(json["metadata"]),
        nickname: json["nickname"],
        product: json["product"],
        recurring: RecurringSubscriptions.fromJson(json["recurring"]),
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

class RecurringSubscriptions {
  RecurringSubscriptions({
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

  factory RecurringSubscriptions.fromJson(Map<String, dynamic> json) =>
      RecurringSubscriptions(
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

// class PauseCollection {
//   PauseCollection({
//     @required this.behavior,
//     @required this.resumesAt,
//   });

//   final String behavior;
//   final dynamic resumesAt;

//   factory PauseCollection.fromJson(Map<String, dynamic> json) => PauseCollection(
//     behavior: json["behavior"],
//     resumesAt: json["resumes_at"],
//   );

//   Map<String, dynamic> toJson() => {
//     "behavior": behavior,
//     "resumes_at": resumesAt,
//   };
// }

class SubscriptionPaymentSettings {
  SubscriptionPaymentSettings({
    @required this.paymentMethodOptions,
    @required this.paymentMethodTypes,
    @required this.saveDefaultPaymentMethod,
  });

  final dynamic paymentMethodOptions;
  final dynamic paymentMethodTypes;
  final String saveDefaultPaymentMethod;

  factory SubscriptionPaymentSettings.fromJson(Map<String, dynamic> json) =>
      SubscriptionPaymentSettings(
        paymentMethodOptions: json["payment_method_options"],
        paymentMethodTypes: json["payment_method_types"],
        saveDefaultPaymentMethod: json["save_default_payment_method"],
      );

  Map<String, dynamic> toJson() => {
        "payment_method_options": paymentMethodOptions,
        "payment_method_types": paymentMethodTypes,
        "save_default_payment_method": saveDefaultPaymentMethod,
      };
}
