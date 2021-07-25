import 'package:cast_ui/cast_ui.dart';
import 'package:flutter/material.dart';
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
        MaterialButton(
          onPressed: () => CastUiUtil().stopSession(),
          child: Text('STOP SESSION'),
        ),
      ],
    );
  }
}
