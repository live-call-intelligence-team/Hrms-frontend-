import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/shift_provider.dart';
import '../../../data/models/shift_models.dart';

class ShiftFormScreen extends StatefulWidget {
  final Shift? shift;

  const ShiftFormScreen({super.key, this.shift});

  @override
  State<ShiftFormScreen> createState() => _ShiftFormScreenState();
}

class _ShiftFormScreenState extends State<ShiftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Duration _breakDuration = const Duration(hours: 1);
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shift?.name ?? '');
    _descriptionController = TextEditingController(text: widget.shift?.description ?? '');
    _isActive = widget.shift?.isActive ?? true;

    if (widget.shift != null) {
      _startTime = _parseTime(widget.shift!.startTime);
      _endTime = _parseTime(widget.shift!.endTime);
      _breakDuration = _parseDuration(widget.shift!.breakDuration);
    }
  }

  // Helpers to parse "HH:mm:ss" strings
  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }
  
  Duration _parseDuration(String durationStr) {
     try {
      final parts = durationStr.split(':');
      return Duration(
        hours: int.parse(parts[0]), 
        minutes: int.parse(parts[1]), 
        seconds: int.parse(parts[2])
      );
    } catch (e) {
      return const Duration(hours: 1);
    }
  }
  
  String _formatTime(TimeOfDay time) {
    // Returns HH:mm:ss format (seconds 00)
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String _formatDuration(Duration duration) {
     final h = duration.inHours.toString().padLeft(2, '0');
     final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
     final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
     return '$h:$m:$s';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shift == null ? 'Add Shift' : 'Edit Shift'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Shift Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter shift name' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Start Time', 
                      selectedTime: _startTime, 
                      onChanged: (val) => setState(() => _startTime = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker(
                      label: 'End Time', 
                      selectedTime: _endTime, 
                      onChanged: (val) => setState(() => _endTime = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildDurationPicker(
                  label: 'Break Duration', 
                  duration: _breakDuration,
                  onChanged: (val) => setState(() => _breakDuration = val),
              ),
              
              const SizedBox(height: 16),
              
              _buildTotalHoursCalculation(),
              
              const SizedBox(height: 16),
               TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text("Active"),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val!),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(widget.shift == null ? 'Create Shift' : 'Update Shift'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label, 
    required TimeOfDay? selectedTime, 
    required ValueChanged<TimeOfDay> onChanged
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: selectedTime ?? TimeOfDay.now());
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          selectedTime?.format(context) ?? 'Select Time',
          style: TextStyle(
            color: selectedTime == null ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDurationPicker({
      required String label, 
      required Duration duration, 
      required ValueChanged<Duration> onChanged
  }) {
      return InkWell(
        onTap: () async {
            // Simplified duration picker using TimeOfDay for HH:mm
             final picked = await showTimePicker(
                context: context, 
                initialTime: TimeOfDay(hour: duration.inHours, minute: duration.inMinutes % 60),
                helpText: 'SELECT BREAK DURATION (Hours:Minutes)'
            );
            if (picked != null) {
                onChanged(Duration(hours: picked.hour, minutes: picked.minute));
            }
        },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
             child: Text(
              "${duration.inHours}h ${duration.inMinutes % 60}m",
               style: const TextStyle(color: Colors.black),
            ),
          ),
      );
  }

  Widget _buildTotalHoursCalculation() {
    String totalStr = '--:--';
    if (_startTime != null && _endTime != null) {
      final start = DateTime(2020, 1, 1, _startTime!.hour, _startTime!.minute);
      var end = DateTime(2020, 1, 1, _endTime!.hour, _endTime!.minute);
      
      if (end.isBefore(start)) {
        end = end.add(const Duration(days: 1)); // Overnight shift
      }
      
      final diff = end.difference(start);
      final net = diff - _breakDuration;
      
      if (net.isNegative) {
          totalStr = "Invalid (Break > Duration)";
      } else {
           totalStr = "${net.inHours}h ${net.inMinutes % 60}m";
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Calculated Total Hours:", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(totalStr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select start and end times")));
        return;
    }

    final start = DateTime(2020, 1, 1, _startTime!.hour, _startTime!.minute);
    var end = DateTime(2020, 1, 1, _endTime!.hour, _endTime!.minute);
    if (end.isBefore(start)) end = end.add(const Duration(days: 1));
    
    final diff = end.difference(start);
    if (diff < _breakDuration) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Break duration cannot be longer than shift duration")));
         return;
    }
    
    final net = diff - _breakDuration;
    
    final data = {
      'name': _nameController.text,
      'start_time': _formatTime(_startTime!),
      'end_time': _formatTime(_endTime!),
      'break_duration': _formatDuration(_breakDuration),
      'total_hours': _formatDuration(net),
      'description': _descriptionController.text,
      'is_active': _isActive,
    };

    final provider = context.read<ShiftProvider>();
    bool success;
    
    if (widget.shift == null) {
        // Create (Shift object construction is internal to provider or we pass map to service, 
        // but provider method takes Shift model usually. Let's adjust provider to take ID for update but maybe Map or Model for create.
        // My previous provider implementation expects a Shift object for Create/Update.
        // Let's create a temp Shift object with dummy ID 0
        final newShift = Shift(
            id: 0, 
            name: data['name'] as String, 
            startTime: data['start_time'] as String, 
            endTime: data['end_time'] as String, 
            breakDuration: data['break_duration'] as String, 
            totalHours: data['total_hours'] as String,
            description: data['description'] as String,
            isActive: data['is_active'] as bool,
        );
        success = await provider.createShift(newShift);
    } else {
        final updatedShift = Shift(
            id: widget.shift!.id, 
            name: data['name'] as String, 
            startTime: data['start_time'] as String, 
            endTime: data['end_time'] as String, 
            breakDuration: data['break_duration'] as String, 
            totalHours: data['total_hours'] as String,
             description: data['description'] as String,
            isActive: data['is_active'] as bool,
        );
        success = await provider.updateShift(widget.shift!.id, updatedShift);
    }

    if (success && mounted) {
        Navigator.pop(context);
    } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.errorMessage ?? 'An error occurred'))
         );
    }
  }
}
