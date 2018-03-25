import 'redux/app_state.dart';
import 'redux/reducers.dart';
import 'redux/middleware.dart';
import 'package:redux/redux.dart';

final store = new Store<AppState>(appReducer,
    initialState: new AppState.loading(), middleware: createStoreMiddleware());
