import 'package:flutter/foundation.dart';

class TodoItem {
  TodoItem({required this.title, this.isDone = false});

  final String title;
  final bool isDone;

  TodoItem copyWith({String? title, bool? isDone}) =>
      TodoItem(title: title ?? this.title, isDone: isDone ?? this.isDone);
}

class TodoRepository extends ChangeNotifier {
  TodoRepository._();
  static final TodoRepository instance = TodoRepository._();

  final List<TodoItem> _todos = <TodoItem>[];

  List<TodoItem> get todos => List.unmodifiable(_todos);

  void add(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    _todos.insert(0, TodoItem(title: trimmed));
    notifyListeners();
  }

  void toggleAt(int index) {
    if (index < 0 || index >= _todos.length) return;
    final current = _todos[index];
    _todos[index] = current.copyWith(isDone: !current.isDone);
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _todos.length) return;
    _todos.removeAt(index);
    notifyListeners();
  }
}

