import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tripbuddyapp/doa/groupDOA.dart';
import 'package:tripbuddyapp/footer.dart';
import 'package:tripbuddyapp/utils.dart';
import 'package:tripbuddyapp/beans.dart';

import 'footer.dart';

/**
 *  @author Pradeep CH
 */
class CreateGroupPage extends StatefulWidget {
  @override
  GroupInfoState createState() => GroupInfoState();
}

class GroupInfoState extends State<CreateGroupPage> {
  bool loading = false;
  var groupid = "";
  var passcode = "";
  static String groupidCondition = "Only letters, numbers and _ are supported";
  bool created = false;
  bool passCodeRequired = false;
  bool isPrivate = false;
  bool customLabel = false;
  TextEditingController _groupIdController = TextEditingController();

  RegExp _groupIdRegEx;
  @override
  void initState() {
    super.initState();
    _refresh();
    _groupIdRegEx = RegExp('^[_a-zA-Z0-9]{2,20}\$');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        body: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
                child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                Positioned(
                    top: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Visibility(
                            visible: !customLabel,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    groupid,
                                    style: TextStyle(fontSize: 50.0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        customLabel = true;
                                      });
                                    },
                                  )
                                ])),
                        Container(
                          child: Visibility(
                              visible: customLabel,
                              child: Column(children: [
                                TextFormField(
                                  controller: _groupIdController,
                                  style: TextStyle(
                                    fontSize: 30,
                                  ),
                                  decoration:
                                      InputDecoration(labelText: "Group Id"),
                                ),
                                Text(
                                  groupidCondition,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic),
                                ),
                              ])),
                          width: MediaQuery.of(context).size.width * 0.8,
                        ),
                        Container(
                          height: 20.0,
                        ),
                        created
                            ? _getShareButton()
                            : RaisedButton(
                                onPressed: _createGroup,
                                child:
                                    Text(!loading ? "Create" : "Please wait.."),
                                color: Colors.blue,
                                textColor: Colors.white),
                        Container(
                          height: 20.0,
                        ),
                        Visibility(
                          visible: !created,
                          child: ExpansionTile(
                            childrenPadding: EdgeInsets.all(5),
                            title: Text("Advanced"),
                            //leading: Icon(Icons.more_horiz),
                            trailing: Icon(Icons.settings),
                            children: [
                              SwitchListTile(
                                title: Text("Password"),
                                subtitle:
                                    Text(passCodeRequired ? passcode : ""),
                                value: passCodeRequired,
                                onChanged: (value) {
                                  setState(() {
                                    passCodeRequired = value;
                                  });
                                },
                                selected: passCodeRequired,
                                secondary: Icon(Icons.lock),
                              ),
                              SwitchListTile(
                                title: Text("Private"),
                                selected: isPrivate,
                                subtitle: Text(
                                    "Admin should accept the member to join"),
                                value: isPrivate,
                                onChanged: (value) {
                                  setState(() {
                                    isPrivate = value;
                                  });
                                },
                                secondary: Icon(Icons.check_circle),
                              )
                            ],
                          ),
                        )
                      ],
                    )),
                Visibility(
                  child: Positioned(
                      width: MediaQuery.of(context).size.width,
                      child: LinearProgressIndicator(),
                      bottom: 0.0),
                  visible: loading,
                ),
              ],
            ))),
        bottomNavigationBar: BottomControll(selectedIndex: 0));
  }

  void _createGroup() {
    if (loading) return;

    if (customLabel) {
      groupid = _groupIdController.value.text;
    }
    if (!_validatateGrouId()) {
      UserInfoMessageUtil.showMessage(
          "Invalid group id. $groupidCondition", UserInfoMessageMode.ERROR);
      return;
    }
    setState(() {
      loading = true;
    });
    groupDOA
        .createGroup(getCurrentGroup())
        .then((value) => {processCreateResponse(true, value)})
        .catchError((e) {
      processCreateResponse(false, e);
    });
  }

  Group getCurrentGroup() {
    Group item = Group();
    item.groupId = groupid.trim();
    item.passCode = passCodeRequired ? passcode.trim() : "";
    item.passCodeRequired = passCodeRequired;
    item.isPrivate = isPrivate;
    return item;
  }

  processCreateResponse(bool success, resp) {
    if (success) {
      created = true;
      customLabel = false;
      UserInfoMessageUtil.showMessage(
          "Group created. Share with friends.", UserInfoMessageMode.SUCCESS);
    } else {
      UserInfoMessageUtil.showMessage(
          CommonUtil.getErrorMessage(resp), UserInfoMessageMode.ERROR);
    }
    setState(() {
      loading = false;
    });
  }

  String _generateId(int digit) {
    var k = pow(10, digit - 1);
    return (Random().nextInt(9 * k) + k).toString();
  }

  void _refresh() {
    if (created || loading) return;
    groupid = _generateId(8);
    passcode = _generateId(4);
    _groupIdController.text = groupid;
  }

  _getShareButton() {
    return IconButton(
        icon: Icon(Icons.share),
        onPressed: () {
          CommonUtil.initiateGroupShare(getCurrentGroup());
        });
  }

  bool _validatateGrouId() {
    return _groupIdRegEx.hasMatch(groupid);
  }
}
