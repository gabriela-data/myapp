import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/contact/contact_edit_page.dart';
import 'package:myapp/contact/contact_list_viewmodel.dart';
import 'package:myapp/contact/contact.dart';

class ContactListPage extends ConsumerWidget {
  const ContactListPage({super.key});

  void _onUpdate(WidgetRef ref) {
    ref.invalidate(contactListViewModelProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactList = ref.watch(contactListViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ContactEditPage(
                contactId: null,
              ),
            ),
          );
          if (saved == true) {
            _onUpdate(ref);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: contactList.when(
          data: (list) => _buildContactList(ref, list),
          error: _buildError,
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget? _buildError(error, stackTrace) => Center(
        child: Column(
          children: [
            Text('Error: $error'),
            Text('Stack trace: $stackTrace'),
          ],
        ),
      );

  Widget? _buildContactList(WidgetRef ref, List<Contact> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No contacts found'),
      );
    } else {
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          Contact contact = list[index];
          return ListTile(
            title: Text(contact.title),
            subtitle: Text(contact.isCompleted ? 'Completed' : 'Not completed'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // create dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Contact'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ref
                              .read(contactListViewModelProvider.notifier)
                              .delete(contact);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
            onTap: () async {
              final saved = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ContactEditPage(contactId: contact.id),
                ),
              );
              if (saved == true) {
                _onUpdate(ref);
              }
            },
          );
        },
      );
    }
  }
}
