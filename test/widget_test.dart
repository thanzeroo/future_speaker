import 'package:flutter_test/flutter_test.dart';
import 'package:future_speaker/main.dart';

void main() {
  testWidgets('Future Speaker smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FutureSpeakerApp());
    expect(find.text('FUTURE SPEAKER'), findsOneWidget);

    // Transition through splash screen
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 700));
  });
}
