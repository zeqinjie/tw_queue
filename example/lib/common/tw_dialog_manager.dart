import 'package:tw_queue/tw_queue.dart';

import 'tw_log.dart';

class TWDialogManager {
  final dialogQueue = TWQueue();

  // static final TWDialogManager _instance = TWDialogManager._();
  // static TWDialogManager get instance => _instance;
  // TWDialogManager._();

  /// 添加队列弹窗
  /// [dialog] 队列弹窗
  /// [priority] 优先级
  /// [tag] 唯一 ID
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

  /// 队列暂停
  void pause() {
    dialogQueue.pause();
  }

  /// 注意删除后，会抛异常
  /// fix 原组件删除后，可以继续添加队列问题
  void cancel() {
    dialogQueue.cancel();
  }

  /// 删除队列
  /// [tag] 唯一 ID
  void remove(String tag) {
    dialogQueue.remove(tag);
  }

  /// 队列继续
  void resume() {
    dialogQueue.resume();
  }

  /// 存在活跃的队列项
  bool get isActiveItem => dialogQueue.activeItemTags.isNotEmpty;
}
