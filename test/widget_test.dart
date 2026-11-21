
import 'package:flutter_test/flutter_test.dart';
import 'package:lawccheck/main.dart';

void main() {
  testWidgets('Advocate Notebook home screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const AdvocateNotebookApp());

    expect(find.text('Advocate Notebook'), findsOneWidget);
    expect(find.text('Case overview'), findsOneWidget);
    expect(find.text('Upcoming hearings'), findsOneWidget);
    expect(find.text('Rahman vs Karim'), findsOneWidget);
  });
}
