import 'package:flutter_test/flutter_test.dart';

import 'package:flock_app/main.dart';

void main() {
  testWidgets('renders login screen by default', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Flock Carpool'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });
}
