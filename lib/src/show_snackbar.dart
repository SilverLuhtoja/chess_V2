import 'package:flutter/material.dart';

void showError(
    {required BuildContext currentContext, required String message, required bool isError}) {
  ScaffoldMessenger.of(currentContext).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: isError ? Colors.red : null,
  ));
}
