import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/main.dart';

void main() {
  testWidgets('App should start', (WidgetTester tester) async {
    await tester.pumpWidget(const IkaSmanSaraApp());
    expect(find.text('IKA SMANSARA'), findsWidgets);
  });
}
