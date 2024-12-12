abstract class CryptoDataApiContracts {
  //coingecko API KEY
  static const apiKey = 'YOUR_API_KEY_HERE';
  static const nameApiKey = 'x-cg-demo-api-key';

  static const url = 'api.coingecko.com';
  static String endpoint(String crypto) =>
      '/api/v3/coins/$crypto/market_chart/range';
  

  static Map<String, String> queryParameters({
    required String fiat,
    required String from,
    required String to,
  }) {
    return {
      'vs_currency': fiat,
      'from': from,
      'to': to,
    };
  }
}


