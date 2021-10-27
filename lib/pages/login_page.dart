

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transport/controllers/storage_controller.dart';
import 'package:transport/helper/helper.dart';
import 'package:transport/pages/home_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var controller=TextEditingController();
  StorageController storageController=Get.find<StorageController>();

  validate() async{
    if(controller.value.text!=null && controller.value.text!="" && controller.value.text.length>=9){
      var response=await Dio().get(login_url+"?id=${controller.text}");
      // print(response);
      if(response.statusCode==200){
        if(response.data['record_found']==true){
          Get.snackbar("Logged In","Already a User",snackPosition: SnackPosition.BOTTOM);

        }
        else{
          Get.snackbar("Logged In","New User",snackPosition: SnackPosition.BOTTOM);

        }
        print("Id from login page"+response.data["id"].toString());
        storageController.putData(response.data["id"].toString());
        Get.offAll(HomePage(id: response.data["id"]));

      }
      else{
        Get.snackbar("Error","Error Occured",snackPosition: SnackPosition.BOTTOM);

      }

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller:controller ,
                decoration: InputDecoration(
                  hintText: "Enter Vehicle Number",
                  border:OutlineInputBorder(),
                ),
              ),

              Container(
                width: double.infinity,

                child: ElevatedButton(child:Text("Submit"),onPressed: (){
                  validate();

                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
