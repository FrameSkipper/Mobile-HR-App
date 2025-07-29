// compliance_screen.dart
import 'package:flutter/material.dart';
import 'compliance_service.dart';

class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});

  @override
  State<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends State<ComplianceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ComplianceService _complianceService;
  List<ComplianceItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _complianceService = ComplianceService();
    _filteredItems = _complianceService.complianceItems;
    _searchController.addListener(_filterItems);
    _complianceService.addListener(_onComplianceDataChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _complianceService.removeListener(_onComplianceDataChanged);
    super.dispose();
  }

  void _onComplianceDataChanged() {
    _filterItems();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _complianceService.complianceItems;
      } else {
        _filteredItems = _complianceService.searchItems(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with search and overview
        Container(
          padding: const EdgeInsets.all(16.0),
          color: const Color(0xFFF9FAFB),
          child: Column(
            children: [
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search compliance items...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton.icon(
                    onPressed: _showAddComplianceDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      'Compliance Rate',
                      '${(_complianceService.complianceRate * 100).toStringAsFixed(0)}%',
                      Icons.trending_up,
                      const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildOverviewCard(
                      'Overdue',
                      _complianceService.overdueCount.toString(),
                      Icons.warning,
                      const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildOverviewCard(
                      'Due Soon',
                      _complianceService.dueSoonCount.toString(),
                      Icons.schedule,
                      const Color(0xFFEAB308),
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
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF6B7280),
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Items'),
            Tab(text: 'Pending'),
            Tab(text: 'Overdue'),
            Tab(text: 'Completed'),
          ],
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllItemsTab(),
              _buildPendingTab(),
              _buildOverdueTab(),
              _buildCompletedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8.0),
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
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllItemsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildComplianceCard(item);
      },
    );
  }

  Widget _buildPendingTab() {
    final pendingItems = _complianceService.pendingItems;
    return _buildItemsList(pendingItems, 'No pending compliance items');
  }

  Widget _buildOverdueTab() {
    final overdueItems = _complianceService.overdueItems;
    return _buildItemsList(overdueItems, 'No overdue items');
  }

  Widget _buildCompletedTab() {
    final completedItems = _complianceService.getItemsByStatus(ComplianceStatus.completed);
    return _buildItemsList(completedItems, 'No completed items');
  }

  Widget _buildItemsList(List<ComplianceItem> items, String emptyMessage) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF10B981)),
            const SizedBox(height: 20),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildComplianceCard(item);
      },
    );
  }

  Widget _buildComplianceCard(ComplianceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.type.icon,
                  color: _getTypeColor(item.type),
                  size: 20,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(item),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            Text(
              item.description,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8.0),

            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: item.isOverdue ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_formatDate(item.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.isOverdue ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                    fontWeight: item.isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (item.assignedTo != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.person, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    item.assignedTo!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
                const Spacer(),
                if (item.status != ComplianceStatus.completed)
                  TextButton(
                    onPressed: () => _showCompleteDialog(item),
                    child: const Text('Start'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(ComplianceType type) {
    switch (type) {
      case ComplianceType.safety:
        return const Color(0xFFEF4444);
      case ComplianceType.training:
        return const Color(0xFF2563EB);
      case ComplianceType.documentation:
        return const Color(0xFF6B7280);
      case ComplianceType.audit:
        return const Color(0xFFEAB308);
      case ComplianceType.legal:
        return Colors.purple;
      case ComplianceType.certification:
        return const Color(0xFF10B981);
    }
  }

  Color _getStatusColor(ComplianceItem item) {
    if (item.isOverdue && item.status != ComplianceStatus.completed) {
      return const Color(0xFFEF4444);
    }

    switch (item.status) {
      case ComplianceStatus.pending:
        return const Color(0xFF6B7280);
      case ComplianceStatus.inProgress:
        return const Color(0xFF2563EB);
      case ComplianceStatus.completed:
        return const Color(0xFF10B981);
      case ComplianceStatus.overdue:
        return const Color(0xFFEF4444);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCompleteDialog(ComplianceItem item) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complete: ${item.title}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Completion Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _complianceService.markAsCompleted(item.id, notesController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.title} marked as complete'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showAddComplianceDialog() {
    showDialog(
      context: context,
      builder: (context) => AddComplianceDialog(
        onItemAdded: (item) {
          _complianceService.addComplianceItem(item);
        },
      ),
    );
  }
}

// Add Compliance Dialog
class AddComplianceDialog extends StatefulWidget {
  final Function(ComplianceItem) onItemAdded;

  const AddComplianceDialog({
    super.key,
    required this.onItemAdded,
  });

  @override
  State<AddComplianceDialog> createState() => _AddComplianceDialogState();
}

class _AddComplianceDialogState extends State<AddComplianceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();

  ComplianceType _selectedType = ComplianceType.documentation;
  CompliancePriority _selectedPriority = CompliancePriority.medium;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final item = ComplianceItem(
      id: 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      status: ComplianceStatus.pending,
      dueDate: _selectedDate,
      assignedTo: _assignedToController.text.trim().isEmpty ? null : _assignedToController.text.trim(),
      priority: _selectedPriority,
    );

    widget.onItemAdded(item);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compliance item "${_titleController.text}" added'),
          backgroundColor: const Color(0xFF10B981),
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
                        Icons.add_task,
                        color: Color(0xFF2563EB),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add Compliance Item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Type and Priority Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ComplianceType>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                          items: ComplianceType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<CompliancePriority>(
                          value: _selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                          items: CompliancePriority.values.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(priority.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Assigned To
                  TextFormField(
                    controller: _assignedToController,
                    decoration: const InputDecoration(
                      labelText: 'Assigned To (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Due Date
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
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
                              : const Text('Add Item'),
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