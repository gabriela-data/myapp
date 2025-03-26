import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:myapp/contact/contact.dart';
import 'package:myapp/contact/contact_repository.dart';

part 'contact_edit_viewmodel.g.dart';

@riverpod
class ContactEditViewModel extends _$ContactEditViewModel {
  @override
  Future<Contact> build(String? contactId) async {
    if (contactId == null) {
      return Future.value(Contact.empty());
    } else {
      final contact = await ref.read(contactRepositoryProvider).findById(contactId);
      if (contact == null) {
        throw Exception('Contact not found');
      }
      return contact;
    }
  }

  Future<void> updateState(Contact contact) async {
    state = AsyncValue.data(contact);
  }

  Future<void> save() async {
    state = const AsyncValue.loading();

    Contact contact = state.requireValue;
    final contactRepository = ref.read(contactRepositoryProvider);
    if (contact.id == null) {
      contact = await contactRepository.insert(contact);
    } else {
      await contactRepository.update(contact.id!, contact);
    }
    state = await AsyncValue.guard(() => Future.value(contact));
  }
}
