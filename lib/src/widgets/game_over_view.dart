import 'package:flutter/material.dart';
import '../components/game_over_status.dart';

class GameOverView extends StatefulWidget {
  final GameOverStatus? status;

  const GameOverView({super.key, required this.status});

  @override
  State<GameOverView> createState() => _GameOverViewState();
}

class _GameOverViewState extends State<GameOverView> {
  late String message;

  @override
  void initState() {
    super.initState();
    message = widget.status?.value ?? "Unknown State";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        const Text("Game Over", style: TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        Text(message, style: const TextStyle(fontSize: 20))
      ],
    ));
  }
}
