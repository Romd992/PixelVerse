import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/title_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape orientation on mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI for immersive game
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const PixelVerseApp());
}

class PixelVerseApp extends StatelessWidget {
  const PixelVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        fontFamily: 'monospace',
      ),
      home: const TitleScreen(),
    );
  }
}
