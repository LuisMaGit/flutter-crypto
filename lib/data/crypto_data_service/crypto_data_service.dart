import 'dart:convert';
import 'dart:io';

import 'package:crypto_tracker/data/crypto_data_service/crypto_data_api_contracts.dart';
import 'package:crypto_tracker/data/crypto_data_service/crypto_data_constants.dart';
import 'package:crypto_tracker/data/crypto_data_service/crypto_data_model.dart';

class CryptoDataService {
  (String from, String to) _dateRangeRequestBasedOnTimeSpan(TimeSpan span) {
    final now = DateTime.now().toLocal();
    switch (span) {
      case TimeSpan.Day:
        final nowOnlyDateAndHour = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
        );
        final startDateTime = nowOnlyDateAndHour.subtract(Duration(hours: 24));
        final from = startDateTime.millisecondsSinceEpoch ~/ 1000;
        final to = nowOnlyDateAndHour.millisecondsSinceEpoch ~/ 1000;
        return (
          from.toString(),
          to.toString(),
        );
      case TimeSpan.Week:
        final nowOnlyDate = DateTime(now.year, now.month, now.day);
        final start = nowOnlyDate.subtract(Duration(days: 7));
        final from = start.millisecondsSinceEpoch ~/ 1000;
        final to = nowOnlyDate.millisecondsSinceEpoch ~/ 1000;
        return (
          from.toString(),
          to.toString(),
        );
      case TimeSpan.TwoWeeks:
        final nowOnlyDate = DateTime(now.year, now.month, now.day);
        final start = nowOnlyDate.subtract(Duration(days: 14));
        final from = start.millisecondsSinceEpoch ~/ 1000;
        final to = nowOnlyDate.millisecondsSinceEpoch ~/ 1000;
        return (
          from.toString(),
          to.toString(),
        );
      case TimeSpan.Month:
        final nowOnlyDate = DateTime(now.year, now.month, now.day);
        final start = nowOnlyDate.subtract(Duration(days: 30));
        final from = start.millisecondsSinceEpoch ~/ 1000;
        final to = nowOnlyDate.millisecondsSinceEpoch ~/ 1000;
        return (
          from.toString(),
          to.toString(),
        );
      case TimeSpan.Year:
        final nowOnlyDate = DateTime(now.year, now.month, now.day);
        final start = nowOnlyDate.subtract(Duration(days: 364));
        final from = start.millisecondsSinceEpoch ~/ 1000;
        final to = nowOnlyDate.millisecondsSinceEpoch ~/ 1000;
        return (
          from.toString(),
          to.toString(),
        );
    }
  }

  static String _prettyTimePutCero(int time) {
    final timeStr = time.toString();
    return timeStr.length == 1 ? '0$timeStr' : timeStr;
  }

  static String _prettyTime({
    required int timeMillisecondsSinceEpoch,
    required TimeSpan timeSpan,
  }) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      timeMillisecondsSinceEpoch,
    );

    final base =
        '${_prettyTimePutCero(date.year)}-${_prettyTimePutCero(date.month)}-${_prettyTimePutCero(date.day)}';
    if (timeSpan == TimeSpan.Day) {
      return '$base\n${_prettyTimePutCero(date.hour)}:${_prettyTimePutCero(date.minute)}';
    }

    return base;
  }

  List<CryptoModel> _extractFromResponseNeedItDataBaseOnTimeSpan({
    required List<CryptoModel> cryptos,
    required TimeSpan timeSpan,
  }) {
    var output = <CryptoModel>[];
    final crytosReversed = cryptos.reversed;
    switch (timeSpan) {
      case TimeSpan.Day:
        var hour = -1;
        for (var crypto in crytosReversed) {
          if (crypto.dateTime.hour != hour) {
            hour = crypto.dateTime.hour;
            output.add(
              crypto.copyWith(
                prettyTime: _prettyTime(
                  timeMillisecondsSinceEpoch:
                      crypto.dateTimeMillisecondsSinceEpoch,
                  timeSpan: timeSpan,
                ),
              ),
            );
          }
        }
        break;
      case TimeSpan.TwoWeeks:
      case TimeSpan.Week:
      case TimeSpan.Month:
        var day = -1;
        for (var crypto in crytosReversed) {
          if (crypto.dateTime.day != day) {
            day = crypto.dateTime.day;
            output.add(
              crypto.copyWith(
                prettyTime: _prettyTime(
                  timeMillisecondsSinceEpoch:
                      crypto.dateTimeMillisecondsSinceEpoch,
                  timeSpan: timeSpan,
                ),
              ),
            );
          }
        }
      case TimeSpan.Year:
        var month = -1;
        for (var crypto in crytosReversed) {
          if (crypto.dateTime.month != month) {
            month = crypto.dateTime.month;
            output.add(
              crypto.copyWith(
                prettyTime: _prettyTime(
                  timeMillisecondsSinceEpoch:
                      crypto.dateTimeMillisecondsSinceEpoch,
                  timeSpan: timeSpan,
                ),
              ),
            );
          }
        }
    }
    return output.reversed.toList();
  }

  Future<List<CryptoModel>?> getCryptoData({
    required TimeSpan timeSpan,
    required CryptoCode cryptoCode,
    required FiatCode fiatCode,
  }) async {
    final (start, end) = _dateRangeRequestBasedOnTimeSpan(timeSpan);
    final uri = Uri.https(
      CryptoDataApiContracts.url,
      CryptoDataApiContracts.endpoint(cryptoCode.apiCode),
      CryptoDataApiContracts.queryParameters(
        fiat: fiatCode.apiCode,
        from: start,
        to: end,
      ),
    );
    try {
      final client = HttpClient();
      final request = await client.getUrl(uri);
      request.headers.add(
        CryptoDataApiContracts.nameApiKey,
        CryptoDataApiContracts.apiKey,
      );
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final fullCryptoData = CryptoResponseModel.fromJson(
          source: responseBody,
        ).cryptoData;
        return _extractFromResponseNeedItDataBaseOnTimeSpan(
          cryptos: fullCryptoData,
          timeSpan: timeSpan,
        );
      }
      return null;
    } catch (e) {
      print('XX_ ${e.toString()}');
      return null;
    }
  }
}
