import 'package:flutter_test/flutter_test.dart';
import 'package:pocketcrm/domain/models/contact.dart';

void main() {
  group('Contact.fromTwenty', () {
    test('should parse a full contact JSON correctly', () {
      final json = {
        'id': 'contact-1',
        'name': {
          'firstName': 'John',
          'lastName': 'Doe',
        },
        'emails': {
          'primaryEmail': 'john.doe@example.com',
        },
        'phones': {
          'primaryPhoneCallingCode': '+1',
          'primaryPhoneNumber': '5550123',
        },
        'avatarUrl': 'https://example.com/avatar.png',
        'company': {
          'id': 'company-1',
          'name': 'Example Corp',
        },
        'createdAt': '2023-10-27T10:00:00Z',
      };

      final contact = Contact.fromTwenty(json);

      expect(contact.id, 'contact-1');
      expect(contact.firstName, 'John');
      expect(contact.lastName, 'Doe');
      expect(contact.email, 'john.doe@example.com');
      expect(contact.phone, '+15550123');
      expect(contact.avatarUrl, 'https://example.com/avatar.png');
      expect(contact.companyId, 'company-1');
      expect(contact.companyName, 'Example Corp');
      expect(contact.createdAt, DateTime.parse('2023-10-27T10:00:00Z'));
    });

    test('should handle minimal JSON with default values', () {
      final json = {
        'id': 'contact-2',
      };

      final contact = Contact.fromTwenty(json);

      expect(contact.id, 'contact-2');
      expect(contact.firstName, '');
      expect(contact.lastName, '');
      expect(contact.email, isNull);
      expect(contact.phone, isNull);
      expect(contact.avatarUrl, isNull);
      expect(contact.companyId, isNull);
      expect(contact.companyName, isNull);
      expect(contact.createdAt, isNull);
    });

    test('should parse company name when it is a Map (Twenty CRM pattern)', () {
      final json = {
        'id': 'contact-3',
        'company': {
          'id': 'company-2',
          'name': {'text': 'Map Corp'},
        },
      };

      final contact = Contact.fromTwenty(json);

      expect(contact.companyName, 'Map Corp');
      expect(contact.companyId, 'company-2');
    });

    test('should handle phone numbers without calling code', () {
      final json = {
        'id': 'contact-4',
        'phones': {
          'primaryPhoneNumber': '123456789',
        },
      };

      final contact = Contact.fromTwenty(json);

      expect(contact.phone, '123456789');
    });

    test('should handle phone numbers without number but with calling code', () {
      final json = {
        'id': 'contact-5',
        'phones': {
          'primaryPhoneCallingCode': '+33',
        },
      };

      final contact = Contact.fromTwenty(json);

      expect(contact.phone, '+33');
    });

    test('should handle empty strings in phone data', () {
      final json = {
        'id': 'contact-6',
        'phones': {
          'primaryPhoneCallingCode': '',
          'primaryPhoneNumber': '',
        },
      };

      final contact = Contact.fromTwenty(json);

      expect(contact.phone, isNull);
    });

    test('should only accept avatarUrl starting with http', () {
      final jsonWithHttp = {
        'id': 'contact-7',
        'avatarUrl': 'https://example.com/photo.jpg',
      };
      final jsonWithoutHttp = {
        'id': 'contact-8',
        'avatarUrl': 'internal/path/to/photo.jpg',
      };

      final contactWithHttp = Contact.fromTwenty(jsonWithHttp);
      final contactWithoutHttp = Contact.fromTwenty(jsonWithoutHttp);

      expect(contactWithHttp.avatarUrl, 'https://example.com/photo.jpg');
      expect(contactWithoutHttp.avatarUrl, isNull);
    });
  });
}
