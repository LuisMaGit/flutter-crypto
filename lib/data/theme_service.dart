import 'dart:async';

class ThemeService {
  factory ThemeService() {
    return _instance;
  }
  ThemeService._privateConstructor();
  static final ThemeService _instance = ThemeService._privateConstructor();

  late StreamController<ThemeModeCrypto> themeController =
      StreamController<ThemeModeCrypto>.broadcast();
  ThemeModeCrypto _themeMode = ThemeModeCrypto.Dark;
  ThemeModeCrypto get themeMode => _themeMode;

  void _setThemeMode() {
    _themeMode = _themeMode == ThemeModeCrypto.Light
        ? ThemeModeCrypto.Dark
        : ThemeModeCrypto.Light;
  }

  void switchTheme() {
    _setThemeMode();
    themeController.add(_themeMode);
  }

  void dispose() {
    themeController.close();
  }
}

enum ThemeModeCrypto {
  Dark,
  Light,
}
