/// A chat bubble containing either a received or a sent message
///
/// Authors:
///   * Heye Hamadmad
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/util/current_time.dart';
import '../../models/chat_message.dart';
import '../../models/chat_message_content.dart';

class ChatBubble extends ConsumerWidget {
  final ChatMessage message;
  final void Function(BinaryContent content) openDocumentCallback;

  const ChatBubble(
      {super.key, required this.message, required this.openDocumentCallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: IntrinsicHeight(
                child: Row(children: [
              Expanded(
                  child: switch (message.content) {
                BinaryContent(:final mimeType) => OutlinedButton(
                    onPressed: () {
                      openDocumentCallback(message.content as BinaryContent);
                    },
                    child: Text(mimeType)),
                TextualContent(content: final contents) => Text(contents),
              }),
              switch (message) {
                ReceivedChatMessage() =>
                  Text("Received at ${message.timestamp.toTimeOfDay()}"),
                SentChatMessage() =>
                  Text("Sent at ${message.timestamp.toTimeOfDay()}"),
              }
            ]))));
  }
}
