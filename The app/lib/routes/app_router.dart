import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_group_app/presentation/pages/home_page.dart';
import 'package:swp_group_app/presentation/pages/login_page.dart';
import 'package:swp_group_app/routes/auth_guard.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final Ref<AppRouter> ref;

  AppRouter(this.ref);

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: LoginRoute.page,
          title: (context, data) => 'Login Page',
        ),
        AutoRoute(
          path: '/home',
          page: HomeRoute.page,
          title: (context, data) => 'Home Page',
          guards: [AuthGuard(ref)],
        ),
      ];
}
