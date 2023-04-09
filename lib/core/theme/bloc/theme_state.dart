part of 'theme_bloc.dart';

enum ThemeStatus { loading, success, failure }

class ThemeState extends Equatable {
  const ThemeState({
    this.status = ThemeStatus.loading,
    this.useDarkTheme = true,
    this.colorSchemeSeed = Colors.blueGrey,
  });

  final ThemeStatus status;
  final bool useDarkTheme;
  final MaterialColor colorSchemeSeed;

  ThemeState copyWith({
    ThemeStatus? status,
    bool? useDarkTheme,
    MaterialColor? colorSchemeSeed,
  }) {
    return ThemeState(
      status: status ?? this.status,
      useDarkTheme: useDarkTheme ?? true,
      colorSchemeSeed: colorSchemeSeed ?? Colors.blueGrey,
    );
  }

  @override
  String toString() => '''ThemeState { status: $status, useDarkTheme: $useDarkTheme }''';

  @override
  List<dynamic> get props => [status, useDarkTheme, colorSchemeSeed];
}
