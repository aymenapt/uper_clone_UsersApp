import 'package:fluttertoast/fluttertoast.dart';

import '../../app_manager/color_manager/color_manager.dart';



showtoast(var error){
Fluttertoast.showToast(
        msg: '$error',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 3,
        backgroundColor: maincolor,
        textColor: white,
        fontSize: 16.0,

    );
}