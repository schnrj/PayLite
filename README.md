# PayLite 💸

UPI-style person-to-person payments with QR scan-and-pay mobile banking app.
Designed according to the BankEase 4-layer reference architecture for the Flutter Banking Capstone track.

## Architecture

- **Presentation (`lib/features/*/presentation`)**: Screens, widgets, and routes using `go_router`.
- **State (`lib/features/*/state`)**: Riverpod notifiers and providers.
- **Data (`lib/features/*/data`, `domain`)**: Repository pattern, pure-Dart business logic, models with `fromJson`.
- **Core (`lib/core`)**: Dio client & interceptors, sealed `BankError`, biometric security, integer paise currency formatting, animations.

## Getting Started

1. Ensure Flutter is installed and added to your `PATH`.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter test` to execute unit and widget tests.
4. Run `flutter run` to launch PayLite.
