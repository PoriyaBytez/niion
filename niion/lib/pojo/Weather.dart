// To parse this JSON data, do
//
//     final weather = weatherFromJson(jsonString);

import 'dart:convert';

Weather? weatherFromJson(String str) => Weather.fromJson(json.decode(str));

String weatherToJson(Weather? data) => json.encode(data!.toJson());

class Weather {
  Weather({
    this.location,
    this.current,
  });

  Location? location;
  Current? current;

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    location: Location.fromJson(json["location"]),
    current: Current.fromJson(json["current"]),
  );

  Map<String, dynamic> toJson() => {
    "location": location!.toJson(),
    "current": current!.toJson(),
  };
}

class Current {
  Current({
    this.tempC,
    this.condition,
  });

  double? tempC;
  Condition? condition;

  factory Current.fromJson(Map<String, dynamic> json) => Current(
    tempC: json["temp_c"],
    condition: Condition.fromJson(json["condition"]),
  );

  Map<String, dynamic> toJson() => {
    "temp_c": tempC,
    "condition": condition!.toJson(),
  };
}

class Condition {
  Condition({
    this.text,
    this.icon,
  });

  String? text;
  String? icon;

  factory Condition.fromJson(Map<String, dynamic> json) => Condition(
    text: json["text"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "icon": icon,
  };
}

class Location {
  Location({
    this.name,
    this.region,
    this.lat,
    this.lon,
    this.localtimeEpoch,
  });

  String? name;
  String? region;
  double? lat;
  double? lon;
  int? localtimeEpoch;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    name: json["name"],
    region: json["region"],
    lat: json["lat"].toDouble(),
    lon: json["lon"].toDouble(),
    localtimeEpoch: json["localtime_epoch"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "region": region,
    "lat": lat,
    "lon": lon,
    "localtime_epoch": localtimeEpoch,
  };
}
