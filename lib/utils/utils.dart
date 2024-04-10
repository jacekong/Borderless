


class UniqueId {
  static int createUniqueId() {
  return DateTime.now().microsecondsSinceEpoch.remainder(5);
}
}