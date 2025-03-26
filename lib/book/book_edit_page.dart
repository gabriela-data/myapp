import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/book/book.dart';
import 'package:myapp/book/book_edit_viewmodel.dart';

class BookEditPage extends ConsumerStatefulWidget {
  final String? bookId;
  const BookEditPage({super.key, required this.bookId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BookEditPageState();
}

class _BookEditPageState extends ConsumerState<BookEditPage> {
  get isNewBook => widget.bookId == null;
  Book? book;
  late final TextEditingController _titleController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookEditViewModelProvider(widget.bookId));

    if (book == null && bookAsync.hasValue) {
      book = bookAsync.value!.copyWith();
      _titleController.text = book!.title;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${isNewBook ? "New" : "Edit"} Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: bookAsync.when(
          data: (originalBook) => _buildForm(context),
          error: (error, stackTrace) => Text('Error: $error'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              autofocus: true,
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Book title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                book = book!.copyWith(title: value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            CheckboxListTile(
              title: const Text('Is completed'),
              value: book!.isCompleted,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  book = book!.copyWith(isCompleted: value!);
                });
              },
            ),
            const SizedBox(height: 16),
            _buildButtonBar(ref, context),
          ],
        ),
      ),
    );
  }

  Row _buildButtonBar(WidgetRef ref, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _save,
          child: Text(isNewBook ? 'Create' : 'Save'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel')),
      ],
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final notifier =
        ref.read(bookEditViewModelProvider(widget.bookId).notifier);
    await notifier.updateState(book!);
    await notifier.save();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
