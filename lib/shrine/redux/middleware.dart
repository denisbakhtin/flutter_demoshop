// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:redux/redux.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
    getProducts().then((products) {
      store.dispatch(new ProductsLoadedAction(products));
    }).catchError((_) => store.dispatch(new ProductsNotLoadedAction()));

    next(action);
  };
}

Future<List<Product>> getProducts() async {
  var httpClient = new HttpClient();
  var request = await httpClient
      .getUrl(Uri.parse('http://demoshop.miobalans.ru/api/products'));
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  List data = json.decode(responseBody);
  return data.map((j) => new Product.fromJson(j)).toList();
}
