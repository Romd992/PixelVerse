import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_world.dart';
import '../models/enemy.dart';
import '../models/collectible.dart';
import '../models/obstacle.dart';
import '../models/weapon.dart';
import '../models/skill.dart';
import '../models/projectile.dart';
import '../models/particle.dart';
import '../models/damage_number.dart';
import '../models/save_manager.dart';
import '../models/level_config.dart';
import '../widgets/hud.dart';
import '../widgets/minimap.dart';
import '../widgets/boss_health_bar.dart';
import '../widgets/touch_controls.dart';
import '../screens/start_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/level_transition_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/pause_screen.dart';
import '../screens/victory_screen.dart';
import '../screens/game_over_screen.dart';

/// 游戏阶段
enum GamePhase {
  menu,
  levelSelect,
  settings,
  levelTransition,
  playing,
  paused,
  shop,
  victory,
  gameOver,
}

/// 游戏主屏幕
///
/// 管理游戏循环、输入、渲染、阶段切换、存档。
/// 所有 UI 控件使用 SafeArea 避开刘海/底部横条，触屏控件均 >= 44pt。
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameWorld _world;
  late Timer _gameTimer;
  GamePhase _phase = GamePhase.menu;
  final FocusNode _focusNode = FocusNode();
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  /// 关卡过渡计时器
  Timer? _transitionTimer;

  /// 屏幕尺寸缓存
  double _screenWidth = 800;
  double _screenHeight = 600;

  /// 本局总用时（跨关卡累计）
  double _totalTime = 0;

  // ==================== 生命周期 ====================

  @override
  void initState() {
    super.initState();
    _world = GameWorld();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), _onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheImages());
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _transitionTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _precacheImages() {
    const assets = [
      'assets/images/player.png', 'assets/images/slime.png',
      'assets/images/bat.png', 'assets/images/coin.png',
      'assets/images/heart.png', 'assets/images/gem.png',
      'assets/images/tree.png', 'assets/images/rock.png',
      'assets/images/grass.png', 'assets/images/potion.png',
      'assets/images/portal.png', 'assets/images/sign.png',
      'assets/images/boss.png', 'assets/images/archer.png',
      'assets/images/boar.png', 'assets/images/bomb.png',
      'assets/images/bow.png', 'assets/images/staff.png',
      'assets/images/merchant.png', 'assets/images/arrow.png',
      'assets/images/fireball.png', 'assets/images/dungeon.png',
      'assets/images/chest.png', 'assets/images/lava.png',
      'assets/images/shield.png', 'assets/images/boots.png',
      'assets/images/background.png',
    ];
    for (final a in assets) {
      precacheImage(AssetImage(a), context);
    }
  }

  // ==================== 游戏循环 ====================

  void _onTick(Timer timer) {
    if (_phase != GamePhase.playing) return;

    _applyKeyboardInput();
    _world.update(0.016, _screenWidth, _screenHeight);
    _totalTime += 0.016;

    // 关卡完成 → 进入下一关过渡
    if (_world.levelComplete) {
      _onLevelComplete();
      return;
    }

    // 最终胜利
    if (_world.state == GameState.victory) {
      _onVictory();
      return;
    }

    // 游戏结束
    if (_world.state == GameState.gameOver) {
      _onGameOver();
      return;
    }

    setState(() {});
  }

  // ==================== 阶段切换 ====================

  /// 从主菜单开始新游戏（从第1关）
  void _startNewGame() {
    _totalTime = 0;
    _world.player.fullReset(0, 0); // 重置等级等跨关卡数据
    _loadLevel(0);
  }

  /// 从关卡选择进入指定关卡
  void _startFromLevel(int index) {
    _totalTime = 0;
    _world.player.fullReset(0, 0);
    _loadLevel(index);
  }

  /// 加载关卡并显示过渡画面
  void _loadLevel(int index) {
    _world.loadLevel(index);
    setState(() => _phase = GamePhase.levelTransition);
    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _phase = GamePhase.playing);
        _focusNode.requestFocus();
      }
    });
  }

  /// 关卡完成 → 下一关或最终胜利
  void _onLevelComplete() {
    final next = _world.currentLevel + 1;
    if (next < LevelConfig.levels.length) {
      SaveManager.unlockLevel(next);
      _loadLevel(next);
    } else {
      _onVictory();
    }
  }

  void _onVictory() {
    SaveManager.submitScore(_world.score);
    SaveManager.addKills(_world.player.kills);
    SaveManager.unlockLevel(2); // 解锁全部
    setState(() => _phase = GamePhase.victory);
  }

  void _onGameOver() {
    SaveManager.submitScore(_world.score);
    SaveManager.addKills(_world.player.kills);
    setState(() => _phase = GamePhase.gameOver);
  }

  void _pauseGame() {
    _pressedKeys.clear();
    _world.setKeyboardInput(0, 0);
    setState(() => _phase = GamePhase.paused);
  }

  void _resumeGame() {
    setState(() => _phase = GamePhase.playing);
    _focusNode.requestFocus();
  }

  void _restartLevel() {
    _world.loadLevel(_world.currentLevel);
    setState(() => _phase = GamePhase.playing);
    _focusNode.requestFocus();
  }

  void _backToMenu() {
    _transitionTimer?.cancel();
    _pressedKeys.clear();
    setState(() => _phase = GamePhase.menu);
  }

  void _openShop() {
    setState(() => _phase = GamePhase.shop);
  }

  void _closeShop() {
    setState(() => _phase = GamePhase.playing);
    _focusNode.requestFocus();
  }

  // ==================== 键盘输入 ====================

  void _applyKeyboardInput() {
    double dx = 0, dy = 0;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) dx -= 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) dx += 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) dy -= 1;
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) dy += 1;
    _world.setKeyboardInput(dx, dy);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
      final k = event.logicalKey;
      // 攻击
      if (k == LogicalKeyboardKey.space) {
        _world.requestAttack();
        return KeyEventResult.handled;
      }
      // 技能 Q/W/E
      if (k == LogicalKeyboardKey.keyQ) {
        _world.castSkill(SkillType.dash);
      }
      if (k == LogicalKeyboardKey.keyW) {
        _world.castSkill(SkillType.whirlwind);
      }
      if (k == LogicalKeyboardKey.keyE) {
        _world.castSkill(SkillType.heal);
      }
      // 武器切换 1/2/3
      if (k == LogicalKeyboardKey.digit1) {
        _world.switchWeapon(WeaponType.sword);
      }
      if (k == LogicalKeyboardKey.digit2) {
        _world.switchWeapon(WeaponType.bow);
      }
      if (k == LogicalKeyboardKey.digit3) {
        _world.switchWeapon(WeaponType.staff);
      }
      // ESC 暂停
      if (k == LogicalKeyboardKey.escape) {
        if (_phase == GamePhase.playing) {
          _pauseGame();
        } else if (_phase == GamePhase.paused) {
          _resumeGame();
        } else if (_phase == GamePhase.shop) {
          _closeShop();
        }
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
    return KeyEventResult.ignored;
  }

  // ==================== 构建 ====================

  @override
  Widget build(BuildContext context) {
    final renderWorld = _phase != GamePhase.menu &&
        _phase != GamePhase.levelSelect &&
        _phase != GamePhase.settings;
    final renderUI = _phase == GamePhase.playing ||
        _phase == GamePhase.paused ||
        _phase == GamePhase.shop;

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKeyEvent,
        autofocus: true,
        child: Stack(
          children: [
            // 游戏世界（全屏渲染，不受 SafeArea 限制）
            if (renderWorld) _buildGameWorld(),

            // UI 层（HUD + 小地图 + BOSS血条 + 触屏控件 + 商人提示）
            if (renderUI)
              SafeArea(
                child: Stack(
                  children: [
                    HUD(
                      hp: _world.player.hp,
                      maxHp: _world.player.maxHp,
                      coins: _world.coinsCollected,
                      score: _world.score,
                      hint: _world.hint,
                      level: _world.player.level,
                      xp: _world.player.xp,
                      xpToNext: _world.player.xpToNext,
                      onPause: _pauseGame,
                    ),
                    // 小地图（右上角，HUD 下方）
                    Positioned(
                      right: 10,
                      top: 108,
                      child: Minimap(world: _world),
                    ),
                    // BOSS 血条
                    if (_world.boss != null && !_world.boss!.isDead)
                      Positioned(
                        top: 52,
                        left: 0,
                        right: 0,
                        child: BossHealthBar(
                            hpRatio: _world.boss!.bossHpRatio),
                      ),
                    // 触屏控件（仅游戏中）
                    if (_phase == GamePhase.playing)
                      TouchControls(world: _world),
                    // 商人交互提示
                    if (_phase == GamePhase.playing && _world.nearMerchant)
                      _buildMerchantPrompt(),
                  ],
                ),
              ),

            // 全屏覆盖界面
            if (_phase == GamePhase.menu)
              StartScreen(
                onStart: _startNewGame,
                onLevelSelect: () =>
                    setState(() => _phase = GamePhase.levelSelect),
                onSettings: () =>
                    setState(() => _phase = GamePhase.settings),
              ),
            if (_phase == GamePhase.levelSelect)
              LevelSelectScreen(
                onBack: () => setState(() => _phase = GamePhase.menu),
                onSelectLevel: _startFromLevel,
              ),
            if (_phase == GamePhase.settings)
              SettingsScreen(
                onBack: () => setState(() => _phase = GamePhase.menu),
              ),
            if (_phase == GamePhase.levelTransition)
              LevelTransitionScreen(
                levelIndex: _world.currentLevel,
                levelName: _world.level.name,
                objective: _world.level.objectiveText,
              ),
            if (_phase == GamePhase.paused)
              PauseScreen(
                onResume: _resumeGame,
                onRestartLevel: _restartLevel,
                onMenu: _backToMenu,
              ),
            if (_phase == GamePhase.shop)
              ShopScreen(world: _world, onClose: _closeShop),
            if (_phase == GamePhase.victory)
              VictoryScreen(
                score: _world.score,
                coins: _world.coinsCollected,
                kills: _world.player.kills,
                elapsedTime: _totalTime,
                onRestart: _startNewGame,
                onMenu: _backToMenu,
              ),
            if (_phase == GamePhase.gameOver)
              GameOverScreen(
                score: _world.score,
                coins: _world.coinsCollected,
                kills: _world.player.kills,
                elapsedTime: _totalTime,
                onRestart: _startNewGame,
                onMenu: _backToMenu,
              ),
          ],
        ),
      ),
    );
  }

  // ==================== 商人提示 ====================

  Widget _buildMerchantPrompt() {
    final m = _world.merchant;
    if (m == null) return const SizedBox.shrink();
    final sx = m.x - _world.renderCameraX;
    final sy = m.y - _world.renderCameraY;
    return Positioned(
      left: sx - 10,
      top: sy - 40,
      child: GestureDetector(
        onTap: _openShop,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.brown, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 4),
            ],
          ),
          child: const Text(
            '商店',
            style: TextStyle(
                color: Colors.brown, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ==================== 游戏世界渲染 ====================

  Widget _buildGameWorld() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _screenWidth = constraints.maxWidth;
        _screenHeight = constraints.maxHeight;
        final camX = _world.renderCameraX;
        final camY = _world.renderCameraY;

        return Stack(
          children: [
            // 地面背景（随关卡变化，平铺）
            Positioned(
              left: -camX,
              top: -camY,
              child: Container(
                width: _world.worldWidth,
                height: _world.worldHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_world.level.backgroundAsset),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
            // 障碍物
            ..._world.obstacles.map((o) => _buildObstacle(o, camX, camY)),
            // 宝箱
            if (_world.chest != null)
              _buildChest(camX, camY),
            // 商人
            if (_world.merchant != null)
              _buildMerchant(camX, camY),
            // 传送门
            if (_world.portal != null)
              _buildPortal(camX, camY),
            // 武器拾取
            ..._world.weaponPickups.map((w) => _buildWeaponPickup(w, camX, camY)),
            // 收集物
            ..._world.collectibles.map((c) => _buildCollectible(c, camX, camY)),
            // 弹道
            ..._world.projectiles.map((p) => _buildProjectile(p, camX, camY)),
            // 敌人
            ..._world.enemies.map((e) => _buildEnemy(e, camX, camY)),
            // 玩家
            _buildPlayer(camX, camY),
            // 粒子特效
            ..._world.particles.map((p) => _buildParticle(p, camX, camY)),
            // 伤害飘字
            ..._world.damageNumbers.map((d) => _buildDamageNumber(d, camX, camY)),
          ],
        );
      },
    );
  }

  double _sx(double wx, double camX) => wx - camX;
  double _sy(double wy, double camY) => wy - camY;

  Widget _buildObstacle(Obstacle obs, double camX, double camY) {
    String asset;
    switch (obs.type) {
      case ObstacleType.tree:
        asset = 'assets/images/tree.png';
        break;
      case ObstacleType.rock:
        asset = 'assets/images/rock.png';
        break;
      case ObstacleType.sign:
        asset = 'assets/images/sign.png';
        break;
    }
    return Positioned(
      left: _sx(obs.x, camX),
      top: _sy(obs.y, camY),
      width: obs.width,
      height: obs.height,
      child: Image.asset(asset,
          filterQuality: FilterQuality.low, fit: BoxFit.contain),
    );
  }

  Widget _buildChest(double camX, double camY) {
    final c = _world.chest!;
    return Positioned(
      left: _sx(c.x, camX),
      top: _sy(c.y, camY),
      width: c.width,
      height: c.height,
      child: Opacity(
        opacity: c.opened ? 0.4 : 1.0,
        child: Image.asset(c.asset,
            filterQuality: FilterQuality.low, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildMerchant(double camX, double camY) {
    final m = _world.merchant!;
    return Positioned(
      left: _sx(m.x, camX),
      top: _sy(m.y, camY),
      width: m.width,
      height: m.height,
      child: Image.asset(m.asset,
          filterQuality: FilterQuality.low, fit: BoxFit.contain),
    );
  }

  Widget _buildPortal(double camX, double camY) {
    final portal = _world.portal!;
    final active = _world.level.objectiveType == ObjectiveType.killAll
        ? _world.enemiesRemaining == 0
        : _world.coinsCollected >= _world.level.objectiveValue;
    return Positioned(
      left: _sx(portal.x, camX),
      top: _sy(portal.y, camY),
      width: portal.width,
      height: portal.height,
      child: Opacity(
        opacity: active ? 1.0 : 0.5,
        child: Transform.scale(
          scale: portal.pulseScale,
          child: Image.asset('assets/images/portal.png',
              filterQuality: FilterQuality.low, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildWeaponPickup(WeaponPickup w, double camX, double camY) {
    if (w.collected) return const SizedBox.shrink();
    final asset = WeaponInfo.of(w.weapon).pickupAsset;
    if (asset == null) return const SizedBox.shrink();
    return Positioned(
      left: _sx(w.x, camX),
      top: _sy(w.y, camY),
      width: 32,
      height: 32,
      child: Image.asset(asset,
          filterQuality: FilterQuality.low, fit: BoxFit.contain),
    );
  }

  Widget _buildCollectible(Collectible c, double camX, double camY) {
    String asset;
    switch (c.type) {
      case CollectibleType.coin:
        asset = 'assets/images/coin.png';
        break;
      case CollectibleType.gem:
        asset = 'assets/images/gem.png';
        break;
      case CollectibleType.potion:
        asset = 'assets/images/potion.png';
        break;
    }
    double opacity = 1.0, scale = 1.0;
    if (c.collected) {
      final t = (c.collectAnim / c.collectDuration).clamp(0.0, 1.0);
      opacity = 1.0 - t;
      scale = 1.0 + t * 0.8;
    }
    return Positioned(
      left: _sx(c.x, camX),
      top: _sy(c.y + c.bobOffset, camY),
      width: c.width,
      height: c.height,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Image.asset(asset,
              filterQuality: FilterQuality.low, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildProjectile(Projectile p, double camX, double camY) {
    Widget img = Image.asset(p.asset,
        filterQuality: FilterQuality.low, fit: BoxFit.contain);
    // 箭矢需要旋转朝向
    if (p.type == ProjectileType.arrow) {
      img = Transform.rotate(angle: p.angle, child: img);
    }
    return Positioned(
      left: _sx(p.x, camX),
      top: _sy(p.y, camY),
      width: p.width,
      height: p.height,
      child: img,
    );
  }

  Widget _buildEnemy(Enemy enemy, double camX, double camY) {
    double opacity = 1.0, scale = 1.0;
    if (enemy.isDead) {
      final t = (enemy.deathTimer / enemy.deathDuration).clamp(0.0, 1.0);
      opacity = 1.0 - t;
      scale = 1.0 - t * 0.5;
    }
    // 炸弹怪引信闪烁
    if (enemy.type == EnemyType.bomb && enemy.fuseLit) {
      opacity = (DateTime.now().millisecondsSinceEpoch ~/ 100) % 2 == 0
          ? 1.0
          : 0.4;
    }

    Widget sprite = Image.asset(enemy.asset,
        filterQuality: FilterQuality.low, fit: BoxFit.contain);

    if (enemy.hitFlash > 0) {
      sprite = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        child: sprite,
      );
    }

    return Positioned(
      left: _sx(enemy.x, camX),
      top: _sy(enemy.y, camY),
      width: enemy.width,
      height: enemy.height,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(scale: scale, child: sprite),
      ),
    );
  }

  Widget _buildPlayer(double camX, double camY) {
    final p = _world.player;
    double opacity = 1.0;
    if (p.isInvincible && !p.isDashing) {
      opacity = (p.invincibleTimer * 10).floor() % 2 == 0 ? 0.35 : 1.0;
    }
    if (p.isDashing) opacity = 0.7;

    double scale = p.isAttacking ? 1.12 : 1.0;
    if (p.whirlwindFlash > 0) scale = 1.2;

    Widget sprite = Image.asset('assets/images/player.png',
        filterQuality: FilterQuality.low, fit: BoxFit.contain);

    // 升级发光
    if (p.levelUpFlash > 0) {
      sprite = ColorFiltered(
        colorFilter: ColorFilter.mode(
            Colors.cyan.withOpacity(0.4), BlendMode.srcOver),
        child: sprite,
      );
    }

    return Positioned(
      left: _sx(p.x, camX),
      top: _sy(p.y, camY),
      width: p.width,
      height: p.height,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(scale: scale, child: sprite),
      ),
    );
  }

  Widget _buildParticle(Particle p, double camX, double camY) {
    return Positioned(
      left: _sx(p.x, camX) - p.size / 2,
      top: _sy(p.y, camY) - p.size / 2,
      width: p.size,
      height: p.size,
      child: Opacity(
        opacity: p.opacity,
        child: Container(
          decoration: BoxDecoration(
            color: p.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildDamageNumber(DamageNumber d, double camX, double camY) {
    return Positioned(
      left: _sx(d.x, camX) - 20,
      top: _sy(d.y + d.floatOffset, camY),
      width: 40,
      child: Opacity(
        opacity: d.opacity,
        child: Text(
          d.isHeal ? '+${d.value}' : '${d.value}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: d.isHeal ? Colors.greenAccent : Colors.redAccent,
            fontSize: d.fontSize,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
          ),
        ),
      ),
    );
  }
}
