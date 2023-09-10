import 'package:example/route_observer.dart';
import 'package:example/tw_queue_test_app.dart';

import 'package:flutter/material.dart';

import 'tw_dialog_queue_page.dart';

void main() => runApp(const TWQueuePage());

class TWQueuePage extends StatelessWidget {
  const TWQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          _buildTextButton(
            context,
            'TWDialogQueuePage',
            (context) => const TWDialogQueuePage(),
          ),
          _buildTextButton(
            context,
            'TWQueueTestPage',
            (context) => const TWQueueTestPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextButton(
    BuildContext context,
    String text,
    WidgetBuilder builder,
  ) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: builder),
        );
      },
      child: Text(text),
    );
  }
}
