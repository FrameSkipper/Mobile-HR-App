import 'package:flutter/material.dart';

class ComplianceItem {
  final int id;
  final String title;
  final String description;
  final ComplianceType type;
  final ComplianceStatus status;
  final DateTime dueDate;
  final DateTime? completedDate;
  final String? assignedTo;
  final CompliancePriority priority;
  final String? notes;

  ComplianceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.dueDate,
    this.completedDate,
    this.assignedTo,
    this.priority = CompliancePriority.medium,
    this.notes,
  });

  bool get isOverdue => status != ComplianceStatus.completed && DateTime.now().isAfter(dueDate);
  bool get isDueSoon => !isOverdue && DateTime.now().add(const Duration(days: 7)).isAfter(dueDate);

  ComplianceItem copyWith({
    int? id,
    String? title,
    String? description,
    ComplianceType? type,
    ComplianceStatus? status,
    DateTime? dueDate,
    DateTime? completedDate,
    String? assignedTo,
    CompliancePriority? priority,
    String? notes,
  }) {
    return ComplianceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
    );
  }
}

enum ComplianceType {
  safety,
  training,
  documentation,
  audit,
  legal,
  certification,
}

enum ComplianceStatus {
  pending,
  inProgress,
  completed,
  overdue,
}

enum CompliancePriority {
  low,
  medium,
  high,
  critical,
}

// Extensions for better UI display
extension ComplianceTypeExtension on ComplianceType {
  String get displayName {
    switch (this) {
      case ComplianceType.safety:
        return 'Safety';
      case ComplianceType.training:
        return 'Training';
      case ComplianceType.documentation:
        return 'Documentation';
      case ComplianceType.audit:
        return 'Audit';
      case ComplianceType.legal:
        return 'Legal';
      case ComplianceType.certification:
        return 'Certification';
    }
  }

  IconData get icon {
    switch (this) {
      case ComplianceType.safety:
        return Icons.shield;
      case ComplianceType.training:
        return Icons.school;
      case ComplianceType.documentation:
        return Icons.description;
      case ComplianceType.audit:
        return Icons.fact_check;
      case ComplianceType.legal:
        return Icons.gavel;
      case ComplianceType.certification:
        return Icons.verified;
    }
  }
}

extension ComplianceStatusExtension on ComplianceStatus {
  String get displayName {
    switch (this) {
      case ComplianceStatus.pending:
        return 'Pending';
      case ComplianceStatus.inProgress:
        return 'In Progress';
      case ComplianceStatus.completed:
        return 'Completed';
      case ComplianceStatus.overdue:
        return 'Overdue';
    }
  }
}

extension CompliancePriorityExtension on CompliancePriority {
  String get displayName {
    switch (this) {
      case CompliancePriority.low:
        return 'Low';
      case CompliancePriority.medium:
        return 'Medium';
      case CompliancePriority.high:
        return 'High';
      case CompliancePriority.critical:
        return 'Critical';
    }
  }
}

// Compliance Service
class ComplianceService extends ChangeNotifier {
  static final ComplianceService _instance = ComplianceService._internal();
  factory ComplianceService() => _instance;
  ComplianceService._internal();

  final List<ComplianceItem> _complianceItems = [
    ComplianceItem(
      id: 1,
      title: 'Fire Safety Training',
      description: 'Annual fire safety training for all employees',
      type: ComplianceType.safety,
      status: ComplianceStatus.pending,
      dueDate: DateTime.now().add(const Duration(days: 15)),
      assignedTo: 'HR Department',
      priority: CompliancePriority.high,
    ),
    ComplianceItem(
      id: 2,
      title: 'GDPR Compliance Review',
      description: 'Review and update data protection policies',
      type: ComplianceType.legal,
      status: ComplianceStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(days: 30)),
      assignedTo: 'Legal Team',
      priority: CompliancePriority.critical,
    ),
    ComplianceItem(
      id: 3,
      title: 'Employee Handbook Update',
      description: 'Update employee handbook with new policies',
      type: ComplianceType.documentation,
      status: ComplianceStatus.completed,
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      completedDate: DateTime.now().subtract(const Duration(days: 3)),
      assignedTo: 'HR Department',
      priority: CompliancePriority.medium,
    ),
    ComplianceItem(
      id: 4,
      title: 'Workplace Safety Audit',
      description: 'Quarterly workplace safety inspection',
      type: ComplianceType.audit,
      status: ComplianceStatus.overdue,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      assignedTo: 'Safety Officer',
      priority: CompliancePriority.high,
    ),
    ComplianceItem(
      id: 5,
      title: 'ISO 9001 Certification Renewal',
      description: 'Renew ISO 9001 quality management certification',
      type: ComplianceType.certification,
      status: ComplianceStatus.pending,
      dueDate: DateTime.now().add(const Duration(days: 60)),
      assignedTo: 'Quality Manager',
      priority: CompliancePriority.medium,
    ),
  ];

  // Getters
  List<ComplianceItem> get complianceItems => List.unmodifiable(_complianceItems);

  List<ComplianceItem> get pendingItems =>
      _complianceItems.where((item) => item.status == ComplianceStatus.pending).toList();

  List<ComplianceItem> get overdueItems =>
      _complianceItems.where((item) => item.isOverdue && item.status != ComplianceStatus.completed).toList();

  List<ComplianceItem> get dueSoonItems =>
      _complianceItems.where((item) => item.isDueSoon && item.status != ComplianceStatus.completed).toList();

  int get overdueCount => overdueItems.length;
  int get dueSoonCount => dueSoonItems.length;
  int get completedCount => _complianceItems.where((item) => item.status == ComplianceStatus.completed).length;

  double get complianceRate {
    if (_complianceItems.isEmpty) return 0.0;
    return completedCount / _complianceItems.length;
  }

  // Methods
  void addComplianceItem(ComplianceItem item) {
    final newId = _complianceItems.isEmpty
        ? 1
        : _complianceItems.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;
    final newItem = item.copyWith(id: newId);
    _complianceItems.add(newItem);
    notifyListeners();
  }

  void updateComplianceItem(ComplianceItem updatedItem) {
    final index = _complianceItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _complianceItems[index] = updatedItem;
      notifyListeners();
    }
  }

  void removeComplianceItem(int itemId) {
    _complianceItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void markAsCompleted(int itemId, String? notes) {
    final item = _complianceItems.firstWhere((item) => item.id == itemId);
    updateComplianceItem(item.copyWith(
      status: ComplianceStatus.completed,
      completedDate: DateTime.now(),
      notes: notes,
    ));
  }

  void updateStatus(int itemId, ComplianceStatus status) {
    final item = _complianceItems.firstWhere((item) => item.id == itemId);
    updateComplianceItem(item.copyWith(status: status));
  }

  List<ComplianceItem> getItemsByType(ComplianceType type) {
    return _complianceItems.where((item) => item.type == type).toList();
  }

  List<ComplianceItem> getItemsByStatus(ComplianceStatus status) {
    return _complianceItems.where((item) => item.status == status).toList();
  }

  List<ComplianceItem> searchItems(String query) {
    if (query.isEmpty) return complianceItems;

    final lowercaseQuery = query.toLowerCase();
    return _complianceItems.where((item) {
      return item.title.toLowerCase().contains(lowercaseQuery) ||
          item.description.toLowerCase().contains(lowercaseQuery) ||
          (item.assignedTo?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }
}