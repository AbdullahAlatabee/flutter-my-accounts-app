class Account {
  String clientName;
  double dueAmount;
  double paidAmount;
  DateTime registrationDate;
  String category;

  Account({
    required this.clientName,
    required this.dueAmount,
    required this.paidAmount,
    required this.registrationDate,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'clientName': clientName,
    'dueAmount': dueAmount,
    'paidAmount': paidAmount,
    'registrationDate': registrationDate.toIso8601String(),
    'category': category,
  };

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      clientName: json['clientName'],
      dueAmount: json['dueAmount'],
      paidAmount: json['paidAmount'],
      registrationDate: DateTime.parse(json['registrationDate']),
      category: json['category'],
    );
  }
}
