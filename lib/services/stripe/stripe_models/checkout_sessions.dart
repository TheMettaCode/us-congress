// // // To parse this JSON data, do
// // //
// // //     final checkoutSessions = checkoutSessionsFromJson(jsonString);

// import 'package:meta/meta.dart';
// import 'dart:convert';

// import 'customer.dart';
// import 'invoice.dart';
// import 'subscription.dart';

// CheckoutSessions checkoutSessionsFromJson(String str) =>
//     CheckoutSessions.fromJson(json.decode(str));

// String checkoutSessionsToJson(CheckoutSessions data) =>
//     json.encode(data.toJson());

// class CheckoutSessions {
//   CheckoutSessions({
//     @required this.object,
//     @required this.data,
//     @required this.hasMore,
//     @required this.url,
//   });

//   final String object;
//   final List<CheckoutSessionsDatum> data;
//   final bool hasMore;
//   final String url;

//   factory CheckoutSessions.fromJson(Map<String, dynamic> json) =>
//       CheckoutSessions(
//         object: json["object"],
//         data: List<CheckoutSessionsDatum>.from(
//             json["data"].map((x) => CheckoutSessionsDatum.fromJson(x))),
//         hasMore: json["has_more"],
//         url: json["url"],
//       );

//   Map<String, dynamic> toJson() => {
//         "object": object,
//         "data": List<dynamic>.from(data.map((x) => x.toJson())),
//         "has_more": hasMore,
//         "url": url,
//       };
// }

// class CheckoutSessionsDatum {
//   CheckoutSessionsDatum({
//     @required this.id,
//     @required this.object,
//     @required this.afterExpiration,
//     @required this.allowPromotionCodes,
//     @required this.amountSubtotal,
//     @required this.amountTotal,
//     @required this.automaticTax,
//     @required this.billingAddressCollection,
//     @required this.cancelUrl,
//     @required this.clientReferenceId,
//     @required this.consent,
//     @required this.consentCollection,
//     @required this.created,
//     @required this.currency,
//     @required this.customText,
//     @required this.customer,
//     @required this.customerCreation,
//     @required this.customerDetails,
//     @required this.customerEmail,
//     @required this.expiresAt,
//     // @required this.invoice,
//     // @required this.invoiceCreation,
//     @required this.livemode,
//     @required this.locale,
//     @required this.metadata,
//     @required this.mode,
//     @required this.paymentIntent,
//     @required this.paymentLink,
//     @required this.paymentMethodCollection,
//     // @required this.paymentMethodOptions,
//     @required this.paymentMethodTypes,
//     @required this.paymentStatus,
//     // @required this.phoneNumberCollection,
//     @required this.recoveredFrom,
//     @required this.setupIntent,
//     @required this.shippingAddressCollection,
//     @required this.shippingCost,
//     @required this.shippingDetails,
//     @required this.shippingOptions,
//     @required this.status,
//     @required this.submitType,
//     @required this.subscription,
//     @required this.successUrl,
//     @required this.totalDetails,
//     @required this.url,
//   });

//   final String id;
//   final String object;
//   final dynamic afterExpiration;
//   final bool allowPromotionCodes;
//   final int amountSubtotal;
//   final int amountTotal;
//   final AutomaticTax automaticTax;
//   final String billingAddressCollection;
//   final String cancelUrl;
//   final String clientReferenceId;
//   final dynamic consent;
//   final ConsentCollection consentCollection;
//   final int created;
//   final String currency;
//   final CustomText customText;
//   final StripeCustomer customer;
//   final String customerCreation;
//   final CustomerDetails customerDetails;
//   final dynamic customerEmail;
//   final int expiresAt;
//   // final InvoiceDatum invoice;
//   // final InvoiceCreation invoiceCreation;
//   final bool livemode;
//   final String locale;
//   final MetadataFromPaymentLink metadata;
//   final String mode;
//   final dynamic paymentIntent;
//   final String paymentLink;
//   final String paymentMethodCollection;
//   // final PaymentMethodOptions paymentMethodOptions;
//   final List<String> paymentMethodTypes;
//   final String paymentStatus;
//   // final PhoneNumberCollection phoneNumberCollection;
//   final dynamic recoveredFrom;
//   final dynamic setupIntent;
//   final dynamic shippingAddressCollection;
//   final dynamic shippingCost;
//   final dynamic shippingDetails;
//   final List<dynamic> shippingOptions;
//   final String status;
//   final String submitType;
//   final SubscriptionDatum subscription;
//   final String successUrl;
//   final TotalDetails totalDetails;
//   final String url;

