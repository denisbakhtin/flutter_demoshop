// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import '../shrine_types.dart';

class AddToCartAction {
  final Product product;
  final Order order;
  AddToCartAction(this.product, this.order);
  @override
  String toString() {
    return 'AddToCartAction{product: $product, order: $order}';
  }
}

class ClearCartAction {}

class ProductsNotLoadedAction {}

class ProductsLoadedAction {
  final List<Product> products;
  ProductsLoadedAction(this.products);

  @override
  String toString() {
    return 'ProductsLoadedAction{products: $products}';
  }
}

class LoadProductsAction {}

class ProductsSortByNameAction {}

class ProductsSortByPriceAction {}
