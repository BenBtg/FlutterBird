import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/physics.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: App(),
    );
  }
}

class Box extends StatelessWidget {
  final double height;
  final double y;
  final double x;

  Box({Key key, this.height, this.x, this.y}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        heightFactor: height,
        widthFactor: 0.2,
        alignment: Alignment(x, y),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.purple,
              boxShadow: [
                new BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: new Offset(2.5, 2.5),
                )
              ],
              borderRadius: BorderRadius.circular(10.0)),
        ));
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  AnimationController _birdAnim;
  AnimationController _mainAnim;
  Random _rnd = new Random(42);
  bool _hit = true;
  double _uSize;
  double _lSize;
  int _score = 0;
  int _highScore = 0;

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
          move();
          _score += 1;
        }
      });
    _mainAnim.forward();

    _birdAnim = AnimationController(
      vsync: this,
      lowerBound: -1.0,
      upperBound: 1.3,
    );
  }

  void move() {
    _lSize = 0.8 * _rnd.nextDouble();
    _uSize = max((1.0 - _lSize) - 0.3, 0.1);
    _mainAnim.reset();
    _mainAnim.forward();
  }

  void hitTest() {
    double birdNorm = _birdAnim.value + 1.0;
    if (((_mainAnim.value > 0.1) && (_mainAnim.value < 0.5)) &&
        ((birdNorm * 0.5 < _uSize) || (((2.0 - birdNorm) * 0.5) < _lSize))) {
      _hit = true;
      _highScore = max(_highScore, _score);
      _mainAnim.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Bird"),
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
        Box(height: _uSize, x: 0.0 - _mainAnim.value, y: -1.0),
        Box(height: _lSize, x: 0.0 - _mainAnim.value, y: 1.0),
        FractionallySizedBox(
          widthFactor: 0.2,
          heightFactor: 0.2,
          child: FlareActor("assets/FlutterBird.flr",
              fit: BoxFit.fitWidth, animation: "Flap", isPaused: !_isFlapping),
          alignment: Alignment(-0.5, _birdAnim.value),
        ),
        Align(
          child: Text(
            "High Score: $_highScore \n Score: $_score", textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white, fontSize: 20, shadows: [Shadow(blurRadius: 1.0, offset: Offset(1.5, 1.5))]  ),
          ),
          alignment: Alignment(0.95, -0.95),
        ),
        GestureDetector(onTap: () {
          _isFlapping = true;
          double top = _birdAnim.value - 0.3;
          _birdAnim
              .animateTo(top, duration: Duration(milliseconds: 150))
              .whenComplete(() {
            _isFlapping = false;
            drop();
          });
        }),
        Visibility(
          child: new FlatButton(
            child: Text(
              'Start Game',
              style: TextStyle(color: Colors.white, fontSize: 50, shadows: [Shadow(blurRadius: 1.0, offset: Offset(2, 2))] ),
            ),
            color: Theme.of(context).accentColor,
            splashColor: Colors.blueGrey,
            onPressed: () {
              // Perform some action
              //_hit = false;
              this.setState(() {
                _hit = false;
                _score = 0;
              });
              move();
              _birdAnim.reset();
              drop();
            },
          ),
          visible: _hit,
        ),
      ]),
    );
  }

  void drop() {
    _birdAnim.animateWith(GravitySimulation(4, _birdAnim.value, 1.1, 1.0));
  }
}
