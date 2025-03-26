import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

@freezed
sealed class Book with _$Book {
  const factory Book({
    String? id,
    required String title,
    @Default(false) bool isCompleted,
  }) = _Book;

  factory Book.empty() => const Book(
        id: null,
        title: '',
      );

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  factory Book.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book.fromJson(data).copyWith(id: doc.id);
  }
}
