import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:spark/settings/views/appearance_settings_page.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        centerTitle: false,
        title: AutoSizeText(
          'Settings',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: ListView(
          shrinkWrap: true,
          children: [
            // ListTile(
            //   leading: const Icon(Icons.settings_rounded),
            //   trailing: const Icon(Icons.chevron_right_rounded),
            //   title: const Text('General'),
            //   onTap: () => Navigator.of(context).push(
            //     MaterialPageRoute(builder: (context) => const GeneralSettingsPage()),
            //   ),
            // ),
            ListTile(
              leading: const Icon(Icons.text_fields_rounded),
              trailing: const Icon(Icons.chevron_right_rounded),
              title: Text('Appearance', style: theme.textTheme.bodyMedium),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AppearanceSettingsPage()),
              ),
            ),
            // const Divider(
            //   color: Colors.white24,
            //   thickness: 1,
            //   indent: 8.0,
            //   endIndent: 8.0,
            // ),
            // ListTile(
            //   leading: const Icon(Icons.developer_mode_rounded),
            //   trailing: const Icon(Icons.chevron_right_rounded),
            //   title: const Text('Developer'),
            //   onTap: () => Navigator.of(context).push(
            //     MaterialPageRoute(builder: (context) => const DeveloperSettingsPage()),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
