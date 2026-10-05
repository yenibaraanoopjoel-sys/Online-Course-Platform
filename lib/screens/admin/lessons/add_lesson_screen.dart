import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/lesson_model.dart';
import '../../../services/lesson_service.dart';

class AddLessonScreen extends StatefulWidget {
  final String courseId;

  const AddLessonScreen({super.key, required this.courseId});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '15');
  final _orderCtrl = TextEditingController(text: '1');

  bool _isPublished = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _suggestNextOrder();
  }

  Future<void> _suggestNextOrder() async {
    final count = await context.read<LessonService>().getLessonCount(widget.courseId);
    if (mounted) {
      _orderCtrl.text = '${count + 1}';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final lessonService = context.read<LessonService>();

    final lesson = LessonModel(
      lessonId: '',
      courseId: widget.courseId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      videoUrl: _videoUrlCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      duration: int.tryParse(_durationCtrl.text.trim()) ?? 15,
      order: int.tryParse(_orderCtrl.text.trim()) ?? 1,
      isPublished: _isPublished,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await lessonService.createLesson(lesson);
    if (mounted) {
      setState(() => _saving = false);
      if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson added successfully!'), backgroundColor: AppColors.success),
        );
        context.go('/admin/courses/${widget.courseId}/lessons');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add lesson'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Lesson'),
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
                        'New Lesson Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      // Title
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Lesson Title *',
                          hintText: 'e.g. Introduction to Widgets and State',
                        ),
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
                                hintText: '1, 2, 3...',
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
                          labelText: 'Video URL (MP4 / Web Video / YouTube)',
                          hintText: 'https://commondatastorage.googleapis.com/... or MP4 link',
                          prefixIcon: Icon(Icons.play_circle_outline),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Lesson Summary / Overview',
                          hintText: 'Short summary of key takeaways',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full Content
                      TextFormField(
                        controller: _contentCtrl,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Lesson Notes & Detailed Content',
                          hintText: 'Detailed educational notes, code snippets, reading material...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Published
                      SwitchListTile(
                        title: const Text('Published'),
                        subtitle: const Text('Make lesson visible to enrolled students'),
                        value: _isPublished,
                        onChanged: (val) => setState(() => _isPublished = val),
                      ),
                      const SizedBox(height: 24),

                      // Submit
                      ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Save Lesson', style: TextStyle(fontSize: 16)),
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
