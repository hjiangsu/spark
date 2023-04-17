import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spark/settings/views/appearance_settings_page.dart';

import 'package:spark/settings/views/developer_settings_page.dart';
import 'package:spark/settings/views/general_settings_page.dart';
import 'package:spark/spark/bloc/spark_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();

    context.read<SparkBloc>().add(const AppBarTitleChanged(title: 'Settings'));
    context.read<SparkBloc>().add(const AppBarActionChanged(actions: []));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
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
    );
  }
}
