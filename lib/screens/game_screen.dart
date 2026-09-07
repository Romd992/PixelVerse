import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import '../game/pixel_verse_game.dart';
import '../models/game_state.dart';
import '../models/item.dart';
import '../models/inventory.dart';
import '../systems/farming_system.dart';
import '../systems/save_system.dart';
import '../components/npc_component.dart';
import '../widgets/hud.dart';
import '../widgets/inventory_overlay.dart';
import '../widgets/crafting_overlay.dart';
import '../widgets/dialog_overlay.dart';
import '../widgets/shop_overlay.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/virtual_joystick.dart';
import '../widgets/action_buttons.dart';
import 'title_screen.dart';

/// The main game screen containing the FlameGame and all overlays.
class GameScreen extends StatefulWidget {
  final bool loadSave;

  const GameScreen({super.key, this.loadSave = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameState _gameState;
  late final PixelVerseGame _game;
  bool _gameReady = false;

  // Overlay states
  bool _showInventory = false;
  bool _showCrafting = false;
  bool _showShop = false;
  bool _showPause = false;
  NpcComponent? _dialogNpc;
  String? _toastMessage;
  DateTime? _toastTime;

  // Keyboard focus node
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _initGame();
  }

  Future<void> _initGame() async {
    if (widget.loadSave) {
      await SaveSystem.loadGame(_gameState);
    } else {
      _gameState.reset();
    }

    _game = PixelVerseGame(gameState: _gameState);

    // Wire up game callbacks
    _game.onStateChanged = () {
      if (mounted) setState(() {});
    };
    _game.onShowMessage = (msg) => _showToast(msg);
    _game.onOpenDialog = (npc) {
      setState(() {
        _dialogNpc = npc;
      });
    };
    _game.onOpenShop = () {
      setState(() {
        _showShop = true;
      });
    };
    _game.onOpenCrafting = () {
      setState(() {
        _showCrafting = true;
      });
    };
    _game.onSleep = () async {
      await _game.sleepAndSave();
      _showToast('Saved and advanced to next day!');
    };
    _game.onPlayerDeath = () {
      _showToast('You died! Respawning at home...');
    };

    if (mounted) {
      setState(() {
        _gameReady = true;
      });
    }
  }

  void _showToast(String message) {
    if (mounted) {
      setState(() {
        _toastMessage = message;
        _toastTime = DateTime.now();
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _toastTime != null) {
          if (DateTime.now().difference(_toastTime!).inSeconds >= 3) {
            setState(() {
              _toastMessage = null;
            });
          }
        }
      });
    }
  }

  void _closeAllOverlays() {
    setState(() {
      _showInventory = false;
      _showCrafting = false;
      _showShop = false;
      _showPause = false;
      _dialogNpc = null;
    });
  }

  bool get _anyOverlayOpen =>
      _showInventory || _showCrafting || _showShop || _showPause || _dialogNpc != null;

