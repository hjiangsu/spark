import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spark/core/auth/bloc/auth_bloc.dart';

import 'package:spark/core/singletons/reddit_client.dart';
import 'package:spark/account/bloc/account_bloc.dart';
import 'package:spark/core/utils/datetime.dart';
import 'package:spark/core/utils/numbers.dart';
import 'package:spark/login/login.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String defaultAvatar = 'https://www.redditstatic.com/avatars/defaults/v2/avatar_default_1.png';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () {
              showModalBottomSheet<void>(
                showDragHandle: true,
                context: context,
                builder: (context) => ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout_rounded),
                      title: const Text('Logout'),
                      onTap: () async {
                        context.read<AuthBloc>().add(AuthLogout());
                      },
                    )
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: BlocProvider(
        create: (context) => AccountBloc(reddit: RedditClient.instance),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            BlocProvider.of<AccountBloc>(context).add(AccountFetched(isUserAuthorized: state.isUserAuthorized));
          },
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, state) {
              switch (state.status) {
                case AccountStatus.initial:
                  BlocProvider.of<AccountBloc>(context).add(AccountFetched(isUserAuthorized: context.read<AuthBloc>().state.isUserAuthorized));
                  return const Center(child: CircularProgressIndicator());
                case AccountStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case AccountStatus.success:
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            foregroundImage: CachedNetworkImageProvider(state.accountInformation?.avatarIconImageURL ?? defaultAvatar),
                            maxRadius: 70,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            state.accountInformation!.name,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${formatNumberToK(state.accountInformation?.totalKarma ?? 0)}  ·  ${formatTimeToString(epochTime: state.accountInformation?.createdAt ?? 0)}',
                            style: theme.textTheme.labelMedium?.copyWith(color: theme.textTheme.labelMedium?.color?.withAlpha(200)),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: () => {},
                            child: const Text('Posts'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: () => {},
                            child: const Text('Comments'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: () => {},
                            child: const Text('Saved'),
                          ),
                          // const SizedBox(height: 8),
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     minimumSize: const Size.fromHeight(50),
                          //   ),
                          //   onPressed: () => {},
                          //   child: const Text('Friends'),
                          // ),
                          // const SizedBox(height: 8),
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     minimumSize: const Size.fromHeight(50),
                          //   ),
                          //   onPressed: () => {},
                          //   child: const Text('Upvoted'),
                          // ),
                          // const SizedBox(height: 8),
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     minimumSize: const Size.fromHeight(50),
                          //   ),
                          //   onPressed: () => {},
                          //   child: const Text('Downvoted'),
                          // ),
                          // const SizedBox(height: 8),
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     minimumSize: const Size.fromHeight(50),
                          //   ),
                          //   onPressed: () => {},
                          //   child: const Text('Hidden'),
                          // ),
                          // const SizedBox(height: 8),
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     minimumSize: const Size.fromHeight(50),
                          //   ),
                          //   onPressed: () => {},
                          //   child: const Text('Trophies'),
                          // ),
                        ],
                      ),
                    ),
                  );
                case AccountStatus.failure:
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
