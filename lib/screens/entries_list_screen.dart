import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../providers/entries_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state.dart';
import 'entry_detail_screen.dart';
import 'add_entry_screen.dart';
import 'settings_screen.dart';

/// Ekran listy wpisów - główny widok aplikacji
class EntriesListScreen extends StatefulWidget {
  const EntriesListScreen({super.key});

  @override
  State<EntriesListScreen> createState() => _EntriesListScreenState();
}

class _EntriesListScreenState extends State<EntriesListScreen> {
  @override
  void initState() {
    super.initState();
    // Pobierz wpisy przy starcie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntriesProvider>().fetchEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Dziennik Lokalizacji'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
            onPressed: () {
              context.read<EntriesProvider>().fetchEntries();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ustawienia',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<EntriesProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEntry(),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Dodaj wpis'),
      ),
    );
  }

  Widget _buildBody(EntriesProvider provider) {
    switch (provider.state) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const LoadingIndicator(
          message: 'Ładowanie wpisów...',
        );
      
      case LoadingState.error:
        return ErrorView(
          message: provider.errorMessage ?? 'Wystąpił nieznany błąd',
          onRetry: () => provider.fetchEntries(),
        );
      
      case LoadingState.empty:
        return EmptyState(
          icon: Icons.location_off,
          title: 'Brak wpisów',
          message: 'Dodaj pierwszy wpis, aby rozpocząć\nswój dziennik lokalizacji!',
          actionLabel: 'Dodaj wpis',
          onAction: () => _navigateToAddEntry(),
        );
      
      case LoadingState.loaded:
        return RefreshIndicator(
          onRefresh: () => provider.fetchEntries(),
          child: _buildEntriesList(provider.entries),
        );
    }
  }

  Widget _buildEntriesList(List<Entry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return _EntryCard(
          entry: entries[index],
          onTap: () => _navigateToDetail(entries[index]),
        );
      },
    );
  }

  void _navigateToAddEntry() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEntryScreen(),
      ),
    );
    
    if (result == true && mounted) {
      // Odśwież listę po dodaniu wpisu
      context.read<EntriesProvider>().fetchEntries();
    }
  }

  void _navigateToDetail(Entry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailScreen(entryId: entry.id!),
      ),
    );
  }
}

/// Karta wpisu na liście
class _EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback onTap;

  const _EntryCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tytuł
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.hasLocation)
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Opis
              Text(
                entry.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Metadane
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(entry.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  if (entry.address != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.place,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

