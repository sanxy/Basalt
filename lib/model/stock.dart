import 'dart:convert';

class Data {
  double? open;
  double? high;
  double? low;
  double? close;
  double? volume;
  double? adjHigh;
  double? adjLow;
  double? adjClose;
  double? adjOpen;
  double? adjVolume;
  double? splitFactor;
  double? dividend;
  String? symbol;
  String? exchange;
  String? date;

  Data(
      this.open,
      this.high,
      this.low,
      this.close,
      this.volume,
      this.adjHigh,
      this.adjLow,
      this.adjClose,
      this.adjOpen,
      this.adjVolume,
      this.splitFactor,
      this.dividend,
      this.symbol,
      this.exchange,
      this.date);

  Map<String, dynamic> toMap() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'adj_high': adjHigh,
      'adj_low': adjLow,
      'adj_close': adjClose,
      'adj_open': adjOpen,
      'adj_volume': adjVolume,
      'split_factor': splitFactor,
      'dividend': dividend,
      'symbol': symbol,
      'exchange': exchange,
      'date': date,
    };
  }

  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(
      map['open'] ?? 0.0,
      map['high'] ?? 0.0,
      map['low'] ?? 0.0,
      map['close'] ?? 0.0,
      map['volume'] ?? 0.0,
      map['adj_high'] ?? 0.0,
      map['adj_low'] ?? 0.0,
      map['adj_close'] ?? 0.0,
      map['adj_open'] ?? 0.0,
      map['adj_volume'] ?? 0.0,
      map['split_factor'] ?? 0.0,
      map['dividend'] ?? 0.0,
      map['symbol'] ?? '',
      map['exchange'] ?? '',
      map['date'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Data.fromJson(String source) => Data.fromMap(json.decode(source));
}
