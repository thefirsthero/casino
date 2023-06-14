import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/home/drawer/drawer_widget.dart';
import 'package:flutter_login_screen/services/random_number_generator.dart';

class LotteryScreen extends StatefulWidget {
  final User user;

  const LotteryScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() => _LotteryState();
}

class _LotteryState extends State<LotteryScreen> {
  late User user;
  List<int> numbers = [];
  RandomNumberGenerator rng = RandomNumberGenerator();
  late DateTime nextDrawDateTime;
  late Timer _timer;
  String countdown = '';

  @override
  void initState() {
    super.initState();
    user = widget.user;
    initializeNextDrawDateTime();
    startTimer();
  }

  void initializeNextDrawDateTime() {
    final now = DateTime.now();
    final currentDayOfDraw = DateFormat('EEEE').format(now);
    var daysToAdd = 0;

    switch (currentDayOfDraw) {
      case 'Tuesday':
        daysToAdd = now.weekday <= 2 ? 2 - now.weekday : 9 - now.weekday;
        break;
      case 'Thursday':
        daysToAdd = now.weekday <= 4 ? 4 - now.weekday : 11 - now.weekday;
        break;
      case 'Sunday':
        daysToAdd = now.weekday <= 7 ? 7 - now.weekday : 14 - now.weekday;
        break;
    }

    final nextDrawDate = now.add(Duration(days: daysToAdd));
    nextDrawDateTime = DateTime(nextDrawDate.year, nextDrawDate.month, nextDrawDate.day, 21, 0, 0);
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(nextDrawDateTime)) {
        _timer.cancel();
        return;
      }
      final difference = nextDrawDateTime.difference(now);
      setState(() {
        countdown = '${difference.inHours}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}:${(difference.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });
  }

  void generateRandomNumbers() {
    setState(() {
      numbers = rng.generateNumbers(5, 1, 39);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(user: user),

      appBar: AppBar(
        title: Text(
          'Play Lottery',
          style: TextStyle(
            color: isDarkMode(context) ? Colors.grey.shade50 : Colors.grey.shade900,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDarkMode(context) ? Colors.grey.shade50 : Colors.grey.shade900,
        ),
        backgroundColor: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade50,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (countdown.isNotEmpty)
              Text(
                'Next Draw in: $countdown',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                final difference = nextDrawDateTime.difference(now);
                if (difference.inHours <= 1 || difference.inHours >= 23) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('You cannot enter 1 hour before or 1 hour after the draw.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  generateRandomNumbers();
                }
              },
              child: const Text('Generate Numbers'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Random Numbers:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              numbers.isNotEmpty ? '${user.fullName()} rolled: ${numbers.join(', ')}' : 'No numbers generated',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
