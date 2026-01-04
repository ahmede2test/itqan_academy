class LeaderboardUser {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int totalScore;
  final int rank;

  LeaderboardUser({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.totalScore,
    required this.rank,
  });
}
