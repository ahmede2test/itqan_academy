import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/generated/l10n.dart';
import 'package:itqan_academy/features/home/data/models/services_models.dart';
import 'package:itqan_academy/features/home/data/repos/services_repository.dart';
import 'package:itqan_academy/core/utils/app_colors.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  late final ServicesRepository _repository;
  List<UserTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = ServicesRepositoryImpl(Supabase.instance.client);
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _repository.getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _addTask(String title) async {
    if (title.isEmpty) return;
    try {
      await _repository.addTask(title);
      _fetchTasks();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error adding task: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding task: $e')));
    }
  }

  Future<void> _toggleTask(UserTask task) async {
    // Optimistic update
    final index = _tasks.indexOf(task);
    setState(() {
      _tasks[index] = UserTask(
        id: task.id,
        userId: task.userId,
        title: task.title,
        isCompleted: !task.isCompleted,
        createdAt: task.createdAt,
      );
    });

    try {
      await _repository.toggleTask(task.id, task.isCompleted);
    } catch (e) {
      // Revert on error
      _fetchTasks();
    }
  }

  Future<void> _deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      setState(() {
        _tasks.removeWhere((t) => t.id == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
    }
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title:
            const Text("Add Task", style: TextStyle(color: AppColors.primary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.primary),
          decoration: const InputDecoration(
            hintText: "Enter task name",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel,
                  style: TextStyle(color: Colors.grey[600]))),
          TextButton(
              onPressed: () => _addTask(controller.text),
              child: const Text("Add",
                  style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fallback translations if S class is missing keys
    // Assuming S.of(context).toDoList exists or using simple strings
    final title = "To-Do List";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent))
          : _tasks.isEmpty
              ? const Center(
                  child: Text("No tasks yet",
                      style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.grey.withOpacity(0.2),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                          onChanged: (_) => _toggleTask(task),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            color: task.isCompleted
                                ? Colors.grey
                                : AppColors.primary,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () => _deleteTask(task.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
