import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/buisenisse_logic/maps_provider/maps_provider.dart';

import 'package:users/presentation/app_manager/color_manager/color_manager.dart';
import 'package:users/presentation/widgets/my_text_style/my_text_style.dart';

class NearserDriversScreen extends StatefulWidget {
  const NearserDriversScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<NearserDriversScreen> createState() => _NearserDriversScreenState();
}

class _NearserDriversScreenState extends State<NearserDriversScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: white,
          ),
          onPressed: () {
            Provider.of<MapsProvider>(context, listen: false)
                .databaseReference!
                .remove();

            Navigator.pop(context);
          },
        ),
        backgroundColor: maincolor,
        title: MyDefaultTextStyle(
            text: "Nearset Drivers Screen",
            height: height * 0.018,
            bold: true,
            color: white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          child: ListView.builder(
            itemCount: Provider.of<MapsProvider>(context).dList.length,
            itemBuilder: (context, index) {
              return SizedBox(
                height: height * 0.15,
                child: Card(
                  color: Colors.grey,
                  elevation: 3,
                  shadowColor: Colors.green,
                  margin: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      Provider.of<MapsProvider>(context, listen: false)
                          .getspescificDriverID(index);
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Image.asset(
                          "assets/images/${Provider.of<MapsProvider>(context).dList[index]["cardetail"]["car_type"]}.png"),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Provider.of<MapsProvider>(context).dList[index]
                                ["name"],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            Provider.of<MapsProvider>(context).dList[index]
                                ["cardetail"]["car_model"],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: MyDefaultTextStyle(

                                // show amount by the type of the car
                                text: Provider.of<MapsProvider>(context)
                                                .dList[index]["cardetail"]
                                            ["car_type"] ==
                                        "bike"
                                    ? "${(Provider.of<MapsProvider>(context, listen: false).calculateTotalFearAmount() / 2).toString()} Dz"
                                    : Provider.of<MapsProvider>(context)
                                                    .dList[index]["cardetail"]
                                                ["car_type"] ==
                                            "uber-go"
                                        ? "${(Provider.of<MapsProvider>(context, listen: false).calculateTotalFearAmount()).toString()} Dz"
                                        : "${(Provider.of<MapsProvider>(context, listen: false).calculateTotalFearAmount() * 2).toString()} Dz",
                                height: height * 0.016,
                                color: black),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Flexible(
                            child: MyDefaultTextStyle(
                                text:
                                    "${(Provider.of<MapsProvider>(context).directionDetail.distance_value! / 1000).toStringAsFixed(1)} Km",
                                height: height * 0.016,
                                color: black45),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
