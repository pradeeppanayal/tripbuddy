import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/doa/groupDOA.dart';
import 'package:tripbuddyapp/doa/groupMemberDOA.dart';
import 'package:tripbuddyapp/footer.dart';
import 'package:tripbuddyapp/beans.dart';
import 'package:tripbuddyapp/groupTracking.dart';
import 'package:tripbuddyapp/helpers/groupActionhelper.dart';
import 'package:tripbuddyapp/utils.dart';

/**
 *  @author Pradeep CH
 */
class MyGroupdPage extends StatefulWidget {
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<MyGroupdPage> {
  List<Group> groups = List();
  bool loading = true;
  bool backGroudProcessing = false;
  @override
  void initState() {
    super.initState();
    //getGroups();
    this.loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Groups"),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
          //color: Colors.white,
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height),
            ListView(
              children: getGroupsAsWidget(),
            ),
            Visibility(
              child: Positioned(
                  width: MediaQuery.of(context).size.width,
                  child: LinearProgressIndicator(),
                  bottom: 0.0),
              visible: loading || backGroudProcessing,
            ),
          ]),
      bottomNavigationBar: BottomControll(selectedIndex: 1),
    );
  }

  Future<void> loadGroups() async {
    loading = true;
    try {
      groups = await groupDOA.getGroups();
    } catch (e) {
      print(e);
      UserInfoMessageUtil.showMessage(
          "Could not load the group", UserInfoMessageMode.ERROR);
    }
    setState(() {
      loading = false;
    });
  }

  List<Widget> getGroupsAsWidget() {
    List<Widget> temp = List();
    if (loading) {
      temp.add(Text("Please wait..."));
      return temp;
    }
    if (groups == null || groups.length == 0) {
      temp.add(Center(child: Text("No groups to show")));
      return temp;
    }
    groups.forEach((Group group) {
      temp.add(Card(
          child: ListTile(
        title: Row(children: [
          Text("ID: ${group.groupId}"),
          Container(
            width: 10,
          ),
          Visibility(
            child: Icon(
              Icons.lock,
              color: group.status == 'Active' ? Colors.blue : Colors.grey,
            ),
            visible: group.passCodeRequired,
          ),
          Container(
            width: 10,
          ),
          Visibility(
            child: Icon(
              Icons.check_circle,
              color: group.status == 'Active' ? Colors.blue : Colors.grey,
            ),
            visible: group.isPrivate,
          )
        ]),
        selected: group.status == 'Active',
        subtitle: Text("Created on ${group.addedDateFormatted}"),
        // value: element['status'] == 'enabled',
        //onChanged: (value) => {_updated(element, value)},
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
            onSelected: (val) => {_handleAction(group, val)},
            itemBuilder: (BuildContext context) {
              return _buildItems(group);
            }),
      )));
    });
    return temp;
  }

  List<PopupMenuEntry<String>> _buildItems(Group group) {
    var statusChange = (group.status == 'Active') ? 'Disable' : 'Enable';
    List<PopupMenuEntry<String>> actionmenuItems = [];
    Map<String, Icon> menuItems = Map();
    menuItems[statusChange] = statusChange == 'Disable'
        ? Icon(
            Icons.not_interested,
            color: Colors.black,
          )
        : Icon(
            Icons.check_circle_outline,
            color: Colors.green,
          );
    menuItems['Share'] = Icon(
      Icons.share,
      color: Colors.blue,
    );
    menuItems['Join'] = Icon(
      Icons.merge_type,
      color: Colors.blue,
    );
    menuItems['Delete'] = Icon(
      Icons.delete_forever,
      color: Colors.red,
    );
    menuItems.forEach((key, value) => {
          actionmenuItems.add(PopupMenuItem(
            child: Row(children: <Widget>[value, Text(key)]),
            value: key,
          ))
        });

    return actionmenuItems;
  }

  void _handleAction(Group group, String value) {
    if (loading || backGroudProcessing) return;
    switch (value) {
      case 'Delete':
        _performDelete(group);
        break;
      case 'Enable':
        _updateStatus(group, 'Active');
        break;
      case 'Disable':
        _updateStatus(group, 'Inactive');
        break;
      case 'Join':
        _joinAndRedirect(group);
        break;
      case 'Share':
        _share(group);
        break;
    }
  }

  void _performDelete(Group group) async {
    setState(() {
      backGroudProcessing = true;
    });
    //loading = true;
    try {
      await groupDOA.deleteGroup(group);
      UserInfoMessageUtil.showMessage(
          "Group Deleted", UserInfoMessageMode.INFO);
      await loadGroups();
    } catch (e) {
      print(e);
      UserInfoMessageUtil.showMessage(
          "Could not delete the Group", UserInfoMessageMode.ERROR);
    }
    setState(() {
      backGroudProcessing = false;
      //loading = false;
    });
  }

  void _updateStatus(Group group, String s) async {
    group.status = s;
    setState(() {
      backGroudProcessing = true;
    });
    //loading = true;
    try {
      await groupDOA.update(group);
      UserInfoMessageUtil.showMessage("Updated", UserInfoMessageMode.INFO);
      await loadGroups();
    } catch (e) {
      print(e);
      UserInfoMessageUtil.showMessage(
          "Could not update the Group", UserInfoMessageMode.ERROR);
    }
    setState(() {
      backGroudProcessing = false;
      //loading = false;
    });
  }

  void _joinAndRedirect(Group group) async {
    setState(() {
      backGroudProcessing = true;
    });
    try {
      GroupActionHelper.joinAndRedirect(group, context);
    } catch (e) {
      UserInfoMessageUtil.showMessage(
          CommonUtil.getErrorMessage(e), UserInfoMessageMode.ERROR);
    }
    setState(() {
      backGroudProcessing = false;
      //loading = false;
    });
  }

  void _share(Group group) {
    CommonUtil.initiateGroupShare(group);
  }
}
