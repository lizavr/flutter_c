import 'package:flutter/material.dart';
import '../services/expenses_repository.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  final ExpenseItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(
          Icons.account_balance_wallet,
          color: Colors.lightGreen,
        ),
        title: Text(
          item.title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '\$${item.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.lightGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit, color: Colors.grey, size: 18),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
