import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

import 'services/audio_recorder.dart';
import 'services/chatgpt_client.dart';
import 'pages/main_page.dart';
import 'pages/expenses_page.dart';
import 'pages/todo_list_page.dart';
import 'services/todo_repository.dart';

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
      floatingActionButton: _currentIndex == 2
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'fab_add_task',
                  onPressed: () async {
                    final controller = TextEditingController();
                    final title = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Add task'),
                        content: TextField(
                          controller: controller,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          decoration:
                              const InputDecoration(hintText: 'Task title'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(controller.text),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    );
                    if (title != null && title.trim().isNotEmpty) {
                      TodoRepository.instance.add(title.trim());
                    }
                  },
                  tooltip: 'Add task',
                  child: const Icon(Icons.edit),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'fab_mic_on_todo',
                  onPressed: _onFabPressed,
                  tooltip: 'Microphone',
                  child: Icon(_isRecording ? Icons.stop : Icons.mic),
                ),
              ],
            )
          : FloatingActionButton(
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
      TodoRepository.instance.add(text.trim());
    }
  }
}

