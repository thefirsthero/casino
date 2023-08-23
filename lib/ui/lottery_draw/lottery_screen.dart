import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<int> selectedNumbers = [];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    initializeNextDrawDateTime();
    startTimer();
  }

  Future<void> addCreditsToLotteryEvent() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lotteryEvents')
          .where('isOngoing', isEqualTo: true)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final latestEvent = querySnapshot.docs.first;
        final eventId = latestEvent.id;

        await FirebaseFirestore.instance
            .collection('lotteryEvents')
            .doc(eventId)
            .update({
          'amountSoFar': FieldValue.increment(5),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding credits to lottery event: $e');
      }
    }
  }

  Future<void> deductCredits(int amount) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.userID);

      final userData = await userRef.get();
      final currentCredits = userData.get('credits') as int;

      if (currentCredits >= amount) {
        await userRef.update({'credits': currentCredits - amount});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credits deducted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient credits!')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to deduct credits. Please try again.'),
        ),
      );
    }
  }

  void initializeNextDrawDateTime() {
    final now = DateTime.now();
    final currentDayOfDraw = DateFormat('EEEE').format(now);
    var daysToAdd = 0;

    switch (currentDayOfDraw) {
      case 'Monday':
        daysToAdd = 2 - now.weekday;
        break;
      case 'Tuesday':
        daysToAdd = 2 - now.weekday;
        break;
      case 'Wednesday':
        daysToAdd = 4 - now.weekday;
        break;
      case 'Thursday':
        daysToAdd = 4 - now.weekday;
        break;
      case 'Friday':
        daysToAdd = 7 - now.weekday;
        break;
      case 'Saturday':
        daysToAdd = 7 - now.weekday;
        break;
      case 'Sunday':
        daysToAdd = 7 - now.weekday;
        break;
      default:
        daysToAdd = 0;
        break;
    }

    final nextDrawDate = now.add(Duration(days: daysToAdd));
    nextDrawDateTime = DateTime(
        nextDrawDate.year, nextDrawDate.month, nextDrawDate.day, 21, 0, 0);
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
        countdown =
            '${difference.inHours}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}:${(difference.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });
  }

  Future<String> getDayOfDraw() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('lotteryEvents')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final latestEvent = querySnapshot.docs.first;
      final dayOfDraw = latestEvent.get('dayOfDraw');
      return dayOfDraw;
    }

    return '';
  }

  void generateRandomNumbers(int range) {
    setState(() {
      numbers = rng.generateNumbers(
          range,
          1,
          range == 29
              ? 29
              : range == 39
                  ? 39
                  : 49);
    });
  }

  Future<void> performDatabaseUpdate(String dayOfDraw) async {
    try {
      if (selectedNumbers.length != getRequiredNumberOfNumbers(dayOfDraw)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select the correct number of numbers.')),
        );
        return;
      }

      final selectedNumbersSorted = selectedNumbers.toList()..sort();
      final lotteryEventId = await getLotteryEventId();
      final userId = user.userID;
      final numbersPlayed = selectedNumbersSorted;
      final datePlayed = DateTime.now();

      // Update the database with the entry
      await FirebaseFirestore.instance.collection('gamesPlayed').add({
        'correctNumbers': [],
        'lotteryEventID': lotteryEventId,
        'userID': userId,
        'numbersPlayed': numbersPlayed,
        'datePlayed': datePlayed,
      });

      // Reset selectedNumbers and show a success message
      setState(() {
        selectedNumbers = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully entered the lottery!')),
      );
    } catch (error) {
      // print('Error: $error'); // log this error
      // Display an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to enter the lottery. Please try again.')),
      );
    }
  }

  Future<String> getLotteryEventId() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('lotteryEvents')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final latestEvent = querySnapshot.docs.first;
      final lotteryEventId = latestEvent.id;
      return lotteryEventId;
    }

    return '';
  }

  void enterLottery() async {
    final dayOfDraw = await getDayOfDraw();
    if (dayOfDraw.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No lottery event available.'),
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
      int range = dayOfDraw == 'Sunday'
          ? 49
          : dayOfDraw == 'Thursday'
              ? 39
              : 29;
      generateRandomNumbers(range);
      setState(() {
        selectedNumbers = [];
      }); // Reset selectedNumbers to an empty list
      showNumberSelectionPopup(dayOfDraw);
    }
  }

  void showNumberSelectionPopup(String dayOfDraw) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  'Please select ${dayOfDraw == 'Sunday' ? '2' : dayOfDraw == 'Thursday' ? '3' : '4'} numbers:'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumberSelectionWidget(dayOfDraw, selectedNumbers, (selected) {
                    setState(() {
                      selectedNumbers = selected;
                    });
                  }),
                  const SizedBox(height: 10),
                  Text(
                    'Numbers currently selected: ${selectedNumbers.join(', ')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Go Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedNumbers.length ==
                        getRequiredNumberOfNumbers(dayOfDraw)) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: const Text(
                                'Are you sure you want to enter the lottery? This action cannot be undone.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  // upon final confirmation update the database and take user back to base lottery screen.
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  await performDatabaseUpdate(dayOfDraw);
                                  await deductCredits(
                                      5); // Deduct 5 credits from the user's account
                                  await addCreditsToLotteryEvent(); // Add 5 credits to the amountSoFar field of the most recent lotteryEvent
                                },
                                child: const Text('Confirm'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please select the correct number of numbers.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm Selection'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int getRequiredNumberOfNumbers(String dayOfDraw) {
    switch (dayOfDraw) {
      case 'Sunday':
        return 2;
      case 'Thursday':
        return 3;
      case 'Tuesday':
        return 4;
      default:
        return 0;
    }
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
            color: isDarkMode(context)
                ? Colors.grey.shade50
                : Colors.grey.shade900,
          ),
        ),
        iconTheme: IconThemeData(
          color:
              isDarkMode(context) ? Colors.grey.shade50 : Colors.grey.shade900,
        ),
        backgroundColor:
            isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade50,
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
              onPressed: enterLottery,
              child: const Text('Enter Lottery'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class NumberSelectionWidget extends StatefulWidget {
  final String dayOfDraw;
  final List<int> selectedNumbers;
  final Function(List<int>) onSelectionChanged;

  const NumberSelectionWidget(
      this.dayOfDraw, this.selectedNumbers, this.onSelectionChanged,
      {super.key});

  @override
  _NumberSelectionWidgetState createState() => _NumberSelectionWidgetState();
}

class _NumberSelectionWidgetState extends State<NumberSelectionWidget> {
  late List<int> availableNumbers;

  @override
  void initState() {
    super.initState();
    availableNumbers = List<int>.generate(49, (index) => index + 1);
  }

  bool isNumberSelected(int number) {
    return widget.selectedNumbers.contains(number);
  }

  bool isNumberDisabled(int number) {
    int range = widget.dayOfDraw == 'Sunday'
        ? 49
        : widget.dayOfDraw == 'Thursday'
            ? 39
            : 29;
    return range == 29 && number > range ||
        range == 39 && number > range ||
        range == 49 && number > range;
  }

  void toggleNumberSelection(int number) {
    if (isNumberDisabled(number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('You can only select numbers within the current range.'),
        ),
      );
      return;
    }

    List<int> updatedSelection = List<int>.from(widget.selectedNumbers);

    if (isNumberSelected(number)) {
      updatedSelection.remove(number);
    } else {
      if (widget.dayOfDraw == 'Sunday' && updatedSelection.length >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only select 2 numbers for Sunday draws.'),
          ),
        );
        return;
      }

      if (widget.dayOfDraw == 'Thursday' && updatedSelection.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only select 3 numbers for Thursday draws.'),
          ),
        );
        return;
      }

      if (widget.dayOfDraw == 'Tuesday' && updatedSelection.length >= 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only select 4 numbers for Tuesday draws.'),
          ),
        );
        return;
      }

      updatedSelection.add(number);
    }

    widget.onSelectionChanged(updatedSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: availableNumbers.map((number) {
        return ElevatedButton(
          onPressed: isNumberDisabled(number)
              ? null
              : () => toggleNumberSelection(number),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isNumberSelected(number) ? Colors.blue : Colors.grey.shade300,
            shape: const CircleBorder(),
          ),
          child: Text(
            number.toString(),
            style: TextStyle(
              color: isNumberDisabled(number)
                  ? Colors.grey.shade400
                  : Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }
}
