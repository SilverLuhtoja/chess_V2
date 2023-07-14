import 'package:chess_v2/src/components/piece.dart';

import '../helper/helper_methods.dart';

List<List<ChessPiece?>> initializeBoard() {
  List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8, (index) => null));

  // pawns
  for (int i = 0; i < 8; i++) {
    newBoard[1][i] = ChessPiece(
      type: ChessPieceType.pawn,
      isWhite: false,
    );
    newBoard[6][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: true);
  }

  //rooks
  newBoard[0][0] = ChessPiece(type: ChessPieceType.rook, isWhite: false);
  newBoard[0][7] = ChessPiece(type: ChessPieceType.rook, isWhite: false);
  newBoard[7][0] = ChessPiece(type: ChessPieceType.rook, isWhite: true);
  newBoard[7][7] = ChessPiece(type: ChessPieceType.rook, isWhite: true);

  //bishops
  newBoard[0][1] = ChessPiece(type: ChessPieceType.knight, isWhite: false);
  newBoard[0][6] = ChessPiece(type: ChessPieceType.knight, isWhite: false);
  newBoard[7][1] = ChessPiece(type: ChessPieceType.knight, isWhite: true);
  newBoard[7][6] = ChessPiece(type: ChessPieceType.knight, isWhite: true);

  //knights
  newBoard[0][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: false);
  newBoard[0][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: false);
  newBoard[7][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: true);
  newBoard[7][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: true);

  //queens
  newBoard[0][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false);
  newBoard[7][3] = ChessPiece(type: ChessPieceType.queen, isWhite: true);

  //kings
  newBoard[0][4] = ChessPiece(type: ChessPieceType.king, isWhite: false);
  newBoard[7][4] = ChessPiece(type: ChessPieceType.king, isWhite: true);

  return newBoard;
}

List<List<int>> calculateRawValidMoves(
    int row, int col, ChessPiece? piece, List<List<ChessPiece?>> board) {
  List<List<int>> candidateMoves = [];

  if (piece == null) return [];
  int direction = piece.isWhite ? -1 : 1;

  switch (piece.type) {
    case ChessPieceType.pawn:
      if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
        candidateMoves.add([row + direction, col]);
      }
      if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
        if (isInBoard(row + 2 * direction, col) && board[row + 2 * direction][col] == null) {
          candidateMoves.add([row + 2 * direction, col]);
        }
      }

      if (isInBoard(row + direction, col - 1) &&
          board[row + direction][col - 1] != null &&
          board[row + direction][col - 1]!.isWhite != piece.isWhite) {
        candidateMoves.add([row + direction, col - 1]);
      }

      if (isInBoard(row + direction, col + 1) &&
          board[row + direction][col + 1] != null &&
          board[row + direction][col + 1]!.isWhite != piece.isWhite) {
        candidateMoves.add([row + direction, col + 1]);
      }

      break;
    case ChessPieceType.rook:
      //horizontal and verticals directions
      var directions = [
        [-1, 0], //up
        [1, 0], //down
        [0, -1], //left
        [0, 1], //right
      ];

      for (var dir in directions) {
        var i = 1;
        while (true) {
          var newRow = row + i * dir[0];
          var newCol = col + i * dir[1];

          if (!isInBoard(newRow, newCol)) break;

          var newSquare = board[newRow][newCol];
          if (newSquare != null) {
            if (newSquare.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            break;
          }
          candidateMoves.add([newRow, newCol]);
          i++;
        }
      }
      break;
    case ChessPieceType.knight:
      var directions = [
        [-2, -1],
        [-2, 1],
        [-1, -2],
        [-1, 2],
        [1, -2],
        [1, 2],
        [2, -1],
        [2, 1],
      ];

      for (var dir in directions) {
        var newRow = row + dir[0];
        var newCol = col + dir[1];

        if (!isInBoard(newRow, newCol)) continue;

        var newSquare = board[newRow][newCol];
        if (newSquare != null) {
          if (newSquare.isWhite != piece.isWhite) {
            candidateMoves.add([newRow, newCol]);
          }
          continue;
        }

        candidateMoves.add([newRow, newCol]);
      }
      break;
    case ChessPieceType.bishop:
      //horizontal and verticals directions
      var directions = [
        [-1, -1], //up-left
        [1, -1], //down-left
        [-1, 1], //up-right
        [1, 1], //down-right
      ];

      for (var dir in directions) {
        var i = 1;
        while (true) {
          var newRow = row + i * dir[0];
          var newCol = col + i * dir[1];

          if (!isInBoard(newRow, newCol)) break;

          var newSquare = board[newRow][newCol];
          if (newSquare != null) {
            if (newSquare.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            break;
          }
          candidateMoves.add([newRow, newCol]);
          i++;
        }
      }
      break;
    case ChessPieceType.queen:
      var directions = [
        [-1, 0], //up
        [1, 0], //down
        [0, -1], //left
        [0, 1], //right
        [-1, -1], //up-left
        [1, -1], //down-left
        [-1, 1], //up-right
        [1, 1], //down-right
      ];

      for (var dir in directions) {
        var i = 1;
        while (true) {
          var newRow = row + i * dir[0];
          var newCol = col + i * dir[1];

          if (!isInBoard(newRow, newCol)) break;

          var newSquare = board[newRow][newCol];
          if (newSquare != null) {
            if (newSquare.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            break;
          }
          candidateMoves.add([newRow, newCol]);
          i++;
        }
      }
      break;
    case ChessPieceType.king:
      var directions = [
        [-1, 0], //up
        [1, 0], //down
        [0, -1], //left
        [0, 1], //right
        [-1, -1], //up-left
        [1, -1], //down-left
        [-1, 1], //up-right
        [1, 1], //down-right
      ];

      for (var dir in directions) {
        var newRow = row + dir[0];
        var newCol = col + dir[1];

        if (!isInBoard(newRow, newCol)) continue;

        var newSquare = board[newRow][newCol];
        if (newSquare != null) {
          if (newSquare.isWhite != piece.isWhite) {
            candidateMoves.add([newRow, newCol]);
          }
          continue;
        }
        candidateMoves.add([newRow, newCol]);
      }
      break;
    default:
  }

  return candidateMoves;
}

List<List<int>> calculateRealValidMoves(
    int row, int col, ChessPiece? piece, bool checkSimulation, List<List<ChessPiece?>> board) {
  List<List<int>> realValidMoves = [];
  List<List<int>> candidatedMoves = calculateRawValidMoves(row, col, piece,board);

  // filter out all king check
  if (checkSimulation) {
    for (var move in candidatedMoves) {
      int endRow = move[0];
      int endCol = move[1];
      if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol, board)) {
        realValidMoves.add(move);
      }
    }
  } else {
    realValidMoves = candidatedMoves;
  }

  return realValidMoves;
}


