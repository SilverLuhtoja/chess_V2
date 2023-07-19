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

      printGreen(
          "${state.myColor} is moving to ${String.fromCharCode('a'.codeUnitAt(0) + newCol)} ${8 - newRow}");
      List<String> moveHistory = state.moveHistory;
      moveHistory.add(
          "${String.fromCharCode('a'.codeUnitAt(0) + selectedCol)}${8 - selectedRow} -> ${String.fromCharCode('a'.codeUnitAt(0) + newCol)}${8 - newRow}");
      Map<String, dynamic> params = {
        'db_game_board': board,
        'is_white_turn': !isWhiteTurn,
        "move_history": moveHistory
      };
      if (isCheckMate(!isWhiteTurn, board)) {
        params['winner'] = state.myColor;
        db.update(params);
      } else {
        //change turns
        db.update(params);
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
        ref.read(gameStateProvider.notifier).resetState();
        await db.leaveRoom(state.myColor);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("GAMESCREEN")),
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              state.waitingPlayer
                  ? const WaitingView()
                  : state.gameOverStatus != null
                      ? Center(child: GameOverView(status: state.gameOverStatus))
                      : gameView(context, state, isWhiteTurn, pieceState, validMoves, board,
                          pieceSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget gameView(
      BuildContext context,
      GameState state,
      bool isWhiteTurn,
      PieceState pieceState,
      List<List<int>> validMoves,
      List<List<ChessPiece?>> board,
      void Function(int row, int col) pieceSelected) {
    return Column(
      children: [
        Container(
            margin: const EdgeInsets.only(top: 20),
            child: Text("Waiting for player:  ${state.waitingPlayer}")),
        Container(
            margin: const EdgeInsets.only(top: 10), child: Text("PLAYING AS : ${state.myColor}")),
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
        gameGrid(context, state, isWhiteTurn, pieceState, validMoves, board, pieceSelected),
        buildHistory(context, state),
      ],
    );
  }

  Container gameGrid(
      BuildContext context,
      GameState state,
      bool isWhiteTurn,
      PieceState pieceState,
      List<List<int>> validMoves,
      List<List<ChessPiece?>> board,
      void Function(int row, int col) pieceSelected) {
    double padding = 30;
    double gridSize = MediaQuery.of(context).size.width - padding;
    return Container(
      width: gridSize,
      height: gridSize,
      margin: const EdgeInsets.only(bottom: 50),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: padding), // Empty cell to align with the checkerboard
          for (var i = 0; i < 8; i++)
            Container(
                width: padding - 4,
                height: padding,
                child: Text(
                  String.fromCharCode('a'.codeUnitAt(0) + i),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )),
        ]),
        Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (var i = 0; i < 8; i++)
              Container(
                  width: padding,
                  height: padding,
                  alignment: Alignment.center,
                  child: Text(
                    (8 - i).toString(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  )),
          ]),
          SizedBox(
              width: gridSize - padding,
              height: gridSize - padding,
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
                  })),
        ])),
      ]),
    );
  }

  Widget buildHistory(BuildContext context, GameState state) {
    List<List<String>> rounds = state.moveHistory.fold<List<List<String>>>([], (result, move) {
      if (result.isEmpty || result.last.length == 2) {
        result.add([move]);
      } else {
        result.last.add(move);
      }
      return result;
    });
    return FilledButton(
        onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("History"),
                content: Container(
                    padding: const EdgeInsets.all(10),
                    height: 300,
                    color: Colors.grey,
                    child: SizedBox(
                        child: ListView.builder(
                            itemCount: rounds.length,
                            itemBuilder: (context, roundIndex) {
                              List<String> roundMoves = rounds[roundIndex];

                              return Row(
                                children: [
                                  Text('Round ${roundIndex + 1}: '),
                                  roundMoves.length > 1
                                      ? Row(children: [
                                          Text(roundMoves[0],
                                              style: const TextStyle(color: Colors.white)),
                                          const Text(" , "),
                                          Text(roundMoves[1],
                                              style: const TextStyle(color: Colors.black)),
                                        ])
                                      : Text(roundMoves[0],
                                          style: const TextStyle(color: Colors.white))
                                ],
                              );
                            }))),
              ),
            ),
        child: const Text("MOVES HISTORY"));
  }
}
