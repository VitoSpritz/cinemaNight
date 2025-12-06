import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'date_model.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@JsonEnum(valueField: 'content_type')
enum ChatMessageType {
  @JsonValue('text')
  text,
  @JsonValue('date')
  date,
  @JsonValue('film')
  film,
}

// Discriminated union on message type
@freezed
sealed class ChatContent with _$ChatContent {
  const factory ChatContent.text({required String text}) = TextContent;

  const factory ChatContent.date({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'proposed_date')
    @DateTimeSerializer()
    required DateTime proposedDate,
    @Default(<String>[]) List<String> likes,
  }) = DateContent;

  const factory ChatContent.film({
    // ignore: invalid_annotation_target
    @JsonKey(name: 'film_id') required String filmId,
    @Default(<String>[]) List<String> likes,
    @Default(<String>[]) List<String> dislikes,
  }) = FilmContent;

  factory ChatContent.fromJson(Map<String, dynamic> json) =>
      _$ChatContentFromJson(json);
}

Map<String, dynamic> _chatContentToJson(ChatContent content) =>
    content.toJson();

@Freezed(toJson: true)
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'user_id') required String userId,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'sent_at') @DateTimeSerializer() required DateTime sentAt,
    // ignore: invalid_annotation_target
    @JsonKey(toJson: _chatContentToJson) required ChatContent content,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
abstract class PaginatedChatMessage with _$PaginatedChatMessage {
  const factory PaginatedChatMessage({
    required List<ChatMessage> chatMessages,
    required bool hasMore,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: false, includeToJson: false)
    // ignore: always_specify_types
    DocumentSnapshot? startAfter,
  }) = _PaginatedChatMessage;

  factory PaginatedChatMessage.fromJson(Map<String, dynamic> json) =>
      _$PaginatedChatMessageFromJson(json);
}
