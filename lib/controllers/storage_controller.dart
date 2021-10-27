import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageController extends GetxController{
  var id="";

  var store=GetStorage();
  StorageController(){
   getData();
  }

getData()async{

  // store.write("id", "2");
  var us=await store.read("id");
  id=us;
  print("us========="+us);
  update();
}
putData(id){
    print(id);
    store.write("id", id);
}
}