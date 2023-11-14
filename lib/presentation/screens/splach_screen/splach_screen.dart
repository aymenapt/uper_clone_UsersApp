import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users/buisenisse_logic/maps_provider/maps_provider.dart';

import '../../../buisenisse_logic/assistant_provider/assistant_provider.dart';
import '../../app_manager/color_manager/color_manager.dart';
import '../../widgets/my_text_style/my_text_style.dart';
import '../authnetication_screens/signup_screen/signp_screen.dart';
import '../main_screen/main_screen.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({Key? key}) : super(key: key);

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  void getPermission() async {
    await Provider.of<MapsProvider>(context, listen: false)
        .checkIfLocationPermissionAllowed();
     Provider.of<MapsProvider>(context,listen: false).creatIconActiveDriver(context);   
  }

  void pagenavigate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString("id") == null) {
      prefs.setString("id", "");
    }

    if (!prefs.getString('id')!.isEmpty) {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight, child: MainScreen()));
    } else if (prefs.getString('id')!.isEmpty) {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.theme, child: const SignUpScreen()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getPermission();
    Timer(const Duration(milliseconds: 4000), () {
      pagenavigate();
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: maincolor,
      extendBody: true,
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: height * 0.04),
                    height: height * 0.03,
                    width: width * 0.03,
                    decoration:
                        BoxDecoration(color: white, shape: BoxShape.circle),
                  ),
                  SizedBox(
                    width: width * 0.02,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: MyDefaultTextStyle(
                        text: "Users", height: height * 0.06, bold: true),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.38,
              ),
              Container(
                  alignment: Alignment.center,
                  child: Text(
                    'made by',
                    style: TextStyle(
                        color: white,
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(
                height: height * 0.009,
              ),
              Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Aymen Academy',
                    style: TextStyle(
                        color: white,
                        fontSize: height * 0.019,
                        fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ))
            ]),
      ),
    );
  }
}
