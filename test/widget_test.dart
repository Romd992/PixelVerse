// PixelVerse 基础冒烟测试
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixelverse/main.dart';
import 'package:pixelverse/models/save_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SaveManager.init();
  });

  testWidgets('App launches and shows start screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PixelVerseApp());
    await tester.pump();

    // 验证开始界面标题存在
    expect(find.text('PixelVerse'), findsOneWidget);
    // 验证开始按钮存在
    expect(find.text('开始游戏'), findsOneWidget);
  });
}
