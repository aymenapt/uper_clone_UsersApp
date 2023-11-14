import 'package:flutter/material.dart';

import '../../app_manager/color_manager/color_manager.dart';
import '../my_text_style/my_text_style.dart';

class ProgressDialogue extends StatelessWidget {
  final String message;

  const ProgressDialogue({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      
      insetAnimationCurve: Curves.bounceInOut,
      insetAnimationDuration: const Duration(microseconds: 300),
      child: Container(
        padding: const EdgeInsets.only(left: 30),
        height: 90,
        width: 350,
        decoration: BoxDecoration(
            color: white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(maincolor),
            ),
            const SizedBox(
              width: 15,
            ),
            Flexible(
              child: MyDefaultTextStyle(
                  text: message, height: 13, color: black, bold: true),
            )
          ],
        ),
      ),
    );
  }
}
