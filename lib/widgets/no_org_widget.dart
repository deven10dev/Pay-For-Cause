import 'package:flutter/material.dart';

class NoOrgWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_very_dissatisfied,
              size: 70,
            ),
            SizedBox(height: 10),
            Text(
              'Sorry, but there doesn\'t seems to be any NGOs around you!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}
