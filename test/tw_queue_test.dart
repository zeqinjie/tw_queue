import 'package:test/test.dart';
import 'package:tw_queue/src/tw_queue_base.dart';
import 'package:tw_queue/tw_queue.dart';

void main() {
  group('TWQueue', () {
    late TWQueue queue;

    setUp(() {
      queue = TWQueue();
    });

    test('does it return', () async {
      final result = await queue
          .add(() => Future.delayed(const Duration(milliseconds: 100)));
      expect(result, null);
    });

    test('it should return a value', () async {
      final result = await queue.add(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return "result";
      });
      expect(result, "result");
    });

    test('it should return multiple values', () async {
      final result = await Future.wait([
        queue.add(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          return "result 1";
        }),
        queue.add(() async {
          await Future.delayed(const Duration(milliseconds: 50));
          return "result 2";
        }),
        queue.add(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return "result 3";
        }),
        queue.add(() async {
          await Future.delayed(const Duration(milliseconds: 5));
          return "result 4";
        })
      ]);

      expect(result[0], "result 1");
      expect(result[1], "result 2");
      expect(result[2], "result 3");
      expect(result[3], "result 4");
    });

    test('it should queue', () async {
      final List<String?> results = [];

      await Future.wait([
        queue.add(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          return "result 1";
        }).then((result) => results.add(result)),
        queue.add(() async {
          await Future.delayed(const Duration(milliseconds: 50));
          return "result 2";
        }).then((result) => results.add(result)),
        queue.add(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return "result 3";
        }).then((result) => results.add(result)),
        queue.add(() async {
          await Future.delayed(const Duration(milliseconds: 5));
          return "result 4";
        }).then((result) => results.add(result)),
        queue.add(() async {
          await Future.delayed(const Duration(milliseconds: 1));
          return "result 5";
        }).then((result) => results.add(result))
      ]);

      expect(results[0], "result 1");
      expect(results[1], "result 2");
      expect(results[2], "result 3");
      expect(results[3], "result 4");
      expect(results[4], "result 5");
    });

    test('it should run in parallel', () async {
      final List<String?> results = [];

      final queueParallel = TWQueue(parallel: 3);

      final List<int> remainingItemsResults = [];
      final remainingItemsStream = queueParallel.remainingItems
          .listen((items) => remainingItemsResults.add(items));

      await Future.wait([
        queueParallel.add(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          return "result 1";
        }).then((result) => results.add(result)),
        queueParallel.add(() async {
          await Future.delayed(const Duration(milliseconds: 50));
          return "result 2";
        }).then((result) => results.add(result)),
        queueParallel.add(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return "result 3";
        }).then((result) => results.add(result)),
        queueParallel.add(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return "result 4";
        }).then((result) => results.add(result)),
        queueParallel.add(() async {
          await Future.delayed(const Duration(milliseconds: 50));
          return "result 5";
        }).then((result) => results.add(result))
      ]);

      await Future.delayed(const Duration(seconds: 1));

      unawaited(queueParallel.add(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return "result 1";
      }).then((result) => results.add(result)));
      unawaited(queueParallel.add(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        return "result 2";
      }).then((result) => results.add(result)));
      unawaited(queueParallel.add(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return "result 3";
      }).then((result) => results.add(result)));
      unawaited(queueParallel.add(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return "result 4";
      }).then((result) => results.add(result)));
      unawaited(queueParallel.add(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        return "result 5";
      }).then((result) => results.add(result)));

      await queueParallel.onComplete;

      expect(results[0], "result 3");
      expect(results[1], "result 4");
      expect(results[2], "result 2");
      expect(results[3], "result 5");
      expect(results[4], "result 1");

      expect(results[5], "result 3");
      expect(results[6], "result 4");
      expect(results[7], "result 2");
      expect(results[8], "result 5");
      expect(results[9], "result 1");

      await remainingItemsStream.cancel();
      expect(remainingItemsResults.isNotEmpty, true);
    });

    test('it should handle an error correctly (also testing oncomplete)',
        () async {
      int hitError = 0;
      final errorQueue = TWQueue(parallel: 10);
      for (var i = 0; i < 100; i++) {
        unawaited(errorQueue.add<dynamic>(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          throw Exception("test exception");
        }).catchError((err) {
          hitError++;
          expect(err.toString(), "Exception: test exception");
        }));
      }
      try {
        await errorQueue.add(() {
          Future.delayed(const Duration(milliseconds: 10));
          throw Exception("test exception");
        });
      } catch (e) {
        hitError++;
      }
      await errorQueue.onComplete;
      expect(errorQueue.activeItemTags.length, 0);
      expect(hitError, 101);
    });

    test('should cancel', () async {
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

      await Future.delayed(const Duration(milliseconds: 25));
      cancelQueue.cancel();
      await cancelQueue.onComplete;
      expect(results.length, 3);
      expect(errors.length, 2);
      expect(errors.first is QueueCancelledException, true);
    });

    test("timed out queue item still completes", () async {
      final queue = TWQueue(timeout: const Duration(milliseconds: 10));

      final resultOrder = [];

      unawaited(queue.onComplete.then((_) => resultOrder.add("timedout")));
      resultOrder.add(await queue.add(() async {
        await Future.delayed(const Duration(seconds: 1));
        return "test";
      }));

      expect(resultOrder.length, 2);
      expect(resultOrder.first, "timedout");
      expect(resultOrder[1], "test");
    });

    test("it handles null as expected", () async {
      final queue = TWQueue();

      final result = await queue.add(() async => null);
      expect(result, null);
    });

    test("cancel result 2 and continue next result3", () async {
      final queue = TWQueue(delay: const Duration(milliseconds: 100));
      final results = <String?>[];
      final errors = <Exception>[];
      final errorResults = <String?>[];

      unawaited(queue
          .add(() async {
            await Future.delayed(const Duration(milliseconds: 10));
            return "result 1";
          })
          .then((result) => results.add(result))
          .catchError((err) {
            errors.add(err);
            errorResults.add('error 1');
          }));

      unawaited(queue
          .add(() async {
            await Future.delayed(const Duration(milliseconds: 10));
            return "result 2";
          })
          .then((result) => results.add(result))
          .catchError((err) {
            errors.add(err);
            errorResults.add('error 2');
          }));

      queue.cancel();

      await queue
          .add(() async {
            await Future.delayed(const Duration(milliseconds: 10));
            return "result 3";
          })
          .then((result) => results.add(result))
          .catchError((err) {
            errors.add(err);
            errorResults.add('error 3');
          });

      expect(results.length, 2);
      expect(errors.length, 1);
      expect(errorResults.length, 1);
      expect(errorResults.first, 'error 2');
    });

    test("remove t2 and t4 success", () async {
      final queue = TWQueue();
      final t1 = 'testQueue4-1';
      final t2 = 'testQueue4-2';
      final t3 = 'testQueue4-3';
      final t4 = 'testQueue4-4';
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
      expect(results.length, 2);
    });

    test("pause and resume queue", () async {
      final queue = TWQueue();
      final results = <String?>[];
      final t1 = 'testQueue4-1';
      final t2 = 'testQueue4-2';
      final t3 = 'testQueue4-3';
      final t4 = 'testQueue4-4';
      final t5 = 'testQueue4-5';

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
      unawaited(queue.add(
        () async {
          await Future.delayed(const Duration(seconds: 1));
          results.add(t5);
        },
      ));
      Future.delayed(const Duration(seconds: 1), () {
        expect(results.length, 2);
        queue.resume();
      });
      await queue.onComplete;
      expect(results.length, 5);
    });

    test("set queue priority", () async {
      final queue = TWQueue();
      final results = <String?>[];
      final t1 = 'testQueue5-1';
      final t2 = 'testQueue5-2';
      final t3 = 'testQueue5-3';
      final t4 = 'testQueue5-4';

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
        priority: TWPriority.low,
      ));
      unawaited(queue.add(
        () async {
          await Future.delayed(const Duration(seconds: 1));
          results.add(t4);
        },
        priority: TWPriority.high,
      ));

      await queue.onComplete;
      expect(results.length, 4);
      expect(results[0], t1);
      expect(results[1], t4);
      expect(results[2], t2);
      expect(results[3], t3);
    });

    test("remove all", () async {
      final queue = TWQueue();
      final t1 = 'testQueue6-1';
      final t2 = 'testQueue6-2';
      final t3 = 'testQueue6-3';
      final t4 = 'testQueue6-4';
      final results = <String?>[];

      unawaited(
        queue.add(
          () async {
            await Future.delayed(const Duration(seconds: 2));
            print('t1 = $t1');
            results.add(t1);
          },
          tag: t1,
        ),
      );
      unawaited(
        queue.add(
          () async {
            await Future.delayed(const Duration(seconds: 1));
            print('t2 = $t2');
            results.add(t2);
          },
          tag: t2,
        ),
      );

      unawaited(
        queue.add(
          () async {
            await Future.delayed(const Duration(seconds: 1));
            print('t3 = $t3');
            results.add(t3);
          },
          tag: t3,
        ),
      );

      unawaited(
        queue.add(
          () async {
            await Future.delayed(const Duration(seconds: 1));
            print('t4 = $t4');
            results.add(t4);
          },
          tag: t4,
        ),
      );
      queue.removeAll();
      await queue.onComplete;
      expect(results.length, 1);
    });
  });
}
