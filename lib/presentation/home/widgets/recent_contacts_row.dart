import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecentContactsRow extends StatelessWidget {
  final List<Contact> contacts;

  const RecentContactsRow({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return GestureDetector(
            onTap: () => context.push('/contacts/${contact.id}'),
            child: Container(
              width: 68,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    backgroundImage: contact.avatarUrl != null
                        ? CachedNetworkImageProvider(contact.avatarUrl!)
                        : null,
                    child: contact.avatarUrl == null
                        ? Text(
                            contact.firstName.isNotEmpty ? contact.firstName[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    contact.firstName,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