  // Track pressed keys for movement
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  // Keyboard handling for desktop debugging
  KeyEventResult _handleKey(FocusNode node, RawKeyEvent event) {
    final key = event.logicalKey;

    if (event is RawKeyDownEvent) {
      _pressedKeys.add(key);

      // Hotbar selection
      if (key == LogicalKeyboardKey.digit1) {
        _gameState.inventory.selectedHotbarIndex = 0;
        setState(() {});
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit2) {
        _gameState.inventory.selectedHotbarIndex = 1;
        setState(() {});
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit3) {
        _gameState.inventory.selectedHotbarIndex = 2;
        setState(() {});
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit4) {
        _gameState.inventory.selectedHotbarIndex = 3;
        setState(() {});
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit5) {
        _gameState.inventory.selectedHotbarIndex = 4;
        setState(() {});
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit6) {
        _gameState.inventory.selectedHotbarIndex = 5;
        setState(() {});
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit7) {
        _gameState.inventory.selectedHotbarIndex = 6;
        setState(() {});
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.digit8) {
        _gameState.inventory.selectedHotbarIndex = 7;
        setState(() {});
        return KeyEventResult.handled;
      }

      // Action keys
      if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyJ) {
        if (!_anyOverlayOpen) _game.handleActionButton();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyE || key == LogicalKeyboardKey.keyF) {
        if (!_anyOverlayOpen) _game.handleInteractButton();
        return KeyEventResult.handled;
      }

      // Inventory toggle
      if (key == LogicalKeyboardKey.keyI || key == LogicalKeyboardKey.keyB) {
        setState(() {
          _showInventory = !_showInventory;
        });
        return KeyEventResult.handled;
      }

      // Pause
      if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.keyP) {
        setState(() {
          _showPause = !_showPause;
        });
        return KeyEventResult.handled;
      }
    }

    if (event is RawKeyUpEvent) {
      _pressedKeys.remove(key);
    }

    // Movement via keyboard (WASD / arrows)
    if (event is RawKeyDownEvent || event is RawKeyUpEvent) {
      _updateMovementFromKeys();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _updateMovementFromKeys() {
    Vector2 input = Vector2.zero();
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      input.y -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      input.y += 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      input.x -= 1;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      input.x += 1;
    }
    if (input.length > 0) {
      input = input.normalized();
    }
    if (!_anyOverlayOpen) {
      _game.setJoystickInput(input);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Loading PixelVerse...',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKey: _handleKey,
        child: Stack(
          children: [
            // Flame game
            GameWidget(game: _game),

            // HUD (only when no overlay is open)
            if (!_anyOverlayOpen)
              Hud(
                gameState: _gameState,
                onHotbarSelect: (index) {
                  _gameState.inventory.selectedHotbarIndex = index;
                  setState(() {});
                },
                onOpenInventory: () {
                  setState(() => _showInventory = true);
                },
                onPause: () {
                  setState(() => _showPause = true);
                },
              ),

            // Touch controls (only when no overlay is open)
            if (!_anyOverlayOpen)
              SafeArea(
                child: Stack(
                  children: [
                    // Virtual joystick (bottom-left)
                    Positioned(
                      left: 16,
                      bottom: 80,
                      child: VirtualJoystick(
                        onDirectionChanged: (dir) {
                          _game.setJoystickInput(dir);
                        },
                        onIdle: () {
                          _game.setJoystickInput(Vector2.zero());
                        },
                      ),
                    ),
                    // Action buttons (bottom-right)
                    Positioned(
                      right: 16,
                      bottom: 90,
                      child: ActionButtons(
                        onAction: () => _game.handleActionButton(),
                        onInteract: () => _game.handleInteractButton(),
                        actionLabel: _getActionLabel(),
                        interactLabel: 'Interact',
                      ),
                    ),
                  ],
                ),
              ),

            // Toast message
            if (_toastMessage != null)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Text(
                      _toastMessage!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),

            // Inventory overlay
            if (_showInventory)
              InventoryOverlay(
                gameState: _gameState,
                onClose: () => setState(() => _showInventory = false),
                onSelectSlot: (index) {
                  _gameState.inventory.selectedHotbarIndex = index;
                  setState(() {});
                },
              ),

            // Crafting overlay
            if (_showCrafting)
              CraftingOverlay(
                gameState: _gameState,
                station: 'workbench',
                onClose: () => setState(() => _showCrafting = false),
                onCrafted: () => setState(() {}),
              ),

            // Shop overlay
            if (_showShop)
              ShopOverlay(
                gameState: _gameState,
                onClose: () => setState(() => _showShop = false),
                onTransaction: () => setState(() {}),
              ),

            // Dialog overlay
            if (_dialogNpc != null)
              DialogOverlay(
                npc: _dialogNpc!,
                onClose: () => setState(() => _dialogNpc = null),
              ),

            // Pause overlay
            if (_showPause)
              PauseOverlay(
                onResume: () => setState(() => _showPause = false),
                onSave: () async {
                  await SaveSystem.saveGame(_gameState);
                  _showToast('Game saved!');
                },
                onTitle: () async {
                  await SaveSystem.saveGame(_gameState);
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const TitleScreen()),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getActionLabel() {
    final slot = _gameState.inventory.selectedSlot;
    if (slot.isEmpty) return 'Action';
    switch (slot.itemId) {
      case Items.axe:
        return 'Chop';
      case Items.pickaxe:
        return 'Mine';
      case Items.sword:
        return 'Attack';
      case Items.hoe:
        return 'Till';
      case Items.wateringCan:
        return 'Water';
      default:
        if (CropTypes.fromSeedId(slot.itemId) != null) return 'Plant';
        return 'Action';
    }
  }
}
