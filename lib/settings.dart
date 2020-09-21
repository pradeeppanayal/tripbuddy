import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsItems extends StatelessWidget {
  final Completer<BuildContext> _context = Completer();

  @override
  Widget build(BuildContext context) {
    _context.complete(context);

    return Container(
        width: MediaQuery.of(context).size.width - 10,
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView(
          children: [
            Card(
                child: ListTile(
                    title: Text("Help"),
                    subtitle: Text("Visit us to know more"),
                    leading: Icon(Icons.help),
                    onTap: () => {
                          launch(
                              "https://sites.google.com/view/holdhand-tripbuddy/home")
                        })),
            Card(
                child: ListTile(
              title: Text("Logout"),
              subtitle: Text("Logout from the app"),
              leading: Icon(Icons.exit_to_app),
              onTap: () => {_performLogout()},
            )),
          ],
        ));
  }

  _performLogout() async {
    await authService.signOut();
    var context = await _context.future;

    Navigator.popUntil(context, (route) => false);
    Navigator.pushNamed(context, "/");
  }
}
