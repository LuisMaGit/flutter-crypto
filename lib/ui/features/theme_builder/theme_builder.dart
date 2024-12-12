import 'package:crypto_tracker/data/theme_service.dart';
import 'package:crypto_tracker/ui/ui_constants/kcolors.dart';
import 'package:crypto_tracker/ui/features/base_view/base_view.dart';
import 'package:crypto_tracker/ui/features/theme_builder/theme_builder_vm.dart';
import 'package:flutter/material.dart';

class ThemeBuilder extends StatefulWidget {
  final Widget Function(ThemeData theme) builder;

  const ThemeBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  _ThemeBuilderState createState() => _ThemeBuilderState();
}

class _ThemeBuilderState extends State<ThemeBuilder> {
  final model = ThemeBuilderVM();

  @override
  Widget build(BuildContext context) {
    ThemeData _getTheme(ThemeModeCrypto mode) {
      late Color primary;
      late Color canvasColor;
      late ColorScheme colorScheme;

      switch (mode) {
        case ThemeModeCrypto.Light:
          canvasColor = kWhiteDarker;
          primary = kBlackDarker;
          colorScheme = ColorScheme.light(
            primary: primary,
            background: kWhiteDarker,
            onBackground: kWhite,
            secondary: kBlack,
            onSecondary: kBlackDarker,
            tertiary: kGrayDarker,
          );
          break;

        case ThemeModeCrypto.Dark:
          canvasColor = kBlackDarker;
          primary = kWhiteDarker;
          colorScheme = ColorScheme.dark(
            primary: primary,
            background: kBlackDarker,
            onBackground: kBlack,
            secondary: kWhite,
            onSecondary: kWhiteDarker,
            tertiary: kGray,
          );
          break;
      }

      return ThemeData(
        primaryColor: primary,
        textTheme: TextTheme(
            headlineLarge: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            headlineMedium: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            bodyLarge: TextStyle(
              color: colorScheme.secondary,
              fontSize: 14,
            ),
            bodySmall: TextStyle(
              color: colorScheme.tertiary,
              fontSize: 12,
            )),
        canvasColor: canvasColor,
        colorScheme: colorScheme,
      );
    }

    return BaseViewBuilder(
        viewModel: model,
        builder: (context) => widget.builder(_getTheme(model.themeMode)));
  }
}
