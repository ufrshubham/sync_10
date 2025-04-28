import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
    this.onPlayPressed,
    this.onSettingsPressed,
    this.onLeaderboardPressed,
    this.onCreditsPressed,
  });

  static const id = 'MainMenu';

  final VoidCallback? onPlayPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLeaderboardPressed;
  final VoidCallback? onCreditsPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('SYNC:[10]', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 15),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onPlayPressed,
                child: const Text('Play'),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onSettingsPressed,
                child: const Text('Settings'),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onLeaderboardPressed,
                child: const Text('Leaderboard'),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onCreditsPressed,
                child: const Text('Credits'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
