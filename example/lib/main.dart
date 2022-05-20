import 'package:flutter/material.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
          ),
          useMaterial3: true),
      home: const MyHomePage(title: 'Smooth Video Progress'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final VideoPlayerController _controller;
  Size _videoSize = Size(1, 1);

  @override
  void initState() {
    _controller = VideoPlayerController.network(
      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    _controller.setLooping(true);
    _controller.setVolume(0);
    _initVideoPlayerController(_controller);
    super.initState();
  }

  Future<void> _initVideoPlayerController(
      VideoPlayerController controller) async {
    await _controller.initialize();
    await _controller.play();
    setState(() {
      _videoSize = _controller.value.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoSize.aspectRatio,
                  child: VideoPlayer(
                    _controller,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Without SmoothVideoProgress:",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) => _VideoProgressSlider(
                      position: value.position,
                      duration: value.duration,
                      controller: _controller,
                      swatch: Colors.red,
                    ),
                  ),
                  const Divider(
                    height: 16,
                  ),
                  Text(
                    "With SmoothVideoProgress:",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SmoothVideoProgress(
                    controller: _controller,
                    builder: (context, position, duration, _) =>
                        _VideoProgressSlider(
                      position: position,
                      duration: duration,
                      controller: _controller,
                      swatch: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _VideoProgressSlider extends StatelessWidget {
  const _VideoProgressSlider({
    super.key,
    required this.position,
    required this.duration,
    required this.controller,
    required this.swatch,
  });

  final Duration position;
  final Duration duration;
  final VideoPlayerController controller;
  final Color swatch;

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.clamp(0, max).toDouble();
    return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: swatch),
        useMaterial3: true,
      ),
      child: Slider(
        min: 0,
        max: max,
        value: value,
        onChanged: (value) =>
            controller.seekTo(Duration(milliseconds: value.toInt())),
        onChangeStart: (_) => controller.pause(),
        onChangeEnd: (_) => controller.play(),
      ),
    );
  }
}
