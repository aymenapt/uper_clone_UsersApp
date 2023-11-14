import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:users/buisenisse_logic/maps_provider/maps_provider.dart';
import 'package:users/data/places_predictions_model/placses_predictions_model.dart';
import 'package:users/presentation/app_manager/color_manager/color_manager.dart';
import 'package:users/presentation/screens/main_screen/main_screen.dart';
import 'package:users/presentation/widgets/my_text_style/my_text_style.dart';
import 'package:users/presentation/widgets/my_toast/my_toast.dart';

import '../../screens/search_location_screen/search_location_screen.dart';
import '../progress_dialogue/progress_doalogue.dart';

class PlacesPredictionsStyle extends StatelessWidget {
  final PlacesPredictions placesPredictions;

  const PlacesPredictionsStyle({super.key, required this.placesPredictions});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (ctx) => const ProgressDialogue(
                message: "Setting Up Drop-off , Please wait..."));

        try {
          await Provider.of<MapsProvider>(context, listen: false)
              .getLocationByID(placesPredictions.place_id.toString())
              .then((value) => Navigator.pop(context));

          // ignore: use_build_context_synchronously
        
          Navigator.pop(context, "DropOffSecssful");
        } catch (error) {
          showtoast(error);
        }

        print("hello");
      },
      child: Container(
        color: maincolor,
        height: height * 0.08,
        width: width * 0.6,
        alignment: Alignment.topRight,
        child: ListTile(
          leading: Icon(
            Icons.location_on,
            color: white,
            size: height * 0.034,
          ),
          title: MyDefaultTextStyle(
              text: placesPredictions.main_text.toString(),
              height: height * 0.018,
              bold: true,
              color: white),
          subtitle: MyDefaultTextStyle(
              text: placesPredictions.secondary_text.toString(),
              height: height * 0.016,
              color: white54),
        ),
      ),
    );
  }
}
