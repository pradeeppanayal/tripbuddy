import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tripbuddyapp/createGroup.dart';
import 'package:tripbuddyapp/deeplinkManager.dart';
import 'package:tripbuddyapp/footer.dart';
import 'package:tripbuddyapp/pageNavigator.dart';
import 'package:tripbuddyapp/widgets/tile.dart';

/*
 *  @author Pradeep CH
 *  @version 1.0
 */
class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({this.title});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    DeepLinkHandler.handleAndRedirect(context);
  }

  @override
  Widget build(BuildContext context) {
    var tileSize = MediaQuery.of(context).size.width * 0.3;
    return new Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TBTile(
                  "Join", tileSize, Icons.merge_type, Colors.blue, Colors.white,
                  ontap: () => {rbPageNavigator.redirect(4, context)}),
              SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  child: Divider(
                    thickness: 1.0,
                    color: Colors.grey,
                  )),
              TBTile("Create Group", tileSize, Icons.add, Colors.green,
                  Colors.white,
                  ontap: () => {rbPageNavigator.redirect(3, context)}),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomControll(selectedIndex: 0),
    );
  }
}
