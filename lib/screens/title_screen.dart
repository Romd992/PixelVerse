import 'package:flutter/material.dart';
import '../systems/save_system.dart';
import 'game_screen.dart';

/// The title / main menu screen.
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  bool _hasSave = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSave();
  }

  Future<void> _checkSave() async {
    final has = await SaveSystem.hasSave();
    if (mounted) {
      setState(() {
        _hasSave = has;
        _loading = false;
      });
    }
  }

  void _startNewGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen(loadSave: false)),
    );
  }

  void _continueGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen(loadSave: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a237e),
              Color(0xFF283593),
              Color(0xFF3949ab),
              Color(0xFF5c6bc0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative stars
            ..._buildStars(),
            // Title and buttons
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game title
                  const Text(
                    'PixelVerse',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(4, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A Sandbox Survival Adventure',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Buttons
                  if (_loading)
                    const CircularProgressIndicator(color: Colors.white)
                  else ...[
                    _buildMenuButton(
                      'New Game',
                      Icons.nature,
                      Colors.green,
                      _startNewGame,
                    ),
                    const SizedBox(height: 16),
                    if (_hasSave)
                      _buildMenuButton(
                        'Continue',
                        Icons.play_arrow,
                        Colors.blue,
                        _continueGame,
                      ),
                    if (_hasSave) const SizedBox(height: 16),
                    _buildMenuButton(
                      'Settings',
                      Icons.settings,
                      Colors.grey,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Settings coming soon!')),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            // Version
            const Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'v1.0.0',
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    final stars = <Widget>[];
    for (int i = 0; i < 30; i++) {
      final left = (i * 37.0) % MediaQuery.of(context).size.width;
      final top = (i * 23.0) % (MediaQuery.of(context).size.height * 0.6);
      final size = 1.0 + (i % 3);
      stars.add(
        Positioned(
          left: left,
          top: top,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return stars;
  }

  Widget _buildMenuButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: 260,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
