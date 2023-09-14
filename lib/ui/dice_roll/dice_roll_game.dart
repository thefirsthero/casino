import 'package:flutter/material.dart';
import 'dart:math';

class DiceGameScreen extends StatefulWidget {
  @override
  _DiceGameScreenState createState() => _DiceGameScreenState();
}

class _DiceGameScreenState extends State<DiceGameScreen> {
  int selectedNumber = 1; // Default selected number
  int diceResult = 1; // Default dice result
  bool isRewardEarned = false;

  void rollDice() {
    // Simulate rolling a dice (generate a random number between 1 and 6)
    final random = Random();
    final rolledNumber = random.nextInt(6) + 1;

    setState(() {
      diceResult = rolledNumber;

      // Check if the selected number matches the dice result
      if (selectedNumber == diceResult) {
        isRewardEarned = true;
      } else {
        isRewardEarned = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dice Rolling Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Select a number:',
              style: TextStyle(fontSize: 18),
            ),
            DropdownButton<int>(
              value: selectedNumber,
              items: List.generate(
                6,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text((index + 1).toString()),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedNumber = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: rollDice,
              child: Text('Roll Dice'),
            ),
            SizedBox(height: 20),
            Text(
              'Dice Result: $diceResult',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              isRewardEarned ? 'Congratulations! You earned a reward!' : 'Try again.',
              style: TextStyle(
                fontSize: 20,
                color: isRewardEarned ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
