import 'package:flutter/material.dart';

class RBPageNavigator {
  redirect(int index, context) {
    String targetPage;
    var isHome = index == 0;
    switch (index) {
      case 0:
        targetPage = "/home";
        break;
      case 1:
        targetPage = "/mygroups";
        break;
      case 2:
        targetPage = "/profile";
        break;
      case 3:
        targetPage = "/create";
        break;
      case 4:
        targetPage = "/join";
        break;
    }
    if (targetPage == null) return;
    if (isHome) Navigator.popUntil(context, (route) => false);

    Navigator.pushNamed(context, targetPage);
  }
}

RBPageNavigator rbPageNavigator = RBPageNavigator();
