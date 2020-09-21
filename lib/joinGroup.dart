import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/beans.dart';
import 'package:tripbuddyapp/doa/groupDOA.dart';
import 'package:tripbuddyapp/doa/groupMemberDOA.dart';
import 'package:tripbuddyapp/footer.dart';
import 'package:tripbuddyapp/groupTracking.dart';
import 'package:tripbuddyapp/helpers/groupActionhelper.dart';
import 'package:tripbuddyapp/utils.dart';

/*
 *  @author Pradeep Ch
 */
class JoinGroupPage extends StatefulWidget {
  @override
  _JoinGroupState createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroupPage> {
  bool loading = false;
  var _groupIdFieldController = TextEditingController();
  var _passcodeFieldController = TextEditingController();
  var _preferredNameFieldController = TextEditingController();
  var step = 1;

  @override
  void initState() {
    super.initState();
    _preferredNameFieldController.text = authService.currentUser.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          //color: Colors.white,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Text("Enter the group id"),
                  Container(
                    child: Visibility(
                      visible: step == 1,
                      child: TextField(
                        //maxLength: 8,
                        controller: _groupIdFieldController,
                        decoration: InputDecoration(
                          labelText: "Group ID",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width - 40,
                  ),
                  Container(
                    height: 10,
                  ),
                  Container(
                    child: Visibility(
                        visible: step == 2,
                        child: TextField(
                          //maxLength: 4,
                          controller: _passcodeFieldController,
                          decoration: InputDecoration(
                            labelText: "Passcode",
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        )),
                    width: MediaQuery.of(context).size.width - 40,
                  ),
                  Container(
                    height: 20.0,
                  ),
                  RaisedButton(
                      onPressed: _tryJoin,
                      child: Text("Join"),
                      color: Colors.blue,
                      textColor: Colors.white),
                  Container(
                    height: 20.0,
                  ),
                  ExpansionTile(
                    childrenPadding: EdgeInsets.all(5),
                    title: Text("More"),
                    //leading: Icon(Icons.more_horiz),
                    trailing: Icon(Icons.settings),
                    children: [
                      Container(
                        child: TextField(
                          //maxLength: 8,
                          controller: _preferredNameFieldController,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            labelText: "Preferred Name",
                            isDense: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width - 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Visibility(
              child: Positioned(
                  width: MediaQuery.of(context).size.width,
                  child: LinearProgressIndicator(),
                  bottom: 0.0),
              visible: loading,
            ),
          ],
        ),
        bottomNavigationBar: BottomControll(selectedIndex: 0));
  }

  _tryJoin() async {
    if (loading) return;

    var groupid = _groupIdFieldController.value.text.trim();
    var passcode = _passcodeFieldController.value.text.trim();
    var preferredName = _preferredNameFieldController.value.text.trim();
    if (groupid.isEmpty ||
        (passcode.isEmpty && step == 2) ||
        preferredName.isEmpty) {
      UserInfoMessageUtil.showMessage(
          "Fill all the fields", UserInfoMessageMode.WARN);
      return;
    }

    if (preferredName.length > 20) {
      UserInfoMessageUtil.showMessage(
          "Prefeered name cannot be more than 20", UserInfoMessageMode.ERROR);
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      Group group = await groupDOA.getGroup(groupid);
      if (step == 1 && group.passCodeRequired) {
        setState(() {
          step = 2;
          loading = false;
        });
        return;
      }
      group.passCode = passcode;
      GroupActionHelper.joinAndRedirect(group, context);
    } catch (e) {
      UserInfoMessageUtil.showMessage(
          CommonUtil.getErrorMessage(e), UserInfoMessageMode.ERROR);
    }
    setState(() {
      loading = false;
    });
  }
}
