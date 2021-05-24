import 'package:crypto_tracker/services/crypto_data_service.dart';
import 'package:crypto_tracker/services/theme_service.dart';
import 'package:crypto_tracker/ui/views/base_vm.dart';
import 'package:crypto_tracker/ui/views/main_view/main_view_models.dart';
import 'package:crypto_tracker/utils/enums.dart';

class MainViewVM extends BaseVM {
  final _themeService = ThemeService();
  final ICryptoDataService _cryptoDataService = CryptoDataService();

  CryptoDetailsModel get detailsSelected =>
      _fullCryptoDataModel[cryptoSelected]![timeSpanSelected]![fiatSelected]!;

  CryptoDetailsModel detailsOf(CryptoCode cryptoCode) =>
      _fullCryptoDataModel[cryptoCode]![timeSpanSelected]![fiatSelected]!;

  CryptoCode cryptoSelected = CryptoCode.BTC;
  TimeSpan timeSpanSelected = TimeSpan.Day;
  FiatCode fiatSelected = FiatCode.USD;

  late Map<CryptoCode, Map<TimeSpan, Map<FiatCode, CryptoDetailsModel>>>
      _fullCryptoDataModel;
  late Map<TimeSpan, DateModel> _datesByTimeSpan;
  late AnimationCallback _startAnimation;
  late AnimationCallback _reverseAnimation;
  late ScrollMoveCallback _scrollMoveTo;
  late ShowFiatDialogCallback _showFiatDialog;
  late ShowErrorDialogCallback _showErrorDialog;

  void _setDatesByTimeSpan() {
    _datesByTimeSpan = {};
    final nowDateTime = DateTime.now();
    final now = nowDateTime.toUtc().toIso8601String();

    String substractDateFromNow(Duration duration) =>
        nowDateTime.subtract(duration).toUtc().toIso8601String();

    void addDate(TimeSpan date, int days) {
      _datesByTimeSpan.addAll(
          {date: DateModel(substractDateFromNow(Duration(days: days)), now)});
    }

    TimeSpan.values.forEach((date) {
      switch (date) {
        case TimeSpan.Day:
          addDate(date, 1);
          break;
        case TimeSpan.Week:
          addDate(date, 7);
          break;
        case TimeSpan.TwoWeeks:
          addDate(date, 14);
          break;
        case TimeSpan.Month:
          addDate(date, 30);
          break;
        case TimeSpan.Year:
          addDate(date, 365);
          break;
        case TimeSpan.TwoYears:
          addDate(date, 730);
          break;
        case TimeSpan.FiveYears:
          addDate(date, 1825);
          break;
        default:
      }
    });
  }

  Future<void> _fetchData() async {
    final notError = await _cryptoDataService.getData(
      _datesByTimeSpan[timeSpanSelected]!.firstDate,
      _datesByTimeSpan[timeSpanSelected]!.secondDate,
      strCryptoCodeSelected,
      strFiatCodeSelected,
    );

    if (notError) {
      setDataCryptoSelected();
      setState = ViewState.Iddle;
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
      setState = ViewState.Bussy;
      List<Future<void>> futures = [
        _reverseAnimation(),
        _fetchData(),
      ];
      await Future.wait(futures);
      return;
    }

    await _reverseAnimation();
    _startAnimation();
    setState = ViewState.Iddle;
  }

  Future<void> initMainViewVM({
    required AnimationCallback startAnimation,
    required AnimationCallback reverseAnimation,
    required ScrollMoveCallback scrollMoveTo,
    required ShowFiatDialogCallback showFiatDialog,
    required ShowErrorDialogCallback showErrorDialog
  }) async {
    _startAnimation = startAnimation;
    _reverseAnimation = reverseAnimation;
    _scrollMoveTo = scrollMoveTo;
    _showFiatDialog = showFiatDialog;
    _showErrorDialog = showErrorDialog;

    _setDatesByTimeSpan();

    _fullCryptoDataModel = {};
    for (final code in CryptoCode.values) {
      Map<TimeSpan, Map<FiatCode, CryptoDetailsModel>> timeMap = {};
      for (var time in TimeSpan.values) {
        Map<FiatCode, CryptoDetailsModel> fiatMap = {};
        for (var fiat in FiatCode.values) {
          fiatMap.addAll({fiat: CryptoDetailsModel(cryptoData: [])});
        }
        timeMap.addAll({time: fiatMap});
      }
      _fullCryptoDataModel.addAll({code: timeMap});
    }

    await _fetchData();
  }

  void changeTheme() => _themeService.switchTheme();

  void setDataCryptoSelected() {
    final last = _cryptoDataService.data.last.price;
    final lastStr = last.toStringAsFixed(3);
    final first = _cryptoDataService.data.first.price;
    final percentage = (last / first) * (first > last ? -1 : 1);
    final percentageStr = percentage.toStringAsFixed(3);

    _fullCryptoDataModel[cryptoSelected]![timeSpanSelected]![fiatSelected]!
      ..last = last
      ..lastStr = lastStr
      ..percentage = percentage
      ..percentageStr = percentageStr
      ..cryptoData.addAll(_cryptoDataService.data);
  }

  String get strCryptoCodeSelected => strCodeOf(cryptoSelected);
  String get strFiatCodeSelected => fiatSelected.toString().split('.')[1];

  String strCodeOf(CryptoCode cryptoCode) {
    return cryptoCode.toString().split('.')[1];
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
