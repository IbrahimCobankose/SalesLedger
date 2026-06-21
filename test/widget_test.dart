import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales_ledger/app.dart';

void main() {
  testWidgets('App giriş ekranıyla açılır', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pump();

    expect(find.text('Satış Defteri'), findsWidgets);
  });
}
