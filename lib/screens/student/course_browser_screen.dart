import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/course_service.dart';
import '../../services/category_service.dart';
import '../../models/course_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/course_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/helpers.dart';

class CourseBrowserScreen extends StatefulWidget {
  const CourseBrowserScreen({super.key});

  @override
  State<CourseBrowserScreen> createState() => _CourseBrowserScreenState();
}

class _CourseBrowserScreenState extends State<CourseBrowserScreen> {
  String _search = '';
  String? _categoryFilter;
  String? _levelFilter;
  String? _typeFilter; // 'free' | 'paid'
  String _sort = 'newest';

  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CourseModel> _filter(List<CourseModel> courses) {
    var list = courses.where((c) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!c.title.toLowerCase().contains(q) &&
            !c.instructorName.toLowerCase().contains(q) &&
            !c.categoryName.toLowerCase().contains(q) &&
            !c.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_categoryFilter != null && c.categoryName != _categoryFilter) return false;
      if (_levelFilter != null && c.level != _levelFilter) return false;
      if (_typeFilter == 'free' && !c.isFree) return false;
      if (_typeFilter == 'paid' && c.isFree) return false;
      return true;
    }).toList();

    switch (_sort) {
      case 'popular':
        list.sort((a, b) => b.studentCount.compareTo(a.studentCount));
      case 'rated':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'az':
        list.sort((a, b) => a.title.compareTo(b.title));
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  bool get _hasFilters =>
      _categoryFilter != null || _levelFilter != null || _typeFilter != null || _sort != 'newest';

  void _clearFilters() {
    setState(() {
      _categoryFilter = null;
      _levelFilter = null;
      _typeFilter = null;
      _sort = 'newest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Courses'),
        actions: [
          if (_hasFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear Filters'),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          // Active filter chips
          if (_categoryFilter != null || _levelFilter != null || _typeFilter != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_categoryFilter != null)
                    _filterChip(_categoryFilter!, () => setState(() => _categoryFilter = null)),
                  if (_levelFilter != null)
                    _filterChip(_levelFilter!, () => setState(() => _levelFilter = null)),
                  if (_typeFilter != null)
                    _filterChip(_typeFilter!, () => setState(() => _typeFilter = null)),
                ],
              ),
            ),
          // Results
          Expanded(
            child: StreamBuilder<List<CourseModel>>(
              stream: context.read<CourseService>().publishedCoursesStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingWidget());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final filtered = _filter(snap.data ?? []);
                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'No courses found',
                    subtitle: 'Try changing your search or filters',
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxis = AppHelpers.gridCrossAxisCount(constraints.maxWidth);
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxis,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final c = filtered[i];
                        return CourseCard(
                          course: c,
                          onTap: () => context.go('/student/course/${c.courseId}'),
                        );
                      },
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

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onRemove,
        backgroundColor: AppColors.primaryContainer,
        labelStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showFilterSheet() async {
    final cats = await context.read<CategoryService>().getCategories();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollCtrl) => SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _categoryFilter = null;
                          _levelFilter = null;
                          _typeFilter = null;
                          _sort = 'newest';
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _filterSection('Category', [
                  ...cats.map((c) => c.name),
                ], _categoryFilter, (v) {
                  setSheetState(() => _categoryFilter = v == _categoryFilter ? null : v);
                  setState(() => _categoryFilter = _categoryFilter);
                }),
                _filterSection('Level', ['Beginner', 'Intermediate', 'Advanced'],
                    _levelFilter, (v) {
                  setSheetState(() => _levelFilter = v == _levelFilter ? null : v);
                  setState(() => _levelFilter = _levelFilter);
                }),
                _filterSection('Type', ['free', 'paid'], _typeFilter, (v) {
                  setSheetState(() => _typeFilter = v == _typeFilter ? null : v);
                  setState(() => _typeFilter = _typeFilter);
                }),
                _filterSection('Sort By', ['newest', 'popular', 'rated', 'az'],
                    _sort, (v) {
                  setSheetState(() => _sort = v);
                  setState(() => _sort = v);
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterSection(
    String title,
    List<String> options,
    String? selected,
    void Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
