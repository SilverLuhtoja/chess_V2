import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool isWhite(int index){
  int x = index ~/ 8;
  int y = index % 8;

  return (x + y) % 2 == 0;
}

bool isInBoard(int row, int col){
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}

navigateTo(BuildContext context, StatefulWidget screen) => Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => screen),
);

// Black:   \x1B[30m
// Red:     \x1B[31m
// Green:   \x1B[32m
// Yellow:  \x1B[33m
// Blue:    \x1B[34m
// Magenta: \x1B[35m
// Cyan:    \x1B[36m
// White:   \x1B[37m
// Reset:   \x1B[0m

void printState(dynamic text) {
  print('\x1B[35m$text\x1B[0m');
}

void printDB(dynamic text) {
  print('\x1B[34m$text\x1B[0m');
}

void printGreen(dynamic text) {
  print('\x1B[32m$text\x1B[0m');
}

void printWarning(dynamic text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(dynamic text) {
  print('\x1B[31m$text\x1B[0m');
}