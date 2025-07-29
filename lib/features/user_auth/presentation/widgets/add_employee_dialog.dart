import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// App Colors (consistent with dashboard)
class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color background = Color(0xFFF9FAFB);
}

class AddEmployeeDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onEmployeeAdded;

  const AddEmployeeDialog({
    super.key,
    required this.onEmployeeAdded,
  });

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _vacationDaysController = TextEditingController(text: '25');
  final _sickDaysController = TextEditingController(text: '10');

  String _selectedStatus = 'active';
  bool _isLoading = false;

  final List<String> _statusOptions = ['active', 'inactive', 'on-leave'];
  final List<String> _roleOptions = [
    'Manager',
    'Developer',
    'Designer',
    'Sales Rep',
    'Marketing Manager',
    'HR Specialist',
    'Accountant',
    'Customer Service',
    'Operations',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _hourlyRateController.dispose();
    _vacationDaysController.dispose();
    _sickDaysController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(value) < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    final employeeData = {
      'name': _nameController.text.trim(),
      'role': _roleController.text.trim(),
      'email': _emailController.text.trim().toLowerCase(),
      'status': _selectedStatus,
      'hoursThisWeek': 0.0, // New employee starts with 0 hours
      'hourlyRate': double.parse(_hourlyRateController.text),
      'vacationDaysTotal': int.parse(_vacationDaysController.text),
      'vacationDaysUsed': 0, // New employee starts with 0 used days
      'sickDaysTotal': int.parse(_sickDaysController.text),
      'sickDaysUsed': 0, // New employee starts with 0 used days
    };

    widget.onEmployeeAdded(employeeData);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employee ${_nameController.text} added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
                        Icons.person_add,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add New Employee',
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

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter employee full name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => _validateRequired(value, 'Full name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Role
                  DropdownButtonFormField<String>(
                    value: _roleController.text.isEmpty ? null : _roleController.text,
                    decoration: const InputDecoration(
                      labelText: 'Role *',
                      prefixIcon: Icon(Icons.work),
                      border: OutlineInputBorder(),
                    ),
                    items: _roleOptions.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _roleController.text = value ?? '';
                    },
                    validator: (value) => _validateRequired(value, 'Role'),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address *',
                      hintText: 'employee@company.com',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Status and Hourly Rate Row
                  Row(
                    children: [
                      // Status
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status *',
                            prefixIcon: Icon(Icons.account_circle),
                            border: OutlineInputBorder(),
                          ),
                          items: _statusOptions.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Hourly Rate
                      Expanded(
                        child: TextFormField(
                          controller: _hourlyRateController,
                          decoration: const InputDecoration(
                            labelText: 'Hourly Rate *',
                            hintText: '25.00',
                            prefixIcon: Icon(Icons.attach_money),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          validator: (value) => _validateNumber(value, 'Hourly rate'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Leave Days Row
                  Row(
                    children: [
                      // Vacation Days
                      Expanded(
                        child: TextFormField(
                          controller: _vacationDaysController,
                          decoration: const InputDecoration(
                            labelText: 'Vacation Days *',
                            hintText: '25',
                            prefixIcon: Icon(Icons.beach_access),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) => _validateNumber(value, 'Vacation days'),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Sick Days
                      Expanded(
                        child: TextFormField(
                          controller: _sickDaysController,
                          decoration: const InputDecoration(
                            labelText: 'Sick Days *',
                            hintText: '10',
                            prefixIcon: Icon(Icons.local_hospital),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) => _validateNumber(value, 'Sick days'),
                        ),
                      ),
                    ],
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
                              : const Text('Add Employee'),
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
}