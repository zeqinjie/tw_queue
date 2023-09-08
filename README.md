# Queue

Easily queue futures and await their values.

## Usage

The most simple example:
```dart
import 'package:tw_queue/tw_queue_export.dart';

main() async {
  final queue = TWQueue();

  //Queue up a future and await its result
  final result = await queue.add(()=>Future.delayed(Duration(milliseconds: 10)));

  //Thats it!
}
```

A proof of concept:

```dart
import 'package:tw_queue/tw_queue_export.dart';

main() async {
  //Create the queue container
  final queue = TWQueue(delay: Duration(milliseconds: 10));
  
  //Add items to the queue asyncroniously
  queue.add(()=>Future.delayed(Duration(milliseconds: 100)));
  queue.add(()=>Future.delayed(Duration(milliseconds: 10)));
  
  //Get a result from the future in line with await
  final result = await queue.add(() async {
    await Future.delayed(Duration(milliseconds: 1));
    return "Future Complete";
  });
  
  //100, 10, 1 will reslove in that order.
  result == "Future Complete"; //true
}
```

#### Parallel processing
This doesn't work in batches and will fire the next item as soon as as there is space in the queue
Use [Queue(delayed: ...)] to specify a delay before firing the next item  

```dart
import 'package:tw_queue/tw_queue_export.dart';

main() async {
  final queue = TWQueue(parallel: 2);

  //Queue up a future and await its result
  final result1 = await queue.add(()=>Future.delayed(Duration(milliseconds: 10)));
  final result2 = await queue.add(()=>Future.delayed(Duration(milliseconds: 10)));

  //Thats it!
}
```

#### On complete
```dart
import 'package:tw_queue/tw_queue_export.dart';

main() async {
  final queue = TWQueue(parallel: 2);

  //Queue up a couple of futures
  queue.add(()=>Future.delayed(Duration(milliseconds: 10)));
  queue.add(()=>Future.delayed(Duration(milliseconds: 10)));


  // Will only resolve when all the queue items have resolved.
  await queue.onComplete;
}
```

#### Rate limiting
You can specify a delay before the next item is fired as per the following example:

```dart
import 'package:tw_queue/tw_queue_export.dart';

main() async {
  final queue = TWQueue(delay: Duration(milliseconds: 500)); // Set the delay here

  //Queue up a future and await its result
  final result1 = await queue.add(()=>Future.delayed(Duration(milliseconds: 10)));
  final result2 = await queue.add(()=>Future.delayed(Duration(milliseconds: 10)));

  //Thats it!
}
```

#### Cancel

If you need to stop a queue from processing call Queue.cancel();

This will cancel the remaining items in the queue by throwing a `QueueCancelledException`.
A cancelled queue is "dead" and should be recreated. If you try adding items to the queue after you
call cancel, it will throw a `QueueCancelledException`.

If you have no reason to listen to the results of the items, simply call dispose.

If you want to wait until all the items which are inflight complete, call Queue.onComplete first.

#### Disposing
If you need to dispose of the queue object (best practice in flutter any any time the queue object will close)
simply call queue.dispose();

This is necessary to close the `Queue.remainingItems` controller.

#### Reporting
If you want to query how many items are outstanding in the queue, listen to the Queue.remainingItems stream.

```dart
import 'package:tw_queue/tw_queue_export.dart';
final queue = TWQueue();

final remainingItemsStream = queue.remainingItems.listen((numberOfItems)=>print(numberOfItems));

//Queue up a couple of futures
queue.add(()=>Future.delayed(Duration(milliseconds: 10)));
queue.add(()=>Future.delayed(Duration(milliseconds: 10)));

// Will only resolve when all the queue items have resolved.
await queue.onComplete;
remainingItemsStream.close();
queue.dispose(); // Will clean up any resources in the queue if you are done with it.


```

#### Remove Task
It will be removed from the queue task, if it has not yet been executed. 

```dart
import 'package:tw_queue/tw_queue_export.dart';
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
// remove t2 and t4
queue.remove(t2);
queue.remove(t4);
await queue.onComplete;
// log: results [testQueue4-1, testQueue4-3]
print('results $results');
```

#### Pause and Resume

It will be pause the queue task, if it has not yet been executed. 

```dart
final queue = TWQueue();
final results = <String?>[];
final t1 = 'testQueue4-1';
final t2 = 'testQueue4-2';
final t3 = 'testQueue4-3';
final t4 = 'testQueue4-4';

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
  print('delayed results $results');
  queue.resume();
});
await queue.onComplete;
// onComplete results [testQueue4-1, testQueue4-2, testQueue4-3, testQueue4-4]
print('onComplete results $results');
```



#### Set task priority

It will be set  the queue task priority,  if it has not yet been executed. 

```dart
final queue = TWQueue();
final t1 = 'testQueue4-1';
final t2 = 'testQueue4-2';
final t3 = 'testQueue4-3';
final t4 = 'testQueue4-4';
final results = <String?>[];
//Queue up a future and await its result
queue.add(
  tag: t1,
  () async {
    await Future.delayed(const Duration(seconds: 1));
    results.add(t1);
    print('res1 = $t1');
  },
);
queue.add(
  tag: t2,
  () async {
    await Future.delayed(const Duration(seconds: 1));
    results.add(t2);
    print('res2 = $t2');
  },
);

queue.add(
  tag: t3,
  () async {
    await Future.delayed(const Duration(seconds: 1));
    results.add(t3);
    print('res3 = $t3');
  },
  priority: TWPriority.low,
);

queue.add(
  tag: t4,
  () async {
    await Future.delayed(const Duration(seconds: 1));
    results.add(t4);
    print('res4 = $t4');
  },
  priority: TWPriority.high,
);
await queue.onComplete;
print('results = $results');
```


##  Change 

* fix: the problem of exceeding the specified number of concurrent tasks [pull16](https://github.com/rknell/dart_queue/pull/16)
* fix: after cancel,can add to queue [pull17](https://github.com/rknell/dart_queue/pull/17)
* feat: support lifo from [pull18](https://github.com/rknell/dart_queue/pull/18)
* feat: support remove task
* feat: support pause and resume task
* feat: support set task priority

## Thx 
fork form [dart_queue](https://github.com/rknell/dart_queue)
