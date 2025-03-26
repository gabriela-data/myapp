import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:myapp/book/book.dart';
import 'package:myapp/book/book_repository.dart';

part 'book_edit_viewmodel.g.dart';

@riverpod
class BookEditViewModel extends _$BookEditViewModel {
  @override
  Future<Book> build(String? bookId) async {
    if (bookId == null) {
      return Future.value(Book.empty());
    } else {
      final book = await ref.read(bookRepositoryProvider).findById(bookId);
      if (book == null) {
        throw Exception('Book not found');
      }
      return book;
    }
  }

  Future<void> updateState(Book book) async {
    state = AsyncValue.data(book);
  }

  Future<void> save() async {
    state = const AsyncValue.loading();

    Book book = state.requireValue;
    final bookRepository = ref.read(bookRepositoryProvider);
    if (book.id == null) {
      book = await bookRepository.insert(book);
    } else {
      await bookRepository.update(book.id!, book);
    }
    state = await AsyncValue.guard(() => Future.value(book));
  }
}
