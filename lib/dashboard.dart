import 'package:fluent_ui/fluent_ui.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text('Dashboard', style: TextStyle(fontSize: 20)),
        automaticallyImplyLeading: true,
        height: 80,
      ),
      content: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the Dashboard!',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Preview Feature 1'),
                      const SizedBox(height: 10),
                      const Text('This is a preview of the dashboard.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Preview Feature 2'),
                      const SizedBox(height: 10),
                      const Text('More content can be added here.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
