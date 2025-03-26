import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:myapp/contact/contact.dart';
import 'package:myapp/contact/contact_repository.dart';

part 'contact_list_viewmodel.g.dart';

@riverpod
class ContactListViewModel extends _$ContactListViewModel {
  @override
  Future<List<Contact>> build() async {
    return ref.watch(contactRepositoryProvider).find();
  }

  Future<void> delete(Contact contact) async {
    state = const AsyncValue.loading();
    await ref.read(contactRepositoryProvider).delete(contact.id!);
    ref.invalidateSelf();
  }
}
