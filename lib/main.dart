import 'dart:async';
import 'package:flutter/material.dart';
import 'package:money_tracker/UI/HomeWidget.dart';
import 'package:money_tracker/UI/SplashWidget.dart';
import 'package:money_tracker/Utilitis/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() => runApp(Phoenix(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Money Tracker',
        theme: ThemeData(
          primaryColor: mainGoaldColor,
        ),
        home: MainApp(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomeWidget(parentCtx: context),
          '/splash': (BuildContext context) => SplashWidget(),
        });
  }
}

class MainApp extends StatefulWidget {
  @override
  State createState() => _MainState();
}

class _MainState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/splash', (Route<dynamic> route) => false);
    }
  }

  Widget build(BuildContext context) {
    new Timer(new Duration(milliseconds: 10), () {
      checkFirstSeen();
    });
    return Scaffold(body: new Container());
  }
}