//   factory CheckoutSessionsDatum.fromJson(Map<String, dynamic> json) =>
//       CheckoutSessionsDatum(
//         id: json["id"],
//         object: json["object"],
//         afterExpiration: json["after_expiration"],
//         allowPromotionCodes: json["allow_promotion_codes"],
//         amountSubtotal: json["amount_subtotal"],
//         amountTotal: json["amount_total"],
//         automaticTax: AutomaticTax.fromJson(json["automatic_tax"]),
//         billingAddressCollection: json["billing_address_collection"],
//         cancelUrl: json["cancel_url"],
//         clientReferenceId: json["client_reference_id"],
//         consent: json["consent"],
//         consentCollection: json["consent_collection"] == null
//             ? null
//             : ConsentCollection.fromJson(json["consent_collection"]),
//         created: json["created"],
//         currency: json["currency"],
//         customText: CustomText.fromJson(json["custom_text"]),
//         customer: json["customer"] == null
//             ? null
//             : StripeCustomer.fromJson(json["customer"]),
//         customerCreation: json["customer_creation"],
//         customerDetails: json["customer_details"] == null
//             ? null
//             : CustomerDetails.fromJson(json["customer_details"]),
//         customerEmail: json["customer_email"],
//         expiresAt: json["expires_at"],
//         // invoice: json["invoice"] == null
//         //     ? null
//         //     : InvoiceDatum.fromJson(json["invoice"]),
//         // invoiceCreation: json["invoice_creation"] == null
//         //     ? null
//         //     : InvoiceCreation.fromJson(json["invoice_creation"]),
//         livemode: json["livemode"],
//         locale: json["locale"],
//         metadata: MetadataFromPaymentLink.fromJson(json["metadata"]),
//         mode: json["mode"],
//         paymentIntent: json["payment_intent"],
//         paymentLink: json["payment_link"],
//         paymentMethodCollection: json["payment_method_collection"],
//         // paymentMethodOptions: json["payment_method_options"] == null
//         //     ? null
//         //     : PaymentMethodOptions.fromJson(json["payment_method_options"]),
//         paymentMethodTypes:
//             List<String>.from(json["payment_method_types"].map((x) => x)),
//         paymentStatus: json["payment_status"],
//         // phoneNumberCollection:
//         //     PhoneNumberCollection.fromJson(json["phone_number_collection"]),
//         recoveredFrom: json["recovered_from"],
//         setupIntent: json["setup_intent"],
//         shippingAddressCollection: json["shipping_address_collection"],
//         shippingCost: json["shipping_cost"],
//         shippingDetails: json["shipping_details"],
//         shippingOptions:
//             List<dynamic>.from(json["shipping_options"].map((x) => x)),
//         status: json["status"],
//         submitType: json["submit_type"],
//         subscription: json["subscription"] == null
//             ? null
//             : SubscriptionDatum.fromJson(json["subscription"]),
//         successUrl: json["success_url"],
//         totalDetails: TotalDetails.fromJson(json["total_details"]),
//         url: json["url"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "object": object,
//         "after_expiration": afterExpiration,
//         "allow_promotion_codes": allowPromotionCodes,
//         "amount_subtotal": amountSubtotal,
//         "amount_total": amountTotal,
//         "automatic_tax": automaticTax.toJson(),
//         "billing_address_collection": billingAddressCollection,
//         "cancel_url": cancelUrl,
//         "client_reference_id": clientReferenceId,
//         "consent": consent,
//         "consent_collection":
//             consentCollection == null ? null : consentCollection.toJson(),
//         "created": created,
//         "currency": currency,
//         "custom_text": customText.toJson(),
//         "customer": customer == null ? null : customer.toJson(),
//         "customer_creation": customerCreation,
//         "customer_details":
//             customerDetails == null ? null : customerDetails.toJson(),
//         "customer_email": customerEmail,
//         "expires_at": expiresAt,
//         // "invoice": invoice == null ? null : invoice.toJson(),
//         // "invoice_creation": invoiceCreation == null ? null : invoiceCreation.toJson(),
//         "livemode": livemode,
//         "locale": locale,
//         "metadata": metadata.toJson(),
//         "mode": mode,
//         "payment_intent": paymentIntent,
//         "payment_link": paymentLink,
//         "payment_method_collection": paymentMethodCollection,
//         // "payment_method_options":
//         //     paymentMethodOptions == null ? null : paymentMethodOptions.toJson(),
//         "payment_method_types":
//             List<dynamic>.from(paymentMethodTypes.map((x) => x)),
//         "payment_status": paymentStatus,
//         // "phone_number_collection": phoneNumberCollection.toJson(),
//         "recovered_from": recoveredFrom,
//         "setup_intent": setupIntent,
//         "shipping_address_collection": shippingAddressCollection,
//         "shipping_cost": shippingCost,
//         "shipping_details": shippingDetails,
//         "shipping_options": List<dynamic>.from(shippingOptions.map((x) => x)),
//         "status": status,
//         "submit_type": submitType,
//         "subscription": subscription == null ? null : subscription.toJson(),
//         "success_url": successUrl,
//         "total_details": totalDetails.toJson(),
//         "url": url,
//       };
// }

