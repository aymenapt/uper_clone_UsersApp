import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/buisenisse_logic/maps_provider/maps_provider.dart';
import 'package:users/presentation/app_manager/color_manager/color_manager.dart';
import 'package:users/presentation/widgets/my_text_form/my_text_form.dart';
import 'package:users/presentation/widgets/my_text_style/my_text_style.dart';
import 'package:users/presentation/widgets/places_predictions_style/places_predictions_style.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  TextEditingController searchLoactionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: height * 0.27,
              width: width,
              decoration: const BoxDecoration(color: maincolor, boxShadow: [
                BoxShadow(
                    blurRadius: 6,
                    color: black45,
                    spreadRadius: 0.5,
                    offset: Offset(0.8, 0.8))
              ]),
              child: Stack(children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: height * 0.05,
                          left: width * 0.05,
                          right: width * 0.02),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back_rounded,
                            color: white, size: height * 0.032),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: height * 0.05,
                      ),
                      child: MyDefaultTextStyle(
                          text: "Search & DropOff Location",
                          height: height * 0.029,
                          color: white,
                          bold: true),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: height * 0.13),
                  child: SizedBox(
                      width: width * 0.85,
                      height: height * 0.2,
                      child: TextField(
                        onChanged: (input) async {
                          await Provider.of<MapsProvider>(context,
                                  listen: false)
                              .getPlacesAutoComplete(input);
                          ;
                        },
                        cursorColor: white54,
                        controller: searchLoactionController,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: black45,
                              size: 25,
                            ),
                            fillColor: white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide:
                                    const BorderSide(color: white, width: 2)),
                            hintText: "search...",
                            hintStyle: TextStyle(color: black45, fontSize: 13),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: Colors.white))),
                      )),
                ),
              ]),
            ),
            Provider.of<MapsProvider>(context, listen: true)
                        .placesPredictions
                        .isEmpty ||
                    searchLoactionController.text.isEmpty
                ? Container()
                : SizedBox(
                    height: height,
                    child: ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (BuildContext ctx, int index) {
                          return PlacesPredictionsStyle(
                              placesPredictions: Provider.of<MapsProvider>(
                                      context,
                                      listen: true)
                                  .placesPredictions[index]);
                        },
                        separatorBuilder: (BuildContext ctx, int index) {
                          return const Divider(
                            color: white,
                            thickness: 0.1,
                            height: 1,
                          );
                        },
                        itemCount:
                            Provider.of<MapsProvider>(context, listen: true)
                                .placesPredictions
                                .length),
                  ),
          ],
        ),
      ),
    );
  }
}
