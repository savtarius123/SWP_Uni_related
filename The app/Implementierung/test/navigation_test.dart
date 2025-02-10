/// Testing the navigation by finding and clicking on the page icons and verifying the clicked button will navigate to
/// a page accordingly
///
/// Authors:
///   * Cem Igci
// ignore_for_file: avoid_print

library;

import 'package:auto_route/auto_route.dart';
import 'package:crash_and_burn_marshabitat_ui/presentation/pages/chat_page.dart';
import 'package:crash_and_burn_marshabitat_ui/presentation/pages/dashboard_page.dart';
import 'package:crash_and_burn_marshabitat_ui/presentation/pages/env_values_avg_page.dart';
import 'package:crash_and_burn_marshabitat_ui/presentation/pages/settings_page.dart';
import 'package:crash_and_burn_marshabitat_ui/presentation/pages/time_series_overview_page.dart';
import 'package:crash_and_burn_marshabitat_ui/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/game_icons.dart';

void main() {
  late AppRouter appRouter;

  setUp(() {
    appRouter = AppRouter();
  });

  testWidgets('Navigation switches pages correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerDelegate: AutoRouterDelegate(appRouter),
          routeInformationParser: appRouter.defaultRouteParser(),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 15)); // Wait for UI to build
    print('UI built successfully');

    await tester.pump();

    // Verify Dashboard is displayed
    print('Verifying initial page is Dashboard');
    expect(find.byType(DashboardPage), findsOneWidget);
    print('Dashboard page is displayed');

    // Tap on the Average values button
    print('Testing EnvAvgValues Page icon');
    await tester.tap(find.byWidgetPredicate((widget) =>
        widget is Iconify && widget.icon == GameIcons.computer_fan));
    await tester.pump();
    print('Testing EnvAvgValues route');
    expect(find.byType(EnvValuesAvgPage),
        findsOneWidget); // Verify Avg page is displayed
    print('EnvValuesAvg Page Check');

    // Tap on the Sensorboards button
    print('Testing TimesSeriesOverView Page icon');
    await tester.tap(find.byWidgetPredicate(
        (widget) => widget is Iconify && widget.icon == Bi.graph_up));
    await tester.pump();
    print('Testing TimesSeriesOverView route');
    expect(find.byType(TimeSeriesOverviewPage),
        findsOneWidget); // Verify TimeSeriesOverviewPage is displayed
    print('TimesSeriesOverView Page Check');

    // Tap on the Chat button
    print('Testing Chat Page icon');
    await tester.tap(find.byIcon(Icons.chat));
    await tester.pump();
    print('Testing Chat page route');
    expect(find.byType(ChatPage), findsOneWidget); // Verify Chat is displayed
    print('Chat page is displayed');

    // Tap on the Settings button
    print('Testing Settings Page icon');
    await tester.tap(find.byIcon(Icons.settings));
    print('Testing Settings Page route');
    await tester.pump();
    expect(find.byType(SettingsPage),
        findsOneWidget); // Verify Settings is displayed
    print('Settings Page Check');

    // Tap on the Dashboard button
    print('Testing Dashboard Page icon');
    await tester.tap(find.byIcon(Icons.home));
    await tester.pump();
    print('Testing navigating back to Dashboard Page');
    expect(find.byType(DashboardPage),
        findsOneWidget); // Verify Dashboard is displayed
    print('Dashboard Page is displayed');
  });
}
