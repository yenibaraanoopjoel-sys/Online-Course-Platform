import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/course_service.dart';
import '../../models/enrollment_model.dart';
import '../../models/course_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/date_utils.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Courses'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<List<EnrollmentModel>>(
              stream: context.read<EnrollmentService>().studentEnrollmentsStream(user.userId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingWidget());
                }
                final all = snap.data ?? [];
                final inProgress = all.where((e) => !e.completed).toList();
                final completed = all.where((e) => e.completed).toList();

                return TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _CourseList(
                      enrollments: inProgress,
                      emptyTitle: 'No courses in progress',
                      emptySubtitle: 'Start learning a course to see it here',
                      emptyIcon: Icons.book_outlined,
                    ),
                    _CourseList(
                      enrollments: completed,
                      emptyTitle: 'No completed courses',
                      emptySubtitle: 'Complete a course to see it here',
                      emptyIcon: Icons.check_circle_outline,
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _CourseList extends StatelessWidget {
  final List<EnrollmentModel> enrollments;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;

  const _CourseList({
    required this.enrollments,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (enrollments.isEmpty) {
      return EmptyStateWidget(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
        actionLabel: 'Browse Courses',
        onAction: () => context.go('/student/browse'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enrollments.length,
      itemBuilder: (context, i) {
        final e = enrollments[i];
        return _EnrollmentCard(enrollment: e);
      },
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  final EnrollmentModel enrollment;

  const _EnrollmentCard({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CourseModel?>(
      stream: context.read<CourseService>().courseStream(enrollment.courseId),
      builder: (context, snap) {
        final course = snap.data;

        return GestureDetector(
          onTap: () => context.go('/student/learn/${enrollment.courseId}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        enrollment.courseTitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (enrollment.completed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '✓ Complete',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (course != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    course.instructorName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${enrollment.completedLessons}/${enrollment.totalLessons} lessons',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${enrollment.progressPercent}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: enrollment.progress,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      enrollment.completed ? AppColors.success : AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last: ${AppDateUtils.timeAgo(enrollment.lastAccessedAt)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go('/student/learn/${enrollment.courseId}'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        enrollment.completed ? 'Review' : 'Continue',
                        style: const TextStyle(fontSize: 13),
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
  }
}
