import 'package:flutter/foundation.dart';

// Payroll Models
class PayrollRecord {
  final int id;
  final int employeeId;
  final String employeeName;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final double hoursWorked;
  final double hourlyRate;
  final double regularHours;
  final double overtimeHours;
  final double grossPay;
  final double taxDeductions;
  final double benefitDeductions;
  final double otherDeductions;
  final double netPay;
  final PayrollStatus status;
  final DateTime? processedDate;

  PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.hoursWorked,
    required this.hourlyRate,
    required this.regularHours,
    required this.overtimeHours,
    required this.grossPay,
    required this.taxDeductions,
    required this.benefitDeductions,
    required this.otherDeductions,
    required this.netPay,
    this.status = PayrollStatus.draft,
    this.processedDate,
  });

  PayrollRecord copyWith({
    int? id,
    int? employeeId,
    String? employeeName,
    DateTime? payPeriodStart,
    DateTime? payPeriodEnd,
    double? hoursWorked,
    double? hourlyRate,
    double? regularHours,
    double? overtimeHours,
    double? grossPay,
    double? taxDeductions,
    double? benefitDeductions,
    double? otherDeductions,
    double? netPay,
    PayrollStatus? status,
    DateTime? processedDate,
  }) {
    return PayrollRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      payPeriodStart: payPeriodStart ?? this.payPeriodStart,
      payPeriodEnd: payPeriodEnd ?? this.payPeriodEnd,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      regularHours: regularHours ?? this.regularHours,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      grossPay: grossPay ?? this.grossPay,
      taxDeductions: taxDeductions ?? this.taxDeductions,
      benefitDeductions: benefitDeductions ?? this.benefitDeductions,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      netPay: netPay ?? this.netPay,
      status: status ?? this.status,
      processedDate: processedDate ?? this.processedDate,
    );
  }
}

enum PayrollStatus { draft, pending, processed, paid }

extension PayrollStatusExtension on PayrollStatus {
  String get displayName {
    switch (this) {
      case PayrollStatus.draft:
        return 'Draft';
      case PayrollStatus.pending:
        return 'Pending';
      case PayrollStatus.processed:
        return 'Processed';
      case PayrollStatus.paid:
        return 'Paid';
    }
  }
}

class PayrollService extends ChangeNotifier {
  static final PayrollService _instance = PayrollService._internal();
  factory PayrollService() => _instance;
  PayrollService._internal();

  final List<PayrollRecord> _payrollRecords = [
    PayrollRecord(
      id: 1,
      employeeId: 1,
      employeeName: 'Sarah Johnson',
      payPeriodStart: DateTime.now().subtract(const Duration(days: 14)),
      payPeriodEnd: DateTime.now().subtract(const Duration(days: 1)),
      hoursWorked: 80,
      hourlyRate: 25.0,
      regularHours: 80,
      overtimeHours: 0,
      grossPay: 2000.0,
      taxDeductions: 400.0,
      benefitDeductions: 150.0,
      otherDeductions: 50.0,
      netPay: 1400.0,
      status: PayrollStatus.paid,
      processedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PayrollRecord(
      id: 2,
      employeeId: 2,
      employeeName: 'Mike Chen',
      payPeriodStart: DateTime.now().subtract(const Duration(days: 14)),
      payPeriodEnd: DateTime.now().subtract(const Duration(days: 1)),
      hoursWorked: 85,
      hourlyRate: 30.0,
      regularHours: 80,
      overtimeHours: 5,
      grossPay: 2625.0,
      taxDeductions: 525.0,
      benefitDeductions: 200.0,
      otherDeductions: 75.0,
      netPay: 1825.0,
      status: PayrollStatus.processed,
      processedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Getters
  List<PayrollRecord> get payrollRecords => List.unmodifiable(_payrollRecords);

  List<PayrollRecord> get pendingPayroll =>
      _payrollRecords.where((r) => r.status == PayrollStatus.pending).toList();

  double get totalPayrollCost =>
      _payrollRecords.map((r) => r.grossPay).fold(0.0, (a, b) => a + b);

  // Methods
  void addPayrollRecord(PayrollRecord record) {
    final newId = _payrollRecords.isEmpty
        ? 1
        : _payrollRecords.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
    final newRecord = record.copyWith(id: newId);
    _payrollRecords.add(newRecord);
    notifyListeners();
  }

  void updatePayrollRecord(PayrollRecord updatedRecord) {
    final index = _payrollRecords.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      _payrollRecords[index] = updatedRecord;
      notifyListeners();
    }
  }

  void processPayroll(int recordId) {
    final record = _payrollRecords.firstWhere((r) => r.id == recordId);
    updatePayrollRecord(record.copyWith(
      status: PayrollStatus.processed,
      processedDate: DateTime.now(),
    ));
  }

  PayrollRecord generatePayrollForEmployee(int employeeId, String employeeName,
      double hoursWorked, double hourlyRate) {
    final now = DateTime.now();
    final payPeriodStart = DateTime(now.year, now.month, 1);
    final payPeriodEnd = DateTime(now.year, now.month + 1, 0);

    final regularHours = hoursWorked > 80.0 ? 80.0 : hoursWorked;
    final overtimeHours = hoursWorked > 80.0 ? hoursWorked - 80.0 : 0.0;
    final grossPay = (regularHours * hourlyRate) + (overtimeHours * hourlyRate * 1.5);

    final taxDeductions = grossPay * 0.2; // 20% tax
    final benefitDeductions = grossPay * 0.075; // 7.5% benefits
    final otherDeductions = grossPay * 0.025; // 2.5% other
    final netPay = grossPay - taxDeductions - benefitDeductions - otherDeductions;

    return PayrollRecord(
      id: 0,
      employeeId: employeeId,
      employeeName: employeeName,
      payPeriodStart: payPeriodStart,
      payPeriodEnd: payPeriodEnd,
      hoursWorked: hoursWorked,
      hourlyRate: hourlyRate,
      regularHours: regularHours,
      overtimeHours: overtimeHours,
      grossPay: grossPay,
      taxDeductions: taxDeductions,
      benefitDeductions: benefitDeductions,
      otherDeductions: otherDeductions,
      netPay: netPay,
    );
  }
}