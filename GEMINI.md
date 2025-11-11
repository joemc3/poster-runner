# Poster Runner

## Project Overview

This is a Flutter project called "Poster Runner" designed for managing poster requests in offline environments using Bluetooth Low Energy (BLE). It has two main roles: "Front Desk" for submitting requests and "Back Office" for fulfilling them. The application is built with a focus on reliability and offline-first functionality.

The project is well-structured, with separate directories for the application code (`app`), project standards and documentation (`project_standards`), and general UX/UI standards (`general_standards`).

## Current Project Status

The project is in an advanced stage of development, with most core features implemented.

### What's Complete
-   **UI Layer:** 100% complete, including all 7 screens and a high-contrast, themeable design.
-   **Data Models:** The `PosterRequest` model is fully implemented with serialization and Hive adapters.
-   **Persistence:** The `PersistenceService` using Hive is fully functional for both Front Desk and Back Office roles, ensuring data persists across app restarts.
-   **State Management:** A complete Provider architecture is in place, managing theme, BLE connection, and data for both roles.
-   **BLE Service Layer:** The BLE client (`flutter_reactive_ble`) and server (`ble_peripheral`) services are implemented, along with sync orchestration and permission handling.

### What's Working
-   **One-way Communication:** The Front Desk can successfully send poster requests to the Back Office via BLE.
-   **Offline Functionality:** Both roles have full offline support, with requests and status changes being queued locally in Hive.
-   **Automatic Reconnection:** The app features a three-step handshake protocol to sync data upon reconnection.

### Known Issues
-   **Back Office to Front Desk Notifications:** The primary issue is that the Back Office cannot send status updates (e.g., when a poster is "pulled") back to the Front Desk. This appears as a "Not connected" error in the `SyncService`.

### Next Steps
-   The immediate priority is to **debug the Back Office to Front Desk notification flow** to enable two-way communication.
-   Implement role persistence to save the selected role across app restarts.
-   Add comprehensive test coverage.

## Building and Running

### Prerequisites

- Flutter SDK: Version 3.35+
- Dart SDK: Version 3.9+
- IDE: VS Code, Android Studio, or IntelliJ IDEA with Flutter plugin

### Installation

1.  Navigate to the `app` directory:
    ```bash
    cd app
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```

### Running the App

- Run on any available device:
  ```bash
  flutter run
  ```
- Run on a specific platform (e.g., iOS):
  ```bash
  flutter run -d ios
  ```

### Building for Release

- **Android APK:**
  ```bash
  flutter build apk --release
  ```
- **iOS App:**
  ```bash
  flutter build ios --release
  ```

## Development Conventions

### Architecture

The project follows a clean architecture, separating concerns into:

-   **UI:** Located in `app/lib/screens`, responsible for the user interface.
-   **State Management:** Uses the `provider` package, with providers located in `app/lib/providers`.
-   **Services:** Business logic and communication with external services (like BLE and persistence) are handled in `app/lib/services`.
-   **Models:** Data structures are defined in `app/lib/models`.

### Technologies

-   **Framework:** Flutter
-   **Language:** Dart
-   **State Management:** `provider`
-   **Persistence:** `hive`
-   **Communication:** Bluetooth Low Energy (BLE) using `flutter_reactive_ble` and `ble_peripheral`.

### Testing

-   Run tests with the following command:
    ```bash
    flutter test
    ```
-   Analyze the code for potential issues:
    ```bash
    flutter analyze
    ```
-   Format the code according to the project's style:
    ```bash
    flutter format .
    ```

### Documentation

The `project_standards` directory contains detailed documentation about the project, including:

-   Product Requirements Document (PRD)
-   BLE GATT Architecture Design
-   Data Structure Specification
-   Local Persistence Specification
-   Synchronization Protocol and Error Handling
-   UX Design Documents

This documentation is a valuable resource for understanding the project's design and implementation.