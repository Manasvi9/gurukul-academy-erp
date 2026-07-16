import '../models/result.dart';

abstract interface class OfflineQueue<T> {
  Future<Result<void>> enqueue(T item);

  Future<Result<List<T>>> pendingItems();

  Future<Result<void>> remove(String id);
}
