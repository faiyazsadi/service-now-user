import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:service_now_user/main_screen/main_screen.dart';

import '../global/global.dart';
import '../widgets/progress_dialog.dart';


class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>(); //key for form
  String name="";
  int x = 1;

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();


  saveUserInfo() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Processing. Please Wait...",
          );
        });
        final User? firebaseUser = (await fAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: phoneTextEditingController.text.trim(),
    ).catchError((msg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Error: ' + msg.toString());
    })).user;

    if (firebaseUser != null) {
      Map userMap = {
        "id": firebaseUser.uid,
        "nane": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "password": phoneTextEditingController.text.trim()
      };
      DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("users");
      driversRef.child(firebaseUser.uid).set(userMap);
      currentFirebaseuser = firebaseUser;
      Fluttertoast.showToast(msg: 'Account has been created.');
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => MainScreen()));
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Account could not be created.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();


    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFffffff),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 110,),
                  Text("Here to get",
                    style: TextStyle(
                        fontSize: 35,
                      color: Colors.red.shade900,
                      fontFamily: "FredokaOne",
                    ),
                  ),
                  Text("Welcome !!",
                    style: TextStyle(
                      fontSize: 45,
                      color: Colors.red.shade900,
                      fontFamily: "FredokaOne",
                    ),
                  ),
                  SizedBox(height: 30,),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Add your Profile Image", style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade600,
                          //fontWeight: FontWeight.bold,
                          fontFamily: "Ubuntu",
                        ),),
                        IconButton(
                          iconSize: 40,
                          color: Colors.grey.shade600,
                          icon: const Icon(Icons.add_a_photo_rounded),
                          onPressed: () {

                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15,),
                  TextFormField(
                    controller: nameTextEditingController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person_rounded),
                      labelText: "Enter your name",
                      focusColor: Colors.red.shade900,
                    ),
                    validator: (value){
                      if(value!.isEmpty || !RegExp(r'^[a-z A-Z]+$').hasMatch(value!)){
                        return "Enter Correct Name (Only A-Z or a-z are allowed)";
                      }
                      else{
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 30,),
                  TextFormField(
                    controller: phoneTextEditingController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.phone_android_rounded),
                      labelText: "Enter your Phone",
                    ),
                  ),
                  SizedBox(height: 30,),
                  TextFormField(
                    controller: emailTextEditingController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email_rounded),
                      labelText: "Enter Your Email",
                    ),
                    validator: (value){
                      if(value!.isEmpty || RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2, 4}').hasMatch(value!)){
                        return "Enter Correct Email";
                      }
                      else{
                        return null;
                      }
                    },
                  ),



                  SizedBox(height: 80,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 5,),
                      Text("Sign Up Now", style: TextStyle(
                        fontSize: 28,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Ubuntu",
                      ),),
                      FloatingActionButton(
                          onPressed: () {
                              if(formKey.currentState!.validate()){
                                  x = 2;

                                  saveUserInfo();

                                  showDialog(context: context, builder: (BuildContext contest){
                                    return AlertDialog(
                                      title: Text("Congratulations !!!",
                                        style: TextStyle(
                                          fontSize: 28.0,
                                          color: Colors.red.shade900,
                                          fontFamily: "FredokaOne",
                                        ),),
                                      content: Padding(
                                        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 20.0),
                                        child: Text('You have registered successfully',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.black45,
                                            fontFamily: "Ubuntu",
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                              }
                            },
                        child: const Icon(Icons.navigate_next_rounded),
                        backgroundColor: Colors.red[900],
                      ),
                      SizedBox(width: 5,),
                    ],
                  ),
                  SizedBox(height: 30,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
