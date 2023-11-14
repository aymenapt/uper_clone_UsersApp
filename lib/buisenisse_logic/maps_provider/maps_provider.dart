import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users/buisenisse_logic/assistant_provider/assistant_provider.dart';
import 'package:users/data/active_drivers_model/active_drivers_model.dart';
import 'package:users/data/client_model/client.dart';
import 'package:users/data/direction_detail_model/direction_detail_model.dart';
import 'package:users/data/places_predictions_model/placses_predictions_model.dart';
import 'package:users/presentation/app_manager/api_key/aoi_key.dart';
import 'package:http/http.dart' as http;
import 'package:users/presentation/app_manager/color_manager/color_manager.dart';
import 'package:users/presentation/screens/nearset_drivers_screen/nearset_drivers_screen.dart';
import 'package:users/presentation/widgets/my_toast/my_toast.dart';

import '../../data/direction_model/direction_model.dart';

class MapsProvider with ChangeNotifier {
  String humanReadableAdress = "";
  LocationPermission? _locationPermission;
  late LatLngBounds boundsLatLng;
  Direction direction = Direction();
  DirectionDetail directionDetail = DirectionDetail();
  List<PlacesPredictions> placesPredictions = [];
  bool isEnabeld = false;
  Position? currentPosition;
  List<LatLng> pLineCordinatesList = [];
  List<ActiveDrivers> activeDriversList = [];
  List dList = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool activeDriverLoadKey = false;
  BitmapDescriptor? activeDriverIcon;
// this variable to save our request ride to data base
  DatabaseReference? databaseReference;

  // this variable represent specific driver that be chosen by user

  String? specificDriverID;
  Future<bool> checkIfLocationPermissionAllowed() async {
    isEnabeld = await Geolocator.isLocationServiceEnabled();

    if (!isEnabeld) {
      isEnabeld = false;
      notifyListeners();
      return false;
    }

    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();

      if (_locationPermission == LocationPermission.denied) {
        isEnabeld = false;
        notifyListeners();
        return false;
      }
    }

