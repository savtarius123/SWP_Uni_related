import 'package:backend/config/config.dart';
import 'package:backend/model/src/database.dart';
import 'package:backend/service/group_service.dart';
import 'package:backend/util/job_scheduler.dart';
import 'package:backend/util/logger_provider.dart';

class GroupCleaner extends Job {
  late final GroupService _groupService;

  GroupCleaner(super.interval, super.immediate, AppDatabase db, Config config) {
    _groupService = GroupService(db, config);
    log = LoggerProvider.instance;
    name = 'TentativeMembersCleaningJob';
  }

  @override
  void task() {
    _groupService.deleteTentativeMembers();
  }
}