bool isKingInCheck(bool isWhiteKing, List<List<ChessPiece?>> board) {
  List<int> whiteKingPosition = getKingPosition(isWhiteKing, board);
  List<int> blackKingPosition = getKingPosition(!isWhiteKing, board);
  List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;



  // check if any enemy piece can attack the king
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 8; j++) {
      var square = board[i][j];
      if (square == null || square.isWhite == isWhiteKing) {
        continue;
      }

      List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, square, false, board);
      if (pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
        return true;
      }
    }
  }
  return false;
}

bool isCheckMate(bool isWhiteKing, List<List<ChessPiece?>> board) {
  if (!isKingInCheck(isWhiteKing,board)) return false;

  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 8; j++) {
      var square = board[i][j];
      if (square == null || square.isWhite != isWhiteKing) {
        continue;
      }

      List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, square, true, board);
      if (pieceValidMoves.isNotEmpty) return false;
    }
  }
  return true;
}

bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol,
    List<List<ChessPiece?>> board) {
  List<int> whiteKingPosition = getKingPosition(piece.isWhite, board);
  List<int> blackKingPosition = getKingPosition(!piece.isWhite, board);
  ChessPiece? originalDestinationPiece = board[endRow][endCol];

  List<int>? originalKingPosition;
  if (piece.type == ChessPieceType.king) {
    originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;
    if (piece.isWhite) {
      whiteKingPosition = [endRow, endCol];
    } else {
      blackKingPosition = [endRow, endCol];
    }
  }

  board[endRow][endCol] = piece;
  board[startRow][startCol] = null;

  bool kingInCheck = isKingInCheck(piece.isWhite, board);

  board[startRow][startCol] = piece;
  board[endRow][endCol] = originalDestinationPiece;

  // if piece was king, restore spot
  if (piece.type == ChessPieceType.king) {
    if (piece.isWhite) {
      whiteKingPosition = originalKingPosition!;
    } else {
      blackKingPosition = originalKingPosition!;
    }
  }

  return !kingInCheck; //if king check == true, then its not safe
}

List<int> getKingPosition(bool isWhiteKing, List<List<ChessPiece?>> board) {
  List<int> kingPos = [];
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 8; j++) {
      var square = board[i][j];
      if (square != null && square.isWhite == isWhiteKing && square.type == ChessPieceType.king) {
        kingPos = [i, j];
      }
      if (square != null && square.isWhite != isWhiteKing && square.type == ChessPieceType.king) {
        kingPos = [i, j];
      }
    }
  }
  return kingPos;
}
