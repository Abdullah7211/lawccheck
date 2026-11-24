
import 'package:flutter_test/flutter_test.dart';
import 'package:lawccheck/main.dart';

void main() {
  testWidgets('Advocate Notebook app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AdvocateNotebookApp());

    expect(find.text('Advocate Notebook'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cases'), findsOneWidget);
    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
  });
}
