import 'package:flutter/material.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/ui/home/drawer/drawer_widget.dart';

class AboutPage extends StatelessWidget {
  final User user;

  const AboutPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText1?.color;

    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      drawer: DrawerWidget(user: user), // Include the DrawerWidget

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: textColor ?? Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(
                    'The traditional lottery',
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Allows players to pick 6 random numbers within the range 1 to 59',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your odds of winning are approximately 1 in 45,057,474',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: textColor ?? Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(
                    "The Fairman's lottery",
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Aims to not only increase your odds of winning but increase the fairness of the game, and that starts with giving you choice',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'There are 3 draws that happen every week:',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '- Tuesday draw: Pick 4 numbers within the range 1 to 29. Odds of winning: approximately 1 in 16,290.',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '- Thursday draw: Pick 3 numbers within the range 1 to 39. Odds of winning: approximately 1 in 9,139.',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '- Sunday draw: Pick 2 numbers within the range 1 to 49. Odds of winning: approximately 1 in 1,176.',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
