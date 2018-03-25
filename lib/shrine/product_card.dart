import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'shrine_theme.dart';
import 'shrine_types.dart';
import 'shrine_utils.dart';
import 'shrine_order.dart';

const double unitSize = kToolbarHeight;

// Displays the Vendor's name and avatar.
class _VendorItem extends StatelessWidget {
  const _VendorItem({Key key, @required this.vendor})
      : assert(vendor != null),
        super(key: key);

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      height: 24.0,
      child: new Row(
        children: <Widget>[
          new SizedBox(
            width: 24.0,
            child: new ClipRRect(
              borderRadius: new BorderRadius.circular(12.0),
              child: new Image.network(vendor.imageUrl, fit: BoxFit.cover),
              /*
              child: new Image.asset(
                vendor.avatarAsset,
                package: vendor.avatarAssetPackage,
                fit: BoxFit.cover,
              ),
              */
            ),
          ),
          const SizedBox(width: 8.0),
          new Expanded(
            child: new Text(vendor.name,
                style: ShrineTheme.of(context).vendorItemStyle),
          ),
        ],
      ),
    );
  }
}

// Displays the product's price. If the product is in the shopping cart then the
// background is highlighted.
abstract class _PriceItem extends StatelessWidget {
  const _PriceItem({Key key, @required this.product})
      : assert(product != null),
        super(key: key);

  final Product product;

  Widget buildItem(BuildContext context, TextStyle style, EdgeInsets padding) {
    BoxDecoration decoration;
    if (shoppingCart[product] != null)
      decoration =
          new BoxDecoration(color: ShrineTheme.of(context).priceHighlightColor);

    return new Container(
      padding: padding,
      decoration: decoration,
      child: new Text(product.priceString, style: style),
    );
  }
}

class _ProductPriceItem extends _PriceItem {
  const _ProductPriceItem({Key key, Product product})
      : super(key: key, product: product);

  @override
  Widget build(BuildContext context) {
    return buildItem(
      context,
      ShrineTheme.of(context).priceStyle,
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }
}

class _FeaturePriceItem extends _PriceItem {
  const _FeaturePriceItem({Key key, Product product})
      : super(key: key, product: product);

  @override
  Widget build(BuildContext context) {
    return buildItem(
      context,
      ShrineTheme.of(context).featurePriceStyle,
      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
    );
  }
}

class _HeadingLayout extends MultiChildLayoutDelegate {
  _HeadingLayout();

  static const String price = 'price';
  static const String image = 'image';
  static const String title = 'title';
  static const String description = 'description';
  static const String vendor = 'vendor';

  @override
  void performLayout(Size size) {
    final Size priceSize = layoutChild(price, new BoxConstraints.loose(size));
    positionChild(price, new Offset(size.width - priceSize.width, 0.0));

    final double halfWidth = size.width / 2.0;
    final double halfHeight = size.height / 2.0;
    final double halfUnit = unitSize / 2.0;
    const double margin = 16.0;

    final Size imageSize = layoutChild(image, new BoxConstraints.loose(size));
    final double imageX = imageSize.width < halfWidth - halfUnit
        ? halfWidth / 2.0 - imageSize.width / 2.0 - halfUnit
        : halfWidth - imageSize.width;
    positionChild(
        image, new Offset(imageX, halfHeight - imageSize.height / 2.0));

    final double maxTitleWidth = halfWidth + unitSize - margin;
    final BoxConstraints titleBoxConstraints =
        new BoxConstraints(maxWidth: maxTitleWidth);
    final Size titleSize = layoutChild(title, titleBoxConstraints);
    final double titleX = halfWidth - unitSize;
    final double titleY = halfHeight - titleSize.height;
    positionChild(title, new Offset(titleX, titleY));

    final Size descriptionSize = layoutChild(description, titleBoxConstraints);
    final double descriptionY = titleY + titleSize.height + margin;
    positionChild(description, new Offset(titleX, descriptionY));

    layoutChild(vendor, titleBoxConstraints);
    final double vendorY = descriptionY + descriptionSize.height + margin;
    positionChild(vendor, new Offset(titleX, vendorY));
  }

  @override
  bool shouldRelayout(_HeadingLayout oldDelegate) => false;
}

// A card that highlights the "featured" catalog item.
class Heading extends StatelessWidget {
  Heading({Key key, @required this.product})
      : assert(product != null),
        assert(product.featureTitle != null),
        assert(product.featureDescription != null),
        super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final ShrineTheme theme = ShrineTheme.of(context);
    return new MergeSemantics(
      child: new SizedBox(
        height: screenSize.width > screenSize.height
            ? (screenSize.height - kToolbarHeight) * 0.85
            : (screenSize.height - kToolbarHeight) * 0.70,
        child: new Container(
          decoration: new BoxDecoration(
            color: theme.cardBackgroundColor,
            border:
                new Border(bottom: new BorderSide(color: theme.dividerColor)),
          ),
          child: new CustomMultiChildLayout(
            delegate: new _HeadingLayout(),
            children: <Widget>[
              new LayoutId(
                id: _HeadingLayout.price,
                child: new _FeaturePriceItem(product: product),
              ),
              new LayoutId(
                id: _HeadingLayout.image,
                child: new Image.network(product.imageUrl, fit: BoxFit.cover),
              ),
              new LayoutId(
                id: _HeadingLayout.title,
                child: new Text(product.featureTitle,
                    style: theme.featureTitleStyle),
              ),
              new LayoutId(
                id: _HeadingLayout.description,
                child: new Text(product.featureDescription,
                    style: theme.featureStyle),
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

// A card that displays a product's image, price, and vendor. The _ProductItem
// cards appear in a grid below the heading.
class ProductItem extends StatelessWidget {
  const ProductItem(
      {Key key,
      @required this.product,
      this.parentContext,
      this.products,
      this.shoppingCart})
      : assert(product != null),
        super(key: key);

  final Product product;
  final Map<Product, Order> shoppingCart;
  final List<Product> products;
  final BuildContext parentContext;
  //final VoidCallback onPressed;
  Future<Null> _showOrderPage() async {
    final Order order = shoppingCart[product] ?? new Order(product: product);
    final Order completedOrder = await Navigator.push(
        parentContext,
        new ShrineOrderRoute(
            order: order,
            builder: (BuildContext context) {
              return new OrderPage(
                order: order,
                products: products,
                shoppingCart: shoppingCart,
              );
            }));
    assert(completedOrder.product != null);
    if (completedOrder.quantity == 0)
      shoppingCart.remove(completedOrder.product);
  }

  @override
  Widget build(BuildContext context) {
    return new MergeSemantics(
      child: new Card(
        child: new Stack(
          children: <Widget>[
            new Column(
              children: <Widget>[
                new Align(
                  alignment: Alignment.centerRight,
                  child: new _ProductPriceItem(product: product),
                ),
                new Container(
                  width: 144.0,
                  height: 144.0,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: new Hero(
                    tag: product.tag,
                    child:
                        new Image.network(product.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: new _VendorItem(vendor: product.vendor),
                ),
              ],
            ),
            new Material(
              type: MaterialType.transparency,
              child: new InkWell(onTap: _showOrderPage),
            ),
          ],
        ),
      ),
    );
  }
}
