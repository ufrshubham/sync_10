import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({
    required this.musicValueListenable,
    required this.sfxValueListenable,
    super.key,
    this.onMusicValueChanged,
    this.onSfxValueChanged,
    this.onBackPressed,
    this.gamepadSetupPressed,
  });

  static const id = 'Settings';

  final ValueListenable<bool> musicValueListenable;
  final ValueListenable<bool> sfxValueListenable;

  final ValueChanged<bool>? onMusicValueChanged;
  final ValueChanged<bool>? onSfxValueChanged;
  final VoidCallback? onBackPressed;
  final VoidCallback? gamepadSetupPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 15),
            SizedBox(
              width: 200,
              child: ValueListenableBuilder<bool>(
                valueListenable: musicValueListenable,
                builder: (BuildContext context, bool value, Widget? child) {
                  return SwitchListTile(
                    value: value,
                    onChanged: onMusicValueChanged,
                    title: child,
                  );
                },
                child: const Text('Music'),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 200,
              child: ValueListenableBuilder<bool>(
                valueListenable: sfxValueListenable,
                builder: (BuildContext context, bool value, Widget? child) {
                  return SwitchListTile(
                    value: value,
                    onChanged: onSfxValueChanged,
                    title: child,
                  );
                },
                child: const Text('Sfx'),
              ),
            ),
            const SizedBox(height: 5),
            if (kIsWeb)
              const SizedBox(height: 5)
            else
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  onPressed: gamepadSetupPressed,
                  child: const Text('Gamepad Setup'),
                ),
              ),
            const SizedBox(height: 5),
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
