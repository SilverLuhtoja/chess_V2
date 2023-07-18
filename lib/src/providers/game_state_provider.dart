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
  late List<String> moveHistory;

  GameState({
    required this.gameboard,
    required this.isWhiteTurn,
    required this.waitingPlayer,
    required this.gameOverStatus,
    required this.myColor,
    required this.isCheck,
    required this.moveHistory,
  });

  static GameState init() {
    return GameState(
        gameboard: initializeBoard(),
        isWhiteTurn: true,
        waitingPlayer: true,
        gameOverStatus: null,
        myColor: null,
        isCheck: false,
        moveHistory: []);
  }

  static GameState copyWith(
      {required List<List<ChessPiece?>> board, required bool turn, required String? color, required List<String> history}) {
    return GameState(
        gameboard: board,
        isWhiteTurn: turn,
        waitingPlayer: true,
        gameOverStatus: null,
        myColor: color,
        isCheck: false,
        moveHistory: history);
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

  void setWaitingPlayer(bool value) {
    state.waitingPlayer = value;
  }

  void setIsCheck(bool value) {
    state.isCheck = value;
  }

  void setGameOverStatus(GameOverStatus status) {
    state.gameOverStatus = status;
  }

  startStream() {
    printState("GAMESTATE: Stream Started");
    _stream = db.createStream().listen((event) {
      final json = Map<String, dynamic>.from(event[0] as Map<Object?, Object?>);
      checkPlayerJoinEvent(json);
      updateGameOverStatus(json);

      if (json['db_game_board'].toString().isEmpty) {
        printError('is null');
      } else {
        bool isWhiteTurn = json['is_white_turn'];

        dynamic conversionBoardData = jsonDecode(json['db_game_board']);
        List<List<ChessPiece?>> newBoard = [];

        if (conversionBoardData is List) {
          newBoard = List<List<ChessPiece?>>.from(conversionBoardData.map(
            (row) => List<ChessPiece?>.from(
              row.map(
                (piece) =>
                    piece != null ? ChessPiece.fromJson(Map<String, dynamic>.from(piece)) : null,
              ),
            ),
          ));
        }

        dynamic conversionHistory = jsonDecode(json['move_history']);
        List<String> moveHistory = List<String>.from(conversionHistory);

        bool isMyTurn = state.myColor == (isWhiteTurn == true ? 'white' : 'black');
        bool isKingChecked = false;
        if (isMyTurn && isKingInCheck(isWhiteTurn, newBoard)) isKingChecked = true;

        state = GameState(
          gameboard: newBoard,
          isWhiteTurn: isWhiteTurn,
          waitingPlayer: state.waitingPlayer,
          gameOverStatus: state.gameOverStatus,
          myColor: state.myColor,
          isCheck: isKingChecked,
          moveHistory: moveHistory,
        );
      }
    });
  }

  void checkPlayerJoinEvent(Map<String, dynamic> json) {
    if (json['white'] != null && json['black'] != null) setWaitingPlayer(false);
  }

  void updateGameOverStatus(Map<String, dynamic> json) {
    if (state.waitingPlayer == true) return;

    if (json['winner'] != null) {
      json['winner'] == state.myColor
          ? setGameOverStatus(GameOverStatus.won)
          : setGameOverStatus(GameOverStatus.lost);
      return;
    }
    if (json['white'] == null || json['black'] == null) {
      setGameOverStatus(GameOverStatus.surrendered);
      return;
    }
  }

  closeStream() {
    printState("GAMESTATE: Stream closed!");
    _stream.cancel();
  }
}

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});
