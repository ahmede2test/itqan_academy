import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/features/home/presentation/manger/post_cubit/post_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/post_cubit/post_state.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_cubit/course_cubit.dart';
import 'package:itqan_academy/features/courses/presentation/manger/course_cubit/course_state.dart';
import 'package:itqan_academy/features/home/presentation/manger/exams_cubit/exams_cubit.dart';
import 'package:itqan_academy/features/home/presentation/manger/exams_cubit/exams_state.dart';
import 'package:itqan_academy/features/home/data/models/exam_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Itqan Admin Dashboard',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          tabs: const [
            Tab(text: 'News', icon: Icon(Icons.newspaper_rounded)),
            Tab(text: 'Courses', icon: Icon(Icons.book_rounded)),
            Tab(text: 'Exams', icon: Icon(Icons.quiz_rounded)),
            Tab(text: 'Users', icon: Icon(Icons.people_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _NewsManagementView(),
          _CoursesManagementView(),
          _ExamsManagementView(),
          _UserManagementView(),
        ],
      ),
    );
  }
}

// --- Common Widgets ---

Widget _buildTextField(
    TextEditingController controller, String label, IconData icon,
    {int maxLines = 1, bool readOnly = false}) {
  return TextFormField(
    readOnly: readOnly,
    controller: controller,
    maxLines: maxLines,
    style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontFamily: 'Cairo'),
      prefixIcon: Icon(icon, color: Colors.redAccent, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
    ),
    validator: (value) =>
        value == null || value.isEmpty ? 'Please enter $label' : null,
  );
}

Widget _buildDropdownField(String label, List<String> items,
    Function(String?) onChanged, String? value, IconData icon,
    {List<String>? itemLabels}) {
  // Fix: Ensure value exists in items to prevent Assertion error
  final safeValue = items.contains(value) ? value : null;
  return DropdownButtonFormField<String>(
    value: safeValue,
    items: List.generate(items.length, (index) {
      final val = items[index];
      final lbl = itemLabels != null ? itemLabels[index] : val;
      return DropdownMenuItem(
          value: val,
          child: Text(lbl,
              style:
                  const TextStyle(color: Colors.white, fontFamily: 'Cairo')));
    }),
    onChanged: onChanged,
    dropdownColor: Colors.black,
    style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontFamily: 'Cairo'),
      prefixIcon: Icon(icon, color: Colors.redAccent, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
    ),
    validator: (value) => value == null ? 'Please select $label' : null,
  );
}

Widget _buildAdminButton({
  required String label,
  required VoidCallback? onPressed,
  required bool isLoading,
  Color color = Colors.red,
}) {
  return SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withOpacity(0.05);
            }
            return null;
          },
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
    ),
  );
}

// --- NEWS MANAGEMENT ---

class _NewsManagementView extends StatefulWidget {
  const _NewsManagementView();

  @override
  State<_NewsManagementView> createState() => _NewsManagementViewState();
}

