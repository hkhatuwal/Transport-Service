import 'package:flutter/services.dart';
import 'package:get/get.dart';

showNetworkDialog(){
  Get.defaultDialog(title: "Error",middleText: "No internet Connection",barrierDismissible: false,textConfirm: "Ok",onConfirm: (){
    SystemNavigator.pop(animated: true);
  });
}