    if (_locationPermission == LocationPermission.deniedForever) {
      isEnabeld = false;
      notifyListeners();
    }
    isEnabeld = true;
    notifyListeners();
    return true;
  }

  Future<String> geoCodingLocate(String lat, String long) async {
    String baseUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=AIzaSyAc41mVv_78s4uKORafWHW-4W5_M02vU0M";

    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        humanReadableAdress = data["results"][0]["formatted_address"];
        notifyListeners();
        return humanReadableAdress;
      } else {
        print(res.body);
        return humanReadableAdress;
      }
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> getPlacesAutoComplete(String input) async {
    if (input.isNotEmpty) {
      String baseUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:DZ";

      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        if (data["predictions"] != null) {
          placesPredictions =
              (data["predictions"] as List).map<PlacesPredictions>((e) {
            final prediction = PlacesPredictions.fromMap(e);
            notifyListeners();
            print("Mapped prediction: $prediction");
            return prediction;
          }).toList();
          notifyListeners();
          print("placesPredictions: $placesPredictions");
        } else {
          print("No predictions found in response.");
        }
      } else {
        print("Error response: ${res.body}");
        throw "There is an error in the response.";
      }
    }
  }

  Future<void> getLocationByID(String locationID) async {
    String baseUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$locationID&key=$apiKey";

    try {
      final res = await http.get(Uri.parse(baseUrl));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        direction.name = data["result"]["name"];
        direction.lat = data["result"]["geometry"]["location"]["lat"];
        direction.lng = data["result"]["geometry"]["location"]["lng"];
        notifyListeners();

        print(direction.name);
        print(direction.lat);
        print(direction.lng);
      } else {
        throw "response error";
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> getDirections(
      LatLng originalPosition, LatLng distinationPosition) async {
    String baseUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originalPosition.latitude},${originalPosition.longitude}&destination=${distinationPosition.latitude},${distinationPosition.longitude}&key=$apiKey";

    try {
      final res = await http.get(Uri.parse(baseUrl));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        directionDetail.distance_text =
            data["routes"][0]["legs"][0]["distance"]["text"];

        directionDetail.distance_value =
            data["routes"][0]["legs"][0]["distance"]["value"];

        directionDetail.duration_text =
            data["routes"][0]["legs"][0]["duration"]["text"];

        directionDetail.duration_value =
            data["routes"][0]["legs"][0]["duration"]["value"];

        directionDetail.points =
            data["routes"][0]["overview_polyline"]["points"];

        notifyListeners();

        print("points is : ${directionDetail.points}");
      } else {
        throw "response error";
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> drawPolyLinesFromSourceToDestination() async {
    LatLng originalPosition =
        LatLng(currentPosition!.latitude, currentPosition!.longitude);
    LatLng destinattionPosition =
        LatLng(direction.lat ?? 0, direction.lng ?? 0);

    await getDirections(originalPosition, destinattionPosition);

    polyLineSet.clear();
    pLineCordinatesList.clear();

    if (directionDetail.points != null) {
      PolylinePoints polylinePoints = PolylinePoints();

      List<PointLatLng> decodepolyLineList =
          polylinePoints.decodePolyline(directionDetail.points ?? "");

      if (decodepolyLineList.isNotEmpty) {
        for (var pointLatLng in decodepolyLineList) {
          pLineCordinatesList
              .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        }

        Polyline polyline = Polyline(
            polylineId: const PolylineId("PolylineID"),
            color: maincolor,
            jointType: JointType.round,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            points: pLineCordinatesList,
            geodesic: true);

        polyLineSet.add(polyline);

        notifyListeners();

        if (originalPosition.latitude > destinattionPosition.latitude &&
            originalPosition.longitude > destinattionPosition.longitude) {
          boundsLatLng = LatLngBounds(
              southwest: destinattionPosition, northeast: originalPosition);
        } else if (originalPosition.longitude >
            destinattionPosition.longitude) {
          boundsLatLng = LatLngBounds(
            southwest: LatLng(
                originalPosition.latitude, destinattionPosition.longitude),
            northeast: LatLng(
                destinattionPosition.latitude, originalPosition.longitude),
          );
        } else if (originalPosition.latitude > destinattionPosition.latitude) {
          boundsLatLng = LatLngBounds(
            southwest: LatLng(
                destinattionPosition.latitude, originalPosition.longitude),
            northeast: LatLng(
                originalPosition.latitude, destinattionPosition.longitude),
          );
        } else {
          boundsLatLng = LatLngBounds(
              southwest: originalPosition, northeast: destinattionPosition);
        }

        notifyListeners();

        Marker originMarker = Marker(
          markerId: const MarkerId("originID"),
          infoWindow:
              InfoWindow(title: humanReadableAdress, snippet: "origin "),
          position: originalPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        );

        Marker distinationMarker = Marker(
          markerId: const MarkerId("DistinationID"),
          infoWindow: InfoWindow(title: direction.name, snippet: "destination"),
          position: destinattionPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );

        markerSet.add(originMarker);
        markerSet.add(distinationMarker);
        notifyListeners();

        Circle originCircle = Circle(
          circleId: const CircleId("originID"),
          fillColor: Colors.green,
          radius: 12,
          strokeWidth: 3,
          strokeColor: Colors.white,
          center: originalPosition,
        );

        Circle destinationCircle = Circle(
          circleId: const CircleId("DistinationID"),
          fillColor: Colors.green,
          radius: 12,
          strokeWidth: 3,
          strokeColor: Colors.red,
          center: destinattionPosition,
        );

        circleSet.add(originCircle);
        circleSet.add(destinationCircle);
        notifyListeners();
      }
    }
  }

  void alocateDrivers(Position userCurrentPosition) {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(
            userCurrentPosition.latitude, userCurrentPosition.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          // when a driver become online
          case Geofire.onKeyEntered:
            ActiveDrivers activeDrivers = ActiveDrivers();
            activeDrivers.driverID = map['key'];
            activeDrivers.driver_lat = map['latitude'];
            activeDrivers.driver_lng = map['longitude'];
            activeDriversList.add(activeDrivers);
            print(activeDriversList.length);
            notifyListeners();
            if (activeDriverLoadKey) {
              displayActiveDriversOnMap();
            }

            notifyListeners();
            break;

          //when driver become offline
          case Geofire.onKeyExited:
            deleteActiveDriver(map["key"]);

            notifyListeners();

            break;
          // when driver moved
          case Geofire.onKeyMoved:
            ActiveDrivers activeDrivers = ActiveDrivers();
            activeDrivers.driverID = map['key'];
            activeDrivers.driver_lat = map['latitude'];
            activeDrivers.driver_lng = map['longitude'];

            updateActiveDriver(activeDrivers);
            displayActiveDriversOnMap();

            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            print(map['result']);
            displayActiveDriversOnMap();

            break;
        }
      }
    });
    notifyListeners();
  }

  void deleteActiveDriver(String id) {
    int index =
        activeDriversList.indexWhere((element) => element.driverID == id);

    activeDriversList.removeAt(index);

    markerSet.removeWhere((element) {
      print("markerid ${element.markerId.value}");
      return element.markerId.value == id;
    });
    notifyListeners();
  }

  void updateActiveDriver(ActiveDrivers activeDrivers) {
    int index = activeDriversList
        .indexWhere((element) => element.driverID == activeDrivers.driverID);

    activeDriversList[index].driver_lat = activeDrivers.driver_lat;
    activeDriversList[index].driver_lng = activeDrivers.driver_lng;
    notifyListeners();
  }

  void displayActiveDriversOnMap() {
    markerSet.clear();
    circleSet.clear();

    Set<Marker> activeDriverMarckerSet = Set<Marker>();
    notifyListeners();

    for (ActiveDrivers activeDrivers in activeDriversList) {
      LatLng latLng =
          LatLng(activeDrivers.driver_lat!, activeDrivers.driver_lng!);

      Marker marker = Marker(
          markerId: MarkerId(activeDrivers.driverID!),
          rotation: 360,
          icon: activeDriverIcon == null
              ? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueYellow)
              : activeDriverIcon!,
          position: latLng);

      activeDriverMarckerSet.add(marker);
    }

    markerSet = activeDriverMarckerSet;
    notifyListeners();
  }

  creatIconActiveDriver(BuildContext context) {
    if (activeDriverIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));

      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car.png")
          .then((value) {
        activeDriverIcon = value;
        notifyListeners();
      });
    }
  }

  void searchForAvailbleDrivers(BuildContext context) async {
    if (activeDriversList.isEmpty) {
      //   databaseReference!.remove();
      showtoast("There is no avaolible drivers , try later");
    } else {
      await retriveDriversInformation(activeDriversList);

      Provider.of<MapsProvider>(context, listen: false)
          .saveRideRequest(context);
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NearserDriversScreen(),
          ));
    }
  }

  retriveDriversInformation(List activeDriversList) async {
    bool iscontain = false;
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("drivers");
    print("number = ${activeDriversList.length}");
    print(activeDriversList);

    for (int i = 0; i < activeDriversList.length; i++) {
      for (int j = 0; j < dList.length; j++) {
        if (dList[j]["id"] == activeDriversList[i].driverID) {
          iscontain = true;
          notifyListeners();
        }
      }

      if (iscontain) {
      } else {
        await databaseReference
            .child(activeDriversList[i].driverID)
            .once()
            .then((data) {
          print(data.snapshot.value);
          dList.add(data.snapshot.value);
          print(dList);
          notifyListeners();
        });
      }
    }
  }

  double calculateTotalFearAmount() {
    if (directionDetail.distance_value != null &&
        directionDetail.duration_value != null) {
      // calculate amount per minites
      double fearAmountPerMinutes =
          (directionDetail.duration_value! / 60) * 0.1;

      // calculate amount per kilometers

      double fearAmontPerKilometrs =
          (directionDetail.distance_value! / 1000) * 0.1;

// total fear amount (dollar $$)
      double totlaFearAmount = fearAmontPerKilometrs + fearAmountPerMinutes;

      // transfer dollar to DZ
      double localFearAmount = totlaFearAmount * 22;
      ChangeNotifier();

      return double.parse(localFearAmount.toStringAsFixed(2));
    }
    return 0.0;
  }

  // save user  request ride to data base

  void saveRideRequest(BuildContext context) async {
    databaseReference =
        FirebaseDatabase.instance.ref().child("all ride requests").push();

    // get client information
    Client? client =
        Provider.of<AssistantsService>(context, listen: false).client;

    print(client!.name);
    print(client.email);

    // add the user original position to map
    Map originalUserPosition = {
      'latitude': currentPosition!.latitude,
      'longitude': currentPosition!.longitude
    };

// add the user destination position to map
    Map destinationPosition = {
      'latitude': direction.lat ?? 0,
      'longitude': direction.lng ?? 0
    };

    // add all information to a map to pass it on our real time database
    Map userRequestInformation = {
      'original': originalUserPosition,
      'destination': destinationPosition,
      'currentpositionName': humanReadableAdress,
      'destinationName': direction.name,
      'username': client.name,
      'email': client.email,
      'phone': client.phone,
      'time': DateTime.now().toString(),
      'driverID': 'waiting'
    };

    databaseReference!.set(userRequestInformation);
    notifyListeners();
  }

