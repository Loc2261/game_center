import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leaderboard_provider.dart';


class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  String _selectedGameType = 'global';
  final List<String> _gameTypes = ['global', 'caro'];
  final List<String> _gameTypeNames = ['All Games', 'Caro Game'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLeaderboard());
  }

  Future<void> _loadLeaderboard() async {
    final provider = Provider.of<LeaderboardProvider>(context, listen: false);
    if (_selectedGameType == 'global') {
      await provider.fetchGlobalLeaderboard(top: 20);
    } else {
      await provider.fetchGameLeaderboard(_selectedGameType, top: 20);
    }
  }

  Widget _buildRankBadge(int rank) {
    const topColors = [
      Color(0xFFFFD700), // Gold
      Color(0xFFC0C0C0), // Silver
      Color(0xFFCD7F32), // Bronze
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: rank <= 3
            ? LinearGradient(
          colors: [
            topColors[rank - 1],
            topColors[rank - 1].withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Colors.white, Color(0xFFE3E3E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          if (rank <= 3)
            BoxShadow(
              color: topColors[rank - 1].withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: rank <= 3 ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 5000) return const Color(0xFF4CAF50);
    if (score >= 3000) return const Color(0xFF2196F3);
    if (score >= 1500) return const Color(0xFFFFA726);
    return const Color(0xFFF44336);
  }

  String _formatWinRate(double rate) =>
      '${(rate * 100).toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    final leaderboard = _selectedGameType == 'global'
        ? leaderboardProvider.globalLeaderboard
        : leaderboardProvider.gameLeaderboard;

    final isLoading = leaderboardProvider.isLoading;
    final error = leaderboardProvider.errorMessage;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "🏆 Leaderboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLeaderboard,
        color: Colors.blueAccent,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 220,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF6A1B9A), Color(0xFF00BCD4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(color: Colors.black.withOpacity(0.1)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_gameTypes.length, (i) {
                            final selected =
                                _selectedGameType == _gameTypes[i];
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedGameType = _gameTypes[i]);
                                _loadLeaderboard();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  _gameTypeNames[i],
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.blue[800]
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
              )
            else if (error.isNotEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final entry = leaderboard[i];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: _buildRankBadge(entry.rank),
                        title: Text(
                          entry.user.username.isEmpty
                              ? 'Anonymous'
                              : entry.user.username,
                          style: TextStyle(
                            fontWeight: entry.rank <= 3
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: entry.rank <= 3
                                ? Colors.blue[800]
                                : Colors.grey[800],
                          ),
                        ),
                        subtitle: Text(
                          '🎮 ${entry.gamesPlayed} games • Win rate: ${_formatWinRate(entry.winRate)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Text(
                          '${entry.totalScore} pts',
                          style: TextStyle(
                            color: _getScoreColor(entry.totalScore),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: leaderboard.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
