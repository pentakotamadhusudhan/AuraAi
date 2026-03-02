// To parse this JSON data, do
//
//     final weatherPredictionModel = weatherPredictionModelFromJson(jsonString);

import 'dart:convert';

WeatherPredictionModel weatherPredictionModelFromJson(String str) => WeatherPredictionModel.fromJson(json.decode(str));

String weatherPredictionModelToJson(WeatherPredictionModel data) => json.encode(data.toJson());

class WeatherPredictionModel {
  final double? latitude;
  final double? longitude;
  final double? generationtimeMs;
  final int? utcOffsetSeconds;
  final String? timezone;
  final String? timezoneAbbreviation;
  final int? elevation;
  final CurrentWeatherUnits? currentWeatherUnits;
  final CurrentWeather? currentWeather;

  WeatherPredictionModel({
    this.latitude,
    this.longitude,
    this.generationtimeMs,
    this.utcOffsetSeconds,
    this.timezone,
    this.timezoneAbbreviation,
    this.elevation,
    this.currentWeatherUnits,
    this.currentWeather,
  });

  factory WeatherPredictionModel.fromJson(Map<String, dynamic> json) => WeatherPredictionModel(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    generationtimeMs: json["generationtime_ms"]?.toDouble(),
    utcOffsetSeconds: json["utc_offset_seconds"],
    timezone: json["timezone"],
    timezoneAbbreviation: json["timezone_abbreviation"],
    elevation: json["elevation"],
    currentWeatherUnits: json["current_weather_units"] == null ? null : CurrentWeatherUnits.fromJson(json["current_weather_units"]),
    currentWeather: json["current_weather"] == null ? null : CurrentWeather.fromJson(json["current_weather"]),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
    "generationtime_ms": generationtimeMs,
    "utc_offset_seconds": utcOffsetSeconds,
    "timezone": timezone,
    "timezone_abbreviation": timezoneAbbreviation,
    "elevation": elevation,
    "current_weather_units": currentWeatherUnits?.toJson(),
    "current_weather": currentWeather?.toJson(),
  };
}

class CurrentWeather {
  final String? time;
  final int? interval;
  final double? temperature;
  final double? windspeed;
  final int? winddirection;
  final int? isDay;
  final int? weathercode;

  CurrentWeather({
    this.time,
    this.interval,
    this.temperature,
    this.windspeed,
    this.winddirection,
    this.isDay,
    this.weathercode,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
    time: json["time"],
    interval: json["interval"],
    temperature: json["temperature"]?.toDouble(),
    windspeed: json["windspeed"]?.toDouble(),
    winddirection: json["winddirection"],
    isDay: json["is_day"],
    weathercode: json["weathercode"],
  );

  Map<String, dynamic> toJson() => {
    "time": time,
    "interval": interval,
    "temperature": temperature,
    "windspeed": windspeed,
    "winddirection": winddirection,
    "is_day": isDay,
    "weathercode": weathercode,
  };
}

class CurrentWeatherUnits {
  final String? time;
  final String? interval;
  final String? temperature;
  final String? windspeed;
  final String? winddirection;
  final String? isDay;
  final String? weathercode;

  CurrentWeatherUnits({
    this.time,
    this.interval,
    this.temperature,
    this.windspeed,
    this.winddirection,
    this.isDay,
    this.weathercode,
  });

  factory CurrentWeatherUnits.fromJson(Map<String, dynamic> json) => CurrentWeatherUnits(
    time: json["time"],
    interval: json["interval"],
    temperature: json["temperature"],
    windspeed: json["windspeed"],
    winddirection: json["winddirection"],
    isDay: json["is_day"],
    weathercode: json["weathercode"],
  );

  Map<String, dynamic> toJson() => {
    "time": time,
    "interval": interval,
    "temperature": temperature,
    "windspeed": windspeed,
    "winddirection": winddirection,
    "is_day": isDay,
    "weathercode": weathercode,
  };
}
