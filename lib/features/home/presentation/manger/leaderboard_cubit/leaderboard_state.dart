import 'package:itqan_academy/features/home/data/models/leaderboard_user_model.dart';

abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardUser> topUsers;
  final LeaderboardUser? currentUser; // Contains rank and score

  LeaderboardLoaded({required this.topUsers, this.currentUser});
}

class LeaderboardError extends LeaderboardState {
  final String message;
  LeaderboardError(this.message);
}
