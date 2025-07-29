import 'package:flutter/foundation.dart';

// Employee Model (same as your existing one but with constructor improvements)
class Employee {
  final int id;
  final String name;
  final String role;
  final String email;
  final String status;
  final double hoursThisWeek;
  final double hourlyRate;
  final int vacationDaysTotal;
  final int vacationDaysUsed;
  final int sickDaysTotal;
  final int sickDaysUsed;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.status,
    required this.hoursThisWeek,
    required this.hourlyRate,
    required this.vacationDaysTotal,
    required this.vacationDaysUsed,
    required this.sickDaysTotal,
    required this.sickDaysUsed,
  });

  int get remainingVacationDays => vacationDaysTotal - vacationDaysUsed;
  int get remainingSickDays => sickDaysTotal - sickDaysUsed;
  double get weeklyPay => hoursThisWeek * hourlyRate;

  // Create a copy with updated fields
  Employee copyWith({
    int? id,
    String? name,
    String? role,
    String? email,
    String? status,
    double? hoursThisWeek,
    double? hourlyRate,
    int? vacationDaysTotal,
    int? vacationDaysUsed,
    int? sickDaysTotal,
    int? sickDaysUsed,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      status: status ?? this.status,
      hoursThisWeek: hoursThisWeek ?? this.hoursThisWeek,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      vacationDaysTotal: vacationDaysTotal ?? this.vacationDaysTotal,
      vacationDaysUsed: vacationDaysUsed ?? this.vacationDaysUsed,
      sickDaysTotal: sickDaysTotal ?? this.sickDaysTotal,
      sickDaysUsed: sickDaysUsed ?? this.sickDaysUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'status': status,
      'hoursThisWeek': hoursThisWeek,
      'hourlyRate': hourlyRate,
      'vacationDaysTotal': vacationDaysTotal,
      'vacationDaysUsed': vacationDaysUsed,
      'sickDaysTotal': sickDaysTotal,
      'sickDaysUsed': sickDaysUsed,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      status: json['status'],
      hoursThisWeek: json['hoursThisWeek'].toDouble(),
      hourlyRate: json['hourlyRate'].toDouble(),
      vacationDaysTotal: json['vacationDaysTotal'],
      vacationDaysUsed: json['vacationDaysUsed'],
      sickDaysTotal: json['sickDaysTotal'],
      sickDaysUsed: json['sickDaysUsed'],
    );
  }
}

// Employee Service for managing employee data
class EmployeeService extends ChangeNotifier {
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  EmployeeService._internal();

  List<Employee> _employees = [
    Employee(
      id: 1,
      name: 'Sarah Johnson',
      role: 'Marketing Manager',
      email: 'sarah@company.com',
      status: 'active',
      hoursThisWeek: 40,
      hourlyRate: 25.0,
      vacationDaysTotal: 25,
      vacationDaysUsed: 12,
      sickDaysTotal: 10,
      sickDaysUsed: 3,
    ),
    Employee(
      id: 2,
      name: 'Mike Chen',
      role: 'Developer',
      email: 'mike@company.com',
      status: 'active',
      hoursThisWeek: 38,
      hourlyRate: 30.0,
      vacationDaysTotal: 25,
      vacationDaysUsed: 8,
      sickDaysTotal: 10,
      sickDaysUsed: 1,
    ),
    Employee(
      id: 3,
      name: 'Emma Davis',
      role: 'Sales Rep',
      email: 'emma@company.com',
      status: 'on-leave',
      hoursThisWeek: 0,
      hourlyRate: 22.0,
      vacationDaysTotal: 20,
      vacationDaysUsed: 15,
      sickDaysTotal: 10,
      sickDaysUsed: 5,
    ),
    Employee(
      id: 4,
      name: 'John Smith',
      role: 'Designer',
      email: 'john@company.com',
      status: 'active',
      hoursThisWeek: 42,
      hourlyRate: 28.0,
      vacationDaysTotal: 25,
      vacationDaysUsed: 10,
      sickDaysTotal: 10,
      sickDaysUsed: 2,
    ),
  ];

  // Getters
  List<Employee> get employees => List.unmodifiable(_employees);

  List<Employee> get activeEmployees =>
      _employees.where((e) => e.status == 'active').toList();

  int get activeEmployeeCount => activeEmployees.length;

  double get totalMonthlyPayroll =>
      _employees.map((e) => e.weeklyPay * 4).fold(0.0, (a, b) => a + b);

  // Methods
  void addEmployee(Employee employee) {
    // Generate new ID
    final newId = _employees.isEmpty ? 1 : _employees.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    final newEmployee = employee.copyWith(id: newId);
    _employees.add(newEmployee);
    notifyListeners();
  }

  void updateEmployee(Employee updatedEmployee) {
    final index = _employees.indexWhere((e) => e.id == updatedEmployee.id);
    if (index != -1) {
      _employees[index] = updatedEmployee;
      notifyListeners();
    }
  }

  void removeEmployee(int employeeId) {
    _employees.removeWhere((e) => e.id == employeeId);
    notifyListeners();
  }

  Employee? getEmployeeById(int id) {
    try {
      return _employees.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Employee> searchEmployees(String query) {
    if (query.isEmpty) return employees;

    final lowercaseQuery = query.toLowerCase();
    return _employees.where((employee) {
      return employee.name.toLowerCase().contains(lowercaseQuery) ||
          employee.role.toLowerCase().contains(lowercaseQuery) ||
          employee.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}