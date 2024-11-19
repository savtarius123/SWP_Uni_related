part of 'package:backend/model/src/database.dart';

@DriftAccessor(tables: [Users, LoginData])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<User?> getUserById(int id) async {
    return await (select(users)..where((u) => u.id.equals(id)))
        .getSingleOrNull();
  }

  Future<User?> getUserByEmail(String email) async {
    return await (select(users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  Future<bool> verifyLogin(String email, String pwd) async {
    final query = select(users).join([
      leftOuterJoin(loginData, loginData.userId.equalsExp(users.id)),
    ])
      ..where(users.email.equals(email) & loginData.password.equals(pwd));

    return await query
        .map((row) {
          return row.readTable(users).id;
        })
        .getSingleOrNull()
        .then((id) => id != null);
  }

  Future<String> getSaltByEmail(String email) async {
    return await (select(users).join([
          leftOuterJoin(loginData, loginData.userId.equalsExp(users.id)),
        ])
              ..where(users.email.equals(email)))
            .map((row) => row.readTable(loginData).salt)
            .getSingleOrNull() ??
        '';
  }

  Future<String?> getSaltById(int id) async {
    return await (select(loginData)..where((ld) => ld.userId.equals(id)))
        .map((row) => row.salt)
        .getSingleOrNull();
  }

  Future<bool> updateUserPassword(int id, String pwd, String salt) async {
    return await (update(loginData)..where((ld) => ld.userId.equals(id))).write(
            LoginDataCompanion(password: Value(pwd), salt: Value(salt))) >
        0;
  }

  Future<int> insertUser(
      UsersCompanion userCompanion, String password, String salt) async {
    return transaction(() async {
      final int id = await into(users).insert(userCompanion);
      await into(loginData).insert(LoginDataCompanion(
          userId: Value(id), password: Value(password), salt: Value(salt)));
      return id;
    });
  }

  Future<bool> updateUser(UsersCompanion userCompanion) async {
    return await update(users).replace(userCompanion);
  }

  Future<bool> deleteUser(int id) async {
    return await (delete(users)..where((u) => u.id.equals(id))).go() > 0;
  }

  Future<bool> deleteInactiveUsers() async {
    final deletionDelta = DateTime.now()
        .subtract(const Duration(days: DbConfig.INACTIVE_USER_DAYS));

    // Delete inactive users
    return await (select(loginData)
            .join([innerJoin(users, users.id.equalsExp(loginData.userId))])
          ..where(loginData.createdAt.isSmallerThanValue(deletionDelta) &
              users.active.equals(false)))
        .map((row) => row.readTable(users).id)
        .get()
        .then((ids) async {
      if (ids.isNotEmpty) {
        await (delete(users)..where((u) => u.id.isIn(ids))).go();
        await (delete(loginData)..where((ld) => ld.userId.isIn(ids))).go();
      }
      return true;
    });
  }

  Future<String?> getRefreshToken(int id) async {
    return await (select(loginData)..where((ld) => ld.userId.equals(id)))
        .map((row) => row.refreshToken)
        .getSingleOrNull();
  }

  Future<bool> updateRefreshToken(int id, String token) async {
    return await (update(loginData)..where((ld) => ld.userId.equals(id)))
            .write(LoginDataCompanion(refreshToken: Value(token))) >
        0;
  }

  Future<bool> invalidateRefreshToken(int id) async {
    return await (update(loginData)..where((ld) => ld.userId.equals(id)))
            .write(LoginDataCompanion(refreshToken: Value(null))) >
        0;
  }

  Future<bool> isAdmin(int id) async {
    return await (select(users)
          ..where((u) => u.id.equals(id) & u.role.equals(Role.ADMIN)))
        .getSingleOrNull()
        .then((user) => user != null);
  }
}
