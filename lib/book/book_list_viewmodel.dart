import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:myapp/book/book.dart';
import 'package:myapp/book/book_repository.dart';

part 'book_list_viewmodel.g.dart';

@riverpod
class BookListViewModel extends _$BookListViewModel {
  @override
  Future<List<Book>> build() async {
    return ref.watch(bookRepositoryProvider).find();
  }

  Future<void> delete(Book book) async {
    state = const AsyncValue.loading();
    await ref.read(bookRepositoryProvider).delete(book.id!);
    ref.invalidateSelf();
  }
}
