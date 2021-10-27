
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:screenshot/screenshot.dart';
import 'package:transport/helper/helper.dart';
import 'package:transport/helper/utils.dart';
import 'package:transport/models/user_model.dart';
import 'package:connectivity/connectivity.dart';

class HomeController extends GetxController {
  var file = null;
  ScrollController scrollController=ScrollController();
  DateTime dateTime=DateTime.now();
  ScreenshotController screenshotController = ScreenshotController();
  LocationData? locationData = null;
  User? user = null;
  String location = "Unnamed Road, Rajasthan 301704, India";
  late var _serviceEnabled;
  TextEditingController startCont = TextEditingController();
  TextEditingController endCont = TextEditingController();

  HomeController(id) {
initAll(id);

  }

  getHomeData(id) async {
    User _user;

    try {
      var response = await Dio().get(user_by_id_url + "?id=${id}");
      if (response.statusCode == 200) {
        var vehicle_num = response.data["vehicle_number"];
        var id = response.data["id"].toString();
        user = new User(id: id, vehicleNumber: vehicle_num);
        update();
      }
    } on DioError catch (e) {
      print("Himanshu"+e.type.toString());
      showNetworkDialog();

      print("Exception Dio"+e.toString());
      // TODO
    }
  }
updateTime(){
    dateTime=DateTime.now();
    update();
}
  insertReading(String value, String type) async {
    showLoadingIndicator("Please Wait");

    var res = await Dio().get(
        insert_reading + "?driver_id=${user!.id}&type=${type}&value=${value}");
    if (res.statusCode == 200) {
      Get.defaultDialog(
          title: "Success",
          titleStyle: TextStyle(color: Colors.green),
          middleText: "Data Added Successfully",
          textConfirm: "Ok",
          onConfirm: () {
            file = null;
            update();

            Get.back();
            Get.back();
          });
    } else {
      Get.defaultDialog(
          title: "Failed",
          titleStyle: TextStyle(color: Colors.red),
          middleText: "An Error Occured",
          textConfirm: "Ok",
          onConfirm: () {
            file = null;
            update();

            Get.back();
            Get.back();
          });
    }
  }

  pickImage() async {
    ImagePicker imagePicker = new ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    this.file = pickedFile!.path;
    print(file);
    scrollController.jumpTo(Get.height*0.4);

    update();
    showLoadingIndicator("Please Wait");
    updateLocation();
    final directory =await getApplicationDocumentsDirectory();//from path_provide package
    String fileName = DateTime.now().microsecondsSinceEpoch.toString()+".jpg";
    var path = '${directory.path}';

     screenshotController.captureAndSave(path,fileName: fileName ,delay: Duration(milliseconds: 1500),   ).then((value){
       print("On save"+value.toString());
       uploadData(value.toString(), user!.id, locationData!.latitude.toString(),
           locationData!.longitude.toString());
     });
    //
  }

  updateLocation() async {
    Location location = new Location();

    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      print("service denied");

      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    print("permission" + _permissionGranted.toString());
    if (_permissionGranted == PermissionStatus.denied) {
      print("permission denied");
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        print("permission denied");

        return;
      }
    }

    _locationData = await location.getLocation();
    location.changeNotificationOptions(
        title: "Transport App", description: "Loaction is being updated");
    location.enableBackgroundMode(enable: true);
    getLocation(_locationData.latitude, _locationData.longitude);

    location.onLocationChanged.listen((LocationData locationData) {
      updateUser(locationData.latitude.toString(),
          locationData.longitude.toString(), locationData.heading.toString());
      this.locationData = locationData;


      update();
    });
  }

  uploadData(String path, String id, String latitude, String longitude) async {
    print("upload Started");

    var filename = path.split('/').last;
    var url = upload_url;
    try {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(path, filename: filename),
        "id": id,
        "longitude": longitude,
        "latitude": latitude,
      });
      Response response = await Dio().post(url, data: formData);
      print("File upload response: $response");
      print(response.data);
      Navigator.of(Get.overlayContext!).pop();
      Get.defaultDialog(
          title: "Success",
          titleStyle: TextStyle(color: Colors.green),
          middleText: "Data Added Successfully",
          textConfirm: "Ok",
          onConfirm: () {
            file = null;
            update();

            Get.back();
            Get.back();
          });
    } catch (e) {
      print("Error Caught"+e.toString());
      Navigator.of(Get.overlayContext!).pop();
      Get.defaultDialog(
          title: "Failed",
          titleStyle: TextStyle(color: Colors.red),
          middleText: "An Error Occured",
          textConfirm: "Ok",
          onConfirm: () {
            file = null;
            update();

            Get.back();
            Get.back();
          });
      print("Exception Caught: $e");
    }
  }

  initFireBase() async {
    await Firebase.initializeApp();
  }

  updateUser(String lat, String lon, String head) {
    CollectionReference users = FirebaseFirestore.instance.collection('Driver');
    if(user!=null){
      users
          .doc(user!.vehicleNumber)
          .set({'latitude': lat, 'longitude': lon, 'heading': head})
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    }


  }

  void showLoadingIndicator(String text) {
    Get.defaultDialog(
        title: "Uploading",
        content: CircularProgressIndicator(),
        barrierDismissible: false);
  }

  getLocation(lat, lon) async {
    print("Geo Start");
    var res=await Dio().get(google_url(lat, lon, google_key));
    if(res.statusCode==200){
      // print("Location Res"+res.data.toString());
      try{
        var results=res.data["results"];
        location=results[0]["formatted_address"];
        print("Main Location"+location);
      }catch(e){
        print("Exception Caught"+e.toString());
      }

    }
    else{
      print("Server Error");
    }
    update();
  }
  initAll(id)async{
    initFireBase();
    getHomeData(id);
    updateLocation();
    try {
      final result = await InternetAddress.lookup('example.com');
      print("Result "+result.toString());
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');

      }
    } on SocketException catch (_) {
      print('not connected');
      // showNetworkDialog();
    }

  }

}
