import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_screen/model/game.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/home/drawer/drawer_widget.dart';

enum FilterType {
  day,
  month,
  year,
  all,
}

class HistoryScreen extends StatefulWidget {
  final User user;

  const HistoryScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FilterType _filterType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _filterType = FilterType.all;
    _selectedDate = null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(
              color: isDarkMode(context)
                  ? Colors.grey.shade50
                  : Colors.grey.shade900),
        ),
        iconTheme: IconThemeData(
            color: isDarkMode(context)
                ? Colors.grey.shade50
                : Colors.grey.shade900),
        backgroundColor:
            isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade50,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor:
              isDarkMode(context) ? Colors.grey.shade50 : Colors.grey.shade900,
          unselectedLabelColor:
              isDarkMode(context) ? Colors.grey.shade50 : Colors.grey.shade900,
          tabs: [
            Tab(text: 'Day'),
            Tab(text: 'Month'),
            Tab(text: 'Year'),
            Tab(text: 'All'),
          ],
          onTap: (index) {
            setState(() {
              _filterType = FilterType.values[index];
              _selectedDate = null;
            });
          },
        ),
      ),
      drawer: DrawerWidget(user: widget.user),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('gamesPlayed')
            .where('userID', isEqualTo: widget.user.userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final games = snapshot.data!.docs
                .map((doc) => Game.fromDocument(doc))
                .toList();
            final filteredGamesFuture = _getFilteredGamesWithWinningNumbers(
                games, _filterType, _selectedDate);
            return Column(
              children: [
                if (_filterType != FilterType.all)
                  Container(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _selectedDate = selectedDate;
                          });
                        }
                      },
                      child: Text(
                          'Select ${_filterType.toString().split('.').last}'),
                    ),
                  ),
                Expanded(
                  child: FutureBuilder<List<Game>>(
                    future: filteredGamesFuture,
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
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date Played: ${game.datePlayed}'),
                                    SizedBox(height: 8),
                                    Text(
                                        'Numbers Played: ${game.numbersPlayed}'),
                                    SizedBox(height: 4),
                                    Text(
                                        'Correct Numbers: ${game.correctNumbers}'),
                                    SizedBox(height: 4),
                                    Text(
                                        'Winning Numbers: ${game.winningNumbers}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List<Game>> _getFilteredGamesWithWinningNumbers(
      List<Game> games, FilterType filterType, DateTime? selectedDate) async {
    final List<Game> filteredGamesWithWinningNumbers = [];

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

      bool includeGame = false;

      switch (filterType) {
        case FilterType.day:
          includeGame = _isSameDay(game.datePlayed, selectedDate);
          break;
        case FilterType.month:
          includeGame = _isSameMonth(game.datePlayed, selectedDate);
          break;
        case FilterType.year:
          includeGame = _isSameYear(game.datePlayed, selectedDate);
          break;
        case FilterType.all:
          includeGame = true;
          break;
      }

      if (includeGame) {
        filteredGamesWithWinningNumbers.add(game);
      }
    }

    return filteredGamesWithWinningNumbers;
  }

  bool _isSameDay(String date, DateTime? selectedDate) {
    if (selectedDate == null) return false;
    final gameDate = DateTime.parse(date);
    return gameDate.year == selectedDate.year &&
        gameDate.month == selectedDate.month &&
        gameDate.day == selectedDate.day;
  }

  bool _isSameMonth(String date, DateTime? selectedDate) {
    if (selectedDate == null) return false;
    final gameDate = DateTime.parse(date);
    return gameDate.year == selectedDate.year &&
        gameDate.month == selectedDate.month;
  }

  bool _isSameYear(String date, DateTime? selectedDate) {
    if (selectedDate == null) return false;
    final gameDate = DateTime.parse(date);
    return gameDate.year == selectedDate.year;
  }
}
