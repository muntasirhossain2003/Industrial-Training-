import 'package:first_project/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Student ID Card smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp()); // Removed const keyword

    // Verify that the app title is present
    expect(find.text('Student ID Card'), findsOneWidget);

    // Verify that student info is present
    expect(find.text('Muntasir Hossain'), findsOneWidget);
    expect(find.text('210041265'), findsOneWidget);

    // Verify that department info is present
    expect(find.text('Program BSc in CSE'), findsOneWidget);
    expect(find.text('Department CSE'), findsOneWidget);
  });
}
