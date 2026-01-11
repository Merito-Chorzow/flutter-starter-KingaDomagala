import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../providers/entries_provider.dart';
import '../services/location_service.dart';

/// Ekran dodawania nowego wpisu
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationService = LocationService();

  LocationData? _locationData;
  bool _isLoadingLocation = false;
  bool _isSaving = false;
  String? _locationError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowy wpis'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nagłówek
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withOpacity(0.5),
                      theme.colorScheme.secondaryContainer.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_location_alt,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dodaj nowy wpis',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Zapisz swoje miejsce i wspomnienia',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pole tytułu
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tytuł',
                  hintText: 'np. Wizyta w parku',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wprowadź tytuł wpisu';
                  }
                  if (value.trim().length < 3) {
                    return 'Tytuł musi mieć co najmniej 3 znaki';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pole opisu
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Opis',
                  hintText: 'Opisz to miejsce lub swoje doświadczenia...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wprowadź opis wpisu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Sekcja lokalizacji
              _buildLocationSection(),
              const SizedBox(height: 32),

              // Przycisk zapisz
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveEntry,
                icon: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Zapisywanie...' : 'Zapisz wpis'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _locationData != null
              ? theme.colorScheme.primary.withOpacity(0.5)
              : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gps_fixed,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Lokalizacja GPS',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_locationData != null)
                Chip(
                  label: const Text('Pobrano'),
                  avatar: Icon(
                    Icons.check_circle,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Przycisk pobierania lokalizacji
          OutlinedButton.icon(
            onPressed: _isLoadingLocation ? null : _getLocation,
            icon: _isLoadingLocation
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              _isLoadingLocation
                  ? 'Pobieranie lokalizacji...'
                  : _locationData != null
                      ? 'Pobierz ponownie'
                      : 'Pobierz lokalizację',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Błąd lokalizacji
          if (_locationError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Dane lokalizacji
          if (_locationData != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Współrzędne:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_locationData!.latitude.toStringAsFixed(6)}, ${_locationData!.longitude.toStringAsFixed(6)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (_locationData!.address != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Adres:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _locationData!.address!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (_locationData!.accuracy != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Dokładność: ~${_locationData!.accuracy!.toStringAsFixed(0)} m',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
          Text(
            'Lokalizacja jest opcjonalna, ale pomoże Ci zapamiętać gdzie byłeś.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationData = location;
          _isLoadingLocation = false;
        });
      }
    } on LocationException catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.message;
          _isLoadingLocation = false;
        });

        // Pokaż dialog z opcją otwarcia ustawień
        if (e.type == LocationExceptionType.permissionDeniedForever ||
            e.type == LocationExceptionType.serviceDisabled) {
          _showSettingsDialog(e.type);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = 'Nieoczekiwany błąd: ${e.toString()}';
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _showSettingsDialog(LocationExceptionType type) {
    final isServiceDisabled = type == LocationExceptionType.serviceDisabled;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isServiceDisabled ? 'GPS wyłączony' : 'Brak uprawnień'),
        content: Text(
          isServiceDisabled
              ? 'Usługi lokalizacji są wyłączone. Czy chcesz otworzyć ustawienia lokalizacji?'
              : 'Aplikacja nie ma uprawnień do lokalizacji. Czy chcesz otworzyć ustawienia aplikacji?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nie teraz'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (isServiceDisabled) {
                _locationService.openLocationSettings();
              } else {
                _locationService.openAppSettings();
              }
            },
            child: const Text('Otwórz ustawienia'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final entry = Entry(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: _locationData?.latitude,
      longitude: _locationData?.longitude,
      address: _locationData?.address,
    );

    final success = await context.read<EntriesProvider>().addEntry(entry);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wpis został dodany'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final errorMessage = context.read<EntriesProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Nie udało się dodać wpisu'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

