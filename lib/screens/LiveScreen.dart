import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:tflite/tflite.dart';
import '../helpers/app_helper.dart';
import '../helpers/camera_helper.dart';
import '../helpers/tflite_helper.dart';
import '../models/result.dart';

class LiveScreen extends StatefulWidget {
  LiveScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LiveScreenPageState createState() => _LiveScreenPageState();
}

class _LiveScreenPageState extends State<LiveScreen>
    with TickerProviderStateMixin {
  AnimationController _colorAnimController;
  Animation _colorTween;

  List<Result> outputs;

  void initState() {
    super.initState();

    //Load TFLite Model
    if (!TFLiteHelper.modelLoaded) {
      TFLiteHelper.loadModel().then((value) {
        setState(() {
          print("mode loaded");
          TFLiteHelper.modelLoaded = true;
        });
      });
    }

    //Initialize Camera
    CameraHelper.initializeCamera();

    //Setup Animation
    _setupAnimation();

    //Subscribe to TFLite's Classify events
    TFLiteHelper.tfLiteResultsController.stream.listen(
        (value) {
          value.forEach((element) {
            _colorAnimController.animateTo(element.confidence,
                curve: Curves.bounceIn, duration: Duration(milliseconds: 500));
          });

          //Set Results
          outputs = value;

          //Update results on screen
          setState(() {
            //Set bit to false to allow detection again
            CameraHelper.isDetecting = false;
          });
        },
        onDone: () {},
        onError: (error) {
          AppHelper.log("listen", error);
        });
  }

  @override
  void dispose() {
    CameraHelper.camera.dispose();
    _colorAnimController.dispose();
    TFLiteHelper.disposeModel(closeController: true);
    AppHelper.log("dispose", "Clear resources.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<void>(
        future: CameraHelper.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: <Widget>[
                CameraPreview(CameraHelper.camera),
                // _buildResultsWidget(width, outputs)
                DraggableScrollableSheet(
                  initialChildSize: 0.30,
                  minChildSize: 0.15,
                  maxChildSize: 0.8,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20))),
                      width: width,
                      child: outputs != null && outputs.isNotEmpty
                          ? ListView.builder(
                              itemCount: outputs.length,
                              // shrinkWrap: true,
                              padding: const EdgeInsets.all(20.0),
                              controller: scrollController,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        outputs[index].label,
                                        style: TextStyle(
                                          color: _colorTween.value,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          AnimatedBuilder(
                                              animation: _colorAnimController,
                                              builder: (context, child) =>
                                                  LinearPercentIndicator(
                                                    width: width * 0.73,
                                                    lineHeight: 14.0,
                                                    percent: outputs[index]
                                                        .confidence,
                                                    progressColor:
                                                        _colorTween.value,
                                                  )),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "${(outputs[index].confidence * 100.0).toStringAsFixed(2)} %",
                                            style: TextStyle(
                                              color: _colorTween.value,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              })
                          : Center(
                              child: Text("Wating for model to detect..",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                  ))),
                    );
                  },
                )
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _buildResultsWidgetNew(width, outputs);
      //   },
      // ),
    );
  }

  Widget _buildResultsWidget(double width, List<Result> outputs) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200.0,
          width: width,
          color: Colors.white,
          child: outputs != null && outputs.isNotEmpty
              ? ListView.builder(
                  itemCount: outputs.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        Text(
                          outputs[index].label,
                          style: TextStyle(
                            color: _colorTween.value,
                            fontSize: 20.0,
                          ),
                        ),
                        AnimatedBuilder(
                            animation: _colorAnimController,
                            builder: (context, child) => LinearPercentIndicator(
                                  width: width * 0.83,
                                  lineHeight: 14.0,
                                  percent: outputs[index].confidence,
                                  progressColor: _colorTween.value,
                                )),
                        Text(
                          "${(outputs[index].confidence * 100.0).toStringAsFixed(2)} %",
                          style: TextStyle(
                            color: _colorTween.value,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    );
                  })
              : Center(
                  child: Text("Wating for model to detect..",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ))),
        ),
      ),
    );
  }

  void _buildResultsWidgetNew(double width, List<Result> outputs) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (builder) {
          return Container(
            height: 400.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            width: width,
            child: outputs != null && outputs.isNotEmpty
                ? ListView.builder(
                    itemCount: outputs.length,
                    // shrinkWrap: true,
                    padding: const EdgeInsets.all(20.0),
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: <Widget>[
                          Text(
                            outputs[index].label,
                            style: TextStyle(
                              color: _colorTween.value,
                              fontSize: 20.0,
                            ),
                          ),
                          AnimatedBuilder(
                              animation: _colorAnimController,
                              builder: (context, child) =>
                                  LinearPercentIndicator(
                                    width: width * 0.88,
                                    lineHeight: 14.0,
                                    percent: outputs[index].confidence,
                                    progressColor: _colorTween.value,
                                  )),
                          Text(
                            "${(outputs[index].confidence * 100.0).toStringAsFixed(2)} %",
                            style: TextStyle(
                              color: _colorTween.value,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      );
                    })
                : Center(
                    child: Text("Wating for model to detect..",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        ))),
          );
        });
  }

  void _setupAnimation() {
    _colorAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _colorTween = ColorTween(begin: Colors.green, end: Colors.red)
        .animate(_colorAnimController);
  }
}
