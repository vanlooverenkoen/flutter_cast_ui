import 'package:cast_ui/cast_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChromecastPlayer extends StatelessWidget {
  const ChromecastPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: CastUiUtil().hasActiveMediaSessionStream,
      builder: (context, data) {
        final hasActiveMediaSession = data.data ?? false;
        return Column(
          children: [
            const Text('Player'),
            if (hasActiveMediaSession) ...[
              MaterialButton(
                onPressed: () async {
                  await CastUiUtil().pauseStream();
                },
                child: const Text('PAUSE SESSION'),
              ),
              MaterialButton(
                onPressed: () async {
                  await CastUiUtil().resumeStream();
                },
                child: const Text('RESUME STREAM'),
              ),
              MaterialButton(
                onPressed: () async {
                  await CastUiUtil().stopStream();
                },
                child: const Text('STOP SESSION'),
              ),
            ],
            const SizedBox(height: 24),
            MaterialButton(
              onPressed: () async {
                await CastUiUtil().stopSession();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('STOP SESSION'),
            ),
          ],
        );
      },
    );
  }
}
