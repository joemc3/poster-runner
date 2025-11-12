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
- Custom entry keypad with A-D, 0-9, dash, and ENTER button for rapid input
- Single-field input accepts keypad or keyboard entry (no auto-focus to prevent unwanted keyboard popup)
- Instant transmission confirmation via BLE
- Automatic local caching during connection issues

**Delivery Audit**
- Complete alphabetically-sorted list of fulfilled requests
- Quick lookup for client verification
- Persistent record of all completed pulls
- Real-time BLE connection status indicator (color-coded icon)
- Settings menu with "Clear All Delivered" and theme selection (Light/Dark/System)

### For Back Office Staff

**Live Request Queue**
- Chronologically ordered list of unfulfilled requests
- Fair, first-come-first-served processing
- One-tap fulfillment marking
- Real-time BLE connection status indicator (color-coded icon)

**Fulfilled Log**
- Shared view of completed requests
- Alphabetically sorted for easy reference
- Synchronized with Front Desk records
- Real-time BLE connection status indicator (color-coded icon)
- Settings menu with "Clear All Fulfilled" and theme selection
- Theme modes: Light, Dark, System (follows device settings)
- Persistent storage management with theme preference saved

## Technical Highlights

### Offline-First Architecture

- **Local Persistence**: All data stored immediately using Hive database
- **User Preferences**: Theme selection and app settings persist across restarts
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
- **Flexibility**: User-selectable Light/Dark/System theme modes to match user preference and environment
- **Speed**: Minimal data entry with large, accessible touch targets (56dp minimum)
- **Reliability**: Offline-first design with automatic synchronization
- **Accessibility**: WCAG AAA compliant (7:1+ contrast ratios) with support for various abilities and environments

## Technology Stack

- **Framework**: Flutter 3.35+
- **Language**: Dart 3.9+
- **State Management**: Provider ^6.1.2
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

