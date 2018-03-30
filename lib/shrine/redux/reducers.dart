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

final loadingReducer = combineReducers<bool>([
  new TypedReducer<bool, ProductsLoadedAction>(_setLoaded),
  new TypedReducer<bool, ProductsNotLoadedAction>(_setLoaded),
]);

bool _setLoaded(bool state, action) {
  return false;
}

final productsReducer = combineReducers<List<Product>>([
  new TypedReducer<List<Product>, ProductsLoadedAction>(_setLoadedProducts),
  new TypedReducer<List<Product>, ProductsNotLoadedAction>(_setNoProducts),
  new TypedReducer<List<Product>, ProductsSortByNameAction>(
      _sortProductsByName),
  new TypedReducer<List<Product>, ProductsSortByPriceAction>(
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

final shoppingCartReducer = combineReducers<Map<Product, Order>>([
  new TypedReducer<Map<Product, Order>, AddToCartAction>(_addToCart),
  new TypedReducer<Map<Product, Order>, ClearCartAction>(_clearCart),
]);

Map<Product, Order> _addToCart(Map<Product, Order> state, action) {
  Map<Product, Order> map = new Map.from(state);
  map[action.product] = action.order;
  return map;
}

Map<Product, Order> _clearCart(Map<Product, Order> state, action) {
  return new Map<Product, Order>();
}
