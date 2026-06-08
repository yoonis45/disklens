import 'package:disklens/Provider/DirManager.dart';
import 'package:disklens/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App loads with Disklens title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => Dirmanager(),
        child: const MyApp(),
      ),
    );

    expect(find.text('D I S K L E N S'), findsOneWidget);
  });
}
