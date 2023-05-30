// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path_provider/path_provider.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:spark/auth/bloc/auth_bloc.dart';
// import 'package:spark/shared/widgets/webview.dart';

// class DeveloperSettingsPage extends StatefulWidget {
//   const DeveloperSettingsPage({super.key});

//   @override
//   State<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
// }

// class _DeveloperSettingsPageState extends State<DeveloperSettingsPage> {
//   bool isLoading = true;
//   bool showNetworkLogger = false;
//   bool enableExperimentalFeatures = false;

//   dynamic authenticationInformation;

//   // App information
//   Directory? cacheDirectory;
//   Directory? appDirectory;
//   dynamic cacheDirectoryStats;
//   dynamic appDirectoryStats;

//   void clearPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     _initPreferences();
//   }

//   Map<String, int> dirStatSync(String dirPath) {
//     int fileNum = 0;
//     int totalSize = 0;
//     var dir = Directory(dirPath);
//     try {
//       if (dir.existsSync()) {
//         dir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
//           if (entity is File) {
//             fileNum++;
//             totalSize += entity.lengthSync();
//           }
//         });
//       }
//     } catch (e) {
//       print(e.toString());
//     }

//     return {'fileNum': fileNum, 'size': totalSize};
//   }

//   void getAppCacheInformation() async {
//     final cacheDir = await getTemporaryDirectory();
//     final _cacheDirectoryStats = dirStatSync(cacheDir.toString());

//     final appDir = await getApplicationSupportDirectory();
//     final _appDirectoryStats = dirStatSync(appDir.toString());

//     print('${_cacheDirectoryStats['size']} bytes');
//     print('${_appDirectoryStats['size']} bytes');

//     setState(() {
//       cacheDirectory = cacheDir;
//       appDirectory = appDir;
//       cacheDirectoryStats = _cacheDirectoryStats;
//       appDirectoryStats = _appDirectoryStats;
//     });
//   }

//   void clearAppCacheStorage() async {
//     if (cacheDirectory != null && cacheDirectory!.existsSync()) cacheDirectory!.deleteSync(recursive: true);
//     if (appDirectory != null && appDirectory!.existsSync()) appDirectory!.deleteSync(recursive: true);
//   }

//   void setPreferences(attribute, value) async {
//     final prefs = await SharedPreferences.getInstance();

//     switch (attribute) {
//       case 'showNetworkLogger':
//         prefs.setBool('showNetworkLogger', value);
//         setState(() => showNetworkLogger = value);
//         break;
//       case 'enableExperimentalFeatures':
//         prefs.setBool('enableExperimentalFeatures', value);
//         setState(() => enableExperimentalFeatures = value);
//         break;
//     }
//   }

//   void _initPreferences() async {
//     final prefs = await SharedPreferences.getInstance();

//     // Authentication information
//     final String? encodedAuthorizationMap = prefs.getString('authorization');
//     final Map<String, dynamic>? decodedAuthorizationMap = (encodedAuthorizationMap != null) ? json.decode(encodedAuthorizationMap) : null;

//     setState(() {
//       showNetworkLogger = prefs.getBool('showNetworkLogger') ?? false;
//       enableExperimentalFeatures = prefs.getBool('enableExperimentalFeatures') ?? false;
//       authenticationInformation = decodedAuthorizationMap;

//       isLoading = false;
//     });
//   }

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initPreferences();
//       getAppCacheInformation();
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Development'),
//         centerTitle: false,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SafeArea(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                 child: debugSettings(),
//               ),
//             ),
//     );
//   }

