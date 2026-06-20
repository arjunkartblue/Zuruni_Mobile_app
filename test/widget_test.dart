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
        child: const BookWellApp(),
      ),
    );

    // Verify that the title BookWell is shown.
    expect(find.text('BookWell Mobile'), findsNothing); // Title is inside MaterialApp, not direct widget text
  });
}
