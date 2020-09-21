/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/beans.dart';
import 'package:tripbuddyapp/doa/groupDOA.dart';
import 'package:tripbuddyapp/utils.dart';

class GroupMemberDOA {
  final FirebaseFirestore db;
  static const _MEMBERS = 'members';
  GroupMemberDOA(this.db);

  Future<GroupMember> getMemberByMemberId(
      String groupid, String memberId) async {
    var memberDoc =
        db.collection(_MEMBERS).doc(groupid).collection(_MEMBERS).doc(memberId);
    var member = await memberDoc.get();

    if (member.exists) {
      GroupMember groupMember = GroupMember().loadInfo(member.data());
      groupMember.id = memberDoc.id;
      return groupMember;
    }

    return null;
  }

  Future<String> joinGroup(Group _group, String preferredName) async {
    Group group = await groupDOA.getGroup(_group.groupId);
    if (group.status != 'Active')
      throw Exception("Group is not in active state");
    if (group.passCodeRequired && group.passCode != _group.passCode)
      throw Exception("Invalid passcode");
    GroupMember member =
        await getMember(group.groupId, authService.currentUser.uid);
    print(member);
    if (member == null)
      member =
          await addMember(group, authService.currentUser.uid, preferredName);
    return member.id;
  }

  Future<GroupMember> addMember(
      Group group, String uid, String preferredName) async {
    var memberDoc =
        db.collection(_MEMBERS).doc(group.groupId).collection(_MEMBERS).doc();
    GroupMember data = GroupMember();
    data.displayName = preferredName == null
        ? authService.currentUser.displayName
        : preferredName;
    data.uid = authService.currentUser.uid;
    data.lastUpdated = CommonUtil.currentTime();
    data.isMaster = group.createdBy == data.uid;
    await memberDoc.set(data.toMap());
    data.id = memberDoc.id;
    return data;
  }

  Future<GroupMember> getMember(String groupid, String uid) async {
    var members = db.collection(_MEMBERS).doc(groupid).collection(_MEMBERS);
    var respose = List();
    await members.where("uid", isEqualTo: uid).get().then((snapshot) => {
          snapshot.docs.forEach((element) {
            GroupMember member = GroupMember().loadInfo(element.data());
            member.id = element.id;
            respose.add(member);
          })
        });
    return respose.length > 0 ? respose[0] : null;
  }

  Future<List<GroupMember>> updateAndFetchMembers(
      String groupid, String memberId, LatLng currentLocation) async {
    GroupMember member = await getMemberByMemberId(groupid, memberId);
    if (member == null) throw Exception("Invalid member id");
    member.location = currentLocation;
    member.photoURL = authService.currentUser.photoURL;

    await updateMember(groupid, member);
    return await getAllmembers(groupid);
  }

  Future<bool> updateMember(String groupid, GroupMember _member) async {
    //print(_member);
    var memberDoc = db
        .collection(_MEMBERS)
        .doc(groupid)
        .collection(_MEMBERS)
        .doc(_member.id);
    var member = await memberDoc.get();
    if (!member.exists) throw Exception("Invalid member");
    _member.lastUpdated = CommonUtil.currentTime();
    await memberDoc.update(_member.toMap());
    return true;
  }

  Future<List<GroupMember>> getAllmembers(String groupid) async {
    var members = db.collection(_MEMBERS).doc(groupid).collection(_MEMBERS);
    List<GroupMember> respose = List();
    await members.get().then((snapshot) => {
          snapshot.docs.forEach((element) {
            GroupMember member = GroupMember();
            member.id = element.id;
            respose.add(member.loadInfo(element.data()));
          })
        });
    return respose;
  }

  Future<void> leaveGroup(String groupid, String memberId) async {
    var memberDoc =
        db.collection(_MEMBERS).doc(groupid).collection(_MEMBERS).doc(memberId);
    var member = await memberDoc.get();
    if (member.exists) await memberDoc.delete();
  }
}

final GroupMemberDOA groupMemberDOA =
    GroupMemberDOA(FirebaseFirestore.instance);
