# Poster Runner

A cross-platform mobile application for efficient poster fulfillment management in temporary event locations with unreliable or no internet connectivity.

## Overview

Poster Runner enables seamless communication between Front Desk and Back Office teams at events, trade shows, and temporary installations using Bluetooth Low Energy (BLE) technology. The application ensures reliable request tracking and fulfillment without requiring internet access.

## The Problem

At temporary event locations, Front Desk staff frequently receive requests from clients for posters or materials that need to be retrieved from a Back Office storage area. Traditional solutions fail in these environments due to:

- Unreliable or non-existent internet connectivity
- Need for immediate request acknowledgment
- Requirement for strict chronological processing
- Demand for quick verification and audit trails

## The Solution

Poster Runner uses device-to-device Bluetooth Low Energy communication to:

- Instantly transmit poster requests from Front Desk to Back Office
- Maintain a prioritized queue based on request arrival time
- Provide real-time fulfillment status updates
- Create an auditable record of all completed requests
- Continue operating seamlessly during connectivity interruptions

## Key Features

### For Front Desk Staff

**Request Entry**
- Single-field input for rapid poster number entry
- Instant transmission confirmation via BLE
- Automatic local caching during connection issues

**Delivery Audit**
- Complete alphabetically-sorted list of fulfilled requests
- Quick lookup for client verification
- Persistent record of all completed pulls

### For Back Office Staff

**Live Request Queue**
- Chronologically ordered list of unfulfilled requests
- Fair, first-come-first-served processing
- One-tap fulfillment marking

**Delivery Audit**
- Shared view of completed requests
- Alphabetically sorted for easy reference
- Synchronized with Front Desk records

## Technical Highlights

### Offline-First Architecture

- **Local Persistence**: All data stored immediately using Hive database
- **Automatic Sync**: Intelligent reconnection protocol ensures data convergence
- **Zero Data Loss**: Write-immediately pattern guarantees request preservation

### BLE GATT Protocol

- **Server/Client Roles**: Back Office as authoritative server, Front Desk as client
- **Acknowledged Transactions**: Write-with-response and indication patterns ensure reliability
- **Full Queue Sync**: Reconciliation mechanism for complete state recovery

### Cross-Platform Support

Built with Flutter for:
- **iOS** (iPhone and iPad)
- **Android** (phones and tablets)

Native-quality UI with platform-specific optimizations.

## Design Philosophy

Poster Runner prioritizes **operational efficiency** and **reliability** over aesthetic decoration:

- **Clarity**: High-contrast colors and generous spacing for readability in any lighting
- **Speed**: Minimal data entry with large, accessible touch targets
- **Reliability**: Offline-first design with automatic synchronization
- **Accessibility**: WCAG AA compliant with support for various abilities and environments

## Technology Stack

- **Framework**: Flutter 3.35+
- **Language**: Dart 3.9+
- **Persistence**: Hive (local NoSQL database)
- **Communication**: Bluetooth Low Energy (BLE GATT protocol)
- **Design**: Material Design 3

## Project Structure

```
poster-runner/
├── app/                          # Flutter application
│   ├── lib/                      # Application source code
│   └── test/                     # Test files
├── project_standards/            # Design specifications
│   ├── Product Requirements Document (PRD) - Poster Runner.md
│   ├── BLE GATT Architecture Design.md
│   ├── Data Structure Specification.md
│   ├── Local Persistence Specification.md
│   ├── Synchronization Protocol and Error Handling.md
│   ├── project-theme.md
│   ├── Front Desk UX Design Document.md
│   └── Back Office UX Design Document.md
└── CLAUDE.md                     # Developer guidance for Claude Code
```

## Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.35+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Version 3.9+ (included with Flutter)
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA with Flutter plugin
- **Device/Emulator**: iOS Simulator, Android Emulator, or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd poster-runner
   ```

2. **Navigate to the app directory**
   ```bash
   cd app
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```

### Running the App

#### Option 1: Run on Any Available Device
```bash
# List available devices
flutter devices

