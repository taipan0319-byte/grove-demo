import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/app_state.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final appState = AppState(prefs)..load();
  runApp(GroveApp(appState: appState));
}

class GroveApp extends StatelessWidget {
  final AppState appState;
  const GroveApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        title: 'Grove',
        debugShowCheckedModeBanner: false,
        theme: buildGroveTheme(),
        home: Consumer<AppState>(
          builder: (context, state, _) =>
              state.onboarded ? const MainShell() : const OnboardingScreen(),
        ),
      ),
    );
  }
}
