import 'package:chess_v2/src/components/game_logic.dart';
import 'package:chess_v2/src/providers/game_state_provider.dart';
import 'package:chess_v2/src/providers/piece_provider.dart';
import 'package:chess_v2/src/services/database_service.dart';
import 'package:chess_v2/src/values/constants.dart';
import 'package:chess_v2/src/widgets/game_over_view.dart';
import 'package:chess_v2/src/widgets/waiting_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'components/piece.dart';
import 'components/square.dart';
import 'helper/helper_methods.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late GameState state = ref.watch(gameStateProvider);
    late GameStateNotifier provider = ref.read(gameStateProvider.notifier);
    late List<List<ChessPiece?>> board = ref.watch(gameStateProvider).gameboard;
    late PieceStateNotifier pieceProvider = ref.read(pieceStateProvider.notifier);
    late PieceState pieceState = ref.watch(pieceStateProvider);

    ChessPiece? selectedPiece = pieceState.selectedPiece;
    int selectedRow = pieceState.clickedSquare[0];
    int selectedCol = pieceState.clickedSquare[1];
    List<List<int>> validMoves = pieceState.validMoves;
    bool isWhiteTurn = state.isWhiteTurn;

    void movePiece(int newRow, int newCol) {
      // move piece and clear the old spot
      board[newRow][newCol] = selectedPiece;
      board[selectedRow][selectedCol] = null;

      if (isCheckMate(!isWhiteTurn, board)) {
        db.update({'db_game_board': board, 'is_white_turn': !isWhiteTurn, "winner": state.myColor});
      } else {
        //change turns
        db.update({'db_game_board': board, 'is_white_turn': !isWhiteTurn});
      }
    }

    void pieceSelected(int row, int col) {
      var selectedSquare = board[row][col];
      bool didMove = false;
      // no piece selected yet
      if (selectedSquare != null && selectedPiece == null) {
        if (selectedSquare.isWhite == isWhiteTurn) {
          selectedPiece = selectedSquare;
          pieceProvider.setClickedPiece([row, col], selectedPiece!);
          selectedRow = row;
          selectedCol = col;
        }

        // there is piece selected, but user can select another one of their pieces
      } else if (selectedSquare != null && selectedSquare.isWhite == selectedPiece!.isWhite) {
        selectedPiece = selectedSquare;
        pieceProvider.setClickedPiece([row, col], selectedPiece!);
        selectedRow = row;
        selectedCol = col;

        // if there is a piece selected and user taps on a square that is valid move
      } else if (selectedPiece != null && validMoves.any((e) => e[0] == row && e[1] == col)) {
        movePiece(row, col);
        didMove = true;
      }

      // if a piece is selected, calculate its valid moves
      validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true, board);
      // printGreen('validMoves = $validMoves');
      pieceProvider.setValidMoves(validMoves);

      // clears all moves and selections
      if (didMove) pieceProvider.clearPieceState();
    }

    return WillPopScope(
      onWillPop: () async {
        ref.read(gameStateProvider.notifier).closeStream();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("GAMESCREEN")),
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 20),
                child: Text("Waiting for player:  ${state.waitingPlayer}")),
            Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text("PLAYING AS : ${state.myColor}")),
            Container(
                margin: const EdgeInsets.only(top: 10),
                child: Container(
                    width: 60,
                    height: 60,
                    color: (state.myColor == (isWhiteTurn == true ? 'white' : 'black'))
                        ? Colors.green
                        : Colors.grey)),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  state.isCheck ? "KING IN CHECK" : "",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  state.gameOverStatus != null ? state.gameOverStatus!.value : "",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
            gameGrid(state, isWhiteTurn, pieceState, validMoves, board, pieceSelected),

            // TODO: Working solution
            // state.waitingPlayer
            //     ? WaitingView()
            //     : state.gameOverStatus != null
            //         ? GameOverView(status: state.gameOverStatus)
            //         : gameGrid(state, isWhiteTurn, pieceState, validMoves, board, pieceSelected),
          ],
        ),
      ),
    );
  }

  Expanded gameGrid(
      GameState state,
      bool isWhiteTurn,
      PieceState pieceState,
      List<List<int>> validMoves,
      List<List<ChessPiece?>> board,
      void Function(int row, int col) pieceSelected) {
    return Expanded(
        child: GridView.builder(
            itemCount: 8 * 8,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemBuilder: (context, index) {
              int row = index ~/ 8;
              int col = index % 8;
              bool isSelected = false;
              bool ableToAct = state.myColor == (isWhiteTurn == true ? 'white' : 'black') &&
                  state.waitingPlayer == false;
              // bool isSelected = selectedRow == row && selectedCol == col;

              if (pieceState.clickedSquare.isNotEmpty) {
                isSelected =
                    pieceState.clickedSquare[0] == row && pieceState.clickedSquare[1] == col;
              }

              bool isValidMove = false;
              for (var position in validMoves) {
                if (position[0] == row && position[1] == col) {
                  isValidMove = true;
                }
              }

              return Square(
                isWhite: isWhite(index),
                piece: board[row][col],
                isSelected: isSelected,
                isValidMove: isValidMove,
                onTap: () => ableToAct ? pieceSelected(row, col) : null,
              );
            }));
  }
}
