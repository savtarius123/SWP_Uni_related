/// The page to rule them all; contains a Scaffold with a title and handles general application layout
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/current_route_provider.dart';
import '../widgets/main_menu.dart';
import '../widgets/sidebar.dart';

@RoutePage()
class AppPage extends ConsumerWidget {
  const AppPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.watch(pageTitleProvider) ?? ""),
      ),
      body: const Row(
        children: [
          MainMenu(),
          Expanded(child: AutoRouter()),
          Sidebar(),
        ],
      ),
    );
  }
}
