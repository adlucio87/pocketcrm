import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/di/auth_state.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:pocketcrm/presentation/shared/skeleton_loading.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';
import 'package:pocketcrm/shared/widgets/phone_input_field.dart';
import 'package:pocketcrm/presentation/shared/empty_state_widget.dart';
import 'package:pocketcrm/presentation/shared/swipe_to_delete_wrapper.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(contactsProvider.notifier).loadMore();
    }
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
        title: const Text('Contacts'),
        actions: const [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts...',
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
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(contactsProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'No contacts',
                    message: 'No results match your search.',
                  ),
                ),
              ),
            );
          }
          final notifier = ref.read(contactsProvider.notifier);
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(contactsProvider);
              await ref.read(contactsProvider.future);
            },
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: contacts.length + 1, // +1 for footer
              separatorBuilder: (context, index) => index < contacts.length - 1
                  ? const Divider(height: 1)
                  : const SizedBox.shrink(),
              itemBuilder: (context, index) {
                // Footer: spinner or end-of-list indicator
                if (index == contacts.length) {
                  if (notifier.hasNextPage) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
                final contact = contacts[index];
                return SwipeToDeleteWrapper(
                  itemKey: ValueKey('contact_${contact.id}'),
                  confirmTitle: 'Elimina contatto',
                  confirmMessage: 'Sei sicuro di voler eliminare ${contact.firstName} ${contact.lastName}?\nQuesta azione non può essere annullata.',
                  onDelete: () async {
                    if (!await DemoUtils.checkDemoAction(context, ref)) return;
                    try {
                      await ref.read(contactsProvider.notifier).deleteContact(contact.id);
                      if (context.mounted) {
                        SnackbarHelper.showSuccess(context, 'Contatto eliminato');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarHelper.showError(context, 'Errore durante l\'eliminazione');
                      }
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    backgroundImage:
                        (contact.avatarUrl != null &&
                            contact.avatarUrl!.isNotEmpty)
                        ? CachedNetworkImageProvider(contact.avatarUrl!)
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    contact.companyName ?? contact.email ?? 'No details',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push('/contacts/${contact.id}'),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const ListSkeleton(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!await DemoUtils.checkDemoAction(context, ref)) return;
          if (mounted) _showAddContactDialog(context);
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
      builder: (context) => const AddContactSheet(),
    );
  }
}

class AddContactSheet extends ConsumerStatefulWidget {
  const AddContactSheet({super.key});

  @override
  ConsumerState<AddContactSheet> createState() => AddContactSheetState();
}

class AddContactSheetState extends ConsumerState<AddContactSheet> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  bool _isValidEmail(String email) {
    if (email.isEmpty) return true; // Optional
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return true; // Optional
    // Basic validation: allows + and digits, min 5 chars, max 15
    return RegExp(r'^\+?[0-9\s\-\(\)]{5,15}$').hasMatch(phone);
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
                    'New Contact',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.import_contacts),
                    tooltip: 'Import from contacts',
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (await fc.FlutterContacts.permissions.request(
                                  fc.PermissionType.read,
                                ) ==
                                fc.PermissionStatus.granted) {
                              final contactId = await fc.FlutterContacts.native
                                  .showPicker();
                              if (contactId != null) {
                                final contact = await fc.FlutterContacts.get(
                                  contactId,
                                  properties: {
                                    fc.ContactProperty.name,
                                    fc.ContactProperty.phone,
                                    fc.ContactProperty.email,
                                  },
                                );
                                if (contact != null) {
                                  setState(() {
                                    _firstNameController.text =
                                        contact.name?.first ?? '';
                                    _lastNameController.text =
                                        contact.name?.last ?? '';
                                    if (contact.phones.isNotEmpty) {
                                      _phoneController.text =
                                          contact.phones.first.number;
                                    }
                                    if (contact.emails.isNotEmpty) {
                                      _emailController.text =
                                          contact.emails.first.address;
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
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    !_isValidEmail(v ?? '') ? 'Invalid email format' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone (Mobile)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AbsorbPointer(
                    absorbing: _isLoading,
                    child: PhoneInputField(
                      initialValue: _phoneController.text,
                      onChanged: (val) {
                        _phoneController.text = val ?? '';
                      },
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _errorMessage = null;
                        });
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          final navigator = Navigator.of(context);

                          try {
                            await ref
                                .read(contactsProvider.notifier)
                                .addContact(
                                  firstName: _firstNameController.text.trim(),
                                  lastName: _lastNameController.text.trim(),
                                  email: _emailController.text.trim().isNotEmpty
                                      ? _emailController.text.trim()
                                      : null,
                                  phone: _phoneController.text.trim().isNotEmpty
                                      ? _phoneController.text.trim()
                                      : null,
                                );

                            if (mounted) {
                              navigator.pop(); // Pop solo se successo
                              SnackbarHelper.showSuccess(
                                context,
                                'Contact created successfully',
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              // Extract a readable message if it's a GraphQL error
                              String errorMsg = e.toString();
                              if (errorMsg.contains('INVALID_PHONE_NUMBER')) {
                                errorMsg =
                                    'The phone number (${_phoneController.text}) is invalid or the international prefix is incorrect.';
                              } else if (errorMsg.contains(
                                'Provided phone number is invalid',
                              )) {
                                errorMsg = 'Phone number rejected by server.';
                              } else if (errorMsg.contains('Exception:')) {
                                errorMsg = errorMsg
                                    .replaceAll('Exception:', '')
                                    .trim();
                              }

                              setState(() {
                                _isLoading = false;
                                _errorMessage = errorMsg;
                              });
                            }
                          }
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Contact'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
