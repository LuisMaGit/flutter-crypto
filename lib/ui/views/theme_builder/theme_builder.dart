import 'package:crypto_tracker/ui/styles/kcolors.dart';
import 'package:crypto_tracker/ui/views/base_view.dart';
import 'package:crypto_tracker/ui/views/theme_builder/theme_builder_vm.dart';
import 'package:crypto_tracker/utils/enums.dart';
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
            secondaryVariant: kGrayDarker,
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
            secondaryVariant: kGray,
          );
          break;
      }

      return ThemeData(
        accentColor: primary,
        primaryColor: primary,
        textTheme: TextTheme(
            headline1: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            headline2: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            bodyText1: TextStyle(
              color: colorScheme.secondary,
              fontSize: 14,
            ),
            caption: TextStyle(
              color: colorScheme.secondaryVariant,
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
