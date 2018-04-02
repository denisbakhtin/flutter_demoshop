// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import '../shared/types.dart';

class AddToCartAction {
  final Product product;
  final Order order;
  AddToCartAction(this.product, this.order);
}

class ClearCartAction {}

class ProductsNotLoadedAction {}

class ProductsLoadedAction {
  final List<Product> products;
  ProductsLoadedAction(this.products);
}

class LoadProductsAction {}

class ProductsSortByNameAction {}

class ProductsSortByPriceAction {}

class CartItemChangedAction {
  final Order order;
  final int quantity;
  CartItemChangedAction(this.order, this.quantity);
}

class CartItemRemovedAction {
  final Order order;
  CartItemRemovedAction(this.order);
}
