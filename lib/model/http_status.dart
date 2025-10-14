import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'code')
enum HttpStatus {
  ok(200, 'OK'),
  created(201, 'Created'),
  noContent(204, 'No Content'),
  badRequest(400, 'Bad Request'),
  unauthorized(401, 'Unauthorized'),
  forbidden(403, 'Forbidden'),
  notFound(404, 'Not Found'),
  internalServerError(500, 'Internal Server Error');

  const HttpStatus(this.code, this.message);

  final int code;
  final String message;

  static HttpStatus parseCode(int code) {
    return HttpStatus.values.firstWhere(
      (HttpStatus status) => status.code == code,
      orElse: () => throw ArgumentError('Unknown HTTP status code: $code'),
    );
  }
}
