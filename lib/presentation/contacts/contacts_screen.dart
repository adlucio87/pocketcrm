import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/di/auth_state.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(contactsProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            tooltip: 'Logout / Reset',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca contatti...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return const Center(child: Text('Nessun contatto trovato.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(contactsProvider.future),
            child: ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    backgroundImage: contact.avatarUrl != null
                        ? NetworkImage(contact.avatarUrl!)
                        : null,
                    child: contact.avatarUrl == null
                        ? Text(
                            contact.firstName.isNotEmpty
                                ? contact.firstName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    '${contact.firstName} ${contact.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    contact.companyName ?? contact.email ?? 'Nessun dettaglio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.push('/contacts/${contact.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Errore: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddContactDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddContactSheet(),
    );
  }
}

class _AddContactSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends ConsumerState<_AddContactSheet> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nuovo Contatto',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.import_contacts),
                  tooltip: 'Importa da rubrica',
                  onPressed: () async {
                    if (await fc.FlutterContacts.permissions.request(fc.PermissionType.read) == fc.PermissionStatus.granted) {
                      final contactId = await fc.FlutterContacts.native.showPicker();
                      if (contactId != null) {
                        final contact = await fc.FlutterContacts.get(contactId);
                        if (contact != null) {
                          setState(() {
                            _firstNameController.text = contact.name?.first ?? '';
                            _lastNameController.text = contact.name?.last ?? '';
                            if (contact.phones.isNotEmpty) {
                              _phoneController.text = contact.phones.first.number;
                            }
                            if (contact.emails.isNotEmpty) {
                              _emailController.text = contact.emails.first.address;
                            }
                          });
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => v?.isEmpty == true ? 'Obbligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Cognome'),
              validator: (v) => v?.isEmpty == true ? 'Obbligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefono (Mobile)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await ref
                      .read(contactsProvider.notifier)
                      .addContact(
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        email: _emailController.text.isNotEmpty ? _emailController.text : null,
                        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                      );
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Salva'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
