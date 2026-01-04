import 'package:itqan_academy/features/home/data/models/leaderboard_user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:itqan_academy/features/home/data/repos/leaderboard_repository.dart';
import 'package:itqan_academy/features/home/presentation/manger/leaderboard_cubit/leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final LeaderboardRepository _repository;

  LeaderboardCubit(this._repository) : super(LeaderboardInitial());

  static LeaderboardCubit get(context) => BlocProvider.of(context);

  Future<void> fetchLeaderboard() async {
    emit(LeaderboardLoading());
    try {
      final allRanked = await _repository.fetchAllRankedUsers();

      // Top 10 are the first 10 elements in the list that have full data
      // Actually my repo logic returns a list containing ONLY Top 10 and Current User.
      // They are added in rank order.

      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      final top10 = allRanked.where((u) => u.rank <= 10).toList();

      // Find current user in the list
      final currentUser = allRanked.firstWhere(
        (u) => u.userId == currentUserId,
        orElse: () => LeaderboardUser(
            userId: currentUserId ?? '',
            name: 'Me',
            totalScore: 0,
            rank: 0), // Rank 0 means unranked/no score
      );

      // If user has no score (rank 0), he might not be in the list returned by repo if I logic'd it strictly.
      // But my repo logic only adds if in top 10 OR is current user AND has score.
      // If user has NO score, they won't be in 'exam_results', so repo returns nothing for them.

      emit(LeaderboardLoaded(
          topUsers: top10,
          currentUser: currentUser.rank == 0 ? null : currentUser));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}
