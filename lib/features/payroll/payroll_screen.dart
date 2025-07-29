import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrmobileapp/features/payroll/payroll_service.dart';
import '../employee_management/employee_service.dart';
import '../user_auth/presentation/pages/dashboard.dart';

class PayrollScreen extends StatefulWidget {
  final EmployeeService? employeeService;

  const PayrollScreen({super.key, this.employeeService});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PayrollService _payrollService;
  List<PayrollRecord> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _payrollService = PayrollService();
    _filteredRecords = _payrollService.payrollRecords;
    _searchController.addListener(_filterRecords);
    _payrollService.addListener(_onPayrollDataChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _payrollService.removeListener(_onPayrollDataChanged);
    super.dispose();
  }

  void _onPayrollDataChanged() {
    _filterRecords();
  }

  void _filterRecords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _payrollService.payrollRecords;
      } else {
        _filteredRecords = _payrollService.payrollRecords
            .where((record) => record.employeeName.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with search and actions
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          color: AppColors.background,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search payroll records...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  ElevatedButton.icon(
                    onPressed: _showGeneratePayrollDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Generate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMedium),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Records',
                      _payrollService.payrollRecords.length.toString(),
                      Icons.receipt_long,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child: _buildSummaryCard(
                      'Pending',
                      _payrollService.pendingPayroll.length.toString(),
                      Icons.pending_actions,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Cost',
                      '\$${_payrollService.totalPayrollCost.toStringAsFixed(0)}',
                      Icons.attach_money,
                      AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tab Bar
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'All Records'),
            Tab(text: 'Pending'),
            Tab(text: 'Reports'),
          ],
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllRecordsTab(),
              _buildPendingTab(),
              _buildReportsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllRecordsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _filteredRecords.length,
      itemBuilder: (context, index) {
        final record = _filteredRecords[index];
        return _buildPayrollCard(record);
      },
    );
  }

  Widget _buildPendingTab() {
    final pendingRecords = _payrollService.pendingPayroll;

    if (pendingRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: AppColors.success),
            SizedBox(height: 20),
            Text(
              'No Pending Payroll',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'All payroll records are up to date!',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: pendingRecords.length,
      itemBuilder: (context, index) {
        final record = pendingRecords[index];
        return _buildPayrollCard(record, showActions: true);
      },
    );
  }

  Widget _buildReportsTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payroll Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  _buildReportRow('Total Gross Pay', '\$${_calculateTotalGross()}'),
                  _buildReportRow('Total Tax Deductions', '\$${_calculateTotalTax()}'),
                  _buildReportRow('Total Benefit Deductions', '\$${_calculateTotalBenefits()}'),
                  _buildReportRow('Total Net Pay', '\$${_calculateTotalNet()}'),
                  const Divider(),
                  _buildReportRow('Average Hourly Rate', '\$${_calculateAverageRate()}'),
                  _buildReportRow('Total Hours Worked', '${_calculateTotalHours()}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _exportPayrollReport,
                      icon: const Icon(Icons.download),
                      label: const Text('Export Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollCard(PayrollRecord record, {bool showActions = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.employeeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(record.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(record.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),

            Text(
              'Pay Period: ${_formatDate(record.payPeriodStart)} - ${_formatDate(record.payPeriodEnd)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: AppSizes.paddingSmall),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hours: ${record.hoursWorked}'),
                      Text('Rate: \$${record.hourlyRate}/hr'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gross: \$${record.grossPay.toStringAsFixed(2)}'),
                      Text(
                        'Net: \$${record.netPay.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (showActions)
                  ElevatedButton(
                    onPressed: () => _processPayroll(record),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 36),
                    ),
                    child: const Text('Process'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PayrollStatus status) {
    switch (status) {
      case PayrollStatus.draft:
        return AppColors.textSecondary;
      case PayrollStatus.pending:
        return AppColors.warning;
      case PayrollStatus.processed:
        return AppColors.primary;
      case PayrollStatus.paid:
        return AppColors.success;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _processPayroll(PayrollRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payroll'),
        content: Text('Process payroll for ${record.employeeName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _payrollService.processPayroll(record.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payroll processed for ${record.employeeName}'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  void _showGeneratePayrollDialog() {
    if (widget.employeeService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee service not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => GeneratePayrollDialog(
        employeeService: widget.employeeService!,
        onPayrollGenerated: (record) {
          _payrollService.addPayrollRecord(record);
        },
      ),
    );
  }

  void _exportPayrollReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payroll report export feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _calculateTotalGross() {
    final total = _payrollService.payrollRecords
        .map((r) => r.grossPay)
        .fold(0.0, (a, b) => a + b);
    return total.toStringAsFixed(2);
  }

  String _calculateTotalTax() {
    final total = _payrollService.payrollRecords
        .map((r) => r.taxDeductions)
        .fold(0.0, (a, b) => a + b);
    return total.toStringAsFixed(2);
  }

  String _calculateTotalBenefits() {
    final total = _payrollService.payrollRecords
        .map((r) => r.benefitDeductions)
        .fold(0.0, (a, b) => a + b);
    return total.toStringAsFixed(2);
  }

  String _calculateTotalNet() {
    final total = _payrollService.payrollRecords
        .map((r) => r.netPay)
        .fold(0.0, (a, b) => a + b);
    return total.toStringAsFixed(2);
  }

  String _calculateAverageRate() {
    if (_payrollService.payrollRecords.isEmpty) return '0.00';
    final total = _payrollService.payrollRecords
        .map((r) => r.hourlyRate)
        .fold(0.0, (a, b) => a + b);
    return (total / _payrollService.payrollRecords.length).toStringAsFixed(2);
  }

  String _calculateTotalHours() {
    final total = _payrollService.payrollRecords
        .map((r) => r.hoursWorked)
        .fold(0.0, (a, b) => a + b);
    return total.toStringAsFixed(1);
  }
}

// Generate Payroll Dialog
class GeneratePayrollDialog extends StatefulWidget {
  final EmployeeService employeeService;
  final Function(PayrollRecord) onPayrollGenerated;

  const GeneratePayrollDialog({
    super.key,
    required this.employeeService,
    required this.onPayrollGenerated,
  });

  @override
  State<GeneratePayrollDialog> createState() => _GeneratePayrollDialogState();
}

class _GeneratePayrollDialogState extends State<GeneratePayrollDialog> {
  Employee? _selectedEmployee;
  final TextEditingController _hoursController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  void _generatePayroll() async {
    if (_selectedEmployee == null || _hoursController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an employee and enter hours'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final hours = double.tryParse(_hoursController.text) ?? 0;
    final payrollService = PayrollService();
    final record = payrollService.generatePayrollForEmployee(
      _selectedEmployee!.id,
      _selectedEmployee!.name,
      hours,
      _selectedEmployee!.hourlyRate,
    );

    widget.onPayrollGenerated(record);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payroll generated for ${_selectedEmployee!.name}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate Payroll'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Employee>(
            value: _selectedEmployee,
            decoration: const InputDecoration(
              labelText: 'Select Employee',
              border: OutlineInputBorder(),
            ),
            items: widget.employeeService.activeEmployees.map((employee) {
              return DropdownMenuItem(
                value: employee,
                child: Text(employee.name),
              );
            }).toList(),
            onChanged: (employee) {
              setState(() {
                _selectedEmployee = employee;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hoursController,
            decoration: const InputDecoration(
              labelText: 'Hours Worked',
              border: OutlineInputBorder(),
              suffixText: 'hours',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
          ),
          if (_selectedEmployee != null) ...[
            const SizedBox(height: 16),
            Text(
              'Hourly Rate: \$${_selectedEmployee!.hourlyRate}/hr',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _generatePayroll,
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
              : const Text('Generate'),
        ),
      ],
    );
  }
}