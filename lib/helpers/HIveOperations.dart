import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miniproject/helpers/HIveBoxDetails.dart';

class HiveOperations {
  static Future<bool> saveDataToHIve(
      PickedFile image, Map<String, double> results) async {
    File imageFile = File(image.path);
    String base64image = await imageTobase64(imageFile);

    String id =
        HiveBoxDetails.prefbox.get("nextID", defaultValue: '0').toString();

    print("id is $id");
    Map<dynamic, dynamic> res = Map<dynamic, dynamic>();

    res['id'] = id;
    res['base64image'] = base64image;
    res['label'] = results.keys.toList()[0];
    res['confidence'] = results[results.keys.toList()[0]].toString();

    HiveBoxDetails.box.put(id, res);
    HiveBoxDetails.prefbox.put('nextID', (int.parse(id) + 1).toString());
    return true;
  }

  static List<Map<dynamic, dynamic>> getResultDataFromHive() {
    List<Map<dynamic, dynamic>> temp = List<Map<dynamic, dynamic>>();

    int len = HiveBoxDetails.box.length;

    for (int i = len - 1; i >= 0; i--) {
      print("index is ${i}");
      temp.add(HiveBoxDetails.box.getAt(i));
      print("in box ${HiveBoxDetails.box.getAt(i)}");
    }

    return temp;
  }

  //DELETE OPERATIONS ---------------------------------------------
  //---------------------------------------------------------------

  static deleteResultFromHive(int index) {
    int pos = HiveBoxDetails.box.length - index - 1;
    String key = HiveBoxDetails.box.keyAt(pos);
    HiveBoxDetails.box.delete(key);
  }

  //HELPER OPERATIONS ---------------------------------------------
  //---------------------------------------------------------------
  static Future<String> imageTobase64(File image) async {
    List<int> imageBytes = await image.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  static Uint8List getImageFileFrombase64(String base64img) {
    // print("base64img value is ${base64img}");
    Uint8List bytes = base64Decode(base64img);
    // File imgFile = File.fromRawPath(bytes);

    return bytes;
  }
}
