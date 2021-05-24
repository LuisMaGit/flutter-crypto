import 'dart:convert';
import 'dart:io';

import 'package:crypto_tracker/models/crypto_model.dart';
import 'package:crypto_tracker/utils/string_helpers.dart';

abstract class ICryptoDataService {
  List<CryptoModel> data = [];

  Future<bool> getData(
      String firstDate, String lastDate, String currency, String fiat);
}

class FakeCryptoDataService extends ICryptoDataService {
  @override
  Future<bool> getData(
      String firstDate, String lastDate, String currency, String fiat) async {
    await Future.delayed(Duration(seconds: 5));
    data = [
      CryptoModel(time: '1', price: 5000),
      CryptoModel(time: '1', price: 5010),
      CryptoModel(time: '1', price: 5020),
      CryptoModel(time: '1', price: 4920),
      CryptoModel(time: '1', price: 5050),
      CryptoModel(time: '1', price: 5030),
      CryptoModel(time: '1', price: 5053),
      CryptoModel(time: '1', price: 5200),
      CryptoModel(time: '1', price: 5023),
      CryptoModel(time: '1', price: 4980),
      CryptoModel(time: '1', price: 4820),
      CryptoModel(time: '1', price: 5130),
      CryptoModel(time: '1', price: 4840),
      CryptoModel(time: '1', price: 5100),
      CryptoModel(time: '1', price: 5200),
      CryptoModel(time: '1', price: 5000),
      CryptoModel(time: '1', price: 5010),
      CryptoModel(time: '1', price: 5020),
    ];
    return true;
  }
}

class CryptoDataService extends ICryptoDataService {
  set _setCryptoResponseData(String source) {
    final response = CryptoResponseModel.fromJson(source);
    data = response.cryptoData;
  }

  @override
  Future<bool> getData(
    String firstDate,
    String lastDate,
    String currency,
    String fiat,
  ) async {
    final queryParameters = {
      'key': StrApi.nmonicsKey,
      'ids': currency,
      'start': firstDate,
      'end': lastDate,
      'convert': fiat,
    };

    final uri = Uri.https(StrApi.url, StrApi.endpoint, queryParameters);
    try {
      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        _setCryptoResponseData = responseBody;
        return true;
      }
      return false;
    } on Exception {
      return false;
    }
  }
}
