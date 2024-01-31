import 'dart:async';

import 'package:example/common/tw_log.dart';
import 'package:flutter/material.dart';
import 'package:tw_queue/tw_queue.dart';

class TWQueueTestPage extends StatefulWidget {
  const TWQueueTestPage({Key? key}) : super(key: key);

  @override
  State<TWQueueTestPage> createState() => _TWQueueTestPageState();
}

class _TWQueueTestPageState extends State<TWQueueTestPage> {
  @override
  void initState() {
    super.initState();
    testQueue1();
    testQueue2();
    testQueue3();
    testQueue4();
    testQueue5();
    testQueue6();
    testQueue7();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TWQueueTestPage"),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container();
  }

  testQueue1() async {
    final cancelQueue = TWQueue();
    final results = <String?>[];
    final errors = <Exception>[];

    unawaited(Future.wait([
      cancelQueue
          .add(() async {
            await Future.delayed(const Duration(milliseconds: 10));
            return "result 1";
          })
          .then((result) => results.add(result))
          .catchError((err) => errors.add(err)),
      cancelQueue
          .add(() async {
            await Future.delayed(const Duration(milliseconds: 10));
            return "result 2";
          })
          .then((result) => results.add(result))
          .catchError((err) => errors.add(err)),
      cancelQueue
          .add(() async {
            await Future.delayed(const Duration(milliseconds: 10));
            return "result 3";
          })
          .then((result) => results.add(result))
          .catchError((err) => errors.add(err)),
      cancelQueue
          .add(() async {
            await Future.delayed(const Duration(milliseconds: 10));
            return "result 4";
          })
          .then((result) => results.add(result))
          .catchError((err) => errors.add(err)),
      cancelQueue
          .add(() async {
            await Future.delayed(const Duration(milliseconds: 10));
            return "result 5";
          })
          .then((result) => results.add(result))
          .catchError((err) => errors.add(err))
    ]));

    await cancelQueue.onComplete;
  }

  testQueue2() async {
    final queue = TWQueue(parallel: 2);

    //Queue up a future and await its result

    await queue.add(() => Future.delayed(const Duration(milliseconds: 10)));

    await queue.add(() => Future.delayed(const Duration(milliseconds: 10)));

    await queue.onComplete;
  }

  testQueue3() async {
    final queue =
        TWQueue(delay: const Duration(milliseconds: 2000), parallel: 1);

    Future asyncMessage(String message) async {
      TWLog(message);
    }

    unawaited(queue
        .add(() async {
          await Future.delayed(const Duration(milliseconds: 500));
          await asyncMessage("Message 1");
        })
        .then((result) => TWLog("Message 1 complete"))
        .catchError(
          (e) => TWLog('Message 1 error: $e'),
        ));

    queue
        .add(() async {
          await asyncMessage("Message 2");
        })
        .then((value) => TWLog("Message 2 complete"))
        .catchError((e) => TWLog('Message 2 error: $e'));

    queue.cancel();

    queue
        .add(() async {
          await asyncMessage("Message 3");
        })
        .then((value) => TWLog("Message 3 complete"))
        .catchError((e) => TWLog('Message 3 error: $e'));

    unawaited(queue
        .add(() async {
          await Future.delayed(const Duration(milliseconds: 500));
          await asyncMessage("Message 3");
          TWLog("awaited message");
          // throw Exception("Error");
        })
        .then((result) => TWLog("Message 3 complete"))
        .catchError((e) => TWLog('Message 3 error: $e')));

    unawaited(queue
        .add(() async {
          await Future.delayed(const Duration(milliseconds: 500));
          await asyncMessage("Message 4");
        })
        .then((result) => TWLog("Message 4 complete"))
        .catchError((e) => TWLog('Message 4 error: $e')));
  }

  /// Set task priority
  testQueue4() async {
    final queue = TWQueue();
    const t1 = 'testQueue4-1';
    const t2 = 'testQueue4-2';
    const t3 = 'testQueue4-3';
    const t4 = 'testQueue4-4';
    final results = <String?>[];
    //Queue up a future and await its result
    queue.add(
      tag: t1,
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t1);
        TWLog('res1 = $t1');
      },
    );
    queue.add(
      tag: t2,
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t2);
        TWLog('res2 = $t2');
      },
    );

    queue.add(
      tag: t3,
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t3);
        TWLog('res3 = $t3');
      },
      priority: TWPriority.low,
    );

    queue.add(
      tag: t4,
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t4);
        TWLog('res4 = $t4');
      },
      priority: TWPriority.high,
    );
    await queue.onComplete;
    TWLog('results = $results');
  }

  /// Remove Task
  testQueue5() async {
    final queue = TWQueue();
    const t1 = 'testQueue5-1';
    const t2 = 'testQueue5-2';
    const t3 = 'testQueue5-3';
    const t4 = 'testQueue5-4';
    final results = <String?>[];
    unawaited(
      queue.add(
        () async {
          await Future.delayed(const Duration(seconds: 1));
          results.add(t1);
        },
        tag: t1,
      ),
    );
    unawaited(
      queue.add(
        () async {
          await Future.delayed(const Duration(seconds: 1));
          results.add(t2);
        },
        tag: t2,
      ),
    );

    unawaited(
      queue.add(
        () async {
          await Future.delayed(const Duration(seconds: 1));
          results.add(t3);
        },
        tag: t3,
      ),
    );

    unawaited(
      queue.add(
        () async {
          await Future.delayed(const Duration(seconds: 1));
          results.add(t4);
        },
        tag: t4,
      ),
    );
    queue.remove(t2);
    queue.remove(t4);
    await queue.onComplete;
    TWLog('results $results');
  }

  /// Pause and Resume
  testQueue6() async {
    final queue = TWQueue();
    final results = <String?>[];
    const t1 = 'testQueue6-1';
    const t2 = 'testQueue6-2';
    const t3 = 'testQueue6-3';
    const t4 = 'testQueue6-4';

    await queue.add(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t1);
      },
    );
    await queue.add(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t2);
      },
    );
    queue.pause();
    unawaited(queue.add(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t3);
      },
    ));
    unawaited(queue.add(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t4);
      },
    ));
    Future.delayed(const Duration(seconds: 1), () {
      // delayed results [testQueue4-1, testQueue4-2]
      TWLog('delayed results $results');
      queue.resume();
    });
    await queue.onComplete;
    // onComplete results [testQueue4-1, testQueue4-2, testQueue4-3, testQueue4-4]
    TWLog('onComplete results $results');
  }

  /// Remove All
  testQueue7() async {
    final queue = TWQueue();
    final results = <String?>[];
    const t1 = 'testQueue7-1';
    const t2 = 'testQueue7-2';
    const t3 = 'testQueue7-3';
    const t4 = 'testQueue7-4';

    unawaited(queue.add(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t1);
      },
    ));
    unawaited(queue.add(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t2);
      },
    ));
    unawaited(queue.add(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t3);
      },
    ));
    unawaited(queue.add(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        results.add(t4);
      },
    ));
    queue.removeAll();
    await queue.onComplete;
    TWLog('onComplete results $results');
  }
}
