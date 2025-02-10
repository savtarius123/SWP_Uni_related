// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatHash() => r'bdfd0894b6cf8409ee0a88089fb629e427eb1b61';

/// Listens to incoming MQTT messages on the topic `chatbot/mission_control`
/// and adds them to the chat buffer if they are new.
///
/// Copied from [Chat].
@ProviderFor(Chat)
final chatProvider = NotifierProvider<Chat, List<ChatMessage>>.internal(
  Chat.new,
  name: r'chatProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$chatHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Chat = Notifier<List<ChatMessage>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
