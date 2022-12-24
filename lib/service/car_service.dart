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


class CarService extends StatefulWidget {
  const CarService({Key? key}) : super(key: key);

  @override
  State<CarService> createState() => _CarServiceState();
}

class _CarServiceState extends State<CarService> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("This is func"),
        ),
      ),
    );
  }
}
