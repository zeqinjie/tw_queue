import 'package:tw_queue/tw_queue.dart';

import 'tw_log.dart';

class TWDialogManager {
  final dialogQueue = TWQueue();

  Future<T?> add<T>(
    Future<T?> Function() dialog, {
    String? tag,
    TWPriority priority = TWPriority.middle,
  }) async {
    return dialogQueue
        .add(
      dialog,
      tag: tag,
      priority: priority,
    )
        .catchError(
      (e) {
        TWLog('TWDialogManager add error: $e');
        return Future.value(null);
      },
    );
  }

  void pause() {
    dialogQueue.pause();
  }

  void cancel() {
    dialogQueue.cancel();
  }

  void remove(String tag) {
    dialogQueue.remove(tag);
  }

  void resume() {
    dialogQueue.resume();
  }

  void removeAll() {
    dialogQueue.removeAll();
  }

  bool get isActiveItem => dialogQueue.activeItemTags.isNotEmpty;
}
