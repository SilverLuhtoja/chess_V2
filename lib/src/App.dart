import 'package:flutter/material.dart';

import 'main_menu_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: GameBoard()
        home: MainMenuScreen());
  }
}

