extension ListExtensions<T> on List<T> {
  /// Returns the element before the element at [index], wrapping around.
  T previous(int index) => this[(index - 1 + length) % length];

  /// Returns the element after the element at [index], wrapping around.
  T next(int index) => this[(index + 1) % length];

  /// Returns a new list with [element] replaced at [index].
  List<T> replaceAt(int index, T element) {
    final copy = List<T>.from(this);
    copy[index] = element;
    return copy;
  }

  /// Returns a new list with elements replaced where [predicate] is true.
  List<T> replaceWhere(bool Function(T) predicate, T Function(T) replacer) {
    return map((e) => predicate(e) ? replacer(e) : e).toList();
  }

  /// Returns the maximum value by a numeric key.
  int maxBy(int Function(T) key) =>
      isEmpty ? 0 : map(key).reduce((a, b) => a > b ? a : b);
}
