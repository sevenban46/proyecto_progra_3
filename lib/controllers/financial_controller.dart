import 'dart:math';

import '../models/amortizacion.dart';
import '../models/financial_operation.dart';
import '../repositories/database_helper.dart';

class FinancialController {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Financial calculations
  double calculateSimpleInterest(double principal, double rate, int time) {
    return principal * rate * time / 100;
  }

  double calculateCompoundInterest(double principal, double rate, int time) {
    return principal * (pow(1 + rate / 100, time) - 1);
  }

  double calculateFutureValue(double principal, double rate, int time) {
    return principal * pow(1 + rate / 100, time);
  }

  double calculateAnnuityPayment(double principal, double rate, int time) {
    if (rate == 0) return principal / time;
    return principal * rate / 100 * pow(1 + rate / 100, time) / (pow(1 + rate / 100, time) - 1);
  }

  // CRUD Operations
  Future<int> addOperation(FinancialOperation operation) async {
    return await _databaseHelper.create(operation);
  }

  Future<List<FinancialOperation>> getAllOperations() async {
    return await _databaseHelper.readAll();
  }

  Future<FinancialOperation?> getOperation(int id) async {
    return await _databaseHelper.read(id);
  }

  Future<int> updateOperation(FinancialOperation operation) async {
    return await _databaseHelper.update(operation);
  }

  Future<int> deleteOperation(int id) async {
    return await _databaseHelper.delete(id);
  }

  // Calcula el pago periódico de un préstamo
  double calculateLoanPayment(FinancialOperation loan) {
    final ratePerPeriod = loan.rate / 100 / loan.paymentsPerYear;
    final totalPayments = loan.period * loan.paymentsPerYear;

    if (ratePerPeriod == 0) {
      return loan.amount / totalPayments;
    }

    return loan.amount *
        ratePerPeriod *
        pow(1 + ratePerPeriod, totalPayments) /
        (pow(1 + ratePerPeriod, totalPayments) - 1);
  }
  // Genera la tabla de amortización
  List<AmortizationEntry> generateAmortizationTable(FinancialOperation loan) {
    final payment = calculateLoanPayment(loan);
    final ratePerPeriod = loan.rate / 100 / loan.paymentsPerYear;
    final totalPayments = loan.period * loan.paymentsPerYear;

    double balance = loan.amount;
    final table = <AmortizationEntry>[];
    DateTime currentDate = loan.date;

    for (int i = 1; i <= totalPayments; i++) {
      final interest = balance * ratePerPeriod;
      double principal = payment - interest;
      double newBalance = balance - principal;

      // Ajuste para el último pago
      if (i == totalPayments) {
        principal = balance;
        newBalance = 0;
      }

      table.add(AmortizationEntry(
        paymentNumber: i,
        date: currentDate,
        payment: i == totalPayments ? (principal + interest) : payment,
        principal: principal,
        interest: interest,
        remainingBalance: newBalance,
      ));

      balance = newBalance;

      // Actualizar fecha según frecuencia de pago
      currentDate = _addPeriodToDate(currentDate, loan.paymentFrequency);
    }

    return table;
  }

  /*List<AmortizationEntry> generateAmortizationTable(FinancialOperation loan) {
    final payment = calculateLoanPayment(loan);
    final monthlyRate = loan.rate / 100 / 12; // Tasa mensual
    double balance = loan.amount;

    final table = <AmortizationEntry>[];
    DateTime currentDate = loan.date;

    for (int i = 1; i <= loan.period * 12; i++) {
      final interest = balance * monthlyRate;
      final principal = payment - interest;
      final newBalance = balance - principal;

      table.add(AmortizationEntry(
        paymentNumber: i,
        date: currentDate,
        payment: payment,
        principal: principal,
        interest: interest,
        remainingBalance: newBalance > 0.01 ? newBalance : 0, // Evita valores negativos
      ));

      balance = newBalance;
      currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);

      // Actualizar fecha según frecuencia de pago
      currentDate = _addPeriodToDate(currentDate, loan.paymentFrequency);
    }

    return table;
  }*/

  DateTime _addPeriodToDate(DateTime date, String frequency) {
    switch (frequency) {
      case 'monthly':
        return DateTime(date.year, date.month + 1, date.day);
      case 'quarterly':
        return DateTime(date.year, date.month + 3, date.day);
      case 'yearly':
        return DateTime(date.year + 1, date.month, date.day);
      default:
        return DateTime(date.year, date.month + 1, date.day);
    }
  }
}