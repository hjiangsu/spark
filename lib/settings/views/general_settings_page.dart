import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spark/core/theme/bloc/theme_bloc.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  bool isLoading = true;

  bool videoAutoplay = true;

  void setPreferences(attribute, value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (attribute) {
      case 'videoAutoPlay':
        await prefs.setBool('videoAutoplay', value);
        context.read<ThemeBloc>().add(ThemeRefreshed());
        break;
    }
  }

  void _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      videoAutoplay = prefs.getBool('videoAutoplay') ?? true;
      isLoading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General'),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: generalSettings(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget generalSettings() {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Videos',
            style: theme.textTheme.titleLarge,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(videoAutoplay ? Icons.play_arrow_rounded : Icons.play_disabled_rounded),
                const SizedBox(width: 8.0),
                Text(
                  'Autoplay videos',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            Switch(
              value: videoAutoplay,
              onChanged: (bool value) {
                HapticFeedback.lightImpact();
                setPreferences('videoAutoPlay', value);
                setState(() => videoAutoplay = !videoAutoplay);
              },
            ),
          ],
        ),
      ],
    );
  }
}
