import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Ekran ustawień aplikacji
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sekcja wygląd
          _SectionHeader(
            icon: Icons.palette,
            title: 'Wygląd',
          ),
          const SizedBox(height: 8),
          Card(
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  children: [
                    _ThemeOption(
                      title: 'Systemowy',
                      subtitle: 'Dopasuj do ustawień systemu',
                      icon: Icons.settings_system_daydream,
                      isSelected: themeProvider.themeMode == ThemeMode.system,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      title: 'Jasny',
                      subtitle: 'Zawsze jasny motyw',
                      icon: Icons.light_mode,
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      title: 'Ciemny',
                      subtitle: 'Zawsze ciemny motyw',
                      icon: Icons.dark_mode,
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Sekcja informacje
          _SectionHeader(
            icon: Icons.info,
            title: 'Informacje',
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: const Text('Dziennik Lokalizacji'),
                  subtitle: const Text('Wersja 1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.code,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  title: const Text('Technologie'),
                  subtitle: const Text('Flutter • Dart • GPS • REST API'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Sekcja funkcjonalności
          _SectionHeader(
            icon: Icons.star,
            title: 'Funkcjonalności',
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _FeatureTile(
                  icon: Icons.gps_fixed,
                  title: 'Lokalizacja GPS',
                  description: 'Funkcja natywna do pobierania współrzędnych',
                  color: Colors.blue,
                ),
                const Divider(height: 1),
                _FeatureTile(
                  icon: Icons.cloud_sync,
                  title: 'API REST',
                  description: 'Komunikacja z serwerem (JSONPlaceholder)',
                  color: Colors.green,
                ),
                const Divider(height: 1),
                _FeatureTile(
                  icon: Icons.map,
                  title: 'Mapa',
                  description: 'Wizualizacja lokalizacji na mapie OSM',
                  color: Colors.orange,
                ),
                const Divider(height: 1),
                _FeatureTile(
                  icon: Icons.brightness_6,
                  title: 'Motywy',
                  description: 'Jasny i ciemny motyw aplikacji',
                  color: Colors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Informacja o autorze
          Center(
            child: Column(
              children: [
                Text(
                  '© 2024 Dziennik Lokalizacji',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stworzone z ❤️ przy użyciu Flutter',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(title),
      subtitle: Text(description),
    );
  }
}

