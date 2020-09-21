import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/beans.dart';
import 'package:tripbuddyapp/utils.dart';
/**
 *  @author Pradeep CH
 */

class GroupMemberViewer extends StatelessWidget {
  final List<GroupMember> groupMembers;
  final PanelController panelController;
  final LatLng currentLocation;
  final Function onLeave;
  final Group group;

  GroupMemberViewer(
      this.group, this.groupMembers, this.panelController, this.currentLocation,
      {this.onLeave});

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      controller: panelController,
      panel: Stack(children: [
        Column(children: [
          Container(
            height: 20,
          ),
          _getHeader(),
          _divider(context),
          _getMemberList(context)
        ]),
        _cancelButton(),
        _leaveGroup(context),
        Positioned(
            bottom: 5,
            child: Text(
              "Note: The distance is approximated.",
              style: TextStyle(
                fontSize: 10,
              ),
            ))
      ]),
      isDraggable: false,
      minHeight: 0.0,
      boxShadow: [
        BoxShadow(
          blurRadius: 20.0,
          color: Colors.grey,
        ),
      ],
      borderRadius: CommonUtil.getMarginRadius(),
    );
  }

  Widget _divider(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 100,
        child: Divider(
          thickness: 1.0,
          color: Colors.grey,
        ));
  }

  Widget _getHeader() {
    return Container(
      child: Text(
        group.groupId,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200),
      ),
    );
  }

  Widget _getMemberList(BuildContext context) {
    if (groupMembers == null || groupMembers.length == 0) {
      return Center(
        child: Text("No members."),
      );
    }
    List<Widget> children = List();

    groupMembers.forEach((GroupMember member) {
      bool isMe = (member.uid == authService.currentUser.uid);
      var distance = member.location != null && currentLocation != null
          ? CommonUtil.calculateDistance(currentLocation, member.location)
          : -1; //in kms
      distance = double.parse(distance.toStringAsFixed(2));
      var displayName = isMe ? "You" : member.displayName;
      var distanceText =
          distance > -1 ? "$distance km away" : "Location unavailable";
      distanceText = isMe ? "" : distanceText;
      children.add(Card(
          child: ListTile(
        title: Row(children: [
          Text(displayName),
          member.isMaster
              ? Icon(
                  Icons.verified_user,
                  color: Colors.blue,
                )
              : Text("")
        ]),
        subtitle: Text(distanceText),
        leading: Image.network(member.photoURL),
        onTap: null,
      )));
    });

    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width - 10,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView(children: children))
            ]));
  }

  Widget _cancelButton() {
    return Positioned(
      child: IconButton(
        color: Colors.grey,
        onPressed: () {
          panelController.panelPosition = 0;
        },
        icon: Icon(Icons.close),
      ),
      top: 0,
      right: 0,
    );
  }

  Widget _leaveGroup(BuildContext context) {
    return Positioned(
        bottom: 20,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width - 10,
                child: Card(
                  child: ListTile(
                    onTap: onLeave,
                    title: Text("Leave the group"),
                    subtitle: Text("Exit from the current group."),
                    leading: Icon(
                      Icons.delete_sweep,
                      color: Colors.red,
                    ),
                  ),
                ),
              )
            ]));
  }
}
