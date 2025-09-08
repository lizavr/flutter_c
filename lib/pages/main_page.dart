import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Page'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 100,
              color: Colors.lightGreen.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Main Page',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.lightGreen),
            ),
            const SizedBox(height: 16),
            Text(
              'This is the main page of your app',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Main page action!'),
                    backgroundColor: Colors.lightGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                foregroundColor: Colors.black,
              ),
              child: const Text('Main Action'),
            ),
          ],
        ),
      ),
    );
  }
}

