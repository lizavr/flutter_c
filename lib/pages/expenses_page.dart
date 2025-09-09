import 'package:flutter/material.dart';
import '../services/expenses_repository.dart';
import '../services/categories_repository.dart';
import '../widgets/expense_tile.dart';
import 'category_expenses_page.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage>
    with SingleTickerProviderStateMixin {
  bool _isCategoriesEditMode = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expenses'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Expenses'),
              Tab(text: 'Categories'),
            ],
          ),
          actions: [
            Builder(
              builder: (context) {
                final tabIndex = DefaultTabController.of(context).index;
                if (tabIndex == 1) {
                  return IconButton(
                    tooltip: _isCategoriesEditMode ? 'Done' : 'Edit',
                    icon: Icon(
                      _isCategoriesEditMode ? Icons.check : Icons.edit,
                    ),
                    onPressed: () {
                      setState(() {
                        _isCategoriesEditMode = !_isCategoriesEditMode;
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _AllExpensesTab(),
            _CategoriesTab(),
          ],
        ),
      ),
    );
  }
}

class _AllExpensesTab extends StatelessWidget {
  const _AllExpensesTab();

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
    final categoryCtrl = TextEditingController();
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
              TextField(
                controller: categoryCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Category'),
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
      final category = categoryCtrl.text.trim().isEmpty
          ? null
          : categoryCtrl.text.trim();
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
          category: category,
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
    final categoryCtrl = TextEditingController(text: item.category ?? '');
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
              TextField(
                controller: categoryCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Category'),
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
      final category = categoryCtrl.text.trim().isEmpty
          ? null
          : categoryCtrl.text.trim();
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
        category: category,
        note: note,
        date: dateTime,
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
        final days = repo.sortedDaysTodayFirst();
        if (days.isEmpty) {
          final today = DateTime.now();
          final day = DateTime(today.year, today.month, today.day);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DayHeader(
                day: day,
                isToday: true,
                onAdd: () async {
                  final picked = await _pickDate(context, day);
                  if (picked == null) return;
                  await _addExpenseDialog(context, picked);
                },
                onDelete: () {},
                onEdit: () {},
              ),
              const SizedBox(height: 8),
              const Text(
                'No expenses yet. Use + to add your first one.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          );
        }

        final grouped = repo.groupedByDay();
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final items = grouped[day]!..sort((a, b) => b.date.compareTo(a.date));
            final isToday = _isSameDay(day, DateTime.now());
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DayHeader(
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
                        title: const Text('Delete day'),
                        content: const Text(
                          'Delete all expenses for this day?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      ExpensesRepository.instance.removeByDay(day);
                    }
                  },
                  onEdit: () {},
                ),
                const SizedBox(height: 8),
                ...items.map(
                  (e) => ExpenseTile(
                    item: e,
                    onEdit: () => _editExpenseDialog(context, e),
                    onDelete: () => ExpensesRepository.instance.remove(e.id),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.isToday,
    required this.onAdd,
    required this.onDelete,
    required this.onEdit,
  });

  final DateTime day;
  final bool isToday;
  final VoidCallback onAdd;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final label = isToday
        ? 'Today'
        : '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.lightGreen),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Add',
          onPressed: onAdd,
          icon: const Icon(Icons.add, color: Colors.lightGreen),
        ),
        // Per-item editing only; header Edit removed
        // IconButton(
        //   tooltip: 'Edit',
        //   onPressed: onEdit,
        //   icon: const Icon(Icons.edit, color: Colors.grey),
        // ),
        IconButton(
          tooltip: 'Delete',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
        ),
      ],
    );
  }
}

// Categories tab (unchanged except navigation)
class _CategoriesTab extends StatefulWidget {
  const _CategoriesTab();

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  bool _editMode = false;

  Future<void> _addDialog({required bool isEssential}) async {
    final controller = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEssential ? 'Add essential' : 'Add non-essential'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    final name = res?.trim();
    if (name == null || name.isEmpty) return;
    if (isEssential) {
      CategoriesRepository.instance.addEssential(name);
    } else {
      CategoriesRepository.instance.addNonEssential(name);
    }
  }

