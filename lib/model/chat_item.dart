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

extension ChatItemStateExtension on ChatItemState {
  String get jsonValue {
    switch (this) {
      case ChatItemState.opened:
        return 'opened';
      case ChatItemState.ongoing:
        return 'ongoing';
      case ChatItemState.closed:
        return 'closed';
    }
  }
}

extension StringToChatItemState on String {
  ChatItemState? toChatItemState() {
    switch (this) {
      case 'opened':
        return ChatItemState.opened;
      case 'ongoing':
        return ChatItemState.ongoing;
      case 'closed':
        return ChatItemState.closed;
      default:
        return null;
    }
  }
}

@freezed
abstract class ChatItem with _$ChatItem {
  const factory ChatItem({
    required String id,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created_by') required String createdBy,
    required String name,
    required String state,
    String? description,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'closes_at')
    @DateTimeSerializer()
    required DateTime closesAt,
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
