import 'package:meta/meta.dart';
import 'dart:convert';

EcwidStore ecwidStoreFromJson(String str) =>
    EcwidStore.fromJson(json.decode(str));

String ecwidStoreToJson(EcwidStore data) => json.encode(data.toJson());

class EcwidStore {
  EcwidStore({
    @required this.total,
    @required this.count,
    @required this.offset,
    @required this.limit,
    @required this.items,
  });

  final int total;
  final int count;
  final int offset;
  final int limit;
  final List<EcwidStoreItem> items;

  factory EcwidStore.fromJson(Map<String, dynamic> json) => EcwidStore(
        total: json["total"],
        count: json["count"],
        offset: json["offset"],
        limit: json["limit"],
        items: json["items"] == null
            ? null
            : List<EcwidStoreItem>.from(
                json["items"].map((x) => EcwidStoreItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "count": count,
        "offset": offset,
        "limit": limit,
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class EcwidStoreItem {
  EcwidStoreItem({
    @required this.id,
    @required this.sku,
    @required this.thumbnailUrl,
    @required this.unlimited,
    @required this.inStock,
    @required this.name,
    @required this.price,
    @required this.priceInProductList,
    @required this.defaultDisplayedPrice,
    @required this.defaultDisplayedPriceFormatted,
    @required this.tax,
    @required this.compareToPrice,
    @required this.compareToPriceFormatted,
    @required this.compareToPriceDiscount,
    @required this.compareToPriceDiscountFormatted,
    @required this.compareToPriceDiscountPercent,
    @required this.compareToPriceDiscountPercentFormatted,
    @required this.isShippingRequired,
    @required this.weight,
    @required this.url,
    @required this.created,
    @required this.updated,
    @required this.createTimestamp,
    @required this.updateTimestamp,
    @required this.productClassId,
    @required this.enabled,
    @required this.options,
    @required this.fixedShippingRateOnly,
    @required this.fixedShippingRate,
    @required this.shipping,
    @required this.defaultCombinationId,
    @required this.imageUrl,
    @required this.smallThumbnailUrl,
    @required this.hdThumbnailUrl,
    @required this.originalImageUrl,
    @required this.originalImage,
    @required this.borderInfo,
    @required this.description,
    @required this.galleryImages,
    @required this.media,
    @required this.categoryIds,
    @required this.categories,
    @required this.defaultCategoryId,
    @required this.seoTitle,
    @required this.seoDescription,
    @required this.favorites,
    @required this.attributes,
    @required this.relatedProducts,
    @required this.combinations,
    @required this.volume,
    @required this.isSampleProduct,
    @required this.googleItemCondition,
    @required this.isGiftCard,
    @required this.discountsAllowed,
    @required this.nameYourPriceEnabled,
    @required this.showOnFrontpage,
  });

  final int id;
  final String sku;
  final String thumbnailUrl;
  final bool unlimited;
  final bool inStock;
  final String name;
  final double price;
  final double priceInProductList;
  final double defaultDisplayedPrice;
  final String defaultDisplayedPriceFormatted;
  final Tax tax;
  final int compareToPrice;
  final String compareToPriceFormatted;
  final int compareToPriceDiscount;
  final String compareToPriceDiscountFormatted;
  final int compareToPriceDiscountPercent;
  final String compareToPriceDiscountPercentFormatted;
  final bool isShippingRequired;
  final double weight;
  final String url;
  final String created;
  final String updated;
  final int createTimestamp;
  final int updateTimestamp;
  final int productClassId;
  final bool enabled;
  final List<Option> options;
  final bool fixedShippingRateOnly;
  final int fixedShippingRate;
  final Shipping shipping;
  final int defaultCombinationId;
  final String imageUrl;
  final String smallThumbnailUrl;
  final String hdThumbnailUrl;
  final String originalImageUrl;
  final OriginalImage originalImage;
  final BorderInfo borderInfo;
  final String description;
  final List<GalleryImage> galleryImages;
  final Media media;
  final List<int> categoryIds;
  final List<Category> categories;
  final int defaultCategoryId;
  final String seoTitle;
  final String seoDescription;
  final Favorites favorites;
  final List<dynamic> attributes;
  final RelatedProducts relatedProducts;
  final List<dynamic> combinations;
  final int volume;
  final bool isSampleProduct;
  final String googleItemCondition;
  final bool isGiftCard;
  final bool discountsAllowed;
  final bool nameYourPriceEnabled;
  final int showOnFrontpage;

  factory EcwidStoreItem.fromJson(Map<String, dynamic> json) => EcwidStoreItem(
        id: json["id"],
        sku: json["sku"],
        thumbnailUrl: json["thumbnailUrl"],
        unlimited: json["unlimited"],
        inStock: json["inStock"],
        name: json["name"],
        price: json["price"] == null ? null : json["price"].toDouble(),
        priceInProductList: json["priceInProductList"] == null
            ? null
            : json["priceInProductList"].toDouble(),
        defaultDisplayedPrice: json["defaultDisplayedPrice"] == null
            ? null
            : json["defaultDisplayedPrice"].toDouble(),
        defaultDisplayedPriceFormatted: json["defaultDisplayedPriceFormatted"],
        tax: json["tax"] == null ? null : Tax.fromJson(json["tax"]),
        compareToPrice: json["compareToPrice"],
        compareToPriceFormatted: json["compareToPriceFormatted"],
        compareToPriceDiscount: json["compareToPriceDiscount"],
        compareToPriceDiscountFormatted:
            json["compareToPriceDiscountFormatted"],
        compareToPriceDiscountPercent: json["compareToPriceDiscountPercent"],
        compareToPriceDiscountPercentFormatted:
            json["compareToPriceDiscountPercentFormatted"],
        isShippingRequired: json["isShippingRequired"],
        weight: json["weight"] == null ? null : json["weight"].toDouble(),
        url: json["url"],
        created: json["created"],
        updated: json["updated"],
        createTimestamp: json["createTimestamp"],
        updateTimestamp: json["updateTimestamp"],
        productClassId: json["productClassId"],
        enabled: json["enabled"],
        options: json["options"] == null
            ? null
            : List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
        fixedShippingRateOnly: json["fixedShippingRateOnly"],
        fixedShippingRate: json["fixedShippingRate"],
        shipping: json["shipping"] == null
            ? null
            : Shipping.fromJson(json["shipping"]),
        defaultCombinationId: json["defaultCombinationId"],
        imageUrl: json["imageUrl"],
        smallThumbnailUrl: json["smallThumbnailUrl"],
        hdThumbnailUrl: json["hdThumbnailUrl"],
        originalImageUrl: json["originalImageUrl"],
        originalImage: json["originalImage"] == null
            ? null
            : OriginalImage.fromJson(json["originalImage"]),
        borderInfo: json["borderInfo"] == null
            ? null
            : BorderInfo.fromJson(json["borderInfo"]),
        description: json["description"],
        galleryImages: json["galleryImages"] == null
            ? null
            : List<GalleryImage>.from(
                json["galleryImages"].map((x) => GalleryImage.fromJson(x))),
        media: json["media"] == null ? null : Media.fromJson(json["media"]),
        categoryIds: json["categoryIds"] == null
            ? null
            : List<int>.from(json["categoryIds"].map((x) => x)),
        categories: json["categories"] == null
            ? null
            : List<Category>.from(
                json["categories"].map((x) => Category.fromJson(x))),
        defaultCategoryId: json["defaultCategoryId"],
        seoTitle: json["seoTitle"],
        seoDescription: json["seoDescription"],
        favorites: json["favorites"] == null
            ? null
            : Favorites.fromJson(json["favorites"]),
        attributes: json["attributes"] == null
            ? null
            : List<dynamic>.from(json["attributes"].map((x) => x)),
        relatedProducts: json["relatedProducts"] == null
            ? null
            : RelatedProducts.fromJson(json["relatedProducts"]),
        combinations: json["combinations"] == null
            ? null
            : List<dynamic>.from(json["combinations"].map((x) => x)),
        volume: json["volume"],
        isSampleProduct: json["isSampleProduct"],
        googleItemCondition: json["googleItemCondition"],
        isGiftCard: json["isGiftCard"],
        discountsAllowed: json["discountsAllowed"],
        nameYourPriceEnabled: json["nameYourPriceEnabled"],
        showOnFrontpage: json["showOnFrontpage"] ?? 1000,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sku": sku,
        "thumbnailUrl": thumbnailUrl,
        "unlimited": unlimited,
        "inStock": inStock,
        "name": name,
        "price": price,
        "priceInProductList": priceInProductList,
        "defaultDisplayedPrice": defaultDisplayedPrice,
        "defaultDisplayedPriceFormatted": defaultDisplayedPriceFormatted,
        "tax": tax == null ? null : tax.toJson(),
        "compareToPrice": compareToPrice,
        "compareToPriceFormatted": compareToPriceFormatted,
        "compareToPriceDiscount": compareToPriceDiscount,
        "compareToPriceDiscountFormatted": compareToPriceDiscountFormatted,
        "compareToPriceDiscountPercent": compareToPriceDiscountPercent,
        "compareToPriceDiscountPercentFormatted":
            compareToPriceDiscountPercentFormatted,
        "isShippingRequired": isShippingRequired,
        "weight": weight,
        "url": url,
        "created": created,
        "updated": updated,
        "createTimestamp": createTimestamp,
        "updateTimestamp": updateTimestamp,
        "productClassId": productClassId,
        "enabled": enabled,
        "options": options == null
            ? null
            : List<dynamic>.from(options.map((x) => x.toJson())),
        "fixedShippingRateOnly": fixedShippingRateOnly,
        "fixedShippingRate": fixedShippingRate,
        "shipping": shipping == null ? null : shipping.toJson(),
        "defaultCombinationId": defaultCombinationId,
        "imageUrl": imageUrl,
        "smallThumbnailUrl": smallThumbnailUrl,
        "hdThumbnailUrl": hdThumbnailUrl,
        "originalImageUrl": originalImageUrl,
        "originalImage": originalImage == null ? null : originalImage.toJson(),
        "borderInfo": borderInfo == null ? null : borderInfo.toJson(),
        "description": description,
        "galleryImages": galleryImages == null
            ? null
            : List<dynamic>.from(galleryImages.map((x) => x.toJson())),
        "media": media == null ? null : media.toJson(),
        "categoryIds": categoryIds == null
            ? null
            : List<dynamic>.from(categoryIds.map((x) => x)),
        "categories": categories == null
            ? null
            : List<dynamic>.from(categories.map((x) => x.toJson())),
        "defaultCategoryId": defaultCategoryId,
        "seoTitle": seoTitle,
        "seoDescription": seoDescription,
        "favorites": favorites == null ? null : favorites.toJson(),
        "attributes": attributes == null
            ? null
            : List<dynamic>.from(attributes.map((x) => x)),
        "relatedProducts":
            relatedProducts == null ? null : relatedProducts.toJson(),
        "combinations": combinations == null
            ? null
            : List<dynamic>.from(combinations.map((x) => x)),
        "volume": volume,
        "isSampleProduct": isSampleProduct,
        "googleItemCondition": googleItemCondition,
        "isGiftCard": isGiftCard,
        "discountsAllowed": discountsAllowed,
        "nameYourPriceEnabled": nameYourPriceEnabled,
        "showOnFrontpage": showOnFrontpage ?? 1000,
      };
}

class BorderInfo {
  BorderInfo({
    @required this.dominatingColor,
    @required this.homogeneity,
  });

  final DominatingColor dominatingColor;
  final bool homogeneity;

  factory BorderInfo.fromJson(Map<String, dynamic> json) => BorderInfo(
        dominatingColor: json["dominatingColor"] == null
            ? null
            : DominatingColor.fromJson(json["dominatingColor"]),
        homogeneity: json["homogeneity"],
      );

  Map<String, dynamic> toJson() => {
        "dominatingColor":
            dominatingColor == null ? null : dominatingColor.toJson(),
        "homogeneity": homogeneity,
      };
}

class DominatingColor {
  DominatingColor({
    @required this.red,
    @required this.green,
    @required this.blue,
    @required this.alpha,
  });

  final int red;
  final int green;
  final int blue;
  final int alpha;

  factory DominatingColor.fromJson(Map<String, dynamic> json) =>
      DominatingColor(
        red: json["red"],
        green: json["green"],
        blue: json["blue"],
        alpha: json["alpha"],
      );

  Map<String, dynamic> toJson() => {
        "red": red,
        "green": green,
        "blue": blue,
        "alpha": alpha,
      };
}

class Category {
  Category({
    @required this.id,
    @required this.enabled,
  });

  final int id;
  final bool enabled;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        enabled: json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "enabled": enabled,
      };
}

class Favorites {
  Favorites({
    @required this.count,
    @required this.displayedCount,
  });

  final int count;
  final String displayedCount;

  factory Favorites.fromJson(Map<String, dynamic> json) => Favorites(
        count: json["count"],
        displayedCount: json["displayedCount"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "displayedCount": displayedCount,
      };
}

class GalleryImage {
  GalleryImage({
    @required this.id,
    @required this.url,
    @required this.thumbnail,
    @required this.originalImageUrl,
    @required this.imageUrl,
    @required this.hdThumbnailUrl,
    @required this.thumbnailUrl,
    @required this.smallThumbnailUrl,
    @required this.width,
    @required this.height,
    @required this.orderBy,
    @required this.borderInfo,
  });

  final int id;
  final String url;
  final String thumbnail;
  final String originalImageUrl;
  final String imageUrl;
  final String hdThumbnailUrl;
  final String thumbnailUrl;
  final String smallThumbnailUrl;
  final int width;
  final int height;
  final int orderBy;
  final BorderInfo borderInfo;

  factory GalleryImage.fromJson(Map<String, dynamic> json) => GalleryImage(
        id: json["id"],
        url: json["url"],
        thumbnail: json["thumbnail"],
        originalImageUrl: json["originalImageUrl"],
        imageUrl: json["imageUrl"],
        hdThumbnailUrl: json["hdThumbnailUrl"],
        thumbnailUrl: json["thumbnailUrl"],
        smallThumbnailUrl: json["smallThumbnailUrl"],
        width: json["width"],
        height: json["height"],
        orderBy: json["orderBy"],
        borderInfo: json["borderInfo"] == null
            ? null
            : BorderInfo.fromJson(json["borderInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
        "thumbnail": thumbnail,
        "originalImageUrl": originalImageUrl,
        "imageUrl": imageUrl,
        "hdThumbnailUrl": hdThumbnailUrl,
        "thumbnailUrl": thumbnailUrl,
        "smallThumbnailUrl": smallThumbnailUrl,
        "width": width,
        "height": height,
        "orderBy": orderBy,
        "borderInfo": borderInfo == null ? null : borderInfo.toJson(),
      };
}

class Media {
  Media({
    @required this.images,
  });

  final List<ProductImage> images;

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        images: json["images"] == null
            ? null
            : List<ProductImage>.from(
                json["images"].map((x) => ProductImage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "images": images == null
            ? null
            : List<dynamic>.from(images.map((x) => x.toJson())),
      };
}

class ProductImage {
  ProductImage({
    @required this.id,
    @required this.isMain,
    @required this.orderBy,
    @required this.image160PxUrl,
    @required this.image400PxUrl,
    @required this.image800PxUrl,
    @required this.image1500PxUrl,
    @required this.imageOriginalUrl,
  });

  final String id;
  final bool isMain;
  final int orderBy;
  final String image160PxUrl;
  final String image400PxUrl;
  final String image800PxUrl;
  final String image1500PxUrl;
  final String imageOriginalUrl;

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        id: json["id"],
        isMain: json["isMain"],
        orderBy: json["orderBy"],
        image160PxUrl: json["image160pxUrl"],
        image400PxUrl: json["image400pxUrl"],
        image800PxUrl: json["image800pxUrl"],
        image1500PxUrl: json["image1500pxUrl"],
        imageOriginalUrl: json["imageOriginalUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "isMain": isMain,
        "orderBy": orderBy,
        "image160pxUrl": image160PxUrl,
        "image400pxUrl": image400PxUrl,
        "image800pxUrl": image800PxUrl,
        "image1500pxUrl": image1500PxUrl,
        "imageOriginalUrl": imageOriginalUrl,
      };
}

class Option {
  Option({
    this.type,
    this.name,
    this.nameTranslated,
    this.choices,
    this.defaultChoice,
    this.required,
  });

  final String type;
  final String name;
  final Translated nameTranslated;
  final List<Choice> choices;
  final int defaultChoice;
  final bool required;

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        type: json["type"],
        name: json["name"],
        nameTranslated: json["nameTranslated"] == null
            ? null
            : Translated.fromJson(json["nameTranslated"]),
        choices: json["choices"] == null
            ? null
            : List<Choice>.from(json["choices"].map((x) => Choice.fromJson(x))),
        defaultChoice: json["defaultChoice"],
        required: json["required"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "name": name,
        "nameTranslated":
            nameTranslated == null ? null : nameTranslated.toJson(),
        "choices": choices == null
            ? null
            : List<dynamic>.from(choices.map((x) => x.toJson())),
        "defaultChoice": defaultChoice,
        "required": required,
      };
}

class Choice {
  Choice({
    @required this.text,
    @required this.textTranslated,
    @required this.priceModifier,
    @required this.priceModifierType,
  });

  final String text;
  final Translated textTranslated;
  final double priceModifier;
  final String priceModifierType;

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
        text: json["text"],
        textTranslated: json["textTranslated"] == null
            ? null
            : Translated.fromJson(json["textTranslated"]),
        priceModifier: json["priceModifier"] == null
            ? null
            : json["priceModifier"].toDouble(),
        priceModifierType: json["priceModifierType"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "textTranslated":
            textTranslated == null ? null : textTranslated.toJson(),
        "priceModifier": priceModifier,
        "priceModifierType": priceModifierType,
      };
}

class Translated {
  Translated({
    @required this.en,
  });

  final String en;

  factory Translated.fromJson(Map<String, dynamic> json) => Translated(
        en: json["en"],
      );

  Map<String, dynamic> toJson() => {
        "en": en,
      };
}

class OriginalImage {
  OriginalImage({
    @required this.url,
    @required this.width,
    @required this.height,
  });

  final String url;
  final int width;
  final int height;

  factory OriginalImage.fromJson(Map<String, dynamic> json) => OriginalImage(
        url: json["url"],
        width: json["width"],
        height: json["height"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "width": width,
        "height": height,
      };
}

class RelatedProducts {
  RelatedProducts({
    @required this.productIds,
    @required this.relatedCategory,
  });

  final List<int> productIds;
  final RelatedCategory relatedCategory;

  factory RelatedProducts.fromJson(Map<String, dynamic> json) =>
      RelatedProducts(
        productIds: json["productIds"] == null
            ? null
            : List<int>.from(json["productIds"].map((x) => x)),
        relatedCategory: json["relatedCategory"] == null
            ? null
            : RelatedCategory.fromJson(json["relatedCategory"]),
      );

  Map<String, dynamic> toJson() => {
        "productIds": productIds == null
            ? null
            : List<dynamic>.from(productIds.map((x) => x)),
        "relatedCategory":
            relatedCategory == null ? null : relatedCategory.toJson(),
      };
}

class RelatedCategory {
  RelatedCategory({
    @required this.enabled,
    @required this.categoryId,
    @required this.productCount,
  });

  final bool enabled;
  final int categoryId;
  final int productCount;

  factory RelatedCategory.fromJson(Map<String, dynamic> json) =>
      RelatedCategory(
        enabled: json["enabled"],
        categoryId: json["categoryId"],
        productCount: json["productCount"],
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
        "categoryId": categoryId,
        "productCount": productCount,
      };
}

class Shipping {
  Shipping({
    @required this.type,
    @required this.methodMarkup,
    @required this.flatRate,
    @required this.disabledMethods,
    @required this.enabledMethods,
  });

  final String type;
  final int methodMarkup;
  final int flatRate;
  final List<dynamic> disabledMethods;
  final List<dynamic> enabledMethods;

  factory Shipping.fromJson(Map<String, dynamic> json) => Shipping(
        type: json["type"],
        methodMarkup: json["methodMarkup"],
        flatRate: json["flatRate"],
        disabledMethods: json["disabledMethods"] == null
            ? null
            : List<dynamic>.from(json["disabledMethods"].map((x) => x)),
        enabledMethods: json["enabledMethods"] == null
            ? null
            : List<dynamic>.from(json["enabledMethods"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "methodMarkup": methodMarkup,
        "flatRate": flatRate,
        "disabledMethods": disabledMethods == null
            ? null
            : List<dynamic>.from(disabledMethods.map((x) => x)),
        "enabledMethods": enabledMethods == null
            ? null
            : List<dynamic>.from(enabledMethods.map((x) => x)),
      };
}

class Tax {
  Tax({
    @required this.taxable,
    @required this.defaultLocationIncludedTaxRate,
    @required this.enabledManualTaxes,
    @required this.taxClassCode,
  });

  final bool taxable;
  final int defaultLocationIncludedTaxRate;
  final List<dynamic> enabledManualTaxes;
  final String taxClassCode;

  factory Tax.fromJson(Map<String, dynamic> json) => Tax(
        taxable: json["taxable"],
        defaultLocationIncludedTaxRate: json["defaultLocationIncludedTaxRate"],
        enabledManualTaxes: json["enabledManualTaxes"] == null
            ? null
            : List<dynamic>.from(json["enabledManualTaxes"].map((x) => x)),
        taxClassCode: json["taxClassCode"],
      );

  Map<String, dynamic> toJson() => {
        "taxable": taxable,
        "defaultLocationIncludedTaxRate": defaultLocationIncludedTaxRate,
        "enabledManualTaxes": enabledManualTaxes == null
            ? null
            : List<dynamic>.from(enabledManualTaxes.map((x) => x)),
        "taxClassCode": taxClassCode,
      };
}
