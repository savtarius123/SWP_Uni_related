import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swp_group_app/application/auth_state_provider.dart';
import 'package:swp_group_app/application/auth_status.dart';
import 'package:swp_group_app/routes/app_router.dart';

class AuthGuard extends AutoRouteGuard {
  final Ref<AppRouter> ref;

  AuthGuard(this.ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    ref.watch(authStateProvider).when(
      data: (value) {
        if (value == AuthStatus.authenticated) {
          resolver.next(true);
        } else {
          resolver.next(false);
          router.push(LoginRoute());
        }
      },
      loading: () {
        resolver.next(false);
      },
      error: (error, stack) {
        resolver.next(false);
        router.push(LoginRoute());
      },
    );
  }
}
