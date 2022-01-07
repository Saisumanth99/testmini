import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import '../utils/CurvePainter.dart';
import '../helpers/HIveOperations.dart';

class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<dynamic, dynamic> resultData = Map<dynamic, dynamic>();
  String mailText = '';

 

  Future<void> _showShareOptions() async {
    String label = resultData['label'];
    String confidence =
        (double.parse(resultData['confidence']) * 100.0).toStringAsFixed(2);

    Uint8List bytes = base64Decode(resultData['base64image']);
    String dir = (await getExternalStorageDirectory()).path;
    File imgFile = new File('$dir/temp.jpg');
    imgFile.writeAsBytesSync(bytes);
    final RenderBox box = context.findRenderObject();

    Share.shareFiles(['$dir/temp.jpg'],
        text: "Label : $label \n confidence : $confidence% \n",
        subject: "Results after Plant Classification",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size 
        );

  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      Map<dynamic, dynamic> data =
          ModalRoute.of(context).settings.arguments as Map<dynamic, dynamic>;
      resultData = data['data'];
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        elevation: 0,
      ),
      body: CustomPaint(
        painter: CurvePainter(),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                ),
                Container(
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          HiveOperations.getImageFileFrombase64(
                              resultData['base64image'].toString()),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 300,
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Label : ",
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  '${resultData['label']}',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Confidence : ",
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  '${(double.parse(resultData['confidence']) * 100.0).toStringAsFixed(2)}%',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                ),
                Center(
                  child: Container(
                    width: 100,
                    child: MaterialButton(
                      color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Mail', style: TextStyle(color: Colors.white))
                        ],
                      ),
                      onPressed: () {
                        // _showModalBottomSheet();
                        _showShareOptions();
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
