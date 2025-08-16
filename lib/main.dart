import 'package:flutter/material.dart';
import 'config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '재무제표 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
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
      appBar: AppBar(
        title: const Text('재무제표 시각화 앱'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '재무제표 시각화 앱',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('환경 변수 설정 완료!'),
            Text('DART API 키가 설정되었습니다.'),
          ],
        ),
      ),
    );
  }
}
