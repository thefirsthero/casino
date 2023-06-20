import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String userID;
  final String datePlayed;
  final String numbersPlayed;
  final String correctNumbers;
  final String lotteryEventID;
  List<dynamic> winningNumbers;

  Game({
    required this.id,
    required this.userID,
    required this.datePlayed,
    required this.numbersPlayed,
    required this.correctNumbers,
    required this.lotteryEventID,
    List<dynamic>? winningNumbers, // Updated parameter type
  }) : winningNumbers = winningNumbers ?? []; // Initialize with an empty list if null

  factory Game.fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Game(
      id: snapshot.id,
      userID: data['userID'] as String,
      datePlayed: (data['datePlayed'] as Timestamp).toDate().toString(),
      numbersPlayed: (data['numbersPlayed'] as List<dynamic>).join(', '),
      correctNumbers: (data['correctNumbers'] as List<dynamic>).join(', '),
      lotteryEventID: data['lotteryEventID'] as String,
      winningNumbers: data['winningNumbers'] != null ? data['winningNumbers'] as List<dynamic> : [], // Updated initialization
    );
  }
}
