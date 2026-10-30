import 'package:flutter_test/flutter_test.dart';
import 'package:blastsafe/main.dart';

void main() {
  testWidgets('BlastSafe app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BlastSafeApp());
    expect(find.byType(BlastSafeApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