//   Widget debugSettings() {
//     final theme = Theme.of(context);

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 'Development',
//                 style: theme.textTheme.labelLarge!.copyWith(color: Colors.white70, fontSize: 18.0),
//               ),
//             ),
//             // Row(
//             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //   children: [
//             //     Row(
//             //       children: [
//             //         Icon(showNetworkLogger ? Icons.network_check_rounded : Icons.wifi_off_rounded),
//             //         const SizedBox(width: 8.0),
//             //         const Text('Show network logger'),
//             //       ],
//             //     ),
//             //     Switch(
//             //       value: showNetworkLogger,
//             //       onChanged: (bool value) {
//             //         HapticFeedback.lightImpact();
//             //         setPreferences('showNetworkLogger', value);
//             //       },
//             //     ),
//             //   ],
//             // ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(enableExperimentalFeatures ? Icons.star_rounded : Icons.star_border_rounded),
//                     const SizedBox(width: 8.0),
//                     const Text('Enable experimental features'),
//                   ],
//                 ),
//                 Switch(
//                   value: enableExperimentalFeatures,
//                   onChanged: (bool value) {
//                     HapticFeedback.lightImpact();
//                     setPreferences('enableExperimentalFeatures', value);
//                   },
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 'Reddit Auth',
//                 style: theme.textTheme.labelLarge!.copyWith(color: Colors.white70, fontSize: 18.0),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'A-Token: ${(authenticationInformation != null ? authenticationInformation["access_token"] : '-')}',
//                     style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
//                   ),
//                   Text(
//                     'R-Token: ${(authenticationInformation != null ? authenticationInformation["refresh_token"] : '-')}',
//                     style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
//                   )
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 'App Information',
//                 style: theme.textTheme.labelLarge!.copyWith(color: Colors.white70, fontSize: 18.0),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'App Cache: ${(cacheDirectoryStats != null ? '${cacheDirectoryStats['size']} bytes' : '-')}',
//                     style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
//                   ),
//                   Text(
//                     'App Directory: ${(appDirectoryStats != null ? '${appDirectoryStats['size']} bytes' : '-')}',
//                     style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(50), // NEW
//                 ),
//                 onPressed: () => Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => const WebViewContainer(),
//                 )),
//                 child: const Text('Authenticate with Reddit'),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(50), // NEW
//                 ),
//                 onPressed: () {
//                   clearPreferences();

//                   // context.read<RedditRepository>().reddit.clear_user_authorization();
//                   context.read<AuthBloc>().add(AuthChecked());

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       backgroundColor: const Color.fromRGBO(40, 40, 40, 1),
//                       behavior: SnackBarBehavior.floating,
//                       content: Text(
//                         'Successfully reset all preferences',
//                         style: theme.textTheme.bodyMedium!.copyWith(color: theme.primaryColorLight),
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Text('Reset All Preferences'),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(50), // NEW
//                 ),
//                 onPressed: () {
//                   clearAppCacheStorage();

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       backgroundColor: const Color.fromRGBO(40, 40, 40, 1),
//                       behavior: SnackBarBehavior.floating,
//                       content: Text(
//                         'Successfully cleared app cache and user data',
//                         style: theme.textTheme.bodyMedium!.copyWith(color: theme.primaryColorLight),
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Text('Clear App Data & Cache'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spark/core/theme/bloc/theme_bloc.dart';

class DeveloperSettingsPage extends StatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  State<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends State<DeveloperSettingsPage> {
  bool isLoading = true;

  bool showOriginalURL = false;

  void setPreferences(attribute, value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (attribute) {
      case 'showOriginalURL':
        await prefs.setBool('showOriginalURL', value);
        context.read<ThemeBloc>().add(ThemeRefreshed());
        break;
    }
  }

  void _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      showOriginalURL = prefs.getBool('showOriginalURL') ?? false;
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
                    child: developerSettings(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget developerSettings() {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Debug',
            style: theme.textTheme.titleLarge,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(showOriginalURL ? Icons.link_rounded : Icons.link_off_rounded),
                const SizedBox(width: 8.0),
                Text(
                  'Show original URLs',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            Switch(
              value: showOriginalURL,
              onChanged: (bool value) {
                HapticFeedback.lightImpact();
                setPreferences('showOriginalURL', value);
                setState(() => showOriginalURL = !showOriginalURL);
              },
            ),
          ],
        ),
      ],
    );
  }
}
