import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',

      theme: FluentThemeData(),

      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(title: const Text('Login to dashboard')),

      content: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                TextBox(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  placeholder: 'Email',
                ),

                const SizedBox(height: 16),

                TextBox(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  placeholder: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 16),

                FilledButton(
                  onPressed: () {
                    // Use Fluent UI's ContentDialog

                    showDialog(
                      context: context,

                      builder:
                          (context) => ContentDialog(
                            title: const Text('Welcome'),

                            content: Text('Welcome, ${_emailController.text}!'),

                            actions: [
                              Button(
                                child: const Text('OK'),

                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                    );
                  },

                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
