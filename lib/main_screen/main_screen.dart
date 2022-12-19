import 'dart:async';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:service_now_user/global/global.dart';
import 'package:location/location.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Future<void> updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData, var uid) async {
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);
    setState(() async {
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
        title: const Text("Google Map"),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: Set<Marker>.of(markers.values),
        circles: Set<Circle>.of(circles.values),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.location_searching),
          onPressed: () {
            // getCurrentLocation(context);
            // getActiveUsers(context);
          }),
    );
  }
}
