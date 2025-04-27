import 'package:flutter/material.dart';

typedef OnSubmitCallback = void Function(String, int);

class LevelComplete extends StatefulWidget {
  const LevelComplete({
    required this.levelTime,
    super.key,
    this.onSubmitPressed,
    this.onNextPressed,
    this.onRetryPressed,
    this.onExitPressed,
  });

  static const id = 'LevelComplete';

  final int levelTime;

  final VoidCallback? onNextPressed;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;
  final OnSubmitCallback? onSubmitPressed;

  @override
  State<LevelComplete> createState() => _LevelCompleteState();
}

class _LevelCompleteState extends State<LevelComplete> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _duoNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(210, 229, 238, 238),
      body: Form(
        key: _formKey,
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Level Completed', style: TextStyle(fontSize: 30)),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _duoNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your duo name',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmitPressed?.call(
                          _duoNameController.text,
                          widget.levelTime,
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: widget.onRetryPressed,
                    child: const Text('Retry'),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: widget.onExitPressed,
                    child: const Text('Exit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
