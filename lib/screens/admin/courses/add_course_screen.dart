import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../models/course_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/category_service.dart';
import '../../../services/course_service.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _shortDescCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _thumbnailCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');
  final _priceCtrl = TextEditingController(text: '0');

  String _level = 'Beginner';
  CategoryModel? _selectedCategory;
  bool _isFree = true;
  bool _isPublished = true;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _shortDescCtrl.dispose();
    _descCtrl.dispose();
    _thumbnailCtrl.dispose();
    _durationCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _saving = true);
    final auth = context.read<AuthService>();
    final courseService = context.read<CourseService>();

    final course = CourseModel(
      courseId: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      shortDescription: _shortDescCtrl.text.trim(),
      thumbnail: _thumbnailCtrl.text.trim().isNotEmpty
          ? _thumbnailCtrl.text.trim()
          : 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800',
      instructorId: auth.userModel?.uid ?? 'admin',
      instructorName: auth.userModel?.displayName ?? 'Admin Instructor',
      categoryId: _selectedCategory!.categoryId,
      categoryName: _selectedCategory!.name,
      level: _level,
      duration: int.tryParse(_durationCtrl.text.trim()) ?? 60,
      price: _isFree ? 0.0 : (double.tryParse(_priceCtrl.text.trim()) ?? 0.0),
      isPublished: _isPublished,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await courseService.createCourse(course);
    if (mounted) {
      setState(() => _saving = false);
      if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course created successfully!'), backgroundColor: AppColors.success),
        );
        context.go(AppRoutes.courseManagement);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create course'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryService>().categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Course'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              color: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Course Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Course Title *',
                          hintText: 'e.g. Master Flutter & Dart for Mobile App Development',
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Short description
                      TextFormField(
                        controller: _shortDescCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Short Tagline / Overview',
                          hintText: 'A concise summary shown on course cards',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full description
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Full Course Description *',
                          hintText: 'Detailed curriculum, what students will learn, prerequisites...',
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Category & Level
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<CategoryModel>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(labelText: 'Category *'),
                              items: categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat.name),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _level,
                              decoration: const InputDecoration(labelText: 'Difficulty Level'),
                              items: const [
                                DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                                DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                                DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                                DropdownMenuItem(value: 'All Levels', child: Text('All Levels')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _level = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Thumbnail URL
                      TextFormField(
                        controller: _thumbnailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Thumbnail Image URL',
                          hintText: 'https://images.unsplash.com/...',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Duration & Pricing
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _durationCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Duration (Minutes)',
                                prefixIcon: Icon(Icons.timer_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Free Course'),
                              value: _isFree,
                              onChanged: (val) => setState(() => _isFree = val),
                            ),
                          ),
                        ],
                      ),
                      if (!_isFree) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Price (USD) *',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (val) {
                            if (!_isFree && (val == null || double.tryParse(val) == null)) {
                              return 'Enter a valid price';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Publish switch
                      SwitchListTile(
                        title: const Text('Publish Immediately'),
                        subtitle: const Text('When disabled, course will be saved as draft'),
                        value: _isPublished,
                        onChanged: (val) => setState(() => _isPublished = val),
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Create Course', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
