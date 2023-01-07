

// To parse this JSON data, do
//
//     final stripeProducts = stripeProductsFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

StripeProductsList stripeProductsListFromJson(String str) =>
    StripeProductsList.fromJson(json.decode(str));

String stripeProductsListToJson(StripeProductsList data) => json.encode(data.toJson());

class StripeProductsList {
  StripeProductsList({
    @required this.object,
    @required this.products,
    @required this.hasMore,
    @required this.url,
  });

  final String object;
  final List<StripeProduct> products;
  final bool hasMore;
  final String url;

  factory StripeProductsList.fromJson(Map<String, dynamic> json) => StripeProductsList(
    object: json["object"],
    products: List<StripeProduct>.from(json["data"].map((x) => StripeProduct.fromJson(x))),
    hasMore: json["has_more"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "object": object,
    "data": List<dynamic>.from(products.map((x) => x.toJson())),
    "has_more": hasMore,
    "url": url,
  };
}

// To parse this JSON data, do
//
//     final stripeProduct = stripeProductFromJson(jsonString);

StripeProduct stripeProductFromJson(String str) => StripeProduct.fromJson(json.decode(str));

String stripeProductToJson(StripeProduct data) => json.encode(data.toJson());

class StripeProduct {
  StripeProduct({
    @required this.id,
    @required this.object,
    @required this.active,
    @required this.attributes,
    @required this.created,
    @required this.defaultPrice,
    @required this.description,
    @required this.images,
    @required this.livemode,
    @required this.metadata,
    @required this.name,
    @required this.packageDimensions,
    @required this.shippable,
    @required this.statementDescriptor,
    @required this.taxCode,
    @required this.type,
    @required this.unitLabel,
    @required this.updated,
    @required this.url,
  });

  final String id;
  final String object;
  final bool active;
  final List<dynamic> attributes;
  final int created;
  final String defaultPrice;
  final String description;
  final List<String> images;
  final bool livemode;
  final StripeProductMetadata metadata;
  final String name;
  final dynamic packageDimensions;
  final dynamic shippable;
  final String statementDescriptor;
  final dynamic taxCode;
  final String type;
  final String unitLabel;
  final int updated;
  final dynamic url;

  factory StripeProduct.fromJson(Map<String, dynamic> json) => StripeProduct(
    id: json["id"],
    object: json["object"],
    active: json["active"],
    attributes: List<dynamic>.from(json["attributes"].map((x) => x)),
    created: json["created"],
    defaultPrice: json["default_price"],
    description: json["description"],
    images: List<String>.from(json["images"].map((x) => x)),
    livemode: json["livemode"],
    metadata: StripeProductMetadata.fromJson(json["metadata"]),
    name: json["name"],
    packageDimensions: json["package_dimensions"],
    shippable: json["shippable"],
    statementDescriptor: json["statement_descriptor"],
    taxCode: json["tax_code"],
    type: json["type"],
    unitLabel: json["unit_label"],
    updated: json["updated"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "object": object,
    "active": active,
    "attributes": List<dynamic>.from(attributes.map((x) => x)),
    "created": created,
    "default_price": defaultPrice,
    "description": description,
    "images": List<dynamic>.from(images.map((x) => x)),
    "livemode": livemode,
    "metadata": metadata.toJson(),
    "name": name,
    "package_dimensions": packageDimensions,
    "shippable": shippable,
    "statement_descriptor": statementDescriptor,
    "tax_code": taxCode,
    "type": type,
    "unit_label": unitLabel,
    "updated": updated,
    "url": url,
  };
}

class StripeProductMetadata {
  StripeProductMetadata({
    @required this.credits,
    @required this.entitlements,
    @required this.frequency,
    @required this.productPrice,
    @required this.productType,
  });

  final String credits;
  final String entitlements;
  final String frequency;
  final String productPrice;
  final String productType;

  factory StripeProductMetadata.fromJson(Map<String, dynamic> json) => StripeProductMetadata(
    credits: json["credits"],
    entitlements: json["entitlements"],
    frequency: json["frequency"],
    productPrice: json["product_price"],
    productType: json["product_type"],
  );

  Map<String, dynamic> toJson() => {
    "credits": credits,
    "entitlements": entitlements,
    "frequency": frequency,
    "product_price": productPrice,
    "product_type": productType,
  };
}