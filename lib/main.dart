import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/physics.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'Flutter Demo',
      home: App(title: 'Flappy Flutter'),
    );
  }
}
class App extends StatefulWidget {
  App({Key key, this.title, this.duration }) : super(key: key);
  final String title;
  final Duration duration;
  @override
  _AppState createState() => _AppState();
}


class _AppState extends State<App> with SingleTickerProviderStateMixin {
  AnimationController _controller;
@override
void initState()
{
  super.initState();
  _controller =AnimationController(
    vsync: this,
   duration: const Duration(seconds: 10),

  )..repeat();
}
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  int _counter = 0;

  void _incrementCounter() {
    

    setState(() {

      _counter++;
    });
  }

  Future<void> drop() async {
  try {
    await _controller.animateWith(GravitySimulation(10.0,0,300.0,0.0));
    
    // setState(() {
    //   dismissed = true;
    // });
  } on TickerCanceled {
    // the animation got canceled, probably because we were disposed
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(child: Bird(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: Icon(Icons.add),
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
 // Animation<Offset> _flyAnimation;
  

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, upperBound: 1.0, debugLabel: "Drop", duration: Duration(seconds: 10), lowerBound: 0.0)..addListener(() {
      this.setState(() {});
    });
   // _controller.animateWith(GravitySimulation(10.0,0.0,300.0,1.0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Transform(
          transform: Matrix4.identity()
            ..translate(0.0, 
            _controller.value * height / 2),
            child: 
            GestureDetector(child: FlareActor("assets/FlutterBird.flr", alignment: Alignment.topCenter, fit:BoxFit.contain, animation:"Flap", isPaused: false), //Container(width: 200.0, height: 200.0, color: Colors.green),
              onTap: (){
                _controller.reset();
                _controller.animateWith(GravitySimulation(10.0,0.0,300.0,1.0));
                //_controller.animateWith(GravitySimulation(10.0,1,300.0,0.0));
                //_controller.fling(velocity: 50);
              })
    );
  }
}
