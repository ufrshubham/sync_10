import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({required this.onBackPressed, super.key});

  static const id = 'Leaderboard';
  final VoidCallback? onBackPressed;
  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _leaderboardEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final response = await _supabase
          .from('Leaderboard')
          .select()
          .order('Time', ascending: true)
          .limit(5);

      setState(() {
        _leaderboardEntries = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching leaderboard: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _leaderboardEntries.isEmpty
              ? const Center(child: Text('No leaderboard data available.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _leaderboardEntries.length,
                itemBuilder: (context, index) {
                  final entry = _leaderboardEntries[index];
                  return Card(
                    child: ListTile(
                      leading: Text('#${index + 1}'),
                      title: Text((entry['DuoName'] as String?) ?? 'Unknown'),
                      subtitle: Text('Time: ${_formatTime(entry['Time'])}'),
                    ),
                  );
                },
              ),
    );
  }

  String _formatTime(entry) {
    if (entry is int) {
      final minutes = (entry ~/ 60).toString().padLeft(2, '0');
      final seconds = (entry % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    } else {
      return '00:00';
    }
  }
}
