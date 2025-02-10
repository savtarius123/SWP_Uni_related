/// Displays a list of chat messages and an input box.
///
/// Handles sending, receiving and displaying documents as well
///
/// Authors:
///   * Heye Hamadmad
///   * Cem Igci
///   * Mohamed Aziz Mani
///   * Arin Tanriverdi
library;

import 'package:auto_route/auto_route.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:printing/printing.dart';

import '../../application/providers/chat_provider.dart';
import '../../models/chat_message.dart';
import '../../models/chat_message_content.dart';
import '../widgets/chat_bubble.dart';

final _log = Logger("ChatPage");

@RoutePage()
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
  final _formKey = GlobalKey<FormState>();
  final _chatMessageController = TextEditingController();

  /// When a message is currently being sent, input is not allowed
  var _currentlySendingMessage = true;
  _MessagesOrDocument? _content;

  @override
  void dispose() {
    /// Avoid a memory leak that solely exists due to limitations within Flutter
    _chatMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var chatMessages = ref.watch(chatProvider);
    _content ??= _Messages();

    // The whole widget may either display a list of messages and an input field
    // or alternatively a single document
    return switch (_content!) {
      _Messages() => Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(
                        message: chatMessages[index],
                        openDocumentCallback: _openDocumentCallback);
                  })),
          Form(
              key: _formKey,
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (value) {
                    _sendMessageErrorHandling();
                  },
                  controller: _chatMessageController,
                  enabled: _currentlySendingMessage,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Message must not be empty';
                    }
                    return null;
                  },
                )),
                ElevatedButton(
                    onPressed: _currentlySendingMessage ? _loadDocument : null,
                    child: const Text("Load Document")),
                _currentlySendingMessage
                    ? ElevatedButton(
                        onPressed: _sendMessageErrorHandling,
                        child: const Text("Send"))
                    : const CircularProgressIndicator()
              ]))
        ]),
      _Document(:final document, :final enableSending, :final content) =>
        Column(
          children: [
            Expanded(
              child: document,
            ),
            Row(children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _content = _Messages();
                    //set a boolean
                  });
                },
                child: const Text("Close Document"),
              ),
              enableSending
                  ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _sendMessageErrorHandling(binaryContent: content);
                          _content = _Messages();
                        });
                      },
                      child: const Text("Send Document"),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        await _saveDocument(content);
                      },
                      child: const Text("Save Document"),
                    )
            ])
          ],
        )
    };
  }

  /// Handle error while sending message, if necessary
  void _sendMessageErrorHandling({BinaryContent? binaryContent}) async {
    try {
      await _sendMessage(binaryContent: binaryContent);
    } catch (e) {
      _log.severe('Error while sending message: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error while sending message: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Try Again',
            onPressed: () {
              _sendMessageErrorHandling(
                  binaryContent: binaryContent); // Erneut versuchen
            },
          ),
        ),
      );
    }
  }

  /// Send message using chatProvider
  Future<void> _sendMessage({BinaryContent? binaryContent}) async {
    Future<void>? possibleError;
    setState(() {
      _currentlySendingMessage = false;
    });

    if (binaryContent == null) {
      /// Send a text message by reading the input field
      if (_formKey.currentState?.validate() ?? false) {
        try {
          await ref.read(chatProvider.notifier).sendMessage(TextualContent(
              content: _chatMessageController.text, mimeType: "text/plain"));
          _chatMessageController.clear();
        } catch (e, st) {
          possibleError = Future.error(e, st);
        }
      }
    } else {
      /// Send a message with binary content that was passed in
      try {
        await ref.read(chatProvider.notifier).sendMessage(binaryContent);
      } catch (e, st) {
        possibleError = Future.error(e, st);
      }
    }
    setState(() {
      _currentlySendingMessage = true;
    });
    return possibleError;
  }

  // Pick file to send
  Future<void> _loadDocument() async {
    final XFile? result = await openFile(acceptedTypeGroups: <XTypeGroup>[]);

    if (result == null) {
      return;
    }

    final fileBytes = await result.readAsBytes();

    final tempMessage =
        ReceivedChatMessage(binaryContent: fileBytes, timestamp: 0.0);

    setState(() {
      _content = _Document(
          content: BinaryContent(
              content: tempMessage.content.toUint8List(),
              mimeType: tempMessage.content.mimeType),
          enableSending: true);
    });
  }

  // Save file
  Future<void> _saveDocument(BinaryContent content) async {
    try {
      // Determine the file extension
      String extension = '';
      if (content.mimeType.startsWith('image/')) {
        extension = content.mimeType.split('/').last;
      } else if (content.mimeType == 'application/pdf') {
        extension = 'pdf';
      } else if (content.mimeType == 'text/plain') {
        extension = 'txt';
      } else if (content.mimeType == 'audio/mpeg') {
        extension = 'wav';
      } else {
        extension = 'bin'; // Default to binary for unknown types
      }

      // Use `getSaveLocation` to allow the user to choose a save location
      final FileSaveLocation? saveLocation = await getSaveLocation(
        acceptedTypeGroups: <XTypeGroup>[
          const XTypeGroup(label: 'All Files', extensions: ['*']),
        ],
        suggestedName:
            'Enter the name of the file!.$extension', // Include file extension
      );

      // If the user cancels, return early
      if (saveLocation == null) {
        return;
      }

      // Extract the actual path
      final String savePath = saveLocation.path;

      // Save the file at the specified path
      final file = XFile.fromData(
        content.content,
        name: savePath.split('/').last,
        mimeType: content.mimeType,
      );
      await file.saveTo(savePath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save file: $e')),
      );
    }
  }

  // Show the document instead of the list of messages
  void _openDocumentCallback(BinaryContent content) {
    setState(() {
      _content = _Document(content: content);
    });
  }
}

sealed class _MessagesOrDocument {}

class _Messages extends _MessagesOrDocument {}

class _Document extends _MessagesOrDocument {
  late final Widget document;
  bool enableSending;
  final BinaryContent content;

  _Document({
    required this.content,
    this.enableSending = false,
  }) {
    if (content.mimeType == "application/pdf") {
      document = PdfPreview(
        build: (format) => content.content,
      );
    } else if (content.mimeType.startsWith("image/")) {
      document = Image.memory(content.content);
    } else {
      document = const Center(
        child: Text("Unknown data format"),
      );
    }
  }
}
