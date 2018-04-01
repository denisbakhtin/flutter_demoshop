import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'shrine_page.dart';
import 'shrine_types.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'redux/app_state.dart';
import 'redux/actions.dart';
import 'shrine_theme.dart';

class CartPage extends StatefulWidget {
  CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => new _CartPageState();
}

const double _quantityColumnWidth = 50.0;

class _CartPageState extends State<CartPage> {
  final GlobalKey<ScaffoldState> scaffoldKey =
      new GlobalKey<ScaffoldState>(debugLabel: 'Shrine Cart Page');

  @override
  Widget build(BuildContext context) {
    final ShrineTheme theme = ShrineTheme.of(context);
    return new StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (context, vm) {
        if (vm.shoppingCart.isEmpty) {
          return new ShrinePage(
            scaffoldKey: scaffoldKey,
            body: new Center(child: new Text('Ваша корзина пуста')),
          );
        }
        return new ShrinePage(
          scaffoldKey: scaffoldKey,
          floatingActionButton: new FloatingActionButton(
            onPressed: () => vm.onCheckout(context),
            child: new Icon(
              Icons.check,
              color: theme.floatingActionButtonColor,
            ),
          ),
          body: new CustomScrollView(slivers: <Widget>[
            new Header(),
            new SliverList(
              delegate: new SliverChildListDelegate(
                vm.products.map((Product product) {
                  return new CartItem(new ObjectKey(vm.shoppingCart[product]),
                      vm.shoppingCart[product]);
                }).toList(),
              ),
            ),
            new Footer(vm.total),
          ]),
        );
      },
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ShrineTheme theme = ShrineTheme.of(context);
    return new SliverToBoxAdapter(
      child: new Container(
        decoration: new BoxDecoration(
            border:
                new Border(bottom: new BorderSide(color: theme.dividerColor))),
        padding: new EdgeInsets.all(16.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text(
                'Товар',
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            new Container(
              width: _quantityColumnWidth,
              child: new Text(
                'Кол-во',
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  final String total;
  Footer(this.total);

  @override
  Widget build(BuildContext context) {
    final ShrineTheme theme = ShrineTheme.of(context);
    return new SliverToBoxAdapter(
      child: new Container(
        decoration: new BoxDecoration(
            border: new Border(top: new BorderSide(color: theme.dividerColor))),
        padding: new EdgeInsets.all(16.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text(
                'Итого',
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            new Container(
              alignment: AlignmentDirectional.centerEnd,
              width: _quantityColumnWidth * 2,
              child: new Text(
                total,
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem extends StatefulWidget {
  CartItem(this.key, this.order) : super(key: key);
  final Order order;
  final Key key;

  @override
  _CartItemState createState() => new _CartItemState();
}

class _CartItemState extends State<CartItem> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        new TextEditingController(text: widget.order.quantity.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ItemViewModel>(
      converter: (store) => _ItemViewModel.fromStore(store, widget.order),
      builder: (context, vm) {
        return new Dismissible(
          key: widget.key,
          onDismissed: vm.onDismiss,
          child: new Card(
            child: new ListTile(
              leading: new Image.network(widget.order.product.imageUrl),
              title: new Text(widget.order.product.name),
              subtitle: new Text(widget.order.product.priceString),
              trailing: new SizedBox(
                width: _quantityColumnWidth,
                child: new TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    vm.onQuantityChange(widget.order, value);
                    _controller.text = validQuantity(value).toString();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final List<Product> products; //products in shoppingCart
  final Map<Product, Order> shoppingCart;
  final Function(Order) onAddToCart;
  final Function(BuildContext context) onCheckout;
  final String total;

  _ViewModel({
    @required this.products,
    @required this.shoppingCart,
    @required this.onAddToCart,
    @required this.onCheckout,
    @required this.total,
  });

  static num _totalSum(Map<Product, Order> cart) {
    return cart.isNotEmpty
        ? cart.keys
            .toList()
            .map((product) => product.price * cart[product].quantity)
            .reduce((value, element) => value + element)
        : 0;
  }

  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(
      products: store.state.shoppingCart.keys.toList(),
      shoppingCart: store.state.shoppingCart,
      onAddToCart: (order) =>
          store.dispatch(new AddToCartAction(order.product, order)),
      onCheckout: (BuildContext context) {
        store.dispatch(new ClearCartAction());
        Navigator.pop(context);
      },
      total: '${_totalSum(store.state.shoppingCart)} руб',
    );
  }
}

class _ItemViewModel {
  final Function(Order, String) onQuantityChange;
  final Function(DismissDirection) onDismiss;
  final Order order;

  _ItemViewModel({
    @required this.onQuantityChange,
    @required this.onDismiss,
    @required this.order,
  });

  static _ItemViewModel fromStore(Store<AppState> store, Order order) {
    return new _ItemViewModel(
      order: order,
      onQuantityChange: (order, quantity) => store
          .dispatch(new CartItemChangedAction(order, validQuantity(quantity))),
      onDismiss: (direction) =>
          store.dispatch(new CartItemRemovedAction(order)),
    );
  }
}

int validQuantity(String value) {
  int intval = int.parse(value, onError: (e) => null);
  return (intval != null && intval > 0) ? intval : 1;
}
