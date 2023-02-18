import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spark/app.dart';

void main() {
  testWidgets('User Preferences Tests', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    SharedPreferences.setMockInitialValues({});
    SharedPreferences pref = await SharedPreferences.getInstance();

    bool useDarkTheme = true;
    pref.setBool('useDarkTheme', useDarkTheme);

    useDarkTheme = false;
    pref.setBool('useDarkTheme', useDarkTheme);
  });
}
