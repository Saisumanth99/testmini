import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miniproject/helpers/HIveOperations.dart';
import 'package:miniproject/helpers/tflite_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PickedFile image;
  // List<Map<dynamic, dynamic>> resultData = List<Map<dynamic, dynamic>>();
  List<Map<dynamic, dynamic>> resultData = List<Map<dynamic, dynamic>>();

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

  Future<void> _showDeleteDialog(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Do you want to remove permanently"),
            actions: [
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  HiveOperations.deleteResultFromHive(index);
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
              FlatButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      resultData = HiveOperations.getResultDataFromHive();
    });
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Cropify',
        //       style: GoogleFonts.pacifico(
        //           fontSize: 34, fontWeight: FontWeight.bold)),
        //   centerTitle: true,
        //   elevation: 0,
        //   actions: [
        //     Padding(
        //       padding: const EdgeInsets.only(right: 10),
        //       child: IconButton(
        //         icon: Icon(Icons.camera_rear),
        //         iconSize: 30,
        //         onPressed: () {
        //           Navigator.pushNamed(context, '/livepage');
        //         },
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.only(right: 10),
        //       child: IconButton(
        //         iconSize: 30,
        //         icon: Icon(Icons.camera_enhance),
        //         onPressed: () {
        //           Navigator.pushNamed(context, '/uploadpage');
        //         },
        //       ),
        //     )
        //   ],
        // ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                overflow: Overflow.visible,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 4,
                    width: MediaQuery.of(context).size.width,
                    decoration: new BoxDecoration(
                      color: Colors.blue,
                      borderRadius: new BorderRadius.vertical(
                          bottom: new Radius.circular(30)),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "PlantX",
                            style: GoogleFonts.cookie(
                                fontSize: 55,
                                letterSpacing: 3,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: -40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // InkWell(
                        //   enableFeedback: true,
                        //   onTap: () {
                        //     Navigator.pushNamed(context, '/livepage');
                        //   },
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         borderRadius: BorderRadius.circular(10)),
                        //     child: Card(
                        //       shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10)),
                        //       margin: EdgeInsets.all(5),
                        //       color: Colors.blue[400],
                        //       elevation: 10,
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: Column(
                        //           children: [
                        //             Icon(
                        //               Icons.center_focus_strong,
                        //               color: Colors.white,
                        //               size: 34,
                        //             ),
                        //             SizedBox(
                        //               height: 6,
                        //             ),
                        //             Text(
                        //               'Live Cam',
                        //               style: GoogleFonts.poppins(
                        //                   color: Colors.white, fontSize: 15),
                        //             )
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/uploadpage');
                          },
                          enableFeedback: true,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: EdgeInsets.all(5),
                              color: Colors.blue[400],
                              elevation: 10,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                    Text(
                                      'Classify',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 15),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
              ),
              if (resultData.length > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Center(
                      child: Text(
                    "Recent Activity",
                    style: TextStyle(color: Colors.grey),
                  )),
                ),
              resultData.length > 0
                  ? GridView.count(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      children: List.generate(resultData.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8, left: 8, right: 8),
                          child: InkWell(
                            onLongPress: () {
                              _showDeleteDialog(context, index);
                            },
                            onTap: () {
                              Navigator.of(context).pushNamed('/detailpage',
                                  arguments: {'data': resultData[index]});
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          HiveOperations.getImageFileFrombase64(
                                              resultData[index]['base64image']
                                                  .toString()),
                                          width: 300,
                                          height: 300,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text("${resultData[index]['label']}"),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              "No Classifications done yet!",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
