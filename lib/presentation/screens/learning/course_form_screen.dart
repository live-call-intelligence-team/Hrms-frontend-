import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/course_provider.dart';
import '../../../state/providers/category_provider.dart';
import '../../../data/models/course_model.dart';

class CourseFormScreen extends StatefulWidget {
  final CourseModel? course; // If null, create mode

  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _thumbController;
  late TextEditingController _durationController;
  
  int? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descController = TextEditingController(text: widget.course?.description ?? '');
    _thumbController = TextEditingController(text: widget.course?.thumbnailUrl ?? '');
    
    // Handle dynamic duration type or convert
    _durationController = TextEditingController(text: widget.course?.duration ?? '');

    _selectedCategoryId = widget.course?.category;

    // Fetch categories if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _thumbController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final Map<String, dynamic> data = {
        'title': _titleController.text,
        'description': _descController.text,
        'thumbnail_url': _thumbController.text,
        'duration': int.tryParse(_durationController.text) ?? 0, // Simplified int handling
        'category_id': _selectedCategoryId,
        'is_active': true,
      };

      try {
        bool success;
        final provider = context.read<CourseProvider>();
        
        if (widget.course == null) {
          success = await provider.createCourse(data);
        } else {
          success = await provider.updateCourse(widget.course!.id!, data);
        }

        if (mounted) {
          setState(() => _isLoading = false);
          if (success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course saved successfully')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save course')));
          }
        }
      } catch (e) {
        if (mounted) {
           setState(() => _isLoading = false);
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course == null ? 'Create Course' : 'Edit Course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                 validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              Consumer<CategoryProvider>(
                builder: (context, catProvider, child) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: catProvider.categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                    },
                    validator: (val) => val == null ? 'Please select a category' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thumbController,
                decoration: const InputDecoration(labelText: 'Thumbnail URL', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes - approx)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : Text(widget.course == null ? 'Create Course' : 'Update Course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
