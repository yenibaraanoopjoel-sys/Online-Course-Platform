import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/course_service.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  String _search = '';
  String _statusFilter = 'All'; // All, Published, Draft

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Course Management'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.addCourse),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Course'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search courses by title or category...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (val) => setState(() => _search = val.trim().toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Status')),
                    DropdownMenuItem(value: 'Published', child: Text('Published Only')),
                    DropdownMenuItem(value: 'Draft', child: Text('Draft Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _statusFilter = val);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Course List
          Expanded(
            child: StreamBuilder<List<CourseModel>>(
              stream: context.read<CourseService>().getAllCoursesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var courses = snapshot.data ?? [];

                // Filter
                if (_search.isNotEmpty) {
                  courses = courses.where((c) =>
                    c.title.toLowerCase().contains(_search) ||
                    c.category.toLowerCase().contains(_search)
                  ).toList();
                }

                if (_statusFilter == 'Published') {
                  courses = courses.where((c) => c.isPublished).toList();
                } else if (_statusFilter == 'Draft') {
                  courses = courses.where((c) => !c.isPublished).toList();
                }

                if (courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.library_books_outlined, size: 56, color: AppColors.textTertiary),
                        const SizedBox(height: 16),
                        const Text(
                          'No courses found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.go(AppRoutes.addCourse),
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Course'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Card(
                      elevation: 0,
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Thumbnail / placeholder
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 80,
                                height: 60,
                                color: AppColors.primaryContainer,
                                child: course.thumbnailUrl.isNotEmpty
                                    ? Image.network(
                                        course.thumbnailUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.school,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : const Icon(Icons.school, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          course.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: course.isPublished
                                              ? AppColors.success.withValues(alpha: 0.1)
                                              : AppColors.warning.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          course.isPublished ? 'Published' : 'Draft',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: course.isPublished ? AppColors.success : AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${course.category} • ${course.level.toUpperCase()} • ${course.isFree ? "Free" : "\$${course.price.toStringAsFixed(2)}"}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.play_lesson_outlined, size: 14, color: AppColors.textTertiary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${course.lessonCount} lessons',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.people_outline, size: 14, color: AppColors.textTertiary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${course.studentCount} students',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Actions
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                final courseService = context.read<CourseService>();
                                switch (value) {
                                  case 'details':
                                    context.go('/admin/courses/${course.id}');
                                    break;
                                  case 'lessons':
                                    context.go('/admin/courses/${course.id}/lessons');
                                    break;
                                  case 'edit':
                                    context.go('/admin/courses/edit/${course.id}');
                                    break;
                                  case 'togglePublish':
                                    await courseService.togglePublishCourse(course.id, !course.isPublished);
                                    break;
                                  case 'delete':
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Course'),
                                        content: Text('Are you sure you want to delete "${course.title}"? This cannot be undone.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await courseService.deleteCourse(course.id);
                                    }
                                    break;
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'details',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('View Details'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'lessons',
                                  child: Row(
                                    children: [
                                      Icon(Icons.list_alt, size: 18),
                                      SizedBox(width: 8),
                                      Text('Manage Lessons'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit Course'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'togglePublish',
                                  child: Row(
                                    children: [
                                      Icon(
                                        course.isPublished ? Icons.visibility_off : Icons.publish,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(course.isPublished ? 'Unpublish to Draft' : 'Publish Course'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
