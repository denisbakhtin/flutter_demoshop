// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'shop/home.dart';
import 'shop/shared/routes.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'shop/redux/app_state.dart';
import 'shop/redux/actions.dart';
import 'shop/redux/reducers.dart';
import 'shop/redux/middleware.dart';

class ShrineDemo extends StatelessWidget {
  ShrineDemo(this.store);
  final Store<AppState> store;

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
      store: store,
      child: new MaterialApp(
        title: 'Демо магазин',
        home: new StoreBuilder<AppState>(
          onInit: (store) => store.dispatch(new LoadProductsAction()),
          builder: (context, store) {
            return buildShrine(context, new ShrineHome());
          },
        ),
      ),
    );
  }
}

void main() {
  final store = new Store<AppState>(appReducer,
      initialState: new AppState.loading(),
      middleware: createStoreMiddleware());
  runApp(new ShrineDemo(store));
}
