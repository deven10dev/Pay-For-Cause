import 'package:flutter/material.dart';

class LoadingCircleAvatar extends StatelessWidget {
  const LoadingCircleAvatar(this.char);
  final String char;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Text(
        char,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
