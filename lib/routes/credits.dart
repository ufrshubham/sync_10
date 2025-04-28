import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Credits extends StatelessWidget {
  const Credits({super.key, this.onBackPressed});

  static const id = 'Credits';

  final VoidCallback? onBackPressed;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Credits', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _launchUrl('https://ufrshubham.itch.io/'),
              child: const Text(
                'Programming: DevKage (Shubham)',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => _launchUrl('https://respawnedplayer.itch.io/'),
              child: const Text(
                'Art: RespawnedPlayer (Shivangi)',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => _launchUrl('https://ufrshubham.itch.io/'),
              child: const Text(
                'Music: DevKage (Shubham)',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
