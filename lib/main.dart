import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      routes: {
        '/dashboard': (context) => const PageWrapper(child: DashboardPage()),
      },
      theme: FluentThemeData.light().copyWith(
        typography: Typography.raw(
          display: const TextStyle(fontSize: 115.2, color: Colors.black),
          titleLarge: const TextStyle(fontSize: 48, color: Colors.black),
          title: const TextStyle(fontSize: 38.4, color: Colors.black),
          subtitle: const TextStyle(fontSize: 28.8, color: Colors.black),
          bodyLarge: const TextStyle(fontSize: 21.6, color: Colors.black),
          body: const TextStyle(fontSize: 16.8, color: Colors.black),
          bodyStrong: const TextStyle(
            fontSize: 16.8,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          caption: const TextStyle(fontSize: 14.4, color: Colors.black),
        ),
        iconTheme: const IconThemeData(size: 28.8, color: Colors.black),
      ),
      darkTheme: FluentThemeData.dark().copyWith(
        typography: Typography.raw(
          display: const TextStyle(fontSize: 115.2, color: Colors.white),
          titleLarge: const TextStyle(fontSize: 48, color: Colors.white),
          title: const TextStyle(fontSize: 38.4, color: Colors.white),
          subtitle: const TextStyle(fontSize: 28.8, color: Colors.white),
          bodyLarge: const TextStyle(fontSize: 21.6, color: Colors.white),
          body: const TextStyle(fontSize: 16.8, color: Colors.white),
          bodyStrong: const TextStyle(
            fontSize: 16.8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          caption: const TextStyle(fontSize: 14.4, color: Colors.white),
        ),
        iconTheme: const IconThemeData(size: 28.8, color: Colors.white),
      ),
      themeMode: ThemeMode.system,
      home: const PageWrapper(child: LoginPage()),
    );
  }
}

class PageWrapper extends StatelessWidget {
  final Widget child;

  const PageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            brightness == Brightness.dark ? Brightness.dark : Brightness.light,
      ),
      child: child,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
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
                    Navigator.of(
                      context,
                    ).pushNamed('/dashboard', arguments: _emailController.text);
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
                title: const Text(
                  'Updates Unavailable',
                  style: TextStyle(fontSize: 18),
                ),
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
                title: const Text(
                  'Permission Required',
                  style: TextStyle(fontSize: 18),
                ),
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
          // Sort by created_at descending to get the latest uploaded asset
          apkAssets.sort(
            (a, b) => DateTime.parse(
              b['created_at'],
            ).compareTo(DateTime.parse(a['created_at'])),
          );
          final latestApk = apkAssets.first;

          // Check if already up to date
          final packageInfo = await PackageInfo.fromPlatform();
          final currentVersion = packageInfo.version;
          final currentCommit = currentVersion.split('-').last;
          final apkName = latestApk['name'];
          final nameWithoutExt = apkName.replaceAll('.apk', '');
          final lastDash = nameWithoutExt.lastIndexOf('-');
          final commitPart = nameWithoutExt.substring(lastDash + 1);
          final apkCommit = commitPart.split('_').first;
          if (currentCommit == apkCommit) {
            if (mounted) {
              showDialog(
                context: context,
                builder:
                    (context) => ContentDialog(
                      title: const Text(
                        'Already Up to Date',
                        style: TextStyle(fontSize: 18),
                      ),
                      content: const Text(
                        'You are already running the latest version.',
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

          final downloadUrl = latestApk['browser_download_url'];
          final fileName = latestApk['name'];

          // Download
          final dir = await getExternalStorageDirectory();
          final filePath = '${dir!.path}/$fileName';
          await Dio().download(downloadUrl, filePath);

          // Show success dialog with install option
          if (mounted) {
            showDialog(
              context: context,
              builder:
                  (context) => ContentDialog(
                    title: const Text(
                      'Update Downloaded',
                      style: TextStyle(fontSize: 18),
                    ),
                    content: Text(
                      'Latest APK downloaded to $filePath. Would you like to install it now?',
                    ),
                    actions: [
                      Button(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      FilledButton(
                        child: const Text('Install'),
                        onPressed: () {
                          OpenFile.open(filePath);
                          Navigator.of(context).pop();
                        },
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
                    title: const Text(
                      'No Updates',
                      style: TextStyle(fontSize: 18),
                    ),
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
                  title: const Text(
                    'Check Failed',
                    style: TextStyle(fontSize: 18),
                  ),
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
                title: const Text('Error', style: TextStyle(fontSize: 18)),
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
