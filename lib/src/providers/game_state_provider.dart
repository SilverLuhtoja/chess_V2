import 'dart:async';
import 'dart:convert';

import '../components/game_logic.dart';
import '../components/game_over_status.dart';
import '../components/piece.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helper/helper_methods.dart';
import '../services/database_service.dart';

class GameState {
  final List<List<ChessPiece?>> gameboard;
  final bool isWhiteTurn;
  late bool waitingPlayer;
  late GameOverStatus? gameOverStatus;
  late bool isCheck;
  late String? myColor;
  late List<int> clickedPiece = [-1, -1];

  GameState({
    required this.gameboard,
    required this.isWhiteTurn,
    required this.waitingPlayer,
    required this.gameOverStatus,
    required this.myColor,
    required this.isCheck,
  });

  static GameState init() {
    return GameState(
        gameboard: initializeBoard(),
        isWhiteTurn: true,
        waitingPlayer: true,
        gameOverStatus: null,
        myColor: null,
        isCheck: false);
  }

  static GameState copyWith({required List<List<ChessPiece?>> board, required bool turn, required String? color}) {
    return GameState(
        gameboard: board,
        isWhiteTurn: turn,
        waitingPlayer: true,
        gameOverStatus: null,
        myColor: color,
        isCheck: false);
  }
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState.init());

  late StreamSubscription<dynamic> _stream;

  void resetState() {
    state = GameState.init();
  }

  void setMyColor(String? color) {
    printState('Setting my color to : $color');
    state.myColor = color;
  }

  void setLastClickedPiece(List<int> piece) {
    state.clickedPiece = piece;
  }

  void setWaitingPlayer(bool value) {
    state.waitingPlayer = value;
  }

  void setIsCheck(bool value) {
    state.isCheck = value;
  }

  // void setIsWhiteTurn(){
  //   bool turn = !state.isWhiteTurn;
  //   GameState newState = GameState.copyWith(board: state.gameboard, turn: turn, color: state.myColor);
  //   state = newState;
  // }


  void setGameOverStatus(GameOverStatus status) {
    state.gameOverStatus = status;
  }

  startStream() {
    printState("GAMESTATE: Stream Started");
    _stream = db.createStream().listen((event) {
      final json = Map<String, dynamic>.from(event[0] as Map<Object?, Object?>);
      checkPlayerJoinEvent(json);

      if (json['db_game_board'].toString().isEmpty) {
        printError('is null');
      } else {
        // bool isWhiteTurn = json['current_turn'] == state.myColor ? true : false;
        bool isWhiteTurn = json['is_white_turn'];

        // printState("JSON GAMEBOARD: ${json['db_game_board']}");
        dynamic convertedData = jsonDecode(json['db_game_board']);
        List<List<ChessPiece?>> newBoard = [];

        if (convertedData is List) {
          newBoard = List<List<ChessPiece?>>.from(convertedData.map(
                (row) => List<ChessPiece?>.from(
              row.map(
                    (piece) => piece != null
                    ? ChessPiece.fromJson(Map<String, dynamic>.from(piece))
                    : null,
              ),
            ),
          ));
        }

        // printState("convertedData: $newBoard");

        state = GameState(
            gameboard: newBoard,
            isWhiteTurn: isWhiteTurn,
            waitingPlayer: state.waitingPlayer,
            gameOverStatus: state.gameOverStatus,
            myColor: state.myColor,
            isCheck: state.isCheck);
      }
    });
  }

  void checkPlayerJoinEvent(Map<String, dynamic> json) {
    if (json['white'] != null && json['black'] != null) setWaitingPlayer(false);
  }

  closeStream() {
    printState("GAMESTATE: Stream closed!");
    _stream.cancel();
  }
}

final gameStateProvider =
StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});
