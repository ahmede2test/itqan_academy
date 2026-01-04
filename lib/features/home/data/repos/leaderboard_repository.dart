import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/features/home/data/models/leaderboard_user_model.dart';

class LeaderboardRepository {
  final SupabaseClient _supabaseClient;

  LeaderboardRepository(this._supabaseClient);

  Future<List<LeaderboardUser>> fetchLeaderboard() async {
    try {
      // 1. Fetch all exam results
      final response =
          await _supabaseClient.from('exam_results').select('user_id, score');

      final results = (response as List)
          .map((e) => {
                'user_id': e['user_id'] as String,
                'score': (e['score'] as num).toInt(),
              })
          .toList();

      // 2. Aggregate scores by user_id
      final Map<String, int> userScores = {};
      for (var result in results) {
        final userId = result['user_id'] as String;
        final score = result['score'] as int;
        userScores[userId] = (userScores[userId] ?? 0) + score;
      }

      // 3. Sort by total score descending
      final sortedUserIds = userScores.keys.toList()
        ..sort((a, b) => userScores[b]!.compareTo(userScores[a]!));

      // 4. Take top 10 (or more to handle profile fetch failures, but let's stick to simple logic for now)
      // We will fetch profiles for ALL users to be safe, or just the top 50 if the list is huge.
      // Assuming class size is manageable, let's fetch profiles for the sorted users.

      if (sortedUserIds.isEmpty) return [];

      final profilesResponse = await _supabaseClient
          .from('user_profiles')
          .select('id, full_name, avatar_url, email')
          .filter('id', 'in', sortedUserIds); // Fetch for all to match names

      final profiles = (profilesResponse as List<dynamic>);
      final Map<String, Map<String, dynamic>> profilesMap = {
        for (var p in profiles) p['id'] as String: p as Map<String, dynamic>
      };

      // 5. Build LeaderboardUser list
      List<LeaderboardUser> leaderboard = [];
      int rank = 1;

      for (var userId in sortedUserIds) {
        final profile = profilesMap[userId];
        // If profile doesn't exist (deleted user?), skip or show unknown
        // We will default to "Student" if name missing
        String name = 'Student';
        String? avatarUrl;

        if (profile != null) {
          final fullName = profile['full_name'] as String?;
          if (fullName != null && fullName.isNotEmpty) {
            name = fullName.trim();
          } else {
            // Fallback to email part if name is empty
            final email = profile['email'] as String?;
            if (email != null && email.isNotEmpty) {
              name = email.split('@')[0];
            }
          }
          avatarUrl = profile['avatar_url'] as String?;
        } else {
          // Fallback if profile not found in user_profiles, check metadata if possible?
          // For now, skip or keep as Student.
        }

        leaderboard.add(LeaderboardUser(
          userId: userId,
          name: name,
          avatarUrl: avatarUrl,
          totalScore: userScores[userId]!,
          rank: rank++,
        ));
      }

      // Return only top 10
      return leaderboard.take(10).toList();
    } catch (e) {
      // debugPrint('Leaderboard Error: $e');
      return [];
    }
  }

  Future<int> getCurrentUserRank() async {
    // This could be optimized, but reusing the logic above ensures consistency
    await fetchLeaderboard(); // This only returns top 10.
    // Wait, if I'm not in top 10, I won't know my rank.
    // I need the FULL list to find my rank.

    // Optimized: Run the aggregation again (fast enough for now) and find index.
    // Ideally, we refactor the method above to return full sorted list and UI takes top 10.

    // For now, let's rely on the separate call or refactor.
    return 0;
  }

  // Refactored to get full sorted list
  Future<List<LeaderboardUser>> fetchAllRankedUsers() async {
    try {
      final response =
          await _supabaseClient.from('exam_results').select('user_id, score');

      debugPrint(
          '📡 RAW DATABASE RESPONSE: ${(response as List).length} rows fetched');

      final results = (response as List)
          .map((e) => {
                'user_id': e['user_id'] as String,
                'score': (e['score'] as num).toInt(),
              })
          .toList();

      final Map<String, int> userScores = {};
      for (var result in results) {
        final userId = result['user_id'] as String;
        final score = result['score'] as int;
        userScores[userId] = (userScores[userId] ?? 0) + score;
      }

      final sortedUserIds = userScores.keys.toList()
        ..sort((a, b) => userScores[b]!.compareTo(userScores[a]!));

      if (sortedUserIds.isEmpty) return [];

      // Optimization: Fetch profiles only for visible range?
      // User wants "Sticky Bar: Your Rank". So we need the rank.
      // We can just find the index of currentUser in sortedUserIds + 1.

      // But we need the name/avatar for the UI list.
      // So:
      // 1. Get Sorted IDs.
      // 2. Identify Top 10 IDs.
      // 3. Identify Current User ID.
      // 4. Fetch profiles for Top 10 + Current User.

      final currentUserId = _supabaseClient.auth.currentUser?.id;
      final top10Ids = sortedUserIds.take(10).toList();
      final idsToFetch = {...top10Ids};
      if (currentUserId != null) idsToFetch.add(currentUserId);

      final profilesResponse = await _supabaseClient
          .from('user_profiles')
          .select('id, full_name, avatar_url, email')
          .filter('id', 'in', idsToFetch.toList());

      final profiles = (profilesResponse as List<dynamic>);
      final Map<String, Map<String, dynamic>> profilesMap = {
        for (var p in profiles) p['id'] as String: p as Map<String, dynamic>
      };

      List<LeaderboardUser> fullRankedList = [];
      int rank = 1;

      // we only construct LeaderboardUser objects for those we fetched profiles for (Top 10 + Self)
      // Actually, constructing the full list might be expensive if many users.
      // Let's just return a generic list, but only populate names for those we fetched?
      // Or better: Return a custom object containing "Top10" and "CurrentUserRank".

      // Let's stick to "Fetch Full List" but only mapped for the required ones.

      for (var userId in sortedUserIds) {
        // Only build full object if it's in top 10 or is me
        if (top10Ids.contains(userId) || userId == currentUserId) {
          final profile = profilesMap[userId];
          String name = 'Student';
          String? avatarUrl;

          if (profile != null) {
            final fullName = profile['full_name'] as String?;
            if (fullName != null && fullName.isNotEmpty) {
              name = fullName.trim();
            } else {
              // Fallback to email
              final email = profile['email'] as String?;
              if (email != null && email.isNotEmpty) {
                name = email.split('@')[0];
              }
            }
            avatarUrl = profile['avatar_url'] as String?;
          }

          fullRankedList.add(LeaderboardUser(
            userId: userId,
            name: name,
            avatarUrl: avatarUrl,
            totalScore: userScores[userId]!,
            rank: rank,
          ));
        } else {
          // Add a placeholder if needed, or just skip?
          // If I skip, the list index won't match rank.
          // But I am tracking 'rank' variable.
        }
        rank++;
      }

      debugPrint('📊 NUMBER OF USERS MAPPED: ${fullRankedList.length}');
      debugPrint('📊 NUMBER OF USERS MAPPED: ${fullRankedList.length}');
      return fullRankedList;
    } catch (e) {
      debugPrint('❌ LEADERBOARD ERROR: $e');
      return [];
    }
  }
}
