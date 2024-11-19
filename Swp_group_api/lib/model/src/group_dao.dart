part of 'package:backend/model/src/database.dart';

@DriftAccessor(tables: [GroupDetails, UserGroupMap, Users])
class GroupDao extends DatabaseAccessor<AppDatabase> with _$GroupDaoMixin {
  GroupDao(super.db);

  Future<GroupDetail?> getGroupById(int id) async {
    return await (select(groupDetails)..where((g) => g.id.equals(id)))
        .getSingleOrNull();
  }

  Future<GroupDetail?> getGroupByName(String name) async {
    return await (select(groupDetails)..where((g) => g.name.equals(name)))
        .getSingleOrNull();
  }

  Future<bool> updateGroup(GroupDetailsCompanion groupCompanion) async {
    return await update(groupDetails).replace(groupCompanion);
  }

  Future<List<GroupDetail>> getAllGroups(final int page, final int pageSize) {
    return (select(groupDetails)..limit(pageSize, offset: page * pageSize))
        .get();
  }

  Future<bool> deleteGroup(int groupId) async {
    return transaction(() async {
      return await (delete(groupDetails)..where((g) => g.id.equals(groupId)))
          .go()
          .then((value) => value > 0)
          .onError((error, stackTrace) => false);

      // Deleting the GroupDetails is cascaded to UserGroupMap. Nothing more to
      // do here.
    });
  }
}
