import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../services/auth_service.dart';
import '../../services/lesson_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/progress_service.dart';
import '../../services/course_service.dart';
import '../../models/lesson_model.dart';
import '../../models/enrollment_model.dart';
import '../../models/course_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/helpers.dart';

class LearningScreen extends StatefulWidget {
  final String courseId;

  const LearningScreen({super.key, required this.courseId});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int _currentIndex = 0;
  VideoPlayerController? _videoCtrl;
  bool _videoLoading = false;
  final Set<String> _completedLessonIds = {};

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _initVideo(String url) {
    _videoCtrl?.dispose();
    _videoCtrl = null;
    if (url.isEmpty) return;
    setState(() => _videoLoading = true);
    _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) setState(() => _videoLoading = false);
      }).catchError((_) {
        if (mounted) setState(() => _videoLoading = false);
      });
  }

  Future<void> _markComplete(List<LessonModel> lessons, EnrollmentModel enrollment) async {
    final lesson = lessons[_currentIndex];
    if (_completedLessonIds.contains(lesson.lessonId)) return;

    final auth = context.read<AuthService>();
    final progressService = context.read<ProgressService>();
    final enrollService = context.read<EnrollmentService>();

    await progressService.markLessonComplete(
      studentId: auth.currentUser!.userId,
      courseId: widget.courseId,
      lessonId: lesson.lessonId,
    );

    setState(() => _completedLessonIds.add(lesson.lessonId));

    final completed = _completedLessonIds.length;
    final total = lessons.length;

    await enrollService.updateProgress(
      enrollmentId: enrollment.enrollmentId,
      completedLessons: completed,
      totalLessons: total,
    );

    if (mounted) {
      AppHelpers.showSnackBar(context, 'Lesson marked as complete! 🎉');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<LessonModel>>(
        stream: context.read<LessonService>().lessonsForCourse(widget.courseId, publishedOnly: true),
        builder: (context, lessonSnap) {
          if (lessonSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget());
          }
          final lessons = lessonSnap.data ?? [];
          if (lessons.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.video_library_outlined,
              title: 'No lessons available',
              subtitle: 'This course has no published lessons yet',
            );
          }

          // Clamp index
          if (_currentIndex >= lessons.length) _currentIndex = 0;
          final lesson = lessons[_currentIndex];

          return FutureBuilder<EnrollmentModel?>(
            future: user != null
                ? context.read<EnrollmentService>().getEnrollment(user.userId, widget.courseId)
                : Future.value(null),
            builder: (context, enrollSnap) {
              final enrollment = enrollSnap.data;

              return FutureBuilder<CourseModel?>(
                future: context.read<CourseService>().getCourse(widget.courseId),
                builder: (context, courseSnap) {
                  final course = courseSnap.data;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 900;

                      if (isWide) {
                        return Row(
                          children: [
                            // Lesson sidebar
                            _LessonSidebar(
                              lessons: lessons,
                              currentIndex: _currentIndex,
                              completedIds: _completedLessonIds,
                              course: course,
                              enrollment: enrollment,
                              onSelect: (i) {
                                setState(() => _currentIndex = i);
                                if (lessons[i].hasVideo) _initVideo(lessons[i].videoUrl);
                              },
                            ),
                            const VerticalDivider(width: 1),
                            // Content
                            Expanded(
                              child: _LessonContent(
                                lesson: lesson,
                                videoCtrl: _videoCtrl,
                                videoLoading: _videoLoading,
                                isCompleted: _completedLessonIds.contains(lesson.lessonId),
                                onMarkComplete: enrollment != null
                                    ? () => _markComplete(lessons, enrollment)
                                    : null,
                                onPrev: _currentIndex > 0
                                    ? () => setState(() {
                                          _currentIndex--;
                                          final prev = lessons[_currentIndex];
                                          if (prev.hasVideo) _initVideo(prev.videoUrl);
                                        })
                                    : null,
                                onNext: _currentIndex < lessons.length - 1
                                    ? () => setState(() {
                                          _currentIndex++;
                                          final next = lessons[_currentIndex];
                                          if (next.hasVideo) _initVideo(next.videoUrl);
                                        })
                                    : null,
                              ),
                            ),
                          ],
                        );
                      }

                      // Mobile layout
                      return Column(
                        children: [
                          Expanded(
                            child: _LessonContent(
                              lesson: lesson,
                              videoCtrl: _videoCtrl,
                              videoLoading: _videoLoading,
                              isCompleted: _completedLessonIds.contains(lesson.lessonId),
                              onMarkComplete: enrollment != null
                                  ? () => _markComplete(lessons, enrollment)
                                  : null,
                              onPrev: _currentIndex > 0
                                  ? () => setState(() {
                                        _currentIndex--;
                                        final prev = lessons[_currentIndex];
                                        if (prev.hasVideo) _initVideo(prev.videoUrl);
                                      })
                                  : null,
                              onNext: _currentIndex < lessons.length - 1
                                  ? () => setState(() {
                                        _currentIndex++;
                                        final next = lessons[_currentIndex];
                                        if (next.hasVideo) _initVideo(next.videoUrl);
                                      })
                                  : null,
                            ),
                          ),
                          // Bottom lesson list
                          Container(
                            height: 200,
                            color: AppColors.surface,
                            child: _LessonList(
                              lessons: lessons,
                              currentIndex: _currentIndex,
                              completedIds: _completedLessonIds,
                              scrollDirection: Axis.horizontal,
                              onSelect: (i) {
                                setState(() => _currentIndex = i);
                                if (lessons[i].hasVideo) _initVideo(lessons[i].videoUrl);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _LessonSidebar extends StatelessWidget {
  final List<LessonModel> lessons;
  final int currentIndex;
  final Set<String> completedIds;
  final CourseModel? course;
  final EnrollmentModel? enrollment;
  final void Function(int) onSelect;

  const _LessonSidebar({
    required this.lessons,
    required this.currentIndex,
    required this.completedIds,
    required this.course,
    required this.enrollment,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: AppColors.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        course?.title ?? 'Course',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (enrollment != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${completedIds.length}/${lessons.length} completed',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '${(completedIds.length / lessons.length * 100).round()}%',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: lessons.isEmpty ? 0 : completedIds.length / lessons.length,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _LessonList(
              lessons: lessons,
              currentIndex: currentIndex,
              completedIds: completedIds,
              scrollDirection: Axis.vertical,
              onSelect: onSelect,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  final List<LessonModel> lessons;
  final int currentIndex;
  final Set<String> completedIds;
  final Axis scrollDirection;
  final void Function(int) onSelect;

  const _LessonList({
    required this.lessons,
    required this.currentIndex,
    required this.completedIds,
    required this.scrollDirection,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (scrollDirection == Axis.vertical) {
      return ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, i) => _LessonTile(
          lesson: lessons[i],
          index: i,
          isSelected: i == currentIndex,
          isCompleted: completedIds.contains(lessons[i].lessonId),
          onTap: () => onSelect(i),
        ),
      );
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: lessons.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, i) => _LessonTile(
        lesson: lessons[i],
        index: i,
        isSelected: i == currentIndex,
        isCompleted: completedIds.contains(lessons[i].lessonId),
        onTap: () => onSelect(i),
        compact: true,
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final bool isSelected;
  final bool isCompleted;
  final VoidCallback onTap;
  final bool compact;

  const _LessonTile({
    required this.lesson,
    required this.index,
    required this.isSelected,
    required this.isCompleted,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    size: 14,
                    color: isCompleted ? AppColors.success : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Lesson ${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                lesson.title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return ListTile(
      tileColor: isSelected ? AppColors.primaryContainer : null,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.successLight
              : isSelected
                  ? AppColors.primary
                  : AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isCompleted
              ? const Icon(Icons.check, color: AppColors.success, size: 16)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
        ),
      ),
      title: Text(
        lesson.title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: lesson.duration > 0
          ? Text(
              AppHelpers.formatDuration(lesson.duration),
              style: const TextStyle(fontSize: 11),
            )
          : null,
      trailing: Icon(
        lesson.hasVideo ? Icons.play_circle_outline : Icons.article_outlined,
        size: 16,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}

class _LessonContent extends StatelessWidget {
  final LessonModel lesson;
  final VideoPlayerController? videoCtrl;
  final bool videoLoading;
  final bool isCompleted;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _LessonContent({
    required this.lesson,
    required this.videoCtrl,
    required this.videoLoading,
    required this.isCompleted,
    required this.onMarkComplete,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video area
          if (lesson.hasVideo) ...[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: videoLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : videoCtrl != null && videoCtrl!.value.isInitialized
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(videoCtrl!),
                              GestureDetector(
                                onTap: () {
                                  if (videoCtrl!.value.isPlaying) {
                                    videoCtrl!.pause();
                                  } else {
                                    videoCtrl!.play();
                                  }
                                },
                                child: Icon(
                                  videoCtrl!.value.isPlaying
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  color: Colors.white54,
                                  size: 56,
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_circle_outline, color: Colors.white54, size: 56),
                                const SizedBox(height: 8),
                                Text(
                                  'Video: ${lesson.videoUrl}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
              ),
            ),
          ] else
            Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
              ),
              child: const Center(
                child: Icon(Icons.article_outlined, color: Colors.white54, size: 48),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson number + title
                Text(
                  'Lesson ${lesson.order}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(lesson.title, style: Theme.of(context).textTheme.headlineSmall),
                if (lesson.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Content
                if (lesson.content.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      lesson.content,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Mark complete button
                if (!isCompleted && onMarkComplete != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onMarkComplete,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Mark as Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  )
                else if (isCompleted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Lesson Completed',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Navigation
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onPrev != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onPrev,
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Previous'),
                        ),
                      ),
                    if (onPrev != null && onNext != null) const SizedBox(width: 12),
                    if (onNext != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onNext,
                          label: const Text('Next'),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
