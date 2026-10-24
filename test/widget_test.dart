import 'package:flutter_test/flutter_test.dart';
import 'package:siao_app/main.dart';

void main() {
  testWidgets('Smoke test do SIAOMaisGestaoApp', (WidgetTester tester) async {
    await tester.pumpWidget(const SIAOMaisGestaoApp());
    expect(find.text('SIAO'), findsOneWidget);

    // Aguarda o splash screen avançar para a tela inicial
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SIAO • Mais Gestão'), findsOneWidget);
  });
}
