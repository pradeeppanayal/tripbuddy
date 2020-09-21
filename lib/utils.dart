import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/beans.dart';
import 'package:tripbuddyapp/deeplinkManager.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class Maputil {
  Maputil._();
  static final LatLng defaultLocation = LatLng(12.97, 77.56); //Banglore
  static LatLng getDefaultLocation() {
    return defaultLocation;
  }
}

class UserInfoMessageUtil {
  UserInfoMessageUtil._();
  static void showMessage(String msg, UserInfoMessageMode mode) {
    Color bg;
    switch (mode) {
      case UserInfoMessageMode.ERROR:
        bg = Colors.red;
        break;
      case UserInfoMessageMode.INFO:
      case UserInfoMessageMode.WARN:
        bg = Colors.blue;
        break;
      case UserInfoMessageMode.SUCCESS:
        bg = Colors.green;
        break;
    }
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: bg,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

class CommonUtil {
  CommonUtil._();
  static final defaultErrMsg = 'Something went wrong';
  static final DateFormat defaultDateFormat = DateFormat("yyyy-MMM-dd");

  static getMarginRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
  }

  static String getErrorMessage(e) {
    var emsg = e.message;
    if (emsg == null) return defaultErrMsg;
    return emsg;
  }

  static double calculateDistance(LatLng l1, LatLng l2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((l2.latitude - l1.latitude) * p) / 2 +
        c(l1.latitude * p) *
            c(l2.latitude * p) *
            (1 - c((l2.longitude - l1.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  static int currentTime() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static void initiateGroupShare(Group group) async {
    String subject = "TripBuddy group Invitation";
    String link = await DeepLinkHandler.prepareLink(group);

    String body =
        "${authService.currentUser.displayName} invited you to join TripBuddy group ${group.groupId}";
    if (group.passCodeRequired) body = "$body with passcode ${group.passCode}";
    body = "$body\n\nJoin using the link : $link";
    Share.share(body, subject: subject);
  }

  static String formatDate(int inms) {
    return defaultDateFormat
        .format(DateTime.fromMicrosecondsSinceEpoch(inms * 1000));
  }
}

enum UserInfoMessageMode { INFO, WARN, SUCCESS, ERROR }
