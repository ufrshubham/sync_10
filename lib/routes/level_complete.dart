import 'package:flutter/material.dart';

class LevelComplete extends StatefulWidget {
  const LevelComplete({
    // required this.nStars,
    super.key,
    this.onSubmitPressed,
    this.onNextPressed,
    this.onRetryPressed,
    this.onExitPressed,
  });

  static const id = 'LevelComplete';

  // final int nStars;

  final VoidCallback? onNextPressed;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;
  final ValueChanged<String>? onSubmitPressed;

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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Icon(
              //       nStars >= 1 ? Icons.star : Icons.star_border,
              //       color: nStars >= 1 ? Colors.amber : Colors.black,
              //       size: 50,
              //     ),
              //     Icon(
              //       nStars >= 2 ? Icons.star : Icons.star_border,
              //       color: nStars >= 2 ? Colors.amber : Colors.black,
              //       size: 50,
              //     ),
              //     Icon(
              //       nStars >= 3 ? Icons.star : Icons.star_border,
              //       color: nStars >= 3 ? Colors.amber : Colors.black,
              //       size: 50,
              //     ),
              //   ],
              // ),
              const SizedBox(height: 15),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 16.0),
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Validate will return true if the form is valid, or false if
              //       // the form is invalid.
              //       if (_formKey.currentState!.validate()) {
              //         // Process data.
              //       }
              //     },
              //     child: const Text('Submit'),
              //   ),
              // ),
              SizedBox(
                width: 150,
                child: OutlinedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSubmitPressed?.call(_duoNameController.text);
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
    );
  }
}