// class AutomaticTax {
//   AutomaticTax({
//     @required this.enabled,
//     @required this.status,
//   });

//   final bool enabled;
//   final dynamic status;

//   factory AutomaticTax.fromJson(Map<String, dynamic> json) => AutomaticTax(
//         enabled: json["enabled"],
//         status: json["status"],
//       );

//   Map<String, dynamic> toJson() => {
//         "enabled": enabled,
//         "status": status,
//       };
// }

// class ConsentCollection {
//   ConsentCollection({
//     @required this.promotions,
//     @required this.termsOfService,
//   });

//   final String promotions;
//   final String termsOfService;

//   factory ConsentCollection.fromJson(Map<String, dynamic> json) =>
//       ConsentCollection(
//         promotions: json["promotions"],
//         termsOfService: json["terms_of_service"],
//       );

//   Map<String, dynamic> toJson() => {
//         "promotions": promotions,
//         "terms_of_service": termsOfService,
//       };
// }

// class CustomText {
//   CustomText({
//     @required this.shippingAddress,
//     @required this.submit,
//   });

//   final dynamic shippingAddress;
//   final dynamic submit;

//   factory CustomText.fromJson(Map<String, dynamic> json) => CustomText(
//         shippingAddress: json["shipping_address"],
//         submit: json["submit"],
//       );

//   Map<String, dynamic> toJson() => {
//         "shipping_address": shippingAddress,
//         "submit": submit,
//       };
// }

// class CustomerDetails {
//   CustomerDetails({
//     @required this.address,
//     @required this.email,
//     @required this.name,
//     @required this.phone,
//     @required this.taxExempt,
//     @required this.taxIds,
//   });

//   final Address address;
//   final String email;
//   final String name;
//   final dynamic phone;
//   final String taxExempt;
//   final List<dynamic> taxIds;

//   factory CustomerDetails.fromJson(Map<String, dynamic> json) =>
//       CustomerDetails(
//         address: Address.fromJson(json["address"]),
//         email: json["email"],
//         name: json["name"],
//         phone: json["phone"],
//         taxExempt: json["tax_exempt"],
//         taxIds: List<dynamic>.from(json["tax_ids"].map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "address": address.toJson(),
//         "email": email,
//         "name": name,
//         "phone": phone,
//         "tax_exempt": taxExempt,
//         "tax_ids": List<dynamic>.from(taxIds.map((x) => x)),
//       };
// }

// class Address {
//   Address({
//     @required this.city,
//     @required this.country,
//     @required this.line1,
//     @required this.line2,
//     @required this.postalCode,
//     @required this.state,
//   });

//   final dynamic city;
//   final String country;
//   final dynamic line1;
//   final dynamic line2;
//   final String postalCode;
//   final dynamic state;

//   factory Address.fromJson(Map<String, dynamic> json) => Address(
//         city: json["city"],
//         country: json["country"],
//         line1: json["line1"],
//         line2: json["line2"],
//         postalCode: json["postal_code"],
//         state: json["state"],
//       );

//   Map<String, dynamic> toJson() => {
//         "city": city,
//         "country": country,
//         "line1": line1,
//         "line2": line2,
//         "postal_code": postalCode,
//         "state": state,
//       };
// }

