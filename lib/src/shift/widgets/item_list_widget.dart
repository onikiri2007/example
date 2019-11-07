import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

typedef IndexedWidgetsBuilder = List<Widget> Function(
    BuildContext context, int index);

class ItemList extends StatelessWidget {
  final EdgeInsets padding;
  final IndexedWidgetsBuilder itemBuilder;
  final int itemsCount;

  ItemList({
    @required this.itemBuilder,
    @required this.itemsCount,
    this.padding,
  })  : assert(itemBuilder != null),
        assert(itemsCount != null && itemsCount >= 0);

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = _buildItems(context);
    return Column(
      children: widgets,
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    List<Widget> items = [];
    for (int i = 0; i < itemsCount; i++) {
      items.addAll(itemBuilder(context, i));
    }
    return items;
  }
}

/// Signature for the builder callback used by [AnimatedList].
typedef AnimatedItemListItemBuilder = List<Widget> Function(
    BuildContext context, int index, Animation<double> animation);

/// Signature for the builder callback used by [AnimatedListState.removeItem].
typedef AnimatedItemListRemovedItemBuilder = List<Widget> Function(
    BuildContext context, Animation<double> animation);

typedef IndexedCallback = void Function(int index);

const Duration _kDuration = Duration(milliseconds: 300);

// Incoming and outgoing AnimatedList items.
class _ActiveItem implements Comparable<_ActiveItem> {
  _ActiveItem.incoming(this.controller, this.itemIndex)
      : removedItemBuilder = null;
  _ActiveItem.outgoing(
      this.controller, this.itemIndex, this.removedItemBuilder);
  _ActiveItem.index(this.itemIndex)
      : controller = null,
        removedItemBuilder = null;

  final AnimationController controller;
  final AnimatedItemListRemovedItemBuilder removedItemBuilder;
  int itemIndex;

  @override
  int compareTo(_ActiveItem other) => itemIndex - other.itemIndex;
}

class AnimatedItemList extends StatefulWidget {
  AnimatedItemList({
    Key key,
    @required this.itemBuilder,
    this.initialItemCount = 0,
    this.padding,
    this.onRemoved,
  })  : assert(itemBuilder != null),
        assert(initialItemCount != null && initialItemCount >= 0),
        super(key: key);

  final AnimatedItemListItemBuilder itemBuilder;
  final EdgeInsets padding;
  final int initialItemCount;
  final IndexedCallback onRemoved;

  static AnimatedItemListState of(BuildContext context, {bool nullOk = false}) {
    assert(context != null);
    assert(nullOk != null);
    final AnimatedItemListState result =
        context.ancestorStateOfType(const TypeMatcher<AnimatedItemListState>());
    if (nullOk || result != null) return result;
    throw FlutterError(
        'AnimatedItemListState.of() called with a context that does not contain an AnimatedItemList.\n'
        'No AnimatedList ancestor could be found starting from the context that was passed to AnimatedItemList.of(). '
        'This can happen when the context provided is from the same StatefulWidget that '
        'built the AnimatedList. Please see the AnimatedList documentation for examples '
        'of how to refer to an AnimatedItemListState object: '
        '  https://docs.flutter.io/flutter/widgets/AnimatedListState-class.html \n'
        'The context used was:\n'
        '  $context');
  }

  @override
  AnimatedItemListState createState() => AnimatedItemListState();
}

