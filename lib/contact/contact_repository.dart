import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/firestore_provider.dart';
import 'package:myapp/contact/contact.dart';

part 'contact_repository.g.dart';

class ContactRepository {
  final FirebaseFirestore _firestore;

  ContactRepository(this._firestore);

  Future<Contact?> findById(String id) async {
    final snapshot = await _firestore.collection('contacts').doc(id).get();
    if (!snapshot.exists) {
      return null;
    }
    return Contact.fromDocument(snapshot);
  }

  Future<List<Contact>> find() async {
    final snapshot = await _firestore.collection('contacts').get();
    return snapshot.docs.map((doc) => Contact.fromDocument(doc)).toList();
  }

  Future<Contact> insert(Contact contact) async {
    final contactData = contact.toJson()..remove('id');
    final docRef = await _firestore.collection('contacts').add(contactData);
    return contact.copyWith(id: docRef.id);
  }

  Future<void> update(String id, Contact contact) async {
    final contactData = contact.toJson()..remove('id');
    await _firestore.collection('contacts').doc(contact.id).update(contactData);
  }

  Future<void> delete(String id) async {
    await _firestore.collection('contacts').doc(id).delete();
  }
}

@riverpod
ContactRepository contactRepository(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ContactRepository(firestore);
}
