import 'actions.dart';
import 'package:redux/redux.dart';
import 'app_state.dart';
import '../shrine_types.dart';

// We create the State reducer by combining many smaller reducers into one!
AppState appReducer(AppState state, action) {
  return new AppState(
    isLoading: loadingReducer(state.isLoading, action),
    products: productsReducer(state.products, action),
    shoppingCart: shoppingCartReducer(state.shoppingCart, action),
  );
}

final loadingReducer = combineTypedReducers<bool>([
  new ReducerBinding<bool, ProductsLoadedAction>(_setLoaded),
  new ReducerBinding<bool, ProductsNotLoadedAction>(_setLoaded),
]);

bool _setLoaded(bool state, action) {
  return false;
}

final productsReducer = combineTypedReducers<List<Product>>([
  new ReducerBinding<List<Product>, ProductsLoadedAction>(_setLoadedProducts),
  new ReducerBinding<List<Product>, ProductsNotLoadedAction>(_setNoProducts),
  new ReducerBinding<List<Product>, ProductsSortByNameAction>(
      _sortProductsByName),
  new ReducerBinding<List<Product>, ProductsSortByPriceAction>(
      _sortProductsByPrice),
]);

List<Product> _setLoadedProducts(List<Product> state, action) {
  return action.products;
}

List<Product> _setNoProducts(List<Product> state, action) {
  return [];
}

List<Product> _sortProductsByName(List<Product> state, action) {
  List<Product> result = new List.from(state);
  result.sort((Product a, Product b) => a.name.compareTo(b.name));
  return result;
}

List<Product> _sortProductsByPrice(List<Product> state, action) {
  List<Product> result = new List.from(state);
  result.sort((Product a, Product b) => a.price.compareTo(b.price));
  return result;
}

final shoppingCartReducer = combineTypedReducers<Map<Product, Order>>([
  new ReducerBinding<Map<Product, Order>, AddToCartAction>(_addToCart),
  new ReducerBinding<Map<Product, Order>, ClearCartAction>(_clearCart),
  new ReducerBinding<Map<Product, Order>, CartItemChangedAction>(
      _itemChangedCart),
  new ReducerBinding<Map<Product, Order>, CartItemRemovedAction>(
      _itemRemovedCart),
]);

Map<Product, Order> _addToCart(Map<Product, Order> state, action) {
  Map<Product, Order> map = new Map.from(state);
  map[action.product] = action.order;
  return map;
}

Map<Product, Order> _clearCart(Map<Product, Order> state, action) {
  return new Map<Product, Order>();
}

Map<Product, Order> _itemChangedCart(Map<Product, Order> state, action) {
  Order order = action.order.copyWith(quantity: action.quantity);
  Map<Product, Order> map = new Map.from(state);
  map[action.order.product] = order;
  return map;
}

Map<Product, Order> _itemRemovedCart(Map<Product, Order> state, action) {
  Map<Product, Order> map = new Map.from(state);
  map.remove(action.order.product);
  return map;
}
