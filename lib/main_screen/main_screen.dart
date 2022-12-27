import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_now_user/authentication/view_profile.dart';
import 'package:service_now_user/global/global.dart';
import 'package:location/location.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:service_now_user/service/car_service.dart';
import 'package:service_now_user/service/taxi_service.dart';
import '../authentication/login_screen.dart';
import '../service/fuel_service.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GoogleMapController? _controller;
  final Location _locationTracker = Location();
  Marker? marker;
  Circle? circle;
  Map<dynamic, Marker> markers = <dynamic, Marker>{};
  Map<dynamic, Circle> circles = <dynamic, Circle>{};

  static CameraPosition initialLocation = const CameraPosition(
    target: LatLng(22.899185265097515, 89.5051113558963),
    zoom: 14.4746,
  );
  
  Future<Uint8List> getMarker(BuildContext context) async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("images/myLocation.png");
    return byteData.buffer.asUint8List();
  }

  Future<void> updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData, var uid) async {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    setState(() {
      marker = Marker(
          markerId: MarkerId(uid),
          position: latlng,
          rotation: newLocalData.heading!,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));


      circle = Circle(
          circleId: CircleId(uid),
          radius: newLocalData.accuracy!,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));

      markers[uid] = marker!;
      circles[uid] = circle!;
    });
  }

  void getCurrentLocation(BuildContext context) async {
    Uint8List imageData = await getMarker(context);
    var location = await _locationTracker.getLocation();
    setState(() {
      initialLocation = CameraPosition(
        target: LatLng(location.latitude!, location.longitude!),
        zoom: 18.00
      );
      _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(location.latitude!, location.longitude!),
        tilt: 0,
        zoom: 18.00)));
      updateMarkerAndCircle(location, imageData, currentFirebaseuser!.uid);
    });
  }

  XFile? image;

  @override
  void initState() {
    super.initState();
   getCurrentLocation(context);
    fetchData();
  }

  void fetchData() async{
    DatabaseReference  driversRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid);
    final user = await (driversRef.child("name")).get();
    final imageUrl = await (driversRef.child("image")).get();
    final userEmail = await (driversRef.child("email")).get();
    final userPhone = await (driversRef.child("password")).get();



    setState(() {
      user_name = user!.value.toString();
      user_email = userEmail.value.toString();
      user_phone = userPhone.value.toString();
      urlImage = imageUrl!.value.toString();

      //print("after setting: ${urlImage}");
    });
  }


  String user_email = "loading.....";
  String user_phone = "loading.....";
  String urlImage = "https://png.pngtree.com/png-vector/20210309/ourlarge/pngtree-not-loaded-during-loading-png-image_3022825.jpg";
  String user_name = "";

  @override 
  Widget build(BuildContext context) {
    
    return  Scaffold(
      appBar: AppBar(

        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('This is a snackbar')));

        leading: Builder(
          builder: (BuildContext context) {
            return Icon(Icons.home_rounded,
                  size: 30,
                  color: Colors.white,);

          },
        ),
        title: Text(user_name,
        style: TextStyle(
          fontSize: 25,
          fontFamily: "Ubuntu",
        ),),
        centerTitle: false,
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        elevation: 25,
        toolbarHeight: 60,
        actions: <Widget>[
          TextButton(

            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: ((context) => ViewProfile(user_name, user_phone, user_email, urlImage, name: '',))));
              Navigator.push(context, MaterialPageRoute(builder: ((context) => ViewProfile(name: user_name, phone: user_phone, email: user_email, urlImage: urlImage))));
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2.5, color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("images/loading.png"),
                //backgroundImage: AssetImage('images/service_now_logo.jpeg'),
                child: Container(
                    child: urlImage != null ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(urlImage,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : Icon(Icons.person,
                      size: 20,
                      color: Colors.white,)
                ),

                radius: 15.0,
              ),
            ),
          ),
          SizedBox(width: 10,),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey, spreadRadius: 1)],
                  border: Border(
                    bottom: BorderSide(width: 2, color: Colors.grey),
                  ),

                ),
                height: 620,
                child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: initialLocation,
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                    },
                    markers: Set<Marker>.of(markers.values),
                    circles: Set<Circle>.of(circles.values),
                  ),
                ),
            // floatingActionButton: FloatingActionButton(
            //     child: const Icon(Icons.location_searching),
            //     onPressed: () {
            //       // getCurrentLocation(context);
            //       // getActiveUsers(context);
            //     }),

              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(height: 18,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                height: 100,
                                width: 110,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(blurRadius: 3, color: Colors.blueGrey.shade500, spreadRadius: 1)]
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(width: 2, color: Colors.red.shade900),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: ((context) => CarService(name: user_name, phone: user_phone, email: user_email, urlImage: urlImage))));
                                    },
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image(
                                            image: AssetImage("images/service.png"),
                                            height: 60,
                                            width: 60,
                                          ),
                                          Text("Car Servicing",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.red.shade900,
                                              fontFamily: "Ubuntu",
                                            ),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                height: 100,
                                width: 110,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(blurRadius: 3, color: Colors.blueGrey.shade500, spreadRadius: 1)]
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(width: 2, color: Colors.red.shade900),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(

                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: ((context) => FuelService(name: user_name, phone: user_phone, email: user_email, urlImage: urlImage))));
                                    },
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image(
                                            image: AssetImage("images/fuel.png"),
                                            height: 60,
                                            width: 60,
                                          ),
                                          Text("Fuel",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.red.shade900,
                                              fontFamily: "Ubuntu",
                                            ),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                height: 100,
                                width: 110,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(blurRadius: 3, color: Colors.blueGrey.shade500, spreadRadius: 1)]
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(width: 2, color: Colors.red.shade900),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(

                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: ((context) => TaxiService(name: user_name, phone: user_phone, email: user_email, urlImage: urlImage))));
                                    },
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image(
                                            image: AssetImage("images/rent.png"),
                                            height: 60,
                                            width: 60,
                                          ),
                                          Text("Ambulance",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.red.shade900,
                                              fontFamily: "Ubuntu",
                                            ),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),

                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
