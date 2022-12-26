import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_now_user/authentication/edit_profile.dart';
import 'package:service_now_user/main_screen/main_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../global/global.dart';
import '../main.dart';

class ViewProfile extends StatefulWidget {
  late String name, email, phone, urlImage;
  ViewProfile({required this.name, required this.phone, required this.email, required this.urlImage});
  // const ViewProfile({Key? key}) : super(key: key);

  @override
  State<ViewProfile> createState() => _ViewProfileState(name, phone, email, urlImage);
}

class _ViewProfileState extends State<ViewProfile> {
  late String name, email, phone, urlImage;
  _ViewProfileState(this.name, this.email, this.phone, this.urlImage);
  final formKey = GlobalKey<FormState>(); //key for form

  int x = 1;
  late String imageUrl;
  XFile? image;

  final ImagePicker picker = ImagePicker();
  //we can upload image from camera or from gallery based on parameter

  @override

  void initState(){
    super.initState();
    //fetchData();
  }

  // void fetchData() async{
  //   DatabaseReference  driversRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid);
  //   final user = await (driversRef.child("name")).get();
  //   final userEmail = await (driversRef.child("email")).get();
  //   final userPhone = await (driversRef.child("password")).get();
  //   final imageUrl = await (driversRef.child("image")).get();
  //
  //   setState(() {
  //     user_name = user!.value.toString();
  //     user_email = userEmail.value.toString();
  //     user_phone = userPhone.value.toString();
  //     urlImage = imageUrl!.value.toString();
  //
  //     //print("after setting: ${urlImage}");
  //   });
  // }

  // String user_name = "loading.....";
  // String user_email = "loading.....";
  // String user_phone = "loading.....";
  // String urlImage = "https://png.pngtree.com/png-vector/20210309/ourlarge/pngtree-not-loaded-during-loading-png-image_3022825.jpg";



  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();


    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFffffff),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left:10, right: 10),
              child: Column(
                //padding: const EdgeInsets.all(8),
                children: <Widget>[
                  SizedBox(height: 100,),
                  Center(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(width:2.5, color: Colors.black),
                                  borderRadius: BorderRadius.all(Radius.circular(70)),
                                ),
                                child: CircleAvatar(
                                  radius: 70.0,
                                  backgroundColor: Colors.white,
                                  backgroundImage: AssetImage("images/loading.png"),
                                  //backgroundImage: AssetImage('images/service_now_logo.jpeg'),
                                  child: Container(
                                      child: urlImage != null ? Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(70),
                                          child: Image.network(urlImage,
                                            height: 300,
                                            width: 300,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                          : Icon(Icons.person,
                                        size: 60,
                                        color: Colors.white,)
                                  ),
                                ),
                              ),
                            ),
                            // Positioned(
                            //   bottom: 0,
                            //   right: 0,
                            //   child: Padding(
                            //     padding: const EdgeInsets.only(left: 0.0),
                            //     child: Container(
                            //       decoration: BoxDecoration(
                            //         color: Colors.blueGrey.shade900,
                            //         shape: BoxShape.circle,
                            //         boxShadow: [BoxShadow(blurRadius: 0, color: Colors.black, spreadRadius: 0)],
                            //       ),
                            //       child: IconButton(
                            //         onPressed: () async{
                            //           //myAlert();
                            //         },
                            //         icon: Icon(Icons.add_a_photo_rounded,
                            //           color: Colors.white,
                            //           size: 20,),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                  SizedBox(height: 7,),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1, color: Colors.red.shade900),
                          )
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text('Name',
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: "Ubuntu",
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Center(
                            child: Text(name,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: "Ubuntu",
                                ),
                              ),
                          ),
                          SizedBox(height: 10,),

                        ],
                      ) ,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1, color: Colors.red.shade900),
                          )
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text('Phone',
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: "Ubuntu",
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Center(
                            child: Text(phone,
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Ubuntu",
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),

                        ],
                      ) ,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1, color: Colors.red.shade900),
                          )
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text('Email',
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: "Ubuntu",
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Center(
                            child: Text(email,
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Ubuntu",
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),

                        ],
                      ) ,
                    ),
                  ),
                  SizedBox(height: 60,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 5,),
                      Text("Sign Out?", style: TextStyle(
                        fontSize: 28,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Ubuntu",
                      ),),

                      FloatingActionButton(
                        onPressed: () {
                            showDialog(context: context, builder: (BuildContext contest){
                              return AlertDialog(
                                title: Text("Warning !!",
                                  style: TextStyle(
                                    fontSize: 28.0,
                                    color: Colors.red.shade900,
                                    fontFamily: "FredokaOne",
                                  ),),
                                content: Padding(
                                  padding: const EdgeInsets.only(left: 0.0, right: 10.0, top: 10.0),
                                  child: Text('Are you sure to sign out?',
                                    style: TextStyle(
                                      fontSize: 23.0,
                                      color: Colors.black45,
                                      fontFamily: "Ubuntu",
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(onPressed:(){
                                    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid).child("isActive");
                                    userRef.set(false);
                                    fAuth.signOut();
                                    Fluttertoast.showToast(
                                        msg: "Sign Out!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.black,
                                        fontSize: 20.0
                                    );
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Home()));
                                  },
                                      child: Text(
                                        "YES",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.red.shade900,
                                          fontFamily: "Ubuntu",
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                  ),
                                  TextButton(onPressed:(){
                                    Navigator.of(context).pop();
                                  },
                                      child: Text(
                                        "No",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.red.shade900,
                                          fontFamily: "Ubuntu",
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                  ),
                                  SizedBox(width: 0,)
                                ],
                              );
                            });
                          },

                        child: const Icon(Icons.check_rounded),
                        backgroundColor: Colors.red[900],
                      ),











                      SizedBox(width: 5,),
                    ],
                  ),

                ],
              ),





              ),
            ),
          ),
    );
  }
}

