// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'3a9f8412df34c1653d08100c9826aa2125b80f7f';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$storageServiceHash() => r'4c403eaad74c45dbf0c610f81e1d900cde9a7ce0';

/// See also [storageService].
@ProviderFor(storageService)
final storageServiceProvider = Provider<StorageService>.internal(
  storageService,
  name: r'storageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageServiceRef = ProviderRef<StorageService>;
String _$crmRepositoryHash() => r'79becb479b3eb2cd2061282801710ac980410308';

/// See also [crmRepository].
@ProviderFor(crmRepository)
final crmRepositoryProvider = FutureProvider<CRMRepository>.internal(
  crmRepository,
  name: r'crmRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$crmRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrmRepositoryRef = FutureProviderRef<CRMRepository>;
String _$contactsHash() => r'c94691d08a44f6b692629af73713f48d0f7295aa';

/// See also [Contacts].
@ProviderFor(Contacts)
final contactsProvider =
    AutoDisposeAsyncNotifierProvider<Contacts, List<Contact>>.internal(
      Contacts.new,
      name: r'contactsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Contacts = AutoDisposeAsyncNotifier<List<Contact>>;
String _$contactDetailHash() => r'f277c97ad6aff5f1b22e05fd62fe33a61d214f0f';

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

abstract class _$ContactDetail
    extends BuildlessAutoDisposeAsyncNotifier<Contact> {
  late final String id;

  FutureOr<Contact> build(String id);
}

/// See also [ContactDetail].
@ProviderFor(ContactDetail)
const contactDetailProvider = ContactDetailFamily();

/// See also [ContactDetail].
class ContactDetailFamily extends Family<AsyncValue<Contact>> {
  /// See also [ContactDetail].
  const ContactDetailFamily();

  /// See also [ContactDetail].
  ContactDetailProvider call(String id) {
    return ContactDetailProvider(id);
  }

  @override
  ContactDetailProvider getProviderOverride(
    covariant ContactDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactDetailProvider';
}

/// See also [ContactDetail].
class ContactDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ContactDetail, Contact> {
  /// See also [ContactDetail].
  ContactDetailProvider(String id)
    : this._internal(
        () => ContactDetail()..id = id,
        from: contactDetailProvider,
        name: r'contactDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactDetailHash,
        dependencies: ContactDetailFamily._dependencies,
        allTransitiveDependencies:
            ContactDetailFamily._allTransitiveDependencies,
        id: id,
      );

  ContactDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  FutureOr<Contact> runNotifierBuild(covariant ContactDetail notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(ContactDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContactDetailProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ContactDetail, Contact>
  createElement() {
    return _ContactDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactDetailRef on AutoDisposeAsyncNotifierProviderRef<Contact> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ContactDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ContactDetail, Contact>
    with ContactDetailRef {
  _ContactDetailProviderElement(super.provider);

  @override
  String get id => (origin as ContactDetailProvider).id;
}

String _$companiesHash() => r'd0d8a67bd8bfd8a6cd4d33d66853a1958c0c8fcc';

/// See also [Companies].
@ProviderFor(Companies)
final companiesProvider =
    AutoDisposeAsyncNotifierProvider<Companies, List<Company>>.internal(
      Companies.new,
      name: r'companiesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$companiesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Companies = AutoDisposeAsyncNotifier<List<Company>>;
String _$tasksHash() => r'01b1d465d620951df878c13f870a8a479dab7562';

/// See also [Tasks].
@ProviderFor(Tasks)
final tasksProvider =
    AutoDisposeAsyncNotifierProvider<Tasks, List<Task>>.internal(
      Tasks.new,
      name: r'tasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Tasks = AutoDisposeAsyncNotifier<List<Task>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
