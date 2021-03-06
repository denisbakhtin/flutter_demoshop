// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart';

class Vendor {
  const Vendor({
    this.name,
    this.description,
    this.imageUrl,
  });

  final String name;
  final String description;
  final String imageUrl;

  Vendor.fromJson(Map json)
      : name = json['name'],
        description = json['description'],
        imageUrl = json['image_url'];

  @override
  int get hashCode => name.hashCode ^ description.hashCode ^ imageUrl.hashCode;

  @override
  String toString() => 'Vendor($name)';
}

class Product {
  const Product(
      {this.name,
      this.description,
      this.featureTitle,
      this.featureDescription,
      this.imageUrl,
      this.categories,
      this.price,
      this.vendor});

  final String name;
  final String description;
  final String featureTitle;
  final String featureDescription;
  final String imageUrl;
  final List<String> categories;
  final num price;
  final Vendor vendor;

  String get tag => name; // Unique value for Heroes
  String get priceString => '${price.floor()} руб';

  Product.fromJson(Map json)
      : name = json['name'],
        description = json['description'],
        featureTitle = json['feature_title'],
        featureDescription = json['feature_description'],
        imageUrl = json['image_url'],
        categories = [],
        price = json['price'],
        vendor = new Vendor.fromJson(json['vendor']);

  @override
  int get hashCode => hashValues(
      vendor,
      name.hashCode ^
          description.hashCode ^
          featureTitle.hashCode ^
          featureDescription.hashCode ^
          imageUrl.hashCode ^
          price.hashCode);

  @override
  String toString() => 'Product($name)';
}

class Order {
  Order({@required this.product, this.quantity: 1})
      : assert(product != null),
        assert(quantity != null && quantity >= 0);

  final Product product;
  final int quantity;

  Order copyWith({Product product, int quantity}) {
    return new Order(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Order typedOther = other;
    return product == typedOther.product && quantity == typedOther.quantity;
  }

  @override
  int get hashCode => hashValues(product, quantity);

  @override
  String toString() => 'Order($product, quantity=$quantity)';
}
