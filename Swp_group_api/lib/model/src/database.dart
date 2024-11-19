import 'dart:async';
import 'dart:io';
import 'package:backend/config/config.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:logger/logger.dart';

part 'database.g.dart';
part 'group_dao.dart';
part 'user_dao.dart';
part 'user_group_dao.dart';

class DbConfig {
  static const int DATABASE_VERSION = 1;
  static const int USERNAME_MIN = 3;
  static const int USERNAME_MAX = 255;
  static const int EMAIL_MIN = 3;
  static const int EMAIL_MAX = 255;
  static const int PASSWORD_MIN = 8;
  static const int PASSWORD_MAX = 255;
  static const int GROUP_NAME_MIN = 3;
  static const int GROUP_NAME_MAX = 255;
  static const int GROUP_DESC_MIN = 3;
  static const int GROUP_DESC_MAX = 255;
  static const int SEC_SALT_LENGTH = 32;
  static const int INACTIVE_USER_DAYS = 1;
  static const int TENTATIVE_MEMBER_DAYS = 1;
}

class UserPlatform {
  static const int UNKNOWN = 0;
  static const int ANDROID = 1;
  static const int IOS = 2;
  static const int WEB = 3;
  static const int DESKTOP = 4;
  static const int OTHER = 5;

  static const int minItem = UNKNOWN;
  static const int maxItem = OTHER;
}

const int defaultPlatform = UserPlatform.UNKNOWN;

class Role {
  static const int USER = 0;
  static const int ADMIN = 1;

  static int minItem = USER;
  static int maxItem = ADMIN;
}

const int defaultRole = Role.USER;

// User table for storing user information.
class Users extends Table {
  IntColumn get id =>
      integer().withDefault(const Constant(1)).autoIncrement()();
  TextColumn get name => text()
      .withLength(min: DbConfig.USERNAME_MIN, max: DbConfig.USERNAME_MAX)();
  TextColumn get email => text()
      .withLength(min: DbConfig.EMAIL_MIN, max: DbConfig.EMAIL_MAX)
      .unique()();
  IntColumn get platform =>
      integer().withDefault(const Constant(defaultPlatform))();
  IntColumn get role => integer().withDefault(const Constant(defaultRole))();
  BoolColumn get active => boolean().withDefault(const Constant(false))();
}

class LoginData extends Table {
  IntColumn get userId => integer()
      .customConstraint('NOT NULL REFERENCES users(id) ON DELETE CASCADE')();
  TextColumn get password => text()
      .withLength(min: DbConfig.PASSWORD_MIN, max: DbConfig.PASSWORD_MAX)();
  TextColumn get salt => text().withLength(
      min: DbConfig.SEC_SALT_LENGTH, max: DbConfig.SEC_SALT_LENGTH)();
  TextColumn get refreshToken => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Group table for storing group information
class GroupDetails extends Table {
  IntColumn get id =>
      integer().withDefault(const Constant(1)).autoIncrement()();
  IntColumn get ownerId => integer()
      .customConstraint('NOT NULL REFERENCES users(id) ON DELETE CASCADE')();
  TextColumn get name => text()
      .withLength(min: DbConfig.GROUP_NAME_MIN, max: DbConfig.GROUP_NAME_MAX)
      .unique()();
  TextColumn get description => text()
      .withLength(min: DbConfig.GROUP_DESC_MIN, max: DbConfig.GROUP_DESC_MAX)();
}

class UserGroupMap extends Table {
  IntColumn get userId => integer()
      .customConstraint('NOT NULL REFERENCES users(id) ON DELETE CASCADE')();
  IntColumn get groupId => integer().customConstraint(
      'NOT NULL REFERENCES group_details(id) ON DELETE CASCADE')();
  BoolColumn get isOwner => boolean().withDefault(const Constant(false))();
  BoolColumn get isTentative => boolean().withDefault(const Constant(false))();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, groupId}
      ];
}

@DriftDatabase(
    tables: [Users, LoginData, GroupDetails, UserGroupMap],
    daos: [UserDao, GroupDao, UserGroupDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(final String filePath) : super(_openConnection(filePath));

  AppDatabase.fromExecutor(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          Logger().i('Activating PRAGMA foreign_keys');
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection(final String filePath) {
  return LazyDatabase(() async {
    final File file = File(filePath);
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}
