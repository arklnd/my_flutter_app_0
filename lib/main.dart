import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      theme: FluentThemeData.light().copyWith(
        typography: Typography.raw(
          display: const TextStyle(fontSize: 115.2),
          titleLarge: const TextStyle(fontSize: 48),
          title: const TextStyle(fontSize: 38.4),
          subtitle: const TextStyle(fontSize: 28.8),
          bodyLarge: const TextStyle(fontSize: 21.6),
          body: const TextStyle(fontSize: 16.8),
          bodyStrong: const TextStyle(
            fontSize: 16.8,
            fontWeight: FontWeight.bold,
          ),
          caption: const TextStyle(fontSize: 14.4),
        ),
        iconTheme: const IconThemeData(size: 28.8),
      ),
      darkTheme: FluentThemeData.dark().copyWith(
        typography: Typography.raw(
          display: const TextStyle(fontSize: 115.2),
          titleLarge: const TextStyle(fontSize: 48),
          title: const TextStyle(fontSize: 38.4),
          subtitle: const TextStyle(fontSize: 28.8),
          bodyLarge: const TextStyle(fontSize: 21.6),
          body: const TextStyle(fontSize: 16.8),
          bodyStrong: const TextStyle(
            fontSize: 16.8,
            fontWeight: FontWeight.bold,
          ),
          caption: const TextStyle(fontSize: 14.4),
        ),
        iconTheme: const IconThemeData(size: 28.8),
      ),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          final brightness = MediaQuery.of(context).platformBrightness;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
              statusBarBrightness:
                  brightness == Brightness.dark
                      ? Brightness.dark
                      : Brightness.light,
            ),
            child: const LoginPage(),
          );
        },
      ),
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
      appBar: NavigationAppBar(
        title: const Text('Login to dashboard', style: TextStyle(fontSize: 20)),
        automaticallyImplyLeading: false,
        height: 80,
      ),

      content: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                TextBox(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  placeholder: 'Email',
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),

                const SizedBox(height: 20),

                TextBox(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  placeholder: 'Password',
                  obscureText: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),

                const SizedBox(height: 20),

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

                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    ),
                  ),

                  child: const Text('Login'),
                ),

                const SizedBox(height: 20),

                FilledButton(
                  onPressed: _checkForUpdates,
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    ),
                  ),
                  child: const Text('Check for Updates'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    if (!Platform.isAndroid) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => ContentDialog(
                title: const Text('Updates Unavailable'),
                content: const Text(
                  'Updates are only available on Android devices.',
                ),
                actions: [
                  Button(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
        );
      }
      return;
    }

    // Request storage permission
    Permission permission;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      permission =
          sdkInt >= 30 ? Permission.manageExternalStorage : Permission.storage;
    } else {
      permission = Permission.storage;
    }
    var status = await permission.request();
    if (!status.isGranted) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => ContentDialog(
                title: const Text('Permission Required'),
                content: const Text(
                  'Storage permission is required to download updates.',
                ),
                actions: [
                  if (status.isPermanentlyDenied)
                    Button(
                      child: const Text('Open Settings'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        openAppSettings();
                      },
                    ),
                  Button(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
        );
      }
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
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder:
                  (context) => ContentDialog(
                    title: const Text('No Updates'),
                    content: const Text('No updates are currently available.'),
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
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => ContentDialog(
                  title: const Text('Check Failed'),
                  content: const Text(
                    'Failed to check for updates. Please try again later.',
                  ),
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
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => ContentDialog(
                title: const Text('Error'),
                content: Text('Failed to check for updates: $e'),
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
}
