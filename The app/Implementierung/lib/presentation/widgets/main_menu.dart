/// Sidebar on the left with buttons to allow navigation within app
///
/// Authors:
///   * Heye Hamadmad
///   * Mohamed Aziz Mani
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/game_icons.dart';

import '../../application/providers/current_route_provider.dart';
import '../../routes/app_router.dart';
// widget

class MainMenu extends ConsumerWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRouteName = ref.watch(currentRouteProvider)?.settings.name;
    final navigationItems = [
      (const DashboardRoute(), const Icon(Icons.home)),
      (const EnvValuesAvgRoute(), const Iconify(GameIcons.computer_fan)),
      (TimeSeriesOverviewRoute(), const Iconify(Bi.graph_up)),
      (const ChatRoute(), const Icon(Icons.chat)),
      (const SettingsRoute(), const Icon(Icons.settings)),
    ];

    return Column(
        children: navigationItems
            .map((navigationItem) => Expanded(
                child: _NavigationButton(
                    icon: navigationItem.$2,
                    route: navigationItem.$1,
                    selected: navigationItem.$1.routeName == currentRouteName)))
            .toList());
  }
}

class _NavigationButton extends StatelessWidget {
  final Widget icon;
  final PageRouteInfo route;
  final bool selected;

  const _NavigationButton(
      {required this.icon, required this.route, required this.selected});

  @override
  Widget build(BuildContext context) {
    // This looks convoluted but is the simplest way to get the page title
    // function for a route
    final titleFunction = context
        .router.routeCollection.routes.firstOrNull?.children?.routes
        .firstWhere((routerroute) => routerroute.name == route.routeName)
        .title;

    return Tooltip(
        margin: EdgeInsets.only(left: 50),
        message: titleFunction != null
            ? titleFunction(context, context.routeData)
            : "Untitled page",
        child: InkWell(
          onTap: selected
              ? null
              : () {
                  context.router.navigate(route);
                },
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Opacity(opacity: selected ? 0.2 : 1, child: icon)),
        ));
  }
}
