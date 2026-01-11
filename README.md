# 📍 Dziennik Lokalizacji

Aplikacja Flutter do zapisywania i zarządzania wpisami z lokalizacją GPS.

![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?style=flat-square&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

## 📋 Opis projektu

**Dziennik Lokalizacji** to aplikacja mobilna stworzona w Flutter, która pozwala użytkownikom:
- Zapisywać wpisy z tytułem i opisem
- Pobierać aktualną lokalizację GPS
- Przeglądać historię wpisów na liście
- Wizualizować lokalizację na mapie
- Personalizować wygląd aplikacji (motyw jasny/ciemny)

## ✨ Funkcjonalności

### 🗂️ Widoki (4 ekrany)

1. **Lista wpisów** - główny widok z listą wszystkich zapisanych wpisów
2. **Szczegóły wpisu** - pełne informacje o wpisie z mapą lokalizacji
3. **Dodaj wpis** - formularz do tworzenia nowego wpisu z przyciskiem GPS
4. **Ustawienia** - konfiguracja motywu aplikacji

### 📱 Funkcja natywna: Lokalizacja GPS

**Uzasadnienie wyboru:**
- Praktyczna funkcjonalność dla dziennika podróży/miejsc
- Demonstracja obsługi uprawnień systemowych
- Możliwość wizualizacji na mapie
- Reverse geocoding (konwersja współrzędnych na adres)

**Implementacja:**
- Pakiet `geolocator` do pobierania współrzędnych
- Pakiet `geocoding` do konwersji na adres
- Obsługa stanów: brak uprawnień, wyłączony GPS, timeout
- Dialogi z opcją otwarcia ustawień systemowych

### 🌐 Komunikacja z API

**Endpoint:** JSONPlaceholder (https://jsonplaceholder.typicode.com)

| Metoda | Endpoint | Opis |
|--------|----------|------|
| GET | `/posts` | Pobiera listę wpisów |
| GET | `/posts/{id}` | Pobiera szczegóły wpisu |
| POST | `/posts` | Tworzy nowy wpis |
| DELETE | `/posts/{id}` | Usuwa wpis |

**Obsługiwane scenariusze:**
- ✅ Stan ładowania (spinner)
- ✅ Stan błędu (komunikat + retry)
- ✅ Stan pusty (zachęta do dodania)
- ✅ Brak internetu (dedykowany komunikat)
- ✅ Timeout połączenia

### 🎨 UX/UI

- Material Design 3
- Jasny i ciemny motyw
- Responsywne layouty
- Animacje i przejścia
- Komunikaty Snackbar
- Dialogi potwierdzenia

## 🏗️ Architektura

```
lib/
├── main.dart                 # Punkt wejścia aplikacji
├── models/
│   └── entry.dart           # Model wpisu
├── providers/
│   ├── entries_provider.dart # Stan wpisów
│   └── theme_provider.dart   # Stan motywu
├── screens/
│   ├── entries_list_screen.dart  # Lista wpisów
│   ├── entry_detail_screen.dart  # Szczegóły
│   ├── add_entry_screen.dart     # Dodawanie
│   └── settings_screen.dart      # Ustawienia
├── services/
│   ├── api_service.dart      # Komunikacja HTTP
│   └── location_service.dart # Obsługa GPS
├── theme/
│   └── app_theme.dart        # Konfiguracja motywów
└── widgets/
    ├── loading_indicator.dart # Spinner
    ├── error_view.dart        # Widok błędu
    └── empty_state.dart       # Pusty stan
```

## 🚀 Uruchomienie

### Wymagania

- Flutter SDK 3.5+
- Dart SDK 3.5+
- Android Studio / VS Code
- Emulator lub fizyczne urządzenie

### Instalacja

```bash
# Klonowanie repozytorium
git clone <repo-url>
cd location_diary_app

# Instalacja zależności
flutter pub get

# Uruchomienie na emulatorze
flutter run

# Uruchomienie w trybie debug
flutter run --debug

# Build na Android
flutter build apk

# Build na iOS
flutter build ios
```

### Testowanie

```bash
# Uruchomienie testów jednostkowych
flutter test

# Testy z coverage
flutter test --coverage
```

## 📱 Demonstracja

### Scenariusze testowe

1. **Dodanie wpisu z GPS:**
   - Otwórz formularz dodawania
   - Wypełnij tytuł i opis
   - Kliknij "Pobierz lokalizację"
   - Zezwól na dostęp do lokalizacji
   - Zapisz wpis

2. **Przeglądanie wpisów:**
   - Lista wyświetla wszystkie wpisy
   - Kliknij na wpis, aby zobaczyć szczegóły
   - Mapa pokazuje lokalizację

3. **Obsługa błędów:**
   - Wyłącz internet → komunikat o braku połączenia
   - Odrzuć uprawnienia → dialog z opcją ustawień
   - Wyłącz GPS → komunikat + link do ustawień

4. **Motyw aplikacji:**
   - Przejdź do Ustawień
   - Wybierz motyw: Systemowy / Jasny / Ciemny

## 📦 Zależności

| Pakiet | Wersja | Opis |
|--------|--------|------|
| provider | ^6.1.2 | Zarządzanie stanem |
| http | ^1.2.2 | Klient HTTP |
| geolocator | ^12.0.0 | Lokalizacja GPS |
| geocoding | ^3.0.0 | Reverse geocoding |
| permission_handler | ^11.3.1 | Uprawnienia |
| shared_preferences | ^2.3.2 | Lokalne przechowywanie |
| flutter_map | ^7.0.2 | Mapa OpenStreetMap |
| latlong2 | ^0.9.1 | Współrzędne geograficzne |
| intl | ^0.19.0 | Formatowanie dat |

## 📸 Zrzuty ekranów

### Lista wpisów
*Główny widok z listą wszystkich wpisów*

### Szczegóły wpisu
*Pełne informacje o wpisie z mapą lokalizacji*

### Dodawanie wpisu
*Formularz z przyciskiem pobierania lokalizacji GPS*

### Ustawienia
*Wybór motywu jasnego/ciemnego*

## ✅ Definition of Done

- [x] 4 widoki (Lista, Szczegóły, Dodaj, Ustawienia)
- [x] Kompletna nawigacja między ekranami
- [x] Funkcja natywna: GPS z reverse geocoding
- [x] Operacje API: GET (lista, szczegóły), POST (dodaj), DELETE
- [x] Stany: ładowanie, błąd, pusty
- [x] Motyw jasny/ciemny
- [x] README.md z dokumentacją
- [x] Testy jednostkowe

## 🔧 Konfiguracja uprawnień

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikacja potrzebuje dostępu do lokalizacji...</string>
```

## 📄 Licencja

MIT License - zobacz plik [LICENSE](LICENSE)

---

**Autor:** Projekt demonstracyjny Flutter  
**Data:** 2024

