import 'package:flutter/material.dart';
import '../services/todo_repository.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TodoRepository.instance,
      builder: (context, _) => Scaffold(
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
                child: TodoRepository.instance.todos.isEmpty
                    ? const Center(
                        child: Text(
                          'No todos yet. Speak or add one.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: TodoRepository.instance.todos.length,
                        itemBuilder: (context, index) {
                          final item = TodoRepository.instance.todos[index];
                          return Dismissible(
                            key: ValueKey('${item.title}-$index'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              color: Colors.redAccent.withOpacity(0.6),
                              child: const Icon(Icons.close, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              TodoRepository.instance.removeAt(index);
                            },
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                _TodoTile(index: index, item: item),
                                IconButton(
                                  tooltip: 'Delete',
                                  icon: const Icon(Icons.close, color: Colors.grey),
                                  onPressed: () =>
                                      TodoRepository.instance.removeAt(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'fab_add_todo',
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
                  decoration: const InputDecoration(hintText: 'Task title'),
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
            if (title != null && title.trim().isNotEmpty) {
              TodoRepository.instance.add(title.trim());
            }
          },
          tooltip: 'Add task',
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}

class _TodoTile extends StatefulWidget {
  const _TodoTile({required this.index, required this.item});

  final int index;
  final TodoItem item;

  @override
  State<_TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<_TodoTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  @override
  void didUpdateWidget(covariant _TodoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.isDone != widget.item.isDone) {
      if (widget.item.isDone) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.item.isDone) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    TodoRepository.instance.toggleAt(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.lightGreen,
                      width: 2,
                    ),
                    color: widget.item.isDone
                        ? Colors.lightGreen
                        : Colors.transparent,
                  ),
                  child: widget.item.isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Stack(
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _StrikeThroughPainter(
                                progress: _controller.value,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrikeThroughPainter extends CustomPainter {
  _StrikeThroughPainter({required this.progress, required this.color});

  final double progress; // 0..1
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    final endX = size.width * progress;
    canvas.drawLine(Offset(0, y), Offset(endX, y), paint);
  }

  @override
  bool shouldRepaint(covariant _StrikeThroughPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

