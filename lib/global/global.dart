import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;

User? currentFirebaseuser;

var prevAcceptTime = "", currAcceptTime = "";
bool requestDisabled = false;