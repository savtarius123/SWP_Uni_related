/// Any chat message (no matter the metadata) has some form of content. The classes
/// provided here allow encoding some metadata about that form.
///
/// Authors:
///   * Heye Hamadmad
///   * Arin Tanriverdi
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:typed_data/typed_buffers.dart';

/// Generalized Message content
sealed class ChatMessageContent {
  final String mimeType;
  const ChatMessageContent({required this.mimeType});
  Uint8Buffer toUint8Buffer();
  Uint8List toUint8List();
}

/// Content that can NOT be understood by a human reading its bytes decoded as text
class BinaryContent extends ChatMessageContent {
  final Uint8List content;
  BinaryContent({required this.content, required super.mimeType});

  @override
  Uint8Buffer toUint8Buffer() {
    final retBuffer = Uint8Buffer();
    retBuffer.addAll(content);
    return retBuffer;
  }

  @override
  Uint8List toUint8List() {
    return content;
  }
}

/// Content that CAN be understood by a human reading its bytes decoded as text
class TextualContent extends ChatMessageContent {
  final String content;
  TextualContent({required this.content, required super.mimeType});

  @override
  Uint8Buffer toUint8Buffer() {
    final bytesList = toUint8List();
    final buffer = Uint8Buffer(bytesList.length);
    buffer.addAll(bytesList);
    return buffer;
  }

  @override
  Uint8List toUint8List() {
    return utf8.encode(content);
  }
}
