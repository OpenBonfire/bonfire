import 'package:flutter/material.dart';

/*
I had an issue where it wouldn't rebuild, and I think AI went a bit wild
there's a few spots where it makes a new delegate and I really don't think
we need that
*/

class BidirectionalScrollView extends StatefulWidget {
  final Widget Function(BuildContext context, int index, Key? key)?
  aboveBuilder;
  final Widget Function(BuildContext context, int index, Key? key)?
  belowBuilder;

  final int? aboveItemCount;
  final int? belowItemCount;

  final ScrollController? controller;

  final ScrollPhysics? physics;

  final Key? Function(int index)? aboveKeyBuilder;
  final Key? Function(int index)? belowKeyBuilder;
  final int? Function(Key)? aboveFindChildIndexCallback;
  final int? Function(Key)? belowFindChildIndexCallback;

  // Forces rebuild when this value changes, even if item count stays same
  final Object? rebuildKey;

  const BidirectionalScrollView({
    super.key,
    this.aboveBuilder,
    this.belowBuilder,
    this.aboveItemCount,
    this.belowItemCount,
    this.controller,
    this.physics,
    this.aboveKeyBuilder,
    this.belowKeyBuilder,
    this.aboveFindChildIndexCallback,
    this.belowFindChildIndexCallback,
    this.rebuildKey,
  }) : assert(
         aboveBuilder != null || belowBuilder != null,
         'At least one of aboveBuilder or belowBuilder must be provided',
       );

  @override
  State<BidirectionalScrollView> createState() =>
      _BidirectionalScrollViewState();
}

class _BidirectionalScrollViewState extends State<BidirectionalScrollView> {
  late ScrollController _scrollController;
  _BidirectionalDelegate? _aboveDelegate;
  _BidirectionalDelegate? _belowDelegate;
  int? _aboveItemCount;
  int? _belowItemCount;
  int _aboveDelegateGeneration = 0;
  int _belowDelegateGeneration = 0;

  late final Key _centerKey;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _aboveItemCount = widget.aboveItemCount;
    _belowItemCount = widget.belowItemCount;
    _centerKey = ValueKey('center_key');
  }

  @override
  void didUpdateWidget(BidirectionalScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final aboveItemCountChanged =
        oldWidget.aboveItemCount != widget.aboveItemCount;

    final belowItemCountChanged =
        oldWidget.belowItemCount != widget.belowItemCount;

    final rebuildKeyChanged = oldWidget.rebuildKey != widget.rebuildKey;

    if (aboveItemCountChanged) {
      _aboveItemCount = widget.aboveItemCount;
      _aboveDelegateGeneration++;
    }

    if (belowItemCountChanged) {
      _belowItemCount = widget.belowItemCount;
      _belowDelegateGeneration++;
    }

    if (rebuildKeyChanged) {
      _aboveDelegateGeneration++;
      _belowDelegateGeneration++;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  int? findIndexByKey(Key key) {
    if (_aboveDelegate != null) {
      final index = _aboveDelegate!._keyToIndexMap[key];
      if (index != null) return index;
    }

    if (_belowDelegate != null) {
      final index = _belowDelegate!._keyToIndexMap[key];
      if (index != null) return index;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[];

    if (widget.aboveBuilder != null) {
      final needsNewDelegate =
          _aboveDelegate == null ||
          _aboveDelegate!.itemCount != _aboveItemCount ||
          _aboveDelegate!.generation != _aboveDelegateGeneration;

      if (needsNewDelegate) {
        _aboveDelegate = _BidirectionalDelegate(
          keyedBuilder: widget.aboveBuilder!,
          itemCount: _aboveItemCount,
          isAbove: true,
          keyBuilder: widget.aboveKeyBuilder,
          findChildIndexCallback: widget.aboveFindChildIndexCallback,
          generation: _aboveDelegateGeneration,
        );
      }
      slivers.add(SliverList(delegate: _aboveDelegate!));
    } else {
      _aboveDelegate = null;
    }

    if (widget.belowBuilder != null) {
      final needsNewDelegate =
          _belowDelegate == null ||
          _belowDelegate!.itemCount != _belowItemCount ||
          _belowDelegate!.generation != _belowDelegateGeneration;

      if (needsNewDelegate) {
        _belowDelegate = _BidirectionalDelegate(
          keyedBuilder: widget.belowBuilder!,
          itemCount: _belowItemCount,
          isAbove: false,
          keyBuilder: widget.belowKeyBuilder,
          findChildIndexCallback: widget.belowFindChildIndexCallback,
          generation: _belowDelegateGeneration,
        );
      }
      slivers.add(SliverList(key: _centerKey, delegate: _belowDelegate!));
    } else {
      _belowDelegate = null;
    }

    return Scrollable(
      controller: _scrollController,
      physics: widget.physics,
      viewportBuilder: (context, offset) {
        return Viewport(
          offset: offset,
          center: _centerKey,
          anchor: 1,
          slivers: slivers,
        );
      },
    );
  }
}

class _BidirectionalDelegate extends SliverChildBuilderDelegate {
  final Widget Function(BuildContext context, int index, Key? key) keyedBuilder;
  final int? itemCount;
  final bool isAbove;
  final Map<Key, int> _keyToIndexMap = {};
  final Key? Function(int index)? keyBuilder;
  final int generation;

  _BidirectionalDelegate({
    required this.keyedBuilder,
    required this.itemCount,
    required this.isAbove,
    this.keyBuilder,
    int? Function(Key)? findChildIndexCallback,
    required this.generation,
  }) : super(
         (_, _) => null,
         childCount: itemCount,
         findChildIndexCallback: findChildIndexCallback,
       ) {
    _keyToIndexMap.clear();
  }

  @override
  Widget? build(BuildContext context, int index) {
    if (index < 0) {
      // no idea but it works
      // essentially scrolling up and down really quickly would completely fuck up the scroll view
      return null;
    }

    if (itemCount != null && index >= itemCount!) {
      return null;
    }

    final key =
        keyBuilder?.call(index) ??
        ValueKey('${isAbove ? 'above' : 'below'}_$index');
    _keyToIndexMap[key] = index;

    return keyedBuilder(context, index, key);
  }

  @override
  bool shouldRebuild(covariant SliverChildDelegate oldDelegate) {
    if (oldDelegate is! _BidirectionalDelegate) {
      return true;
    }

    // Rebuild when generation changes (which happens when item count changes)
    // This detects when items are added/removed, including when pending messages
    // become real messages (count stays same but keys change)
    return oldDelegate.generation != generation ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.isAbove != isAbove;
  }
}
