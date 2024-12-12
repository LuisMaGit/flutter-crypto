import 'package:crypto_tracker/data/crypto_data_service/crypto_data_constants.dart';
import 'package:crypto_tracker/data/crypto_data_service/crypto_data_model.dart';
import 'package:crypto_tracker/ui/ui_constants/assets.dart';
import 'package:crypto_tracker/ui/ui_constants/kcolors.dart';
import 'package:crypto_tracker/ui/widgets/graph.dart';

abstract class UIHelper {
  static List<Plot> getPlotsFromCryptoModel(List<CryptoModel> cryptoModel) {
    return cryptoModel.map<Plot>((c) => Plot(c.prettyTime, c.price)).toList();
  }

  static const cryptoName = {
    CryptoCode.BTC: 'Bitcoin',
    CryptoCode.ETH: 'Ethereum',
    CryptoCode.LTC: 'Litecoin',
    CryptoCode.DOGE: 'Doge',
    CryptoCode.ADA: 'Cardano',
    CryptoCode.XMR: 'Monero',
    CryptoCode.DASH: 'Dash',
    CryptoCode.XRP: 'Ripple',
    CryptoCode.USDT: 'Tether',
  };

  static const cyrptoColor = {
    CryptoCode.BTC: kColorBtc,
    CryptoCode.ETH: kColorEth,
    CryptoCode.LTC: kColorLtc,
    CryptoCode.DOGE: kColorDoge,
    CryptoCode.ADA: kColorAda,
    CryptoCode.XMR: kColorXmr,
    CryptoCode.DASH: kColorDash,
    CryptoCode.XRP: kColorXrp,
    CryptoCode.USDT: kColorUsdt,
  };

  static const cryptoPic = {
    CryptoCode.BTC: Assets.btc,
    CryptoCode.ETH: Assets.eth,
    CryptoCode.LTC: Assets.ltc,
    CryptoCode.DOGE: Assets.doge,
    CryptoCode.ADA: Assets.ada,
    CryptoCode.XMR: Assets.xmr,
    CryptoCode.DASH: Assets.dash,
    CryptoCode.XRP: Assets.xrp,
    CryptoCode.USDT: Assets.usdt,
  };

  static const fiat = {
    FiatCode.USD: '\$',
    FiatCode.EUR: '€',
    FiatCode.CAD: 'C\$'
  };

  static const fiatName = {
    FiatCode.USD: 'United States Dollar (USD)',
    FiatCode.EUR: 'Euro (EUR)',
    FiatCode.CAD: 'Canadian Dollar (CAD)'
  };

  static const date = {
    TimeSpan.Day: '1D',
    TimeSpan.Week: '1W',
    TimeSpan.TwoWeeks: '2W',
    TimeSpan.Month: '1M',
    TimeSpan.Year: '1Y',
  };
}
