// PixelVerse basic smoke test
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixelverse/main.dart';
import 'package:pixelverse/models/item.dart';
import 'package:pixelverse/models/inventory.dart';
import 'package:pixelverse/models/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches and shows title screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PixelVerseApp());
    await tester.pump();

    expect(find.text('PixelVerse'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
  });

  test('Inventory add and remove items', () {
    final inv = Inventory();
    expect(inv.addItem(Items.wood, 10), equals(0));
    expect(inv.countOf(Items.wood), equals(10));
    expect(inv.removeItem(Items.wood, 4), isTrue);
    expect(inv.countOf(Items.wood), equals(6));
  });

  test('GameState reset gives starter items', () {
    final state = GameState();
    state.reset();
    expect(state.inventory.countOf(Items.axe), equals(1));
    expect(state.inventory.countOf(Items.pickaxe), equals(1));
    expect(state.coins, equals(50));
    expect(state.day, equals(1));
  });

  test('Item catalog has 32 items', () {
    expect(Items.catalog.length, equals(32));
  });
}
