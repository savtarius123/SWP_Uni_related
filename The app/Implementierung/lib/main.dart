/// Root of the application and the most general initialization logic
///
/// Authors:
///   * Heye Hamadmad
///   * Mohamed Aziz Mani
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'application/providers/chat_provider.dart';
import 'application/providers/influx_init_provider.dart';
import 'application/providers/mqtt_timeseries_adapter_provider.dart';
import 'application/route_refresh_observer.dart';
import 'routes/app_router.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EagerInitialization(
        child: MaterialApp.router(
      title: 'Crash & Burn Hab UI',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter().config(
        navigatorObservers: () => [RouteRefreshObserver(context, ref)],
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
    ));
  }
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize providers by watching them.
    // By using "watch", the provider will stay alive and not be disposed.
    // https://riverpod.dev/docs/essentials/eager_initialization
    ref.watch(
        mqttTimeseriesAdapterProvider); //Ensure that timeseries get pushed from MQTT
    ref.watch(influxInitProvider);
    ref.watch(chatProvider);

    return child;
  }
}
