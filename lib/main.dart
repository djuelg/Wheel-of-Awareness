import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(WheelOfAwareness());
}

class WheelOfAwareness extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String title = "30 Minutes Practice";
    String description =
        "Including Awareness of awareness\nand kindness statements";
    return MaterialApp(
      title: 'Wheel of Awareness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(
          title: title,
          description: description,
          primarySwatch: Color(0xFF2C566E)),
    );
  }
}

class HomePage extends StatefulWidget {
  final Color primarySwatch;
  String title;
  String description;
  HomePage({Key key, this.title, this.description, this.primarySwatch})
      : super(key: key);

  // This class is the configuration for the state. It holds the values
  // provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final _player = new AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.setAsset('assets/30min.mp3');
  }

  _buildCircularSeekBar(double duration, double position) {
    return SleekCircularSlider(
        initialValue: position,
        max: duration,
        appearance: CircularSliderAppearance(
            size: 300,
            angleRange: 360,
            startAngle: 270,
            customWidths: CustomSliderWidths(progressBarWidth: 10, trackWidth: 3),
            customColors: CustomSliderColors(
                trackColor: widget.primarySwatch,
                progressBarColors: [Color(0xFF2C566E), Color(0xFFADD6F2)]),
            infoProperties:
                InfoProperties(mainLabelStyle: TextStyle(fontSize: 0))),
        onChangeEnd: (double newPosition) {
          _player.seek(Duration(seconds: newPosition.truncate()));
        });
  }

  _buildWheelAndSeekBar() {
    return <Widget>[
      SizedBox(
        height: 20.0,
      ),
      Expanded(
        child: Center(
          child: Container(
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        "assets/wheel_of_awareness.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: StreamBuilder<Duration>(
                        stream: _player.durationStream,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration(seconds: 360);
                          return StreamBuilder<Duration>(
                            stream: _player.positionStream,
                            builder: (context, snapshot) {
                              var position = snapshot.data ?? Duration.zero;
                              if (position > duration) {
                                position = duration;
                              }
                              return _buildCircularSeekBar(
                                  duration.inSeconds.truncateToDouble(),
                                  position.inSeconds.truncateToDouble());
                            },
                          );
                        },
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
      )
    ];
  }

  _buildCurrentPractice() {
    return <Widget>[
      Column(
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(
                color: widget.primarySwatch,
                fontSize: 20.0,
                fontFamily: "Nexa"),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            widget.description,
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
      )
    ];
  }

  _buildPlayButton() {
    return <Widget>[
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
                  stream: _player.playerStateStream,
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
                        icon: Icon(Icons.play_arrow,
                            size: 45.0, color: Colors.white),
                        onPressed: _player.play,
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon:
                            Icon(Icons.pause, size: 45.0, color: Colors.white),
                        onPressed: _player.pause,
                      );
                    } else {
                      return IconButton(
                        icon:
                            Icon(Icons.replay, size: 45.0, color: Colors.white),
                        onPressed: () => _player.seek(Duration.zero,
                            index: _player.effectiveIndices.first),
                      );
                    }
                  },
                ),
              ),
            )
          ],
        ),
      )
    ];
  }

  _buildPracticeSwitch() {
    return <Widget>[
      Container(
        height: 150.0,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: -25,
              child: Container(
                width: 45.0,
                height: 150.0,
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
                height: 150.0,
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
                  practice(
                      "30 Minutes Practice",
                      "Full wheel including Awareness of\n awareness and kindness statements",
                      "assets/30min.mp3"),
                  practice(
                      "20 Minutes Practice",
                      "Basic wheel without Awareness of\n awareness and kindness statements",
                      "assets/20min.mp3"),
                  practice(
                      "7 Minutes Practice",
                      "The breath becomes a pacer for\nthe movement of the spoke of attention",
                      "assets/7min.mp3"),
                ],
              ),
            )
          ],
        ),
      ),
      SizedBox(
        height: 10,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text("Wheel of Awareness",
              style:
                  TextStyle(color: widget.primarySwatch, fontFamily: "Nexa")),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.link, color: widget.primarySwatch),
              onPressed: () async {
                const url = "https://drdansiegel.com/wheel-of-awareness/";
                if (await canLaunch(url)) await launch(url);
              },
            )
          ],
        ),
        body: Column(
          children: _buildWheelAndSeekBar() +
              _buildCurrentPractice() +
              _buildPlayButton() +
              _buildPracticeSwitch(),
        ));
  }

  Widget practice(String title, String description, String mp3) {
    return Padding(
        padding: EdgeInsets.all(0.0),
        child: TextButton(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: widget.primarySwatch,
                fontSize: 18.0,
                fontFamily: (widget.title == title) ? "Nexa" : "NexaLight"),
          ),
          onPressed: () async {
            setState(() {
              widget.title = title;
              widget.description = description;
            });
            await _player.stop();
            _player.setAsset(mp3);
          },
        ));
  }
}
