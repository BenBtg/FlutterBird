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
  Color hitColor;
  double _uSize;
  double _lSize;

  bool _isFlapping = false;
  @override
  void initState() {
    super.initState();

    _mainAnim = AnimationController(
      vsync: this,
      lowerBound: -1.5,
      upperBound: 1.5,
      duration: Duration(seconds: 2),
    )
      ..addListener(() {
        hitTest();
        this.setState(() {});
      })
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          _lSize = 0.8 * _rnd.nextDouble();
          _uSize = max((1.0 - _lSize) - 0.3, 0.1);
          _mainAnim.reset();
          _mainAnim.forward();
        }
      });
    _mainAnim.forward();

    _birdAnim = AnimationController(
      vsync: this,
      lowerBound: -1.0,
      upperBound: 1.3,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          print("Drop completed" + _birdAnim.toStringDetails());
        }
      });
  }

  void hitTest() {
    double birdNorm =_birdAnim.value + 1.0;
    if (((_mainAnim.value > -0.2) && (_mainAnim.value < 0.2)) &&
        ((birdNorm * 0.5 < _uSize) || (((2.0 - birdNorm) * 0.5) < _lSize))) {
      hitColor = Colors.red;
    } else {
      hitColor = Colors.deepPurple;
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
            heightFactor: _uSize,
            widthFactor: 0.2,
            alignment: Alignment(0.0 - _mainAnim.value, -1.0),
            child: Container(
              decoration: BoxDecoration(
                  color: hitColor,
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      spreadRadius: 1,
                      offset: new Offset(2.5, 2.5),
                    )
                  ],
                  borderRadius: BorderRadius.circular(10.0)),
            )),
        FractionallySizedBox(
            heightFactor: _lSize,
            widthFactor: 0.2,
            alignment: Alignment(0.0 - _mainAnim.value, 1.0),
            child: Container(
              decoration: BoxDecoration(
                  color: hitColor,
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      spreadRadius: 1,
                      offset: new Offset(2.5, 2.5),
                    )
                  ],
                  borderRadius: BorderRadius.circular(10.0)),
            )),
        FractionallySizedBox(
          widthFactor: 0.2,
          heightFactor: 0.2,
          child: FlareActor("assets/FlutterBird.flr",
              fit: BoxFit.fitWidth, animation: "Flap", isPaused: !_isFlapping),
          alignment: Alignment(0.0, _birdAnim.value),
        ),
        Align(
          child: Text(
            "Score: ",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          alignment: Alignment(0.95, -0.95),
        ),
        GestureDetector(onTap: () {
          _isFlapping = true;
          double top = _birdAnim.value - 0.25;
          _birdAnim
              .animateTo(top, duration: Duration(milliseconds: 150))
              .whenComplete(() {
            _isFlapping = false;
            _birdAnim
                .animateWith(GravitySimulation(5, _birdAnim.value, 1.1, 1.0));
          });
        }),
      ]),
    );
  }
}
