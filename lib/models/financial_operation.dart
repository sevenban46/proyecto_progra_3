class FinancialOperation {
  int? id;
  String type; // 'loan', 'investment', etc.
  String description;
  double amount;
  double rate;
  int period;
  DateTime date;
  String calculationType; // 'simple', 'compound'

  // Nuevas propiedades para amortización
  String paymentFrequency; // 'monthly', 'quarterly', 'yearly'
  int paymentsPerYear;     // 12, 4, 1 según frecuencia

  FinancialOperation({
    this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.rate,
    required this.period,
    required this.date,
    required this.calculationType,
    this.paymentFrequency = 'monthly',
    this.paymentsPerYear = 12,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'amount': amount,
      'rate': rate,
      'period': period,
      'date': date.toIso8601String(),
      'calculationType': calculationType,
      'paymentFrequency': paymentFrequency,
      'paymentsPerYear': paymentsPerYear,
    };
  }

  factory FinancialOperation.fromMap(Map<String, dynamic> map) {
    return FinancialOperation(
      id: map['id'],
      type: map['type'],
      description: map['description'],
      amount: map['amount'],
      rate: map['rate'],
      period: map['period'],
      date: DateTime.parse(map['date']),
      calculationType: map['calculationType'],
      paymentFrequency: map['paymentFrequency'] ?? 'monthly',
      paymentsPerYear: map['paymentsPerYear'] ?? 12,
    );
  }
}