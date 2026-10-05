import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/course_service.dart';
import '../../models/enrollment_model.dart';
import '../../models/course_model.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/course_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/helpers.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar / Hero
          SliverToBoxAdapter(
            child: _HeroSection(name: user?.fullName ?? 'Student'),
          ),
          // Stats
          SliverToBoxAdapter(
            child: StreamBuilder<List<EnrollmentModel>>(
              stream: context
                  .read<EnrollmentService>()
                  .studentEnrollmentsStream(user?.userId ?? ''),
              builder: (context, snap) {
                final enrollments = snap.data ?? [];
                final completed = enrollments.where((e) => e.completed).length;
                final inProgress = enrollments.where((e) => !e.completed).length;
                final overallProgress = enrollments.isEmpty
                    ? 0.0
                    : enrollments.fold(0.0, (s, e) => s + e.progress) / enrollments.length;

                return _StatsRow(
                  enrolled: enrollments.length,
                  completed: completed,
                  inProgress: inProgress,
                  overallProgress: overallProgress,
                );
              },
            ),
          ),
          // Continue Learning
          SliverToBoxAdapter(
            child: _ContinueLearningSection(userId: user?.userId ?? ''),
          ),
          // Recommended
          SliverToBoxAdapter(
            child: _RecommendedSection(userId: user?.userId ?? ''),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String name;

  const _HeroSection({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, 👋',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Continue your learning journey today',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.browse),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Explore Courses',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.school, color: Colors.white38, size: 72),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int enrolled;
  final int completed;
  final int inProgress;
  final double overallProgress;

  const _StatsRow({
    required this.enrolled,
    required this.completed,
    required this.inProgress,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxis = constraints.maxWidth > 600 ? 4 : 2;
          return GridView.count(
            crossAxisCount: crossAxis,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              StatCard(
                label: 'Enrolled',
                value: '$enrolled',
                icon: Icons.book_outlined,
                color: AppColors.primary,
              ),
              StatCard(
                label: 'Completed',
                value: '$completed',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
              StatCard(
                label: 'In Progress',
                value: '$inProgress',
                icon: Icons.trending_up,
                color: AppColors.warning,
              ),
              StatCard(
                label: 'Progress',
                value: '${(overallProgress * 100).round()}%',
                icon: Icons.bar_chart,
                color: AppColors.secondary,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContinueLearningSection extends StatelessWidget {
  final String userId;

  const _ContinueLearningSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Continue Learning',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.myCourses),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        StreamBuilder<List<EnrollmentModel>>(
          stream: context.read<EnrollmentService>().studentEnrollmentsStream(userId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: LoadingWidget(),
              );
            }
            final enrollments = (snap.data ?? []).where((e) => !e.completed).take(3).toList();
            if (enrollments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Text(
                    'No courses in progress. Browse courses to start learning!',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: enrollments.length,
                itemBuilder: (context, i) {
                  final e = enrollments[i];
                  return _ContinueLearningCard(enrollment: e);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  final EnrollmentModel enrollment;

  const _ContinueLearningCard({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/student/learn/${enrollment.courseId}'),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              enrollment.courseTitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${enrollment.completedLessons}/${enrollment.totalLessons} lessons',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  AppHelpers.formatProgress(
                      enrollment.completedLessons, enrollment.totalLessons),
                  style: const TextStyle(
                    fontSize: 12,
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
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/student/learn/${enrollment.courseId}'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  final String userId;

  const _RecommendedSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended For You',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.browse),
                child: const Text('Browse All'),
              ),
            ],
          ),
        ),
        StreamBuilder<List<CourseModel>>(
          stream: context.read<CourseService>().publishedCoursesStream(),
          builder: (context, snap) {
            final courses = snap.data?.take(6).toList() ?? [];
            if (courses.isEmpty && snap.connectionState != ConnectionState.waiting) {
              return const EmptyStateWidget(
                icon: Icons.explore_outlined,
                title: 'No courses yet',
                subtitle: 'New courses will appear here',
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final crossAxis = AppHelpers.gridCrossAxisCount(constraints.maxWidth);
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, i) {
                    final course = courses[i];
                    return CourseCard(
                      course: course,
                      onTap: () =>
                          context.go('/student/course/${course.courseId}'),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
