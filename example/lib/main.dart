import 'dart:async';

import 'package:cast_ui/cast_ui.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cast UI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    CastUiUtil().init('B6DF242C');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: const Text(
          'Cast UI Demo',
        ),
        actions: const [
          ChromecastUiButton(),
        ],
      ),
      body: StreamBuilder<bool>(
        stream: CastUiUtil().hasActiveSessionStream,
        builder: (context, snapshot) {
          final hasActiveCastConnection = snapshot.data ?? false;
          return ListView(
            children: [
              VideoListItem(
                onClick: (data) => onClickVideo(
                  data: data,
                  hasActiveCastConnection: hasActiveCastConnection,
                ),
                data: VideoListItemData(
                  posterUrl: 'https://raw.githubusercontent.com/vanlooverenkoen/flutter_cast_ui/master/supporting-files/big-buck-bunny.jpeg',
                  title: 'Big Buck Bunny',
                  url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/big_buck_bunny_1080p.mp4',
                ),
                hasActiveCastConnection: hasActiveCastConnection,
              ),
              VideoListItem(
                onClick: (data) => onClickVideo(
                  data: data,
                  hasActiveCastConnection: hasActiveCastConnection,
                ),
                data: VideoListItemData(
                  posterUrl: 'https://raw.githubusercontent.com/vanlooverenkoen/flutter_cast_ui/master/supporting-files/hot-air-balloon.png',
                  title: 'Hot Air Balloons',
                  url: 'https://raw.githubusercontent.com/vanlooverenkoen/flutter_cast_ui/master/supporting-files/hot-air-balloon.mp4',
                  subtitleUrl: 'https://raw.githubusercontent.com/vanlooverenkoen/flutter_cast_ui/master/supporting-files/test.vtt',
                  subtitleContentType: 'text/vtt',
                ),
                hasActiveCastConnection: hasActiveCastConnection,
              ),
              VideoListItem(
                onClick: (data) => onClickVideo(
                  data: data,
                  hasActiveCastConnection: hasActiveCastConnection,
                ),
                data: VideoListItemData(
                  posterUrl: 'https://raw.githubusercontent.com/vanlooverenkoen/flutter_cast_ui/master/supporting-files/city.png',
                  title: 'City',
                  url: 'https://raw.githubusercontent.com/vanlooverenkoen/flutter_cast_ui/master/supporting-files/city.mp4',
                  subtitleUrl: 'https://raw.githubusercontent.com/vanlooverenkoen/flutter_cast_ui/master/supporting-files/srt.vtt',
                  subtitleContentType: 'text/plain', //Not supported by chromecast
                ),
                hasActiveCastConnection: hasActiveCastConnection,
              ),
            ],
          );
        },
      ),
    );
  }

  void onClickVideo({
    required VideoListItemData data,
    required bool hasActiveCastConnection,
  }) {
    if (hasActiveCastConnection) {
      CastUiUtil().startPlayingStream(
        url: data.url,
        title: data.title,
        posterUrl: data.posterUrl,
        subtitleUrl: data.subtitleUrl,
        subtitleContentType: data.subtitleContentType,
      );
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlayerScreen(url: data.url, subtitleUrl: data.subtitleUrl)));
    }
  }
}

class VideoListItem extends StatelessWidget {
  final ValueChanged<VideoListItemData> onClick;
  final VideoListItemData data;
  final bool hasActiveCastConnection;

  const VideoListItem({
    required this.onClick,
    required this.data,
    required this.hasActiveCastConnection,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(data.posterUrl),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => onClick(data),
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Icon(
                hasActiveCastConnection ? Icons.cast_rounded : Icons.play_arrow,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VideoListItemData {
  final String title;
  final String posterUrl;
  final String url;
  final String? subtitleUrl;
  final String? subtitleContentType;

  VideoListItemData({
    required this.title,
    required this.posterUrl,
    required this.url,
    this.subtitleUrl,
    this.subtitleContentType,
  });
}

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final String? subtitleUrl;

  const VideoPlayerScreen({
    required this.url,
    this.subtitleUrl,
    Key? key,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url, closedCaptionFile: _getClosedCaptionFile(widget.subtitleUrl))
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  Future<ClosedCaptionFile> _getClosedCaptionFile(String? subtitleUrl) async {
    if (subtitleUrl == null) return SubRipCaptionFile('');
    try {
      final data = await http.get(Uri.parse(subtitleUrl));
      final srtContent = data.body.toString();
      return SubRipCaptionFile(srtContent);
    } catch (e, stack) {
      print('Failed to get subtitles for $subtitleUrl\n$e\n$stack');
      return SubRipCaptionFile('');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(_controller),
                    if (widget.subtitleUrl != null) ...[
                      PlayerUpdater(
                        builder: (context) => ClosedCaption(
                          text: _controller.value.caption.text,
                          textStyle: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

class PlayerUpdater extends StatefulWidget {
  final WidgetBuilder builder;

  const PlayerUpdater({
    required this.builder,
  });

  @override
  _PlayerUpdaterState createState() => _PlayerUpdaterState();
}

class _PlayerUpdaterState extends State<PlayerUpdater> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
