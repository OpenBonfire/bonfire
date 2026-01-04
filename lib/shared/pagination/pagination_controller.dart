import 'package:bonfire/shared/logging/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationHelper<T> {
  PaginationHelper({
    required this.pageSize,
    required this.getState,
    required this.setState,
    required this.fetchPage,
    required this.getId,
    this.getDate,
    this.shouldIncludeInList,
    this.debugName,
  });

  final int pageSize;

  final AsyncValue<List<T>?> Function() getState;

  final void Function(AsyncValue<List<T>?> newState) setState;

  final Future<List<T>> Function(int page, int limit, T? cursor) fetchPage;

  /// Function to extract unique ID from an item
  final dynamic Function(T item) getId;

  /// Extract date from an item (for date-based sorting)
  final DateTime? Function(T item)? getDate;

  /// Filter function to determine if item should be included
  final bool Function(T item)? shouldIncludeInList;

  final String? debugName;

  int _currentPage = 0;
  bool _isLoadingMore = false;

  Future<List<T>?> initialize() async {
    final currentState = getState();

    final existingItems = currentState.value;
    if (existingItems != null && existingItems.isNotEmpty) {
      _currentPage = ((existingItems.length - 1) / pageSize).floor();
      return existingItems;
    }

    _currentPage = 0;
    try {
      final items = await fetchPage(_currentPage, pageSize, null);
      return _filterItems(items);
    } catch (e, st) {
      logger.error(e.toString(), st);
      return null;
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) {
      return;
    }

    final currentItems = getState().value;
    if (currentItems == null || currentItems.isEmpty) {
      return;
    }

    _isLoadingMore = true;
    try {
      _currentPage++;

      final cursor = currentItems.last;
      final newItems = await fetchPage(_currentPage, pageSize, cursor);

      final filteredNewItems = _filterItems(newItems);

      if (filteredNewItems.isNotEmpty) {
        setState(AsyncValue.data([...currentItems, ...filteredNewItems]));
      }
    } catch (e, st) {
      logger.error('Error loading more', e, st);
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }

  void syncAdd(T item) {
    final currentItems = getState().value;
    if (currentItems == null) return;

    final itemId = getId(item);
    if (currentItems.any((existing) => getId(existing) == itemId)) {
      logger.warning('syncAdd: Item with id $itemId already exists, skipping');
      return;
    }

    if (shouldIncludeInList != null && !shouldIncludeInList!(item)) {
      logger.warning('syncAdd: Item filtered out by shouldIncludeInList');
      return;
    }

    List<T> updatedList;

    if (getDate != null) {
      final itemDate = getDate!(item);
      if (itemDate == null) {
        updatedList = [...currentItems, item];
      } else {
        final insertIndex = currentItems.indexWhere((existing) {
          final existingDate = getDate!(existing);
          return existingDate == null || itemDate.isBefore(existingDate);
        });

        if (insertIndex == -1) {
          updatedList = [...currentItems, item];
        } else {
          updatedList = [
            ...currentItems.sublist(0, insertIndex),
            item,
            ...currentItems.sublist(insertIndex),
          ];
        }
      }
    } else {
      updatedList = [...currentItems, item];
    }

    setState(AsyncValue.data(updatedList));
    logger.info('syncAdd: Added item, total items: ${updatedList.length}');
  }

  void syncUpdate(T updatedItem) {
    final currentItems = getState().value;
    if (currentItems == null) return;

    final updatedId = getId(updatedItem);
    final updatedList = currentItems.map((item) {
      return getId(item) == updatedId ? updatedItem : item;
    }).toList();

    setState(AsyncValue.data(updatedList));
    logger.info('syncUpdate: Updated item with id $updatedId');
  }

  void syncRemove(dynamic itemId) {
    final currentItems = getState().value;
    if (currentItems == null) return;

    final updatedList = currentItems
        .where((item) => getId(item) != itemId)
        .toList();

    setState(AsyncValue.data(updatedList));
    logger.info(
      'syncRemove: Removed item with id $itemId, total items: ${updatedList.length}',
    );
  }

  // this is very bad I feel
  // somehow I think we should just do this with invalidate
  Future<void> refresh() async {
    _currentPage = 0;
    _isLoadingMore = false;
    setState(const AsyncValue.loading());
    logger.info('refresh: Refreshing from beginning');

    try {
      final items = await fetchPage(_currentPage, pageSize, null);
      setState(AsyncValue.data(_filterItems(items)));
      logger.info('refresh: Loaded ${items.length} items');
    } catch (e, stack) {
      logger.info('Error in refresh: $e');
      setState(AsyncValue.error(e, stack));
    }
  }

  List<T> _filterItems(List<T> items) {
    if (shouldIncludeInList == null) return items;
    return items.where(shouldIncludeInList!).toList();
  }
}
