import 'package:flutter/material.dart';
import 'package:refresh_sticky/refresh_sticky.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Refresh Sticky Example'),
        ),
        body: RefreshSticky(
          reverse: false,
          builder: (context, controller) {
            return ListView.builder(
              reverse: false,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              controller: controller,
              itemCount: 30,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            );
          },
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
        ),
      ),
    );
  }
}
