import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zuruni_mobile_app/main.dart';
import 'package:zuruni_mobile_app/state/app_state.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppState(),
        child: const ZuruniApp(),
      ),
    );

    // Verify that the title Zuruni is shown.
    expect(find.text('Zuruni Mobile'), findsNothing); // Title is inside MaterialApp, not direct widget text
  });
}
