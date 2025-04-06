class AmortizationEntry {
  final int paymentNumber;
  final DateTime date;
  final double payment;
  final double principal;
  final double interest;
  final double remainingBalance;

  AmortizationEntry({
    required this.paymentNumber,
    required this.date,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.remainingBalance,
  });
}