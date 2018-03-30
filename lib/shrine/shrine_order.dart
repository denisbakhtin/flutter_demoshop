// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'shrine_routes.dart';
import 'shrine_page.dart';
import 'shrine_theme.dart';
import 'shrine_types.dart';
import 'product_card.dart';
import 'product_grid.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux/app_state.dart';
import 'redux/actions.dart';

// Displays the product title's, description, and order quantity dropdown.
class _ProductItem extends StatelessWidget {
  const _ProductItem({
    Key key,
    @required this.product,
    @required this.quantity,
    @required this.onChanged,
  })  : assert(product != null),
        assert(quantity != null),
        assert(onChanged != null),
        super(key: key);

  final Product product;
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ShrineTheme theme = ShrineTheme.of(context);
    return new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Text(product.name, style: theme.featureTitleStyle),
        const SizedBox(height: 24.0),
        new Text(product.description, style: theme.featureStyle),
        const SizedBox(height: 16.0),
        new Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 88.0),
          child: new DropdownButtonHideUnderline(
            child: new Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  color: const Color(0xFFD9D9D9),
                ),
              ),
              child: new DropdownButton<int>(
                items: <int>[0, 1, 2, 3, 4, 5].map((int value) {
                  return new DropdownMenuItem<int>(
                    value: value,
                    child: new Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: new Text('Купить $value',
                          style: theme.quantityMenuStyle),
                    ),
                  );
                }).toList(),
                value: quantity,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Vendor name and description
class _VendorItem extends StatelessWidget {
  const _VendorItem({Key key, @required this.vendor})
      : assert(vendor != null),
        super(key: key);

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final ShrineTheme theme = ShrineTheme.of(context);
    return new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new SizedBox(
          height: 24.0,
          child: new Align(
            alignment: Alignment.bottomLeft,
            child: new Text(vendor.name, style: theme.vendorTitleStyle),
          ),
        ),
        const SizedBox(height: 16.0),
        new Text(vendor.description, style: theme.vendorStyle),
      ],
    );
  }
}

// Layout the order page's heading: the product's image, the
// title/description/dropdown product item, and the vendor item.
class _HeadingLayout extends MultiChildLayoutDelegate {
  _HeadingLayout();

  static const String image = 'image';
  static const String icon = 'icon';
  static const String product = 'product';
  static const String vendor = 'vendor';

  @override
  void performLayout(Size size) {
    const double margin = 56.0;
    final bool landscape = size.width > size.height;
    final double imageWidth =
        (landscape ? size.width / 2.0 : size.width) - margin * 2.0;
    final BoxConstraints imageConstraints =
        new BoxConstraints(maxHeight: 224.0, maxWidth: imageWidth);
    final Size imageSize = layoutChild(image, imageConstraints);
    const double imageY = 0.0;
    positionChild(image, const Offset(margin, imageY));

    final double productWidth =
        landscape ? size.width / 2.0 : size.width - margin;
    final BoxConstraints productConstraints =
        new BoxConstraints(maxWidth: productWidth);
    final Size productSize = layoutChild(product, productConstraints);
    final double productX = landscape ? size.width / 2.0 : margin;
    final double productY = landscape ? 0.0 : imageY + imageSize.height + 16.0;
    positionChild(product, new Offset(productX, productY));

    final Size iconSize = layoutChild(icon, new BoxConstraints.loose(size));
    positionChild(
        icon, new Offset(productX - iconSize.width - 16.0, productY + 8.0));

    final double vendorWidth = landscape ? size.width - margin : productWidth;
    layoutChild(vendor, new BoxConstraints(maxWidth: vendorWidth));
    final double vendorX = landscape ? margin : productX;
    final double vendorY = productY + productSize.height + 16.0;
    positionChild(vendor, new Offset(vendorX, vendorY));
  }

  @override
  bool shouldRelayout(_HeadingLayout oldDelegate) => true;
}

// Describes a product and vendor in detail, supports specifying
// a order quantity (0-5). Appears at the top of the OrderPage.
class _Heading extends StatelessWidget {
  const _Heading({
    Key key,
    @required this.product,
    @required this.quantity,
    this.quantityChanged,
  })  : assert(product != null),
        assert(quantity != null && quantity >= 0 && quantity <= 5),
        super(key: key);

