import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_mobile/features/auth/presentation/widgets/auth_text_field.dart';

void main() {
  group('AuthTextField', () {
    testWidgets('shows obscure text initially and toggles visibility on icon tap',
        (tester) async {
      final controller = TextEditingController(text: 'Secret123!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Şifre',
              controller: controller,
              obscureText: true,
            ),
          ),
        ),
      );

      // Initially obscured
      TextField textField = tester.widget(find.byType(TextField));
      expect(textField.obscureText, true);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      // Tap toggle button to show password
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      textField = tester.widget(find.byType(TextField));
      expect(textField.obscureText, false);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);

      // Tap toggle button again to hide password
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      textField = tester.widget(find.byType(TextField));
      expect(textField.obscureText, true);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('does not show toggle icon when obscureText is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'E-posta',
              obscureText: false,
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsNothing);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, false);
    });
  });
}
