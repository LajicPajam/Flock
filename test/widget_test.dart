import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flock_app/main.dart';

void main() {
  testWidgets('renders login screen by default', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Flock Carpool'), findsOneWidget);
    expect(find.text('New here? Create an account'), findsOneWidget);
  });
}
