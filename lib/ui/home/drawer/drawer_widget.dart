import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:flutter_login_screen/ui/home/crash/crash_screen.dart';
import 'package:flutter_login_screen/ui/home/history/history_screen.dart';
import 'package:flutter_login_screen/ui/home/home_screen.dart';
import 'package:flutter_login_screen/ui/lottery_draw/lottery_screen.dart';
import 'package:flutter_login_screen/ui/about/about_screen.dart';

class DrawerWidget extends StatelessWidget {
  final User user;

  const DrawerWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                user.fullName(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.userID)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var credits = snapshot.data!.get('credits');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        Text(
                          'Credits: $credits',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        const Text(
                          'Credits: Loading...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    const AssetImage('assets/images/placeholder.jpg'),
                child: user.profilePictureURL == ''
                    ? CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey.shade400,
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: Image.asset(
                            'assets/images/placeholder.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : displayCircleImage(user.profilePictureURL, 80, false),
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // home button
                ListTile(
                  title: Text(
                    'Home',
                    style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  leading: Transform.rotate(
                    angle: 0,
                    child: Icon(
                      Icons.home,
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  onTap: () {
                    // Replace with the route to your home page
                    push(context, HomeScreen(user: user));
                  },
                ),
                // play lottery button
                ListTile(
                  title: Text(
                    'Play Lottery',
                    style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  leading: Transform.rotate(
                    angle: pi / 1,
                    child: Icon(
                      Icons.money,
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  onTap: () {
                    push(context, LotteryScreen(user: user));
                  },
                ),
                // about button
                ListTile(
                  title: Text(
                    'About',
                    style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  leading: Transform.rotate(
                    angle: 0,
                    child: Icon(
                      Icons.info,
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  onTap: () {
                    push(context, AboutPage(user: user));
                  },
                ),
                // crash game button
                ListTile(
                  title: Text(
                    'Crash Game',
                    style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  leading: Transform.rotate(
                    angle: pi / 1,
                    child: Icon(
                      Icons.gamepad,
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  onTap: () {
                    // Replace with the route to your crash game screen
                    push(context, CrashGameScreen());
                  },
                ),
                // history button
                ListTile(
                  title: Text(
                    'History',
                    style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  leading: Transform.rotate(
                    angle: pi / 1,
                    child: Icon(
                      Icons.history,
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  onTap: () {
                    push(context, HistoryScreen(user: user));
                  },
                ),
                // logout button
                ListTile(
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  leading: Transform.rotate(
                    angle: pi / 1,
                    child: Icon(
                      Icons.exit_to_app,
                      color: isDarkMode(context)
                          ? Colors.grey.shade50
                          : Colors.grey.shade900,
                    ),
                  ),
                  onTap: () {
                    context.read<AuthenticationBloc>().add(LogoutEvent());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
