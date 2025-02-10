/// Display a 3D model of the Habitat front and Center
///
/// Authors:
///   * Heye Hamadmad
///   * Mohamed Aziz Mani
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/habitat.dart';
import '../widgets/hw_3d_display.dart';

@RoutePage()
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(80),
          child: Hw3dDisplay(),
        ),
        Expanded(child: Habitat())
      ],
    );
  }
}
