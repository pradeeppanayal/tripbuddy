import 'dart:async';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/beans.dart';
import 'package:tripbuddyapp/doa/groupMemberDOA.dart';
import 'package:tripbuddyapp/groupMemberList.dart';
import 'package:tripbuddyapp/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripbuddyapp/markerBuilder.dart';
import 'package:tripbuddyapp/utils.dart';

/*
 *  @author Pradeep CH
 *  @version 1.0
 */
class GroupTrackingPage extends StatefulWidget {
  GroupTrackingPage(this.group, this.memberId);
  final Group group;
  final String memberId;

  @override
  GroupViewerState createState() => GroupViewerState();
}

class GroupViewerState extends State<GroupTrackingPage>
    with WidgetsBindingObserver {
  static final int timeIntervalInSec = 5;
  PanelController panelController;
  var _currentIndex = 0;
  bool loading = true;
  bool hasUserLocation = false;
  final Completer<GoogleMapController> _controller = Completer();
  Map<String, Marker> _markers = Map();
  List<GroupMember> members;
  static LatLng currentLocation = Maputil.getDefaultLocation();
  bool _active = false;
  bool backgroundLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getlocation();
    panelController = PanelController();
    //panelController.panelPosition = 0;
  }

  //This is to fix trying access the components after the dispose
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _active = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.future.then((value) => value.setMapStyle("[]"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: Stack(
              //color: Colors.white,
              children: [
                hasUserLocation
                    ? _googleMap(context)
                    : _getLocationAccessRequired(),
                GroupMemberViewer(
                    widget.group, members, panelController, currentLocation,
                    onLeave: () => {_leaveGroup()}),
                Visibility(
                  child: Positioned(
                      width: MediaQuery.of(context).size.width,
                      child: LinearProgressIndicator(),
                      bottom: 0.0),
                  visible: loading || backgroundLoading,
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _buttonClicked(index);
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), title: Text("Home")),
                _active
                    ? BottomNavigationBarItem(
                        icon: Icon(Icons.location_disabled),
                        title: Text("Pause"))
                    : BottomNavigationBarItem(
                        icon: Icon(Icons.my_location), title: Text("Start")),
                BottomNavigationBarItem(
                    icon: Icon(Icons.group), title: Text("Members")),
              ],
            )),
        onWillPop: _backclicked);
  }

  void _buttonClicked(int index) {
    switch (index) {
      case 0:
        _goHome();
        break;
      case 1:
        liveStatusUpdate();
        break;
      case 2:
        //panelController.show();
        panelController.panelPosition =
            panelController.panelPosition == 1 ? 0 : 1;
        break;
    }
  }

  void liveStatusUpdate() {
    if (loading) return;
    _active = !_active;
    if (_active) startTimer();
  }

  startTimer() {
    //_fetchLiveLocation();
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (_active == null || !_active) timer.cancel();
      _fetchLiveLocation();
    });
  }

  Widget _googleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:
            CameraPosition(target: currentLocation, zoom: 12),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          // MarkerUtil.loadCustomMarkers(context);
          _showCurrentUserMarker();
          _fetchLiveLocation();
        },
        markers: _markers.values.toSet(),
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }

  void _getlocation() async {
    loading = true;

    var location;
    try {
      location = await locationInfoService.getLocation(_currentLocationUpdated);
    } catch (e) {}
    if (location == null) {
      loadingStatusUpdate(false);
      return;
    }
    print("Initial location recived $location");
    //authService.updateUserData(location);
    setState(() {
      currentLocation = location;
      hasUserLocation = true;
    });
    setState(() {
      loading = false;
    });
    loading = false;
    _moveCameraToCurrentlocation();
  }

  void _currentLocationUpdated(LatLng val) {
    currentLocation = val == null ? currentLocation : val;
    _showCurrentUserMarker();
  }

  void _moveCameraToCurrentlocation() async {
    if (currentLocation == null) return;
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation, zoom: 14.00)));
  }

  void loadingStatusUpdate(val) {
    FocusScope.of(context).unfocus();
    setState(() {
      loading = val;
    });
  }

  Widget _getLocationAccessRequired() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: loading
            ? [Text("Loading..")]
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.location_disabled),
                  onPressed: () => {requestForLocationAccess()},
                  iconSize: 100.00,
                  color: Colors.red[400],
                ),
                Text("Location access is required"),
                FlatButton(
                    child: Icon(Icons.refresh),
                    onPressed: () => {requestForLocationAccess()}),
                SizedBox(height: 100),
              ],
      ),
    );
  }

  void requestForLocationAccess() {
    loadingStatusUpdate(true);
    _getlocation();
  }

  void _fetchLiveLocation() async {
    if (loading || backgroundLoading) return;
    setState(() {
      backgroundLoading = true;
    });
    try {
      members = await groupMemberDOA.updateAndFetchMembers(
          widget.group.groupId, widget.memberId, currentLocation);

      _markers.clear();
      for (GroupMember element in members) {
        //skip users with no locatipn or current user
        if (element.location == null ||
            element.uid == authService.currentUser.uid) {
          continue;
        }
        var icon = await MarkerBuilder.makeReceiptImage(
            element.photoURL, element.uid, context);
        setState(() {
          _markers[element.uid] = Marker(
              markerId: MarkerId(element.uid),
              icon: icon,
              position: element.location,
              infoWindow: InfoWindow(title: element.displayName));
        });
      }

      _showCurrentUserMarker();
    } catch (e) {
      print(e);
    }
    setState(() {
      backgroundLoading = false;
    });
  }

  void _showCurrentUserMarker() async {
    //print("==============called $currentLocation");
    if (currentLocation == null) return;
    //_markers.clear();
    //var l = currentLocation.latitude * 1Random().nextDouble();

    Marker marker = Marker(
        markerId: MarkerId(authService.currentUser.uid),
        infoWindow: InfoWindow(title: "You", snippet: "$currentLocation"),
        position: currentLocation,
        icon: await MarkerBuilder.makeReceiptImage(
            authService.currentUser.photoURL,
            authService.currentUser.uid,
            context));

    setState(() {
      _markers[authService.currentUser.uid] = marker;
    });
  }

  Future<bool> _backclicked() {
    _goHome();
    return Future.value(true);
  }

  Future<void> _leaveGroup() async {
    _active = false;
    setState(() {
      loading = true;
    });
    try {
      await groupMemberDOA.leaveGroup(widget.group.groupId, widget.memberId);

      UserInfoMessageUtil.showMessage(
          "Your details are removed from the group", UserInfoMessageMode.INFO);
      _goHome();
    } catch (e) {
      UserInfoMessageUtil.showMessage(
          CommonUtil.getErrorMessage(e), UserInfoMessageMode.ERROR);
    }
    setState(() {
      loading = false;
    });
  }

  void _goHome() {
    _active = false;
    Navigator.pushReplacementNamed(context, '/home');
  }
}
