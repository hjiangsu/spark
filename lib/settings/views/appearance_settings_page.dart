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

  double _fontSize = 3;

  void setPreferences(attribute, value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (attribute) {
      case 'useDarkTheme':
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool _useDarkTheme = prefs.getBool('useDarkTheme') ?? true;
        await prefs.setBool('useDarkTheme', !_useDarkTheme);
        setState(() => useDarkTheme = _useDarkTheme);
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Theme',
            style: theme.textTheme.labelLarge!.copyWith(fontSize: 18.0),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(useDarkTheme ? Icons.dark_mode : Icons.dark_mode_outlined),
                const SizedBox(width: 8.0),
                const Text('Use dark theme'),
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
            const Row(
              children: [
                Icon(Icons.palette_rounded),
                SizedBox(width: 8.0),
                Text('Palette'),
              ],
            ),
            DropdownButton<String>(
              value: colorScheme,
              underline: Container(),
              onChanged: (String? value) {
                setPreferences('colorScheme', value);
              },
              items: colorSchemeOptions.map<DropdownMenuItem<String>>((ColorSchemeOption colorSchemeOption) {
                return DropdownMenuItem<String>(
                  value: colorSchemeOption.value,
                  child: Row(
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: colorSchemeOption.color),
                      ),
                      const SizedBox(width: 8.0),
                      Text(colorSchemeOption.label),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
          child: Text(
            'Accessibility',
            style: theme.textTheme.labelLarge!.copyWith(fontSize: 18.0),
          ),
        ),
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     const Row(
        //       children: [
        //         Icon(Icons.text_fields_rounded),
        //         SizedBox(width: 8.0),
        //         Text('Font Size'),
        //       ],
        //     ),
        //     Slider(
        //       value: _fontSize,
        //       max: 5,
        //       divisions: 4,
        //       label: _fontSize.round().toString(),
        //       onChanged: (double value) {
        //         setPreferences('fontSize', value);
        //       },
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
