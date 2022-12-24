import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_now_user/main_screen/main_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>(); //key for form
  String name="";
  int x = 1;
  late String imageUrl;
  XFile? image;


  final ImagePicker picker = ImagePicker();

  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    setState(() {
      image = img;
    });
  }

  //show popup dialog
  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Choose media to select!',
            style: TextStyle(
              fontSize: 23,
              fontFamily: "Ubuntu",
              color: Colors.red.shade900,
              fontWeight: FontWeight.bold,
            ),),
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  SizedBox(width: 15,),
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () async {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);

                      if(image==null) return;

                      String uniqueFileName=DateTime.now().microsecondsSinceEpoch.toString();
                      //Get a reference to storage root
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages = referenceRoot.child('images');


                      //Create a reference for the image to be stored
                      Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

                      //Store the file
                      try{
                        await referenceImageToUpload.putFile(File(image!.path));
                        imageUrl = await referenceImageToUpload.getDownloadURL();
                      }catch(error){
                        //Do something for handling error
                      }



                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.red.shade900),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.image,
                        color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 15,),
                        Text('Gallery',style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: 20,
                          color: Colors.white,
                        ),),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.red.shade900),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        SizedBox(width: 15,),
                        Text('Camera', style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: 20,
                        ),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
                  SizedBox(height: 90,),
                  Text("Wanna do any",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.red.shade900,
                      fontFamily: "FredokaOne",
                    ),
                  ),
                  Text("Change !!",
                    style: TextStyle(
                      fontSize: 45,
                      color: Colors.red.shade900,
                      fontFamily: "FredokaOne",
                    ),
                  ),
                  SizedBox(height: 30,),
                  Center(
                    child: Stack(
                      children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black, spreadRadius: 1)],
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.red.shade900,
                                //backgroundImage: AssetImage('images/service_now_logo.jpeg'),
                                child: Container(
                                  child: image != null
                                      ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child: Image.file(
                                        //to show image, you type like this.
                                        File(image!.path),
                                        fit: BoxFit.cover,
                                          width: 300,
                                          height: 300,
                                      ),
                                    ),
                                  )
                                      : Icon(Icons.person_outline_rounded,
                                  size: 60,
                                  color: Colors.white,)
                                ),

                                radius: 56.0,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade900,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(blurRadius: 0, color: Colors.black, spreadRadius: 0)],
                                ),
                                child: IconButton(
                                  onPressed: () async{
                                    myAlert();
                                  },
                                  icon: Icon(Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 20,),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
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
                    decoration: InputDecoration(
                      icon: Icon(Icons.phone_android_rounded),
                      labelText: "Enter your Phone",
                    ),
                  ),
                  SizedBox(height: 30,),
                  TextFormField(
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
                      Text("Change Now", style: TextStyle(
                        fontSize: 28,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Ubuntu",
                      ),),
                      FloatingActionButton(
                        onPressed: () {
                          if(formKey.currentState!.validate()){
                            x = 2;
                            showDialog(context: context, builder: (BuildContext contest){
                              return AlertDialog(
                                title: Text("Warning !!!",
                                  style: TextStyle(
                                    fontSize: 28.0,
                                    color: Colors.red.shade900,
                                    fontFamily: "FredokaOne",
                                  ),),
                                content: Padding(
                                  padding: const EdgeInsets.only(left: 0.0, right: 10.0, top: 10.0),
                                    child: Text('Are you sure?',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.black45,
                                      fontFamily: "Ubuntu",
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(onPressed:(){


                                    // Navigator.push(context, MaterialPageRoute(builder: ((context) => MainScreen())));
                                  },
                                        child: Text(
                                          "OK",
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
                                          "CANCEL",
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
                          }
                        },
                        child: const Icon(Icons.check_rounded),
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

