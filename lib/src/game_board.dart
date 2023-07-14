import 'package:chess_v2/src/components/game_logic.dart';
import 'package:chess_v2/src/values/constants.dart';
import 'package:flutter/material.dart';

import 'components/piece.dart';
import 'components/square.dart';
import 'helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board = initializeBoard();

  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];
  bool isWhiteTurn = true;

  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  void pieceSelected(int row, int col) {
    var selectedSquare = board[row][col];
    setState(() {
      // no piece selected yet
      if (selectedSquare != null && selectedPiece == null) {
        if (selectedSquare.isWhite == isWhiteTurn) {
          selectedPiece = selectedSquare;
          selectedRow = row;
          selectedCol = col;
        }

        // there is piece selected, but user can select another one of their pieces
      } else if (selectedSquare != null && selectedSquare.isWhite == selectedPiece!.isWhite) {
        selectedPiece = selectedSquare;
        selectedRow = row;
        selectedCol = col;

        // if there is a piece selected annd user taps on a square that is valid move
      } else if (selectedPiece != null && validMoves.any((e) => e[0] == row && e[1] == col)) {
        movePiece(row, col);
      }

      // if a piece is selected, calculate its valid moves
      validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
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
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidatedMoves = calculateRawValidMoves(row, col, piece);

    // filter out all king check
    if (checkSimulation) {
      for (var move in candidatedMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidatedMoves;
    }

    return realValidMoves;
  }

  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
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

    bool kingInCheck = isKingInCheck(piece.isWhite);

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

    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    //clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Check Mate!"),
              ));
    }

    //change turns
    isWhiteTurn = !isWhiteTurn;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemy piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        var square = board[i][j];
        if (square == null || square.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, square, false);
        if (pieceValidMoves
            .any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool isCheckMate(bool isWhiteKing) {
    if (!isKingInCheck(isWhiteKing)) return false;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        var square = board[i][j];
        if (square == null || square.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, square, true);
        if (pieceValidMoves.isNotEmpty) return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(top: 100), child: Text("My Color:  Current Turn: Color")),
          Container(
              margin: const EdgeInsets.only(top: 100), child: Text(checkStatus ? "CHECK" : "")),
          Expanded(
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;

                bool isSelected = selectedRow == row && selectedCol == col;

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
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
