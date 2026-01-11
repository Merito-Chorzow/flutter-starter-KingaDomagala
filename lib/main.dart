import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/entries_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/entries_list_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pl_PL');
  runApp(const LocationDiaryApp());
}

/// Główna klasa aplikacji Dziennik Lokalizacji
class LocationDiaryApp extends StatelessWidget {
  const LocationDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EntriesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Dziennik Lokalizacji',
            debugShowCheckedModeBanner: false,
            
            // Motywy
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Ekran startowy
            home: const EntriesListScreen(),
          );
        },
      ),
    );
  }
}

