/// Monitors Route changes and updates the currentRouteProvider accordingly
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'providers/current_route_provider.dart';

class RouteRefreshObserver extends AutoRouterObserver {
  final BuildContext context;
  final WidgetRef ref;

  RouteRefreshObserver(this.context, this.ref);

  final log = Logger("RouteRefreshObserver");

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.data != null) {
      ref.read(currentRouteProvider.notifier).update(route, context);
    } else {
      log.info("No Route Data");
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    ref.read(currentRouteProvider.notifier).update(previousRoute, context);
  }
}
