import 'package:flutter/material.dart';
import 'package:tripbuddyapp/pageNavigator.dart';

class BottomControll extends StatelessWidget {
  final selectedIndex;
  BottomControll({this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        //if (index == selectedIndex) return;
        rbPageNavigator.redirect(index, context);
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
        BottomNavigationBarItem(icon: Icon(Icons.group), title: Text("Groups")),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), title: Text("My Account")),
      ],
    );
  }
}
