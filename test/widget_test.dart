// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:calculadora_financiera/controllers/financial_controller.dart';
import 'package:calculadora_financiera/models/financial_operation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculadora_financiera/main.dart';

void main() {
  final controller = FinancialController();
  final testLoan = FinancialOperation(
    type: 'loan',
    description: 'Test Loan',
    amount: 10000,
    rate: 5.0,
    period: 5,
    date: DateTime.now(),
    calculationType: 'compound',
    paymentFrequency: 'monthly',
    paymentsPerYear: 12,
  );

  test('Calculate monthly payment', () {
    final payment = controller.calculateLoanPayment(testLoan);
    expect(payment.toStringAsFixed(2), equals('188.71'));
  });

  test('Generate amortization table', () {
    final table = controller.generateAmortizationTable(testLoan);
    expect(table.length, equals(60)); // 5 años * 12 meses
    expect(table.first.interest.toStringAsFixed(2), equals('41.67'));
    expect(table.last.remainingBalance.abs().toStringAsFixed(2), equals('0.00')); // Usamos abs()
  });
  /*testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });*/
}
