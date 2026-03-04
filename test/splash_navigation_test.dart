import 'package:flutter_test/flutter_test.dart';

import 'package:tripme_splash/app.dart';
import 'package:tripme_splash/screens/home/home_screen.dart';

void main() {
  testWidgets('Splash navigates to home after total duration', (tester) async {
    await tester.pumpWidget(const TripMeApp());

    expect(find.byType(HomeScreen), findsNothing);

    // 5.0s splash + fade route transition.
    await tester.pump(const Duration(milliseconds: 5600));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
