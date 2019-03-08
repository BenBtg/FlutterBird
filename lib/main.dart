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
  App({Key key, this.title }) : super(key: key);
  final String title;
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(children: <Widget>[
        Container(
      decoration: BoxDecoration(
              // Box decoration takes a gradient
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                stops: [0.1, 1.0],
                colors: [
                  Color.fromRGBO(131, 232, 255, 1.0),
                  Color.fromRGBO(110, 10, 211, 1.0),
                ],
              ),
          ),
       ),
       Bird()]
       ),
    );
  }
}

class Bird extends StatefulWidget {
  @override
  _BirdState createState() => _BirdState();
}

class _BirdState extends State<Bird> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, upperBound: 1.0, debugLabel: "Drop", duration: Duration(seconds: 10), lowerBound: 0.0)..addListener(() {
      this.setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(width: 220.0, height: 200.0, 
        child: GestureDetector(child: FlareActor("assets/FlutterBird.flr", alignment: Alignment.topCenter, fit:BoxFit.fill, animation:"Flap", isPaused: false),
        onTap: (){
          _controller.reset();
          _controller.animateWith(GravitySimulation(10.0,0.0,300.0,1.0));
        }),
        transform: Matrix4.identity()..translate(0.0, _controller.value * height / 2),
        );
  }
}
