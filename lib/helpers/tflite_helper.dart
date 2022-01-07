import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../models/result.dart';
import 'package:tflite/tflite.dart';

import 'app_helper.dart';

class TFLiteHelper {
  static StreamController<List<Result>> tfLiteResultsController =
      new StreamController.broadcast();
  static List<Result> _outputs = List();
  static var modelLoaded = false;

  static Future<String> loadModel() async {
    // AppHelper.log("loadModel", "Loading model..");

    return Tflite.loadModel(
        // model: "assets/model_unquant.tflite", labels: "assets/labels.txt"

        // model: "assets/mobilenet_v1_1.0_224.tflite",
        // labels: "assets/labels1.txt",

        // model: "assets/converted_model.tflite",
        // labels: "assets/labels4.txt");

        // model: "assets/sum.tflite",
        // labels: "assets/labels1.txt");

        model: "assets/umodel.tflite",
        labels: "assets/labels2.txt",
        numThreads: 1);
  }

  static classifyImage({CameraImage image}) async {
    print("in classify image frame");
    await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) {
        print("in plane bytes");
        return plane.bytes;
      }).toList(),
      imageWidth: image.width,
      imageHeight: image.height,
      imageMean: 0,
      imageStd: 255,
      numResults: 5,
      threshold: 0.4,
      // rotation: 0,
    ).then((value) {
      if (value.isNotEmpty) {
        AppHelper.log("classifyImage", "Results loaded. ${value.length}");

        //Clear previous results
        _outputs.clear();

        value.forEach((element) {
          _outputs.add(Result(
              element['confidence'], element['index'], element['label']));

          AppHelper.log("classifyImage",
              "${element['confidence']} , ${element['index']}, ${element['label']}");
        });
      }

      //Sort results according to most confidence
      _outputs.sort((a, b) => b.confidence.compareTo(a.confidence));

      //Send results
      tfLiteResultsController.add(_outputs);
    }).catchError((Object e) {
      print("some error");
    });
  }

  static void disposeModel({bool closeController: false}) {
   if(TFLiteHelper.modelLoaded == true) Tflite.close();

    TFLiteHelper.modelLoaded = false;
    if (closeController) tfLiteResultsController.close();
  }

  static Future<Map<String, double>> classifyImageFromFile(
      PickedFile image) async {
    Map<String, double> res = Map<String, double>();

    // File img = preprocessImage(image.path);

    await Tflite.runModelOnImage(
      path: image.path,
      asynch: true,
      numResults: 5,
      imageStd: 255,
      imageMean: 0,
    ).then((value) {
      if (value.isNotEmpty) {
        // AppHelper.log("classifyImage", "Results loaded. ${value.length}");

        //Clear previous results

        String label;
        double confidence = 0;
        value.forEach((element) {
          if (element['confidence'] >= confidence) {
            label = element['label'];
            confidence = element['confidence'];
          }

          // AppHelper.log("classifyImage",
          //     "${element['confidence']} , ${element['index']}, ${element['label']}");
        });
        res[label] = confidence;
      }
    });

    return res;
  }
}
