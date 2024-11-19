import 'dart:io';

import 'package:backend/config/production_config.dart';
import 'package:backend/exception/service_exception.dart';
import 'package:backend/middleware/api_token_manager.dart';
import 'package:backend/model/src/database.dart';
import 'package:backend/server/base_router.dart';
import 'package:backend/service/group_service.dart';
import 'package:backend/service/user_service.dart';
import 'package:backend/util/group_cleaner.dart';
import 'package:backend/util/job_scheduler.dart';
import 'package:backend/util/logger_provider.dart';
import 'package:backend/util/user_cleaner.dart';
import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> arguments) async {
  final String logLevel = Platform.environment['LOG_LEVEL'] ?? 'info';
  LoggerProvider.configureLogger(logLevel);

  // Initialize the logger
  final Logger log = LoggerProvider.instance;
  log.i('Starting server');

  // Initialize the configuration
  final ProductionConfig config = ProductionConfig();

  // Initialize the database
  final AppDatabase db = AppDatabase(config.DATABASE_PATH, );

  // Add a default admin user if none exists
  UserService(db, config)
      .createDefaultAdmin()
      .then((_) => log.i('Default admin created'))
      .catchError((error) => log.i('Error creating default admin: $error'));

  try {
    final admin = await UserService(db, config)
        .getUserByEmail(config.DEFAULT_ADMIN_EMAIL);

    // Add a default admin group if none exists
    await GroupService(db, config).createGroupWithUser(
        admin['data']['id'], 'Admin Group', 'The default admin group');
  } on ServiceException catch (e) {
    switch (e.errorCode) {
      case HttpErrorStatus.notFound:
        log.i('Could not find default admin user');
        break;
      case HttpErrorStatus.conflict:
        log.i('Default admin group already exists');
        break;
      default:
        log.e('Error creating default admin group: $e');
    }
  }

  // Initialize the routes
  final Routes service = Routes(db, config);
  final Router router = service.router;

  // Configure the job scheduler
  final JobScheduler jobScheduler = JobScheduler();

  jobScheduler.addJob(UserCleaner(
      Duration(minutes: config.INACTIVE_USER_MINUTES), true, db, config));
  jobScheduler.addJob(GroupCleaner(
      Duration(days: config.INVITATION_EXPIRATION_DAYS), true, db, config));

  // Start all jobs
  jobScheduler.startAll();

  // Generate an API debug token
  String apiDebugToken = ApiTokenManger(config)
      .generateToken(config.DEFAULT_ADMIN_EMAIL, daysValid: 365);
  log.i('API Debug Token: $apiDebugToken');

  // Add middleware here if needed
  final Handler handler = Pipeline()
      .addHandler(router.call);

  // Run the server
  await io
      .serve(handler, config.API_HOST, config.API_PORT)
      .then((_) => log
          .i('Server running on http://${config.API_HOST}:${config.API_PORT}'))
      .catchError((error) {
    log.e('Error: $error');
    exit(1);
  });
}
