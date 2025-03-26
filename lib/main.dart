import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/contact/contact_list_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(child: MaterialApp(home: AuthenticationWrapper())),
  );
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ContactListPage();
  }
}

class AuthenticationWrapper extends ConsumerWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (user) {
        return user == null ? const SignInPage() : const MainPage();
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text('Error'))),
    );
  }
}

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}


// Como vai ter autenticação, o usuário vai ter um id, então o id vai ser passado para o contactListViewModelProvider
// e o usuário vai ter que acessar só os dados do cadastro dele
// e o contactListViewModelProvider vai ter que ser modificado para receber o id do usuário