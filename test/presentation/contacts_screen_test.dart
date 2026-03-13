import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/utils/storage_service.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/presentation/contacts/contacts_screen.dart';

import '../core/di/providers_test.mocks.dart';

// Create a dummy storage service for testing
class MockStorageService extends Mock implements StorageService {
  @override
  Future<String?> read({required String key}) async {
    if (key == 'api_token') return 'fake_token';
    if (key == 'instance_url') return 'https://fake.url';
    return null;
  }
}

void main() {
  group('ContactsScreen Tests', () {
    late MockCRMRepository mockCRMRepository;
    late MockStorageService mockStorageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockCRMRepository = MockCRMRepository();
      mockStorageService = MockStorageService();
    });

    Widget createWidgetUnderTest() {

      return ProviderScope(
        overrides: [
          crmRepositoryProvider.overrideWith((ref) => Future.value(mockCRMRepository)),
          storageServiceProvider.overrideWithValue(mockStorageService),
        ],
        child: const MaterialApp(
          home: ContactsScreen(),
        ),
      );
    }

    testWidgets('Add Contact adds contact and updates UI list immediately', (WidgetTester tester) async {
      // 1. Setup mock data
      final initialContacts = [
        Contact(id: '1', firstName: 'John', lastName: 'Doe', email: 'john@example.com', phone: null),
      ];
      final newContact = Contact(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phone: '1234567890',
      );
      final updatedContacts = [...initialContacts, newContact];

      // 2. Mock repository behavior
      // First call for initial load
      when(mockCRMRepository.getContacts()).thenAnswer((_) async =>
          (contacts: initialContacts, endCursor: null, hasNextPage: false));

      when(mockCRMRepository.createContact(
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phone: '1234567890',
      )).thenAnswer((_) async => newContact);

      // 3. Pump the widget
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for Future to resolve

      // 4. Verify initial state shows John Doe
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);

      // Change getContacts to return updatedContacts for the refresh after adding
      when(mockCRMRepository.getContacts()).thenAnswer((_) async =>
          (contacts: updatedContacts, endCursor: null, hasNextPage: false));

      // 5. Open Add Contact dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 6. Fill the form
      await tester.enterText(find.widgetWithText(TextFormField, 'First Name').first, 'Jane');
      await tester.enterText(find.widgetWithText(TextFormField, 'Last Name').first, 'Smith');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email').first, 'jane@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone (Mobile)').first, '1234567890');

      // 7. Tap Salva Contatto
      await tester.tap(find.text('Save Contact'));
      await tester.pumpAndSettle(); // Wait for the provider state update and modal closing

      // 8. Verify UI now shows both contacts (the state refresh inserts it immediately)
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);

      // 9. Verify repository methods were called
      verify(mockCRMRepository.createContact(
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phone: '1234567890',
      )).called(1);

      // Called once on initial build
      verify(mockCRMRepository.getContacts()).called(1);
    });

    testWidgets('Pull to Refresh updates the list', (WidgetTester tester) async {
      // 1. Setup mock data
      final initialContacts = [
        Contact(id: '1', firstName: 'Old', lastName: 'Contact', email: null, phone: null),
      ];
      final refreshedContacts = [
        Contact(id: '1', firstName: 'Old', lastName: 'Contact', email: null, phone: null),
        Contact(id: '3', firstName: 'Refreshed', lastName: 'Contact', email: null, phone: null),
      ];

      // 2. Mock repository behavior for initial load
      when(mockCRMRepository.getContacts()).thenAnswer((_) async =>
          (contacts: initialContacts, endCursor: null, hasNextPage: false));

      // 3. Pump the widget
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 4. Verify initial state
      expect(find.text('Old Contact'), findsOneWidget);
      expect(find.text('Refreshed Contact'), findsNothing);

      // 5. Change getContacts to return new data for refresh
      when(mockCRMRepository.getContacts()).thenAnswer((_) async =>
          (contacts: refreshedContacts, endCursor: null, hasNextPage: false));

      // 6. Perform pull to refresh
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle(); // Wait for refresh indicator and provider reload

      // 7. Verify UI shows the new contact
      expect(find.text('Old Contact'), findsOneWidget);
      expect(find.text('Refreshed Contact'), findsOneWidget);

      // 8. Verify getContacts was called twice (initial + refresh)
      verify(mockCRMRepository.getContacts()).called(2);
    });
  });
}
