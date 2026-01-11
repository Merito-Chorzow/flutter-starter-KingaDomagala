import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/entry.dart';

/// Wyjątek dla błędów API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// Wyjątek dla braku połączenia
class NoConnectionException implements Exception {
  final String message;
  NoConnectionException([this.message = 'Brak połączenia z internetem']);

  @override
  String toString() => message;
}

/// Serwis do komunikacji z API
/// Używa JSONPlaceholder jako mock API do demonstracji
class ApiService {
  // JSONPlaceholder jako przykładowe API
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  
  final http.Client _client;
  
  // Lokalna lista wpisów (symulacja bazy danych)
  final List<Entry> _localEntries = [];
  int _nextId = 1000;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Pobiera listę wpisów z API
  /// GET /posts
  Future<List<Entry>> getEntries() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw NoConnectionException('Przekroczono czas oczekiwania'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        // Bierzemy tylko pierwsze 10 wpisów dla lepszego UX
        final apiEntries = jsonList
            .take(10)
            .map((json) => Entry.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Dodajemy lokalne wpisy na początek
        return [..._localEntries.reversed, ...apiEntries];
      } else {
        throw ApiException(
          'Nie udało się pobrać wpisów',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NoConnectionException();
    } on http.ClientException {
      throw NoConnectionException();
    }
  }

  /// Pobiera szczegóły wpisu
  /// GET /posts/{id}
  Future<Entry> getEntry(int id) async {
    // Najpierw szukamy w lokalnych wpisach
    final localEntry = _localEntries.where((e) => e.id == id).firstOrNull;
    if (localEntry != null) {
      return localEntry;
    }

    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw NoConnectionException('Przekroczono czas oczekiwania'),
      );

      if (response.statusCode == 200) {
        return Entry.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ApiException('Wpis nie został znaleziony', statusCode: 404);
      } else {
        throw ApiException(
          'Nie udało się pobrać wpisu',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NoConnectionException();
    } on http.ClientException {
      throw NoConnectionException();
    }
  }

  /// Tworzy nowy wpis
  /// POST /posts
  Future<Entry> createEntry(Entry entry) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(entry.toJson()),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw NoConnectionException('Przekroczono czas oczekiwania'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // JSONPlaceholder zwraca id=101 dla wszystkich nowych wpisów
        // Używamy własnego ID dla lokalnego przechowywania
        final createdEntry = entry.copyWith(id: _nextId++);
        _localEntries.add(createdEntry);
        return createdEntry;
      } else {
        throw ApiException(
          'Nie udało się utworzyć wpisu',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NoConnectionException();
    } on http.ClientException {
      throw NoConnectionException();
    }
  }

  /// Usuwa wpis
  /// DELETE /posts/{id}
  Future<void> deleteEntry(int id) async {
    // Usuwamy z lokalnych wpisów
    _localEntries.removeWhere((e) => e.id == id);

    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw NoConnectionException('Przekroczono czas oczekiwania'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          'Nie udało się usunąć wpisu',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NoConnectionException();
    } on http.ClientException {
      throw NoConnectionException();
    }
  }

  /// Zamyka klienta HTTP
  void dispose() {
    _client.close();
  }
}

