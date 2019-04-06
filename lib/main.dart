import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/physics.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: new Offset(2, 2),
                )
              ],
              borderRadius: BorderRadius.circular(10)),
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
  SharedPreferences _prefs;
  Random _rnd = new Random(42);
  bool _hit = true;
  double _uSize = 0;
  double _lSize = 0;
  int _score = 0;
  int _highScore = 0;

  bool _isFlapping = false;
  @override
  initState() {
    super.initState();
    getHighScore();

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
          _highScore = max(_highScore, _score);
          await _prefs.setInt('highScore', _highScore);
        }
      });
    _mainAnim.forward();

    _birdAnim = AnimationController(
      vsync: this,
      lowerBound: -1.0,
      upperBound: 1.3,
    );
  }

  void getHighScore() async {
    _prefs = await SharedPreferences.getInstance();
    _highScore = _prefs.getInt('_highScore') ?? 0;
  }

  void move() {
    _lSize = _rnd.nextDouble() * 0.6 + 0.01;
    _uSize = (1.0 - _lSize) - 0.4 + (_score * 0.001);
    _mainAnim.reset();
    _mainAnim.forward();
  }

  void hitTest() {
    double birdNorm = _birdAnim.value + 1.1;
    if (((_mainAnim.value > 0.1) && (_mainAnim.value < 0.5)) &&
        ((birdNorm * 0.5 < _uSize) || (((2.0 - birdNorm) * 0.5) < _lSize))) {
      _hit = true;
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
          heightFactor: 0.3,
          child: Container(color: Colors.black26),
          alignment: Alignment(0, -1.0 + (_uSize * 2.2)),
        ),
        FractionallySizedBox(
            heightFactor: 0.12,
            child: FlareActor("assets/FlutterBird.flr",
                animation: "Flap",
                fit: BoxFit.fitHeight,
                isPaused: !_isFlapping),
            alignment: Alignment(-0.5, _birdAnim.value)),
        Align(
          child: Text(
            "High Score: $_highScore \n Score: $_score",
            textAlign: TextAlign.right,
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                shadows: [Shadow(blurRadius: 1.0, offset: Offset(1.5, 1.5))]),
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  shadows: [Shadow(blurRadius: 1.0, offset: Offset(2, 2))]),
            ),
            color: Theme.of(context).accentColor,
            splashColor: Colors.blueGrey,
            onPressed: () {
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
