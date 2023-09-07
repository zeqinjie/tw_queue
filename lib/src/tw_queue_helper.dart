
import 'dart:math';

class TWQueueHelper {
  /// random string generator
  static String getUniqueId({int count = 5}) {
    String randomStr = Random().nextInt(10).toString();
    for (var i = 0; i < count; i++) {
      var str = Random().nextInt(10);
      randomStr = randomStr + "$str";
    }
    final timeNumber = DateTime.now().millisecondsSinceEpoch;
    final uuid = randomStr + "$timeNumber";
    return uuid;
  }
}