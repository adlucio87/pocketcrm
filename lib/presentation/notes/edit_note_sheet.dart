import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/domain/models/note.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';

class EditNoteSheet extends ConsumerStatefulWidget {
  final Note note;
  final String? companyId;
  final String? contactId;

  const EditNoteSheet({
    super.key,
    required this.note,
    this.companyId,
    this.contactId,
  });

  @override
  ConsumerState<EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends ConsumerState<EditNoteSheet> {
  late final TextEditingController _bodyController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController(text: _extractPlainText(widget.note.body));
  }

  String _extractPlainText(String body) {
    if (body.isEmpty) return '';
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        final buffer = StringBuffer();
        for (final block in decoded) {
          if (block is Map && block['content'] != null) {
            final content = block['content'];
            if (content is List) {
              for (final inline in content) {
                if (inline is Map && inline['text'] != null) {
                  buffer.write(inline['text']);
                }
              }
            } else if (content is String) {
              buffer.write(content);
            }
          }
          buffer.writeln(); // new line per paragraph
        }
        return buffer.toString().trim();
      }
    } catch (_) {
      // Not JSON, return as is
    }
    return body;
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Note',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _bodyController,
              enabled: !_isLoading,
              maxLines: 10,
              minLines: 4,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Note text',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveNote,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (!await DemoUtils.checkDemoAction(context, ref)) return;

    final text = _bodyController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      if (widget.contactId != null) {
        await ref.read(contactNotesProvider(widget.contactId!).notifier).updateNote(
              widget.note.id,
              text,
            );
      } else if (widget.companyId != null) {
        await ref.read(companyNotesProvider(widget.companyId!).notifier).updateNote(
              widget.note.id,
              text,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
        SnackbarHelper.showSuccess(context, 'Note saved successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
