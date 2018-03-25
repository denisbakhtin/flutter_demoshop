// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:redux/redux.dart';
import 'app_state.dart';
import 'actions.dart';
import '../shrine_types.dart';

List<Middleware<AppState>> createStoreMiddleware() {
  return combineTypedMiddleware([
    new MiddlewareBinding<AppState, LoadProductsAction>(_loadProducts()),
  ]);
}

Middleware<AppState> _loadProducts() {
  return (Store<AppState> store, action, NextDispatcher next) {
    //final List<Product> _products = new List<Product>.from(allProducts());
    final List<Product> _products = [];
    store.dispatch(new ProductsLoadedAction(_products));

    next(action);
  };
}
