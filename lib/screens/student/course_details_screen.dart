import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../services/lesson_service.dart';
import '../../services/enrollment_service.dart';
import '../../models/course_model.dart';
import '../../models/lesson_model.dart';
import '../../models/enrollment_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/utils/helpers.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool _enrolling = false;

  Future<void> _enroll(CourseModel course) async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _enrolling = true);

    final enrollService = context.read<EnrollmentService>();
    final courseService = context.read<CourseService>();
    final lessonService = context.read<LessonService>();

    final existing = await enrollService.getEnrollment(user.userId, course.courseId);
    if (existing != null) {
      if (mounted) context.go('/student/learn/${course.courseId}');
      return;
    }

    final totalLessons = await lessonService.getLessonCount(course.courseId);
    final enrollment = EnrollmentModel(
      enrollmentId: '',
      studentId: user.userId,
      studentName: user.fullName,
      courseId: course.courseId,
      courseTitle: course.title,
      enrolledAt: DateTime.now(),
      totalLessons: totalLessons,
      lastAccessedAt: DateTime.now(),
    );

    final id = await enrollService.enroll(enrollment);
    if (id != null) {
      await courseService.incrementStudentCount(course.courseId);
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Enrolled successfully! 🎉');
        context.go('/student/learn/${course.courseId}');
      }
    } else {
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Enrollment failed. Try again.', isError: true);
      }
    }
    setState(() => _enrolling = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<CourseModel?>(
        stream: context.read<CourseService>().courseStream(widget.courseId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget());
          }
          final course = snap.data;
          if (course == null) {
            return const Center(child: Text('Course not found'));
          }

          return CustomScrollView(
            slivers: [
              // Hero app bar with thumbnail
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: course.thumbnail.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.primaryDark,
                            child: const Icon(Icons.play_lesson, color: Colors.white54, size: 56),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.primaryDark,
                            child: const Icon(Icons.play_lesson, color: Colors.white54, size: 56),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.heroGradient),
                          ),
                          child: const Center(
                            child: Icon(Icons.play_lesson, color: Colors.white54, size: 56),
                          ),
                        ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Level chips
                      Row(
                        children: [
                          _chip(course.categoryName, AppColors.primaryContainer, AppColors.primary),
                          const SizedBox(width: 8),
                          _chip(
                            course.level,
                            AppHelpers.levelColor(course.level).withOpacity(0.12),
                            AppHelpers.levelColor(course.level),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      // Instructor
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            course.instructorName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stats row
                      _statsRow(course),
                      const SizedBox(height: 20),
                      // Price / Enroll button
                      if (user != null)
                        FutureBuilder<EnrollmentModel?>(
                          future: context.read<EnrollmentService>().getEnrollment(user.userId, course.courseId),
                          builder: (context, enrollSnap) {
                            final isEnrolled = enrollSnap.data != null;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: course.isFree ? AppColors.successLight : AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        course.isFree ? '🆓 Free Course' : '₹${course.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: course.isFree ? AppColors.success : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isEnrolled)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppColors.successLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          '✓ Enrolled',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  label: isEnrolled ? 'Continue Learning' : 'Enroll Now',
                                  onPressed: _enrolling ? null : () => _enroll(course),
                                  loading: _enrolling,
                                  fullWidth: true,
                                  height: 52,
                                  icon: Icon(
                                    isEnrolled ? Icons.play_arrow : Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                      // Description
                      const Text(
                        'About This Course',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Lesson list
                      const Text(
                        'Course Content',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _LessonListPreview(courseId: widget.courseId),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statsRow(CourseModel course) {
    return Row(
      children: [
        _stat(Icons.menu_book_outlined, '${course.lessonCount} Lessons'),
        const SizedBox(width: 16),
        _stat(Icons.timer_outlined, AppHelpers.formatDuration(course.duration)),
        const SizedBox(width: 16),
        _stat(Icons.people_outline, '${course.studentCount} Students'),
        const SizedBox(width: 16),
        if (course.rating > 0)
          _stat(Icons.star_outline, course.rating.toStringAsFixed(1)),
      ],
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _chip(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _LessonListPreview extends StatelessWidget {
  final String courseId;

  const _LessonListPreview({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LessonModel>>(
      stream: context.read<LessonService>().lessonsForCourse(courseId, publishedOnly: true),
      builder: (context, snap) {
        final lessons = snap.data ?? [];
        if (lessons.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Text(
              'No lessons added yet',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return Column(
          children: lessons.asMap().entries.map((e) {
            final lesson = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${lesson.order}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (lesson.duration > 0)
                          Text(
                            AppHelpers.formatDuration(lesson.duration),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    lesson.hasVideo ? Icons.play_circle_outline : Icons.article_outlined,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
