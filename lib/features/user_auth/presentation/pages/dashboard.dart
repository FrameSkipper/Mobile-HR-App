import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../employee_management/employee_service.dart';
import '../../../leave_management/leave_request_service.dart';
import '../widgets/add_employee_dialog.dart';
import '../../../payroll/payroll_service.dart';
import '../../../payroll/payroll_screen.dart';
import '../../../compliance/compliance_service.dart';
import '../../../compliance/compliance_screen.dart';

// App Colors
class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color background = Color(0xFFF9FAFB);
}

// App Sizes
class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 8.0;
}

// Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late EmployeeService _employeeService;
  late LeaveRequestService _leaveRequestService;
  late PayrollService _payrollService;
  late ComplianceService _complianceService;

  @override
  void initState() {
    super.initState();
    _employeeService = EmployeeService();
    _leaveRequestService = LeaveRequestService();
    _payrollService = PayrollService();
    _complianceService = ComplianceService();

    // Listeners
    _employeeService.addListener(_onDataChanged);
    _leaveRequestService.addListener(_onDataChanged);
    _payrollService.addListener(_onDataChanged);
    _complianceService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _employeeService.removeListener(_onDataChanged);
    _leaveRequestService.removeListener(_onDataChanged);
    _payrollService.removeListener(_onDataChanged);
    _complianceService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Employees';
      case 2:
        return 'Payroll';
      case 3:
        return 'Leave Requests';
      case 4:
        return 'Compliance';
      case 5:
        return 'Profile';
      default:
        return 'HR Manager';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  setState(() => _selectedIndex = 3);
                },
              ),
              if (_leaveRequestService.pendingRequestCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_leaveRequestService.pendingRequestCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: SidebarMenu(
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        selectedIndex: _selectedIndex,
      ),
      body: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return EmployeesScreen(employeeService: _employeeService);
      case 2:
      return PayrollScreen(employeeService: _employeeService);
      case 3:
        return LeaveRequestManagementScreen(
          employeeService: _employeeService,
          leaveRequestService: _leaveRequestService,
        );
      case 4:
        return const ComplianceScreen();
      case 5:
        return const ProfileScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final activeEmployees = _employeeService.activeEmployeeCount;
    final totalPayroll = _employeeService.totalMonthlyPayroll;
    final pendingRequests = _leaveRequestService.pendingRequestCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Active Employees',
                  value: activeEmployees.toString(),
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: StatsCard(
                  title: 'Monthly Payroll',
                  value: '\$${totalPayroll.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingSmall),

          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Pending Requests',
                  value: pendingRequests.toString(),
                  icon: Icons.pending_actions,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: StatsCard(
                  title: 'This Month',
                  value: '${DateTime.now().month}/${DateTime.now().year}',
                  icon: Icons.calendar_today,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Add Employee',
                  Icons.person_add,
                  AppColors.primary,
                      () => _showAddEmployeeDialog(),
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: _buildQuickActionCard(
                  'View Employees',
                  Icons.people,
                  AppColors.success,
                      () => setState(() => _selectedIndex = 1),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingSmall),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Leave Requests',
                  Icons.calendar_today,
                  pendingRequests > 0 ? AppColors.warning : AppColors.textSecondary,
                      () => setState(() => _selectedIndex = 3),
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: _buildQuickActionCard(
                  'Add Leave Request',
                  Icons.add_circle,
                  AppColors.primary,
                      () => _showAddLeaveRequestDialog(),
                ),
              ),
            ],
          ),

          // Recent Leave Requests
          if (_leaveRequestService.leaveRequests.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingLarge),
            const Text(
              'Recent Leave Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            ..._leaveRequestService.leaveRequests
                .take(3)
                .map((request) => _buildLeaveRequestCard(request)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 20,
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getLeaveTypeColor(request.type).withOpacity(0.1),
          child: Icon(
            _getLeaveTypeIcon(request.type),
            color: _getLeaveTypeColor(request.type),
            size: 20,
          ),
        ),
        title: Text(request.employeeName),
        subtitle: Text(
          '${request.type.displayName} • ${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(request.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            request.status.displayName.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(request.status),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => setState(() => _selectedIndex = 3),
      ),
    );
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEmployeeDialog(
        onEmployeeAdded: (employeeData) {
          final employee = Employee(
            id: 0,
            name: employeeData['name'],
            role: employeeData['role'],
            email: employeeData['email'],
            status: employeeData['status'],
            hoursThisWeek: employeeData['hoursThisWeek'],
            hourlyRate: employeeData['hourlyRate'],
            vacationDaysTotal: employeeData['vacationDaysTotal'],
            vacationDaysUsed: employeeData['vacationDaysUsed'],
            sickDaysTotal: employeeData['sickDaysTotal'],
            sickDaysUsed: employeeData['sickDaysUsed'],
          );
          _employeeService.addEmployee(employee);
        },
      ),
    );
  }

  void _showAddLeaveRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AddLeaveRequestDialog(
        employees: _employeeService.employees,
        onLeaveRequestAdded: (leaveRequestData) {
          final leaveRequest = LeaveRequest(
            employeeId: leaveRequestData['employeeId'],
            employeeName: leaveRequestData['employeeName'],
            type: leaveRequestData['type'],
            startDate: leaveRequestData['startDate'],
            endDate: leaveRequestData['endDate'],
            reason: leaveRequestData['reason'],
          );
          _leaveRequestService.addLeaveRequest(leaveRequest);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getLeaveTypeColor(LeaveType type) {
    switch (type) {
      case LeaveType.vacation:
        return AppColors.primary;
      case LeaveType.sick:
        return AppColors.error;
      case LeaveType.personal:
        return AppColors.warning;
      case LeaveType.maternity:
      case LeaveType.paternity:
        return AppColors.success;
    }
  }

  IconData _getLeaveTypeIcon(LeaveType type) {
    switch (type) {
      case LeaveType.vacation:
        return Icons.beach_access;
      case LeaveType.sick:
        return Icons.local_hospital;
      case LeaveType.personal:
        return Icons.person;
      case LeaveType.maternity:
      case LeaveType.paternity:
        return Icons.child_care;
    }
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return AppColors.warning;
      case LeaveStatus.approved:
        return AppColors.success;
      case LeaveStatus.rejected:
        return AppColors.error;
      case LeaveStatus.cancelled:
        return AppColors.textSecondary;
    }
  }
}

