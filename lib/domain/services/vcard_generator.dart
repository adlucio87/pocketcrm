import 'package:pocketcrm/domain/models/contact.dart';

class VCardGenerator {
  /// Generates a v3.0 vCard format string from a Contact object.
  static String generate(Contact contact) {
    final buffer = StringBuffer();

    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');

    // N and FN are required
    final lastName = _escape(contact.lastName);
    final firstName = _escape(contact.firstName);
    buffer.writeln('N:$lastName;$firstName;;;');

    String fn;
    if (contact.firstName.isEmpty && contact.lastName.isEmpty) {
      fn = contact.email != null && contact.email!.isNotEmpty
          ? _escape(contact.email!)
          : '';
    } else {
      fn = _escape('${contact.firstName} ${contact.lastName}'.trim());
    }
    buffer.writeln('FN:$fn');

    if (contact.companyName != null && contact.companyName!.isNotEmpty) {
      buffer.writeln('ORG:${_escape(contact.companyName!)}');
    }

    // Check if jobTitle exists in the Contact model. If so, add it.
    // Assuming we don't have jobTitle, website, linkedin, city right now based on Contact model read earlier,
    // but the instructions say "Se il modello Contact ha già questi campi usali nel vCard, altrimenti ignorali senza errori"

    try {
      // Use dynamic to safely check if contact has these properties
      final dynamic dynContact = contact;

      final String? jobTitle = dynContact.jobTitle;
      if (jobTitle != null && jobTitle.isNotEmpty) {
        buffer.writeln('TITLE:${_escape(jobTitle)}');
      }
    } catch (_) {}

    if (contact.email != null && contact.email!.isNotEmpty) {
      buffer.writeln('EMAIL;TYPE=INTERNET:${_escape(contact.email!)}');
    }

    if (contact.phone != null && contact.phone!.isNotEmpty) {
      buffer.writeln('TEL;TYPE=CELL:${_escape(contact.phone!)}');
    }

    final dynamic dynContact = contact;
    try {
      final String? website = dynContact.website;
      if (website != null && website.isNotEmpty) {
        buffer.writeln('URL:${_escape(website)}');
      }
    } catch (_) {}

    try {
      final String? linkedin = dynContact.linkedin;
      if (linkedin != null && linkedin.isNotEmpty) {
        buffer.writeln('URL;TYPE=LinkedIn:${_escape(linkedin)}');
      }
    } catch (_) {}

    try {
      final String? city = dynContact.city;
      if (city != null && city.isNotEmpty) {
        buffer.writeln('ADR;TYPE=HOME:;;${_escape(city)};;;;');
      }
    } catch (_) {}

    buffer.writeln('NOTE:Aggiunto da TwentyMobile');
    buffer.writeln('END:VCARD');

    return buffer.toString();
  }

  static String _escape(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n');
  }
}
