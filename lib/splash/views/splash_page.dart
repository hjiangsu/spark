import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  final String? splashText;

  const SplashPage({super.key, this.splashText});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double opacityLevel = 0.0;

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  @override
  void initState() {
    super.initState();
    _changeOpacity();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: AnimatedOpacity(
        opacity: opacityLevel,
        duration: const Duration(milliseconds: 500),
        child: Container(
          color: const Color.fromRGBO(18, 18, 18, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo_transparent.png',
                width: 230,
                height: 230,
              ),
              const SizedBox(height: 8.0),
              const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              ),
              const SizedBox(height: 16.0),
              if (widget.splashText != null) Text(widget.splashText!, style: theme.textTheme.labelLarge?.copyWith(color: theme.hintColor, fontSize: 16.0)),
            ],
          ),
        ),
      ),
    );
  }
}
