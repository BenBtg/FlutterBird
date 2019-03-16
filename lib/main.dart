import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/physics.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: App(title: 'Flappy Flutter'),
    );
  }
}

class App extends StatefulWidget {
  App({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  AnimationController _birdAnim;
  AnimationController _mainAnim;
  Random _rnd = new Random(42);
  Color hitColor = Colors.green;
  double _blockHeight = 1.0;
  bool _isFlapping = false;
  @override
  void initState() {
    super.initState();

    _mainAnim = AnimationController(
      vsync: this,
      lowerBound: -1.5,
      upperBound: 1.5,
      debugLabel: "Main",
      duration: Duration(seconds: 2),
    )
      ..addListener(() {
        // print("Mainframe "+ _mainAnim.toStringDetails());
        // Hit testing
        hitTest();
        this.setState(() {});
      })
      ..addStatusListener((status) async {
        if (_birdAnim != null) {
          print("Frame " + _birdAnim.toStringDetails());
        }
        if (status == AnimationStatus.completed) {
          //await new Future.delayed(const Duration(seconds : 2));
          debugPrint("New block");
          _blockHeight = _rnd.nextDouble();
          _mainAnim.reset();
          _mainAnim.forward();
        }
      });
    _mainAnim.forward();

    _birdAnim = AnimationController(
      vsync: this,
      lowerBound: -1.0,
      upperBound: 1.3,
      debugLabel: "Drop",
      duration: Duration(seconds: 5),
    )
      ..addListener(() {
        hitTest();
        this.setState(() {});
      })
      ..addStatusListener((status) {
        // print("Status changed " + status.toString() + _birdAnim.toStringDetails());
        if (status == AnimationStatus.completed) {
          print("Drop completed" + _birdAnim.toStringDetails());
        }
      });
  }

  void hitTest() {
    if ((((2.0 - (_birdAnim.value + 1.0)) * 0.5) < _blockHeight) &&
        (_mainAnim.value > -0.2) &&
        (_mainAnim.value < 0.2)) {
      debugPrint("Hit!");
      hitColor = Colors.red;
    } else {
      hitColor = Colors.green;
    }
  }

  @override
  void dispose() {
    _birdAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(fit: StackFit.expand, children: <Widget>[
        Container(
          decoration: BoxDecoration(
            // Box decoration takes a gradient
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
              stops: [0.1, 1.0],
              colors: [
                Color.fromRGBO(131, 232, 255, 1.0),
                Color.fromRGBO(110, 90, 210, 1.0),
              ],
            ),
          ),
        ),
        FractionallySizedBox(
            heightFactor: 0.8 * _blockHeight,
            widthFactor: 0.2,
            alignment: Alignment(0.0 - _mainAnim.value, 1.0),
            child: Container(color: hitColor)),
        FractionallySizedBox(
          widthFactor: 0.2,
          heightFactor: 0.2,
          child: FlareActor("assets/FlutterBird.flr",
              fit: BoxFit.fitWidth, animation: "Flap", isPaused: !_isFlapping),
          alignment: Alignment(0.0, _birdAnim.value),
        ),
        Align(
          child: Text(
            "Score: " + _birdAnim.value.toString(),
            style: TextStyle(color: Colors.white),
          ),
          alignment: Alignment(0.95, -0.95),
        ),
        GestureDetector(onTap: () {
          _isFlapping = true;
          double top = _birdAnim.value - 0.25;
          print("Flying" + _birdAnim.toStringDetails());
          _birdAnim
              .animateTo(top, duration: Duration(milliseconds: 200))
              .whenComplete(() {
            _isFlapping = false;
            print("Flap completed" + _birdAnim.toStringDetails());
            _birdAnim
                .animateWith(GravitySimulation(9.8, _birdAnim.value, 1.1, 1.0));
          });
        }),
      ]),
    );
  }
}
