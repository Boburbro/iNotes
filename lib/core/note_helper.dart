class ListHelper {
  static void addItem<T>(
    List<T> items,
    T newItem, {
    bool Function(T)? uniqueChecker,
  }) {
    if (uniqueChecker == null || !items.any(uniqueChecker)) {
      items.insert(0, newItem);
    }
  }

  static void updateItem<T>(
    List<T> items,
    bool Function(T) matcher,
    T updatedItem,
  ) {
    final index = items.indexWhere(matcher);
    if (index != -1) {
      items[index] = updatedItem;
    }
  }

  static void removeItem<T>(
    List<T> items,
    bool Function(T) matcher,
  ) {
    final index = items.indexWhere(matcher);
    if (index != -1) {
      items.removeAt(index);
    }
  }

  static void incrementCount<T>(
    List<T> items,
    bool Function(T) matcher,
    int Function(T) getCount,
    T Function(T, int) updateCount,
  ) {
    final index = items.indexWhere(matcher);
    if (index != -1) {
      final item = items[index];
      items[index] = updateCount(item, getCount(item) + 1);
    }
  }

  static void decrementCount<T>(
    List<T> items,
    bool Function(T) matcher,
    int Function(T) getCount,
    T Function(T, int) updateCount,
  ) {
    final index = items.indexWhere(matcher);
    if (index != -1) {
      final item = items[index];
      items[index] = updateCount(item, getCount(item) - 1);
    }
  }
}
