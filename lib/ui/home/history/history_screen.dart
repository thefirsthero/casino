import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_screen/model/game.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/ui/home/drawer/drawer_widget.dart';

class HistoryScreen extends StatelessWidget {
  final User user;

  const HistoryScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      drawer: DrawerWidget(user: user),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('gamesPlayed')
            .where('userID', isEqualTo: user.userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final games = snapshot.data!.docs
                .map((doc) => Game.fromDocument(doc))
                .toList();
            return FutureBuilder<List<Game>>(
              future: _getGamesWithWinningNumbers(games),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final gamesWithWinningNumbers = snapshot.data!;
                  return ListView.builder(
                    itemCount: gamesWithWinningNumbers.length,
                    itemBuilder: (context, index) {
                      final game = gamesWithWinningNumbers[index];
                      return ListTile(
                        title: Text('Date Played: ${game.datePlayed}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Numbers Played: ${game.numbersPlayed}'),
                            Text('Correct Numbers: ${game.correctNumbers}'),
                            Text('Winning Numbers: ${game.winningNumbers}'),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future<List<Game>> _getGamesWithWinningNumbers(List<Game> games) async {
    final List<Game> gamesWithWinningNumbers = [];

    for (final game in games) {
      final lotteryEvent = await FirebaseFirestore.instance
          .collection('lotteryEvents')
          .doc(game.lotteryEventID)
          .get();

      if (lotteryEvent.exists && !lotteryEvent['isOngoing']) {
        final winningNumbers = lotteryEvent['winningNumbers'];
        game.winningNumbers = winningNumbers;
      } else {
        game.winningNumbers = [];
      }

      gamesWithWinningNumbers.add(game);
    }

    return gamesWithWinningNumbers;
  }
}
