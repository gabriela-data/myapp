import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/book/book_edit_page.dart';
import 'package:myapp/book/book_list_viewmodel.dart';
import 'package:myapp/book/book.dart';

class BookListPage extends ConsumerWidget {
  const BookListPage({super.key});

  void _onUpdate(WidgetRef ref) {
    ref.invalidate(bookListViewModelProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookList = ref.watch(bookListViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BookEditPage(
                bookId: null,
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
        child: bookList.when(
          data: (list) => _buildBookList(ref, list),
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

  Widget? _buildBookList(WidgetRef ref, List<Book> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No books found'),
      );
    } else {
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          Book book = list[index];
          return ListTile(
            title: Text(book.title),
            subtitle: Text(book.isCompleted ? 'Completed' : 'Not completed'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // create dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Book'),
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
                              .read(bookListViewModelProvider.notifier)
                              .delete(book);
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
                  builder: (context) => BookEditPage(bookId: book.id),
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
