import 'package:flutter/material.dart';
import 'button.dart';
import 'how_to_play_screen.dart';
import 'widgets/new_game_button.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("MainMenu"),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 10, child: Text("C H E S S Y", style: style())),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NewGameButton(),
                const SizedBox(height: 20),
                MenuButton(
                    text: "How to PLay?", handler: () => navigateTo(const HowToPlayScreen())),
              ],
            )
          ],
        ),
      ),
    );
  }

  TextStyle style() => const TextStyle(fontSize: 60);
}
