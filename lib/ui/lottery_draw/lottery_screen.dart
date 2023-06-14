import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:flutter_login_screen/ui/auth/welcome/welcome_screen.dart';

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

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  void generateRandomNumbers() {
    setState(() {
      numbers = rng.generateNumbers(5, 1, 39);
    });
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .center, // Align column to the center vertically

            children: [
              // Temporary lines explaining the project
              ElevatedButton(
                onPressed: generateRandomNumbers,
                child: const Text('Generate Numbers'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Random Numbers:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                numbers.isNotEmpty
                    ? '${user.fullName()} rolled: ${numbers.join(', ')}'
                    : 'No numbers generated',
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
