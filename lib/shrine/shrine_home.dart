// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

import 'shrine_page.dart';
import 'shrine_types.dart';
import 'product_grid.dart';
import 'product_card.dart';
import 'shrine_utils.dart';
import 'shrine_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux/app_state.dart';

// The Shrine app's home page. Displays the featured item above a grid
// of the product items.
class ShrineHome extends StatelessWidget {
  ShrineHome();
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(debugLabel: 'Shrine Home');
  static final ShrineGridDelegate gridDelegate = new ShrineGridDelegate();

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (context, vm) {
        if (vm.loading) {
          return new Container(
            decoration: new BoxDecoration(
                color: ShrineTheme.of(context).cardBackgroundColor),
            child:
                new CupertinoActivityIndicator(animating: true, radius: 20.0),
          );
        } else {
          return new ShrinePage(
            scaffoldKey: _scaffoldKey,
            shoppingCart: shoppingCart,
            body: new CustomScrollView(
              slivers: <Widget>[
                new SliverToBoxAdapter(
                    child: new Heading(product: vm.featured)),
                new SliverSafeArea(
                  top: false,
                  minimum: const EdgeInsets.all(16.0),
                  sliver: new SliverGrid(
                    gridDelegate: gridDelegate,
                    delegate: new SliverChildListDelegate(
                      vm.products.map((Product product) {
                        return new ProductItem(
                          product: product,
                          parentContext: context,
                          shoppingCart: shoppingCart,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _ViewModel {
  final List<Product> products;
  final Product featured;
  final bool loading;

  _ViewModel({
    @required this.products,
    @required this.loading,
    @required this.featured,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(
      products: store.state.products,
      featured: store.state.products.length > 0
          ? store.state.products
              .firstWhere((Product product) => product.featureDescription != '')
          : null,
      loading: store.state.isLoading,
    );
  }
}
