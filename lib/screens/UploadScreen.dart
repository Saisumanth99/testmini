import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miniproject/utils/CurvePainter.dart';
import 'package:miniproject/helpers/HIveOperations.dart';
import 'package:miniproject/helpers/tflite_helper.dart';

import '../helpers/app_helper.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PickedFile image;
  Map<String, double> results = Map<String, double>();
  bool resState = false;
  String message = '';
  bool isloading = false;
  bool isuploaded = false;
  bool isclassfied = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!TFLiteHelper.modelLoaded) {
      TFLiteHelper.loadModel().then((value) {
        setState(() {
          print("mode loaded");
          TFLiteHelper.modelLoaded = true;
        });
      });
    }
  }

  @override
  void dispose() {
    TFLiteHelper.disposeModel();
    AppHelper.log("dispose in uplaod ", "Clear resources.");
    super.dispose();
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Pick image from"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Row(
                        children: [
                          Icon(Icons.image),
                          Text("Gallery"),
                        ],
                      ),
                      onTap: () {
                        _openGallery(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          Text("Camera"),
                        ],
                      ),
                      onTap: () {
                        _openCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  _showSavedModel(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(title: Text("Successfully Saved."), actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ]);
        });
  }

  void _openGallery(BuildContext context) async {
    ImagePicker picker = ImagePicker();
    PickedFile picture = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      // maxHeight: 70,
      // maxWidth: 70
    );
    this.setState(() {
      if (picture != null) {
        image = picture;
        resState = false;
        isuploaded = true;
        isclassfied = false;
      } else {
        isuploaded = true;
      }
    });
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    ImagePicker picker = ImagePicker();
    var picture =
        await picker.getImage(source: ImageSource.camera, imageQuality: 20);
    this.setState(() {
      image = picture;
      if (image != null) {
        resState = false;
        isuploaded = true;
        isclassfied = false;
      }
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/homepage', (Route<dynamic> route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upload'),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/homepage', (Route<dynamic> route) => false);
            },
          ),
        ),
        body: CustomPaint(
          painter: CurvePainterTwo(),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Stack(
                  overflow: Overflow.visible,
                  children: [
                    Positioned(
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: image != null
                                  ? Image.file(
                                      File(image.path),
                                      width: 300,
                                      height: 300,
                                    )
                                  : Container(
                                      width: 300,
                                      height: 300,
                                      child: Center(
                                        child: Text(
                                          'choose an image to preview',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ))),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      left: 0,
                      bottom: -25,
                      child: MaterialButton(
                        height: 60,
                        color: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () async {
                          _showSelectionDialog(context);
                        },
                        shape: CircleBorder(),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      height: 80,
                      width: 300,
                      child: Center(
                          child: resState
                              ? Text(
                                  '${results.keys.toList()[0]} : ${results[results.keys.toList()[0]]}')
                              : Text(
                                  'No classification done yet',
                                  style: TextStyle(color: Colors.grey),
                                )),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RaisedButton(
                          disabledColor: Colors.blueGrey[300],
                          child: Text(
                            'Classify',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                          onPressed: isuploaded
                              ? () async {
                                  results =
                                      await TFLiteHelper.classifyImageFromFile(
                                          image);
                                  setState(() {
                                    resState = true;
                                    isclassfied = true;
                                  });
                                }
                              : null,
                        ),
                        RaisedButton(
                          disabledColor: Colors.blueGrey[300],
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                          onPressed: (isuploaded && isclassfied)
                              ? () async {
                                  setState(() {
                                    isloading = true;
                                  });
                                  isloading =
                                      await HiveOperations.saveDataToHIve(
                                          image, results);

                                  setState(() {
                                    if (isloading == true)
                                      message = 'Saved successfully';
                                    _showSavedModel(context);

                                    isloading = false;
                                    image = null;
                                    isuploaded = false;
                                    isclassfied = false;
                                    resState = false;
                                    results.clear();
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isloading)
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
