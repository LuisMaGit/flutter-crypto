abstract class StrApi {
  //nomics API KEY
  static const nmonicsKey = 'YOUR_API_KEY_HERE';
  //nomics API KEY
  static const url = 'api.nomics.com';
  static const endpoint = '/v1/currencies/sparkline';
}

abstract class Assets{
  static const _base = 'assets/crypto_logos/';
  static const btc = '${_base}BTC.png';
  static const doge = '${_base}DOGE.png';
  static const eth = '${_base}ETH.png';
  static const ltc = '${_base}LTC.png';
  static const ada = '${_base}ADA.png';
  static const xmr = '${_base}XMR.png';
  static const dash = '${_base}DASH.png';
  static const xrp = '${_base}XRP.png';
  static const usdt = '${_base}USDT.png';
}