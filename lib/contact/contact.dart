import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact.freezed.dart';
part 'contact.g.dart';

@freezed
sealed class Contact with _$Contact {
  const factory Contact({
    String? id,
    required String name,
    required String phone,
    @Default([]) List<Contact> contacts,
  }) = _Contact;

  factory Contact.empty() => const Contact(
        id: null,
        name: '',
        phone: '',
      );

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

  factory Contact.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contact.fromJson(data).copyWith(id: doc.id);
  }
}
