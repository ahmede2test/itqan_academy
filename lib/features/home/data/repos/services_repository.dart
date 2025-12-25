import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/services_models.dart';

abstract class ServicesRepository {
  // Tasks
  Future<List<UserTask>> getTasks();
  Future<void> addTask(String title);
  Future<void> toggleTask(String taskId, bool currentStatus);
  Future<void> deleteTask(String taskId);

  // Notes
  Future<List<UserNote>> getNotes();
  Future<void> addNote(String title, String content);
  Future<void> updateNote(String id, String title, String content);
  Future<void> deleteNote(String id);

  // Study Sessions
  Future<void> logStudySession(int durationMinutes);
}

class ServicesRepositoryImpl implements ServicesRepository {
  final SupabaseClient _supabaseClient;

  ServicesRepositoryImpl(this._supabaseClient);

  String get _userId => _supabaseClient.auth.currentUser!.id;

  // --- Tasks ---
  @override
  Future<List<UserTask>> getTasks() async {
    final response = await _supabaseClient
        .from('user_tasks')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => UserTask.fromJson(e)).toList();
  }

  @override
  Future<void> addTask(String title) async {
    try {
      await _supabaseClient.from('user_tasks').insert({
        'user_id': _supabaseClient.auth.currentUser!.id,
        'title': title,
        'is_completed': false,
      });
    } catch (e) {
      debugPrint('Repo Error adding task: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleTask(String taskId, bool currentStatus) async {
    await _supabaseClient.from('user_tasks').update({
      'is_completed': !currentStatus,
    }).eq('id', taskId);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _supabaseClient.from('user_tasks').delete().eq('id', taskId);
  }

  // --- Notes ---
  @override
  Future<List<UserNote>> getNotes() async {
    final response = await _supabaseClient
        .from('user_notes')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => UserNote.fromJson(e)).toList();
  }

  @override
  Future<void> addNote(String title, String body) async {
    try {
      await _supabaseClient.from('user_notes').insert({
        'user_id': _supabaseClient.auth.currentUser!.id,
        'title': title,
        'body': body,
      });
    } catch (e) {
      debugPrint('Repo Error adding note: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateNote(String id, String title, String body) async {
    await _supabaseClient.from('user_notes').update({
      'title': title,
      'body': body,
    }).eq('id', id);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _supabaseClient.from('user_notes').delete().eq('id', id);
  }

  // --- Study Sessions ---
  @override
  Future<void> logStudySession(int durationMinutes) async {
    await _supabaseClient.from('study_sessions').insert({
      'user_id': _userId,
      'duration': durationMinutes,
    });
  }
}
