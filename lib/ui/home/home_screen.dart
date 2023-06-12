import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:flutter_login_screen/ui/auth/welcome/welcome_screen.dart';

import 'package:flutter_login_screen/ui/home/drawer/drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.authState == AuthState.unauthenticated) {
          pushAndRemoveUntil(context, const WelcomeScreen(), false);
        }
      },
      child: Scaffold(
        drawer: DrawerWidget(user: user), // Use the DrawerWidget

        appBar: AppBar(
          title: Text(
            'Home',
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
        ),
        body: const Center(
            child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Align column to the center vertically

          children: [
            // Temporary lines explaining the project
            Text(
                'The traditional lottery is pick 6 numbers from the range [1,59]'),
            Text('Your odds of winning are approximately 1 in 45,057,474'),
            Text("The Fairman's lottery is pick 6 numbers from the range [1,39]"),
            Text('Your odds of winning here are approximately 1 in  575,757'),
            Text(
                'Increasing your adds of winning by approximately 1297.37 times'),
          ],
        )),
      ),
    );
  }
}
