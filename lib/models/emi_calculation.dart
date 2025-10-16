class EMICalculation {
  final int? id;
  final double amount;
  final double interestRate;
  final int periodMonths;
  final double monthlyEMI;
  final double totalInterest;
  final double processingFee;
  final double totalPayment;
  final DateTime calculatedDate;

  EMICalculation({
    this.id,
    required this.amount,
    required this.interestRate,
    required this.periodMonths,
    required this.monthlyEMI,
    required this.totalInterest,
    required this.processingFee,
    required this.totalPayment,
    required this.calculatedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'interestRate': interestRate,
      'periodMonths': periodMonths,
      'monthlyEMI': monthlyEMI,
      'totalInterest': totalInterest,
      'processingFee': processingFee,
      'totalPayment': totalPayment,
      'calculatedDate': calculatedDate.toIso8601String(),
    };
  }

  factory EMICalculation.fromMap(Map<String, dynamic> map) {
    return EMICalculation(
      id: map['id'],
      amount: map['amount'],
      interestRate: map['interestRate'],
      periodMonths: map['periodMonths'],
      monthlyEMI: map['monthlyEMI'],
      totalInterest: map['totalInterest'],
      processingFee: map['processingFee'],
      totalPayment: map['totalPayment'],
      calculatedDate: DateTime.parse(map['calculatedDate']),
    );
  }
}