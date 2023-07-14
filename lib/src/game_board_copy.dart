import 'package:chess_v2/src/components/game_logic.dart';
import 'package:chess_v2/src/providers/game_state_provider.dart';
import 'package:chess_v2/src/providers/piece_provider.dart';
import 'package:chess_v2/src/services/database_service.dart';
import 'package:chess_v2/src/values/constants.dart';
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

    List<int> whiteKingPosition = [7, 4];
    List<int> blackKingPosition = [0, 4];
    bool checkStatus = false;

    void movePiece(int newRow, int newCol) {
      // move piece and clear the old spot
      board[newRow][newCol] = selectedPiece;
      board[selectedRow][selectedCol] = null;

      // check if the piece being moved is a king
      if (selectedPiece!.type == ChessPieceType.king) {
        // update appropriate king pos
        if (selectedPiece!.isWhite) {
          whiteKingPosition = [newRow, newCol];
        } else {
          blackKingPosition = [newRow, newCol];
        }
      }

      if (isKingInCheck(!isWhiteTurn, board)) {
        checkStatus = true;
      } else {
        checkStatus = false;
      }

      if (isCheckMate(!isWhiteTurn, board)) {
        showDialog(
            context: context,
            builder: (context) => const AlertDialog(
                  title: Text("Check Mate!"),
                ));
      }

      //change turns
      db.update({'db_game_board': board, 'is_white_turn': !isWhiteTurn});
    }

    void pieceSelected(int row, int col) {
      // printWarning("PIECESTATE : ${pieceState.clickedSquare}, ${pieceState.selectedPiece}, ${pieceState.validMoves}");
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
        appBar: AppBar(
          title: const Text(""),
        ),
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 20), child: Text("GAMESCREEN")),
            Container(
                margin: const EdgeInsets.only(top: 60),
                child: Text("Waiting for player:  ${state.waitingPlayer}")),
            Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(
                    "My Color: ${state.myColor}  Current Turn: ${isWhiteTurn == true ? 'white' : 'black'}")),
            Container(
                margin: const EdgeInsets.only(top: 10),
                child:
                    Text("My Turn: ${state.myColor == (isWhiteTurn == true ? 'white' : 'black')}")),
            Container(
                margin: const EdgeInsets.only(top: 100), child: Text(checkStatus ? "CHECK" : "")),
            Expanded(
                child: GridView.builder(
                    itemCount: 8 * 8,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                    itemBuilder: (context, index) {
                      int row = index ~/ 8;
                      int col = index % 8;
                      bool isSelected = false;
                      bool ableToAct = state.myColor == (isWhiteTurn == true ? 'white' : 'black') &&
                          state.waitingPlayer == false;
                      // bool isSelected = selectedRow == row && selectedCol == col;

                      if (pieceState.clickedSquare.isNotEmpty) {
                        isSelected = pieceState.clickedSquare[0] == row &&
                            pieceState.clickedSquare[1] == col;
                      }

                      bool isValidMove = false;
                      // for (var position in validMoves) {
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
                        // onTap: () => pieceSelected(row, col),
                        onTap: () => ableToAct ? pieceSelected(row, col) : null,
                        // onTap: () => print("$row $col"),
                      );
                    })),
          ],
        ),
      ),
    );
  }
}
