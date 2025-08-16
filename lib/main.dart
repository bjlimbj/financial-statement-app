import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '테스트 앱',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('테스트 앱'),
        ),
        body: const Center(
          child: Text(
            '안녕하세요! 앱이 실행되었습니다!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
