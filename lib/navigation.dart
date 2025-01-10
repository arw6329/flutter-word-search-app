import 'package:flutter/material.dart';

clearHistoryAndNavigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => page)
    );
}