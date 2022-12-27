import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../authentication/view_profile.dart';
import '../global/global.dart';
import '../main_screen/main_screen.dart';
import '../widgets/progress_dialog.dart';
import 'accept.dart';


class TaxiService extends StatefulWidget {
  late String name, email, phone, urlImage;
  TaxiService({required this.name, required this.phone, required this.email, required this.urlImage});
  // const CarService({super.key});
  @override
  State<TaxiService> createState() => _TaxiServiceState(name, phone, email, urlImage);
}

class _TaxiServiceState extends State<TaxiService> {
  late String name, email, phone, urlImage;

  _TaxiServiceState(this.name, this.email, this.phone, this.urlImage);

  StreamSubscription? _locationSubscription, _locationSubscriptionOthers;
  final Location _locationTracker = Location();
  Marker? marker;
  Circle? circle;
  GoogleMapController? _controller;
  Map<dynamic, Marker> markers = <dynamic, Marker>{};
  Map<dynamic, Circle> circles = <dynamic, Circle>{};

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates
    );
    polylines[id] = polyline;
    setState((){});
  }
  void makeLines(PointLatLng myLocation, PointLatLng userLocation) async {
    await polylinePoints
        .getRouteBetweenCoordinates(
      // 'GOOGLE MAP API KEY'
      // PointLatLng(6.2514, 80.7642), //Starting LATLANG
      // PointLatLng(6.9271, 79.8612), //End LATLANG
      'AIzaSyB3UWDair3TJS0xnJviTeo3wasW1TUvLdI',
      myLocation,
      userLocation,
      travelMode: TravelMode.driving,
    ).then((value) {
      value.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }).then((value) {
      Navigator.push(context, MaterialPageRoute(builder: ((context) => Accept(myLocation: myLocation, driverLocation: driverLocation ))));
      addPolyLine();
    });
  }

  static CameraPosition initialLocation = const CameraPosition(
    target: LatLng(22.899185265097515, 89.5051113558963),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker(BuildContext context) async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("images/myLocation.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData, var uid) {
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
    try {
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
      });
      updateMarkerAndCircle(location, imageData, currentFirebaseuser!.uid);
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
      usersRef.child(currentFirebaseuser!.uid).update({"latitude": location.latitude, "longitude": location.longitude});

      DatabaseReference userConnection = FirebaseDatabase.instance.ref().child("users/${currentFirebaseuser!.uid}/isActive");
      userConnection.onDisconnect().set(false);

      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }


      _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          //************this line would be uncommented
          usersRef.child(currentFirebaseuser!.uid).update({"latitude": newLocalData.latitude, "longitude": newLocalData.longitude});
          DatabaseReference userConnection = FirebaseDatabase.instance.ref().child("users/${currentFirebaseuser!.uid}/isActive");
          userConnection.onDisconnect().set(false);
          _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude!, newLocalData.longitude!),
              tilt: 0,
              zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData, currentFirebaseuser!.uid);
        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void getActiveDrivers(BuildContext context) async {
    try {
      if (_locationSubscriptionOthers != null) {
        _locationSubscriptionOthers!.cancel();
      }
      _locationSubscriptionOthers = _locationTracker.onLocationChanged.listen((newLocalData) async {
        if(_controller != null) {
          DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
          final snapshot = await driversRef.get();
          final drivers = snapshot.value as Map<dynamic, dynamic>;
          drivers.forEach((key, value) async {
            if(value["isActive"] == true) {
              var uid = value["id"];
              if(value["id"] != currentFirebaseuser!.uid) {
                Uint8List imageData = await getMarker(context);
                var latitude = value["latitude"];
                var longitude = value["longitude"];
                LatLng latLng = LatLng(latitude, longitude);
                setState(() {
                  var m = Marker(
                      markerId: MarkerId(uid),
                      position: latLng,
                      // rotation: newLocalData.heading!,
                      draggable: false,
                      zIndex: 2,
                      flat: true,
                      anchor: const Offset(0.5, 0.5),
                      icon: BitmapDescriptor.fromBytes(imageData));
                  var c = Circle(
                      circleId: CircleId(uid),
                      // radius: latLng.accuracy,
                      zIndex: 1,
                      strokeColor: Colors.blue,
                      center: latLng,
                      fillColor: Colors.blue.withAlpha(70));

                  markers[uid] = m;
                  circles[uid] = c;
                });
              }
            }
          });
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void notifyActiveDrivers() async {
    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
    final snapshot = await driversRef.get();
    final drivers = snapshot.value as Map<dynamic, dynamic>;
    drivers.forEach((key, value) async {
      if(value["id"] != currentFirebaseuser!.uid && value["isActive"] == true) {
        DateTime time = DateTime.now();
        await driversRef.child(value["id"]).update({"request_from": currentFirebaseuser!.uid});
        await driversRef.child(value["id"]).update({"request_time": time.toString()});
      }
    });
  }
  late PointLatLng myLocation, driverLocation;

  getPositions() async {
    DatabaseReference mylatRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid).child("latitude");
    DatabaseReference mylonRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid).child("longitude");
    var myLatitude, myLongitude;
    final mylat = await mylatRef.get();
    final mylon = await mylonRef.get().then((mylon) => {
      myLatitude = mylat.value,
      myLongitude = mylon.value
    });
    myLocation =  PointLatLng(myLatitude, myLongitude);

    DatabaseReference acceptRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid).child("AcceptedBy");
    final accepted_by = await acceptRef.get();

    DatabaseReference latRef = FirebaseDatabase.instance.ref().child("drivers").child(accepted_by.value.toString()).child("latitude");
    DatabaseReference lonRef = FirebaseDatabase.instance.ref().child("drivers").child(accepted_by.value.toString()).child("longitude");

    var driverLatitude, driverLongitude;
    final lat = await latRef.get();
    final lon = await lonRef.get().then((lon) => {
      driverLatitude = lat.value,
      driverLongitude = lon.value,
    });
    driverLocation = PointLatLng(driverLatitude, driverLongitude);
    makeLines(myLocation, driverLocation);
  }

  @override
  initState() {
    super.initState();

    getCurrentLocation(context);
    getActiveDrivers(context);

  }
  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    if (_locationSubscriptionOthers != null) {
      _locationSubscriptionOthers!.cancel();
    }
    super.dispose();
  }
  request() async {

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid).child("isBusy");
    final snapshot = await userRef.get();
    // Timer(const Duration(seconds: 60), () async {
    //   showDialog(
    //       context: context,
    //       barrierDismissible: false,
    //       barrierColor: Colors.transparent,
    //       useSafeArea: false,
    //       builder: (BuildContext context) {
    //         return Container(
    //           decoration: BoxDecoration(
    //             border: Border.all(width: 2, color: Colors.red),
    //           ),
    //           child: ProgressDialog(
    //             message: "Requesting to providers. Please Wait...",
    //           ),
    //         );
    //       }
    //       );
    //
    //
    //
    //
    //
    // });



    // DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid).child("isBusy");
    // final snapshot = await userRef.get();
    if(snapshot.value == false) {
      notifyActiveDrivers();
      userRef.set(true);
      requestDisabled = true;
      setState(() {
      });
    } else {
      // TODO
    }
  }
  cancel() async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid).child("isBusy");
    userRef.set(false);
    requestDisabled = false;
    polylineCoordinates.clear();
    polylines.clear();
    DatabaseReference userRef2 = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid).child("AcceptedBy");
    final driverid = await userRef2.get();
    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers").child(driverid.value.toString()).child("isBusy");
    driverRef.set(false);
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context){
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseuser!.uid).child("AcceptTime");
    final snapshot = ref.get().asStream();
    return  Scaffold(
      appBar: AppBar(
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('This is a snackbar')));

        leading: Builder(
          builder: (BuildContext context) {
            return Container(
                child: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: ((context) => MainScreen())));
                  },
                  icon: Icon(Icons.home,
                    size: 30,),

                )
            );
          },
        ),
        title: Text("Car Servicing",
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
              Navigator.push(context, MaterialPageRoute(builder: ((context) => ViewProfile(name: name, phone: phone, email: email, urlImage: urlImage))));
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



                  // child: Image.network(urlImage),
                  //
                  //
                  // child: Image.network(
                  //   urlImage,
                  //   fit: BoxFit.fill,
                  //   loadingBuilder: (BuildContext context, Widget child,
                  //       ImageChunkEvent? loadingProgress) {
                  //     if (loadingProgress == null) return child;
                  //     return Center(
                  //       child: CircularProgressIndicator(
                  //         value: loadingProgress.expectedTotalBytes != null
                  //             ? loadingProgress.cumulativeBytesLoaded /
                  //             loadingProgress.expectedTotalBytes!
                  //             : null,
                  //       ),
                  //     );
                  //   },
                  // ),

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
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey, spreadRadius: 1)],
                  border: Border(
                    bottom: BorderSide(width: 2, color: Colors.white),
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
                  polylines: Set<Polyline>.of(polylines.values),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 50.0, bottom: 1100),
              //   child: FloatingActionButton(
              //       child: const Icon(Icons.location_searching),
              //       onPressed: () {
              //         // getCurrentLocation(context);
              //         // getActiveUsers(context);
              //       }),
              // ),


              // Center(
              //   child: Row(
              //     children: [

              //       ElevatedButton(
              //         onPressed: requestDisabled ? null : request,
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.deepPurple[700],
              //         ),
              //         child: const Text('Request Help'),
              //       ),
              //       ElevatedButton(
              //         onPressed: requestDisabled ? cancel : null,
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.red[700],
              //         ),
              //         child: const Text('Cancel Request'),
              //       ),
              //     ],
              //   ),
              // ),


              Center(
                child: Container(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        StreamBuilder(
                            stream: snapshot,
                            builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
                              if(snapshot.hasData) {
                                currAcceptTime = snapshot.data!.value.toString();
                                if(prevAcceptTime != currAcceptTime) {
                                  print(snapshot.data!.value);
                                  prevAcceptTime = currAcceptTime;
                                  getPositions();
                                }
                              }
                              return const Text("");
                            }
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.black45),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 0.0, right: 0, top: 10, bottom: 10),
                                  child: ElevatedButton(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text('Help Request'),
                                    ),
                                    onPressed: () {
                                      showDialog(context: context, builder: (BuildContext contest) {
                                        return AlertDialog(
                                            title: Text("Warning!",
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.red.shade900,
                                                fontFamily: "FredokaOne",
                                              ),),
                                            content: Text("Are you sure to request?",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black45,
                                                fontFamily: "Ubuntu",
                                              ),),
                                            actions: [
                                              TextButton(
                                                onPressed: requestDisabled ? null : request,
                                                //Navigator.push(context, MaterialPageRoute(builder: ((context) => CarService(name: user_name, phone: user_phone, email: user_email, urlImage: urlImage))));
                                                child: Text("YES",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Colors.red.shade900,
                                                    fontFamily: "Ubuntu",
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: (){
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("NO",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Colors.red.shade900,
                                                    fontFamily: "Ubuntu",
                                                  ),
                                                ),

                                              ),
                                            ]
                                        );
                                      }
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.grey.shade900,
                                        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                                        textStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Ubuntu")),
                                  ),




                                  // TextButton(
                                  //   onPressed: requestDisabled ? cancel : null,
                                  //   child: Center(
                                  //     child: Column(
                                  //       children: [
                                  //         Image(
                                  //           image: AssetImage("images/cancelRequest.png"),
                                  //           height: 50,
                                  //           width: 50,
                                  //         ),
                                  //         SizedBox(height: 7,),
                                  //         Text("Cancel Requst",
                                  //           style: TextStyle(
                                  //             fontWeight: FontWeight.bold,
                                  //             fontSize: 15,
                                  //             color: Colors.red.shade900,
                                  //             fontFamily: "Ubuntu",
                                  //           ),),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0.0, right: 0, top: 10, bottom: 10),
                                  child: ElevatedButton(
                                    child: Text('Cancel Request'),
                                    onPressed: () {
                                      showDialog(context: context, builder: (BuildContext contest) {
                                        return AlertDialog(
                                            title: Text("Warning!",
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.red.shade900,
                                                fontFamily: "FredokaOne",
                                              ),),
                                            content: Text("Are you sure to request?",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black45,
                                                fontFamily: "Ubuntu",
                                              ),),
                                            actions: [
                                              TextButton(
                                                onPressed: (){
                                                  cancel();
                                                },
                                                //onPressed: requestDisabled ? null : request,
                                                //Navigator.push(context, MaterialPageRoute(builder: ((context) => CarService(name: user_name, phone: user_phone, email: user_email, urlImage: urlImage))));
                                                child: Text("YES",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Colors.red.shade900,
                                                    fontFamily: "Ubuntu",
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: (){
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("NO",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Colors.red.shade900,
                                                    fontFamily: "Ubuntu",
                                                  ),
                                                ),

                                              ),
                                            ]
                                        );
                                      }
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.red.shade900,
                                        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                                        textStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Ubuntu")),
                                  ),




                                  // TextButton(
                                  //   onPressed: requestDisabled ? cancel : null,
                                  //   child: Center(
                                  //     child: Column(
                                  //       children: [
                                  //         Image(
                                  //           image: AssetImage("images/cancelRequest.png"),
                                  //           height: 50,
                                  //           width: 50,
                                  //         ),
                                  //         SizedBox(height: 7,),
                                  //         Text("Cancel Requst",
                                  //           style: TextStyle(
                                  //             fontWeight: FontWeight.bold,
                                  //             fontSize: 15,
                                  //             color: Colors.red.shade900,
                                  //             fontFamily: "Ubuntu",
                                  //           ),),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(left: 0.0, right: 0, top: 10, bottom: 10),
                                //   child: ElevatedButton(
                                //     child: Text('Cancel Request'),
                                //     onPressed: () {
                                //       onPressed: requestDisabled ? cancel : null;
                                //     },
                                //     style: ElevatedButton.styleFrom(
                                //         primary: Colors.red.shade900,
                                //         padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                                //         textStyle: TextStyle(
                                //             fontSize: 20,
                                //             fontWeight: FontWeight.bold,
                                //             fontFamily: "Ubuntu")),
                                //   ),
                                //
                                //
                                //
                                //
                                //   // TextButton(
                                //   //   onPressed: requestDisabled ? cancel : null,
                                //   //   child: Center(
                                //   //     child: Column(
                                //   //       children: [
                                //   //         Image(
                                //   //           image: AssetImage("images/cancelRequest.png"),
                                //   //           height: 50,
                                //   //           width: 50,
                                //   //         ),
                                //   //         SizedBox(height: 7,),
                                //   //         Text("Cancel Requst",
                                //   //           style: TextStyle(
                                //   //             fontWeight: FontWeight.bold,
                                //   //             fontSize: 15,
                                //   //             color: Colors.red.shade900,
                                //   //             fontFamily: "Ubuntu",
                                //   //           ),),
                                //   //       ],
                                //   //     ),
                                //   //   ),
                                //   // ),
                                // ),

                              ],
                            ),
                          ),
                        ),
                        // SizedBox(height: 10,),
                      ],
                    ),
                  ),

                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}