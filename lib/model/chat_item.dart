import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'date_model.dart';

part 'chat_item.freezed.dart';
part 'chat_item.g.dart';

@JsonEnum(valueField: 'state')
enum ChatItemState {
  @JsonValue("opened")
  opened,
  @JsonValue("ongoing")
  ongoing,
  @JsonValue("closed")
  closed,
}

@freezed
abstract class ChatItem with _$ChatItem {
  const factory ChatItem({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created_by') required String createdBy,
    required String name,
    String? state,
    String? description,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created_at')
    @DateTimeSerializer()
    required DateTime createdAt,
    required String password,
  }) = _ChatItem;

  factory ChatItem.fromJson(Map<String, dynamic> json) =>
      _$ChatItemFromJson(json);
}

@freezed
abstract class PaginatedChatItem with _$PaginatedChatItem {
  factory PaginatedChatItem({
    required List<ChatItem> chatItems,
    required bool hasMore,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: false, includeToJson: false)
    // ignore: always_specify_types
    DocumentSnapshot? startAfter,
  }) = _PaginatedChatItem;

  factory PaginatedChatItem.fromJson(Map<String, dynamic> json) =>
      _$PaginatedChatItemFromJson(json);
}
