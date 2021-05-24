import 'dart:convert';

class CryptoResponseModel {
  List<CryptoModel> cryptoData = [];

  CryptoResponseModel({
    required this.cryptoData,
  });

  factory CryptoResponseModel.fromMap(List<dynamic> list) {
    final Map<String, dynamic> map = list.first;

    final dates = map['timestamps'].cast<String>();
    final prices = map['prices'].cast<String>();

    List<CryptoModel> _cryptoData = [];

    for (int x = 0; x < dates.length; x++) {
      _cryptoData.add(CryptoModel(
          time: _formatDate(dates[x]), price: double.parse(prices[x])));
    }

    return CryptoResponseModel(cryptoData: _cryptoData);
  }

  factory CryptoResponseModel.fromJson(String source) =>
      CryptoResponseModel.fromMap(json.decode(source));

  static String _formatDate(String dateRaw) {
    try {
      final dateTime = DateTime.tryParse(dateRaw);
      if (dateTime == null) return '';
      return dateTime.year.toString() +
          '-' +
          _putCero(dateTime.month.toString()) +
          '-' +
          _putCero(dateTime.day.toString()) +
          '\n' +
          _putCero(dateTime.hour.toString()) +
          ' : ' +
          _putCero(dateTime.minute.toString());
    } on Exception {
      return '';
    }
  }

  static String _putCero(String time) {
    return time.length == 1 ? '0$time' : time;
  }
}

class CryptoModel {
  String time;
  double price;

  CryptoModel({
    required this.time,
    required this.price,
  });
}
