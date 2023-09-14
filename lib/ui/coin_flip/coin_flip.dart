import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_login_screen/model/user.dart';

class CoinFlipScreen extends StatefulWidget {
  final User user;

  CoinFlipScreen({required this.user});

  @override
  _CoinFlipScreenState createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends State<CoinFlipScreen> {
  final List<String> coinSides = ['Heads', 'Tails'];
  String result = '';
  bool isFlipping = false;
  int userCredits = 1;
  String userChoice = '';
  int initialCredits = 0; // Initial credits fetched from Firestore

  @override
  void initState() {
    super.initState();
    // Fetch initial credits from Firestore when the screen initializes
    fetchInitialCredits();
  }

  Future<void> fetchInitialCredits() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.user.userID);

      final userData = await userRef.get();
      final credits = userData.get('credits') as int;

      setState(() {
        initialCredits = credits;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching initial credits: $error');
      }
    }
  }

  Future<void> deductCredits(int amount) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.userID);

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

  Future<void> addGameRecord(
    int creditsEndedWith,
    bool isGameWon,
    int creditsWagered,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('coinFlipGamesPlayed').add({
        'userID': widget.user.userID,
        'creditsStartedWith': initialCredits,
        'creditsEndedWith': creditsEndedWith,
        'isGameWon': isGameWon,
        'creditsWagered': creditsWagered,
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error adding game record: $error');
      }
    }
  }

  Future<void> flipCoin() async {
    try {
      if (!isFlipping) {
        if (userCredits < 1 || userCredits > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Wager must be between 1 and 100 credits.')),
          );
          return;
        }

        if (userChoice.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select "Heads" or "Tails".')),
          );
          return;
        }

        isFlipping = true;
        final random = Random();
        final randomIndex = random.nextInt(coinSides.length);
        final randomSide = coinSides[randomIndex];

        Timer.periodic(const Duration(milliseconds: 100), (timer) {
          setState(() {
            result = randomSide;
          });
          timer.cancel();
          isFlipping = false;

          final isUserWin = (result == userChoice);
          var finalCreditsNumber = initialCredits - userCredits;

          if (isUserWin) {
            finalCreditsNumber += userCredits;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You win ${userCredits * 2} credits!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You lose all your credits.')),
            );
          }

          // Deduct or add credits to the user's database
          deductCredits(userCredits * (isUserWin ? -1 : 1));

          // Record game information in Firestore
          addGameRecord(
            finalCreditsNumber,
            isUserWin,
            userCredits,
          );

          // Reset the slider and selected choice
          setState(() {
            userCredits = 1;
            userChoice = '';
          });
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to play dice. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heads or Tails'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Result:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              result,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Wager: $userCredits credits',
              style: TextStyle(fontSize: 20),
            ),
            Slider(
              value: userCredits.toDouble(),
              min: 1,
              max: 100,
              onChanged: (value) {
                setState(() {
                  userCredits =
                      value.round().clamp(1, 100); // Ensure valid range
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Select: $userChoice',
              style: TextStyle(fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      userChoice = 'Heads';
                    });
                  },
                  child: Text('Heads'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      userChoice = 'Tails';
                    });
                  },
                  child: Text('Tails'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: flipCoin,
              child: Text('Flip Coin'),
            ),
          ],
        ),
      ),
    );
  }
}
