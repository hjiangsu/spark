import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spark/core/theme/bloc/theme_bloc.dart';

class ColorSchemeOption {
  String label;
  String value;
  MaterialColor color;

  ColorSchemeOption({required this.label, required this.value, required this.color});
}

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  bool isLoading = true;

  bool useDarkTheme = true;
  String? colorScheme;

  double _fontSize = 250;

  void setPreferences(attribute, value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (attribute) {
      case 'useDarkTheme':
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool _useDarkTheme = prefs.getBool('useDarkTheme') ?? true;
        await prefs.setBool('useDarkTheme', !_useDarkTheme);
        setState(() => useDarkTheme = !useDarkTheme);
        context.read<ThemeBloc>().add(ThemeRefreshed());
        break;
      case 'colorScheme':
        prefs.setString('colorScheme', value);
        setState(() => colorScheme = value);
        context.read<ThemeBloc>().add(ThemeRefreshed());
        break;
      case 'fontSize':
        prefs.setDouble('fontSize', value);
        setState(() => _fontSize = value);
        context.read<ThemeBloc>().add(ThemeRefreshed());
        break;
    }
  }

  void _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      useDarkTheme = prefs.getBool('useDarkTheme') ?? true;
      colorScheme = prefs.getString('colorScheme') ?? "blueGrey";
      _fontSize = prefs.getDouble('fontSize') ?? 250;
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
        title: const Text('Appearance'),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: appearanceSettings(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget appearanceSettings() {
    final theme = Theme.of(context);
    final fontSizeScale = context.read<ThemeBloc>().state.fontSizeScale;

    List<ColorSchemeOption> colorSchemeOptions = <ColorSchemeOption>[
      ColorSchemeOption(label: "Pink", value: "pink", color: Colors.pink),
      ColorSchemeOption(label: "Red", value: "red", color: Colors.red),
      ColorSchemeOption(label: "Deep Orange", value: "deepOrange", color: Colors.deepOrange),
      ColorSchemeOption(label: "Orange", value: "orange", color: Colors.orange),
      ColorSchemeOption(label: "Amber", value: "amber", color: Colors.amber),
      ColorSchemeOption(label: "Yellow", value: "yellow", color: Colors.yellow),
      ColorSchemeOption(label: "Lime", value: "lime", color: Colors.lime),
      ColorSchemeOption(label: "Light Green", value: "lightGreen", color: Colors.lightGreen),
      ColorSchemeOption(label: "Green", value: "green", color: Colors.green),
      ColorSchemeOption(label: "Teal", value: "teal", color: Colors.teal),
      ColorSchemeOption(label: "Cyan", value: "cyan", color: Colors.cyan),
      ColorSchemeOption(label: "Light Blue", value: "lightBlue", color: Colors.lightBlue),
      ColorSchemeOption(label: "Blue", value: "blue", color: Colors.blue),
      ColorSchemeOption(label: "Indigo", value: "indigo", color: Colors.indigo),
      ColorSchemeOption(label: "Purple", value: "purple", color: Colors.purple),
      ColorSchemeOption(label: "Deep Purple", value: "deepPurple", color: Colors.deepPurple),
      ColorSchemeOption(label: "Blue Grey", value: "blueGrey", color: Colors.blueGrey),
      ColorSchemeOption(label: "Brown", value: "brown", color: Colors.brown),
      ColorSchemeOption(label: "Grey", value: "grey", color: Colors.grey),
    ];

    ColorSchemeOption _colorScheme = colorSchemeOptions.firstWhere((element) => element.value == colorScheme);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Theme',
            style: theme.textTheme.titleLarge,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(useDarkTheme ? Icons.dark_mode : Icons.dark_mode_outlined),
                const SizedBox(width: 8.0),
                Text(
                  'Use dark theme',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            Switch(
              value: useDarkTheme,
              onChanged: (bool value) {
                HapticFeedback.lightImpact();
                setPreferences('useDarkTheme', value);
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_rounded),
                const SizedBox(width: 8.0),
                Text(
                  'Palette',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            TextButton(
              child: Row(
                children: [
                  Text(
                    _colorScheme.label,
                    style: theme.textTheme.bodyMedium!.copyWith(color: _colorScheme.color),
                  ),
                  const SizedBox(width: 12.0),
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _colorScheme.color),
                  ),
                ],
              ),
              onPressed: () {
                showModalBottomSheet<void>(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.48,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24.0, bottom: 12.0, left: 16.0, right: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Color Scheme',
                                style: theme.textTheme.titleLarge!.copyWith(),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: SingleChildScrollView(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: colorSchemeOptions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final ColorSchemeOption colorSchemeOption = colorSchemeOptions[index];
                                  return ListTile(
                                    title: Text(
                                      colorSchemeOption.label,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    leading: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: colorSchemeOption.color),
                                    ),
                                    onTap: () {
                                      setPreferences('colorScheme', colorSchemeOption.value);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0, top: 16.0),
          child: Text(
            'Accessibility',
            style: theme.textTheme.titleLarge,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.text_fields_rounded),
                const SizedBox(width: 8.0),
                Text(
                  'Font Size',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            Slider(
              value: _fontSize ?? 200.0,
              min: 200,
              max: 400,
              divisions: 4,
              label: (_fontSize.round() / 250).toString(),
              onChanged: (double value) => setState(() => _fontSize = value),
              onChangeEnd: (double value) => setPreferences('fontSize', value),
            ),
          ],
        ),
      ],
    );
  }
}