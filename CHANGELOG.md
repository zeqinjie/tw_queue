## 0.0.1
### Easily queue futures and await their values.
fork form [dart_queue](https://github.com/rknell/dart_queue)
### change
* fix: the problem of exceeding the specified number of concurrent tasks [pull16](https://github.com/rknell/dart_queue/pull/16)
* fix: after cancel,can add to queue [pull17](https://github.com/rknell/dart_queue/pull/17)
* feat: support lifo from [pull18](https://github.com/rknell/dart_queue/pull/18)
* feat: support remove task
* feat: support pause and resume task
* feat: support set task priority

## 0.0.2
* add demo

## 0.0.3
* add removes all items from the queue that have not thrown a [QueueCancelledException]