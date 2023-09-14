import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(PlinkoApp());

class PlinkoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PlinkoScreen(),
    );
  }
}

class PlinkoScreen extends StatefulWidget {
  @override
  _PlinkoScreenState createState() => _PlinkoScreenState();
}

class _PlinkoScreenState extends State<PlinkoScreen> {
  final int rows = 7;
  final int slots = 8;
  double ballPosition = 0.0;
  bool isDropping = false;
  late StreamController<double> _controller;
  late StreamSubscription<double> _subscription;

  @override
  void initState() {
    super.initState();
    _controller = StreamController<double>();
    _subscription = _controller.stream.listen((position) {
      setState(() {
        ballPosition = position;
      });
    });
  }

  @override
  void dispose() {
    _controller.close();
    _subscription.cancel();
    super.dispose();
  }

  void dropBall() {
    if (!isDropping) {
      isDropping = true;
      double initialX = 0.0; // Initial starting slot
      double currentX = initialX;
      double currentY = 0.0;
      const double slotWidth = 1.0 / 8; // Width of each slot

      _controller.add(currentX);

      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        currentY += 0.1; // Adjust the speed of the ball drop

        if (currentY >= rows) {
          // Ball reached the bottom
          timer.cancel();
          isDropping = false;
        } else {
          currentX += slotWidth * (Random().nextInt(3) - 1); // Move left or right randomly
          _controller.add(currentX);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plinko Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PlinkoBoard(
              rows: rows,
              slots: slots,
              ballPosition: ballPosition,
            ),
            ElevatedButton(
              onPressed: dropBall,
              child: Text('Drop Ball'),
            ),
          ],
        ),
      ),
    );
  }
}

class PlinkoBoard extends StatelessWidget {
  final int rows;
  final int slots;
  final double ballPosition;

  PlinkoBoard({
    required this.rows,
    required this.slots,
    required this.ballPosition,
  });

  @override
  Widget build(BuildContext context) {
    final double slotWidth = 1.0 / slots;
    final double slotHeight = 1.0 / rows;

    return Container(
      width: 300,
      height: 500,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Stack(
        children: <Widget>[
          for (int i = 0; i < rows; i++)
            for (int j = 0; j < slots; j++)
              Positioned(
                left: j * slotWidth * 300,
                top: i * slotHeight * 500,
                child: Container(
                  width: slotWidth * 300,
                  height: slotHeight * 500,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          Positioned(
            left: ballPosition * 300,
            top: rows * slotHeight * 500 - 20, // Adjust the position of the ball
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
