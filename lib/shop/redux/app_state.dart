import 'package:meta/meta.dart';
import '../shared/types.dart';

@immutable
class AppState {
  final bool isLoading;
  final List<Product> products;
  final Map<Product, Order> shoppingCart;

  AppState({
    this.isLoading = false,
    this.products = const [],
    this.shoppingCart = const <Product, Order>{},
  });

  factory AppState.loading() => new AppState(isLoading: true);

  AppState copyWith({
    bool isLoading,
    List<Product> products,
    Map<Product, Order> shoppingCart,
  }) {
    return new AppState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      shoppingCart: shoppingCart ?? this.shoppingCart,
    );
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^ products.hashCode ^ shoppingCart.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          products == other.products &&
          shoppingCart == other.shoppingCart;

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading, products: $products, shoppingCart: $shoppingCart}';
  }
}
