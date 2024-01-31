// ignore: depend_on_referenced_packages
import 'package:stack_trace/stack_trace.dart';

enum TWLogMode {
  debug, // 💚 DEBUG
  warning, // 💛 WARNING
  info, // 💙 INFO
  error, // ❤️ ERROR
}

const int _limitLength = 800;
List<String> historyLogs = [];

// ignore: non_constant_identifier_names
void TWLog(dynamic msg, {TWLogMode mode = TWLogMode.debug}) {
  var chain = Chain.current();
  chain =
      chain.foldFrames((frame) => frame.isCore || frame.package == "flutter");

  final frames = chain.toTrace().frames;

  final idx = frames.indexWhere((element) => element.member == "TWLog");
  if (idx == -1 || idx + 1 >= frames.length) {
    return;
  }

  final frame = frames[idx + 1];

  var modeStr = "";
  switch (mode) {
    case TWLogMode.debug:
      modeStr = "💚 DEBUG";
      break;
    case TWLogMode.warning:
      modeStr = "💛 WARNING";
      break;
    case TWLogMode.info:
      modeStr = "💙 INFO";
      break;
    case TWLogMode.error:
      modeStr = "❤️ ERROR";
      break;
  }

  final printStr =
      "$modeStr ${frame.uri.toString().split("/").last}(${frame.line}) - $msg ";
  if (printStr.length < _limitLength) {
    // ignore: avoid_print
    print(printStr);
  } else {
    segmentationLog(printStr);
  }
}

void segmentationLog(String msg) {
  var outStr = StringBuffer();
  for (var index = 0; index < msg.length; index++) {
    outStr.write(msg[index]);
    if (index % _limitLength == 0 && index != 0) {
      // ignore: avoid_print
      print(outStr);
      outStr.clear();
      var lastIndex = index + 1;
      if (msg.length - lastIndex < _limitLength) {
        var remainderStr = msg.substring(lastIndex, msg.length);
        // ignore: avoid_print
        print(remainderStr);
        break;
      }
    }
  }
}
