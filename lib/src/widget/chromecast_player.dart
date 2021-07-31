import 'package:cast_ui/cast_ui.dart';
import 'package:cast_ui/src/model/media_status/media_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChromecastPlayer extends StatelessWidget {
  const ChromecastPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaSessionStatus?>(
      stream: CastUiUtil().activeMediaSessionStream,
      builder: (context, data) {
        final hasActiveMediaSession = data.data?.isActive ?? false;
        final isPlaying = data.data?.isPlaying ?? false;
        final media = CastUiUtil().lastActiveMedia;
        final imageUrl = media?.metadata.images.first.url;
        return Container(
          width: double.infinity,
          child: Column(
            children: [
              if (hasActiveMediaSession) ...[
                if (imageUrl != null) ...[
                  Expanded(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                ],
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: () async {
                            await CastUiUtil().pauseStream();
                          },
                          icon: const Icon(Icons.replay_10_rounded),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: () async {
                            if (isPlaying) {
                              await CastUiUtil().pauseStream();
                            } else {
                              await CastUiUtil().resumeStream();
                            }
                          },
                          icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: () async => CastUiUtil().stopStream(),
                          icon: const Icon(Icons.stop_rounded),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: () async {
                            await CastUiUtil().resumeStream();
                          },
                          icon: const Icon(Icons.forward_10_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Spacer(),
              ],
              const SizedBox(height: 16),
              MaterialButton(
                onPressed: () async {
                  await CastUiUtil().stopSession();
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text('STOP CASTING'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
