import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../models/lesson_model.dart';
import '../../../services/course_service.dart';
import '../../../services/lesson_service.dart';

class LessonManagementScreen extends StatefulWidget {
  final String courseId;

  const LessonManagementScreen({super.key, required this.courseId});

  @override
  State<LessonManagementScreen> createState() => _LessonManagementScreenState();
}

class _LessonManagementScreenState extends State<LessonManagementScreen> {
  CourseModel? _course;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final c = await context.read<CourseService>().getCourseById(widget.courseId);
    if (mounted) {
      setState(() => _course = c);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_course != null ? 'Lessons: ${_course!.title}' : 'Manage Lessons'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => context.go('/admin/courses/${widget.courseId}/lessons/add'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Lesson'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<List<LessonModel>>(
        stream: context.read<LessonService>().getLessonsStream(widget.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lessons = snapshot.data ?? [];
          if (lessons.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.video_library_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text(
                    'No lessons yet for this course',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add lessons with videos, articles, and learning content.',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/admin/courses/${widget.courseId}/lessons/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Lesson'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return Card(
                color: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      '${lesson.order}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  title: Text(
                    lesson.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${lesson.duration} mins • ${lesson.hasVideo ? "Has Video" : "Reading"} • ${lesson.isPublished ? "Published" : "Draft"}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        tooltip: 'Edit Lesson',
                        onPressed: () {
                          context.go('/admin/courses/${widget.courseId}/lessons/edit/${lesson.lessonId}');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'Delete Lesson',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Lesson'),
                              content: Text('Are you sure you want to delete "${lesson.title}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await context.read<LessonService>().deleteLesson(lesson.lessonId);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
