import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smartkasir/services/preferences_service.dart';
import 'package:smartkasir/services/theme_service.dart';
import 'package:smartkasir/views/dashboard/kelola_pegawai_view.dart';
import 'package:smartkasir/views/dashboard/kelola_produk_view.dart';
import 'package:smartkasir/views/dashboard/list_pegawai_view.dart';
import 'package:smartkasir/views/home_view.dart';
import 'package:smartkasir/views/profile/profile_view.dart';
import 'package:smartkasir/views/settings/settings_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesService = PreferencesService();
    final themeService = ThemeService(preferencesService);

    return MultiProvider(
      providers: [
        Provider<PreferencesService>.value(value: preferencesService),
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'SMARTKASIR',
            debugShowCheckedModeBanner: false,
            themeMode: themeService.themeMode,
            theme: ThemeData(
              fontFamily: GoogleFonts.poppins().fontFamily,
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeService.seedColor,
                brightness: Brightness.light,
                dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
              ),
              progressIndicatorTheme: const ProgressIndicatorThemeData(),
              sliderTheme: const SliderThemeData(),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              fontFamily: GoogleFonts.poppins().fontFamily,
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeService.seedColor,
                brightness: Brightness.dark,
                dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
              ),
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              ).apply(bodyColor: Colors.black, displayColor: Colors.white),
              progressIndicatorTheme: const ProgressIndicatorThemeData(),
              sliderTheme: const SliderThemeData(),
              useMaterial3: true,
            ),
            home: const SettingsView(), // arahkan ke HomePage
          );
        },
      ),
    );
  }
}
