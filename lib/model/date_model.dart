import 'package:freezed_annotation/freezed_annotation.dart';

class DateTimeSerializer implements JsonConverter<DateTime, String> {
  const DateTimeSerializer();

  @override
  DateTime fromJson(String dateTime) => DateTime.parse(dateTime).toLocal();

  @override
  String toJson(DateTime dateTime) => dateTime.toString();
}
