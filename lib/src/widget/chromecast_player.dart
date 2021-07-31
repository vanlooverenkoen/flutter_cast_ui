import 'dart:async';

import 'package:cast_ui/cast_ui.dart';
import 'package:cast_ui/src/model/media_status/media_status.dart';
import 'package:cast_ui/src/widget/chromecast_player_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChromecastPlayer extends StatefulWidget {
  final Duration? refreshInterval;

  const ChromecastPlayer({
    this.refreshInterval = const Duration(milliseconds: 500),
    Key? key,
  }) : super(key: key);

  @override
  _ChromecastPlayerState createState() => _ChromecastPlayerState();
}

class _ChromecastPlayerState extends State<ChromecastPlayer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final refreshInterval = widget.refreshInterval;
    if (refreshInterval != null) {
      _timer = Timer.periodic(
        refreshInterval,
        (timer) => CastUiUtil().getStatus(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaSessionStatus?>(
      stream: CastUiUtil().activeMediaSessionStream,
      builder: (context, data) {
        final mediaSession = data.data;
        final hasActiveMediaSession = mediaSession?.isActive ?? false;
        final isPlaying = data.data?.isPlaying ?? false;
        final isBuffering = data.data?.isBuffering ?? false;
        final media = CastUiUtil().lastActiveMedia;
        final lastActiveMediaDuration = CastUiUtil().lastActiveMediaDuration;
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
                            await CastUiUtil().scrubStreamBackwards();
                          },
                          icon: const Icon(Icons.replay_10_rounded),
                        ),
                      ),
                      if (isBuffering) ...[
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ] else ...[
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
                      ],
                      Expanded(
                        child: IconButton(
                          onPressed: () async => CastUiUtil().stopStream(),
                          icon: const Icon(Icons.stop_rounded),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: () async {
                            await CastUiUtil().scrubStreamForward();
                          },
                          icon: const Icon(Icons.forward_10_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
                ChromecastPlayerSlider(
                  value: mediaSession?.currentTime ?? 0,
                  min: 0,
                  max: lastActiveMediaDuration ?? 0,
                  onChanged: (value) => CastUiUtil().seekStream(value),
                ),
              ] else ...[
                const Spacer(),
              ],
              const SizedBox(height: 16),
              MaterialButton(
                onPressed: () async {
                  await CastUiUtil().stopSession();
                  if (!mounted) return;
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
