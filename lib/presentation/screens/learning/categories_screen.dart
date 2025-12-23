import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/category_model.dart';
import '../../../state/providers/category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  void _showCategoryDialog({CategoryModel? category}) {
    final TextEditingController _controller = TextEditingController(text: category?.name ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _controller.text.trim();
              if (name.isNotEmpty) {
                final provider = context.read<CategoryProvider>();
                bool success;
                if (category == null) {
                  success = await provider.addCategory(name);
                } else {
                  success = await provider.updateCategory(category.id, name);
                }
                
                if (context.mounted) {
                  Navigator.pop(context);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operation failed')));
                  }
                }
              }
            },
            child: Text(category == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
           if (provider.isLoading) return const Center(child: CircularProgressIndicator());
           
           if (provider.categories.isEmpty) return const Center(child: Text("No categories found."));

           return ListView.separated(
             padding: const EdgeInsets.all(16),
             itemCount: provider.categories.length,
             separatorBuilder: (ctx, i) => const Divider(),
             itemBuilder: (context, index) {
               final cat = provider.categories[index];
               return ListTile(
                 title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                 subtitle: Text('${cat.courses.length} courses'),
                 trailing: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     IconButton(
                       icon: const Icon(Icons.edit, color: Colors.blue),
                       onPressed: () => _showCategoryDialog(category: cat),
                     ),
                     IconButton(
                       icon: const Icon(Icons.delete, color: Colors.red),
                       onPressed: () async {
                         final confirm = await showDialog<bool>(
                           context: context,
                           builder: (ctx) => AlertDialog(
                             title: const Text('Delete Category?'),
                             content: const Text('This cannot be undone.'),
                             actions: [
                               TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                               TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                             ],
                           ),
                         );
                         
                         if (confirm == true && context.mounted) {
                            await provider.deleteCategory(cat.id);
                         }
                       },
                     ),
                   ],
                 ),
               );
             },
           );
        },
      ),
    );
  }
}
