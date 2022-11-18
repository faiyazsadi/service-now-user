import 'package:flutter/material.dart';
import 'package:service_now_user/global/global.dart';

import '../authentication/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('Logout'),
        onPressed: () {
          fAuth.signOut();
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => LoginScreen())));
        },
      ),
    );
  }
}
