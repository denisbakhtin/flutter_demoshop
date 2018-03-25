// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'shrine_page.dart';
import 'shrine_types.dart';
import 'product_grid.dart';
import 'product_card.dart';
import 'shrine_utils.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'shrine_theme.dart';
import 'package:flutter/cupertino.dart';

Future<List<Product>> getProducts() async {
  var httpClient = new HttpClient();
  var request = await httpClient
      .getUrl(Uri.parse('http://demoshop.miobalans.ru/api/products'));
  var response = await request.close();
  var responseBody = await response.transform(new Utf8Decoder()).join();
  List data = json.decode(responseBody);
  return data.map((j) => new Product.fromJson(j)).toList();
}

class ShrineHomeWrapper extends StatelessWidget {
  ShrineHomeWrapper();

  @override
  Widget build(BuildContext context) {
    final ShrineTheme theme = ShrineTheme.of(context);
    return new FutureBuilder<List<Product>>(
      future: getProducts(),
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Text('Press button to start');
          case ConnectionState.waiting:
            return new Container(
              decoration: new BoxDecoration(color: theme.cardBackgroundColor),
              child:
                  new CupertinoActivityIndicator(animating: true, radius: 20.0),
            );
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return new ShrineHome(snapshot.data);
        }
      },
    );
  }
}

// The Shrine app's home page. Displays the featured item above a grid
// of the product items.
class ShrineHome extends StatefulWidget {
  ShrineHome(this.products);
  final List<Product> products;
  @override
  _ShrineHomeState createState() => new _ShrineHomeState();
}

class _ShrineHomeState extends State<ShrineHome> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(debugLabel: 'Shrine Home');
  static final ShrineGridDelegate gridDelegate = new ShrineGridDelegate();

  @override
  Widget build(BuildContext context) {
    //final List<Product> _products = new List<Product>.from(allProducts());
    final Product featured = widget.products
        .firstWhere((Product product) => product.featureDescription != '');
    return new ShrinePage(
      scaffoldKey: _scaffoldKey,
      products: widget.products,
      shoppingCart: shoppingCart,
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverToBoxAdapter(child: new Heading(product: featured)),
          new SliverSafeArea(
            top: false,
            minimum: const EdgeInsets.all(16.0),
            sliver: new SliverGrid(
              gridDelegate: gridDelegate,
              delegate: new SliverChildListDelegate(
                widget.products.map((Product product) {
                  return new ProductItem(
                    product: product,
                    parentContext: context,
                    products: widget.products,
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
}
