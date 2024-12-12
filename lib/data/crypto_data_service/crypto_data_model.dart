import 'dart:convert';

class CryptoResponseModel {
  List<CryptoModel> cryptoData = [];

  CryptoResponseModel({
    required this.cryptoData,
  });

  factory CryptoResponseModel.fromMap({
    required Map<String, dynamic> map,
  }) {
    final prices = map['prices'] as List<dynamic>;
    List<CryptoModel> output = [];
    prices.forEach(
      (price) {
        output.add(
          CryptoModel(
            prettyTime: '',
            dateTimeMillisecondsSinceEpoch: price[0],
            dateTime: DateTime.fromMillisecondsSinceEpoch(
              price[0],
            ),
            price: price[1],
          ),
        );
      },
    );

    return CryptoResponseModel(
      cryptoData: output,
    );
  }

  factory CryptoResponseModel.fromJson({
    required String source,
  }) {
    return CryptoResponseModel.fromMap(
      map: json.decode(source),
    );
  }
}

class CryptoModel {
  String prettyTime;
  double price;
  int dateTimeMillisecondsSinceEpoch;
  DateTime dateTime;

  CryptoModel({
    required this.prettyTime,
    required this.price,
    required this.dateTimeMillisecondsSinceEpoch,
    required this.dateTime,
  });

  CryptoModel copyWith({
    String? prettyTime,
    double? price,
    int? dateTimeMillisecondsSinceEpoch,
    DateTime? dateTime,
  }) {
    return CryptoModel(
      prettyTime: prettyTime ?? this.prettyTime,
      price: price ?? this.price,
      dateTimeMillisecondsSinceEpoch:
          dateTimeMillisecondsSinceEpoch ?? this.dateTimeMillisecondsSinceEpoch,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