### ✅ Completed (Phase 5 - Full BLE Working! + Phase 6 Started)
- **UI Layer**: All screens and components fully implemented with real persistence
- **Connection Status Indicators**: Real-time BLE status icons in Front Desk and Back Office headers (Phase 6.1 ✅)
- **Data Management**: "Clear All Delivered" option added to Front Desk settings menu (Phase 6.4 partial ✅)
- **High-Contrast Theme System**: Complete light/dark mode support
  - Pure white backgrounds (#FFFFFF) with true black text (#000000)
  - WCAG AAA compliant (7:1+ contrast ratios) throughout
  - All UI components derive styling from centralized theme
  - Zero hardcoded colors, fonts, or theme values in implementation
- **Role Selection**: Choose between Front Desk and Back Office roles with BLE initialization
- **Front Desk Screens**: Request Entry + Delivered Audit (integrated with BLE)
- **Back Office Screens**: Live Queue + Fulfilled Log (integrated with BLE)
- **Reusable Components**: Status badges, list items, search widgets
- **Data Model**: `PosterRequest` class with status enum and Hive adapters
- **Complete Persistence Layer**: Both Front Desk and Back Office data persist to Hive database
  - Back Office: fulfilled_requests box (pull functionality)
  - Front Desk: submitted_requests box (request entry) + delivered_audit box (fulfilled requests)
  - All data persists across app restarts
  - Real-time UI updates via Provider and Hive listeners
- **Data Management**: Settings menu with clear all functionality and theme selection
- **State Management**: Complete Provider architecture
  - ThemeProvider for light/dark/system theme selection
  - BleConnectionProvider for connection state
  - FrontDeskProvider for Front Desk data and operations
  - BackOfficeProvider for Back Office data and operations
  - All screens integrated with Consumer pattern
  - Clean architecture: UI ← Providers ← PersistenceService ← Hive
- **BLE Service Layer**: Complete implementation with real device testing
  - BLE GATT Client for Front Desk (flutter_reactive_ble)
  - BLE GATT Server for Back Office (ble_peripheral)
  - Permission handling (Android 12+, iOS) via permission_handler
  - BLE initialization on role selection with error handling
  - MTU negotiation (512 bytes) for larger JSON payloads
  - Service discovery with proper timing (2-second wait)
  - CCCD descriptor auto-configuration for notifications
  - Payload buffering for fragmented messages
  - Sync orchestration with three-step reconnection handshake
  - Retry logic (3 attempts with 2-second delay)
  - All 3 characteristics implemented (Request A, Queue Status B, Full Queue Sync C)
  - Providers fully wired to BLE services
  - Offline-first design with automatic queueing
  - Mock data removed - app starts with clean state

### ✅ What's Working on Real Devices
- Front Desk → Back Office communication (sending poster requests via BLE) ✅ TESTED
- Back Office → Front Desk communication (sending status updates via BLE) ✅ TESTED
- BLE connection establishment and service discovery ✅ WORKING
- Notification subscription (Front Desk subscribes to Queue Status updates) ✅ WORKING
- Full JSON payload transmission (MTU negotiation working) ✅ WORKING
- Request parsing and queue display on Back Office ✅ WORKING
- Status update parsing and delivered audit updates on Front Desk ✅ WORKING
- Bidirectional sync with persistence integration ✅ WORKING
- Offline-first with automatic reconnection sync ✅ WORKING

### 📋 Next Phases (Phases 6-9)

**Phase 6 - Essential UX Feedback (IN PROGRESS - 1 week):**
- ✅ Connection status indicators showing real-time BLE state (DONE - color-coded icons in app headers)
- 📋 Visual indicators for unsynced offline requests (TODO - badge showing count)
- 📋 Better error handling and user feedback for BLE operations (TODO - improved error messages)
- ⚡ Settings screen improvements (PARTIAL - "Clear All Delivered" for Front Desk DONE, About/diagnostics TODO)

**Phase 7 - Testing & QA (2-3 weeks):**
- Comprehensive unit tests (60%+ coverage target)
- Widget tests for all screens and components
- Integration tests for BLE sync scenarios

**Phase 8 - Production Readiness (1 week):**
- App store preparation (icons, screenshots, metadata)
- Structured logging and diagnostics
- User documentation and troubleshooting guides

**Phase 9 - Post v1.0 Enhancements (Optional):**
- Role persistence (save role selection across app restarts)
- Request history/audit trail with export capabilities
- Multi-device support (multiple Front Desks → one Back Office)
- Advanced sync features (manual sync, conflict resolution)

### How to Setup and Test BLE Synchronization

**IMPORTANT:** BLE synchronization requires **TWO physical devices** (or one physical device + one simulator for testing). You cannot test BLE sync with two simulators.

#### Prerequisites

- **Two devices** running the app:
  - **Back Office:** iOS or Android device (macOS not supported for BLE server)
  - **Front Desk:** iOS, Android, or macOS (all platforms supported for BLE client)
- **Bluetooth enabled** on both devices
- **Location permissions** granted (Android requirement for BLE scanning)
- **Devices in close proximity** (within Bluetooth range, typically <10 meters)

**Important:** Due to BLE peripheral mode limitations, **Back Office cannot run on macOS**. Use an iPhone, iPad, or Android device for Back Office. Front Desk works on all platforms including macOS.

#### Setup Instructions

**Step 1: Start the Back Office Device (GATT Server)**

1. Launch the app on the first device
2. **Tap "Back Office"** on the role selection screen
3. Wait for "Initializing Bluetooth..." message
4. Once initialized, you'll see the Live Queue screen
5. The device is now **advertising** as "Poster Runner - Back Office"
6. **Look for BLE initialization logs** in console (if running from IDE)

**Step 2: Start the Front Desk Device (GATT Client)**

1. Launch the app on the second device
2. **Tap "Front Desk"** on the role selection screen
3. Wait for "Initializing Bluetooth..." message
4. The app will automatically **scan for** the Back Office device
5. Once found, it will **connect automatically**
6. Watch for connection status in the console logs

**Step 3: Test Synchronization**

**On Front Desk:**
1. Navigate to "Request Entry" tab
2. Enter a poster number (e.g., "A457")
3. Tap "SUBMIT REQUEST"
4. **Watch the request transmit via BLE** to Back Office
5. Check console for: `[Sync Service] Sending new request via BLE`

**On Back Office:**
1. The request should **appear immediately** in the Live Queue
2. Check console for: `[Sync Service] Received incoming request`
3. Tap "PULL" on the request to mark it as fulfilled
4. **Watch the status update transmit via BLE** to Front Desk

**On Front Desk (Delivered Audit):**
1. Switch to "Delivered Audit" tab
2. The fulfilled request should **appear automatically**
3. Check console for: `[Sync Service] Received status update`

#### Troubleshooting

**If devices don't connect:**

1. **Check Bluetooth permissions:**
   - iOS: Settings → Privacy → Bluetooth → Poster Runner (Allow)
   - Android: Settings → Apps → Poster Runner → Permissions → Nearby devices (Allow)
   - Android: Ensure Location Services are enabled (required for BLE scanning)

2. **Check console logs for errors:**
   ```
   [BLE Initializer] Initializing for Back Office
   [BLE Server Service] Starting advertising...
   [BLE Server Service] Advertising started successfully
   ```
   ```
   [BLE Initializer] Initializing for Front Desk
   [BLE Service] Starting scan for Back Office...
   [BLE Service] Found device: Poster Runner - Back Office
   [BLE Service] Connected to device
   ```

3. **Restart the app** on both devices (especially if you switched roles)

4. **Reset Bluetooth:**
   - Turn Bluetooth OFF then ON on both devices
   - Relaunch the app

5. **Check device compatibility:**
   - iOS 10.0+ required
   - Android 5.0+ (API 21+) required
   - BLE 4.0+ hardware required
   - **macOS BLE peripheral mode limitation:** The `ble_peripheral` package has known issues with macOS. Back Office may timeout when adding services. For full BLE functionality, test on iOS or Android devices.

**If you get "Service addition timed out" error on macOS:**

This is a **known limitation** of the `ble_peripheral` package on macOS. The error occurs when trying to initialize Back Office BLE GATT server on macOS.

**Workaround Options:**
1. **Use iOS/Android for Back Office** (RECOMMENDED):
   - Deploy Back Office to an iPhone, iPad, or Android device
   - Deploy Front Desk to macOS, iOS, or Android
   - This configuration will work correctly

2. **Use macOS for Front Desk only**:
   - Front Desk (GATT Client) works perfectly on macOS
   - Back Office (GATT Server) needs iOS or Android

3. **Test UI without BLE**:
   - You can still test UI, persistence, and offline mode on macOS
   - Submit requests - they save to Hive database
   - Just won't sync between devices until you deploy to iOS/Android

**Why this happens:**
- macOS CoreBluetooth has stricter requirements for BLE peripheral mode
- The `ble_peripheral` Flutter package has limited macOS support
- iOS and Android have full support for BLE GATT server functionality

**If sync doesn't work after connection:**

1. **Check for BLE transmission errors** in console:
   ```
   [Front Desk Provider] BLE transmission failed - request queued for sync
   ```

2. **Verify Back Office is in GATT server mode:**
   - Only ONE Back Office device should be running at a time
   - Back Office must be started BEFORE Front Desk

3. **Test the three-step handshake:**
   - Submit a request on Front Desk while disconnected
   - Reconnect to Back Office
   - Watch console for: `[Sync Service] Executing reconnection handshake`

#### Testing Offline Mode

**Test 1: Offline Request Submission**
1. Start Front Desk WITHOUT starting Back Office
2. Submit several poster requests
3. Requests save to local Hive database with `isSynced: false`
4. Start Back Office and connect
5. Watch requests sync automatically via reconnection handshake

**Test 2: Offline Request Fulfillment**
1. Connect Front Desk and Back Office
2. Submit a request from Front Desk
3. **Disconnect** Front Desk (close app or turn off Bluetooth)
4. Mark request as fulfilled on Back Office
5. Reconnect Front Desk
6. Watch status update sync automatically

**Test 3: Connection Loss Recovery**
1. Connect both devices
2. Move devices out of Bluetooth range
3. Submit/fulfill requests while disconnected
4. Move devices back in range
5. Watch automatic reconnection and sync

#### Development Testing (Single Device)

If you only have one physical device, you can test partial functionality:

**Option 1: Physical Device + Simulator**
- Run Back Office on physical device (GATT server requires real Bluetooth)
- Run Front Desk on simulator/emulator
- **Note:** BLE connection will NOT work, but you can test UI and offline persistence

**Option 2: Mock Data Testing**
- Use the existing mock data in `lib/models/mock_data.dart`
- Test UI, persistence, and state management
- Test offline mode (requests save to Hive)

**Option 3: Chrome Testing (UI Only)**
```bash
flutter run -d chrome
```
- Test UI layouts and theme
- BLE will not function in web mode

#### Console Output Reference

**Successful Connection Flow:**
```
[BLE Initializer] Initializing for Back Office
[BLE Server Service] Initializing...
[BLE Server Service] Starting advertising
[BLE Server Service] Advertising started: Poster Runner - Back Office

[BLE Initializer] Initializing for Front Desk
[BLE Service] Initializing for Front Desk role
[BLE Service] Starting scan...
[BLE Service] Found device: Poster Runner - Back Office (RSSI: -45)
[BLE Service] Connecting to device...
[BLE Service] Connected successfully
[BLE Connection Provider] Connection state: connected
[Sync Service] Executing reconnection handshake
[Sync Service] Step 1: Pushing unsynced requests (0 requests)
[Sync Service] Step 3: Reading full queue sync
[Sync Service] Reconnection handshake complete
```

**Successful Request Sync:**
```
[Front Desk Provider] Submitting request: A457
[Persistence Service] Saved submitted request: A457
[Sync Service] Sending new request via BLE
[BLE Service] Writing to Request Characteristic (A)
[BLE Service] Write successful

[BLE Server Service] Received write request on characteristic: 0000A001...
[Sync Service] Received incoming request: A457
[Back Office Provider] Adding request to queue: A457
```

**Successful Status Update Sync:**
```
[Back Office Provider] Fulfilling request: A457
[Persistence Service] Saved fulfilled request: A457
[Sync Service] Sending status update via BLE
[BLE Server Service] Sending notification on Queue Status Characteristic (B)

[BLE Service] Received notification on Queue Status Characteristic
[Sync Service] Received status update for: A457
[Front Desk Provider] Updating delivered audit: A457
[Persistence Service] Saved to delivered audit: A457
```

## Project Structure

```
app/lib/
├── main.dart                          # App entry point (✅ Hive + MultiProvider initialized)
├── models/
│   ├── poster_request.dart            # PosterRequest data model (✅ Complete)
│   ├── poster_request.g.dart          # Generated Hive adapters (✅ Complete)
│   └── mock_data.dart                 # Mock data generator (✅ Complete)
├── providers/
│   ├── theme_provider.dart            # Theme management (✅ Complete)
│   ├── ble_connection_provider.dart   # BLE connection state (✅ Phase 4 - integrated)
│   ├── front_desk_provider.dart       # Front Desk data & ops (✅ Phase 4 - BLE integrated)
│   └── back_office_provider.dart      # Back Office data & ops (✅ Phase 4 - BLE integrated)
├── theme/
│   └── app_theme.dart                 # Theme configuration (✅ Complete)
├── widgets/
│   ├── status_badge.dart              # Status indicator widget (✅ Complete)
│   ├── request_list_item.dart         # List item widget (✅ Complete)
│   ├── search_bar_widget.dart         # Search input widget (✅ Complete)
│   └── poster_entry_keypad.dart       # Custom keypad for poster number entry (✅ Complete)
├── screens/
│   ├── role_selection_screen.dart     # Role selection (✅ Complete)
│   ├── front_desk/
│   │   ├── front_desk_home.dart       # Navigation wrapper (✅ Complete)
│   │   ├── request_entry_screen.dart  # Request entry (✅ Uses FrontDeskProvider)
│   │   └── delivered_audit_screen.dart # Audit log (✅ Uses FrontDeskProvider)
│   └── back_office/
│       ├── back_office_home.dart      # Navigation wrapper (✅ Complete)
│       ├── live_queue_screen.dart     # Live queue (✅ Uses BackOfficeProvider)
│       └── fulfilled_log_screen.dart  # Fulfilled log (✅ Uses BackOfficeProvider)
└── services/
    ├── persistence_service.dart       # Hive storage (✅ Complete - Both Front Desk & Back Office)
    ├── ble_service.dart               # BLE GATT Client (✅ Phase 4 - Front Desk)
    ├── ble_server_service.dart        # BLE GATT Server (✅ Phase 4 - Back Office)
    ├── sync_service.dart              # Sync orchestration (✅ Phase 4 - 3-step handshake)
    └── ble_initializer.dart           # BLE initialization (✅ Phase 4 - role-based setup)
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

3. **Phase 3: Implement State Management** ✅ COMPLETED
   - ✅ Created BleConnectionProvider for BLE connection state management
   - ✅ Created FrontDeskProvider for Front Desk data and operations
   - ✅ Created BackOfficeProvider for Back Office data and operations
   - ✅ Replaced local state with Provider-managed state in all screens
   - ✅ Wrapped app in MultiProvider in main.dart
   - ✅ Integrated all screens with Consumer pattern
   - ✅ Clean architecture: UI ← Providers ← PersistenceService ← Hive

4. **Phase 4: Implement BLE Service Layer** ✅ COMPLETED
   - ✅ Created BLE GATT Client service (ble_service.dart) using flutter_reactive_ble
   - ✅ Created BLE GATT Server service (ble_server_service.dart) using ble_peripheral
   - ✅ Implemented all 3 characteristics (Request A, Queue Status B, Full Queue Sync C)
   - ✅ Back Office as GATT Server with advertising
   - ✅ Front Desk as GATT Client with scanning, connecting, subscribing
   - ✅ Integrated PosterRequest serialization methods with BLE payloads

5. **Phase 5: Implement Synchronization Service** ✅ COMPLETED
   - ✅ Created sync_service.dart with three-step reconnection handshake
   - ✅ Implemented retry logic (3 attempts with 2-second delay)
   - ✅ Automatic connection state monitoring and recovery
   - ✅ Coordinated BLE services with providers via dependency injection
   - ✅ Created ble_initializer.dart for lazy role-based initialization
   - ✅ Wired FrontDeskProvider and BackOfficeProvider to BLE services

6. **Phase 6: Real Device Testing** ✅ COMPLETED
   - ✅ Tested BLE communication on actual hardware devices (iOS and Android)
   - ✅ Called BleInitializer in role selection screen
   - ✅ Tested end-to-end BLE synchronization (Front Desk → Back Office → Front Desk)
   - ✅ Verified bidirectional communication working
   - ✅ Tested offline mode and automatic reconnection sync
   - ✅ Confirmed persistence integration with BLE sync

7. **Phase 6: Essential UX Feedback** ⚡ IN PROGRESS (1 week)
   - ✅ Connection status indicators (DONE - Real-time BLE status icons with color coding)
   - 📋 Offline queue indicators (TODO - Badge showing count of unsynced requests)
   - 📋 Error handling & user feedback (TODO - Better BLE error messages)
   - ⚡ Settings screen improvements (PARTIAL - "Clear All Delivered" for Front Desk DONE, About/diagnostics TODO)

8. **Phase 8: Testing & Quality Assurance** (2-3 weeks)
   - Unit tests for BLE services, providers, and persistence (60%+ coverage)
   - Widget tests for all 7 screens and components
   - Integration tests for full BLE sync scenarios
   - Performance testing and optimization

9. **Phase 9: Production Readiness** (1 week)
   - App store preparation (icons, screenshots, metadata, privacy policy)
   - Structured logging and diagnostics
   - User documentation and troubleshooting guides

10. **Phase 10: Post v1.0 Enhancements** (Optional)
   - Role persistence (save role selection across app restarts)
   - Request history/audit trail (searchable archive, CSV export, analytics)
   - Multi-device support (multiple Front Desks → one Back Office)
   - Advanced sync features (manual sync, conflict resolution UI, batch operations)

See `CLAUDE.md` for detailed architecture and implementation guidance.

## License

[License information to be added]

## Contributing

[Contribution guidelines to be added]
