import 'package:flutter/material.dart';
import 'button.dart';
import 'game_board.dart';
import 'new_game_button.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  navigateTo(StatefulWidget screen) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );

  @override
  Widget build(BuildContext context) {
    // db.removeAllSubriptions();
    return Scaffold(
      appBar: AppBar(
        title: const Text("MainMenu"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 10, child: Text("C H E S S Y", style: style())),
              NewGameButton(),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     MenuButton(text: "New Game", handler: () => navigateTo(const NewGameButton())),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle style() => const TextStyle(fontSize: 60);
}
