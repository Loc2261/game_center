import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/leaderboard_provider.dart';

class LeaderboardWidget extends StatelessWidget {
  final String gameType;
  final int top;
  final bool showGlobal;

  const LeaderboardWidget({
    Key? key,
    required this.gameType,
    this.top = 10,
    this.showGlobal = false,
  }) : super(key: key);

  Widget _buildRankBadge(int rank) {
    const topThreeColors = [
      Color(0xFFFFD700), // 🥇 Gold
      Color(0xFFC0C0C0), // 🥈 Silver
      Color(0xFFCD7F32), // 🥉 Bronze
    ];

    if (rank <= 3) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              topThreeColors[rank - 1],
              topThreeColors[rank - 1].withOpacity(0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: topThreeColors[rank - 1].withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              shadows: [
                Shadow(color: Colors.black38, blurRadius: 3),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 5000) return const Color(0xFF00C853); // Green
    if (score >= 3000) return const Color(0xFF2196F3); // Blue
    if (score >= 1500) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFE53935); // Red
  }

  String _formatWinRate(double winRate) {
    return '${(winRate * 100).toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);

    final leaderboard = showGlobal
        ? leaderboardProvider.globalLeaderboard.take(top).toList()
        : leaderboardProvider.gameLeaderboard.take(top).toList();

    final isLoading = leaderboardProvider.isLoading;
    final error = leaderboardProvider.errorMessage;

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.redAccent.shade200),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (showGlobal) {
                    leaderboardProvider.fetchGlobalLeaderboard(top: top);
                  } else {
                    leaderboardProvider.fetchGameLeaderboard(gameType, top: top);
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (leaderboard.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 10),
            const Text(
              'Chưa có dữ liệu bảng xếp hạng',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hãy chơi để leo top ngay nào 🎮',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // 🔹 Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                SizedBox(width: 50, child: Text('🏅', textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Người chơi', style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 60, child: Text('Trận', style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 70, child: Text('Tỷ lệ thắng', style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 70, child: Text('Điểm', style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Danh sách người chơi
          ...leaderboard.map((entry) {
            final isTopThree = entry.rank <= 3;
            final bgGradient = isTopThree
                ? LinearGradient(
              colors: [
                Colors.white,
                Colors.blue.shade50.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                gradient: bgGradient,
                color: bgGradient == null ? Colors.white : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: _buildRankBadge(entry.rank),
                title: Text(
                  entry.user.username.isEmpty ? 'Người chơi ẩn danh' : entry.user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isTopThree ? Colors.blue[800] : Colors.grey[800],
                  ),
                ),
                subtitle: Text(
                  '${entry.gamesPlayed} trận',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatWinRate(entry.winRate),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.totalScore}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(entry.totalScore),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