// get specific driver id that be chosen by user
  getspescificDriverID(int index) {
    specificDriverID = dList[index]["id"];
    notifyListeners();
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(specificDriverID.toString())
        .once()
        .then(
      (snap) {
        if (snap.snapshot.value != null) {
          String? driverToken =
              (snap.snapshot.value! as Map)["driversToken"];

             
          notifyListeners();
          sendNotification(driverToken);
        } else {
          showtoast("this user dosn't exist,try again please");
        }
      },
    );
    print(specificDriverID);
  }

  // send notification requst to the chosen driver

  sendNotification(var drviverToken) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(specificDriverID.toString())
        .child("newRideStatus")
        .set(databaseReference!.key.toString());

    try {
      print(databaseReference!.key.toString());
      String baseUrl = "https://fcm.googleapis.com/fcm/send";

      http.post(Uri.parse(baseUrl), 
       headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':'key=AAAAO-tNJI4:APA91bFYQyrsD6MLtCwK5Mzom1QyQ4X27RPeVVzTlVVL8ChJiUeXcMfuu1CiquZJD91UVfbbILG9N8Pxs0rEOSGHgIGVplwJ8d8GQJhCoIYEf4WVr4H9QlpdMsrUExQz7gyRbaSG4U09'
          },
      body:json.encode({
        "to":drviverToken,
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_Click",
          "id": "1",
          "status": "done",
          "rideRequestID": databaseReference!.key.toString()
        },
        "notification": {
          "body": "there is new request ride, Please check it",
          "title": "aymen uber clone"
        }}) 
      );
    } catch (error) {
      print(error);
    }
  }
}
