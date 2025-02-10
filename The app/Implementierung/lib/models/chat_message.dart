/// The data model for a chat message and utilities for parsing received bytes
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:mime/mime.dart';

import '../application/util/current_time.dart';
import 'chat_message_content.dart';

/// A [ChatMessage] and its subtypes [SentChatMessage]
/// and [ReceivedChatMessage] are immutable.
sealed class ChatMessage {
  late final ChatMessageContent content;
  late final MartianTimeStamp timestamp;
}

/// When instantiating, the constructor will try to
/// determine the mime type of the contents by looking up its magic bytes
/// (similar to the file utility on Linux systems). If this fails, but the
/// message can be successfully decoded as UTF-8 (or consequently ASCII),
/// the mime type is set to text/plain. Otherwise the fallback is
/// application/octet-stream.
class ReceivedChatMessage extends ChatMessage {
  ReceivedChatMessage({required Uint8List binaryContent, timestamp}) {
    //It would be possible to encode every message as multipart/form-data, but it's fine this way.
    final mimeType = lookupMimeType("",
        headerBytes: binaryContent.buffer.asUint8List(
            0,
            min(defaultMagicNumbersMaxLength,
                binaryContent.buffer.lengthInBytes)));
    if (mimeType == null || RegExp("^text/.*\$").hasMatch(mimeType)) {
      try {
        super.content = TextualContent(
            content: utf8.decode(binaryContent.buffer.asUint8List()),
            mimeType: mimeType ??
                "text/plain"); // No other text/* format will be recognized for now
      } on FormatException {
        super.content = BinaryContent(
            content: binaryContent, mimeType: "application/octet-stream");
      }
    } else {
      super.content = BinaryContent(content: binaryContent, mimeType: mimeType);
    }
    super.timestamp = timestamp;
  }
}

class SentChatMessage extends ChatMessage {
  SentChatMessage(
      {required ChatMessageContent content,
      required MartianTimeStamp timestamp}) {
    super.content = content;
    super.timestamp = timestamp;
  }
}
