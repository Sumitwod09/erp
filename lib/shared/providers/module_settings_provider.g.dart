// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$moduleSettingsHash() => r'1b6b7f607ab2bcd7e64a078bd302cc6a9f83c40e';

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

abstract class _$ModuleSettings
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, dynamic>> {
  late final String moduleId;

  FutureOr<Map<String, dynamic>> build(
    String moduleId,
  );
}

/// See also [ModuleSettings].
@ProviderFor(ModuleSettings)
const moduleSettingsProvider = ModuleSettingsFamily();

/// See also [ModuleSettings].
class ModuleSettingsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [ModuleSettings].
  const ModuleSettingsFamily();

  /// See also [ModuleSettings].
  ModuleSettingsProvider call(
    String moduleId,
  ) {
    return ModuleSettingsProvider(
      moduleId,
    );
  }

  @override
  ModuleSettingsProvider getProviderOverride(
    covariant ModuleSettingsProvider provider,
  ) {
    return call(
      provider.moduleId,
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
  String? get name => r'moduleSettingsProvider';
}

/// See also [ModuleSettings].
class ModuleSettingsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ModuleSettings, Map<String, dynamic>> {
  /// See also [ModuleSettings].
  ModuleSettingsProvider(
    String moduleId,
  ) : this._internal(
          () => ModuleSettings()..moduleId = moduleId,
          from: moduleSettingsProvider,
          name: r'moduleSettingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$moduleSettingsHash,
          dependencies: ModuleSettingsFamily._dependencies,
          allTransitiveDependencies:
              ModuleSettingsFamily._allTransitiveDependencies,
          moduleId: moduleId,
        );

  ModuleSettingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.moduleId,
  }) : super.internal();

  final String moduleId;

  @override
  FutureOr<Map<String, dynamic>> runNotifierBuild(
    covariant ModuleSettings notifier,
  ) {
    return notifier.build(
      moduleId,
    );
  }

  @override
  Override overrideWith(ModuleSettings Function() create) {
    return ProviderOverride(
      origin: this,
      override: ModuleSettingsProvider._internal(
        () => create()..moduleId = moduleId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        moduleId: moduleId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ModuleSettings, Map<String, dynamic>>
      createElement() {
    return _ModuleSettingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleSettingsProvider && other.moduleId == moduleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, moduleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ModuleSettingsRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, dynamic>> {
  /// The parameter `moduleId` of this provider.
  String get moduleId;
}

class _ModuleSettingsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ModuleSettings,
        Map<String, dynamic>> with ModuleSettingsRef {
  _ModuleSettingsProviderElement(super.provider);

  @override
  String get moduleId => (origin as ModuleSettingsProvider).moduleId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
