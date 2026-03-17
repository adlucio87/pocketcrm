import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/services/vcard_generator.dart';

class ContactShareService {
  /// Generates a vCard and shares it using the native share sheet.
  Future<void> shareContact(Contact contact) async {
    final vCardData = VCardGenerator.generate(contact);

    // Generate filename
    String filename;
    if (contact.firstName.isEmpty && contact.lastName.isEmpty) {
      filename = contact.email != null && contact.email!.isNotEmpty
          ? contact.email!
          : 'contact';
    } else {
      filename = '${contact.firstName}_${contact.lastName}'.trim();
    }

    // Sanitize filename: remove all non-alphanumeric except underscore
    filename = filename.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    filename = filename.replaceAll(RegExp(r'_+'), '_'); // remove double underscores
    if (filename.startsWith('_')) filename = filename.substring(1);
    if (filename.endsWith('_')) filename = filename.substring(0, filename.length - 1);

    if (filename.isEmpty) {
      filename = 'contact';
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename.vcf');

    try {
      await file.writeAsString(vCardData, flush: true);

      final xFile = XFile(
        file.path,
        mimeType: 'text/vcard',
        name: '$filename.vcf',
      );

      await Share.shareXFiles(
        [xFile],
        text: 'Condividi contatto',
      );
    } finally {
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }
}
