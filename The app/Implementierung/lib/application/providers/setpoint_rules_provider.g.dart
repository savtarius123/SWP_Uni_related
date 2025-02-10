// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setpoint_rules_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$setpointRuleIdsHash() => r'd4d424eb5344a449d86ba8e2f60ecc7d29541498';

/// See also [setpointRuleIds].
@ProviderFor(setpointRuleIds)
final setpointRuleIdsProvider = AutoDisposeProvider<Iterable<String>>.internal(
  setpointRuleIds,
  name: r'setpointRuleIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$setpointRuleIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SetpointRuleIdsRef = AutoDisposeProviderRef<Iterable<String>>;
String _$setpointRuleByTopicHash() =>
    r'7aee59b370d5f1580b5dc998c1faf8393b4ec789';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [setpointRuleByTopic].
@ProviderFor(setpointRuleByTopic)
const setpointRuleByTopicProvider = SetpointRuleByTopicFamily();

/// See also [setpointRuleByTopic].
class SetpointRuleByTopicFamily extends Family<SetpointRule?> {
  /// See also [setpointRuleByTopic].
  const SetpointRuleByTopicFamily();

  /// See also [setpointRuleByTopic].
  SetpointRuleByTopicProvider call(
    String topic,
  ) {
    return SetpointRuleByTopicProvider(
      topic,
    );
  }

  @override
  SetpointRuleByTopicProvider getProviderOverride(
    covariant SetpointRuleByTopicProvider provider,
  ) {
    return call(
      provider.topic,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'setpointRuleByTopicProvider';
}

/// See also [setpointRuleByTopic].
class SetpointRuleByTopicProvider extends AutoDisposeProvider<SetpointRule?> {
  /// See also [setpointRuleByTopic].
  SetpointRuleByTopicProvider(
    String topic,
  ) : this._internal(
          (ref) => setpointRuleByTopic(
            ref as SetpointRuleByTopicRef,
            topic,
          ),
          from: setpointRuleByTopicProvider,
          name: r'setpointRuleByTopicProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$setpointRuleByTopicHash,
          dependencies: SetpointRuleByTopicFamily._dependencies,
          allTransitiveDependencies:
              SetpointRuleByTopicFamily._allTransitiveDependencies,
          topic: topic,
        );

  SetpointRuleByTopicProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topic,
  }) : super.internal();

  final String topic;

  @override
  Override overrideWith(
    SetpointRule? Function(SetpointRuleByTopicRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SetpointRuleByTopicProvider._internal(
        (ref) => create(ref as SetpointRuleByTopicRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topic: topic,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<SetpointRule?> createElement() {
    return _SetpointRuleByTopicProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SetpointRuleByTopicProvider && other.topic == topic;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topic.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SetpointRuleByTopicRef on AutoDisposeProviderRef<SetpointRule?> {
  /// The parameter `topic` of this provider.
  String get topic;
}

class _SetpointRuleByTopicProviderElement
    extends AutoDisposeProviderElement<SetpointRule?>
    with SetpointRuleByTopicRef {
  _SetpointRuleByTopicProviderElement(super.provider);

  @override
  String get topic => (origin as SetpointRuleByTopicProvider).topic;
}

String _$setpointRulesHash() => r'd3d73ca935ee01b1edc30c2bfdc046841dc8f7ae';

abstract class _$SetpointRules
    extends BuildlessAutoDisposeNotifier<SetpointRule?> {
  late final String ruleId;

  SetpointRule? build(
    String ruleId,
  );
}

/// See also [SetpointRules].
@ProviderFor(SetpointRules)
const setpointRulesProvider = SetpointRulesFamily();

/// See also [SetpointRules].
class SetpointRulesFamily extends Family<SetpointRule?> {
  /// See also [SetpointRules].
  const SetpointRulesFamily();

  /// See also [SetpointRules].
  SetpointRulesProvider call(
    String ruleId,
  ) {
    return SetpointRulesProvider(
      ruleId,
    );
  }

  @override
  SetpointRulesProvider getProviderOverride(
    covariant SetpointRulesProvider provider,
  ) {
    return call(
      provider.ruleId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'setpointRulesProvider';
}

/// See also [SetpointRules].
class SetpointRulesProvider
    extends AutoDisposeNotifierProviderImpl<SetpointRules, SetpointRule?> {
  /// See also [SetpointRules].
  SetpointRulesProvider(
    String ruleId,
  ) : this._internal(
          () => SetpointRules()..ruleId = ruleId,
          from: setpointRulesProvider,
          name: r'setpointRulesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$setpointRulesHash,
          dependencies: SetpointRulesFamily._dependencies,
          allTransitiveDependencies:
              SetpointRulesFamily._allTransitiveDependencies,
          ruleId: ruleId,
        );

  SetpointRulesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ruleId,
  }) : super.internal();

  final String ruleId;

  @override
  SetpointRule? runNotifierBuild(
    covariant SetpointRules notifier,
  ) {
    return notifier.build(
      ruleId,
    );
  }

  @override
  Override overrideWith(SetpointRules Function() create) {
    return ProviderOverride(
      origin: this,
      override: SetpointRulesProvider._internal(
        () => create()..ruleId = ruleId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ruleId: ruleId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SetpointRules, SetpointRule?>
      createElement() {
    return _SetpointRulesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SetpointRulesProvider && other.ruleId == ruleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ruleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SetpointRulesRef on AutoDisposeNotifierProviderRef<SetpointRule?> {
  /// The parameter `ruleId` of this provider.
  String get ruleId;
}

class _SetpointRulesProviderElement
    extends AutoDisposeNotifierProviderElement<SetpointRules, SetpointRule?>
    with SetpointRulesRef {
  _SetpointRulesProviderElement(super.provider);

  @override
  String get ruleId => (origin as SetpointRulesProvider).ruleId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
