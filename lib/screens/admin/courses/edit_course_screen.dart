import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/category_model.dart';
import '../../../models/course_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/category_service.dart';
import '../../../services/course_service.dart';

class EditCourseScreen extends StatefulWidget {
  final String courseId;

  const EditCourseScreen({super.key, required this.courseId});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _shortDescCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _thumbnailCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _level = 'Beginner';
  String? _categoryId;
  bool _isFree = true;
  bool _isPublished = true;
  bool _loading = true;
  bool _saving = false;
  CourseModel? _course;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final c = await context.read<CourseService>().getCourseById(widget.courseId);
    if (mounted) {
      if (c != null) {
        setState(() {
          _course = c;
          _titleCtrl.text = c.title;
          _shortDescCtrl.text = c.shortDescription;
          _descCtrl.text = c.description;
          _thumbnailCtrl.text = c.thumbnail;
          _durationCtrl.text = c.duration.toString();
          _priceCtrl.text = c.price.toString();
          _level = c.level;
          _categoryId = c.categoryId;
          _isFree = c.isFree;
          _isPublished = c.isPublished;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    }
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _course == null) return;

    setState(() => _saving = true);
    final courseService = context.read<CourseService>();
    final categories = context.read<CategoryService>().categories;
    final cat = categories.firstWhere(
      (c) => c.categoryId == _categoryId,
      orElse: () => CategoryModel(
        categoryId: _categoryId ?? '',
        name: _course!.categoryName,
        createdAt: DateTime.now(),
      ),
    );

    final updated = _course!.copyWith(
      title: _titleCtrl.text.trim(),
      shortDescription: _shortDescCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      thumbnail: _thumbnailCtrl.text.trim(),
      categoryId: cat.categoryId,
      categoryName: cat.name,
      level: _level,
      duration: int.tryParse(_durationCtrl.text.trim()) ?? _course!.duration,
      price: _isFree ? 0.0 : (double.tryParse(_priceCtrl.text.trim()) ?? 0.0),
      isPublished: _isPublished,
    );

    final success = await courseService.updateCourse(updated);
    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course updated successfully!'), backgroundColor: AppColors.success),
        );
        context.go(AppRoutes.courseManagement);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update course'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Course')),
        body: const Center(child: Text('Course not found')),
      );
    }

    final categories = context.watch<CategoryService>().categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Course'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Manage Lessons',
            onPressed: () => context.go('/admin/courses/${widget.courseId}/lessons'),
          ),
        ],
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
                        'Edit Course Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Course Title *'),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Short description
                      TextFormField(
                        controller: _shortDescCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Short Description'),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 5,
                        decoration: const InputDecoration(labelText: 'Full Description *'),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Category & Level
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _categoryId,
                              decoration: const InputDecoration(labelText: 'Category'),
                              items: categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat.categoryId,
                                  child: Text(cat.name),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _categoryId = val),
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

                      // Thumbnail
                      TextFormField(
                        controller: _thumbnailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Thumbnail URL',
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
                              decoration: const InputDecoration(labelText: 'Duration (Minutes)'),
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
                              return 'Enter valid price';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Publish switch
                      SwitchListTile(
                        title: const Text('Published'),
                        subtitle: const Text('Make course visible to students'),
                        value: _isPublished,
                        onChanged: (val) => setState(() => _isPublished = val),
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Save Changes', style: TextStyle(fontSize: 16)),
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
