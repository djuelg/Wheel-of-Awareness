import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter_background/flutter_background.dart';

import 'str.dart';

void main() {
  runApp(WheelOfAwareness());
}

class WheelOfAwareness extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String title = Str.title_custom;
    String description = Str.descr_custom;
    return MaterialApp(
      title: Str.app_title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: title, description: description, primarySwatch: Color(0xFF2C566E)),
    );
  }
}

class HomePage extends StatefulWidget {
  final Color primarySwatch;
  String title;
  String description;

  HomePage({Key key, this.title, this.description, this.primarySwatch}) : super(key: key);

  // This class is the configuration for the state. It holds the values
  // provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final _player = new AudioPlayer();
  var _customPracticeSleep = false;
  var _customPracticeDuration = 23; // TODO Load from settings and via BloC
  var _dialogCustomPracticeDuration = 23; // TODO Load from settings and via BloC
  @override
  void initState() {
    super.initState();
    _player.setAsset('assets/23min.mp3');
    buildBackgroundRunner();
    buildPlayerEventStreams();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text(Str.app_title, style: TextStyle(color: widget.primarySwatch, fontFamily: "Nexa")),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.access_time, color: widget.primarySwatch),
              onPressed: () async {
                _showCustomDurationDialog();
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.link, color: widget.primarySwatch),// If I really want the link button back, here it is
            //   onPressed: () async {
            //     const url = Str.website;
            //     if (await canLaunch(url)) await launch(url);
            //   },
            // )
          ],
        ),
        body: Column(children: [
          SizedBox(
            height: 20.0,
          ),
          _buildWheelAndSeekBar(),
          SizedBox(
            height: 20.0,
          ),
          _buildCurrentPractice(),
          _buildPlayButton(),
          _buildPracticeSwitch(),
        SizedBox(
          height: 10,
        ),
        ]));
  }

  Future<bool> buildBackgroundRunner() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Wheel of Awareness",
      notificationText: "The Wheel of Awareness practice is running in the background",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(name: 'icon_v3_notification', defType: 'mipmap'), // Default is ic_launcher from folder mipmap
    );
    bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
    return success;
  }

  void buildPlayerEventStreams() async {
    // Stream to run in background during practice
    _player.playerStateStream.listen((state) {
      if (state.playing && !FlutterBackground.isBackgroundExecutionEnabled) {
        FlutterBackground.enableBackgroundExecution();
      } else if (state.processingState == ProcessingState.completed && FlutterBackground.isBackgroundExecutionEnabled) {
        FlutterBackground.disableBackgroundExecution();
      }
    });

    // Stream to pause to increase silence
    _player.positionStream.listen((position) {
      const customDuration = Duration(minutes: 23, seconds: 9, milliseconds: 818);
      if (_player.duration != null && customDuration.compareTo(_player.duration) == 0 && _customPracticeDuration > 23) {
        if (position.inSeconds == 540 || position.inSeconds == 650 || position.inSeconds == 780) {
          // Positions in practice with silence
          _customPracticeSleep = true;
        } else if (_customPracticeSleep) {
          _customPracticeSleep = false;
          _player.pause();
          var additionalSilence = (((_customPracticeDuration - 23) * 60) / 3);
          continueAfterTimeout(additionalSilence.toInt());
        }
      }
    });
  }

  Timer continueAfterTimeout([int seconds]) => Timer(Duration(seconds: seconds), _player.play);

  _buildCircularSeekBar(double duration, double position) {
    return SleekCircularSlider(
        initialValue: position,
        max: duration,
        appearance: CircularSliderAppearance(
            size: 300,
            angleRange: 360,
            startAngle: 270,
            customWidths: CustomSliderWidths(progressBarWidth: 10, trackWidth: 3),
            customColors: CustomSliderColors(trackColor: widget.primarySwatch, progressBarColors: [Color(0xFF2C566E), Color(0xFFADD6F2)]),
            infoProperties: InfoProperties(mainLabelStyle: TextStyle(fontSize: 0))),
        onChangeEnd: (double newPosition) {
          _player.seek(Duration(seconds: newPosition.truncate()));
        });
  }

  _buildWheelAndSeekBar() {
    return Expanded(
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
                              return _buildCircularSeekBar(duration.inSeconds.truncateToDouble(), position.inSeconds.truncateToDouble());
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
      );
  }

  _buildCurrentPractice() {
    return Column(
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(color: widget.primarySwatch, fontSize: 20.0, fontFamily: "Nexa"),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: TextStyle(color: widget.primarySwatch, fontSize: 18.0, fontFamily: "NexaLight"),
          )
        ],
      );
  }

  _buildPlayButton() {
    return Container(
        width: 350.0,
        height: 100.0,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 82.0,
                height: 82.0,
                decoration: BoxDecoration(color: widget.primarySwatch, shape: BoxShape.circle),
                child: StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;
                    if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                      return Container(
                        margin: EdgeInsets.all(8.0),
                        width: 64.0,
                        height: 64.0,
                        child: CircularProgressIndicator(),
                      );
                    } else if (playing != true) {
                      return IconButton(
                        icon: Icon(Icons.play_arrow, size: 45.0, color: Colors.white),
                        onPressed: _player.play,
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon: Icon(Icons.pause, size: 45.0, color: Colors.white),
                        onPressed: _player.pause,
                      );
                    } else {
                      return IconButton(
                        icon: Icon(Icons.replay, size: 45.0, color: Colors.white),
                        onPressed: () => _player.seek(Duration.zero, index: _player.effectiveIndices.first),
                      );
                    }
                  },
                ),
              ),
            )
          ],
        ),
      );
  }

  _buildPracticeSwitch() {
    return Container(
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
                    borderRadius: BorderRadius.only(topRight: Radius.circular(30.0), bottomRight: Radius.circular(30.0))),
              ),
            ),
            Positioned(
              right: -25,
              child: Container(
                width: 45.0,
                height: 150.0,
                decoration: BoxDecoration(
                    color: widget.primarySwatch,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft: Radius.circular(30.0))),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    practice(Str.title_custom, Str.descr_custom, "assets/23min.mp3"),
                    practice(Str.title_30m, Str.descr_30m, "assets/30min.mp3"),
                    practice(Str.title_37m, Str.descr_37m, "assets/37min.mp3"),
                    practice(Str.title_20m, Str.descr_20m, "assets/20min.mp3"),
                    practice(Str.title_7m, Str.descr_7m, "assets/7min.mp3"),
                  ],
                ),
              ),
            )
          ],
        ),
      );
  }

  Future<void> _showCustomDurationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must NOT tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(Str.dialog_title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Str.dialog_descr),
                SpinBox(
                  min: 23,
                  value: _dialogCustomPracticeDuration.toDouble(),
                  acceleration: 0.001,
                  decoration: InputDecoration(labelText: 'Minutes'),
                  validator: (text) => text.isEmpty || int.parse(text) < 23 ? 'Invalid' : null,
                  onChanged: (duration) => updateCustomPracticeDuration(duration),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(Str.dialog_save),
              onPressed: () {
                Navigator.of(context).pop();
                _customPracticeDuration = _dialogCustomPracticeDuration;
              },
            ),
          ],
        );
      },
    );
  }

  Widget practice(String title, String description, String mp3) {
    return TextButton(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(color: widget.primarySwatch, fontSize: 18.0, fontFamily: (widget.title == title) ? "Nexa" : "NexaLight"),
      ),
      onPressed: () async {
        setState(() {
          widget.title = title;
          widget.description = description;
        });
        await _player.stop();
        _player.setAsset(mp3);
      },
    );
  }

  updateCustomPracticeDuration(double duration) {
    if (duration >= 23) {
      _dialogCustomPracticeDuration = duration.toInt();
    }
  }
}
