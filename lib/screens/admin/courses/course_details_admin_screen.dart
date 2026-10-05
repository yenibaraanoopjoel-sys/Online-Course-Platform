import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/course_model.dart';
import '../../../models/lesson_model.dart';
import '../../../services/course_service.dart';
import '../../../services/lesson_service.dart';

class CourseDetailsAdminScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsAdminScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsAdminScreen> createState() => _CourseDetailsAdminScreenState();
}

class _CourseDetailsAdminScreenState extends State<CourseDetailsAdminScreen> {
  CourseModel? _course;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final c = await context.read<CourseService>().getCourseById(widget.courseId);
    if (mounted) {
      setState(() {
        _course = c;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Details')),
        body: const Center(child: Text('Course not found')),
      );
    }

    final course = _course!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(course.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Course',
            onPressed: () => context.go('/admin/courses/edit/${widget.courseId}'),
          ),
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
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Card(
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 140,
                            height: 100,
                            color: AppColors.primaryContainer,
                            child: course.thumbnail.isNotEmpty
                                ? Image.network(
                                    course.thumbnail,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.school,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : const Icon(Icons.school, size: 40, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: course.isPublished
                                          ? AppColors.success.withValues(alpha: 0.1)
                                          : AppColors.warning.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      course.isPublished ? 'Published' : 'Draft',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: course.isPublished ? AppColors.success : AppColors.warning,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      course.categoryName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${course.level.toUpperCase()} • ${course.duration} mins • ${course.isFree ? "Free" : "\$${course.price.toStringAsFixed(2)}"}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                Card(
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Course Description',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          course.description.isNotEmpty ? course.description : 'No description provided.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lessons Section
                Card(
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Lessons Curriculum',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/admin/courses/${widget.courseId}/lessons/add'),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Lesson'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<LessonModel>>(
                          stream: context.read<LessonService>().getLessonsStream(widget.courseId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final lessons = snapshot.data ?? [];
                            if (lessons.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'No lessons added yet for this course.',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: lessons.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, idx) {
                                final lesson = lessons[idx];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primaryContainer,
                                    child: Text(
                                      '${lesson.order}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('${lesson.duration} mins${lesson.hasVideo ? " • Has Video" : ""}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    onPressed: () {
                                      context.go('/admin/courses/${widget.courseId}/lessons/edit/${lesson.lessonId}');
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
