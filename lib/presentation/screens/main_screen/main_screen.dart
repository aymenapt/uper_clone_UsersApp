import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:users/buisenisse_logic/assistant_provider/assistant_provider.dart';
import 'package:users/buisenisse_logic/auth_provider/auth_provider.dart';
import 'package:users/buisenisse_logic/maps_provider/maps_provider.dart';
import 'package:users/presentation/app_manager/color_manager/color_manager.dart';
import 'package:users/presentation/screens/authnetication_screens/login_screen/login_screen.dart';
import 'package:users/presentation/screens/search_location_screen/search_location_screen.dart';
import 'package:users/presentation/widgets/my_buttomn/my_buttomn.dart';
import 'package:users/presentation/widgets/my_drawer/my_drawer.dart';
import 'package:users/presentation/widgets/my_text_style/my_text_style.dart';
import 'package:users/presentation/widgets/my_toast/my_toast.dart';
import 'package:users/presentation/widgets/progress_dialogue/progress_doalogue.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? _newGoogleController;
  Position? userCurrentPosition;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  Position? currentPosition;

  String humanReaduableAdreese = "";
  var geoLocator = Geolocator();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> initializeLocationAndMap() async {
    // Check if location permission is allowed

    print("hello");
    bool isEnabled =
        Provider.of<MapsProvider>(context, listen: false).isEnabeld;

    if (isEnabled) {
      // Obtain and set user's current position
      Position cPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      userCurrentPosition = cPosition;

      Provider.of<MapsProvider>(context, listen: false).currentPosition =
          cPosition;

      LatLng latLngPosition = LatLng(cPosition.latitude, cPosition.longitude);

      CameraPosition cameraPosition =
          CameraPosition(target: latLngPosition, zoom: 14);

      if (_newGoogleController != null) {
        // Wait for the map to fully initialize before animating the camera
        _newGoogleController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
      }

      print("Longitude: ${latLngPosition.longitude}");
      print("Latitude: ${latLngPosition.latitude}");

      humanReaduableAdreese =
          await Provider.of<MapsProvider>(context, listen: false)
              .geoCodingLocate(latLngPosition.latitude.toString(),
                  latLngPosition.longitude.toString());
      Provider.of<MapsProvider>(context, listen: false)
          .creatIconActiveDriver(context);

      Provider.of<MapsProvider>(context, listen: false)
          .alocateDrivers(userCurrentPosition!);
          
      print("hello ${humanReaduableAdreese}");
    } else {
      // Handle permission not granted case
    }
  }

  void fetchUserData() async {
    await Provider.of<AssistantsService>(context, listen: false)
        .getCurrentUserInfo();
  }

  void googleBlackTheme() {
    _newGoogleController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  @override
  void initState() {
    super.initState();

    // Fetch user data and initialize location and map
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: sKey,
      extendBodyBehindAppBar: true,
      drawer: MyDrawer(
        name: Provider.of<AssistantsService>(context).client?.name.toString() ==
                null
            ? ''
            : Provider.of<AssistantsService>(context).client!.name.toString(),
        email: Provider.of<AssistantsService>(context)
                    .client
                    ?.email
                    .toString() ==
                null
            ? ''
            : Provider.of<AssistantsService>(context).client!.email.toString(),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            polylines: Provider.of<MapsProvider>(context).polyLineSet,
            markers: Provider.of<MapsProvider>(context).markerSet,
            circles: Provider.of<MapsProvider>(context).circleSet,
            onMapCreated: (controller) async {
              _googleMapController.complete(controller);
              setState(() {
                _newGoogleController = controller;
              });
              googleBlackTheme();
              initializeLocationAndMap();
            },
          ),
          Positioned(
            height: height * 0.15,
            left: width * 0.04,
            child: GestureDetector(
              onTap: () {
                sKey.currentState!.openDrawer();
              },
              child: const CircleAvatar(
                backgroundColor: gris,
                child: Icon(
                  Icons.menu,
                  color: white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: AnimatedSize(
              duration: const Duration(microseconds: 400),
              curve: Curves.easeIn,
              child: Container(
                height: height * 0.4,
                decoration: const BoxDecoration(
                    color: black45,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18))),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: height * 0.04, left: width * 0.04),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: white,
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyDefaultTextStyle(
                                  text: "From",
                                  height: height * 0.014,
                                  color: white54),
                              MyDefaultTextStyle(
                                  text: Provider.of<MapsProvider>(context)
                                              .humanReadableAdress
                                              .length >
                                          40
                                      ? "${Provider.of<MapsProvider>(context, listen: false).humanReadableAdress.substring(0, 38)}..."
                                      : Provider.of<MapsProvider>(context,
                                              listen: false)
                                          .humanReadableAdress,
                                  height: height * 0.014,
                                  color: white54)
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Divider(
                        thickness: height * 0.0018,
                        color: white54,
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var dropOffSecssful = await Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  child: const SearchLocationScreen()));

                          if (dropOffSecssful == "DropOffSecssful") {
                            await Provider.of<MapsProvider>(context,
                                    listen: false)
                                .drawPolyLinesFromSourceToDestination();

                            print(Provider.of<MapsProvider>(context,
                                    listen: false)
                                .polyLineSet
                                .length);

                            _newGoogleController!.animateCamera(
                                CameraUpdate.newLatLngBounds(
                                    Provider.of<MapsProvider>(context,
                                            listen: false)
                                        .boundsLatLng,
                                    65));
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_location_alt_outlined,
                              color: white,
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyDefaultTextStyle(
                                    text: "To",
                                    height: height * 0.014,
                                    color: white54),
                                MyDefaultTextStyle(
                                    text: Provider.of<MapsProvider>(context)
                                            .direction
                                            .name ??
                                        "Where to go ?",
                                    height: height * 0.014,
                                    color: white54)
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Divider(
                        thickness: height * 0.0018,
                        color: white54,
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Defaultbutton(
                          functon: () async {
                            if (Provider.of<MapsProvider>(context,
                                        listen: false)
                                    .direction
                                    .name ==
                                null) {
                              showtoast("Please Slecte where you went to go");
                            } else {
                              Provider.of<MapsProvider>(context, listen: false)
                                  .searchForAvailbleDrivers(context);
                            }
                          },
                          text: "Request a ride",
                          height: height * 0.06,
                          width: width * 0.4,
                          fontsize: height * 0.016,
                          color: maincolor,
                          textcolor: white)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
