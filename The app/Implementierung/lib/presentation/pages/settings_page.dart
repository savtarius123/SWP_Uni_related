/// Allows to switch between general settings and setpoints / ranges with tabs
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/app_router.dart';

@RoutePage()
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsRouter.tabBar(
      routes: const [
        SettingsGeneralRoute(),
        SettingsRangesRoute(),
      ],
      builder: (context, child, tabController) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Column(
          children: [
            TabBar(
              controller: tabController,
              tabs: const [Tab(text: "General"), Tab(text: "Ranges")],
              onTap: (index) {
                tabsRouter.setActiveIndex(index);
              },
            ),
            Expanded(child: child)
          ],
        );
      },
    );
  }
}
