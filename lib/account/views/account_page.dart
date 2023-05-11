import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/core/auth/bloc/auth_bloc.dart';
import 'package:spark/core/singletons/reddit_client.dart';
import 'package:spark/login/bloc/login_bloc.dart';
import 'package:spark/login/views/login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => LoginBloc(reddit: RedditClient.instance),
      child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign in to access your Reddit account',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              child: const Text('Sign In with Reddit'),
            )
          ],
        );
      }),
    );
  }
}