// COMPLETE Leave Request Management Screen
class LeaveRequestManagementScreen extends StatefulWidget {
  final EmployeeService employeeService;
  final LeaveRequestService leaveRequestService;

  const LeaveRequestManagementScreen({
    super.key,
    required this.employeeService,
    required this.leaveRequestService,
  });

  @override
  State<LeaveRequestManagementScreen> createState() => _LeaveRequestManagementScreenState();
}

class _LeaveRequestManagementScreenState extends State<LeaveRequestManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<LeaveRequest> _filteredRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _filteredRequests = widget.leaveRequestService.leaveRequests;
    _searchController.addListener(_filterRequests);
    widget.leaveRequestService.addListener(_onDataChanged);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    widget.leaveRequestService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    _filterRequests();
  }

  void _onTabChanged() {
    _filterRequests();
  }

  void _filterRequests() {
    List<LeaveRequest> baseRequests;

    switch (_tabController.index) {
      case 0: // All
        baseRequests = widget.leaveRequestService.leaveRequests;
        break;
      case 1: // Pending
        baseRequests = widget.leaveRequestService.pendingRequests;
        break;
      case 2: // Approved
        baseRequests = widget.leaveRequestService.approvedRequests;
        break;
      case 3: // Rejected
        baseRequests = widget.leaveRequestService.rejectedRequests;
        break;
      default:
        baseRequests = widget.leaveRequestService.leaveRequests;
    }

    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRequests = baseRequests;
      } else {
        _filteredRequests = baseRequests.where((request) {
          return request.employeeName.toLowerCase().contains(query) ||
              request.type.displayName.toLowerCase().contains(query) ||
              request.reason.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Add Button
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search leave requests...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddLeaveRequestDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Leave Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tab Bar
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'All (${widget.leaveRequestService.leaveRequests.length})'),
            Tab(text: 'Pending (${widget.leaveRequestService.pendingRequestCount})'),
            Tab(text: 'Approved (${widget.leaveRequestService.approvedRequests.length})'),
            Tab(text: 'Rejected (${widget.leaveRequestService.rejectedRequests.length})'),
          ],
        ),

        // Request List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRequestList(),
              _buildRequestList(),
              _buildRequestList(),
              _buildRequestList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestList() {
    if (_filteredRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: AppColors.textSecondary),
            SizedBox(height: 20),
            Text(
              'No leave requests found',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        return _buildLeaveRequestCard(request);
      },
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getLeaveTypeColor(request.type).withOpacity(0.1),
                  radius: 20,
                  child: Icon(
                    _getLeaveTypeIcon(request.type),
                    color: _getLeaveTypeColor(request.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        request.type.displayName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status.displayName.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingMedium),

            // Date Range
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  '${request.dayCount} day${request.dayCount != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            // Reason
            if (request.reason.isNotEmpty) ...[
              const SizedBox(height: AppSizes.paddingSmall),
              Text(
                'Reason: ${request.reason}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],

            // Action Buttons for Pending Requests
            if (request.status == LeaveStatus.pending) ...[
              const SizedBox(height: AppSizes.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRequest(request),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(request),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddLeaveRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AddLeaveRequestDialog(
        employees: widget.employeeService.employees,
        onLeaveRequestAdded: (leaveRequestData) {
          final leaveRequest = LeaveRequest(
            employeeId: leaveRequestData['employeeId'],
            employeeName: leaveRequestData['employeeName'],
            type: leaveRequestData['type'],
            startDate: leaveRequestData['startDate'],
            endDate: leaveRequestData['endDate'],
            reason: leaveRequestData['reason'],
          );
          widget.leaveRequestService.addLeaveRequest(leaveRequest);
        },
      ),
    );
  }

  void _approveRequest(LeaveRequest request) {
    widget.leaveRequestService.approveLeaveRequest(request.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave request for ${request.employeeName} approved'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _rejectRequest(LeaveRequest request) {
    widget.leaveRequestService.rejectLeaveRequest(request.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave request for ${request.employeeName} rejected'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getLeaveTypeColor(LeaveType type) {
    switch (type) {
      case LeaveType.vacation:
        return AppColors.primary;
      case LeaveType.sick:
        return AppColors.error;
      case LeaveType.personal:
        return AppColors.warning;
      case LeaveType.maternity:
      case LeaveType.paternity:
        return AppColors.success;
    }
  }

  IconData _getLeaveTypeIcon(LeaveType type) {
    switch (type) {
      case LeaveType.vacation:
        return Icons.beach_access;
      case LeaveType.sick:
        return Icons.local_hospital;
      case LeaveType.personal:
        return Icons.person;
      case LeaveType.maternity:
      case LeaveType.paternity:
        return Icons.child_care;
    }
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return AppColors.warning;
      case LeaveStatus.approved:
        return AppColors.success;
      case LeaveStatus.rejected:
        return AppColors.error;
      case LeaveStatus.cancelled:
        return AppColors.textSecondary;
    }
  }
}

class AddLeaveRequestDialog extends StatefulWidget {
  final List<Employee> employees;
  final Function(Map<String, dynamic>) onLeaveRequestAdded;

  const AddLeaveRequestDialog({
    super.key,
    required this.employees,
    required this.onLeaveRequestAdded,
  });

  @override
  State<AddLeaveRequestDialog> createState() => _AddLeaveRequestDialogState();
}

class _AddLeaveRequestDialogState extends State<AddLeaveRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  Employee? _selectedEmployee;
  LeaveType _selectedLeaveType = LeaveType.vacation;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedEmployee == null ||
        _startDate == null ||
        _endDate == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final leaveRequestData = {
      'employeeId': _selectedEmployee!.id,
      'employeeName': _selectedEmployee!.name,
      'type': _selectedLeaveType,
      'startDate': _startDate!,
      'endDate': _endDate!,
      'reason': _reasonController.text.trim(),
    };

    widget.onLeaveRequestAdded(leaveRequestData);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request for ${_selectedEmployee!.name} submitted'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  int get _dayCount {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add Leave Request',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Employee Selection
                  DropdownButtonFormField<Employee>(
                    value: _selectedEmployee,
                    decoration: const InputDecoration(
                      labelText: 'Employee *',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: widget.employees.map((employee) {
                      return DropdownMenuItem(
                        value: employee,
                        child: Text('${employee.name} - ${employee.role}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployee = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select an employee' : null,
                  ),
                  const SizedBox(height: 16),

                  // Leave Type
                  DropdownButtonFormField<LeaveType>(
                    value: _selectedLeaveType,
                    decoration: const InputDecoration(
                      labelText: 'Leave Type *',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: LeaveType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getLeaveTypeIcon(type), size: 20),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLeaveType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Selection Row
                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date *',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _startDate != null
                                  ? _formatDate(_startDate!)
                                  : 'Select date',
                              style: TextStyle(
                                color: _startDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // End Date
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date *',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _endDate != null
                                  ? _formatDate(_endDate!)
                                  : 'Select date',
                              style: TextStyle(
                                color: _endDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Day Count Display
                  if (_startDate != null && _endDate != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Total days: $_dayCount',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Reason
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      hintText: 'Enter reason for leave request...',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text('Submit Request'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getLeaveTypeIcon(LeaveType type) {
    switch (type) {
      case LeaveType.vacation:
        return Icons.beach_access;
      case LeaveType.sick:
        return Icons.local_hospital;
      case LeaveType.personal:
        return Icons.person;
      case LeaveType.maternity:
      case LeaveType.paternity:
        return Icons.child_care;
    }
  }
}

class EmployeesScreen extends StatefulWidget {
  final EmployeeService employeeService;

  const EmployeesScreen({super.key, required this.employeeService});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<Employee> _filteredEmployees = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredEmployees = widget.employeeService.employees;
    _searchController.addListener(_filterEmployees);
    widget.employeeService.addListener(_onEmployeeDataChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.employeeService.removeListener(_onEmployeeDataChanged);
    super.dispose();
  }

  void _onEmployeeDataChanged() {
    _filterEmployees();
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = widget.employeeService.employees;
      } else {
        _filteredEmployees = widget.employeeService.searchEmployees(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search employees...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddEmployeeDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add New Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = _filteredEmployees[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: employee.status == 'active'
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      child: Text(
                        employee.name.split(' ').map((n) => n[0]).join(),
                        style: TextStyle(
                          color: employee.status == 'active'
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(employee.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee.role),
                        Text(
                          employee.email,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: employee.status == 'active'
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            employee.status.toUpperCase(),
                            style: TextStyle(
                              color: employee.status == 'active'
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\${employee.weeklyPay.toStringAsFixed(0)}/wk',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showEmployeeDetails(employee),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEmployeeDialog(
        onEmployeeAdded: (employeeData) {
          final employee = Employee(
            id: 0,
            name: employeeData['name'],
            role: employeeData['role'],
            email: employeeData['email'],
            status: employeeData['status'],
            hoursThisWeek: employeeData['hoursThisWeek'],
            hourlyRate: employeeData['hourlyRate'],
            vacationDaysTotal: employeeData['vacationDaysTotal'],
            vacationDaysUsed: employeeData['vacationDaysUsed'],
            sickDaysTotal: employeeData['sickDaysTotal'],
            sickDaysUsed: employeeData['sickDaysUsed'],
          );
          widget.employeeService.addEmployee(employee);
        },
      ),
    );
  }

  void _showEmployeeDetails(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${employee.role}'),
            Text('Email: ${employee.email}'),
            Text('Status: ${employee.status}'),
            Text('Hours this week: ${employee.hoursThisWeek}'),
            Text('Hourly rate: \${employee.hourlyRate}'),
            Text('Weekly pay: \${employee.weeklyPay.toStringAsFixed(2)}'),
            Text('Vacation days: ${employee.remainingVacationDays}/${employee.vacationDaysTotal}'),
            Text('Sick days: ${employee.remainingSickDays}/${employee.sickDaysTotal}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(employee);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.employeeService.removeEmployee(employee.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${employee.name} deleted successfully'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.primary),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profile coming soon!')),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarMenu extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const SidebarMenu({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(0, Icons.dashboard, 'Dashboard'),
                _buildMenuItem(1, Icons.people, 'Employees'),
                _buildMenuItem(2, Icons.payment, 'Payroll'),
                _buildMenuItem(3, Icons.calendar_today, 'Leave Requests'),
                _buildMenuItem(4, Icons.verified_user, 'Compliance'),
                _buildMenuItem(5, Icons.person, 'Profile'),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    return ListTile(
      leading: Icon(
        icon,
        color: selectedIndex == index ? AppColors.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selectedIndex == index ? AppColors.primary : Colors.black,
          fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selectedIndex == index,
      onTap: () => onItemSelected(index),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}