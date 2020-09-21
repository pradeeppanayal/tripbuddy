import 'package:firebase_core/firebase_core.dart';
import 'package:tripbuddyapp/auth.dart';
import 'package:tripbuddyapp/createGroup.dart';
import 'package:tripbuddyapp/home.dart';
import 'package:flutter/material.dart';
import 'package:tripbuddyapp/joinGroup.dart';
import 'package:tripbuddyapp/mygroups.dart';
import 'package:tripbuddyapp/myprofile.dart';
import 'package:tripbuddyapp/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripBuddy App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => MainPage(),
        '/home': (BuildContext context) => MyHomePage(),
        '/join': (BuildContext context) => JoinGroupPage(),
        '/create': (BuildContext context) => CreateGroupPage(),
        '/mygroups': (BuildContext context) => MyGroupdPage(),
        '/profile': (BuildContext context) => UserProfilePage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainPage> {
  bool isUserLoggedIn = false;
  bool loading = false;
  bool loginError = false;
  void initState() {
    super.initState();
    loading = true;
    authService
        .isUserSignedIn()
        .then((value) => {_loginStateUpdated(value)})
        .catchError((value) => {showLoginfailedError(value)});
  }

  _loginStateUpdated(v) {
    setState(() {
      isUserLoggedIn = v;
      loading = false;
    });
    if (isUserLoggedIn) _trylogin();
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
                Image(
                  image: AssetImage("assets/images/logo.png"),
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 50),
                (loading || isUserLoggedIn) && !loginError
                    ? Text("Please wait..")
                    : _signInButton(),
                Visibility(
                  visible: loginError && isUserLoggedIn,
                  child: IconButton(
                      icon: Icon(Icons.refresh), onPressed: () => _trylogin()),
                ),
                SizedBox(height: 100),
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
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: _trylogin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage("assets/images/google_logo.png"),
                height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _trylogin() {
    if (loading) return;
    setState(() {
      loading = true;
      loginError = false;
    });
    authService
        .tryLogin()
        .then((value) => {
              if (value != null && authService.getUserToken() != null)
                {Navigator.pushReplacementNamed(context, "/home")}
            })
        .then((value) => setState(() {
              loading = false;
            }))
        .catchError((error) => showLoginfailedError(error));
  }

  showLoginfailedError(error) {
    print(error);
    UserInfoMessageUtil.showMessage("Login failed.", UserInfoMessageMode.ERROR);
    setState(() {
      loading = false;
      loginError = true;
    });
  }
}
