import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:transport/controllers/storage_controller.dart';
import 'package:transport/pages/home_page.dart';
import 'package:transport/pages/login_page.dart';
void main() async{
  await GetStorage.init();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
   MyApp({Key? key}) : super(key: key);
   StorageController controller=Get.put(StorageController());





  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      getPages: [
        GetPage(name: "/home", page:()=> HomePage())
      ],
      home: GetBuilder<StorageController>(

        builder: (context) {
          return controller.id==""||controller.id==null?LoginPage():HomePage(id:controller.id);
        }
      ),
    );

  }
}
