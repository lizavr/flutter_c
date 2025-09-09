import 'package:flutter/foundation.dart';

class ExpenseItem {
  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category,
    this.note,
  });

  final String id;
  final String title; // fallback/title shown in UI
  final double amount;
  final DateTime date; // full timestamp
  final String? category;
  final String? note;

  DateTime get day => DateTime(date.year, date.month, date.day);

  ExpenseItem copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? note,
  }) => ExpenseItem(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        category: category ?? this.category,
        note: note ?? this.note,
      );
}

class ExpensesRepository extends ChangeNotifier {
  ExpensesRepository._();
  static final ExpensesRepository instance = ExpensesRepository._();

  final List<ExpenseItem> _items = <ExpenseItem>[];

  List<ExpenseItem> get items => List.unmodifiable(_items);

  void add({
    required String title,
    required double amount,
    required DateTime date,
    String? category,
    String? note,
  }) {
    final item = ExpenseItem(
      id: UniqueKey().toString(),
      title: title.trim(),
      amount: amount,
      date: date,
      category: category,
      note: note?.trim().isEmpty == true ? null : note,
    );
    _items.add(item);
    notifyListeners();
  }

  void update(String id, ExpenseItem updated) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _items[index] = updated;
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void removeByDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    _items.removeWhere((e) => e.day == d);
    notifyListeners();
  }

  Map<DateTime, List<ExpenseItem>> groupedByDay() {
    final map = <DateTime, List<ExpenseItem>>{};
    for (final e in _items) {
      final key = e.day;
      (map[key] ??= <ExpenseItem>[]).add(e);
    }
    return map;
  }

  List<DateTime> sortedDaysTodayFirst() {
    final days = groupedByDay().keys.toList();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    days.sort((a, b) => b.compareTo(a));
    if (days.contains(todayKey)) {
      days.remove(todayKey);
      return [todayKey, ...days];
    }
    return days;
  }
}
