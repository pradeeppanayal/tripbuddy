import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/beans.dart';
import 'package:tripbuddyapp/doa/groupMemberDOA.dart';
import 'package:tripbuddyapp/groupTracking.dart';
import 'package:tripbuddyapp/utils.dart';

/**
 * @author Pradeep CH
 */
class GroupActionHelper {
  static void joinAndRedirect(Group group, BuildContext context) async {
    String key = await groupMemberDOA.joinGroup(
        group, authService.currentUser.displayName);
    if (key != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupTrackingPage(
                    group,
                    key,
                  )));
    } else {
      print(key);
      UserInfoMessageUtil.showMessage(
          "Joining to the group could not be performed",
          UserInfoMessageMode.ERROR);
    }
  }
}
