import 'package:crypto_tracker/data/crypto_data_service/crypto_data_constants.dart';
import 'package:crypto_tracker/data/crypto_data_service/crypto_data_model.dart';
import 'package:crypto_tracker/data/crypto_data_service/crypto_data_service.dart';
import 'package:crypto_tracker/data/theme_service.dart';
import 'package:crypto_tracker/ui/features/base_view/base_view_state.dart';
import 'package:crypto_tracker/ui/features/base_view/base_vm.dart';
import 'package:crypto_tracker/ui/features/main_view/main_view_data.dart';

class MainViewVM extends BaseVM {
  final _themeService = ThemeService();
  final _cryptoDataService = CryptoDataService();

  CryptoViewData get detailsSelected =>
      _fullCryptoDataModel[cryptoSelected]![timeSpanSelected]![fiatSelected]!;

  CryptoViewData detailsOf(CryptoCode cryptoCode) =>
      _fullCryptoDataModel[cryptoCode]![timeSpanSelected]![fiatSelected]!;

  CryptoCode cryptoSelected = CryptoCode.BTC;
  TimeSpan timeSpanSelected = TimeSpan.Day;
  FiatCode fiatSelected = FiatCode.USD;

  late Map<CryptoCode, Map<TimeSpan, Map<FiatCode, CryptoViewData>>>
      _fullCryptoDataModel;
  late AnimationCallback _startAnimation;
  late AnimationCallback _reverseAnimation;
  late ScrollMoveCallback _scrollMoveTo;
  late ShowFiatDialogCallback _showFiatDialog;
  late ShowErrorDialogCallback _showErrorDialog;

  void _setDataCryptoSelected(List<CryptoModel> data) {
    final last = data.last.price;
    final lastStr = last.toStringAsFixed(3);
    final first = data.first.price;
    final percentage = (last / first) * (first > last ? -1 : 1);
    final percentageStr = percentage.toStringAsFixed(3);

    _fullCryptoDataModel[cryptoSelected]![timeSpanSelected]![fiatSelected]!
      ..last = last
      ..lastStr = lastStr
      ..percentage = percentage
      ..percentageStr = percentageStr
      ..cryptoData.addAll(data);
  }

  Future<void> _fetchData() async {
    final data = await _cryptoDataService.getCryptoData(
      timeSpan: timeSpanSelected,
      cryptoCode: cryptoSelected,
      fiatCode: fiatSelected,
    );

    if (data != null) {
      _setDataCryptoSelected(data);
      setState = BaseViewState.Iddle;
      _startAnimation();
      return;
    }

    await _showErrorDialog();
    _fetchData();
  }

  Future<void> _handleChange() async {
    if (_fullCryptoDataModel[cryptoSelected]![timeSpanSelected]![fiatSelected]!
        .cryptoData
        .isEmpty) {
      setState = BaseViewState.Bussy;
      List<Future<void>> futures = [
        _reverseAnimation(),
        _fetchData(),
      ];
      await Future.wait(futures);
      return;
    }

    await _reverseAnimation();
    _startAnimation();
    setState = BaseViewState.Iddle;
  }

  Future<void> initMainViewVM(
      {required AnimationCallback startAnimation,
      required AnimationCallback reverseAnimation,
      required ScrollMoveCallback scrollMoveTo,
      required ShowFiatDialogCallback showFiatDialog,
      required ShowErrorDialogCallback showErrorDialog}) async {
    _startAnimation = startAnimation;
    _reverseAnimation = reverseAnimation;
    _scrollMoveTo = scrollMoveTo;
    _showFiatDialog = showFiatDialog;
    _showErrorDialog = showErrorDialog;
    _fullCryptoDataModel = {};
    for (final code in CryptoCode.values) {
      Map<TimeSpan, Map<FiatCode, CryptoViewData>> timeMap = {};
      for (var time in TimeSpan.values) {
        Map<FiatCode, CryptoViewData> fiatMap = {};
        for (var fiat in FiatCode.values) {
          fiatMap.addAll({fiat: CryptoViewData(cryptoData: [])});
        }
        timeMap.addAll({time: fiatMap});
      }
      _fullCryptoDataModel.addAll({code: timeMap});
    }

    await _fetchData();
  }

  void changeTheme() {
    _themeService.switchTheme();
  }

  Future<void> changeDate(TimeSpan t) async {
    if (t == timeSpanSelected) return;

    timeSpanSelected = t;

    await _handleChange();
  }

  Future<void> changeCrypto(CryptoCode c) async {
    if (c == cryptoSelected) return;
    cryptoSelected = c;
    await _handleChange();
  }

  Future<void> changeCryptoByTap(CryptoCode c) async {
    _scrollMoveTo(c);
    await changeCrypto(c);
  }

  Future<void> openFiatDialog() async {
    final fiat = await _showFiatDialog(fiatSelected);

    if (fiat == null || fiat == fiatSelected) return;

    fiatSelected = fiat;
    await _handleChange();
  }
}
