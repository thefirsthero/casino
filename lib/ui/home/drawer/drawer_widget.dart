import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:flutter_login_screen/ui/lottery_draw/lottery_screen.dart';

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
              accountEmail: Text(user.email),
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
                // play lottery button (test button)
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
                    push(context, LotteryScreen(user: user)); // TEMP NAVIGATION CODE. MUST CHANGE TO BLOC!!!
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
