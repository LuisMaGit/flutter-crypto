import 'package:crypto_tracker/data/crypto_data_service/crypto_data_constants.dart';
import 'package:crypto_tracker/data/crypto_data_service/crypto_data_model.dart';

typedef AnimationCallback = Future<void> Function();
typedef ScrollMoveCallback = void Function(CryptoCode c);
typedef ShowFiatDialogCallback = Future<FiatCode?> Function(FiatCode c);
typedef ShowErrorDialogCallback = Future<void> Function();


class CryptoViewData {
  List<CryptoModel> cryptoData;
  double percentage;
  String percentageStr;
  double last;
  String lastStr;

  CryptoViewData({
    required this.cryptoData,
    this.percentage = 0.0,
    this.percentageStr = '',
    this.last = 0.0,
    this.lastStr = '',
  });
}
