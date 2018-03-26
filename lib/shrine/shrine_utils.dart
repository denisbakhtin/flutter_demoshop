import 'package:flutter/material.dart';
import 'shrine_theme.dart' show ShrineTheme;
import 'globals.dart' as globals;
import 'package:flutter_redux/flutter_redux.dart';
import 'redux/app_state.dart';

// This code would ordinarily be part of the MaterialApp's home. It's being
// used by the ShrineDemo and by each route pushed from there because this
// isn't a standalone app with its own main() and MaterialApp.
Widget buildShrine(BuildContext context, Widget child) {
  return new Theme(
      data: new ThemeData(
        primarySwatch: Colors.grey,
        iconTheme: const IconThemeData(color: const Color(0xFF707070)),
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
    return new StoreProvider<AppState>(
      store: globals.store,
      child: buildShrine(
          context, super.buildPage(context, animation, secondaryAnimation)),
    );
  }
}
