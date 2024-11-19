import 'package:backend/config/config.dart';
import 'package:backend/model/src/database.dart';
import 'package:backend/service/user_service.dart';
import 'package:backend/util/job_scheduler.dart';
import 'package:backend/util/logger_provider.dart';

class UserCleaner extends Job {
  late final UserService _userService;

  UserCleaner(super.interval, super.immediate, AppDatabase db, Config config) {
    _userService = UserService(db, config);
    log = LoggerProvider.instance;
    name = 'InactiveUsersCleaningJob';
  }

  @override
  void task() {
    _userService.deleteInactiveUsers();
  }
}
