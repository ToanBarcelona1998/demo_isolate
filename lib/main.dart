import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
    _animation = Tween(begin: 0.0, end: 200.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value*2*pi,
                  child: Image.asset("assets/images/send.png"),
                );
              },
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                //_controller.stop();
                createNewIsolate();
              },
              child: Text("Start"),
            )
          ],
        ),
      ),
    );
  }
  void createNewIsolate() async{
    var receiveMainPort=ReceivePort();
    var plusIsolate=await Isolate.spawn(plus, receiveMainPort.sendPort);
    
    Future.delayed(Duration(seconds: 4),(){
      plusIsolate.kill(priority: Isolate.immediate);
      print("plus Isolate killed");
    });
    receiveMainPort.listen((message) {
      print("Total: ${message[0]}");
      if(message[1] is SendPort){
        message[1].send("From main Isolate");
      }
    });
  }
  static void plus(SendPort sendPort){
    var receivePlusPort=ReceivePort();
    var total=0;
    for(int i=0;i<100000000;i++){
      total+=i;
    }
    sendPort.send([total,receivePlusPort.sendPort]);
    receivePlusPort.listen((message) {
      print(message);
    });
  }

}
