import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/firestore_provider.dart';
import 'package:myapp/book/book.dart';

part 'book_repository.g.dart';

class BookRepository {
  final FirebaseFirestore _firestore;

  BookRepository(this._firestore);

  Future<Book?> findById(String id) async {
    final snapshot = await _firestore.collection('books').doc(id).get();
    if (!snapshot.exists) {
      return null;
    }
    return Book.fromDocument(snapshot);
  }

  Future<List<Book>> find() async {
    final snapshot = await _firestore.collection('books').get();
    return snapshot.docs.map((doc) => Book.fromDocument(doc)).toList();
  }

  Future<Book> insert(Book book) async {
    final bookData = book.toJson()..remove('id');
    final docRef = await _firestore.collection('books').add(bookData);
    return book.copyWith(id: docRef.id);
  }

  Future<void> update(String id, Book book) async {
    final bookData = book.toJson()..remove('id');
    await _firestore.collection('books').doc(book.id).update(bookData);
  }

  Future<void> delete(String id) async {
    await _firestore.collection('books').doc(id).delete();
  }
}

@riverpod
BookRepository bookRepository(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return BookRepository(firestore);
}
