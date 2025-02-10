/// The routes and titles of pages within the app
///
/// Authors:
///   * Heye Hamadmad
///   * Cem Igci
///   * Mohamed Aziz Mani
///   * Arin Tanriverdi
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../models/display_group.dart';
import '../presentation/pages/app_page.dart';
import '../presentation/pages/chat_page.dart';
import '../presentation/pages/dashboard_page.dart';
import '../presentation/pages/env_values_avg_page.dart';
import '../presentation/pages/settings_general_page.dart';
import '../presentation/pages/settings_page.dart';
import '../presentation/pages/settings_ranges_page.dart';
import '../presentation/pages/time_series_overview_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
            path: "/",
            title: (context, data) => "Crash & Burn Hab UI",
            page: AppRoute.page,
            initial: true,
            children: [
              AutoRoute(
                path: '',
                page: DashboardRoute.page,
                title: (context, data) => 'Dashboard',
                initial: true,
              ),
              AutoRoute(
                path: 'env_values_avg',
                page: EnvValuesAvgRoute.page,
                title: (context, data) => 'Environmental Values (avg)',
              ),
              AutoRoute(
                path: 'time_series_overview',
                page: TimeSeriesOverviewRoute.page,
                title: (context, data) => 'Individual Sensors',
              ),
              AutoRoute(
                path: 'chat',
                page: ChatRoute.page,
                title: (context, data) => 'Chat',
              ),
              AutoRoute(
                  path: 'settings',
                  page: SettingsRoute.page,
                  title: (context, data) => 'Settings',
                  children: [
                    AutoRoute(
                      path: 'general',
                      page: SettingsGeneralRoute.page,
                      title: (context, data) => 'General Settings',
                      initial: true,
                    ),
                    AutoRoute(
                      path: 'ranges',
                      page: SettingsRangesRoute.page,
                      title: (context, data) => 'Ranges / Setpoints',
                    ),
                  ]),
            ])
      ];
}
