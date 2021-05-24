import 'package:crypto_tracker/services/theme_service.dart';
import 'package:crypto_tracker/ui/views/base_vm.dart';
import 'package:crypto_tracker/utils/enums.dart';

class ThemeBuilderVM extends BaseVM {
  final _themeService = ThemeService();
  final bool listenable = false;
  late ThemeModeCrypto themeMode;

  ThemeBuilderVM() {
    initTheme();
  }

  void initTheme() {
    themeMode = _themeService.themeMode;

    Stream stream = _themeService.themeController.stream;
    stream.listen((value) {
      _swichTheme(value);
    });
  }

  void _swichTheme(ThemeModeCrypto value) {
    themeMode = value;
    notifyListeners();
  }
}
