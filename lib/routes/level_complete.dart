import 'package:flutter/material.dart';

typedef OnSubmitCallback = Future<bool> Function(String, int);

class LevelComplete extends StatefulWidget {
  const LevelComplete({
    required this.levelTime,
    super.key,
    this.onSubmitPressed,
    this.onRetryPressed,
    this.onExitPressed,
  });

  static const id = 'LevelComplete';

  final int levelTime;

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
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Congratulations!', style: TextStyle(fontSize: 30)),
                const SizedBox(height: 15),
                Text(
                  '''Your level time was ${widget.levelTime} seconds!''',
                  style: const TextStyle(fontSize: 20),
                ),
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
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _duoNameController,
                  builder: (context, value, child) {
                    return SizedBox(
                      width: 150,
                      child: OutlinedButton(
                        onPressed:
                            value.text.isNotEmpty
                                ? () {
                                  if (_formKey.currentState!.validate()) {
                                    widget.onSubmitPressed
                                        ?.call(
                                          _duoNameController.text,
                                          widget.levelTime,
                                        )
                                        .then((result) {
                                          if (result) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Submitted successfully!',
                                                ),
                                              ),
                                            );

                                            widget.onExitPressed?.call();
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Submission failed!',
                                                ),
                                              ),
                                            );
                                          }
                                        });
                                  }
                                }
                                : null,
                        child: const Text('Submit'),
                      ),
                    );
                  },
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
