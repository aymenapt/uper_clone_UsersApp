import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:users/presentation/app_manager/color_manager/color_manager.dart';
import 'package:users/presentation/widgets/my_text_style/my_text_style.dart';

import '../../../buisenisse_logic/auth_provider/auth_provider.dart';
import '../../screens/authnetication_screens/login_screen/login_screen.dart';
import '../progress_dialogue/progress_doalogue.dart';

class MyDrawer extends StatelessWidget {
  final String name;
  final String email;

  const MyDrawer({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Drawer(
      backgroundColor: white,
      child: Column(children: [
        Container(
            // margin: EdgeInsets.only(top: height * 0.04),

            alignment: Alignment.center,
            height: height * 0.25,
            width: width,
            color: maincolor,
            child: ListTile(
              leading: Icon(
                Icons.person,
                color: white,
                size: height * 0.08,
              ),
              title: MyDefaultTextStyle(
                  text: name, height: height * 0.018, bold: true, color: white),
              subtitle: MyDefaultTextStyle(
                  text: email,
                  height: height * 0.018,
                  bold: true,
                  color: white),
            )),

        // Drawer Boady
        SizedBox(
          height: height * 0.02,
        ),
        GestureDetector(
          child: ListTile(
            onTap: () {},
            leading: Icon(
              Icons.history,
              color: maincolor,
              size: height * 0.04,
            ),
            title: MyDefaultTextStyle(
                text: "History",
                height: height * 0.018,
                color: maincolor,
                bold: true),
          ),
        ),
        SizedBox(
          height: height * 0.02,
        ),
        GestureDetector(
          child: ListTile(
            onTap: () {},
            leading: Icon(
              Icons.person,
              color: maincolor,
              size: height * 0.04,
            ),
            title: MyDefaultTextStyle(
                text: "Visit Profile",
                height: height * 0.018,
                color: maincolor,
                bold: true),
          ),
        ),

        SizedBox(
          height: height * 0.02,
        ),

        GestureDetector(
          child: ListTile(
            onTap: () {},
            leading: Icon(
              Icons.info_outline_rounded,
              color: maincolor,
              size: height * 0.04,
            ),
            title: MyDefaultTextStyle(
                text: "About",
                height: height * 0.018,
                color: maincolor,
                bold: true),
          ),
        ),

        SizedBox(
          height: height * 0.02,
        ),

        GestureDetector(
          child: ListTile(
            onTap: () async {
              const ProgressDialogue(message: "LogOut...");

              await Provider.of<AuthService>(context, listen: false).logOut();

              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      duration: const Duration(milliseconds: 450),
                      type: PageTransitionType.leftToRight,
                      child: const LoginScreen()));
            },
            leading: Icon(
              Icons.logout,
              color: maincolor,
              size: height * 0.04,
            ),
            title: MyDefaultTextStyle(
                text: "LogOut",
                height: height * 0.018,
                color: maincolor,
                bold: true),
          ),
        )
      ]),
    );
  }
}
