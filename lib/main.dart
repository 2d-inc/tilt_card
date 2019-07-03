import 'package:flutter/material.dart';

import 'flare_tilt_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Tilt Card'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  double pitch = 0;
  double roll = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        lowerBound: 0,
        upperBound: 1,
        duration: const Duration(milliseconds: 500),
        vsync: this)
      ..addListener(() {
        setState(() {
          pitch *= _controller.value;
          roll *= _controller.value;
        });
      });

    // attitudeEvents.listen((AttitudeEvent event) {
    //   // Do something with the event.
    //   setState(() {
    //     attitude = event;
    //   });
    //   //print("${event.pitch} ${event.roll} ${event.pitch}");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(49, 27, 0, 1),
      body: GestureDetector(
        onPanUpdate: (DragUpdateDetails drag) {
          setState(() {
            var size = MediaQuery.of(context).size;
            pitch += drag.delta.dy * (1 / size.height);
            roll -= drag.delta.dx * (1 / size.width);
          });
        },
        onPanEnd: (DragEndDetails details) {
          _controller.reverse(from: 1.0);
        },
        onPanStart: (DragStartDetails details) {
          _controller.stop();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: FlareTiltWidget(
                'assets/Hamilton.flr',
                fit: BoxFit.contain,
                //   pitch: -attitude.pitch - pi / 1.45,
                //   roll: attitude.roll,
                pitch: pitch,
                roll: roll,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
