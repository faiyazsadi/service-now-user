import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:service_now_user/authentication/edit_profile.dart';
import 'package:service_now_user/authentication/sign_up.dart';
import 'package:service_now_user/main_screen/main_screen.dart';

import '../main.dart';

class MyOtp extends StatefulWidget {
  String phone;
  //const MyOtp({this.text}, {Key? key}) : super(key: key);
  MyOtp({required this.phone});

  @override
  State<MyOtp> createState() => _MyOtpState(phone);
}

class _MyOtpState extends State<MyOtp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String phone;
  _MyOtpState(this.phone);


  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        // border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    var code="";
    return Container(
      child: Scaffold(

          backgroundColor: Color(0xFFffffff),
          body: SingleChildScrollView(
            child: Container(
              // padding: EdgeInsets.all(50.0),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  Text('Enter OTP',
                    style: TextStyle(
                      fontSize: 22.0,
                    ),),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child:
                    Container(
                      child: Pinput(
                        length: 6,
                        showCursor: true,
                        onChanged: (value){
                          code=value;
                        },
                      ),
                    ),
                  ),
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: ((context) => SignUp())));
                  },
                    child: Text("Resubmit for OTP",
                      style: TextStyle(
                        color: Color(0xFFB71C1C),
                        fontFamily: 'Ubuntu',
                        fontSize: 18.0,
                        decoration: TextDecoration.underline,
                      ),
                    ),

                  ),

                  SizedBox(height:20.0),
                  FloatingActionButton(onPressed: () async {
                    try{
                      //OTP matching functions: will work later********************
                      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: Home.verify, smsCode: code);
                      await auth.signInWithCredential(credential);
                      Navigator.push(
                          context, MaterialPageRoute(builder: ((context) => EditProfile())));
                    }
                    catch(e){
                      showDialog(context: context, builder: (BuildContext contest){
                        return AlertDialog(
                          title: Text("Opssss!!!"),
                          content: Text('You provide wrong OTP',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          actions: [
                            FloatingActionButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                              backgroundColor: Colors.red[900],
                              child: const Icon(Icons.thumb_up_alt_rounded),
                            )
                          ],
                        );
                      });
                    };
                  },
                    backgroundColor: Colors.red[900],
                    child: const Icon(Icons.navigate_next_rounded),),
                  SizedBox(height: 20.0,),

                ],
              ),
            ),
          )
      ),
    );
  }
}
