import 'package:chess_v2/src/components/piece.dart';
import 'package:flutter/material.dart';

import '../values/constants.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  const Square(
      {super.key,
      required this.isWhite,
      required this.piece,
      required this.isSelected,
      required this.isValidMove,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    } else if (isValidMove) {
      squareColor = Colors.green[300];
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        // child: piece != null ? Image.asset(piece!.imagePath, color: piece!.isWhite ? Colors.white : Colors.black) : null,
        child: piece != null
            ? Image.asset("lib/src/images/${piece?.type.name}.png",
                color: piece!.isWhite ? Colors.white : Colors.black)
            : null,
      ),
    );
  }
}
