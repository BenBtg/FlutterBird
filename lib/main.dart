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
  AnimationController _controller;
  bool _isFlapping =false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, lowerBound: -1.0, upperBound: 1.01, debugLabel: "Drop", duration: Duration(seconds: 5),)
    ..addListener(() {
      print("Frame "+ _controller.toStringDetails());
      this.setState(() {});
    })..addStatusListener((status){
      print("Status changed " + status.toString() + _controller.toStringDetails());
      if (status == AnimationStatus.completed) {
          print("Drop completed" + _controller.toStringDetails());
      }
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
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
       FractionallySizedBox(widthFactor: 0.2, heightFactor: 0.2, child:
        FlareActor("assets/FlutterBird.flr", fit:BoxFit.fitWidth, animation:"Flap", isPaused: !_isFlapping),

        alignment: new Alignment(0.0, _controller.value),
        ),
       GestureDetector(
        onTap: (){
          _isFlapping=true;
         double top =_controller.value - 0.25;
         print("Flying" + _controller.toStringDetails());
         _controller.animateTo(top, duration: Duration(milliseconds: 200)).whenComplete((){
          _isFlapping =false;
         print("Flap completed" + _controller.toStringDetails());
        _controller.animateWith(GravitySimulation(9.8, _controller.value, 1.01,1.0));
        }
        );
        }),
        ]
       ),
       
    );
  }
}

// class Bird extends StatefulWidget {
//   Bird({this.y});
//   double y;
//   @override
//   _BirdState createState() => _BirdState();
// }

// class _BirdState extends State<Bird> with SingleTickerProviderStateMixin {
//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     double x = MediaQuery.of(context).size.width / 9;
//     return Container(width: 250.0, height: 200.0, 
//         child: FlareActor("assets/FlutterBird.flr", alignment: Alignment.topCenter, fit:BoxFit.fill, animation:"Flap", isPaused: false),
//         transform: Matrix4.identity()..translate(x, widget.y),
//         );
//   }
// }