class AnimatedItemListState extends State<AnimatedItemList>
    with TickerProviderStateMixin<AnimatedItemList> {
  final List<_ActiveItem> _incomingItems = <_ActiveItem>[];
  final List<_ActiveItem> _outgoingItems = <_ActiveItem>[];
  int _itemsCount = 0;

  @override
  void initState() {
    _itemsCount = widget.initialItemCount;
    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedItemList oldWidget) {
    if (oldWidget.initialItemCount != widget.initialItemCount) {
      _itemsCount = widget.initialItemCount;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (_ActiveItem item in _incomingItems) item.controller.dispose();
    for (_ActiveItem item in _outgoingItems) item.controller.dispose();
    super.dispose();
  }

  int _indexToItemIndex(int index) {
    int itemIndex = index;
    for (_ActiveItem item in _outgoingItems) {
      if (item.itemIndex <= itemIndex)
        itemIndex += 1;
      else
        break;
    }
    return itemIndex;
  }

  int _itemIndexToIndex(int itemIndex) {
    int index = itemIndex;
    for (_ActiveItem item in _outgoingItems) {
      assert(item.itemIndex != itemIndex);
      if (item.itemIndex < itemIndex)
        index -= 1;
      else
        break;
    }
    return index;
  }

  _ActiveItem _removeActiveItemAt(List<_ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, _ActiveItem.index(itemIndex));
    return i == -1 ? null : items.removeAt(i);
  }

  _ActiveItem _activeItemAt(List<_ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, _ActiveItem.index(itemIndex));
    return i == -1 ? null : items[i];
  }

  /// Insert an item at [index] and start an animation that will be passed
  /// to [AnimatedList.itemBuilder] when the item is visible.
  ///
  /// This method's semantics are the same as Dart's [List.insert] method:
  /// it increases the length of the list by one and shifts all items at or
  /// after [index] towards the end of the list.
  void insertItem(int index, {Duration duration = _kDuration}) {
    assert(index != null && index >= 0);
    assert(duration != null);

    final int itemIndex = _indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex <= _itemsCount);

    // Increment the incoming and outgoing item indices to account
    // for the insertion.
    for (_ActiveItem item in _incomingItems) {
      if (item.itemIndex >= itemIndex) item.itemIndex += 1;
    }
    for (_ActiveItem item in _outgoingItems) {
      if (item.itemIndex >= itemIndex) item.itemIndex += 1;
    }

    final AnimationController controller =
        AnimationController(duration: duration, vsync: this);
    final _ActiveItem incomingItem =
        _ActiveItem.incoming(controller, itemIndex);
    setState(() {
      _incomingItems
        ..add(incomingItem)
        ..sort();
      _itemsCount += 1;
    });

    controller.forward().then<void>((_) {
      _removeActiveItemAt(_incomingItems, incomingItem.itemIndex)
          .controller
          .dispose();
    });
  }

  /// Remove the item at [index] and start an animation that will be passed
  /// to [builder] when the item is visible.
  ///
  /// Items are removed immediately. After an item has been removed, its index
  /// will no longer be passed to the [AnimatedList.itemBuilder]. However the
  /// item will still appear in the list for [duration] and during that time
  /// [builder] must construct its widget as needed.
  ///
  /// This method's semantics are the same as Dart's [List.remove] method:
  /// it decreases the length of the list by one and shifts all items at or
  /// before [index] towards the beginning of the list.
  void removeItem(int index, AnimatedItemListRemovedItemBuilder builder,
      {Duration duration = _kDuration}) {
    assert(index != null && index >= 0);
    assert(builder != null);
    assert(duration != null);

    final int itemIndex = _indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex < _itemsCount);
    assert(_activeItemAt(_outgoingItems, itemIndex) == null);

    final _ActiveItem incomingItem =
        _removeActiveItemAt(_incomingItems, itemIndex);
    final AnimationController controller = incomingItem?.controller ??
        AnimationController(duration: duration, value: 1.0, vsync: this);
    final _ActiveItem outgoingItem =
        _ActiveItem.outgoing(controller, itemIndex, builder);
    setState(() {
      _outgoingItems
        ..add(outgoingItem)
        ..sort();
    });

    controller.reverse().then<void>((void value) {
      _removeActiveItemAt(_outgoingItems, outgoingItem.itemIndex)
          .controller
          .dispose();

      // Decrement the incoming and outgoing item indices to account
      // for the removal.
      for (_ActiveItem item in _incomingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) item.itemIndex -= 1;
      }
      for (_ActiveItem item in _outgoingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) item.itemIndex -= 1;
      }

      setState(() {
        _itemsCount -= 1;
      });

      if (widget.onRemoved != null) {
        widget.onRemoved(index);
      }
    });
  }

  List<Widget> _itemBuilder(BuildContext context, int itemIndex) {
    final _ActiveItem outgoingItem = _activeItemAt(_outgoingItems, itemIndex);
    if (outgoingItem != null)
      return outgoingItem.removedItemBuilder(
          context, outgoingItem.controller.view);

    final _ActiveItem incomingItem = _activeItemAt(_incomingItems, itemIndex);
    final Animation<double> animation =
        incomingItem?.controller?.view ?? kAlwaysCompleteAnimation;
    return widget.itemBuilder(context, _itemIndexToIndex(itemIndex), animation);
  }

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemBuilder: _itemBuilder,
      itemsCount: _itemsCount,
      padding: widget.padding,
    );
  }
}
