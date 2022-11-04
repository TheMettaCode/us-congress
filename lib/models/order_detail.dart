import 'package:meta/meta.dart';
import 'dart:convert';

OrderDetailList orderDetailListFromJson(String str) =>
    OrderDetailList.fromJson(json.decode(str));

String orderDetailListToJson(OrderDetailList data) =>
    json.encode(data.toJson());

class OrderDetailList {
  OrderDetailList({@required this.orders});
  final List<Order> orders;

  factory OrderDetailList.fromJson(Map<String, dynamic> json) =>
      OrderDetailList(
        orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
      };
}

class Order {
  Order(
      {@required this.orderDate,
      @required this.orderId,
      @required this.orderIdExtended,
      @required this.userName,
      @required this.userId,
      @required this.productId,
      @required this.productName,
      this.productOptions,
      @required this.productDescription,
      @required this.productPrice,
      @required this.productImageUrl,
      @required this.customerName,
      @required this.customerId,
      @required this.customerShippingAddress,
      @required this.customerEmail,
      this.customerPhone
      // this.productInfo,
      // this.customerInfo,
      // this.userInfo,
      });

  final DateTime orderDate;
  final String orderId;
  final String orderIdExtended;
  final String userName;
  final String userId;
  final String productName;
  final String productId;
  final String productPrice;
  final String productImageUrl;
  final String productOptions;
  final String productDescription;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerShippingAddress;
  // final Map<String, dynamic> productInfo;
  // final Map<String, dynamic> customerInfo;
  // final Map<String, dynamic> userInfo;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json["order_id"],
        orderIdExtended: json['order_id_extended'],
        orderDate: DateTime.parse(json["order_date"]),
        userId: json["user_id"],
        userName: json["user_name"],
        productId: json["product_id"],
        productName: json["product_name"],
        productOptions: json["product_options"],
        productPrice: json["product_price"],
        productImageUrl: json['product_image_url'],
        productDescription: json["product_description"],
        customerId: json["customer_id"],
        customerName: json["customer_name"],
        customerEmail: json["customer_email"],
        customerPhone: json["customer_phone"],
        customerShippingAddress: json["customer_shipping_address"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "order_id_extended": orderIdExtended,
        "order_date": orderDate.toString(),
        "user_id": userId,
        "user_name": userName,
        "product_id": productId,
        "product_name": productName,
        "product_options": productOptions ?? 'No Product Options',
        "product_price": productPrice,
        "product_image_url": productImageUrl,
        "product_description": productDescription,
        "customer_id": customerId,
        "customer_name": customerName,
        "customer_email": customerEmail,
        "customer_phone": customerPhone ?? 'No Phone Number',
        "customer_shipping_address": customerShippingAddress
      };

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}
