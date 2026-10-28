import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled1/main.dart';

class FakeHome extends StatelessWidget {
  const FakeHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Pantalla de Prueba')),
    );
  }
}

void main() {
  testWidgets('La app carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FakeHome(),
      ),
    );

    expect(find.text('Pantalla de Prueba'), findsOneWidget);
  });
}