  final Product product;
  final int quantity;
  final ValueChanged<int> quantityChanged;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return new SizedBox(
      height: (screenSize.height - kToolbarHeight) * 1.35,
      child: new Material(
        type: MaterialType.card,
        elevation: 0.0,
        child: new Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 18.0, right: 16.0, bottom: 24.0),
          child: new CustomMultiChildLayout(
            delegate: new _HeadingLayout(),
            children: <Widget>[
              new LayoutId(
                id: _HeadingLayout.image,
                child: new Hero(
                  tag: product.tag,
                  child: new Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              new LayoutId(
                id: _HeadingLayout.icon,
                child: const Icon(
                  Icons.info_outline,
                  size: 24.0,
                  color: const Color(0xFFFFE0E0),
                ),
              ),
              new LayoutId(
                id: _HeadingLayout.product,
                child: new _ProductItem(
                  product: product,
                  quantity: quantity,
                  onChanged: quantityChanged,
                ),
              ),
              new LayoutId(
                id: _HeadingLayout.vendor,
                child: new _VendorItem(vendor: product.vendor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderPage extends StatefulWidget {
  OrderPage({
    Key key,
    @required this.order,
  })  : assert(order != null),
        super(key: key);

  final Order order;

  @override
  _OrderPageState createState() => new _OrderPageState();
}

// Displays a product's heading above photos of all of the other products
// arranged in two columns. Enables the user to specify a quantity and add an
// order to the shopping cart.
class _OrderPageState extends State<OrderPage> {
  GlobalKey<ScaffoldState> scaffoldKey;
  static final ShrineGridDelegate gridDelegate = new ShrineGridDelegate();

  @override
  void initState() {
    super.initState();
    scaffoldKey = new GlobalKey<ScaffoldState>(
        debugLabel: 'Shrine Order ${widget.order}');
  }

  Order get currentOrder => ShrineOrderRoute.of(context).order;

  set currentOrder(Order value) {
    ShrineOrderRoute.of(context).order = value;
  }

  void updateOrder(int quantity) {
    final Order newOrder = currentOrder.copyWith(quantity: quantity);
    if (currentOrder != newOrder) {
      setState(() {
        currentOrder = newOrder;
      });
    }
  }

  void showSnackBarMessage(String message) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (context, vm) {
        return new ShrinePage(
          scaffoldKey: scaffoldKey,
          floatingActionButton: new FloatingActionButton(
            onPressed: () {
              vm.onAddToCart(currentOrder);
              final int n = currentOrder.quantity;
              final String item = currentOrder.product.name;
              showSnackBarMessage('В корзине $n $item.');
            },
            backgroundColor: const Color(0xFF16F0F0),
            child: const Icon(
              Icons.add_shopping_cart,
              color: Colors.black,
            ),
          ),
          body: new CustomScrollView(
            slivers: <Widget>[
              new SliverToBoxAdapter(
                child: new _Heading(
                  product: widget.order.product,
                  quantity: currentOrder.quantity,
                  quantityChanged: (int value) {
                    updateOrder(value);
                  },
                ),
              ),
              new SliverSafeArea(
                top: false,
                minimum: const EdgeInsets.all(16.0),
                sliver: new SliverGrid(
                  gridDelegate: gridDelegate,
                  delegate: new SliverChildListDelegate(
                    vm.products
                        .where((Product product) =>
                            product != widget.order.product)
                        .map((Product product) {
                      return new ProductItem(
                        product: product,
                        parentContext: context,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final List<Product> products;
  final Map<Product, Order> shoppingCart;
  final Function(Order) onAddToCart;

  _ViewModel({
    @required this.products,
    @required this.shoppingCart,
    @required this.onAddToCart,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(
      products: store.state.products,
      shoppingCart: store.state.shoppingCart,
      onAddToCart: (order) =>
          store.dispatch(new AddToCartAction(order.product, order)),
    );
  }
}
