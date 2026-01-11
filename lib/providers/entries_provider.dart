import 'package:flutter/foundation.dart';
import '../models/entry.dart';
import '../services/api_service.dart';

/// Stan ładowania danych
enum LoadingState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Provider do zarządzania wpisami
class EntriesProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Entry> _entries = [];
  LoadingState _state = LoadingState.initial;
  String? _errorMessage;

  EntriesProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Gettery
  List<Entry> get entries => _entries;
  LoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadingState.loading;
  bool get hasError => _state == LoadingState.error;
  bool get isEmpty => _state == LoadingState.empty;

  /// Pobiera listę wpisów z API
  Future<void> fetchEntries() async {
    _state = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _entries = await _apiService.getEntries();
      _state = _entries.isEmpty ? LoadingState.empty : LoadingState.loaded;
    } on NoConnectionException catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.message;
    } on ApiException catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Nieoczekiwany błąd: ${e.toString()}';
    }

    notifyListeners();
  }

  /// Pobiera pojedynczy wpis
  Future<Entry?> getEntry(int id) async {
    try {
      return await _apiService.getEntry(id);
    } catch (e) {
      return _entries.where((entry) => entry.id == id).firstOrNull;
    }
  }

  /// Dodaje nowy wpis
  Future<bool> addEntry(Entry entry) async {
    try {
      final newEntry = await _apiService.createEntry(entry);
      _entries.insert(0, newEntry);
      _state = LoadingState.loaded;
      notifyListeners();
      return true;
    } on NoConnectionException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Nie udało się dodać wpisu: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Usuwa wpis
  Future<bool> deleteEntry(int id) async {
    try {
      await _apiService.deleteEntry(id);
      _entries.removeWhere((entry) => entry.id == id);
      _state = _entries.isEmpty ? LoadingState.empty : LoadingState.loaded;
      notifyListeners();
      return true;
    } on NoConnectionException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Nie udało się usunąć wpisu: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Czyści komunikat błędu
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}

