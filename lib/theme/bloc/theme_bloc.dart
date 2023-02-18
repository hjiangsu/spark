import 'dart:async';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeRefreshed>(_onThemeRefresh);
  }

  Future<void> _onThemeRefresh(ThemeRefreshed event, Emitter<ThemeState> emit) async {
    try {
      emit(state.copyWith(status: ThemeStatus.loading));

      final prefs = await SharedPreferences.getInstance();
      bool useDarkTheme = prefs.getBool('useDarkTheme') ?? true;
      String? colorScheme = prefs.getString('colorScheme');

      MaterialColor colorSchemeSeed = Colors.blueGrey;

      // Determines color scheme based on user preferences
      switch (colorScheme) {
        case "pink":
          colorSchemeSeed = Colors.pink;
          break;
        case "red":
          colorSchemeSeed = Colors.red;
          break;
        case "deepOrange":
          colorSchemeSeed = Colors.deepOrange;
          break;
        case "orange":
          colorSchemeSeed = Colors.orange;
          break;
        case "amber":
          colorSchemeSeed = Colors.amber;
          break;
        case "yellow":
          colorSchemeSeed = Colors.yellow;
          break;
        case "lime":
          colorSchemeSeed = Colors.lime;
          break;
        case "lightGreen":
          colorSchemeSeed = Colors.lightGreen;
          break;
        case "green":
          colorSchemeSeed = Colors.green;
          break;
        case "teal":
          colorSchemeSeed = Colors.teal;
          break;
        case "cyan":
          colorSchemeSeed = Colors.cyan;
          break;
        case "lightBlue":
          colorSchemeSeed = Colors.lightBlue;
          break;
        case "blue":
          colorSchemeSeed = Colors.blue;
          break;
        case "indigo":
          colorSchemeSeed = Colors.indigo;
          break;
        case "purple":
          colorSchemeSeed = Colors.purple;
          break;
        case "deepPurple":
          colorSchemeSeed = Colors.deepPurple;
          break;
        case "blueGrey":
          colorSchemeSeed = Colors.blueGrey;
          break;
        case "brown":
          colorSchemeSeed = Colors.brown;
          break;
        case "grey":
          colorSchemeSeed = Colors.grey;
          break;
        default:
          colorSchemeSeed = Colors.blueGrey;
          break;
      }

      return emit(
        state.copyWith(
          status: ThemeStatus.success,
          colorSchemeSeed: colorSchemeSeed,
          useDarkTheme: useDarkTheme,
        ),
      );
    } catch (_) {
      emit(state.copyWith());
    }
  }
}