// // class InvoiceCreation {
// //   InvoiceCreation({
// //     @required this.enabled,
// //     @required this.invoiceData,
// //   });

// //   final bool enabled;
// //   final InvoiceData invoiceData;

// //   factory InvoiceCreation.fromJson(Map<String, dynamic> json) =>
// //       InvoiceCreation(
// //         enabled: json["enabled"],
// //         invoiceData: InvoiceData.fromJson(json["invoice_data"]),
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "enabled": enabled,
// //         "invoice_data": invoiceData.toJson(),
// //       };
// // }

// // class InvoiceData {
// //   InvoiceData({
// //     @required this.accountTaxIds,
// //     @required this.customFields,
// //     @required this.description,
// //     @required this.footer,
// //     @required this.metadata,
// //     @required this.renderingOptions,
// //   });

// //   final dynamic accountTaxIds;
// //   final dynamic customFields;
// //   final dynamic description;
// //   final dynamic footer;
// //   final PaymentMethodOptions metadata;
// //   final dynamic renderingOptions;

// //   factory InvoiceData.fromJson(Map<String, dynamic> json) => InvoiceData(
// //         accountTaxIds: json["account_tax_ids"],
// //         customFields: json["custom_fields"],
// //         description: json["description"],
// //         footer: json["footer"],
// //         metadata: PaymentMethodOptions.fromJson(json["metadata"]),
// //         renderingOptions: json["rendering_options"],
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "account_tax_ids": accountTaxIds,
// //         "custom_fields": customFields,
// //         "description": description,
// //         "footer": footer,
// //         "metadata": metadata.toJson(),
// //         "rendering_options": renderingOptions,
// //       };
// // }

// // class PaymentMethodOptions {
// //   PaymentMethodOptions();

// //   factory PaymentMethodOptions.fromJson(Map<String, dynamic> json) =>
// //       PaymentMethodOptions();

// //   Map<String, dynamic> toJson() => {};
// // }

// class MetadataFromPaymentLink {
//   MetadataFromPaymentLink({
//     @required this.appUserId,
//     @required this.appVersion,
//     @required this.stripeCustomerId,
//   });

//   final String appUserId;
//   final String appVersion;
//   final String stripeCustomerId;

//   factory MetadataFromPaymentLink.fromJson(Map<String, dynamic> json) =>
//       MetadataFromPaymentLink(
//         appUserId: json["app_user_id"] ?? "",
//         appVersion: json["app_version"] ?? "",
//         stripeCustomerId: json["stripe_customer_id"] ?? "",
//       );

//   Map<String, dynamic> toJson() => {
//         "app_user_id": appUserId,
//         "app_version": appVersion,
//         "stripe_customer_id": stripeCustomerId,
//       };
// }

// // class PhoneNumberCollection {
// //   PhoneNumberCollection({
// //     @required this.enabled,
// //   });

// //   final bool enabled;

// //   factory PhoneNumberCollection.fromJson(Map<String, dynamic> json) =>
// //       PhoneNumberCollection(
// //         enabled: json["enabled"],
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "enabled": enabled,
// //       };
// // }

// class TotalDetails {
//   TotalDetails({
//     @required this.amountDiscount,
//     @required this.amountShipping,
//     @required this.amountTax,
//   });

//   final int amountDiscount;
//   final int amountShipping;
//   final int amountTax;

//   factory TotalDetails.fromJson(Map<String, dynamic> json) => TotalDetails(
//         amountDiscount: json["amount_discount"],
//         amountShipping: json["amount_shipping"],
//         amountTax: json["amount_tax"],
//       );

//   Map<String, dynamic> toJson() => {
//         "amount_discount": amountDiscount,
//         "amount_shipping": amountShipping,
//         "amount_tax": amountTax,
//       };
// }

// To parse this JSON data, do
//
//     final checkoutSessions = checkoutSessionsFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CheckoutSessions checkoutSessionsFromJson(String str) =>
    CheckoutSessions.fromJson(json.decode(str));

String checkoutSessionsToJson(CheckoutSessions data) =>
    json.encode(data.toJson());

class CheckoutSessions {
  CheckoutSessions({
    @required this.object,
    @required this.data,
    @required this.hasMore,
    @required this.url,
  });

