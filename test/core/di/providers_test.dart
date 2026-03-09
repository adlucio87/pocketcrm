import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/repositories/crm_repository.dart';

@GenerateNiceMocks([MockSpec<CRMRepository>()])
import 'providers_test.mocks.dart';

void main() {
  group('Contacts Provider', () {
    late MockCRMRepository mockCRMRepository;
    late ProviderContainer container;

    setUp(() {
      mockCRMRepository = MockCRMRepository();
      container = ProviderContainer(
        overrides: [
          crmRepositoryProvider.overrideWith((ref) => mockCRMRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('addContact adds contact and updates state', () async {
      // 1. Setup mock data
      final initialContacts = [
        Contact(id: '1', firstName: 'John', lastName: 'Doe', email: null, phone: null),
      ];
      final newContact = Contact(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: null,
        phone: null,
      );
      final updatedContacts = [...initialContacts, newContact];

      // 2. Mock repository behavior
      when(mockCRMRepository.getContacts()).thenAnswer((_) async => initialContacts);

      when(mockCRMRepository.createContact(
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phone: '1234567890',
      )).thenAnswer((_) async => newContact);

      // 3. Call addContact
      final contactsNotifier = container.read(contactsProvider.notifier);

      // wait for build to finish
      await container.read(contactsProvider.future);

      // Change getContacts to return updatedContacts for the refresh
      when(mockCRMRepository.getContacts()).thenAnswer((_) async => updatedContacts);

      await contactsNotifier.addContact(
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phone: '1234567890',
      );

      // 4. Verify the state has been updated
      expect(container.read(contactsProvider).value, updatedContacts);

      // 5. Verify repository methods were called
      verify(mockCRMRepository.getContacts()).called(2); // Once on build, once after addContact
      verify(mockCRMRepository.createContact(
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phone: '1234567890',
      )).called(1);
    });

    test('addContact handles errors and updates state with error', () async {
      final initialContacts = [
        Contact(id: '1', firstName: 'John', lastName: 'Doe', email: null, phone: null),
      ];

      when(mockCRMRepository.getContacts()).thenAnswer((_) async => initialContacts);

      when(mockCRMRepository.createContact(
        firstName: 'Error',
        lastName: 'User',
        email: null,
        phone: null,
      )).thenThrow(Exception('Failed to create contact'));

      final contactsNotifier = container.read(contactsProvider.notifier);
      await container.read(contactsProvider.future);

      await contactsNotifier.addContact(
        firstName: 'Error',
        lastName: 'User',
      );

      // State should contain the error
      expect(container.read(contactsProvider).hasError, isTrue);
    });
  });
}
