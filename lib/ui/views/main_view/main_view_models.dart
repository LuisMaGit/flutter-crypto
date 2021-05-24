import 'package:crypto_tracker/models/crypto_model.dart';

typedef AnimationCallback = Future<void> Function();
typedef ScrollMoveCallback = void Function(CryptoCode c);
typedef ShowFiatDialogCallback = Future<FiatCode?> Function(FiatCode c);
typedef ShowErrorDialogCallback = Future<void> Function();

enum TimeSpan {
  Day,
  Week,
  TwoWeeks,
  Month,
  Year,
  TwoYears,
  FiveYears,
}

enum CryptoCode {
  BTC,
  XRP,
  XMR,
  DASH,
  USDT,
  DOGE,
  LTC,
  ADA,
  ETH,
}

enum FiatCode { USD, EUR, CUP }

class DateModel {
  final String firstDate;
  final String secondDate;

  const DateModel(this.firstDate, this.secondDate);
}

class CryptoDetailsModel {
  List<CryptoModel> cryptoData;
  double percentage;
  String percentageStr;
  double last;
  String lastStr;

  CryptoDetailsModel({
    required this.cryptoData,
    this.percentage = 0.0,
    this.percentageStr = '',
    this.last = 0.0,
    this.lastStr = '',
  });
}
