import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:transport/controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  final id;

  const HomePage({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.put(HomeController(id));
    print(controller.file);
    TextEditingController startCont = TextEditingController();
    TextEditingController endCont = TextEditingController();
    controller.updateLocation();
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: Icon(CupertinoIcons.car_detailed),
        title: GetBuilder<HomeController>(builder: (_) {
          return controller.user == null
              ? Text("Loading...")
              : Text(" ${controller.user!.vehicleNumber}");
        }),
      ),
      body: GetBuilder<HomeController>(builder: (context) {
        return Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: Container(
                width:Get.width,
                height: Get.height,
                child:Image.asset("assets/bg.jpg",fit: BoxFit.cover,)
              ),
            ),
            SingleChildScrollView(
              controller: controller.scrollController,
              child: controller.user == null
                  ? Container(
                      height: Get.height,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                          semanticsLabel: "Please Wait..",
                        ),
                      ))
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            width: Get.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: Get.width * 0.6,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      controller: startCont,

                                      decoration: InputDecoration(
                                          labelText: "Start meter",
                                          prefixIcon: Icon(Icons.watch_later,color: Colors.deepPurple,),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blueAccent,width: 10))),
                                    ),
                                  ),
                                  Container(
                                    width: Get.width * 0.3,
                                    height: 57,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: Color(0xff172774)),
                                      onPressed: () {
                                        controller.insertReading(
                                            startCont.text, "Start");
                                      },
                                      child: Text("Submit",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 22)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: Get.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: Get.width * 0.6,

                                    child: TextField(
                                      controller: endCont,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          labelText: "End meter",
                                          prefixIcon: Icon(Icons.watch_later,color: Colors.deepPurple,),
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blueAccent))),
                                    ),
                                  ),
                                  Container(
                                    width: Get.width * 0.3,
                                    height: 55,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),

                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary:Color(0xff172774)),

                                      onPressed: () {
                                        controller.insertReading(
                                            endCont.text, "End");
                                      },
                                      child: Text("Submit",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 22)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: width,
                              height: 50,
                              child: ElevatedButton(

                                style: ElevatedButton.styleFrom(primary: Colors.indigo),
                                  onPressed: (() => {controller.pickImage()}),
                                  child: Text("Pick Image",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),)),
                            ),
                          ),
                          GetBuilder<HomeController>(
                              builder: (_) => Screenshot(
                                controller: controller.screenshotController,
                                child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              width: double.infinity,
                                              height: controller.file != null?Get.height*0.85:Get.height*0.50,
                                              child: controller.file != null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                      child: Image.file(
                                                        File(controller.file
                                                            .toString()),
                                                        fit: BoxFit.fill,
                                                      ))
                                                  : Center(
                                                      child: Text(""),
                                                    )),
                                        ),
                                        getLocationCard(controller)
                                      ],
                                    ),
                              )),

                          // GetBuilder<HomeController>(builder: (context) {
                          //   return controller.locationData == null
                          //       ? Text("Loading Location")
                          //       :Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: Column(
                          //     children: [
                          //         Row(
                          //           children: [
                          //             Icon(CupertinoIcons.location_circle_fill),
                          //             Text("Latitude ${controller.locationData!.latitude.toString()}")
                          //           ],
                          //         ),
                          //   SizedBox(height: 10,),
                          //       Row(
                          //           children: [
                          //             Icon(CupertinoIcons.location_circle_fill),
                          //             Text("Longitude ${controller.locationData!.longitude.toString()}")
                          //           ],
                          //         )
                          //     ],
                          //   ),
                          //       );
                          // })
                        ],
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget getLocationCard(HomeController controller) {
    return GetBuilder<HomeController>(builder: (_) {
      return Positioned(
        width: Get.width,
        bottom: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                  color: Color(0xff261C2C),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Card(
                            child: Container(
                              width: 100,
                                height: 100,


                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    "https://www.incimages.com/uploaded_files/image/1920x1080/getty_578108630_366457.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                ))),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: Get.width-140,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${controller.location}",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: controller.locationData == null
                                      ? Text(
                                          "Loading",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : Text(
                                          "${controller.locationData!.latitude} , ${controller.locationData!.longitude}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("${controller.dateTime.toString().split(".").first}",
                                      style: TextStyle(color: Colors.white)),
                                ),

                              ]),
                        )
                      ])),
            ],
          ),
        ),
      );
    });
  }

}
