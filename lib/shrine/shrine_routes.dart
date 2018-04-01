import 'package:flutter/material.dart';
import 'shrine_theme.dart' show ShrineTheme;
import 'shrine_types.dart';
import 'package:flutter/foundation.dart';

// This code would ordinarily be part of the MaterialApp's home. It's being
// used by the ShrineDemo and by each route pushed from there because this
// isn't a standalone app with its own main() and MaterialApp.
Widget buildShrine(BuildContext context, Widget child) {
  return new Theme(
      data: new ThemeData(
        primaryColor: Colors.blueGrey.shade400,
        primarySwatch: Colors.blueGrey,
        iconTheme: const IconThemeData(color: const Color(0xAAFFFFFF)),
        platform: Theme.of(context).platform,
      ),
      child: new ShrineTheme(child: child));
}

// In a standalone version of this app, MaterialPageRoute<T> could be used directly.
class ShrinePageRoute<T> extends MaterialPageRoute<T> {
  ShrinePageRoute(
      {WidgetBuilder builder, RouteSettings settings: const RouteSettings()})
      : super(builder: builder, settings: settings);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return buildShrine(
        context, super.buildPage(context, animation, secondaryAnimation));
  }
}

// Displays a full-screen modal CartPage.
class ShrineCartRoute extends ShrinePageRoute {
  ShrineCartRoute({
    WidgetBuilder builder,
    RouteSettings settings: const RouteSettings(),
  }) : super(builder: builder, settings: settings);

  static ShrineCartRoute of(BuildContext context) => ModalRoute.of(context);
}

// Displays a full-screen modal OrderPage.
//
// The order field will be replaced each time the user reconfigures the order.
// When the user backs out of this route the completer's value will be the
// final value of the order field.
class ShrineOrderRoute extends ShrinePageRoute<Order> {
  ShrineOrderRoute({
    @required this.order,
    WidgetBuilder builder,
    RouteSettings settings: const RouteSettings(),
  })  : assert(order != null),
        super(builder: builder, settings: settings);

  Order order;

  @override
  Order get currentResult => order;

  static ShrineOrderRoute of(BuildContext context) => ModalRoute.of(context);
}
