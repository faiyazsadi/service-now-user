import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../authentication/login_screen.dart';
import '../global/global.dart';
import '../main_screen/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      // send user to main screen
      if (await fAuth.currentUser != null) {
        currentFirebaseuser = fAuth.currentUser;
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => MainScreen())));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => LoginScreen())));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red[900],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black, spreadRadius: 1)],
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/service_now_logo.jpeg'),
                  radius: 50.0,
                ),
              ),
              const SizedBox(height: 30,),
              Text("SERVICE NOW",
                style: TextStyle(
                  fontSize: 35.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'FredokaOne',
                ),
              ),
              const SizedBox(height: 60),
              SpinKitFoldingCube(
                color: Colors.white,
                size: 50.0,
              ),

            ],
          ),
        )
    );
  }
}
