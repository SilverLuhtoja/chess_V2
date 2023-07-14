import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/piece.dart';

class PieceState {
  List<int> clickedSquare = [-1, -1];
  List<List<int>> validMoves = [];
  ChessPiece? selectedPiece;

  PieceState({required this.clickedSquare, required this.validMoves, required this.selectedPiece});

  static PieceState init(){
    return PieceState(clickedSquare: [-1, -1], validMoves: [], selectedPiece: null);
  }
}

class PieceStateNotifier extends StateNotifier<PieceState> {
  PieceStateNotifier() : super(PieceState.init()); // init GameState in super for StateNotifierProvider

  void setClickedPiece(List<int> square, ChessPiece? piece) {
    state = PieceState(clickedSquare: square, validMoves: [], selectedPiece: piece);
    // state.clickedPiece = piece;
  }

  void setValidMoves(List<List<int>> moves){
    state = PieceState(clickedSquare: state.clickedSquare, validMoves: moves, selectedPiece: state.selectedPiece);
  }

  void clearPieceState(){
    state = PieceState.init();
  }
}

final pieceStateProvider = StateNotifierProvider<PieceStateNotifier, PieceState>((ref) {
  return PieceStateNotifier();
});
