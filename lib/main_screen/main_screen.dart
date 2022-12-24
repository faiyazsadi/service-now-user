import 'dart:async';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:service_now_user/global/global.dart';
import 'package:location/location.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:service_now_user/service/car_service.dart';
import '../authentication/login_screen.dart';

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
    ByteData byteData = await DefaultAssetBundle.of(context).load("images/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData, var uid) async {
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

  @override
  void initState() {
    super.initState();
    getCurrentLocation(context);
  }

  @override 
  Widget build(BuildContext context) {
    
    return  Scaffold(
      appBar: AppBar(

        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('This is a snackbar')));

        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                onPressed: (){},
                icon: Icon(Icons.settings)
            );
          },
        ),
        title: const Text("Rifat Arefin",
        style: TextStyle(
          fontSize: 26,
          fontFamily: "Ubuntu"
        ),),
        centerTitle: false,
        backgroundColor: Colors.red.shade900,
        toolbarHeight: 65,
        actions: <Widget>[
          TextButton(
            onPressed: () { Scaffold.of(context).openDrawer(); },
            child: const CircleAvatar(
              backgroundImage: AssetImage('images/service_now_logo.jpeg'),
              radius: 17.0,
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
                  border: Border(
                    bottom: BorderSide(width: 7, color: Colors.red.shade900),
                  ),
                ),
      
                height: 600,
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
      
              Container(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
      
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: ((context) => CarService())));
                                },
                                child: Image(
                                    image: AssetImage("images/service.png"),
                                  height: 60,
                                  width: 60,
                                ),
                            ),
                          ),
                        ),
      
                        Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
      
                              onPressed: (){},
                              child: Image(
                                image: AssetImage("images/fuel.png"),
                                height: 60,
                                width: 60,
                              ),
                            ),
                          ),
                        ),
      
                        Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
                              onPressed: (){},
                              child: Image(
                                image: AssetImage("images/rent.png"),
                                height: 60,
                                width: 60,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
      
                            child: TextButton(
      
                              onPressed: (){},
                              child: Image(image: AssetImage("images/courier.png"),
                                height: 60,
                                width: 60,
                              ),
                            ),
                          ),
                        ),
      
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 16,),
                        Text("Car Service",
                        style: TextStyle(
                          fontWeight: ui.FontWeight.bold,
                          fontSize: 15,
                          color: Colors.red.shade900,
                          fontFamily: "Ubuntu",
                        ),),
      
                        SizedBox(width: 55,),
                        Text("Fuel",
                          style: TextStyle(
                            fontWeight: ui.FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red.shade900,
                            fontFamily: "Ubuntu",
                          ),),
      
                        SizedBox(width: 55,),
                        Text("Rent a Car",
                          style: TextStyle(
                            fontWeight: ui.FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red.shade900,
                            fontFamily: "Ubuntu",
                          ),),
      
                        SizedBox(width: 44,),
                        Text("Courier",
                          style: TextStyle(
                            fontWeight: ui.FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red.shade900,
                            fontFamily: "Ubuntu",
                          ),),
      
                      ],
                    )
                  ],
                ),
      
              )
      
            ],
          ),
        ),
      )
    );
  }
}
