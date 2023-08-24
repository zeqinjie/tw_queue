enum TWPriority {
  superHigh,
  high,
  middle,
  low,
  superLow,
}

class TWPriorityList<T> {
  final Map<TWPriority, List<T>> _containers = {
    TWPriority.superHigh: [],
    TWPriority.high: [],
    TWPriority.middle: [],
    TWPriority.low: [],
    TWPriority.superLow: [],
  };

  List<T> get _allObjects => [
        ..._containers[TWPriority.superHigh]!,
        ..._containers[TWPriority.high]!,
        ..._containers[TWPriority.middle]!,
        ..._containers[TWPriority.low]!,
        ..._containers[TWPriority.superLow]!,
      ];

  List<T> get list => _allObjects;

  int get length => _allObjects.length;

  T get last => _allObjects.last;
  T get first => _allObjects.first;

  bool get isNotEmpty => _allObjects.isNotEmpty;

  bool get isEmpty => _allObjects.isEmpty;

  insert(
    T object, {
    TWPriority priority = TWPriority.middle,
    bool repeatability = true,
  }) {
    if (!repeatability) {
      remove(object);
    }
    _containers[priority]!.insert(0, object);
  }

  add(
    T object, {
    TWPriority priority = TWPriority.middle,
    bool repeatability = true,
  }) {
    if (!repeatability) {
      remove(object);
    }
    _containers[priority]!.add(object);
  }

  addToSuperHigh(T object) => add(object, priority: TWPriority.superHigh);

  addToHigh(T object) => add(object, priority: TWPriority.high);

  addToMiddle(T object) => add(object, priority: TWPriority.middle);

  addToLow(T object) => add(object, priority: TWPriority.low);

  addToSuperLow(T object) => add(object, priority: TWPriority.superLow);

  removeWhere(bool Function(T element) test) {
    _containers.values.forEach((container) {
      container.removeWhere(test);
    });
  }

  remove(
    T object, {
    TWPriority? priority,
  }) {
    if (priority != null) {
      _containers[priority]!.remove(object);
    } else {
      for (final container in _containers.values) {
        container.remove(object);
      }
    }
  }

  removeFromSuperHigh(T object) => remove(
        object,
        priority: TWPriority.superHigh,
      );

  removeFromHigh(T object) => remove(object, priority: TWPriority.high);

  removeFromMiddle(T object) => remove(object, priority: TWPriority.middle);

  removeFromLow(T object) => remove(object, priority: TWPriority.low);

  removeFromSuperLow(T object) => remove(object, priority: TWPriority.superLow);

  T operator [](int index) {
    return _allObjects[index];
  }
}
