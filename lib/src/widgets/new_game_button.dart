import 'package:chess_v2/src/game_screen.dart';
import 'package:chess_v2/src/providers/game_state_provider.dart';
import 'package:chess_v2/src/services/database_service.dart';
import 'package:chess_v2/src/widgets/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helper/helper_methods.dart';

class NewGameButton extends ConsumerWidget {
  const NewGameButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameProvider = ref.read(gameStateProvider.notifier);

    return SizedBox(
      width: 160,
      child: FilledButton(
          onPressed: () async {
            try {
              String myColor = await db.createOrJoinGame();
              gameProvider.setMyColor(myColor);
              printGreen("new_game_button: new game created");
              if (context.mounted) {
                gameProvider.startStream();
                // navigateTo(context, const GameBoard());
                navigateTo(context, GameScreen());
              }
            } catch (e) {
              printError(e.toString());
              showError(
                  currentContext: context,
                  message: 'Could not connect to DB. Please try again ',
                  isError: true);
            }
          },
          child: const Text('New Game')),
    );
  }
}