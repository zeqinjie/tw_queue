<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

The most simple example:
```dart
import 'package:tw_queue/tw_queue_export.dart';

main() async {
  final queue = Queue();

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
  final Queue queue = Queue(delay: Duration(milliseconds: 10));
  
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
  final queue = Queue(parallel: 2);

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
  final queue = Queue(parallel: 2);

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
  final queue = Queue(delay: Duration(milliseconds: 500)); // Set the delay here

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
final queue = Queue();

final remainingItemsStream = queue.remainingItems.listen((numberOfItems)=>print(numberOfItems));

//Queue up a couple of futures
queue.add(()=>Future.delayed(Duration(milliseconds: 10)));
queue.add(()=>Future.delayed(Duration(milliseconds: 10)));

// Will only resolve when all the queue items have resolved.
await queue.onComplete;
remainingItemsStream.close();
queue.dispose(); // Will clean up any resources in the queue if you are done with it.


```
## Change 
- fix: the problem of exceeding the specified number of concurrent tasks [pull16](https://github.com/rknell/dart_queue/pull/16)
- fix: after cancel,can add to queue [pull17](https://github.com/rknell/dart_queue/pull/17)
- feat: support lifo from [pull19](https://github.com/rknell/dart_queue/pull/18)
- feat: support remove task
- feat: support pause and resume task
- feat: support set task priority


## Contributing

Pull requests are welcome. There is a shell script `ci_checks.sh` that will run the checks to get 
past CI and also format the code before committing. If that all passes your PR will likely be accepted.

Please write tests to cover your new feature.


## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.

## Modify Form 
thx and fork form [dart_queue](https://github.com/rknell/dart_queue)
