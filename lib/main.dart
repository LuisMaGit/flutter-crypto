import 'package:crypto_tracker/ui/views/theme_builder/theme_builder.dart';
import 'package:crypto_tracker/ui/views/main_view/main_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CryptoTracker());
}

class CryptoTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (theme) {
        return MaterialApp(
            title: 'CryptoTracker',
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: MainView());
      },
    );
  }
}
