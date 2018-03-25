import 'actions.dart';
import 'package:redux/redux.dart';
import 'app_state.dart';
import '../shrine_types.dart';

// We create the State reducer by combining many smaller reducers into one!
AppState appReducer(AppState state, action) {
  return new AppState(
    isLoading: loadingReducer(state.isLoading, action),
    products: productsReducer(state.products, action),
    //products: _setLoadedProducts(state.products, action),
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
]);

List<Product> _setLoadedProducts(List<Product> state, action) {
  return action.products;
}

List<Product> _setNoProducts(List<Product> state, action) {
  return [];
}

final shoppingCartReducer = combineTypedReducers<Map<Product, Order>>([
  new ReducerBinding<Map<Product, Order>, AddToCartAction>(_addToCart),
  new ReducerBinding<Map<Product, Order>, ClearCartAction>(_clearCart),
]);

Map<Product, Order> _addToCart(Map<Product, Order> state, action) {
  Map<Product, Order> map = new Map.from(state);
  map[action.product] = action.order;
  return map;
}

Map<Product, Order> _clearCart(Map<Product, Order> state, action) {
  return new Map<Product, Order>();
}
