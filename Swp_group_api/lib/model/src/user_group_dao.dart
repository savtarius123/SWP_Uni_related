part of 'package:backend/model/src/database.dart';

@DriftAccessor(tables: [UserGroupMap])
class UserGroupDao extends DatabaseAccessor<AppDatabase>
    with _$UserGroupDaoMixin {
  UserGroupDao(super.db);

  // Get all groups by user ID from the database.
  Future<List<GroupDetail>> getGroupsByUserId(
      int userId, int page, int pageSize) {
    final query = select(userGroupMap).join([
      innerJoin(groupDetails, groupDetails.id.equalsExp(userGroupMap.groupId)),
    ])
      ..where(userGroupMap.userId.equals(userId) &
          userGroupMap.isTentative.equals(false))
      ..limit(pageSize, offset: page * pageSize);

    return query.get().then((result) {
      return result.map((row) {
        return GroupDetail(
          id: row.readTable(groupDetails).id,
          name: row.readTable(groupDetails).name,
          description: row.readTable(groupDetails).description,
          ownerId: row.readTable(groupDetails).ownerId,
        );
      }).toList();
    });
  }

  Future<List<User>> getUsersByGroupId(int groupId, int page, int pageSize) {
    final query = select(userGroupMap).join([
      innerJoin(users, users.id.equalsExp(userGroupMap.userId)),
    ])
      ..where(userGroupMap.groupId.equals(groupId) &
          userGroupMap.isTentative.equals(false))
      ..limit(pageSize, offset: page * pageSize);

    return query.get().then((result) {
      return result.map((row) {
        return User(
          id: row.readTable(users).id,
          name: row.readTable(users).name,
          email: row.readTable(users).email,
          active: row.readTable(users).active,
          platform: row.readTable(users).platform,
          role: row.readTable(users).role,
        );
      }).toList();
    });
  }

  Future<List<User>> getTentativeUsersByGroupId(
      int groupId, int page, int pageSize) {
    final query = select(userGroupMap).join([
      innerJoin(users, users.id.equalsExp(userGroupMap.userId)),
    ])
      ..where(userGroupMap.groupId.equals(groupId) &
          userGroupMap.isTentative.equals(true))
      ..limit(pageSize, offset: page * pageSize);

    return query.get().then((result) {
      return result.map((row) {
        return User(
          id: row.readTable(users).id,
          name: row.readTable(users).name,
          email: row.readTable(users).email,
          active: row.readTable(users).active,
          platform: row.readTable(users).platform,
          role: row.readTable(users).role,
        );
      }).toList();
    });
  }

  Future<List<GroupDetail>> getTentativeGroupsByUserId(
      int userId, int page, int pageSize) {
    final query = select(userGroupMap).join([
      innerJoin(groupDetails, groupDetails.id.equalsExp(userGroupMap.groupId)),
    ])
      ..where(userGroupMap.userId.equals(userId) &
          userGroupMap.isTentative.equals(true))
      ..limit(pageSize, offset: page * pageSize);

    return query.get().then((result) {
      return result.map((row) {
        return GroupDetail(
          id: row.readTable(groupDetails).id,
          name: row.readTable(groupDetails).name,
          description: row.readTable(groupDetails).description,
          ownerId: row.readTable(groupDetails).ownerId,
        );
      }).toList();
    });
  }

  Future<User> getOwnerByGroupId(int groupId) async {
    return transaction(() async {
      final query = select(userGroupMap).join([
        innerJoin(users, users.id.equalsExp(userGroupMap.userId)),
      ])
        ..where(userGroupMap.groupId.equals(groupId) &
            userGroupMap.isOwner.equals(true));

      final row = await query.getSingle();

      return User(
        id: row.readTable(users).id,
        name: row.readTable(users).name,
        email: row.readTable(users).email,
        active: row.readTable(users).active,
        platform: row.readTable(users).platform,
        role: row.readTable(users).role,
      );
    });
  }

  Stream<List<User>> getOwnedGroupsByUserId(int userId) {
    final query = select(userGroupMap).join([
      innerJoin(users, users.id.equalsExp(userGroupMap.userId)),
    ])
      ..where(userGroupMap.userId.equals(userId) &
          userGroupMap.isOwner.equals(true));

    return query.watch().map((rows) {
      return rows.map((row) {
        return User(
          id: row.readTable(users).id,
          name: row.readTable(users).name,
          email: row.readTable(users).email,
          active: row.readTable(users).active,
          platform: row.readTable(users).platform,
          role: row.readTable(users).role,
        );
      }).toList();
    });
  }

  Future<int> addUserToGroup(int userId, int groupId,
      {bool isTentative = true}) async {
    return transaction(() async {
      final userGroupMapDetail = UserGroupMapCompanion.insert(
        userId: userId,
        groupId: groupId,
        isTentative: Value(isTentative),
      );

      return await into(userGroupMap).insert(userGroupMapDetail);
    });
  }

  Future<bool> removeUserFromGroup(int userId, int groupId) async {
    return transaction(() async {
      await (delete(userGroupMap)
            ..where(
                (ug) => ug.userId.equals(userId) & ug.groupId.equals(groupId)))
          .go()
          .then((value) => value > 0)
          .onError((error, stackTrace) => false);

      // Check if the user is the owner of the group, if so we must delete the
      // or else there would be an orphaned group with no owner.
      final bool isOwner = await (select(userGroupMap)
            ..where((ug) =>
                ug.userId.equals(userId) &
                ug.groupId.equals(groupId) &
                ug.isOwner.equals(true)))
          .getSingleOrNull()
          .then((value) => value != null);

      if (isOwner) {
        return await (delete(groupDetails)..where((g) => g.id.equals(groupId)))
                .go() >
            0;
      }

      return false;
    });
  }

  Future<int> createGroup(int userId, String name, String description) async {
    return transaction(() async {
      final GroupDetailsCompanion companion = GroupDetailsCompanion.insert(
        name: name,
        description: description,
        ownerId: userId,
      );

      final groupId = await into(groupDetails).insert(companion);

      final userGroupMapDetail = UserGroupMapCompanion.insert(
        userId: userId,
        groupId: groupId,
        isOwner: Value(true),
        isTentative: Value(false),
      );

      return await into(userGroupMap).insert(userGroupMapDetail);
    });
  }

  Future<bool> ownsGroup(int userId, int groupId) async {
    return (select(userGroupMap)
          ..where((ug) =>
              ug.userId.equals(userId) &
              ug.groupId.equals(groupId) &
              ug.isOwner.equals(true)))
        .getSingleOrNull()
        .then((value) => value != null);
  }

  Future<bool> isMemberOfGroup(int userId, int groupId) {
    return (select(userGroupMap)
          ..where((ug) =>
              ug.userId.equals(userId) &
              ug.groupId.equals(groupId) &
              ug.isTentative.equals(false)))
        .getSingleOrNull()
        .then((value) => value != null);
  }

  Future<bool> isTentativeMemberOfGroup(int userId, int groupId) {
    return (select(userGroupMap)
          ..where((ug) =>
              ug.userId.equals(userId) &
              ug.groupId.equals(groupId) &
              ug.isTentative.equals(true)))
        .getSingleOrNull()
        .then((value) => value != null);
  }

  Future<bool> setTentativeStatus(int userId, int groupId, bool status) {
    return (update(userGroupMap)
          ..where(
              (ug) => ug.userId.equals(userId) & ug.groupId.equals(groupId)))
        .write(UserGroupMapCompanion(
          isTentative: Value(status),
        ))
        .then((value) => value > 0)
        .onError((error, stackTrace) => false);
  }

  Future<bool> deleteTentativeMembers() {
    final deletionDelta = DateTime.now()
        .subtract(const Duration(days: DbConfig.TENTATIVE_MEMBER_DAYS));

    return (delete(userGroupMap)
          ..where((ug) =>
              ug.isTentative.equals(true) &
              ug.joinedAt.isSmallerThanValue(deletionDelta)))
        .go()
        .then((value) => value > 0)
        .onError((error, stackTrace) => false);
  }

  Future<int> getTentativeGroupSize(int groupId) {
    return (select(userGroupMap)..where((ug) => ug.groupId.equals(groupId)))
        .get()
        .then((value) => value.length);
  }

  Future<int> getGroupSize(int groupId) {
    return (select(userGroupMap)
          ..where((ug) =>
              ug.groupId.equals(groupId) & ug.isTentative.equals(false)))
        .get()
        .then((value) => value.length);
  }

  Future<int> getGroupCountOwnedByUserId(int userId) {
    return (select(userGroupMap)
          ..where((ug) => ug.userId.equals(userId) & ug.isOwner.equals(true)))
        .get()
        .then((value) => value.length);
  }

  Future<int?> getGroupOwner(int groupId) {
    return (select(userGroupMap)
          ..where((ug) => ug.groupId.equals(groupId) & ug.isOwner.equals(true)))
        .getSingleOrNull()
        .then((value) => value?.userId);
  }
}
