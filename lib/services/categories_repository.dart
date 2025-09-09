import 'package:flutter/foundation.dart';

class CategoriesRepository extends ChangeNotifier {
  CategoriesRepository._() {
    essential.addAll(const [
      'Housing',
      'Food & groceries',
      'Transportation',
      'Communication & internet',
      'Healthcare',
      'Education',
      'Financial obligations',
    ]);
    nonEssential.addAll(const [
      'Dining out & food delivery',
      'Clothing & footwear',
      'Entertainment & leisure',
      'Travel & vacations',
      'Personal care',
      'Sports & fitness',
    ]);
  }

  static final CategoriesRepository instance = CategoriesRepository._();

  final List<String> essential = <String>[];
  final List<String> nonEssential = <String>[];

  void addEssential(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    essential.add(n);
    notifyListeners();
  }

  void addNonEssential(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    nonEssential.add(n);
    notifyListeners();
  }

  void moveToEssential(String name) {
    if (nonEssential.remove(name)) {
      essential.add(name);
      notifyListeners();
    }
  }

  void moveToNonEssential(String name) {
    if (essential.remove(name)) {
      nonEssential.add(name);
      notifyListeners();
    }
  }

  void rename(String oldName, String newName) {
    final n = newName.trim();
    if (n.isEmpty) return;
    final i1 = essential.indexOf(oldName);
    if (i1 != -1) {
      essential[i1] = n;
      notifyListeners();
      return;
    }
    final i2 = nonEssential.indexOf(oldName);
    if (i2 != -1) {
      nonEssential[i2] = n;
      notifyListeners();
      return;
    }
  }

  void remove(String name) {
    final removed = essential.remove(name) || nonEssential.remove(name);
    if (removed) notifyListeners();
  }

  void reorderInEssential(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= essential.length) return;
    if (newIndex < 0 || newIndex >= essential.length) return;
    final item = essential.removeAt(oldIndex);
    essential.insert(newIndex, item);
    notifyListeners();
  }

  void reorderInNonEssential(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= nonEssential.length) return;
    if (newIndex < 0 || newIndex >= nonEssential.length) return;
    final item = nonEssential.removeAt(oldIndex);
    nonEssential.insert(newIndex, item);
    notifyListeners();
  }

  // Aliases per spec
  void reorderEssential(int oldIndex, int newIndex) =>
      reorderInEssential(oldIndex, newIndex);
  void reorderNonEssential(int oldIndex, int newIndex) =>
      reorderInNonEssential(oldIndex, newIndex);
}
