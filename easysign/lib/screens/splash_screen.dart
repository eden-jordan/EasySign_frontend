import 'package:easysign/screens/home_screen.dart';
import 'package:easysign/screens/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/splash.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();

        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration &&
              !_navigated) {
            _navigated = true;
            _redirectUser();
          }
        });
      });
  }

  Future<void> _redirectUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => token != null && token.isNotEmpty
            ? const HomeScreen()
            : const StartScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
