import 'package:flutter/widgets.dart';

class ChromecastPlayer extends StatelessWidget {
  const ChromecastPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Player'),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }
}
