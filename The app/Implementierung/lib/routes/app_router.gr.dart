// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AppPage]
class AppRoute extends PageRouteInfo<void> {
  const AppRoute({List<PageRouteInfo>? children})
    : super(AppRoute.name, initialChildren: children);

  static const String name = 'AppRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppPage();
    },
  );
}

/// generated route for
/// [ChatPage]
class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatPage();
    },
  );
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardPage();
    },
  );
}

/// generated route for
/// [EnvValuesAvgPage]
class EnvValuesAvgRoute extends PageRouteInfo<void> {
  const EnvValuesAvgRoute({List<PageRouteInfo>? children})
    : super(EnvValuesAvgRoute.name, initialChildren: children);

  static const String name = 'EnvValuesAvgRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EnvValuesAvgPage();
    },
  );
}

/// generated route for
/// [SettingsGeneralPage]
class SettingsGeneralRoute extends PageRouteInfo<void> {
  const SettingsGeneralRoute({List<PageRouteInfo>? children})
    : super(SettingsGeneralRoute.name, initialChildren: children);

  static const String name = 'SettingsGeneralRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsGeneralPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [SettingsRangesPage]
class SettingsRangesRoute extends PageRouteInfo<void> {
  const SettingsRangesRoute({List<PageRouteInfo>? children})
    : super(SettingsRangesRoute.name, initialChildren: children);

  static const String name = 'SettingsRangesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsRangesPage();
    },
  );
}

/// generated route for
/// [TimeSeriesOverviewPage]
class TimeSeriesOverviewRoute
    extends PageRouteInfo<TimeSeriesOverviewRouteArgs> {
  TimeSeriesOverviewRoute({
    Key? key,
    String? highlightedTopic,
    HwCategory? selectedHwCategory,
    int? selectedHwInstance,
    DisplayGroup? selectedDisplayGroup,
    List<PageRouteInfo>? children,
  }) : super(
         TimeSeriesOverviewRoute.name,
         args: TimeSeriesOverviewRouteArgs(
           key: key,
           highlightedTopic: highlightedTopic,
           selectedHwCategory: selectedHwCategory,
           selectedHwInstance: selectedHwInstance,
           selectedDisplayGroup: selectedDisplayGroup,
         ),
         initialChildren: children,
       );

  static const String name = 'TimeSeriesOverviewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TimeSeriesOverviewRouteArgs>(
        orElse: () => const TimeSeriesOverviewRouteArgs(),
      );
      return TimeSeriesOverviewPage(
        key: args.key,
        highlightedTopic: args.highlightedTopic,
        selectedHwCategory: args.selectedHwCategory,
        selectedHwInstance: args.selectedHwInstance,
        selectedDisplayGroup: args.selectedDisplayGroup,
      );
    },
  );
}

class TimeSeriesOverviewRouteArgs {
  const TimeSeriesOverviewRouteArgs({
    this.key,
    this.highlightedTopic,
    this.selectedHwCategory,
    this.selectedHwInstance,
    this.selectedDisplayGroup,
  });

  final Key? key;

  final String? highlightedTopic;

  final HwCategory? selectedHwCategory;

  final int? selectedHwInstance;

  final DisplayGroup? selectedDisplayGroup;

  @override
  String toString() {
    return 'TimeSeriesOverviewRouteArgs{key: $key, highlightedTopic: $highlightedTopic, selectedHwCategory: $selectedHwCategory, selectedHwInstance: $selectedHwInstance, selectedDisplayGroup: $selectedDisplayGroup}';
  }
}
