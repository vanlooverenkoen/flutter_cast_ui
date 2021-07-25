import 'package:cast_ui/cast_ui.dart';
import 'package:flutter/material.dart';
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
        stream: CastUiUtil().hasActiveSession,
        builder: (context, snapshot) {
          final hasActiveCastConnection = snapshot.data ?? false;
          return ListView(
            children: [
              Stack(
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/proxy/9TzV9kZS8MOWNEGHfW63ggra3GXsDipu57aqkbvWkYzDDy81cIebGDnqw5qxsHftlPAv_yNAvlZ5kgB6kG4aaVTebGYk4tAKHnBaBnfL0j_L028lXI2CwYk3IcQMW2d1',
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => onClickVideo(
                        url: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/big_buck_bunny_1080p.mp4',
                        hasActiveCastConnection: hasActiveCastConnection,
                      ),
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.play_arrow,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Image.network(
                    'https://github.com/vanlooverenkoen/flutter_cast_ui/raw/master/supporting-files/hot-air-balloon.png',
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => onClickVideo(
                        url: 'https://github.com/vanlooverenkoen/flutter_cast_ui/raw/master/supporting-files/hot-air-balloon.mp4',
                        hasActiveCastConnection: hasActiveCastConnection,
                      ),
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.play_arrow,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Image.network(
                    'https://github.com/vanlooverenkoen/flutter_cast_ui/raw/master/supporting-files/city.png',
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => onClickVideo(
                        url: 'https://github.com/vanlooverenkoen/flutter_cast_ui/raw/master/supporting-files/city.mp4',
                        hasActiveCastConnection: hasActiveCastConnection,
                      ),
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.play_arrow,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void onClickVideo({required String url, required bool hasActiveCastConnection}) {
    if (hasActiveCastConnection) {
      print('Implement the cast implementation. And show the player');
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlayerScreen(url: url)));
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({
    required this.url,
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
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
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
                child: VideoPlayer(_controller),
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
