import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../state/providers/leave_provider.dart';
import '../../../../data/models/leave_model.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _leaveType = 'Casual';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isHalfDay = false;
  String? _halfDayType = 'First Half';
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _leaveTypes = ['Casual', 'Sick', 'Earned', 'Loss of Pay'];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Leave')),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLeaveTypeDropdown(),
                const SizedBox(height: 16),
                _buildDateSelectors(),
                if (_isHalfDay) ...[
                   const SizedBox(height: 16),
                   _buildHalfDaySelector(),
                ],
                const SizedBox(height: 16),
                _buildReasonField(),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitForm,
                    child: provider.isLoading 
                       ? const CircularProgressIndicator(color: Colors.white)
                       : const Text('SUBMIT REQUEST'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaveTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Leave Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      value: _leaveType,
      items: _leaveTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
      onChanged: (val) => setState(() => _leaveType = val!),
    );
  }

  Widget _buildDateSelectors() {
    // Calculate total days
    String duration = '';
    if (_startDate != null && _endDate != null) {
      if (_isHalfDay) {
        duration = '0.5 Day';
      } else {
        final days = _endDate!.difference(_startDate!).inDays + 1;
        duration = '$days Day(s)';
      }
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_startDate == null ? 'Select' : DateFormat('dd/MM/yyyy').format(_startDate!)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  child: Text(_endDate == null ? 'Select' : DateFormat('dd/MM/yyyy').format(_endDate!)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
         Row(
           children: [
             Checkbox(
               value: _isHalfDay,
               onChanged: (val) {
                 setState(() {
                   _isHalfDay = val!;
                   // If half day, start and end must be same? Usually yes.
                   if (_isHalfDay && _startDate != null) _endDate = _startDate; 
                 });
               }
             ),
             const Text('Half Day'),
             const Spacer(),
             if (duration.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Text(duration, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                )
           ],
         ),
      ],
    );
  }

  Widget _buildHalfDaySelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('First Half'),
            value: 'First Half',
            groupValue: _halfDayType,
            onChanged: (val) => setState(() => _halfDayType = val),
          ),
        ),
        Expanded(
           child: RadioListTile<String>(
            title: const Text('Second Half'),
            value: 'Second Half',
            groupValue: _halfDayType,
            onChanged: (val) => setState(() => _halfDayType = val),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Reason',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      validator: (val) => val == null || val.isEmpty ? 'Please enter a reason' : null,
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 60)), // Allow some backdating?
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // If end date is before new start date, reset it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
          if (_isHalfDay) _endDate = _startDate;
        } else {
          _endDate = picked;
          if (_isHalfDay) _startDate = _endDate;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select dates')));
        return;
      }
      
      final leave = LeaveModel(
        leaveType: _leaveType,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text,
        isHalfDay: _isHalfDay,
        halfDayType: _isHalfDay ? _halfDayType : null,
      );
      
      final success = await context.read<LeaveProvider>().applyLeave(leave);
      
      if (mounted) {
        if (success) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave applied successfully')));
           Navigator.pop(context);
        } else {
           final err = context.read<LeaveProvider>().errorMessage ?? 'Failed to apply';
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        }
      }
    }
  }
}
