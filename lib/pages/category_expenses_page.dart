import 'package:flutter/material.dart';
import '../services/expenses_repository.dart';
import '../widgets/expense_tile.dart';

class CategoryExpensesPage extends StatefulWidget {
  const CategoryExpensesPage({super.key, required this.category});

  final String category;

  @override
  State<CategoryExpensesPage> createState() => _CategoryExpensesPageState();
}

class _CategoryExpensesPageState extends State<CategoryExpensesPage> {
  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1, now.month, now.day);
    final last = DateTime(now.year + 1, now.month, now.day);
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
  }

  Future<void> _addExpenseDialog(
    BuildContext context,
    DateTime preselectedDay,
  ) async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime date = preselectedDay;
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(hintText: 'Amount'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Category: ${widget.category}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Note (optional)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await _pickDate(ctx, date);
                      if (picked != null) {
                        date = DateTime(picked.year, picked.month, picked.day);
                      }
                    },
                    child: const Text('Change date'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (res == true) {
      final title = titleCtrl.text.trim();
      final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
      final note = noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim();
      if (title.isNotEmpty && amount > 0) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          DateTime.now().hour,
          DateTime.now().minute,
        );
        ExpensesRepository.instance.add(
          title: title,
          amount: amount,
          date: dateTime,
          category: widget.category,
          note: note,
        );
      }
    }
  }

  Future<void> _editExpenseDialog(
    BuildContext context,
    ExpenseItem item,
  ) async {
    final titleCtrl = TextEditingController(text: item.title);
    final amountCtrl = TextEditingController(
      text: item.amount.toStringAsFixed(2),
    );
    final noteCtrl = TextEditingController(text: item.note ?? '');
    DateTime date = item.day;
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(hintText: 'Amount'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Category: ${widget.category}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Note (optional)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await _pickDate(ctx, date);
                      if (picked != null) {
                        date = DateTime(picked.year, picked.month, picked.day);
                      }
                    },
                    child: const Text('Change date'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (res == true) {
      final title = titleCtrl.text.trim();
      final amount = double.tryParse(amountCtrl.text.trim()) ?? item.amount;
      final note = noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim();
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        item.date.hour,
        item.date.minute,
      );
      final updated = item.copyWith(
        title: title.isEmpty ? item.title : title,
        amount: amount,
        note: note,
        date: dateTime,
        category: widget.category,
      );
      ExpensesRepository.instance.update(item.id, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ExpensesRepository.instance,
      builder: (context, _) {
        final repo = ExpensesRepository.instance;
        final grouped = <DateTime, List<ExpenseItem>>{};
        for (final e in repo.items) {
          if (e.category == widget.category) {
            (grouped[e.day] ??= <ExpenseItem>[]).add(e);
          }
        }
        final days = grouped.keys.toList();
        final today = DateTime.now();
        final todayKey = DateTime(today.year, today.month, today.day);
        days.sort((a, b) => b.compareTo(a));
        if (days.contains(todayKey)) {
          days.remove(todayKey);
          days.insert(0, todayKey);
        }

        return Scaffold(
          appBar: AppBar(title: Text(widget.category), centerTitle: true),
          body: days.isEmpty
              ? _EmptyCategoryView(
                  category: widget.category,
                  onAdd: () async {
                    final now = DateTime.now();
                    final day = DateTime(now.year, now.month, now.day);
                    final picked = await _pickDate(context, day);
                    if (picked == null) return;
                    await _addExpenseDialog(context, picked);
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final items = grouped[day]!
                      ..sort((a, b) => b.date.compareTo(a.date));
                    final isToday = _isSameDay(day, DateTime.now());
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoryDayHeader(
                          day: day,
                          isToday: isToday,
                          onAdd: () async {
                            final picked = await _pickDate(context, day);
                            if (picked == null) return;
                            await _addExpenseDialog(context, picked);
                          },
                          onDelete: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete day in category'),
                                content: const Text(
                                  'Delete all expenses for this day in this category?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              final all = List.of(
                                ExpensesRepository.instance.items,
                              );
                              for (final e in all) {
                                if (e.category == widget.category &&
                                    e.day == day) {
                                  ExpensesRepository.instance.remove(e.id);
                                }
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        ...items.map(
                          (e) => ExpenseTile(
                            item: e,
                            onEdit: () => _editExpenseDialog(context, e),
                            onDelete: () => repo.remove(e.id),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _EmptyCategoryView extends StatelessWidget {
  const _EmptyCategoryView({required this.category, required this.onAdd});
  final String category;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CategoryDayHeader(
          day: day,
          isToday: true,
          onAdd: onAdd,
          onDelete: () {},
        ),
        const SizedBox(height: 8),
        const Text(
          'No expenses yet in this category. Use + to add your first one.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _CategoryDayHeader extends StatelessWidget {
  const _CategoryDayHeader({
    required this.day,
    required this.isToday,
    required this.onAdd,
    required this.onDelete,
  });

  final DateTime day;
  final bool isToday;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final label = isToday
        ? 'Today'
        : '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.lightGreen),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Add',
          onPressed: onAdd,
          icon: const Icon(Icons.add, color: Colors.lightGreen),
        ),
        IconButton(
          tooltip: 'Delete',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
        ),
      ],
    );
  }
}
