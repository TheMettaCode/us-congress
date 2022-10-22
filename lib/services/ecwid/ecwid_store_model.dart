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
        total: json["total"] == null ? null : json["total"],
        count: json["count"] == null ? null : json["count"],
        offset: json["offset"] == null ? null : json["offset"],
        limit: json["limit"] == null ? null : json["limit"],
        items: json["items"] == null
            ? null
            : List<EcwidStoreItem>.from(
                json["items"].map((x) => EcwidStoreItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total == null ? null : total,
        "count": count == null ? null : count,
        "offset": offset == null ? null : offset,
        "limit": limit == null ? null : limit,
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
        id: json["id"] == null ? null : json["id"],
        sku: json["sku"] == null ? null : json["sku"],
        thumbnailUrl:
            json["thumbnailUrl"] == null ? null : json["thumbnailUrl"],
        unlimited: json["unlimited"] == null ? null : json["unlimited"],
        inStock: json["inStock"] == null ? null : json["inStock"],
        name: json["name"] == null ? null : json["name"],
        price: json["price"] == null ? null : json["price"].toDouble(),
        priceInProductList: json["priceInProductList"] == null
            ? null
            : json["priceInProductList"].toDouble(),
        defaultDisplayedPrice: json["defaultDisplayedPrice"] == null
            ? null
            : json["defaultDisplayedPrice"].toDouble(),
        defaultDisplayedPriceFormatted:
            json["defaultDisplayedPriceFormatted"] == null
                ? null
                : json["defaultDisplayedPriceFormatted"],
        tax: json["tax"] == null ? null : Tax.fromJson(json["tax"]),
        compareToPrice:
            json["compareToPrice"] == null ? null : json["compareToPrice"],
        compareToPriceFormatted: json["compareToPriceFormatted"] == null
            ? null
            : json["compareToPriceFormatted"],
        compareToPriceDiscount: json["compareToPriceDiscount"] == null
            ? null
            : json["compareToPriceDiscount"],
        compareToPriceDiscountFormatted:
            json["compareToPriceDiscountFormatted"] == null
                ? null
                : json["compareToPriceDiscountFormatted"],
        compareToPriceDiscountPercent:
            json["compareToPriceDiscountPercent"] == null
                ? null
                : json["compareToPriceDiscountPercent"],
        compareToPriceDiscountPercentFormatted:
            json["compareToPriceDiscountPercentFormatted"] == null
                ? null
                : json["compareToPriceDiscountPercentFormatted"],
        isShippingRequired: json["isShippingRequired"] == null
            ? null
            : json["isShippingRequired"],
        weight: json["weight"] == null ? null : json["weight"].toDouble(),
        url: json["url"] == null ? null : json["url"],
        created: json["created"] == null ? null : json["created"],
        updated: json["updated"] == null ? null : json["updated"],
        createTimestamp:
            json["createTimestamp"] == null ? null : json["createTimestamp"],
        updateTimestamp:
            json["updateTimestamp"] == null ? null : json["updateTimestamp"],
        productClassId:
            json["productClassId"] == null ? null : json["productClassId"],
        enabled: json["enabled"] == null ? null : json["enabled"],
        options: json["options"] == null
            ? null
            : List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
        fixedShippingRateOnly: json["fixedShippingRateOnly"] == null
            ? null
            : json["fixedShippingRateOnly"],
        fixedShippingRate: json["fixedShippingRate"] == null
            ? null
            : json["fixedShippingRate"],
        shipping: json["shipping"] == null
            ? null
            : Shipping.fromJson(json["shipping"]),
        defaultCombinationId: json["defaultCombinationId"] == null
            ? null
            : json["defaultCombinationId"],
        imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
        smallThumbnailUrl: json["smallThumbnailUrl"] == null
            ? null
            : json["smallThumbnailUrl"],
        hdThumbnailUrl:
            json["hdThumbnailUrl"] == null ? null : json["hdThumbnailUrl"],
        originalImageUrl:
            json["originalImageUrl"] == null ? null : json["originalImageUrl"],
        originalImage: json["originalImage"] == null
            ? null
            : OriginalImage.fromJson(json["originalImage"]),
        borderInfo: json["borderInfo"] == null
            ? null
            : BorderInfo.fromJson(json["borderInfo"]),
        description: json["description"] == null ? null : json["description"],
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
        defaultCategoryId: json["defaultCategoryId"] == null
            ? null
            : json["defaultCategoryId"],
        seoTitle: json["seoTitle"] == null ? null : json["seoTitle"],
        seoDescription:
            json["seoDescription"] == null ? null : json["seoDescription"],
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
        volume: json["volume"] == null ? null : json["volume"],
        isSampleProduct:
            json["isSampleProduct"] == null ? null : json["isSampleProduct"],
        googleItemCondition: json["googleItemCondition"] == null
            ? null
            : json["googleItemCondition"],
        isGiftCard: json["isGiftCard"] == null ? null : json["isGiftCard"],
        discountsAllowed:
            json["discountsAllowed"] == null ? null : json["discountsAllowed"],
        nameYourPriceEnabled: json["nameYourPriceEnabled"] == null
            ? null
            : json["nameYourPriceEnabled"],
        showOnFrontpage:
            json["showOnFrontpage"] == null ? 1000 : json["showOnFrontpage"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "sku": sku == null ? null : sku,
        "thumbnailUrl": thumbnailUrl == null ? null : thumbnailUrl,
        "unlimited": unlimited == null ? null : unlimited,
        "inStock": inStock == null ? null : inStock,
        "name": name == null ? null : name,
        "price": price == null ? null : price,
        "priceInProductList":
            priceInProductList == null ? null : priceInProductList,
        "defaultDisplayedPrice":
            defaultDisplayedPrice == null ? null : defaultDisplayedPrice,
        "defaultDisplayedPriceFormatted": defaultDisplayedPriceFormatted == null
            ? null
            : defaultDisplayedPriceFormatted,
        "tax": tax == null ? null : tax.toJson(),
        "compareToPrice": compareToPrice == null ? null : compareToPrice,
        "compareToPriceFormatted":
            compareToPriceFormatted == null ? null : compareToPriceFormatted,
        "compareToPriceDiscount":
            compareToPriceDiscount == null ? null : compareToPriceDiscount,
        "compareToPriceDiscountFormatted":
            compareToPriceDiscountFormatted == null
                ? null
                : compareToPriceDiscountFormatted,
        "compareToPriceDiscountPercent": compareToPriceDiscountPercent == null
            ? null
            : compareToPriceDiscountPercent,
        "compareToPriceDiscountPercentFormatted":
            compareToPriceDiscountPercentFormatted == null
                ? null
                : compareToPriceDiscountPercentFormatted,
        "isShippingRequired":
            isShippingRequired == null ? null : isShippingRequired,
        "weight": weight == null ? null : weight,
        "url": url == null ? null : url,
        "created": created == null ? null : created,
        "updated": updated == null ? null : updated,
        "createTimestamp": createTimestamp == null ? null : createTimestamp,
        "updateTimestamp": updateTimestamp == null ? null : updateTimestamp,
        "productClassId": productClassId == null ? null : productClassId,
        "enabled": enabled == null ? null : enabled,
        "options": options == null
            ? null
            : List<dynamic>.from(options.map((x) => x.toJson())),
        "fixedShippingRateOnly":
            fixedShippingRateOnly == null ? null : fixedShippingRateOnly,
        "fixedShippingRate":
            fixedShippingRate == null ? null : fixedShippingRate,
        "shipping": shipping == null ? null : shipping.toJson(),
        "defaultCombinationId":
            defaultCombinationId == null ? null : defaultCombinationId,
        "imageUrl": imageUrl == null ? null : imageUrl,
        "smallThumbnailUrl":
            smallThumbnailUrl == null ? null : smallThumbnailUrl,
        "hdThumbnailUrl": hdThumbnailUrl == null ? null : hdThumbnailUrl,
        "originalImageUrl": originalImageUrl == null ? null : originalImageUrl,
        "originalImage": originalImage == null ? null : originalImage.toJson(),
        "borderInfo": borderInfo == null ? null : borderInfo.toJson(),
        "description": description == null ? null : description,
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
        "defaultCategoryId":
            defaultCategoryId == null ? null : defaultCategoryId,
        "seoTitle": seoTitle == null ? null : seoTitle,
        "seoDescription": seoDescription == null ? null : seoDescription,
        "favorites": favorites == null ? null : favorites.toJson(),
        "attributes": attributes == null
            ? null
            : List<dynamic>.from(attributes.map((x) => x)),
        "relatedProducts":
            relatedProducts == null ? null : relatedProducts.toJson(),
        "combinations": combinations == null
            ? null
            : List<dynamic>.from(combinations.map((x) => x)),
        "volume": volume == null ? null : volume,
        "isSampleProduct": isSampleProduct == null ? null : isSampleProduct,
        "googleItemCondition":
            googleItemCondition == null ? null : googleItemCondition,
        "isGiftCard": isGiftCard == null ? null : isGiftCard,
        "discountsAllowed": discountsAllowed == null ? null : discountsAllowed,
        "nameYourPriceEnabled":
            nameYourPriceEnabled == null ? null : nameYourPriceEnabled,
        "showOnFrontpage": showOnFrontpage == null ? 1000 : showOnFrontpage,
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
        homogeneity: json["homogeneity"] == null ? null : json["homogeneity"],
      );

  Map<String, dynamic> toJson() => {
        "dominatingColor":
            dominatingColor == null ? null : dominatingColor.toJson(),
        "homogeneity": homogeneity == null ? null : homogeneity,
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
        red: json["red"] == null ? null : json["red"],
        green: json["green"] == null ? null : json["green"],
        blue: json["blue"] == null ? null : json["blue"],
        alpha: json["alpha"] == null ? null : json["alpha"],
      );

  Map<String, dynamic> toJson() => {
        "red": red == null ? null : red,
        "green": green == null ? null : green,
        "blue": blue == null ? null : blue,
        "alpha": alpha == null ? null : alpha,
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
        id: json["id"] == null ? null : json["id"],
        enabled: json["enabled"] == null ? null : json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "enabled": enabled == null ? null : enabled,
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
        count: json["count"] == null ? null : json["count"],
        displayedCount:
            json["displayedCount"] == null ? null : json["displayedCount"],
      );

  Map<String, dynamic> toJson() => {
        "count": count == null ? null : count,
        "displayedCount": displayedCount == null ? null : displayedCount,
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
        id: json["id"] == null ? null : json["id"],
        url: json["url"] == null ? null : json["url"],
        thumbnail: json["thumbnail"] == null ? null : json["thumbnail"],
        originalImageUrl:
            json["originalImageUrl"] == null ? null : json["originalImageUrl"],
        imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
        hdThumbnailUrl:
            json["hdThumbnailUrl"] == null ? null : json["hdThumbnailUrl"],
        thumbnailUrl:
            json["thumbnailUrl"] == null ? null : json["thumbnailUrl"],
        smallThumbnailUrl: json["smallThumbnailUrl"] == null
            ? null
            : json["smallThumbnailUrl"],
        width: json["width"] == null ? null : json["width"],
        height: json["height"] == null ? null : json["height"],
        orderBy: json["orderBy"] == null ? null : json["orderBy"],
        borderInfo: json["borderInfo"] == null
            ? null
            : BorderInfo.fromJson(json["borderInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "url": url == null ? null : url,
        "thumbnail": thumbnail == null ? null : thumbnail,
        "originalImageUrl": originalImageUrl == null ? null : originalImageUrl,
        "imageUrl": imageUrl == null ? null : imageUrl,
        "hdThumbnailUrl": hdThumbnailUrl == null ? null : hdThumbnailUrl,
        "thumbnailUrl": thumbnailUrl == null ? null : thumbnailUrl,
        "smallThumbnailUrl":
            smallThumbnailUrl == null ? null : smallThumbnailUrl,
        "width": width == null ? null : width,
        "height": height == null ? null : height,
        "orderBy": orderBy == null ? null : orderBy,
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
        id: json["id"] == null ? null : json["id"],
        isMain: json["isMain"] == null ? null : json["isMain"],
        orderBy: json["orderBy"] == null ? null : json["orderBy"],
        image160PxUrl:
            json["image160pxUrl"] == null ? null : json["image160pxUrl"],
        image400PxUrl:
            json["image400pxUrl"] == null ? null : json["image400pxUrl"],
        image800PxUrl:
            json["image800pxUrl"] == null ? null : json["image800pxUrl"],
        image1500PxUrl:
            json["image1500pxUrl"] == null ? null : json["image1500pxUrl"],
        imageOriginalUrl:
            json["imageOriginalUrl"] == null ? null : json["imageOriginalUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "isMain": isMain == null ? null : isMain,
        "orderBy": orderBy == null ? null : orderBy,
        "image160pxUrl": image160PxUrl == null ? null : image160PxUrl,
        "image400pxUrl": image400PxUrl == null ? null : image400PxUrl,
        "image800pxUrl": image800PxUrl == null ? null : image800PxUrl,
        "image1500pxUrl": image1500PxUrl == null ? null : image1500PxUrl,
        "imageOriginalUrl": imageOriginalUrl == null ? null : imageOriginalUrl,
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
        type: json["type"] == null ? null : json["type"],
        name: json["name"] == null ? null : json["name"],
        nameTranslated: json["nameTranslated"] == null
            ? null
            : Translated.fromJson(json["nameTranslated"]),
        choices: json["choices"] == null
            ? null
            : List<Choice>.from(json["choices"].map((x) => Choice.fromJson(x))),
        defaultChoice:
            json["defaultChoice"] == null ? null : json["defaultChoice"],
        required: json["required"] == null ? null : json["required"],
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "name": name == null ? null : name,
        "nameTranslated":
            nameTranslated == null ? null : nameTranslated.toJson(),
        "choices": choices == null
            ? null
            : List<dynamic>.from(choices.map((x) => x.toJson())),
        "defaultChoice": defaultChoice == null ? null : defaultChoice,
        "required": required == null ? null : required,
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
        text: json["text"] == null ? null : json["text"],
        textTranslated: json["textTranslated"] == null
            ? null
            : Translated.fromJson(json["textTranslated"]),
        priceModifier: json["priceModifier"] == null
            ? null
            : json["priceModifier"].toDouble(),
        priceModifierType: json["priceModifierType"] == null
            ? null
            : json["priceModifierType"],
      );

  Map<String, dynamic> toJson() => {
        "text": text == null ? null : text,
        "textTranslated":
            textTranslated == null ? null : textTranslated.toJson(),
        "priceModifier": priceModifier == null ? null : priceModifier,
        "priceModifierType":
            priceModifierType == null ? null : priceModifierType,
      };
}

class Translated {
  Translated({
    @required this.en,
  });

  final String en;

  factory Translated.fromJson(Map<String, dynamic> json) => Translated(
        en: json["en"] == null ? null : json["en"],
      );

  Map<String, dynamic> toJson() => {
        "en": en == null ? null : en,
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
        url: json["url"] == null ? null : json["url"],
        width: json["width"] == null ? null : json["width"],
        height: json["height"] == null ? null : json["height"],
      );

  Map<String, dynamic> toJson() => {
        "url": url == null ? null : url,
        "width": width == null ? null : width,
        "height": height == null ? null : height,
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
        enabled: json["enabled"] == null ? null : json["enabled"],
        categoryId: json["categoryId"] == null ? null : json["categoryId"],
        productCount:
            json["productCount"] == null ? null : json["productCount"],
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled == null ? null : enabled,
        "categoryId": categoryId == null ? null : categoryId,
        "productCount": productCount == null ? null : productCount,
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
        type: json["type"] == null ? null : json["type"],
        methodMarkup:
            json["methodMarkup"] == null ? null : json["methodMarkup"],
        flatRate: json["flatRate"] == null ? null : json["flatRate"],
        disabledMethods: json["disabledMethods"] == null
            ? null
            : List<dynamic>.from(json["disabledMethods"].map((x) => x)),
        enabledMethods: json["enabledMethods"] == null
            ? null
            : List<dynamic>.from(json["enabledMethods"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "methodMarkup": methodMarkup == null ? null : methodMarkup,
        "flatRate": flatRate == null ? null : flatRate,
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
        taxable: json["taxable"] == null ? null : json["taxable"],
        defaultLocationIncludedTaxRate:
            json["defaultLocationIncludedTaxRate"] == null
                ? null
                : json["defaultLocationIncludedTaxRate"],
        enabledManualTaxes: json["enabledManualTaxes"] == null
            ? null
            : List<dynamic>.from(json["enabledManualTaxes"].map((x) => x)),
        taxClassCode:
            json["taxClassCode"] == null ? null : json["taxClassCode"],
      );

  Map<String, dynamic> toJson() => {
        "taxable": taxable == null ? null : taxable,
        "defaultLocationIncludedTaxRate": defaultLocationIncludedTaxRate == null
            ? null
            : defaultLocationIncludedTaxRate,
        "enabledManualTaxes": enabledManualTaxes == null
            ? null
            : List<dynamic>.from(enabledManualTaxes.map((x) => x)),
        "taxClassCode": taxClassCode == null ? null : taxClassCode,
      };
}
