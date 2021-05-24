import 'package:crypto_tracker/models/crypto_model.dart';
import 'package:crypto_tracker/ui/styles/kcolors.dart';
import 'package:crypto_tracker/ui/views/main_view/main_view_models.dart';
import 'package:crypto_tracker/ui/widgets/graph.dart';
import 'package:crypto_tracker/utils/string_helpers.dart';

abstract class Binders {
  static List<Plot> getPlotsFromCryptoModel(List<CryptoModel> cryptoModel) {
    return cryptoModel.map<Plot>((c) => Plot(c.time, c.price)).toList();
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
    FiatCode.CUP: 'C'
  };

  static const fiatName = {
    FiatCode.USD: 'United States Dollar (USD)',
    FiatCode.EUR: 'Euro (EUR)',
    FiatCode.CUP: 'Cuban Peso (CUP)'
  };

  static const date = {
    TimeSpan.Day: '1D',
    TimeSpan.Week: '1W',
    TimeSpan.TwoWeeks: '2W',
    TimeSpan.Month: '1M',
    TimeSpan.Year: '1Y',
    TimeSpan.TwoYears: '2Y',
    TimeSpan.FiveYears: '5Y',
  };
}
