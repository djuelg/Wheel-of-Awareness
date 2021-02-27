import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

void main() {
  runApp(WheelOfAwareness());
}

class WheelOfAwareness extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wheel of Awareness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Wheel of Awareness', primarySwatch: Color(0xFF2C566E)),
    );
  }
}

class HomePage extends StatefulWidget {

  final String title;
  final Color primarySwatch;

  HomePage({Key key, this.title, this.primarySwatch}) : super(key: key);

  // This class is the configuration for the state. It holds the values
  // provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  double _thumbPercent = 0.4;

  // https://pub.dev/packages/just_audio/example
  final player = new AudioPlayer();

  @override
  void initState() {
    super.initState();
    player.setAsset('assets/20min.mp3');
  }

  // TODO: Define Radial SeekBar like here
  // TODO: via https://pub.dev/packages/sleek_circular_slider

  // Widget _buildRadialSeekBar() {
  //   return RadialSeekBar(
  //     trackColor: Colors.red.withOpacity(.5),
  //     trackWidth: 2.0,
  //     progressColor: widget.primarySwatch,
  //     progressWidth: 5.0,
  //     thumbPercent: _thumbPercent,
  //     thumb: CircleThumb(
  //       color: widget.primarySwatch,
  //       diameter: 20.0,
  //     ),
  //     progress: _thumbPercent,
  //     onDragUpdate: (double percent) {
  //       setState(() {
  //         _thumbPercent = percent;
  //       });
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: widget.primarySwatch),
            onPressed: () {},
          ),
          title: Text(widget.title,
              style: TextStyle(color: widget.primarySwatch, fontFamily: "Nexa")),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.menu, color: widget.primarySwatch),
              onPressed: () {},
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),

            Expanded(child: Center(
              child: Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      // decoration: BoxDecoration(
                      //     color: widget.primarySwatch.withOpacity(.5),
                      //     shape: BoxShape.circle),
                      // child: Padding(
                      //   padding: const EdgeInsets.all(12.0)
                      //   //child: Null, //_buildRadialSeekBar(), // TODO Insert seekbar here
                      // ),
                    ),
                    Center(
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.asset(
                            "assets/woa.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            ),

            SizedBox(
              height: 20.0,
            ),
            Column(
              children: <Widget>[
                Text(
                  "30 Minutes Excercise",
                  style: TextStyle(
                      color: widget.primarySwatch,
                      fontSize: 20.0,
                      fontFamily: "Nexa"),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  "Including Awareness of awareness\nand kindness statements",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: widget.primarySwatch,
                      fontSize: 18.0,
                      fontFamily: "NexaLight"),
                )
              ],
            ),
            SizedBox(
              height: 0,
            ),
            Container(
              width: 350.0,
              height: 100.0,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 82.0,
                      height: 82.0,
                      decoration: BoxDecoration(
                          color: widget.primarySwatch, shape: BoxShape.circle),
                      child: StreamBuilder<PlayerState>(
                        stream: player.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return Container(
                              margin: EdgeInsets.all(8.0),
                              width: 64.0,
                              height: 64.0,
                              child: CircularProgressIndicator(),
                            );
                          } else if (playing != true) {
                            return IconButton(
                              icon: Icon(Icons.play_arrow, size: 45.0, color: Colors.white),
                              onPressed: player.play,
                            );
                          } else if (processingState != ProcessingState.completed) {
                            return IconButton(
                              icon: Icon(Icons.pause, size: 45.0, color: Colors.white),
                              onPressed: player.pause,
                            );
                          } else {
                            return IconButton(
                              icon: Icon(Icons.replay, size: 45.0, color: Colors.white),
                              onPressed: () => player.seek(Duration.zero,
                                  index: player.effectiveIndices.first),
                            );
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 130.0,
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: -25,
                    child: Container(
                      width: 45.0,
                      height: 130.0,
                      decoration: BoxDecoration(
                          color: widget.primarySwatch,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0))),
                    ),
                  ),
                  Positioned(
                    right: -25,
                    child: Container(
                      width: 45.0,
                      height: 130.0,
                      decoration: BoxDecoration(
                          color: widget.primarySwatch,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              bottomLeft: Radius.circular(30.0))),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        exercise("30 Minutes Exercise", "Nexa"),
                        exercise("20 Minutes Exercise"),
                        exercise("7 Minutes Exercise"),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        )
    );
  }

  Widget exercise(String title, [String fontFamily = "NexaLight"]) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: widget.primarySwatch,
              fontSize: 18.0,
              fontFamily: fontFamily),
        )
    );
  }

}


