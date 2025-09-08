import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

import 'services/audio_recorder.dart';
import 'services/chatgpt_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses & Todo App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.lightGreen,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.lightGreen,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.black,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _recorder = AudioRecorderService();
  final _client = ChatGptClient();
  bool _isRecording = false;

  final List<Widget> _pages = [
    const MainPage(),
    const ExpensesPage(),
    const TodoListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Main'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'TodoList',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        tooltip: 'Microphone',
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }

  Future<void> _onFabPressed() async {
    if (_isRecording) {
      final bytes = await _recorder.stop();
      setState(() => _isRecording = false);
      if (bytes != null) {
        await _sendToChatGpt(bytes);
      } else {
        debugPrint('No audio captured');
      }
      return;
    }

    final granted = await Permission.microphone.request();
    if (!granted.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied.')),
      );
      return;
    }
    final ok = await _recorder.start();
    if (ok) {
      setState(() => _isRecording = true);
    } else {
      debugPrint('Failed to start recording');
    }
  }

  Future<void> _sendToChatGpt(Uint8List bytes) async {
    final text = await _client.sendAudioBytes(bytes);
    if (text == null || text.trim().isEmpty) {
      debugPrint('ChatGPT returned empty response');
    } else {
      debugPrint('ChatGPT: $text');
    }
  }
}

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

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Expenses',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.lightGreen),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.lightGreen,
                      ),
                      title: Text(
                        'Expense ${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '\$${(index + 1) * 25}.00',
                        style: const TextStyle(
                          color: Colors.lightGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Tasks',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.lightGreen),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        index % 2 == 0
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: index % 2 == 0 ? Colors.lightGreen : Colors.grey,
                      ),
                      title: Text(
                        'Task ${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: index % 2 == 0
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        'Description for task ${index + 1}',
                        style: TextStyle(
                          color: Colors.grey,
                          decoration: index % 2 == 0
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: Icon(Icons.more_vert, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
