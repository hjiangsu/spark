// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// class GeneralSettingsPage extends StatefulWidget {
//   const GeneralSettingsPage({super.key});

//   @override
//   State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
// }

// class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
//   bool isLoading = true;

//   bool showExpandedMedia = false;
//   bool showVideoOnFeed = false;
//   bool enableRandomButton = true;

//   void setPreferences(attribute, value) async {
//     final prefs = await SharedPreferences.getInstance();

//     switch (attribute) {
//       case 'showVideoOnFeed':
//         prefs.setBool('showVideoOnFeed', value);
//         setState(() => showVideoOnFeed = value);
//         break;
//       case 'enableRandomButton':
//         prefs.setBool('enableRandomButton', value);
//         setState(() => enableRandomButton = value);
//         break;
//     }
//   }

//   void _initPreferences() async {
//     final prefs = await SharedPreferences.getInstance();

//     setState(() {
//       showVideoOnFeed = prefs.getBool('showVideoOnFeed') ?? false;
//       enableRandomButton = prefs.getBool('enableRandomButton') ?? true;

//       isLoading = false;
//     });
//   }

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('General'),
//         centerTitle: false,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                     child: generalSettings(),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget generalSettings() {
//     final theme = Theme.of(context);

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 8.0),
//           child: Text(
//             'Posts',
//             style: theme.textTheme.labelLarge!.copyWith(fontSize: 18.0),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(showVideoOnFeed ? Icons.subscriptions_rounded : Icons.subscriptions_outlined),
//                 const SizedBox(width: 8.0),
//                 const Text('Show videos'),
//               ],
//             ),
//             Switch(
//               value: showVideoOnFeed,
//               onChanged: (bool value) {
//                 HapticFeedback.lightImpact();
//                 setPreferences('showVideoOnFeed', value);
//               },
//             ),
//           ],
//         ),
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 8.0),
//           child: Divider(
//             color: Colors.white24,
//             thickness: 1,
//             indent: 8.0,
//             endIndent: 8.0,
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 8.0),
//           child: Text(
//             'Features',
//             style: theme.textTheme.labelLarge!.copyWith(fontSize: 18.0),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.shuffle_rounded),
//                 SizedBox(width: 8.0),
//                 Text('Random subreddit button'),
//               ],
//             ),
//             Switch(
//               value: enableRandomButton,
//               onChanged: (bool value) {
//                 HapticFeedback.lightImpact();
//                 setPreferences('enableRandomButton', value);
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
