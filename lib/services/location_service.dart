import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Wyjątek dla błędów lokalizacji
class LocationException implements Exception {
  final String message;
  final LocationExceptionType type;

  LocationException(this.message, this.type);

  @override
  String toString() => message;
}

/// Typ błędu lokalizacji
enum LocationExceptionType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}

/// Dane lokalizacji
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final double? accuracy;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.accuracy,
  });

  @override
  String toString() => 'LocationData(lat: $latitude, lng: $longitude, addr: $address)';
}

/// Serwis do obsługi lokalizacji GPS (funkcja natywna)
/// 
/// Uzasadnienie wyboru GPS:
/// - Praktyczna funkcjonalność dla dziennika lokalizacji
/// - Demonstracja uprawnień i obsługi błędów
/// - Możliwość wizualizacji na mapie
/// - Często używana w aplikacjach mobilnych
class LocationService {
  /// Sprawdza czy usługi lokalizacji są włączone
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Sprawdza status uprawnień
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Prosi o uprawnienia do lokalizacji
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Pobiera aktualną lokalizację
  /// 
  /// Rzuca [LocationException] gdy:
  /// - Usługi lokalizacji są wyłączone
  /// - Brak uprawnień
  /// - Przekroczono czas oczekiwania
  Future<LocationData> getCurrentLocation() async {
    // Sprawdź czy usługi lokalizacji są włączone
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'Usługi lokalizacji są wyłączone. Włącz GPS w ustawieniach urządzenia.',
        LocationExceptionType.serviceDisabled,
      );
    }

    // Sprawdź uprawnienia
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(
          'Odmówiono dostępu do lokalizacji. Zezwól na dostęp w ustawieniach.',
          LocationExceptionType.permissionDenied,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Dostęp do lokalizacji jest trwale zablokowany. Zmień ustawienia w aplikacji Ustawienia.',
        LocationExceptionType.permissionDeniedForever,
      );
    }

    // Pobierz lokalizację
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      // Próbuj pobrać adres (reverse geocoding)
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = _formatAddress(place);
        }
      } catch (e) {
        // Ignoruj błędy geocodingu - adres nie jest wymagany
        address = null;
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        accuracy: position.accuracy,
      );
    } on TimeoutException {
      throw LocationException(
        'Przekroczono czas oczekiwania na lokalizację. Upewnij się, że masz dobry sygnał GPS.',
        LocationExceptionType.timeout,
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException(
        'Nie udało się pobrać lokalizacji: ${e.toString()}',
        LocationExceptionType.unknown,
      );
    }
  }

  /// Formatuje adres z danych geocodingu
  String _formatAddress(Placemark place) {
    final parts = <String>[];
    
    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      parts.add(place.country!);
    }
    
    return parts.join(', ');
  }

  /// Oblicza odległość między dwoma punktami (w metrach)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Otwiera ustawienia aplikacji (dla trwale zablokowanych uprawnień)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Otwiera ustawienia lokalizacji
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}

