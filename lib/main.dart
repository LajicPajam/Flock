import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/trip_list_screen.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Flock Carpool',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryGreen,
            secondary: AppColors.secondaryGreen,
            tertiary: AppColors.primaryAccent,
            surface: AppColors.cardBackground,
            onPrimary: Colors.white,
            onSecondary: AppColors.textInk,
            onTertiary: Colors.white,
            onSurface: AppColors.textInk,
          ),
          scaffoldBackgroundColor: AppColors.canvasBackground,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
          ),
          cardTheme: const CardThemeData(
            color: AppColors.cardBackground,
            surfaceTintColor: Colors.transparent,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: Colors.white,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.secondaryGreen,
            labelStyle: const TextStyle(color: AppColors.textInk),
            side: const BorderSide(color: AppColors.subtleBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          textTheme: ThemeData.light().textTheme.apply(
                bodyColor: AppColors.textInk,
                displayColor: AppColors.textInk,
              ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryAccent,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
          useMaterial3: true,
        ),
        home: Consumer<AppState>(
          builder: (context, appState, _) {
            if (appState.isAuthenticated) {
              return const TripListScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
