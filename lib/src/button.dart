import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
   VoidCallback? handler;
   String text;

   MenuButton({super.key, required this.text, required this.handler});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 160, child: FilledButton(onPressed: handler, child: Text(text)));
  }
}
