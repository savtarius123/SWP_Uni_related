/// Gets updated by RouteRefreshObserver so that every widget can get the current
/// route and title. Used in navigation.
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_route_provider.g.dart';

Route? _pageRoute;
BuildContext? _context;

@riverpod
class CurrentRoute extends _$CurrentRoute {
  @override
  Route? build() {
    return _pageRoute;
  }

  void update(Route? pageRoute, BuildContext context) {
    _pageRoute = pageRoute;
    _context = context;
    ref.invalidateSelf();
    ref.invalidate(pageTitleProvider);
  }
}

// Relies on library-local variables of currentRouteProvider and thus has to reside in the same file
@riverpod
class PageTitle extends _$PageTitle {
  @override
  String? build() {
    //return _pageRoute.
    return _context != null ? _pageRoute?.data?.title(_context!) : null;
  }
}
