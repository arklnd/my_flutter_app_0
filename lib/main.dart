import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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
      darkTheme: FluentThemeData.dark(),
      themeMode: ThemeMode.system,
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
  void initState() {
    super.initState();
    _checkForUpdates();
  }

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

  Future<void> _checkForUpdates() async {
    if (!Platform.isAndroid) return;

    // Request storage permission
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      // Handle permission denied
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/arklnd/my_flutter_app_0/releases/latest',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final assets = data['assets'] as List;
        // Find APK assets
        final apkAssets =
            assets.where((asset) => asset['name'].endsWith('.apk')).toList();
        if (apkAssets.isNotEmpty) {
          // Sort by name descending to get the latest (assuming names include commit hash)
          apkAssets.sort((a, b) => b['name'].compareTo(a['name']));
          final latestApk = apkAssets.first;
          final downloadUrl = latestApk['browser_download_url'];
          final fileName = latestApk['name'];

          // Download
          final dir = await getExternalStorageDirectory();
          final filePath = '${dir!.path}/$fileName';
          await Dio().download(downloadUrl, filePath);

          // Show success dialog
          if (mounted) {
            showDialog(
              context: context,
              builder:
                  (context) => ContentDialog(
                    title: const Text('Update Downloaded'),
                    content: Text('Latest APK downloaded to $filePath'),
                    actions: [
                      Button(
                        child: const Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
            );
          }
        }
      }
    } catch (e) {
      // Handle error
    }
  }
}
