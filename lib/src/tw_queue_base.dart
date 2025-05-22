import 'dart:async';

import 'tw_priority.dart';
import 'tw_queue_helper.dart';

class _QueuedFuture<T> {
  final Completer completer;
  final Future<T> Function() closure;
  final Duration? timeout;
  final String tag;
  Function? onComplete;

  _QueuedFuture(
    this.closure,
    this.completer,
    this.timeout,
    this.tag, {
    this.onComplete,
  });

  bool _timedOut = false;

  Future<void> execute() async {
    try {
      T result;
      Timer? timoutTimer;

      if (timeout != null) {
        timoutTimer = Timer(timeout!, () {
          _timedOut = true;
          if (onComplete != null) {
            onComplete!();
          }
        });
      }
      result = await closure();
      if (result != null) {
        completer.complete(result);
      } else {
        completer.complete(null);
      }

      //Make sure not to execute the next command until this future has completed
      timoutTimer?.cancel();
      await Future.microtask(() {});
    } catch (e, stack) {
      completer.completeError(e, stack);
    } finally {
      if (onComplete != null && !_timedOut) onComplete!();
    }
  }
}

/// Queue to execute Futures in order.
/// It awaits each future before executing the next one.
class TWQueue {
  /// The queue of items to process
  final TWPriorityList<_QueuedFuture> _nextCycle =
      TWPriorityList<_QueuedFuture>();

  TWPriorityList<_QueuedFuture> get nextCycle => _nextCycle;

  /// A delay to await between each future.
  final Duration? delay;

  /// A timeout before processing the next item in the queue
  final Duration? timeout;

  /// Shoud we process this queue LIFO (last in first out)
  final bool lifo;

  /// The number of items to process at one time
  ///
  /// Can be edited mid processing
  int parallel;

  /// pause of the queue
  bool isPause = false;

  StreamController<int>? _remainingItemsController;

  TWQueue({
    this.delay,
    this.parallel = 1,
    this.timeout,
    this.lifo = false,
  });

  Stream<int> get remainingItems {
    // Lazily create the remaining items controller so if people aren't listening to the stream, it won't create any potential memory leaks.
    // Probably not necessary, but hey, why not?
    _remainingItemsController ??= StreamController<int>();
    return _remainingItemsController!.stream.asBroadcastStream();
  }

  final List<Completer<void>> _completeListeners = [];

  /// Resolve when all items are complete
  ///
  /// Returns a future that will resolve when all items in the queue have
  /// finished processing
  Future get onComplete {
    final completer = Completer();
    _completeListeners.add(completer);
    return completer.future;
  }

  /// active items tags
  Set<String> activeItemTags = {};

  /// Cancels the queue. Also cancels any unprocessed items throwing a [QueueCancelledException]
  ///
  /// Subsquent calls to [add] will throw.
  void cancel() {
    for (final item in _nextCycle.list) {
      item.completer.completeError(QueueCancelledException());
    }
    _nextCycle.removeWhere((item) => item.completer.isCompleted);
  }

  /// Dispose of the queue
  ///
  /// This will run the [cancel] function and close the remaining items stream
  /// To gracefully exit the queue, waiting for items to complete first,
  /// call `await [Queue.onComplete];` before disposing
  void dispose() {
    _remainingItemsController?.close();
    cancel();
  }

  /// pause of the queue
  /// It will be pause  the queue if it has not yet been executed.
  void pause() {
    isPause = true;
  }

  /// resume of the queue
  void resume() {
    isPause = false;
    unawaited(_process());
  }

  /// Adds the future-returning closure to the queue.
  ///
  /// It will be executed after futures returned
  /// by preceding closures have been awaited.
  ///
  /// Will throw an exception if the queue has been cancelled.
  Future<T> add<T>(
    Future<T> Function() closure, {
    String? tag,
    TWPriority priority = TWPriority.middle,
  }) {
    tag = tag ?? TWQueueHelper.getUniqueId();
    final completer = Completer<T>();
    _nextCycle.add(
      _QueuedFuture<T>(
        closure,
        completer,
        timeout,
        tag,
      ),
      priority: priority,
    );
    _updateRemainingItems();
    unawaited(_process());
    return completer.future;
  }

  /// Removes the future-returning closure from the queue.
  /// It will be removed from the queue if it has not yet been executed.
  void remove(
    String tag, {
    TWPriority priority = TWPriority.middle,
  }) {
    _nextCycle.removeWhere((item) => item.tag == tag);
    activeItemTags.remove(tag);
    _updateRemainingItems();
  }

  /// Removes all items from the queue that have not thrown a [QueueCancelledException]
  /// It will be removed from the queue if it has not yet been executed.
  void removeAll() {
    _nextCycle.clear();
    activeItemTags.clear();
    _updateRemainingItems();
  }

  /// Handles the number of parallel tasks firing at any one time
  ///
  /// It does this by checking how many streams are running by querying active
  /// items, and then if it has less than the number of parallel operations fire off another stream.
  ///
  /// When each item completes it will only fire up one othe process
  ///
  Future<void> _process() async {
    if (activeItemTags.length < parallel) {
      _queueUpNext();
    }
  }

  void _updateRemainingItems() {
    final remainingItemsController = _remainingItemsController;
    if (remainingItemsController != null &&
        remainingItemsController.isClosed == false) {
      remainingItemsController.sink
          .add(_nextCycle.length + activeItemTags.length);
    }
  }

  void _queueUpNext() {
    if (isPause) return;
    if (_nextCycle.isNotEmpty && activeItemTags.length < parallel) {
      final item = lifo ? _nextCycle.last : _nextCycle.first;
      final processId = item.tag;
      activeItemTags.add(processId);
      _nextCycle.remove(item);
      item.onComplete = () async {
        activeItemTags.remove(processId);
        if (delay != null) {
          await Future.delayed(delay!);
        }
        _updateRemainingItems();
        _queueUpNext();
      };
      unawaited(item.execute());
    } else if (activeItemTags.isEmpty && _nextCycle.isEmpty) {
      //Complete
      for (final completer in _completeListeners) {
        if (completer.isCompleted != true) {
          completer.complete();
        }
      }
      _completeListeners.clear();
    }
  }
}

class QueueCancelledException implements Exception {}

// Don't throw analysis error on unawaited future.
void unawaited(Future<void> future) {}
