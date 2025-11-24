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
- Customizable letter buttons (A, B, C, D) with up to 3 characters each for event-specific shortcuts (e.g., MON/TUE/WED or VIP/GEN/STF)
- Single-field input accepts keypad or keyboard entry (no auto-focus to prevent unwanted keyboard popup)
- Input becomes read-only during submission to prevent accidental entry
- Instant transmission confirmation via BLE
- Automatic local caching during connection issues
- Offline queue badge showing count of pending sync requests

**Delivery Audit**
- Complete alphabetically-sorted list of fulfilled requests
- Quick lookup for client verification
- Persistent record of all completed pulls
- Real-time BLE connection status indicator (color-coded icon)
- Offline queue badge showing count of unsynced requests
- Settings menu with "Customize Letter Buttons", "Clear All Delivered", and theme selection (Light/Dark/System)

### For Back Office Staff

**Live Request Queue**
- Chronologically ordered list of unfulfilled requests
- Fair, first-come-first-served processing
- One-tap fulfillment marking
- Real-time BLE connection status indicator (color-coded icon)
- Offline queue badge showing count of unsynced status updates

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
- **iOS** (iPhone and iPad) - iOS 13.0+
- **Android** (phones and tablets) - Android 5.0+ (API 21+)
- **macOS** (MacBook, iMac, Mac mini) - macOS 10.15+ (Catalina or later)

Native-quality UI with platform-specific optimizations.

**Note:** Device matching uses BLE service UUID for cross-platform compatibility. macOS devices advertise with their system device name (e.g., "Alice's MacBook Pro") rather than a custom name.

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
├── docs/                         # Project documentation
│   ├── PRD.md                    # Product requirements overview
│   ├── TAD.md                    # Technical architecture overview
│   └── specs/                    # Detailed design specifications
│       ├── Product Requirements Document (PRD) - Poster Runner.md
│       ├── BLE GATT Architecture Design.md
│       ├── Data Structure Specification.md
│       ├── Local Persistence Specification.md
│       ├── Synchronization Protocol and Error Handling.md
│       ├── project-theme.md
│       ├── Front Desk UX Design Document.md
│       └── Back Office UX Design Document.md
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

## 📋 Development Roadmap

All planned work is tracked in GitHub Issues and BEADS. Current epics:

- [Epic #19: Phase 6 - Essential UX Feedback](https://github.com/joemc3/poster-runner/issues/19) - **IN PROGRESS** (P0)
- [Epic #20: Phase 7 - Testing & QA](https://github.com/joemc3/poster-runner/issues/20) - Next (P1)
- [Epic #21: Phase 8 - Production Readiness](https://github.com/joemc3/poster-runner/issues/21) - Important (P2)
- [Epic #22: Phase 9 - Nice-to-Have Features](https://github.com/joemc3/poster-runner/issues/22) - Optional (P3)

View current work:
```bash
# See ready tasks
bd ready --limit 5

# View project stats
bd stats

# List all issues
gh issue list
```

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
│   ├── keypad_customization_provider.dart # A, B, C, D button customization (✅ Phase 6)
│   ├── ble_connection_provider.dart   # BLE connection state (✅ Phase 4 - integrated)
│   ├── front_desk_provider.dart       # Front Desk data & ops (✅ Phase 4 - BLE integrated)
│   └── back_office_provider.dart      # Back Office data & ops (✅ Phase 4 - BLE integrated)
├── theme/
│   └── app_theme.dart                 # Theme configuration (✅ Complete)
├── widgets/
│   ├── status_badge.dart              # Status indicator widget (✅ Complete)
│   ├── request_list_item.dart         # List item widget (✅ Complete)
│   ├── search_bar_widget.dart         # Search input widget (✅ Complete)
│   ├── poster_entry_keypad.dart       # Custom keypad for poster number entry (✅ Complete with customization)
│   ├── sync_badge.dart                # Offline queue badge indicator (✅ Complete)
│   └── customize_keypad_dialog.dart   # Dialog for customizing A, B, C, D button labels (✅ Phase 6)
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

## Development

All work is tracked in [GitHub Issues](https://github.com/joemc3/poster-runner/issues). See:
- [Epic #35](https://github.com/joemc3/poster-runner/issues/35) - Foundation work (Phases 1-5) - COMPLETE
- [Epic #19](https://github.com/joemc3/poster-runner/issues/19) - Phase 6: Essential UX Feedback - IN PROGRESS
- [Epic #20](https://github.com/joemc3/poster-runner/issues/20) - Phase 7: Testing & QA
- [Epic #21](https://github.com/joemc3/poster-runner/issues/21) - Phase 8: Production Readiness
- [Epic #22](https://github.com/joemc3/poster-runner/issues/22) - Phase 9: Nice-to-Have Features

See `CLAUDE.md` for architecture and implementation guidance.

## License

[License information to be added]

## Contributing

[Contribution guidelines to be added]
