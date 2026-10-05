import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/lesson_model.dart';
import '../../../services/lesson_service.dart';

class EditLessonScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;

  const EditLessonScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<EditLessonScreen> createState() => _EditLessonScreenState();
}

class _EditLessonScreenState extends State<EditLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();

  bool _isPublished = true;
  bool _loading = true;
  bool _saving = false;
  LessonModel? _lesson;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    final l = await context.read<LessonService>().getLessonById(widget.lessonId);
    if (mounted) {
      if (l != null) {
        setState(() {
          _lesson = l;
          _titleCtrl.text = l.title;
          _descCtrl.text = l.description;
          _videoUrlCtrl.text = l.videoUrl;
          _contentCtrl.text = l.content;
          _durationCtrl.text = l.duration.toString();
          _orderCtrl.text = l.order.toString();
          _isPublished = l.isPublished;
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
    _descCtrl.dispose();
    _videoUrlCtrl.dispose();
    _contentCtrl.dispose();
    _durationCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _lesson == null) return;

    setState(() => _saving = true);
    final lessonService = context.read<LessonService>();

    final updated = _lesson!.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      videoUrl: _videoUrlCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      duration: int.tryParse(_durationCtrl.text.trim()) ?? _lesson!.duration,
      order: int.tryParse(_orderCtrl.text.trim()) ?? _lesson!.order,
      isPublished: _isPublished,
    );

    final success = await lessonService.updateLesson(updated);
    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson updated successfully!'), backgroundColor: AppColors.success),
        );
        context.go('/admin/courses/${widget.courseId}/lessons');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update lesson'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Lesson')),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Lesson'),
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
                        'Edit Lesson',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Lesson Title *'),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Order & Duration
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _orderCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Order Sequence *',
                                prefixIcon: Icon(Icons.format_list_numbered),
                              ),
                              validator: (val) =>
                                  val == null || int.tryParse(val) == null ? 'Valid number required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Video URL
                      TextFormField(
                        controller: _videoUrlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Video URL',
                          prefixIcon: Icon(Icons.play_circle_outline),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Lesson Summary'),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      TextFormField(
                        controller: _contentCtrl,
                        maxLines: 6,
                        decoration: const InputDecoration(labelText: 'Lesson Notes & Content'),
                      ),
                      const SizedBox(height: 16),

                      // Published
                      SwitchListTile(
                        title: const Text('Published'),
                        value: _isPublished,
                        onChanged: (val) => setState(() => _isPublished = val),
                      ),
                      const SizedBox(height: 24),

                      // Submit
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
