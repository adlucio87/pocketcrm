import 'package:flutter_test/flutter_test.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/services/vcard_generator.dart';

void main() {
  group('VCardGenerator', () {
    test('generate returns a valid vCard string with basic contact info', () {
      final contact = Contact(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '1234567890',
        companyName: 'Acme Corp',
      );

      final vcard = VCardGenerator.generate(contact);

      expect(vcard, contains('BEGIN:VCARD'));
      expect(vcard, contains('VERSION:3.0'));
      expect(vcard, contains('N:Doe;John;;;'));
      expect(vcard, contains('FN:John Doe'));
      expect(vcard, contains('EMAIL;TYPE=INTERNET:john.doe@example.com'));
      expect(vcard, contains('TEL;TYPE=CELL:1234567890'));
      expect(vcard, contains('ORG:Acme Corp'));
      expect(vcard, contains('END:VCARD'));
    });

    test('generate handles missing optional fields gracefully', () {
      final contact = Contact(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
      );

      // This should not throw even though Contact doesn't have jobTitle, website, etc.
      final vcard = VCardGenerator.generate(contact);

      expect(vcard, contains('BEGIN:VCARD'));
      expect(vcard, contains('N:Doe;John;;;'));
      expect(vcard, contains('FN:John Doe'));
      expect(vcard, isNot(contains('EMAIL')));
      expect(vcard, isNot(contains('TEL')));
      expect(vcard, isNot(contains('ORG')));
      expect(vcard, isNot(contains('TITLE')));
      expect(vcard, isNot(contains('URL')));
      expect(vcard, contains('END:VCARD'));
    });

    test('generate escapes special characters', () {
      final contact = Contact(
        id: '1',
        firstName: 'John;',
        lastName: 'Doe,',
        companyName: 'Acme\nCorp',
      );

      final vcard = VCardGenerator.generate(contact);

      expect(vcard, contains('N:Doe\\,;John\\;;;;'));
      expect(vcard, contains('ORG:Acme\\nCorp'));
    });
  });
}
