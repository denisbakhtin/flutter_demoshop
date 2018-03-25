// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'shrine_theme.dart';
import 'shrine_types.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux/app_state.dart';
import 'redux/actions.dart';

enum ShrineAction { sortByPrice, sortByProduct, emptyCart }

class ShrinePage extends StatefulWidget {
  const ShrinePage(
      {Key key,
      @required this.scaffoldKey,
      @required this.body,
      this.floatingActionButton,
      this.shoppingCart})
      : assert(body != null),
        assert(scaffoldKey != null),
        super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget body;
  final Widget floatingActionButton;
  final Map<Product, Order> shoppingCart;

  @override
  ShrinePageState createState() => new ShrinePageState();
}

/// Defines the Scaffold, AppBar, etc that the demo pages have in common.
class ShrinePageState extends State<ShrinePage> {
  double _appBarElevation = 0.0;

  bool _handleScrollNotification(ScrollNotification notification) {
    final double elevation =
        notification.metrics.extentBefore <= 0.0 ? 0.0 : 1.0;
    if (elevation != _appBarElevation) {
      setState(() {
        _appBarElevation = elevation;
      });
    }
    return false;
  }

  void _showShoppingCart() {
    showModalBottomSheet<Null>(
        context: context,
        builder: (BuildContext context) {
          if (widget.shoppingCart.isEmpty) {
            return const Padding(
                padding: const EdgeInsets.all(24.0),
                child: const Text('Корзина пуста'));
          }
          return new ListView(
            padding: kMaterialListPadding,
            children: widget.shoppingCart.values.map((Order order) {
              return new ListTile(
                  title: new Text(order.product.name),
                  leading: new Text('${order.quantity}'),
                  subtitle: new Text(order.product.vendor.name));
            }).toList(),
          );
        });
  }

  void _emptyCart() {
    widget.shoppingCart.clear();
    widget.scaffoldKey.currentState
        .showSnackBar(const SnackBar(content: const Text('Корзина очищена')));
  }

  @override
  Widget build(BuildContext context) {
    final ShrineTheme theme = ShrineTheme.of(context);
    return new StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (context, vm) {
        return new Scaffold(
            key: widget.scaffoldKey,
            appBar: new AppBar(
                elevation: _appBarElevation,
                backgroundColor: theme.appBarBackgroundColor,
                iconTheme: Theme.of(context).iconTheme,
                brightness: Brightness.light,
                flexibleSpace: new Container(
                    decoration: new BoxDecoration(
                        border: new Border(
                            bottom:
                                new BorderSide(color: theme.dividerColor)))),
                title: new Text('ДЕМО',
                    style: ShrineTheme.of(context).appBarTitleStyle),
                centerTitle: true,
                actions: <Widget>[
                  new IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      tooltip: 'Корзина',
                      onPressed: _showShoppingCart),
                  new PopupMenuButton<ShrineAction>(
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuItem<ShrineAction>>[
                            const PopupMenuItem<ShrineAction>(
                                value: ShrineAction.sortByPrice,
                                child: const Text('Сортировать по цене')),
                            const PopupMenuItem<ShrineAction>(
                                value: ShrineAction.sortByProduct,
                                child: const Text('Сортировать по названию')),
                            const PopupMenuItem<ShrineAction>(
                                value: ShrineAction.emptyCart,
                                child: const Text('Очистить корзину'))
                          ],
                      onSelected: (ShrineAction action) {
                        switch (action) {
                          case ShrineAction.sortByPrice:
                            vm.onSortByPrice();
                            break;
                          case ShrineAction.sortByProduct:
                            vm.onSortByName();
                            break;
                          case ShrineAction.emptyCart:
                            setState(_emptyCart);
                            break;
                        }
                      })
                ]),
            floatingActionButton: widget.floatingActionButton,
            body: new NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification, child: widget.body));
      },
    );
  }
}

class _ViewModel {
  final List<Product> products;
  final Function() onSortByName;
  final Function() onSortByPrice;

  _ViewModel({
    @required this.products,
    @required this.onSortByName,
    @required this.onSortByPrice,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(
      products: store.state.products,
      onSortByName: () => store.dispatch(new ProductsSortByNameAction()),
      onSortByPrice: () => store.dispatch(new ProductsSortByPriceAction()),
    );
  }
}