class _NewsManagementViewState extends State<_NewsManagementView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveNews() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('academy_news').insert({
        'title': _titleController.text,
        'content': _contentController.text,
        'category': _categoryController.text,
        'image_url': _imageUrlController.text,
        'author': user?.email ?? 'Admin',
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('News added successfully!'),
              backgroundColor: Colors.green),
        );
        _titleController.clear();
        _contentController.clear();
        _categoryController.clear();
        _imageUrlController.clear();
        context.read<PostCubit>().getPosts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current News',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<PostCubit, PostState>(
                    builder: (context, state) {
                      if (state is PostLoading) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.red));
                      } else if (state is PostSuccess) {
                        return ListView.builder(
                          itemCount: state.posts.length,
                          itemBuilder: (context, index) {
                            final post = state.posts[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  post.featuredImage ?? '',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.newspaper),
                                ),
                              ),
                              title: Text(post.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Cairo')),
                              subtitle: Text(post.category,
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontFamily: 'Cairo')),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  await Supabase.instance.client
                                      .from('academy_news')
                                      .delete()
                                      .eq('id', post.id);
                                  context.read<PostCubit>().getPosts();
                                },
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: Text('No news found'));
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_titleController, 'Title', Icons.title),
                  const SizedBox(height: 12),
                  _buildTextField(_contentController, 'Content', Icons.article,
                      maxLines: 4),
                  const SizedBox(height: 12),
                  _buildTextField(
                      _categoryController, 'Category', Icons.category),
                  const SizedBox(height: 12),
                  _buildTextField(
                      _imageUrlController, 'Image URL', Icons.image),
                  const SizedBox(height: 24),
                  _buildAdminButton(
                    label: 'Save News',
                    onPressed: _saveNews,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- COURSES MANAGEMENT ---

class _CoursesManagementView extends StatefulWidget {
  const _CoursesManagementView();

  @override
  State<_CoursesManagementView> createState() => _CoursesManagementViewState();
}

class _CoursesManagementViewState extends State<_CoursesManagementView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _thumbController = TextEditingController();
  String? _selectedLevel;
  int? _selectedYear;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<CourseCubit>().getCourses();
  }

  final List<Map<String, String>> _levels = [
    {'value': 'Primary', 'label': 'المرحلة الابتدائية'},
    {'value': 'Prep', 'label': 'المرحلة الإعدادية'},
    {'value': 'Secondary', 'label': 'المرحلة الثانوية'},
    {'value': 'University', 'label': 'المرحلة الجامعية'},
  ];

  final Map<String, List<int>> _years = {
    'Primary': [0, 1, 2, 3, 4, 5, 6],
    'Prep': [0, 1, 2, 3],
    'Secondary': [0, 1, 2, 3],
    'University': [0, 1, 2, 3, 4],
  };

  String _getYearLabel(String level, int year) {
    if (year == 0) return 'General (عام)';
    if (level == 'University') return 'الفرقة $year';
    return 'الصف $year';
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('courses').insert({
        'title': _titleController.text,
        'thumbnail': _thumbController.text,
        'target_level': _selectedLevel,
        'target_year': _selectedYear,
      });
      if (mounted) {
        _titleController.clear();
        _thumbController.clear();
        setState(() {
          _selectedLevel = null;
          _selectedYear = null;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Existing Courses',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<CourseCubit, CourseState>(
                    builder: (context, state) {
                      if (state is UserCoursesSuccessState) {
                        return ListView.builder(
                          itemCount: state.courses.length,
                          itemBuilder: (context, index) {
                            final course = state.courses[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  course.thumbnail,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.book),
                                ),
                              ),
                              title: Text(course.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Cairo')),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit Course',
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blueAccent),
                                    onPressed: () =>
                                        _showEditCourseDialog(context, course),
                                  ),
                                  IconButton(
                                    tooltip: 'Manage Lessons',
                                    icon: const Icon(
                                        Icons.video_library_rounded,
                                        color: Colors.greenAccent),
                                    onPressed: () =>
                                        _showLessonsDialog(context, course),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () =>
                                        _confirmDeleteCourse(context, course),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(
                        _titleController, 'Course Title', Icons.book),
                    const SizedBox(height: 12),
                    _buildTextField(
                        _thumbController, 'Thumbnail URL', Icons.image),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      'المرحلة الدراسية',
                      _levels.map((e) => e['value']!).toList(),
                      (val) {
                        setState(() {
                          _selectedLevel = val;
                          _selectedYear = null;
                        });
                      },
                      _selectedLevel,
                      Icons.school,
                      itemLabels: _levels.map((e) => e['label']!).toList(),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedLevel != null &&
                        _years.containsKey(_selectedLevel))
                      _buildDropdownField(
                        'السنة الدراسية',
                        _years[_selectedLevel!]!
                            .map((e) => e.toString())
                            .toList(),
                        (val) {
                          setState(() => _selectedYear = int.tryParse(val!));
                        },
                        _selectedYear?.toString(),
                        Icons.calendar_today,
                        itemLabels: _years[_selectedLevel!]!
                            .map((e) => _getYearLabel(_selectedLevel!, e))
                            .toList(),
                      ),
                    const SizedBox(height: 24),
                    _buildAdminButton(
                      label: 'Add Course',
                      onPressed: _saveCourse,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLessonsDialog(BuildContext context, dynamic course) {
    showDialog(
      context: context,
      builder: (context) => _LessonManagementDialog(
        courseId: course.id.toString(),
        courseTitle: course.title,
      ),
    );
  }

  Future<void> _showEditCourseDialog(
      BuildContext context, dynamic course) async {
    // 3. Initialize the controllers locally at the very beginning
    final titleController = TextEditingController(text: course.title ?? '');
    final thumbController = TextEditingController(text: course.thumbnail ?? '');
    String? selectedLevel = course.targetLevel;
    int selectedYear = course.targetYear ?? 0;
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Edit Course',
                  style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                            titleController, 'Course Title', Icons.book),
                        const SizedBox(height: 12),
                        _buildTextField(
                            thumbController, 'Thumbnail URL', Icons.image),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          'المرحلة الدراسية',
                          _levels.map((e) => e['value']!).toList(),
                          (val) {
                            setState(() {
                              selectedLevel = val;
                              selectedYear = 0; // Reset year on level change
                            });
                          },
                          selectedLevel,
                          Icons.school,
                          itemLabels: _levels.map((e) => e['label']!).toList(),
                        ),
                        const SizedBox(height: 12),
                        if (selectedLevel != null &&
                            _years.containsKey(selectedLevel))
                          DropdownButtonFormField<String>(
                            value: _years[selectedLevel!]!
                                    .any((e) => e == selectedYear)
                                ? selectedYear.toString()
                                : '0', // Default to '0' (General) if value not found
                            dropdownColor: const Color(0xFF1E1E1E),
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Cairo'),
                            decoration: InputDecoration(
                              labelText: 'السنة الدراسية',
                              labelStyle:
                                  const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.calendar_today,
                                  color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none),
                            ),
                            items: _years[selectedLevel!]!.map((e) {
                              return DropdownMenuItem(
                                value: e.toString(),
                                child: Text(_getYearLabel(selectedLevel!, e)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() =>
                                  selectedYear = int.tryParse(val ?? '0') ?? 0);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white54)),
                ),
                _buildAdminButton(
                  label: 'Update Course',
                  isLoading: isLoading,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setState(() => isLoading = true);
                    bool success = false;
                    try {
                      await Supabase.instance.client.from('courses').update({
                        'title': titleController.text,
                        'thumbnail': thumbController.text,
                        'target_level': selectedLevel,
                        'target_year': selectedYear,
                      }).eq('id', course.id);

                      success = true;
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Course updated successfully!'),
                              backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      debugPrint("Error updating course: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error updating course: $e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      // Only stop loading if we are keeping the dialog open (failure case)
                      if (!success && context.mounted) {
                        setState(() => isLoading = false);
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    // Disposal removed to prevent race condition with dialog exit animation
    // The controllers will be GC'd with the closure context.
  }

  Future<void> _confirmDeleteCourse(
      BuildContext context, dynamic course) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Course',
            style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
        content: Text(
            'Are you sure you want to delete "${course.title}"?\nThis action cannot be undone.',
            style: const TextStyle(color: Colors.white70, fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      if (!context.mounted) return;
      try {
        await Supabase.instance.client
            .from('courses')
            .delete()
            .eq('id', course.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Course deleted successfully'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        debugPrint("Error deleting course: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

class _LessonManagementDialog extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  const _LessonManagementDialog(
      {required this.courseId, required this.courseTitle});

  @override
  State<_LessonManagementDialog> createState() =>
      _LessonManagementDialogState();
}

class _LessonManagementDialogState extends State<_LessonManagementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _pdfUrlController = TextEditingController();
  final _orderController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _lessons = [];

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    try {
      final response = await Supabase.instance.client
          .from('lessons')
          .select()
          .eq('course_id', widget.courseId)
          .order('order_index', ascending: true);
      setState(() {
        _lessons = response as List;
      });
    } catch (e) {
      debugPrint("Error fetching lessons: $e");
    }
  }

  Future<void> _addLesson() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('lessons').insert({
        'course_id': widget.courseId,
        'title': _titleController.text,
        'video_url': _videoUrlController.text,
        'pdf_url':
            _pdfUrlController.text.isEmpty ? null : _pdfUrlController.text,
        'order_index': int.tryParse(_orderController.text) ?? 1,
      });
      _titleController.clear();
      _videoUrlController.clear();
      _pdfUrlController.clear();
      _orderController.clear();
      await _fetchLessons();
    } catch (e) {
      debugPrint("Error adding lesson: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLesson(int lessonId) async {
    try {
      await Supabase.instance.client
          .from('lessons')
          .delete()
          .eq('id', lessonId);
      await _fetchLessons();
    } catch (e) {
      debugPrint("Error deleting lesson: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121212),
      title: Text('Lessons: ${widget.courseTitle}',
          style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')),
      content: SizedBox(
        width: 800,
        height: 600,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Text('Current Lessons',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Cairo')),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _lessons[index];
                        return Card(
                          color: Colors.white.withOpacity(0.05),
                          child: ListTile(
                            title: Text(lesson['title'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white, fontFamily: 'Cairo')),
                            subtitle: Text('Index: ${lesson['order_index']}',
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontFamily: 'Cairo')),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () => _deleteLesson(lesson['id']),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(color: Colors.white24),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text('Add New Lesson',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontFamily: 'Cairo')),
                      const SizedBox(height: 20),
                      _buildTextField(
                          _titleController, 'Lesson Title', Icons.title),
                      const SizedBox(height: 12),
                      _buildTextField(_videoUrlController, 'Video URL',
                          Icons.play_circle_fill),
                      const SizedBox(height: 12),
                      _buildTextField(_orderController, 'Order Index (1, 2...)',
                          Icons.sort),
                      const SizedBox(height: 12),
                      _buildTextField(_pdfUrlController, 'PDF URL (Optional)',
                          Icons.picture_as_pdf),
                      const SizedBox(height: 24),
                      _buildAdminButton(
                        label: 'Add Lesson',
                        onPressed: _addLesson,
                        isLoading: _isLoading,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Close', style: TextStyle(color: Colors.white54))),
      ],
    );
  }
}

// --- EXAMS MANAGEMENT ---

class _ExamsManagementView extends StatefulWidget {
  const _ExamsManagementView();

  @override
  State<_ExamsManagementView> createState() => _ExamsManagementViewState();
}

class _ExamsManagementViewState extends State<_ExamsManagementView> {
  final _formKey = GlobalKey<FormState>();
  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  String? _selectedLevel;
  int? _selectedYear;
  bool _isLoading = false;

  final List<Map<String, String>> _levels = [
    {'value': 'Primary', 'label': 'المرحلة الابتدائية'},
    {'value': 'Prep', 'label': 'المرحلة الإعدادية'},
    {'value': 'Secondary', 'label': 'المرحلة الثانوية'},
    {'value': 'University', 'label': 'المرحلة الجامعية'},
  ];

  final Map<String, List<int>> _years = {
    'Primary': [0, 1, 2, 3, 4, 5, 6],
    'Prep': [0, 1, 2, 3],
    'Secondary': [0, 1, 2, 3],
    'University': [0, 1, 2, 3, 4],
  };

  String _getYearLabel(String level, int year) {
    if (year == 0) return 'General (عام)';
    if (level == 'University') return 'الفرقة $year';
    return 'الصف $year';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.red,
            onPrimary: Colors.white,
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.red,
            onPrimary: Colors.white,
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          final format = (picked.hour >= 12) ? 'PM' : 'AM';
          final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
          _timeController.text =
              "${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $format";
        });
      }
    }
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('exams').insert({
        'title_en': _titleEnController.text,
        'title_ar': _titleArController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'duration': int.parse(_durationController.text),
        'venue_en': 'Online',
        'venue_ar': 'أونلاين',
        'target_level': _selectedLevel,
        'target_year': _selectedYear,
      });
      if (mounted) {
        _titleEnController.clear();
        _titleArController.clear();
        _dateController.clear();
        _timeController.clear();
        _durationController.clear();
        setState(() {
          _selectedLevel = null;
          _selectedYear = null;
        });
        context.read<ExamsCubit>().getExams();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Exam created successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available Exams',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<ExamsCubit, ExamsState>(
                    builder: (context, state) {
                      if (state is ExamsLoaded) {
                        return ListView.builder(
                          itemCount: state.exams.length,
                          itemBuilder: (context, index) {
                            final exam = state.exams[index];
                            return ListTile(
                              title: Text(exam.subjectEn,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Cairo')),
                              subtitle: Text('${exam.date} @ ${exam.time}',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontFamily: 'Cairo')),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_task,
                                        color: Colors.cyanAccent),
                                    onPressed: () =>
                                        _showQuestionsDialog(context, exam),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () async {
                                      await Supabase.instance.client
                                          .from('exams')
                                          .delete()
                                          .eq('id', exam.id);
                                      context.read<ExamsCubit>().getExams();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(
                        _titleEnController, 'Exam Title (EN)', Icons.quiz),
                    const SizedBox(height: 12),
                    _buildTextField(
                        _titleArController, 'Exam Title (AR)', Icons.quiz),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildTextField(_dateController, 'Select Date',
                            Icons.calendar_today,
                            readOnly: true),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: _buildTextField(
                            _timeController, 'Select Time', Icons.access_time,
                            readOnly: true),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(_durationController, 'Duration (Min)',
                        Icons.hourglass_bottom),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      'المرحلة الدراسية',
                      _levels.map((e) => e['value']!).toList(),
                      (val) {
                        setState(() {
                          _selectedLevel = val;
                          _selectedYear = null;
                        });
                      },
                      _selectedLevel,
                      Icons.school,
                      itemLabels: _levels.map((e) => e['label']!).toList(),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedLevel != null &&
                        _years.containsKey(_selectedLevel))
                      _buildDropdownField(
                        'السنة الدراسية',
                        _years[_selectedLevel!]!
                            .map((e) => e.toString())
                            .toList(),
                        (val) {
                          setState(() => _selectedYear = int.tryParse(val!));
                        },
                        _selectedYear?.toString(),
                        Icons.calendar_today,
                        itemLabels: _years[_selectedLevel!]!
                            .map((e) => _getYearLabel(_selectedLevel!, e))
                            .toList(),
                      ),
                    const SizedBox(height: 24),
                    _buildAdminButton(
                      label: 'Create Exam',
                      onPressed: _saveExam,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestionsDialog(BuildContext context, ExamModel exam) {
    showDialog(
      context: context,
      builder: (context) => _AddQuestionDialog(examId: exam.id),
    );
  }
}

class _AddQuestionDialog extends StatefulWidget {
  final String examId;
  const _AddQuestionDialog({required this.examId});

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qEnController = TextEditingController();
  final _qArController = TextEditingController();
  final _optAController = TextEditingController();
  final _optBController = TextEditingController();
  final _optCController = TextEditingController();
  final _optDController = TextEditingController();
  int _correctIndex = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Add Question',
          style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  _qEnController, 'Question (EN)', Icons.question_mark),
              const SizedBox(height: 10),
              _buildTextField(
                  _qArController, 'Question (AR)', Icons.question_mark),
              const SizedBox(height: 10),
              _buildTextField(
                  _optAController, 'Option A', Icons.circle_outlined),
              const SizedBox(height: 10),
              _buildTextField(
                  _optBController, 'Option B', Icons.circle_outlined),
              const SizedBox(height: 10),
              _buildTextField(
                  _optCController, 'Option C', Icons.circle_outlined),
              const SizedBox(height: 10),
              _buildTextField(
                  _optDController, 'Option D', Icons.circle_outlined),
              const SizedBox(height: 20),
              const Text('Correct Answer:',
                  style: TextStyle(color: Colors.white70)),
              DropdownButton<int>(
                dropdownColor: Colors.black,
                value: _correctIndex,
                items: const [
                  DropdownMenuItem(
                      value: 0,
                      child: Text('A', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 1,
                      child: Text('B', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 2,
                      child: Text('C', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 3,
                      child: Text('D', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) => setState(() => _correctIndex = val!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        _buildAdminButton(
          label: 'Add',
          onPressed: _isLoading ? null : _submit,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final options = [
        _optAController.text,
        _optBController.text,
        _optCController.text,
        _optDController.text,
      ];
      await Supabase.instance.client.from('questions').insert({
        'exam_id': widget.examId,
        'question_text_en': _qEnController.text,
        'question_text_ar': _qArController.text,
        'options': options,
        'correct_option_index': _correctIndex,
        'correct_answer': options[_correctIndex],
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// --- USER MANAGEMENT ---

class _UserManagementView extends StatefulWidget {
  const _UserManagementView();

  @override
  State<_UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<_UserManagementView> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = []; // 🔍 Filtered list
  final _searchController = TextEditingController(); // 🔍 Search Controller
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    // Listen to search changes
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = (user['full_name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .order('full_name', ascending: true);

      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response);
          _filteredUsers = _users; // Initialize filtered list
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateAcademicYear(String userId, int? year) async {
    try {
      await Supabase.instance.client
          .from('user_profiles')
          .update({'academic_year': year}).eq('id', userId);

      // Optimistic Update
      setState(() {
        final index = _users.indexWhere((u) => u['id'] == userId);
        if (index != -1) {
          _users[index]['academic_year'] = year;
          _filterUsers();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Academic year updated'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      debugPrint("Error updating academic year: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleSubscription(String userId, bool currentValue) async {
    final newValue = !currentValue;
    try {
      debugPrint("Toggling subscription for $userId to $newValue");

      // 1. Optimistic Update (Immediate UI feedback)
      setState(() {
        final index = _users.indexWhere((u) => u['id'] == userId);
        if (index != -1) {
          final updatedUser = Map<String, dynamic>.from(_users[index]);
          updatedUser['is_subscribed'] = newValue;
          _users[index] = updatedUser;
          _filterUsers(); // Re-apply filter to update UI
        }
      });

      // 2. Perform DB Update
      await Supabase.instance.client
          .from('user_profiles')
          .update({'is_subscribed': newValue}) // STRICT Update
          .eq('id', userId);

      debugPrint("DB Update Successful");
    } catch (e) {
      // Revert Optimistic Update on Failure
      setState(() {
        final index = _users.indexWhere((u) => u['id'] == userId);
        if (index != -1) {
          final updatedUser = Map<String, dynamic>.from(_users[index]);
          updatedUser['is_subscribed'] = newValue;
          _users[index] = updatedUser;
          _filterUsers(); // Re-apply filter to update UI
        }
      });

      String errorMsg = e.toString();
      if (e is PostgrestException) {
        errorMsg = "Code: ${e.code}, Message: ${e.message}";
      }
      debugPrint("Toggle failed: $errorMsg");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update Failed: $errorMsg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('User Management',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: _fetchUsers,
                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                tooltip: 'Refresh List',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 🔍 Search Bar
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
            decoration: InputDecoration(
              hintText: 'Search by Name or Email...',
              hintStyle:
                  const TextStyle(color: Colors.white54, fontFamily: 'Cairo'),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_errorMessage',
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _fetchUsers,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Retry',
                                  style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? const Center(
                            child: Text('No users found matching query',
                                style: TextStyle(color: Colors.white54)))
                        : ListView.separated(
                            itemCount: _filteredUsers.length,
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.white.withOpacity(0.05)),
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              final bool isSubscribed =
                                  user['is_subscribed'] ?? false;
                              return Card(
                                color: Colors.white.withOpacity(0.05),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            Colors.red.withOpacity(0.1),
                                        child: Text(
                                          (user['full_name'] ?? 'U')[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(user['full_name'] ?? 'No Name',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Cairo')),
                                            Text(
                                                user['email'] ??
                                                    'ID: ${user['id'].toString().substring(0, 8)}',
                                                style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                    fontFamily: 'Cairo')),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Academic Year Dropdown
                                      DropdownButton<int>(
                                        value: ([
                                          0,
                                          1,
                                          2,
                                          3
                                        ].contains(user['academic_year']))
                                            ? user['academic_year']
                                            : 0,
                                        dropdownColor: const Color(0xFF1E1E1E),
                                        hint: const Text("Year",
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12)),
                                        underline: Container(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Cairo',
                                            fontSize: 14),
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.white54),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 1,
                                            child: Text('1st Sec'),
                                          ),
                                          DropdownMenuItem(
                                            value: 2,
                                            child: Text('2nd Sec'),
                                          ),
                                          DropdownMenuItem(
                                            value: 3,
                                            child: Text('3rd Sec'),
                                          ),
                                          DropdownMenuItem(
                                            value: 0,
                                            child: Text('General'),
                                          ),
                                        ],
                                        onChanged: (val) => _updateAcademicYear(
                                            user['id'], val),
                                      ),
                                      const SizedBox(width: 16),
                                      Switch(
                                        value: isSubscribed,
                                        activeColor: Colors.green,
                                        inactiveThumbColor: Colors.red,
                                        onChanged: (val) => _toggleSubscription(
                                            user['id'], isSubscribed),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
