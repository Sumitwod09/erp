// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_modules_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeModulesHash() => r'8bdc19d66f3fc5418ed0b64d55d312f6addf6205';

/// Provider for active modules based on business subscriptions
///
/// Copied from [ActiveModules].
@ProviderFor(ActiveModules)
final activeModulesProvider =
    AutoDisposeAsyncNotifierProvider<ActiveModules, List<ModuleModel>>.internal(
  ActiveModules.new,
  name: r'activeModulesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeModulesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveModules = AutoDisposeAsyncNotifier<List<ModuleModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
