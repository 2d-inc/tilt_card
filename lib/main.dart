import 'package:flutter/material.dart';

import 'flare_tilt_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> tilt;
  Animation<double> depth;
  double pitch = 0;
  double yaw = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this)
      ..addListener(() {
        setState(() {
          if (tilt != null) {
            pitch *= tilt.value;
            yaw *= tilt.value;
          }
        });
      });
    _controller.forward(from: 1.0);
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
            yaw -= drag.delta.dx * (1 / size.width);
          });
        },
        onPanEnd: (DragEndDetails details) {
          tilt = Tween<double>(
            begin: 1.0,
            end: 0.0,
          ).animate(_controller);
          depth = Tween<double>(
            begin: 1.0,
            end: 0.0,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Cubic(0.5, 0.0, 0.26, 1.0),
            ),
          );
          _controller.forward();
        },
        onPanStart: (DragStartDetails details) {
          tilt = null;
          depth = Tween<double>(
            begin: 1.0,
            end: 0.0,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Cubic(1.0, 0.0, 1.0, 1.0),
            ),
          );
          _controller.reverse();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: FlareTiltWidget(
                'assets/TiltSquares.flr',
                fit: BoxFit.contain,
                alignment: Alignment.center,
                pitch: pitch,
                yaw: yaw,
                depth: (depth?.value ?? 0) * 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
