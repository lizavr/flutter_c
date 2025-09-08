import 'package:flutter/material.dart';

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
                      trailing: const Icon(Icons.more_vert, color: Colors.grey),
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

