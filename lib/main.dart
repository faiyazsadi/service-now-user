import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:service_now_user/authentication/sign_up.dart';
import 'authentication/edit_profile.dart';
import 'authentication/otp_input.dart';
import 'global/global.dart';
import 'main_screen/main_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}
class _SplashState extends State<Splash> with SingleTickerProviderStateMixin{

  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      // send user to main screen
      if (fAuth.currentUser != null) {
        currentFirebaseuser = fAuth.currentUser;
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users/${currentFirebaseuser}/AcceptTime");
        final snapshot = await userRef.get();
        prevAcceptTime = snapshot.value.toString();

        Navigator.push(context, MaterialPageRoute(builder: ((context) => const MainScreen())));
            DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("users");
            driversRef.child(currentFirebaseuser!.uid).update({"isActive": true});
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => const SignUp())));
      }
      // Navigator.push(context, MaterialPageRoute(builder: ((context) => const SignUp())));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Future.delayed(const Duration(seconds: 3), (){
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const SignUp()));
    // }
    // );
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


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  static String verify="";

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  TextEditingController countrycode = TextEditingController();

  var phone="";

  @override

  void initState(){
    countrycode.text = "+880";
    super.initState();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SizedBox(height: 150.0,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black, spreadRadius: 2)],
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/service_now_logo.jpeg'),
                  radius: 50.0,
                ),
              ),
              SizedBox(height: 30.0,),
              Text(
                "Service Now",
                style: TextStyle(
                  fontSize: 40.0,
                  fontFamily: 'FredokaOne',
                ),
              ),
              SizedBox(height: 40.0),
              Text('Enter your Phone number',
                style: TextStyle(
                  fontSize: 22.0,
                ),),
              Padding(
                padding: EdgeInsets.all(20.0),
                child:
                Container(
                  child: TextField(
                    onChanged: (value){
                      phone = value;
                    },
                    keyboardType: TextInputType.phone,
                    autofocus: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFB71C1C),
                          width: 3.0,
                        ),
                      ),
                      labelText: '+880  | ',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                      hintText: 'Enter next 10 digit (e.g.1xxxxxxxxx)',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0,),
              FloatingActionButton(onPressed: () async {
                //used for OTP: will work later*******************************
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: '${countrycode.text + phone}',
                  verificationCompleted: (PhoneAuthCredential credential) {},
                  verificationFailed: (FirebaseAuthException e) {},
                  codeSent: (String verificationId, int? resendToken) {
                    Home.verify = verificationId;
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyOtp(phone : phone)));

                  },
                  codeAutoRetrievalTimeout: (String verificationId) {},
                );
                // Navigator.push(
                //     context, MaterialPageRoute(builder: ((context) => MyOtp(text: phone))));

                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyOtp(phone : phone)));
              },
                backgroundColor: Colors.red[900],
                child: const Icon(Icons.navigate_next_rounded),),
            ],
          )
      ),
    );
  }
}