# Run on default device
flutter run
```

#### Option 2: Run on Specific Platform

**iOS Simulator (macOS only):**
```bash
# Open iOS Simulator first
open -a Simulator

# Then run the app
flutter run -d ios
```

**Android Emulator:**
```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator-id>

# Run the app
flutter run -d android
```

**Chrome (for quick UI testing):**
```bash
flutter run -d chrome
```

#### Option 3: Physical Device

**iOS Device:**
1. Connect your iPhone/iPad via USB
2. Trust the computer on your device
3. Run `flutter run`

**Android Device:**
1. Enable Developer Mode and USB Debugging on your device
2. Connect via USB
3. Run `flutter run`

### Hot Reload (During Development)

While the app is running:
- Press **`r`** for hot reload (preserves app state)
- Press **`R`** for hot restart (resets app state)
- Press **`q`** to quit

### Building for Release

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**iOS App:**
```bash
flutter build ios --release
# Then open in Xcode to archive and distribute
```

## Current Implementation Status

### ✅ Completed
- **UI Layer**: All screens and components fully implemented
- **Theme System**: Complete light/dark mode support
- **Role Selection**: Choose between Front Desk and Back Office roles
- **Front Desk Screens**: Request Entry + Delivered Audit tabs
- **Back Office Screens**: Live Queue + Fulfilled Log tabs
- **Reusable Components**: Status badges, list items, search widgets
- **Data Model**: `PosterRequest` class with status enum

### ⚠️ Not Yet Implemented (Using Placeholder Data)
- BLE communication layer
- Hive local persistence
- State management (Provider/Riverpod/BLoC)
- Actual data synchronization between devices
- Error handling and retry logic
- Role persistence (role selection resets on app restart)

### How to Test the Current Build

The app currently runs with **hardcoded placeholder data** to demonstrate the UI/UX:

1. **Launch the app** using `flutter run`
2. **Select a role** (Front Desk or Back Office)
3. **Explore the UI**:
   - Front Desk: Enter poster numbers, view delivered audit
   - Back Office: See pending requests, mark as fulfilled
4. **Test light/dark mode** via device settings
5. **Try search/filter** on audit screens

**Note:** All interactions are local-only and do not persist between app restarts. Data does not sync between devices.

## Project Structure

```
app/lib/
├── main.dart                          # App entry point
├── models/
│   └── poster_request.dart            # PosterRequest data model
├── theme/
│   └── app_theme.dart                 # Theme configuration (light/dark)
├── widgets/
│   ├── status_badge.dart              # Reusable status indicator
│   ├── request_list_item.dart         # Reusable list item
│   └── search_bar_widget.dart         # Search input field
├── screens/
│   ├── role_selection_screen.dart     # Role selection
│   ├── front_desk/
│   │   ├── front_desk_home.dart       # Front Desk navigation
│   │   ├── request_entry_screen.dart  # Request entry screen
│   │   └── delivered_audit_screen.dart # Audit log screen
│   └── back_office/
│       ├── back_office_home.dart      # Back Office navigation
│       ├── live_queue_screen.dart     # Live queue screen
│       └── fulfilled_log_screen.dart  # Fulfilled log screen
```

## Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Code Formatting
```bash
flutter format .
```

## Next Steps

To complete the application, the following components need to be implemented:

1. **BLE Service Layer** (`lib/services/ble_service.dart`)
   - GATT server/client setup
   - Characteristic definitions
   - Request/status transmission

2. **Persistence Layer** (`lib/services/persistence_service.dart`)
   - Hive database initialization
   - PosterRequest storage
   - Sync flag management

3. **State Management** (Provider, Riverpod, or BLoC)
   - Global app state
   - Real-time data updates
   - Role persistence

4. **Synchronization Service** (`lib/services/sync_service.dart`)
   - Three-step reconnection handshake
   - Conflict resolution
   - Error handling

See `CLAUDE.md` for detailed architecture and implementation guidance.

## License

[License information to be added]

## Contributing

[Contribution guidelines to be added]
