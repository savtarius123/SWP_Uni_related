import 'package:backend/config/config.dart';
import 'package:backend/model/src/database.dart';
import 'package:backend/server/router_utils.dart';
import 'package:backend/server/routes/auth_router.dart';
import 'package:backend/server/routes/user_router.dart';
import 'package:backend/server/routes/group_router.dart';
import 'package:backend/service/api_service.dart';
import 'package:backend/service/user_service.dart';
import 'package:backend/service/group_service.dart';
import 'package:shelf_router/shelf_router.dart';

abstract class BaseRouter {
  Router get router;

  late final AppDatabase db;
  late final Config config;
  late final String issuer;
  late final String secret;
  late final RouterUtils utils;

  late final UserService userService;
  late final GroupService groupService;
  late final ApiService apiService;

  BaseRouter(this.db, this.config)
      : utils = RouterUtils(db, config),
        userService = UserService(db, config),
        groupService = GroupService(db, config),
        apiService = ApiService(db, config);
}

class Routes extends BaseRouter {
  Routes(final AppDatabase db, final Config config) : super(db, config);

  @override
  Router get router {
    final router = Router();
    final userRouter = UserRouter(db, config);
    final groupRouter = GroupRouter(db, config);
    final securityRouter = AuthRouter(db, config);

    router.mount('/api/user/', userRouter.router.call);
    router.mount('/api/group/', groupRouter.router.call);
    router.mount('/api/auth/', securityRouter.router.call);

    return router;
  }
}
