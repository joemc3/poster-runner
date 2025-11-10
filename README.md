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

**Fulfilled Log**
- Shared view of completed requests
- Alphabetically sorted for easy reference
- Synchronized with Front Desk records
- Settings menu with "Clear All" functionality
- Persistent storage management

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

- **Clarity**: High-contrast theme with pure white backgrounds and true black text for maximum readability in any lighting
- **Speed**: Minimal data entry with large, accessible touch targets (56dp minimum)
- **Reliability**: Offline-first design with automatic synchronization
- **Accessibility**: WCAG AAA compliant (7:1+ contrast ratios) with support for various abilities and environments

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

### ✅ Completed (Phase 1 - Persistence Layer Complete!)
- **UI Layer**: All screens and components fully implemented with real persistence
- **High-Contrast Theme System**: Complete light/dark mode support
  - Pure white backgrounds (#FFFFFF) with true black text (#000000)
  - WCAG AAA compliant (7:1+ contrast ratios) throughout
  - All UI components derive styling from centralized theme
  - Zero hardcoded colors, fonts, or theme values in implementation
- **Role Selection**: Choose between Front Desk and Back Office roles
- **Front Desk Screens**: Request Entry (saves to Hive) + Delivered Audit (reads from Hive)
- **Back Office Screens**: Live Queue + Fulfilled Log (both read/write to Hive)
- **Reusable Components**: Status badges, list items, search widgets
- **Data Model**: `PosterRequest` class with status enum and Hive adapters
- **Complete Persistence Layer**: Both Front Desk and Back Office data persist to Hive database
  - Back Office: fulfilled_requests box (pull functionality)
  - Front Desk: submitted_requests box (request entry) + delivered_audit box (fulfilled requests)
  - All data persists across app restarts
  - Real-time UI updates via ValueListenableBuilder
- **Data Management**: Settings menu with clear all functionality

### ⚠️ Not Yet Implemented
- BLE service implementation (package installed, not yet integrated)
- State management integration (Provider package installed, not yet wired up)
- Actual data synchronization between devices via BLE
- BLE retry logic and error handling
- Role persistence (role selection resets on app restart)

### How to Test the Current Build

1. **Launch the app** using `flutter run`
2. **Select a role** (Front Desk or Back Office)
3. **Test Front Desk** (NEW - Full Persistence!):
   - Enter poster numbers (e.g., "A457", "B123") - they save to Hive!
   - Submit multiple requests and see success confirmations
   - Switch to Delivered Audit tab (empty for now, will populate via BLE sync)
   - Restart the app - submitted requests persist!
4. **Test Back Office**:
   - See pending requests in Live Queue
   - Pull a poster request to mark it as fulfilled (persists to Hive)
   - View the fulfilled request in the Fulfilled Log tab
   - Restart the app - fulfilled requests persist
   - Use the settings menu (gear icon) to clear all fulfilled requests
5. **Test light/dark mode** via device settings
6. **Try search/filter** on audit screens

**Note:** Both Front Desk and Back Office data now persist to Hive database! Data does not yet sync between devices via BLE (Phase 2-6).

## Project Structure

```
app/lib/
├── main.dart                          # App entry point (✅ Hive initialized)
├── models/
│   ├── poster_request.dart            # PosterRequest data model (✅ Complete)
│   ├── poster_request.g.dart          # Generated Hive adapters (✅ Complete)
│   └── mock_data.dart                 # Mock data generator (✅ Complete)
├── theme/
│   └── app_theme.dart                 # Theme configuration (✅ Complete)
├── widgets/
│   ├── status_badge.dart              # Status indicator widget (✅ Complete)
│   ├── request_list_item.dart         # List item widget (✅ Complete)
│   └── search_bar_widget.dart         # Search input widget (✅ Complete)
├── screens/
│   ├── role_selection_screen.dart     # Role selection (✅ Complete)
│   ├── front_desk/
│   │   ├── front_desk_home.dart       # Navigation wrapper (✅ Complete)
│   │   ├── request_entry_screen.dart  # Request entry (✅ Saves to Hive)
│   │   └── delivered_audit_screen.dart # Audit log (✅ Reads from Hive)
│   └── back_office/
│       ├── back_office_home.dart      # Navigation wrapper (✅ Complete)
│       ├── live_queue_screen.dart     # Live queue (✅ Pull to Hive working)
│       └── fulfilled_log_screen.dart  # Fulfilled log (✅ Reads from Hive)
└── services/
    └── persistence_service.dart       # Hive storage (✅ COMPLETE - Both Front Desk & Back Office)
                                       # Note: ble_service.dart and sync_service.dart not yet created
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

1. **Phase 1: Add Front Desk Persistence** ✅ COMPLETED
   - ✅ Extended PersistenceService with front desk boxes (submitted_requests, delivered_audit)
   - ✅ Added 14 new methods for Front Desk operations including getUnsyncedSubmittedRequests()
   - ✅ Wired up Front Desk Request Entry screen to save to Hive
   - ✅ Wired up Front Desk Delivered Audit screen to read from Hive with real-time updates

2. **Phase 2: Add BLE Package & Platform Configuration** ✅ COMPLETED
   - ✅ Installed flutter_reactive_ble ^5.3.1 and provider ^6.1.2 packages
   - ✅ Configured Android Bluetooth permissions (API 31+ and legacy support)
   - ✅ Configured macOS Bluetooth permissions (Info.plist)
   - ✅ Configured macOS entitlements for Bluetooth (Debug and Release profiles)
   - ✅ Verified app builds successfully on macOS

3. **Phase 3: Implement State Management** 📋 NEXT
   - Create Provider models for BLE connection state
   - Create Provider models for request data
   - Replace local state with Provider-managed state
   - Wrap app in MultiProvider

4. **Phase 4: Implement BLE Service Layer** (`lib/services/ble_service.dart`)
   - GATT server/client setup
   - Back Office as GATT Server (Service A000, Characteristics A001/A002/A003)
   - Front Desk as GATT Client (scanning, connecting, subscribing)
   - Integrate with PosterRequest serialization methods

5. **Phase 5: Implement Synchronization Service** (`lib/services/sync_service.dart`)
   - Three-step reconnection handshake
   - isSynced flag management
   - Connection loss detection and offline caching

6. **Phase 6: UI Integration**
   - Connect all screens to providers for real-time updates
   - Add connection status indicators (Bluetooth icons)
   - Wire up BLE events to UI updates

7. **Phase 7: Testing & Polish**
   - Unit tests for serialization and persistence
   - Widget tests for all screens
   - Integration tests for sync scenarios
   - Add role persistence

See `CLAUDE.md` for detailed architecture and implementation guidance. See the todo list for all 25 tracked tasks across all phases.

## License

[License information to be added]

## Contributing

[Contribution guidelines to be added]
