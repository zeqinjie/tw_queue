import 'package:example/common/tw_dialog_manager.dart';
import 'package:example/common/tw_show_animation_dialog.dart';
import 'package:example/common/tw_toot.dart';
import 'package:flutter/material.dart';

class TWDialogQueuePage extends StatefulWidget {
  const TWDialogQueuePage({Key? key}) : super(key: key);

  @override
  State<TWDialogQueuePage> createState() => _TWDialogQueuePageState();
}

class _TWDialogQueuePageState extends State<TWDialogQueuePage> {
  final queueManager = TWDialogManager();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TWDialogQueuePage"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text(
                'open',
              ),
              onPressed: () {
                showDialog(context, TWTool.randomColor().toString());
              },
            ),
          ],
        ),
      ),
    );
  }

  showDialog(
    BuildContext context,
    String title,
  ) {
    queueManager.add(
      () => twShowAnimationDialog(
        context: context,
        transitionType: TwTransitionType.inFromBottom,
        builder: (ctx) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                height: 200,
                width: 200,
                color: TWTool.randomColor(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    ElevatedButton(
                      child: const Text(
                        'open',
                      ),
                      onPressed: () {
                        showDialog(context, TWTool.randomColor().toString());
                      },
                    ),
                    ElevatedButton(
                      child: const Text(
                        'cancel',
                      ),
                      onPressed: () {
                        queueManager.cancel();
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
