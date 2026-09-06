import 'package:flutter/material.dart';
import 'game/game_screen.dart';
import 'models/save_manager.dart';

/// PixelVerse 应用入口
///
/// 初始化 shared_preferences 存档后启动应用。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SaveManager.init();
  runApp(const PixelVerseApp());
}

/// 应用根组件
class PixelVerseApp extends StatelessWidget {
  const PixelVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
