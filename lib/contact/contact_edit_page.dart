import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/contact/contact.dart';
import 'package:myapp/contact/contact_edit_viewmodel.dart';

class ContactEditPage extends ConsumerStatefulWidget {
  final String? contactId;
  const ContactEditPage({super.key, required this.contactId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends ConsumerState<ContactEditPage> {
  get isNewContact => widget.contactId == null;
  Contact? contact;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactAsync = ref.watch(contactEditViewModelProvider(widget.contactId));

    if (contact == null && contactAsync.hasValue) {
      contact = contactAsync.value!.copyWith();
      _nameController.text = contact!.name;
      _phoneController.text = contact!.phone;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${isNewContact ? "New" : "Edit"} Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: contactAsync.when(
          data: (originalContact) => _buildForm(context),
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
            Column(
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    contact = contact!.copyWith(name: value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    contact = contact!.copyWith(phone: value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
            //CheckboxListTile(
            //  title: const Text('Is completed'),
            //  value: contact!.isCompleted,
            //  controlAffinity: ListTileControlAffinity.leading,
            //  onChanged: (value) {
            //    setState(() {
            //     contact = contact!.copyWith(isCompleted: value!);
            //    });
            //  },
            //),
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
          child: Text(isNewContact ? 'Create' : 'Save'),
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
        ref.read(contactEditViewModelProvider(widget.contactId).notifier);
    await notifier.updateState(contact!);
    await notifier.save();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