  void _toggleEdit() => setState(() => _editMode = !_editMode);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CategoriesRepository.instance,
      builder: (context, _) {
        final repo = CategoriesRepository.instance;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Categories',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.lightGreen),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: _editMode ? 'Done' : 'Edit',
                    icon: Icon(_editMode ? Icons.check : Icons.edit),
                    onPressed: _toggleEdit,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _CategoryColumn(
                        title: 'Essential',
                        items: repo.essential,
                        onAdd: () => _addDialog(isEssential: true),
                        onMoveIn: (name) => repo.moveToEssential(name),
                        editMode: _editMode,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CategoryColumn(
                        title: 'Non-essential',
                        items: repo.nonEssential,
                        onAdd: () => _addDialog(isEssential: false),
                        onMoveIn: (name) => repo.moveToNonEssential(name),
                        editMode: _editMode,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryColumn extends StatelessWidget {
  const _CategoryColumn({
    required this.title,
    required this.items,
    required this.onAdd,
    required this.onMoveIn,
    required this.editMode,
  });

  final String title;
  final List<String> items;
  final VoidCallback onAdd;
  final void Function(String name) onMoveIn;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.lightGreen),
            ),
          ),
          Expanded(
            child: DragTarget<String>(
              onWillAccept: (_) => true,
              onAccept: (payload) {
                final parts = payload.split('|');
                if (parts.length != 2) return;
                final src = parts[0];
                final name = parts[1];
                if ((title == 'Essential' && src == 'E') ||
                    (title == 'Non-essential' && src == 'N')) {
                  final list = items;
                  final oldIndex = list.indexOf(name);
                  if (oldIndex != -1) {
                    final newIndex = list.length - 1;
                    if (title == 'Essential') {
                      CategoriesRepository.instance
                          .reorderInEssential(oldIndex, newIndex);
                    } else {
                      CategoriesRepository.instance
                          .reorderInNonEssential(oldIndex, newIndex);
                    }
                  }
                } else {
                  onMoveIn(name);
                }
              },
              builder: (context, candidate, rejected) => ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final name = items[index];
                  return Column(
                    children: [
                      DragTarget<String>(
                        onWillAccept: (_) => true,
                        onAccept: (payload) {
                          final parts = payload.split('|');
                          if (parts.length != 2) return;
                          final src = parts[0];
                          final dragged = parts[1];
                          if ((title == 'Essential' && src == 'E') ||
                              (title == 'Non-essential' && src == 'N')) {
                            final list = items;
                            final oldIndex = list.indexOf(dragged);
                            if (oldIndex == -1) return;
                            var newIndex = index;
                            if (oldIndex < newIndex) newIndex -= 1;
                            if (title == 'Essential') {
                              CategoriesRepository.instance
                                  .reorderInEssential(oldIndex, newIndex);
                            } else {
                              CategoriesRepository.instance
                                  .reorderInNonEssential(oldIndex, newIndex);
                            }
                          } else {
                            onMoveIn(dragged);
                          }
                        },
                        builder: (context, c, r) => const SizedBox.shrink(),
                      ),
                      LongPressDraggable<String>(
                        data: (title == 'Essential' ? 'E|' : 'N|') + name,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _CategoryChip(
                            name: name,
                            editMode: false,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: _CategoryChip(
                            name: name,
                            editMode: editMode,
                          ),
                        ),
                        child: _CategoryChip(
                          name: name,
                          editMode: editMode,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.lightGreen),
            label: const Text(
              'Add category',
              style: TextStyle(color: Colors.lightGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.name, required this.editMode});

  final String name;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: editMode
          ? () async {
              final controller = TextEditingController(text: name);
              final action = await showDialog<_EditAction>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Edit category'),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(_EditAction.cancel),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(_EditAction.delete),
                      child: const Text('Delete'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(_EditAction.save),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (action == _EditAction.save) {
                CategoriesRepository.instance.rename(name, controller.text);
              } else if (action == _EditAction.delete) {
                CategoriesRepository.instance.remove(name);
              }
            }
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryExpensesPage(category: name),
                ),
              );
            },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: editMode
                ? Colors.lightGreen.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (editMode)
              const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

enum _EditAction { cancel, save, delete }

