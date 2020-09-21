import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/beans.dart';
import 'package:tripbuddyapp/utils.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class GroupDOA {
  final FirebaseFirestore db;
  static const _GROUPS = 'groups';
  static const _MEMBERS = 'members';
  GroupDOA(this.db);
  Future<List<Group>> getGroups() async {
    List<Group> groups = List();
    await db
        .collection("groups")
        .where("createdBy", isEqualTo: authService.currentUser.uid)
        .get()
        .then((QuerySnapshot snapshot) => {
              snapshot.docs.forEach((element) {
                groups.add(Group().load(element.data()));
              })
            });
    return groups;
  }

  Future<Group> getGroup(String groupId) async {
    var groupDoc =
        FirebaseFirestore.instance.collection(_GROUPS).doc(groupId.trim());
    var group = await groupDoc.get();
    if (group.exists) {
      return Group().load(group.data());
    }
    throw Exception("Group does not exist");
  }

  Future<bool> isGroupExit(groupId) async {
    var doc = db.collection(_GROUPS).doc(groupId);
    return (await doc.get()).exists;
  }

  Future<dynamic> createGroup(Group group) async {
    group.groupId = group.groupId.trim();
    group.passCode = group.passCode.trim();
    var doc = db.collection(_GROUPS).doc(group.groupId);
    if (await isGroupExit(group.groupId)) {
      throw Exception("Group id exist");
    }
    group.createdOn = CommonUtil.currentTime();
    group.status = 'Active';
    group.createdByDisplayName = authService.currentUser.displayName != null
        ? authService.currentUser.displayName
        : 'No Name';
    group.createdBy = authService.currentUser.uid;

    await doc.set(group.toMap());
    return doc.id;
  }

  Future<void> deleteGroup(Group group) async {
    await db.collection(_GROUPS).doc(group.groupId).delete();
    try {
      await db.collection(_MEMBERS).doc(group.groupId).delete();
    } catch (e) {
      print(e);
    }
    return;
  }

  Future<void> update(Group group) async {
    group.lastUpdatedOn = CommonUtil.currentTime();
    await db.collection(_GROUPS).doc(group.groupId).update(group.toMap());
    return true;
  }
}

final GroupDOA groupDOA = GroupDOA(FirebaseFirestore.instance);