  final String object;
  final List<CheckoutSessionsDatum> data;
  final bool hasMore;
  final String url;

  factory CheckoutSessions.fromJson(Map<String, dynamic> json) =>
      CheckoutSessions(
        object: json["object"],
        data: List<CheckoutSessionsDatum>.from(
            json["data"].map((x) => CheckoutSessionsDatum.fromJson(x))),
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

class CheckoutSessionsDatum {
  CheckoutSessionsDatum({
    @required this.id,
    @required this.object,
    @required this.afterExpiration,
    @required this.allowPromotionCodes,
    @required this.amountSubtotal,
    @required this.amountTotal,
    @required this.automaticTax,
    @required this.billingAddressCollection,
    @required this.cancelUrl,
    @required this.clientReferenceId,
    @required this.consent,
    @required this.consentCollection,
    @required this.created,
    @required this.currency,
    @required this.customText,
    @required this.customer,
    @required this.customerCreation,
    @required this.customerDetails,
    @required this.customerEmail,
    @required this.expiresAt,
    @required this.invoice,
    @required this.invoiceCreation,
    @required this.livemode,
    @required this.locale,
    @required this.metadata,
    @required this.mode,
    @required this.paymentIntent,
    @required this.paymentLink,
    @required this.paymentMethodCollection,
    @required this.paymentMethodOptions,
    @required this.paymentMethodTypes,
    @required this.paymentStatus,
    @required this.phoneNumberCollection,
    @required this.recoveredFrom,
    @required this.setupIntent,
    @required this.shippingAddressCollection,
    @required this.shippingCost,
    @required this.shippingDetails,
    @required this.shippingOptions,
    @required this.status,
    @required this.submitType,
    @required this.subscription,
    @required this.successUrl,
    @required this.totalDetails,
    @required this.url,
  });

  final String id;
  final String object;
  final dynamic afterExpiration;
  final bool allowPromotionCodes;
  final int amountSubtotal;
  final int amountTotal;
  final AutomaticTax automaticTax;
  final String billingAddressCollection;
  final String cancelUrl;
  final String clientReferenceId;
  final dynamic consent;
  final dynamic consentCollection;
  final int created;
  final String currency;
  final CustomText customText;
  final String customer;
  final String customerCreation;
  final CustomerDetails customerDetails;
  final dynamic customerEmail;
  final int expiresAt;
  final String invoice;
  final InvoiceCreation invoiceCreation;
  final bool livemode;
  final String locale;
  final MetadataFromPaymentLink metadata;
  final String mode;
  final String paymentIntent;
  final String paymentLink;
  final String paymentMethodCollection;
  final PaymentMethodOptions paymentMethodOptions;
  final List<String> paymentMethodTypes;
  final String paymentStatus;
  final PhoneNumberCollection phoneNumberCollection;
  final dynamic recoveredFrom;
  final dynamic setupIntent;
  final dynamic shippingAddressCollection;
  final dynamic shippingCost;
  final dynamic shippingDetails;
  final List<dynamic> shippingOptions;
  final String status;
  final String submitType;
  final String subscription;
  final String successUrl;
  final TotalDetails totalDetails;
  final String url;

  factory CheckoutSessionsDatum.fromJson(Map<String, dynamic> json) =>
      CheckoutSessionsDatum(
        id: json["id"],
        object: json["object"],
        afterExpiration: json["after_expiration"],
        allowPromotionCodes: json["allow_promotion_codes"],
        amountSubtotal: json["amount_subtotal"],
        amountTotal: json["amount_total"],
        automaticTax: AutomaticTax.fromJson(json["automatic_tax"]),
        billingAddressCollection: json["billing_address_collection"],
        cancelUrl: json["cancel_url"],
        clientReferenceId: json["client_reference_id"],
        consent: json["consent"],
        consentCollection: json["consent_collection"],
        created: json["created"],
        currency: json["currency"],
        customText: CustomText.fromJson(json["custom_text"]),
        customer: json["customer"] == null ? null : json["customer"],
        customerCreation: json["customer_creation"],
        customerDetails: json["customer_details"] == null
            ? null
            : CustomerDetails.fromJson(json["customer_details"]),
        customerEmail: json["customer_email"],
        expiresAt: json["expires_at"],
        invoice: json["invoice"] == null ? null : json["invoice"],
        invoiceCreation: json["invoice_creation"] == null
            ? null
            : InvoiceCreation.fromJson(json["invoice_creation"]),
        livemode: json["livemode"],
        locale: json["locale"],
        metadata: MetadataFromPaymentLink.fromJson(json["metadata"]),
        mode: json["mode"],
        paymentIntent:
            json["payment_intent"] == null ? null : json["payment_intent"],
        paymentLink: json["payment_link"],
        paymentMethodCollection: json["payment_method_collection"],
        paymentMethodOptions: json["payment_method_options"] == null
            ? null
            : PaymentMethodOptions.fromJson(json["payment_method_options"]),
        paymentMethodTypes:
            List<String>.from(json["payment_method_types"].map((x) => x)),
        paymentStatus: json["payment_status"],
        phoneNumberCollection:
            PhoneNumberCollection.fromJson(json["phone_number_collection"]),
        recoveredFrom: json["recovered_from"],
        setupIntent: json["setup_intent"],
        shippingAddressCollection: json["shipping_address_collection"],
        shippingCost: json["shipping_cost"],
        shippingDetails: json["shipping_details"],
        shippingOptions:
            List<dynamic>.from(json["shipping_options"].map((x) => x)),
        status: json["status"],
        submitType: json["submit_type"],
        subscription:
            json["subscription"] == null ? null : json["subscription"],
        successUrl: json["success_url"],
        // totalDetails: TotalDetails.fromJson(json["total_details"]),
        url: json["url"] == null ? null : json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "after_expiration": afterExpiration,
        "allow_promotion_codes": allowPromotionCodes,
        "amount_subtotal": amountSubtotal,
        "amount_total": amountTotal,
        "automatic_tax": automaticTax.toJson(),
        "billing_address_collection": billingAddressCollection,
        "cancel_url": cancelUrl,
        "client_reference_id": clientReferenceId,
        "consent": consent,
        "consent_collection": consentCollection,
        "created": created,
        "currency": currency,
        "custom_text": customText.toJson(),
        "customer": customer == null ? null : customer,
        "customer_creation": customerCreation,
        "customer_details":
            customerDetails == null ? null : customerDetails.toJson(),
        "customer_email": customerEmail,
        "expires_at": expiresAt,
        "invoice": invoice == null ? null : invoice,
        "invoice_creation":
            invoiceCreation == null ? null : invoiceCreation.toJson(),
        "livemode": livemode,
        "locale": locale,
        "metadata": metadata.toJson(),
        "mode": mode,
        "payment_intent": paymentIntent == null ? null : paymentIntent,
        "payment_link": paymentLink,
        "payment_method_collection": paymentMethodCollection,
        "payment_method_options":
            paymentMethodOptions == null ? null : paymentMethodOptions.toJson(),
        "payment_method_types":
            List<dynamic>.from(paymentMethodTypes.map((x) => x)),
        "payment_status": paymentStatus,
        "phone_number_collection": phoneNumberCollection.toJson(),
        "recovered_from": recoveredFrom,
        "setup_intent": setupIntent,
        "shipping_address_collection": shippingAddressCollection,
        "shipping_cost": shippingCost,
        "shipping_details": shippingDetails,
        "shipping_options": List<dynamic>.from(shippingOptions.map((x) => x)),
        "status": status,
        "submit_type": submitType,
        "subscription": subscription == null ? null : subscription,
        "success_url": successUrl,
        // "total_details": totalDetails.toJson(),
        "url": url == null ? null : url,
      };
}

class AutomaticTax {
  AutomaticTax({
    @required this.enabled,
    @required this.status,
  });

  final bool enabled;
  final dynamic status;

  factory AutomaticTax.fromJson(Map<String, dynamic> json) => AutomaticTax(
        enabled: json["enabled"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
        "status": status,
      };
}

class CustomText {
  CustomText({
    @required this.shippingAddress,
    @required this.submit,
  });

  final dynamic shippingAddress;
  final dynamic submit;

  factory CustomText.fromJson(Map<String, dynamic> json) => CustomText(
        shippingAddress: json["shipping_address"],
        submit: json["submit"],
      );

  Map<String, dynamic> toJson() => {
        "shipping_address": shippingAddress,
        "submit": submit,
      };
}

class CustomerDetails {
  CustomerDetails({
    @required this.address,
    @required this.email,
    @required this.name,
    @required this.phone,
    @required this.taxExempt,
    @required this.taxIds,
  });

  final Address address;
  final String email;
  final String name;
  final dynamic phone;
  final String taxExempt;
  final List<dynamic> taxIds;

  factory CustomerDetails.fromJson(Map<String, dynamic> json) =>
      CustomerDetails(
        address: Address.fromJson(json["address"]),
        email: json["email"],
        name: json["name"],
        phone: json["phone"],
        taxExempt: json["tax_exempt"],
        taxIds: List<dynamic>.from(json["tax_ids"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "address": address.toJson(),
        "email": email,
        "name": name,
        "phone": phone,
        "tax_exempt": taxExempt,
        "tax_ids": List<dynamic>.from(taxIds.map((x) => x)),
      };
}

class Address {
  Address({
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

  factory Address.fromJson(Map<String, dynamic> json) => Address(
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

class InvoiceCreation {
  InvoiceCreation({
    @required this.enabled,
    @required this.invoiceData,
  });

  final bool enabled;
  final InvoiceData invoiceData;

  factory InvoiceCreation.fromJson(Map<String, dynamic> json) =>
      InvoiceCreation(
        enabled: json["enabled"],
        invoiceData: InvoiceData.fromJson(json["invoice_data"]),
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
        "invoice_data": invoiceData.toJson(),
      };
}

class InvoiceData {
  InvoiceData({
    @required this.accountTaxIds,
    @required this.customFields,
    @required this.description,
    @required this.footer,
    @required this.metadata,
    @required this.renderingOptions,
  });

  final dynamic accountTaxIds;
  final dynamic customFields;
  final dynamic description;
  final dynamic footer;
  final PaymentMethodOptions metadata;
  final dynamic renderingOptions;

  factory InvoiceData.fromJson(Map<String, dynamic> json) => InvoiceData(
        accountTaxIds: json["account_tax_ids"],
        customFields: json["custom_fields"],
        description: json["description"],
        footer: json["footer"],
        metadata: PaymentMethodOptions.fromJson(json["metadata"]),
        renderingOptions: json["rendering_options"],
      );

  Map<String, dynamic> toJson() => {
        "account_tax_ids": accountTaxIds,
        "custom_fields": customFields,
        "description": description,
        "footer": footer,
        "metadata": metadata.toJson(),
        "rendering_options": renderingOptions,
      };
}

class PaymentMethodOptions {
  PaymentMethodOptions();

  factory PaymentMethodOptions.fromJson(Map<String, dynamic> json) =>
      PaymentMethodOptions();

  Map<String, dynamic> toJson() => {};
}

class MetadataFromPaymentLink {
  MetadataFromPaymentLink({
    @required this.appUserId,
    @required this.appVersion,
    @required this.stripeCustomerId,
  });

  final String appUserId;
  final String appVersion;
  final String stripeCustomerId;

  factory MetadataFromPaymentLink.fromJson(Map<String, dynamic> json) =>
      MetadataFromPaymentLink(
        appUserId: json["app_user_id"],
        appVersion: json["app_version"],
        stripeCustomerId: json["stripe_customer_id"] == null
            ? null
            : json["stripe_customer_id"],
      );

  Map<String, dynamic> toJson() => {
        "app_user_id": appUserId,
        "app_version": appVersion,
        "stripe_customer_id":
            stripeCustomerId == null ? null : stripeCustomerId,
      };
}

class PhoneNumberCollection {
  PhoneNumberCollection({
    @required this.enabled,
  });

  final bool enabled;

  factory PhoneNumberCollection.fromJson(Map<String, dynamic> json) =>
      PhoneNumberCollection(
        enabled: json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
      };
}

class TotalDetails {
  TotalDetails({
    @required this.amountDiscount,
    @required this.amountShipping,
    @required this.amountTax,
  });

  final int amountDiscount;
  final int amountShipping;
  final int amountTax;

  factory TotalDetails.fromJson(Map<String, dynamic> json) => TotalDetails(
        amountDiscount: json["amount_discount"],
        amountShipping: json["amount_shipping"],
        amountTax: json["amount_tax"],
      );

  Map<String, dynamic> toJson() => {
        "amount_discount": amountDiscount,
        "amount_shipping": amountShipping,
        "amount_tax": amountTax,
      };
}
