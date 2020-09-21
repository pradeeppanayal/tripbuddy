import 'package:flutter/material.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/footer.dart';
import 'package:tripbuddyapp/settings.dart';

/**
 *  @author Pradeep CH
 */
class UserProfilePage extends StatefulWidget {
  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfilePage> {
  static final double avatarSize = 50.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width),
          Container(
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.red],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.6, 1.0],
                  tileMode: TileMode.clamp),
            ),
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2 - avatarSize,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Column(children: [
              CircleAvatar(
                backgroundImage: NetworkImage(authService.currentUser.photoUrl),
                backgroundColor: Colors.white,
                minRadius: avatarSize, //avatarSize,
                maxRadius: avatarSize,
              ),
              Text(
                authService.currentUser.displayName,
                style: TextStyle(fontSize: 20),
              )
            ])),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.2 + avatarSize * 1.5,
              child: SettingsItems())
        ]),
        bottomNavigationBar: BottomControll(selectedIndex: 2));
  }
}

class UserNameWidget extends StatelessWidget {
  final String label;
  final double scale;
  UserNameWidget(this.label, this.scale);
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
          color: Colors.black,
          fontSize: MediaQuery.of(context).size.shortestSide *
              (0.06 + (scale) * 0.01),
          fontWeight: FontWeight.w500),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }
}

class ClippingClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..lineTo(size.height * 0.3, size.height * 0.7) // Add line p1p2
      //..lineTo(size.width, size.height) // Add line p2p3
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
