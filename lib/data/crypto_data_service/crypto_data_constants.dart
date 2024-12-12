enum TimeSpan {
  Day,
  Week,
  TwoWeeks,
  Month,
  Year,
}

enum CryptoCode {
  BTC(uiCode: 'BTC', apiCode: 'bitcoin'),
  ETH(uiCode: 'ETH', apiCode: 'ethereum'),
  XRP(uiCode: 'XRP', apiCode: 'ripple'),
  XMR(uiCode: 'XMR', apiCode: 'monero'),
  DASH(uiCode: 'DASH', apiCode: 'dash'),
  USDT(uiCode: 'USDT', apiCode: 'tether'),
  DOGE(uiCode: 'DOGE', apiCode: 'dogecoin'),
  LTC(uiCode: 'LTC', apiCode: 'litecoin'),
  ADA(uiCode: 'ADA', apiCode: 'cardano');

  const CryptoCode({
    required this.uiCode,
    required this.apiCode,
  });

  final String uiCode;
  final String apiCode;
}

enum FiatCode {
  USD(uiCode: 'USD', apiCode: 'usd'),
  EUR(uiCode: 'EUR', apiCode: 'eur'),
  CAD(uiCode: 'CAD', apiCode: 'cad');

  const FiatCode({
    required this.uiCode,
    required this.apiCode,
  });

  final String uiCode;
  final String apiCode;
}
