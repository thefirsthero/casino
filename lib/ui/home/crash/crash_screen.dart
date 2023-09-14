import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class CrashGameScreen extends StatefulWidget {
  @override
  _CrashGameScreenState createState() => _CrashGameScreenState();
}

class _CrashGameScreenState extends State<CrashGameScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  double _rocketPositionX = 0.1;
  double _rocketPositionY = 0.9;
  double _crashPointX = 0.0;
  double _crashPointY = 0.0;
  int _crashTime = 0;
  Timer? _timer;
  double _multiplier = 1.0;
  bool _isGameRunning = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startMultiplierTimer();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _generateRandomCrashTime() {
    final random = Random();
    _crashTime = random.nextInt(10) + 1; // Generates a random crash time between 1 and 10 seconds
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _crashTime),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _rocketCrashed();
        }
      });
  }

  void _rocketCrashed() {
    setState(() {
      _rocketPositionX = _crashPointX;
      _rocketPositionY = _crashPointY;
      _multiplier = 1.0;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Crash!'),
        content: const Text('The rocket crashed!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _startCrashGame() {
    setState(() {
      _isGameRunning = true;
      _generateRandomCrashTime();
      final random = Random();
      _crashPointX = random.nextDouble();
      _crashPointY = random.nextDouble();
      _animationController!.duration = Duration(seconds: _crashTime);
      _animationController!.reset();
      _animationController!.forward();
      _timer = Timer(Duration(seconds: _crashTime), _rocketCrashed);
    });
  }

  void _stopCrashGame() {
    setState(() {
      _isGameRunning = false;
      _animationController!.stop();
      _timer?.cancel();
    });
  }

  void _resetGame() {
    setState(() {
      _rocketPositionX = 0.1;
      _rocketPositionY = 0.9;
      _multiplier = 1.0;
    });
  }

  void _startMultiplierTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isGameRunning) {
        setState(() {
          _multiplier += 0.1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crash Game',
          style: TextStyle(
            color: Theme.of(context).textTheme.headline6!.color,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.headline6!.color,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned(
                bottom: _rocketPositionY * MediaQuery.of(context).size.height,
                left: _rocketPositionX * MediaQuery.of(context).size.width,
                child: Container(
                  width: 100,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/rocket.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isGameRunning ? null : _startCrashGame,
                      child: Text('Start'),
                    ),
                    ElevatedButton(
                      onPressed: _isGameRunning ? _stopCrashGame : null,
                      child: Text('Stop'),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Text(
                  'Multiplier: x${_multiplier.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
