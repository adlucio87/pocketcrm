// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hiveStorageBoxHash() => r'8f6df0baedbef06c34bf223fb90e0f9161b194d2';

/// See also [hiveStorageBox].
@ProviderFor(hiveStorageBox)
final hiveStorageBoxProvider = Provider<Box<String>>.internal(
  hiveStorageBox,
  name: r'hiveStorageBoxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hiveStorageBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HiveStorageBoxRef = ProviderRef<Box<String>>;
String _$storageServiceHash() => r'5c42b009606eff2830b2cef0914a72c78ac18a3c';

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
String _$isDemoModeHash() => r'c1aef0d9ced4c3ccb4049b1cd151c3851fcd8e85';

/// See also [isDemoMode].
@ProviderFor(isDemoMode)
final isDemoModeProvider = FutureProvider<bool>.internal(
  isDemoMode,
  name: r'isDemoModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isDemoModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsDemoModeRef = FutureProviderRef<bool>;
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
String _$currentUserNameHash() => r'b26064b448fd5a1c46309b0de276c3936ffe639d';

/// See also [currentUserName].
@ProviderFor(currentUserName)
final currentUserNameProvider = FutureProvider<String>.internal(
  currentUserName,
  name: r'currentUserNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserNameRef = FutureProviderRef<String>;
String _$contactsHash() => r'290e487566e3ef110b980a2a8b75aea2aa04f8f9';

/// See also [Contacts].
@ProviderFor(Contacts)
final contactsProvider =
    AsyncNotifierProvider<Contacts, List<Contact>>.internal(
      Contacts.new,
      name: r'contactsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Contacts = AsyncNotifier<List<Contact>>;
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

String _$contactNotesHash() => r'94836b03c1a57cd68311ce0c330da4b448ec724d';

abstract class _$ContactNotes
    extends BuildlessAutoDisposeAsyncNotifier<List<Note>> {
  late final String id;

  FutureOr<List<Note>> build(String id);
}

/// See also [ContactNotes].
@ProviderFor(ContactNotes)
const contactNotesProvider = ContactNotesFamily();

/// See also [ContactNotes].
class ContactNotesFamily extends Family<AsyncValue<List<Note>>> {
  /// See also [ContactNotes].
  const ContactNotesFamily();

  /// See also [ContactNotes].
  ContactNotesProvider call(String id) {
    return ContactNotesProvider(id);
  }

  @override
  ContactNotesProvider getProviderOverride(
    covariant ContactNotesProvider provider,
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
  String? get name => r'contactNotesProvider';
}

/// See also [ContactNotes].
class ContactNotesProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ContactNotes, List<Note>> {
  /// See also [ContactNotes].
  ContactNotesProvider(String id)
    : this._internal(
        () => ContactNotes()..id = id,
        from: contactNotesProvider,
        name: r'contactNotesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactNotesHash,
        dependencies: ContactNotesFamily._dependencies,
        allTransitiveDependencies:
            ContactNotesFamily._allTransitiveDependencies,
        id: id,
      );

  ContactNotesProvider._internal(
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
  FutureOr<List<Note>> runNotifierBuild(covariant ContactNotes notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(ContactNotes Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContactNotesProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ContactNotes, List<Note>>
  createElement() {
    return _ContactNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactNotesProvider && other.id == id;
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
mixin ContactNotesRef on AutoDisposeAsyncNotifierProviderRef<List<Note>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ContactNotesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ContactNotes, List<Note>>
    with ContactNotesRef {
  _ContactNotesProviderElement(super.provider);

  @override
  String get id => (origin as ContactNotesProvider).id;
}

String _$companyDetailHash() => r'6b2a4728b7264874b4d8f0a39f9b3f07199bb5d6';

abstract class _$CompanyDetail
    extends BuildlessAutoDisposeAsyncNotifier<Company> {
  late final String id;

  FutureOr<Company> build(String id);
}

/// See also [CompanyDetail].
@ProviderFor(CompanyDetail)
const companyDetailProvider = CompanyDetailFamily();

/// See also [CompanyDetail].
class CompanyDetailFamily extends Family<AsyncValue<Company>> {
  /// See also [CompanyDetail].
  const CompanyDetailFamily();

  /// See also [CompanyDetail].
  CompanyDetailProvider call(String id) {
    return CompanyDetailProvider(id);
  }

  @override
  CompanyDetailProvider getProviderOverride(
    covariant CompanyDetailProvider provider,
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
  String? get name => r'companyDetailProvider';
}

/// See also [CompanyDetail].
class CompanyDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<CompanyDetail, Company> {
  /// See also [CompanyDetail].
  CompanyDetailProvider(String id)
    : this._internal(
        () => CompanyDetail()..id = id,
        from: companyDetailProvider,
        name: r'companyDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$companyDetailHash,
        dependencies: CompanyDetailFamily._dependencies,
        allTransitiveDependencies:
            CompanyDetailFamily._allTransitiveDependencies,
        id: id,
      );

  CompanyDetailProvider._internal(
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
  FutureOr<Company> runNotifierBuild(covariant CompanyDetail notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(CompanyDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: CompanyDetailProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<CompanyDetail, Company>
  createElement() {
    return _CompanyDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompanyDetailProvider && other.id == id;
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
mixin CompanyDetailRef on AutoDisposeAsyncNotifierProviderRef<Company> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CompanyDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CompanyDetail, Company>
    with CompanyDetailRef {
  _CompanyDetailProviderElement(super.provider);

  @override
  String get id => (origin as CompanyDetailProvider).id;
}

String _$companyNotesHash() => r'f04175e171d779ebe67b234f7ae20b77ea4ad684';

abstract class _$CompanyNotes
    extends BuildlessAutoDisposeAsyncNotifier<List<Note>> {
  late final String id;

  FutureOr<List<Note>> build(String id);
}

/// See also [CompanyNotes].
@ProviderFor(CompanyNotes)
const companyNotesProvider = CompanyNotesFamily();

/// See also [CompanyNotes].
class CompanyNotesFamily extends Family<AsyncValue<List<Note>>> {
  /// See also [CompanyNotes].
  const CompanyNotesFamily();

  /// See also [CompanyNotes].
  CompanyNotesProvider call(String id) {
    return CompanyNotesProvider(id);
  }

  @override
  CompanyNotesProvider getProviderOverride(
    covariant CompanyNotesProvider provider,
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
  String? get name => r'companyNotesProvider';
}

/// See also [CompanyNotes].
class CompanyNotesProvider
    extends AutoDisposeAsyncNotifierProviderImpl<CompanyNotes, List<Note>> {
  /// See also [CompanyNotes].
  CompanyNotesProvider(String id)
    : this._internal(
        () => CompanyNotes()..id = id,
        from: companyNotesProvider,
        name: r'companyNotesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$companyNotesHash,
        dependencies: CompanyNotesFamily._dependencies,
        allTransitiveDependencies:
            CompanyNotesFamily._allTransitiveDependencies,
        id: id,
      );

  CompanyNotesProvider._internal(
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
  FutureOr<List<Note>> runNotifierBuild(covariant CompanyNotes notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(CompanyNotes Function() create) {
    return ProviderOverride(
      origin: this,
      override: CompanyNotesProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<CompanyNotes, List<Note>>
  createElement() {
    return _CompanyNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompanyNotesProvider && other.id == id;
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
mixin CompanyNotesRef on AutoDisposeAsyncNotifierProviderRef<List<Note>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CompanyNotesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CompanyNotes, List<Note>>
    with CompanyNotesRef {
  _CompanyNotesProviderElement(super.provider);

  @override
  String get id => (origin as CompanyNotesProvider).id;
}

String _$companyContactsHash() => r'55ec82552005f6ffe2de00cd4764fc81c75de723';

abstract class _$CompanyContacts
    extends BuildlessAutoDisposeAsyncNotifier<List<Contact>> {
  late final String id;

  FutureOr<List<Contact>> build(String id);
}

/// See also [CompanyContacts].
@ProviderFor(CompanyContacts)
const companyContactsProvider = CompanyContactsFamily();

/// See also [CompanyContacts].
class CompanyContactsFamily extends Family<AsyncValue<List<Contact>>> {
  /// See also [CompanyContacts].
  const CompanyContactsFamily();

  /// See also [CompanyContacts].
  CompanyContactsProvider call(String id) {
    return CompanyContactsProvider(id);
  }

  @override
  CompanyContactsProvider getProviderOverride(
    covariant CompanyContactsProvider provider,
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
  String? get name => r'companyContactsProvider';
}

/// See also [CompanyContacts].
class CompanyContactsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<CompanyContacts, List<Contact>> {
  /// See also [CompanyContacts].
  CompanyContactsProvider(String id)
    : this._internal(
        () => CompanyContacts()..id = id,
        from: companyContactsProvider,
        name: r'companyContactsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$companyContactsHash,
        dependencies: CompanyContactsFamily._dependencies,
        allTransitiveDependencies:
            CompanyContactsFamily._allTransitiveDependencies,
        id: id,
      );

  CompanyContactsProvider._internal(
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
  FutureOr<List<Contact>> runNotifierBuild(covariant CompanyContacts notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(CompanyContacts Function() create) {
    return ProviderOverride(
      origin: this,
      override: CompanyContactsProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<CompanyContacts, List<Contact>>
  createElement() {
    return _CompanyContactsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompanyContactsProvider && other.id == id;
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
mixin CompanyContactsRef on AutoDisposeAsyncNotifierProviderRef<List<Contact>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CompanyContactsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<CompanyContacts, List<Contact>>
    with CompanyContactsRef {
  _CompanyContactsProviderElement(super.provider);

  @override
  String get id => (origin as CompanyContactsProvider).id;
}

String _$taskContactsHash() => r'90bef80c91ba0a79815bb2da270fdf63c8d715d9';

abstract class _$TaskContacts
    extends BuildlessAutoDisposeAsyncNotifier<List<Contact>> {
  late final String id;

  FutureOr<List<Contact>> build(String id);
}

/// See also [TaskContacts].
@ProviderFor(TaskContacts)
const taskContactsProvider = TaskContactsFamily();

/// See also [TaskContacts].
class TaskContactsFamily extends Family<AsyncValue<List<Contact>>> {
  /// See also [TaskContacts].
  const TaskContactsFamily();

  /// See also [TaskContacts].
  TaskContactsProvider call(String id) {
    return TaskContactsProvider(id);
  }

  @override
  TaskContactsProvider getProviderOverride(
    covariant TaskContactsProvider provider,
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
  String? get name => r'taskContactsProvider';
}

/// See also [TaskContacts].
class TaskContactsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<TaskContacts, List<Contact>> {
  /// See also [TaskContacts].
  TaskContactsProvider(String id)
    : this._internal(
        () => TaskContacts()..id = id,
        from: taskContactsProvider,
        name: r'taskContactsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskContactsHash,
        dependencies: TaskContactsFamily._dependencies,
        allTransitiveDependencies:
            TaskContactsFamily._allTransitiveDependencies,
        id: id,
      );

  TaskContactsProvider._internal(
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
  FutureOr<List<Contact>> runNotifierBuild(covariant TaskContacts notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(TaskContacts Function() create) {
    return ProviderOverride(
      origin: this,
      override: TaskContactsProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<TaskContacts, List<Contact>>
  createElement() {
    return _TaskContactsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskContactsProvider && other.id == id;
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
mixin TaskContactsRef on AutoDisposeAsyncNotifierProviderRef<List<Contact>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TaskContactsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TaskContacts, List<Contact>>
    with TaskContactsRef {
  _TaskContactsProviderElement(super.provider);

  @override
  String get id => (origin as TaskContactsProvider).id;
}

String _$companiesHash() => r'f4cf134b3b9809a569d794d695aa0a1db11950ae';

/// See also [Companies].
@ProviderFor(Companies)
final companiesProvider =
    AsyncNotifierProvider<Companies, List<Company>>.internal(
      Companies.new,
      name: r'companiesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$companiesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Companies = AsyncNotifier<List<Company>>;
String _$taskFilterHash() => r'44791578439545964641fee9fbfdadc6fa4f5072';

/// See also [TaskFilter].
@ProviderFor(TaskFilter)
final taskFilterProvider =
    AutoDisposeNotifierProvider<TaskFilter, bool>.internal(
      TaskFilter.new,
      name: r'taskFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskFilter = AutoDisposeNotifier<bool>;
String _$tasksHash() => r'2aa61d65a7b9183bd95ac39a03a7eea9db8922c5';

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
