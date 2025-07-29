import 'package:flutter/foundation.dart';

// Leave Request Model
class LeaveRequest {
  final int? id;
  final int employeeId;
  final String employeeName;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final DateTime createdAt;

  LeaveRequest({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = LeaveStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get dayCount {
    return endDate.difference(startDate).inDays + 1;
  }

  LeaveRequest copyWith({
    int? id,
    int? employeeId,
    String? employeeName,
    LeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveStatus? status,
    DateTime? createdAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'type': type.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      type: LeaveType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'],
      status: LeaveStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum LeaveType { vacation, sick, personal, maternity, paternity }

enum LeaveStatus { pending, approved, rejected, cancelled }

// Extensions for better UI display
extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.vacation:
        return 'Vacation';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.personal:
        return 'Personal';
      case LeaveType.maternity:
        return 'Maternity';
      case LeaveType.paternity:
        return 'Paternity';
    }
  }
}

extension LeaveStatusExtension on LeaveStatus {
  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }
}

// Leave Request Service for managing leave request data
class LeaveRequestService extends ChangeNotifier {
  static final LeaveRequestService _instance = LeaveRequestService._internal();
  factory LeaveRequestService() => _instance;
  LeaveRequestService._internal();

  final List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      id: 1,
      employeeId: 1,
      employeeName: 'Sarah Johnson',
      type: LeaveType.vacation,
      startDate: DateTime.now().add(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 20)),
      reason: 'Family vacation to Europe',
      status: LeaveStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    LeaveRequest(
      id: 2,
      employeeId: 2,
      employeeName: 'Mike Chen',
      type: LeaveType.sick,
      startDate: DateTime.now().subtract(const Duration(days: 3)),
      endDate: DateTime.now().subtract(const Duration(days: 1)),
      reason: 'Flu symptoms',
      status: LeaveStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    LeaveRequest(
      id: 3,
      employeeId: 3,
      employeeName: 'Emma Davis',
      type: LeaveType.personal,
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      reason: 'Medical appointment',
      status: LeaveStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  // Getters
  List<LeaveRequest> get leaveRequests => List.unmodifiable(_leaveRequests);

  List<LeaveRequest> get pendingRequests =>
      _leaveRequests.where((r) => r.status == LeaveStatus.pending).toList();

  List<LeaveRequest> get approvedRequests =>
      _leaveRequests.where((r) => r.status == LeaveStatus.approved).toList();

  List<LeaveRequest> get rejectedRequests =>
      _leaveRequests.where((r) => r.status == LeaveStatus.rejected).toList();

  int get pendingRequestCount => pendingRequests.length;

  // Methods
  void addLeaveRequest(LeaveRequest request) {
    // Generate new ID
    final newId = _leaveRequests.isEmpty
        ? 1
        : _leaveRequests.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    final newRequest = request.copyWith(id: newId);
    _leaveRequests.add(newRequest);
    notifyListeners();
  }

  void updateLeaveRequest(LeaveRequest updatedRequest) {
    final index = _leaveRequests.indexWhere((r) => r.id == updatedRequest.id);
    if (index != -1) {
      _leaveRequests[index] = updatedRequest;
      notifyListeners();
    }
  }

  void removeLeaveRequest(int requestId) {
    _leaveRequests.removeWhere((r) => r.id == requestId);
    notifyListeners();
  }

  LeaveRequest? getLeaveRequestById(int id) {
    try {
      return _leaveRequests.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  List<LeaveRequest> getLeaveRequestsByEmployee(int employeeId) {
    return _leaveRequests.where((r) => r.employeeId == employeeId).toList();
  }

  List<LeaveRequest> getLeaveRequestsByStatus(LeaveStatus status) {
    return _leaveRequests.where((r) => r.status == status).toList();
  }

  List<LeaveRequest> getLeaveRequestsByDateRange(DateTime start, DateTime end) {
    return _leaveRequests.where((r) {
      return (r.startDate.isBefore(end) || r.startDate.isAtSameMomentAs(end)) &&
          (r.endDate.isAfter(start) || r.endDate.isAtSameMomentAs(start));
    }).toList();
  }

  void approveLeaveRequest(int requestId) {
    final request = getLeaveRequestById(requestId);
    if (request != null) {
      updateLeaveRequest(request.copyWith(status: LeaveStatus.approved));
    }
  }

  void rejectLeaveRequest(int requestId) {
    final request = getLeaveRequestById(requestId);
    if (request != null) {
      updateLeaveRequest(request.copyWith(status: LeaveStatus.rejected));
    }
  }

  void cancelLeaveRequest(int requestId) {
    final request = getLeaveRequestById(requestId);
    if (request != null) {
      updateLeaveRequest(request.copyWith(status: LeaveStatus.cancelled));
    }
  }

  // Statistics
  Map<LeaveType, int> getLeaveTypeStatistics() {
    final stats = <LeaveType, int>{};
    for (final type in LeaveType.values) {
      stats[type] = _leaveRequests.where((r) => r.type == type).length;
    }
    return stats;
  }

  Map<LeaveStatus, int> getLeaveStatusStatistics() {
    final stats = <LeaveStatus, int>{};
    for (final status in LeaveStatus.values) {
      stats[status] = _leaveRequests.where((r) => r.status == status).length;
    }
    return stats;
  }

  int getTotalLeaveDaysForEmployee(int employeeId, LeaveType? type) {
    var requests = getLeaveRequestsByEmployee(employeeId)
        .where((r) => r.status == LeaveStatus.approved);

    if (type != null) {
      requests = requests.where((r) => r.type == type);
    }

    return requests.map((r) => r.dayCount).fold(0, (a, b) => a + b);
  }
}