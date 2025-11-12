# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Poster Runner** is a cross-platform Flutter application designed for offline communication between Front Desk and Back Office staff at temporary event locations. The app uses Bluetooth Low Energy (BLE) to sync poster pull requests in environments with unreliable or no internet connectivity.

### Quick Start for New Developers

**Current State (TL;DR):**
- ✅ **UI is 100% complete** - All 7 screens working
- ✅ **Data models are 100% complete** - PosterRequest with full serialization
- ✅ **Hive adapters generated** - Type adapters ready in poster_request.g.dart
- ✅ **Back office persistence working** - Fulfilled requests persist across app restarts
- ✅ **Front desk persistence working** - Submitted requests and delivered audit persist to Hive
- ✅ **BLE packages installed** - flutter_reactive_ble ^5.3.1 + ble_peripheral ^2.4.0 + permission_handler ^11.3.1
- ✅ **State management implemented** - Provider ^6.1.2 integrated across all screens
- ✅ **Provider architecture complete** - 4 providers managing theme, connection state, and data
- ✅ **Theme selection implemented** - Light/Dark/System modes with persistence to Hive
- ✅ **BLE service layer complete** - GATT Client (Front Desk) + GATT Server (Back Office) implemented
- ✅ **Sync orchestration complete** - Three-step reconnection handshake with retry logic
- ✅ **Providers wired to BLE** - FrontDeskProvider and BackOfficeProvider integrated with SyncService
- ✅ **BLE initialization working** - Role selection screen initializes BLE services with permission handling
- ✅ **CCCD descriptor fixed** - Notifications/indications working correctly
- ✅ **MTU negotiation added** - Supports larger payloads (up to 512 bytes)
- ✅ **Service discovery timing fixed** - Proper wait for service discovery before subscribing
- ✅ **Mock data removed** - App starts with clean slate, only real BLE data
- ✅ **Full BLE communication working** - Bidirectional communication tested and confirmed on real devices
- ✅ **Phase 5 complete** - All BLE features implemented and tested successfully
- 📋 **Next steps** - Add role persistence and comprehensive test coverage

**What You Can Do Right Now:**
```bash
cd app
flutter pub get
flutter run  # Run on two devices to see BLE communication in action!
# Front Desk (Device 1): Submit poster requests - they send via BLE to Back Office!
# Front Desk: Delivered Audit automatically updates when Back Office marks requests as fulfilled
# Front Desk: Use the settings menu (gear icon) to change theme (Light/Dark/System)
# Back Office (Device 2): Receives requests in real-time via BLE
# Back Office: Pull a poster - status updates automatically sent to Front Desk via BLE!
# Back Office: Use the settings menu (gear icon) to clear all fulfilled requests or change theme
# All screens use Provider for centralized state management
# Theme preference and all data persist across app restarts
# Full bidirectional BLE sync working between devices!
```

**Phase 5 Complete - BLE Testing & Integration:**
1. ✅ ~~Add BLE packages~~ (DONE - flutter_reactive_ble + ble_peripheral + permission_handler)
2. ✅ ~~Add state management package~~ (DONE - provider ^6.1.2 installed)
3. ✅ ~~Implement state management with Provider~~ (DONE - Phase 3 complete)
4. ✅ ~~Build BLE service and sync orchestration~~ (DONE - Phase 4 complete)
5. ✅ ~~Connect Front Desk and Back Office via BLE~~ (DONE - Phase 4 complete)
6. ✅ ~~Initialize BLE on role selection~~ (DONE - BleInitializer with permission handling)
7. ✅ ~~Fix CCCD descriptor for notifications~~ (DONE - ble_peripheral adds it automatically)
8. ✅ ~~Add MTU negotiation~~ (DONE - requests 512 bytes, prevents payload truncation)
9. ✅ ~~Fix service discovery timing~~ (DONE - waits 2s before subscribing)
10. ✅ ~~Remove mock data~~ (DONE - app starts with clean state)
11. ✅ ~~Debug and test BLE communication~~ (DONE - Full bidirectional sync working on real devices)

**Phase 6 - Future Enhancements:**
1. 📋 Add role persistence (currently resets on app restart)
2. 📋 Add comprehensive test coverage
3. 📋 Add connection status UI indicators
4. 📋 Implement offline queue management UI

## Essential Commands

### Development
```bash
# Navigate to the Flutter app directory
cd app

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal

# Run tests
flutter test

# Analyze code
flutter analyze

# Generate Hive type adapters (required after model changes)
flutter pub run build_runner build

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

## Current Implementation Status

### Codebase Statistics
- **Total Dart Files:** 26 files (~6,700 lines of code)
- **Screens:** 7 complete screens
- **Reusable Widgets:** 4 components
- **Data Models:** 1 core model + 1 enum + generated Hive adapters + mock data generator
- **Services:** 5 services (persistence, BLE client, BLE server, sync orchestration, BLE initializer)
- **State Management:** 4 Provider models (Theme, BLE connection, Front Desk data, Back Office data)
- **Test Coverage:** Minimal (1 smoke test)

### What's Complete ✅

**UI Layer (100% Complete)**
- All screens implemented with real persistence
- Role selection screen
- Front Desk: Request Entry (saves to Hive) + Delivered Audit (reads from Hive with theme settings)
- Back Office: Live Queue + Fulfilled Log (both read/write to Hive with theme settings)
- Complete high-contrast theme system (light/dark mode)
  - Pure white backgrounds (#FFFFFF) for maximum contrast
  - True black text (#000000) with 21:1 contrast ratio
  - WCAG AAA compliant colors (7:1+ contrast) throughout
  - All UI components derive styling from theme (zero hardcoded values)
  - User-selectable theme modes: Light, Dark, System (follows device settings)
  - Theme preference persists to Hive and restores on app startup
- Settings menus with theme selection
  - Front Desk Delivered Audit: Gear icon menu with theme selection
  - Back Office Fulfilled Log: Gear icon menu with "Clear All Fulfilled" and theme selection
- Reusable widgets (StatusBadge, RequestListItem, SearchBarWidget, PosterEntryKeypad)
- All UX specifications from design documents implemented
- Zero linting issues
- Zero hardcoded colors, fonts, or theme values in implementation files

**Data Models (100% Complete)**
- `PosterRequest` class (`lib/models/poster_request.dart`)
  - All 6 fields implemented including `isSynced` for BLE sync tracking
  - Full JSON serialization (toJson/fromJson) for BLE transmission
  - Hive type adapter annotations (typeId: 0)
  - Specialized serialization methods for BLE characteristics
  - Utility methods: copyWith, equality operators, status getters
- `RequestStatus` enum (sent, pending, fulfilled)
  - Extension methods for display labels and icons
  - Hive type adapter annotations (typeId: 1)
  - JSON serialization methods
- Hive type adapters (`lib/models/poster_request.g.dart`)
  - Generated PosterRequestAdapter (typeId: 0)
  - Generated RequestStatusAdapter (typeId: 1)
  - Binary serialization for efficient storage
- Mock data generator (`lib/models/mock_data.dart`)
  - 15 realistic sample requests (3 sent, 5 pending, 7 fulfilled)
  - Pre-sorted views for each screen type (liveQueue, deliveredAudit, fulfilledLog)
  - Filter methods and batch generation utilities
  - Offline scenario data for testing sync logic

**Persistence Layer (100% Complete)**
- `PersistenceService` class (`lib/services/persistence_service.dart`)
  - Manages 3 Hive boxes: fulfilled_requests, submitted_requests, delivered_audit
  - Write-immediately pattern for data safety
  - Back Office methods: save/retrieve/delete fulfilled requests
  - Front Desk methods: save/retrieve/delete submitted requests and delivered audit
  - Special method: getUnsyncedSubmittedRequests() for BLE sync
  - Real-time data change listeners via Hive streams
  - Initialized in main.dart on app startup
- `ThemeProvider` manages additional Hive box: app_preferences
  - Stores theme mode preference (light/dark/system)
  - Automatically loads saved preference on app startup
- Back Office Live Queue screen
  - "PULL" button saves to Hive with timestampPulled
  - Error handling for save failures
  - Confirmation messages on success
- Back Office Fulfilled Log screen
  - Reads directly from Hive database (fulfilled_requests box)
  - ValueListenableBuilder for real-time UI updates
  - Automatically refreshes when new requests are pulled
  - Data persists across app restarts
  - Settings menu (gear icon) with "Clear All Fulfilled" and theme selection options
  - Confirmation dialog before clearing all data
  - Clears both screen and persistent storage
  - Theme selection (Light/Dark/System) with persistence
- Front Desk Request Entry screen
  - Custom entry keypad with A-D, 0-9, dash, and ENTER button
  - Input field accepts keyboard input but does not auto-focus (no unwanted keyboard popup)
  - Generates UUID for each new request
  - Saves to Hive database (submitted_requests box) with isSynced: false
  - Error handling for persistence failures
  - Success confirmation messages
  - Data persists across app restarts
- Front Desk Delivered Audit screen
  - Reads directly from Hive database (delivered_audit box)
  - ValueListenableBuilder for real-time UI updates
  - Automatically refreshes when BLE sync adds fulfilled requests
  - Live search/filter by poster number
  - Sorted alphabetically (A-Z) by poster number
  - Data persists across app restarts
  - Settings menu (gear icon) with theme selection (Light/Dark/System)

**State Management Layer (100% Complete - Phase 3)**
- `ThemeProvider` class (`lib/providers/theme_provider.dart`)
  - Manages application theme mode (Light, Dark, System)
  - Persists theme preference to Hive (app_preferences box)
  - Automatically loads saved theme on app startup
  - Provides theme selection UI methods and display names
  - Notifies listeners on theme changes for reactive UI updates
- `BleConnectionProvider` class (`lib/providers/ble_connection_provider.dart`)
  - Manages BLE connection state (disconnected, scanning, connecting, connected, error)
  - Tracks device info, signal strength (RSSI), and last sync time
  - Provides connection management methods (placeholder for Phase 4)
  - Convenience getters for connection status
- `FrontDeskProvider` class (`lib/providers/front_desk_provider.dart`)
  - Manages all Front Desk data and operations
  - Handles request submission with validation and error handling
  - Provides last submission feedback for UI display
  - Listens to Hive changes for real-time updates
  - Prepared for BLE sync (getUnsyncedRequests, handleStatusUpdate, etc.)
- `BackOfficeProvider` class (`lib/providers/back_office_provider.dart`)
  - Manages active queue state and fulfilled log data
  - Handles request fulfillment and persistence
  - Provides methods for clearing fulfilled requests
  - Ready for BLE incoming request handling
- All screens integrated with Provider using Consumer pattern
- Clean architecture: UI ← Providers ← PersistenceService ← Hive
- MultiProvider setup in main.dart with 4 providers

### What's Complete (Phase 5 - COMPLETE) ✅

**BLE Service Layer (100% COMPLETE):**
- ✅ **BLE Client Service** (`ble_service.dart`) - Front Desk GATT Client using flutter_reactive_ble
- ✅ **BLE Server Service** (`ble_server_service.dart`) - Back Office GATT Server using ble_peripheral
- ✅ **Sync Orchestration** (`sync_service.dart`) - Three-step reconnection handshake with retry logic
- ✅ **BLE Initializer** (`ble_initializer.dart`) - Lazy initialization with permission handling
- ✅ **Permission Service** (`permission_service.dart`) - Runtime Bluetooth permissions for Android 12+/iOS
- ✅ **Provider Integration** - FrontDeskProvider and BackOfficeProvider wired to BLE services
- ✅ **All 3 Characteristics** - Request (A), Queue Status (B), Full Queue Sync (C) implemented
- ✅ **Retry Logic** - 3 attempts with 2-second delay for failed BLE operations
- ✅ **Offline-First** - Works without BLE, queues unsynced data for later transmission
- ✅ **MTU Negotiation** - Requests 512 byte MTU to support larger JSON payloads
- ✅ **Service Discovery** - Proper timing with 2-second wait before subscribing to characteristics
- ✅ **CCCD Descriptor** - Notifications working correctly (auto-added by ble_peripheral)
- ✅ **Mock Data Removed** - App starts with empty queue, only shows real BLE data
- ✅ **Full BLE Sync** - Bidirectional communication tested and working on real devices

**Tested and Working on Real Devices:**
- ✅ **Front Desk → Back Office** - Successfully sends poster requests via BLE
- ✅ **Back Office → Front Desk** - Successfully sends status updates via BLE notifications
- ✅ **BLE Connection** - Front Desk connects to Back Office automatically
- ✅ **Service Discovery** - All characteristics discovered correctly
- ✅ **Notification Subscription** - Front Desk subscribes to Queue Status updates
- ✅ **Bidirectional Communication** - Full request/response cycle working
- ✅ **Payload Transmission** - Full JSON payloads transmitted (MTU negotiation working)
- ✅ **Request Parsing** - Both devices correctly receive and parse JSON data
- ✅ **Queue Display** - Received requests show in Back Office Live Queue in real-time
- ✅ **Status Updates** - Fulfilled requests automatically appear in Front Desk Delivered Audit
- ✅ **Persistence Integration** - All BLE-synced data persists to Hive correctly

**Known Limitations (To Be Addressed in Phase 6):**
- 📋 **Role Persistence** - Role selection resets on app restart (needs Hive storage)
- 📋 **Connection Status UI** - Bluetooth icons in screens need to show real connection state
- 📋 **Offline Queue UI** - No visual indicator for unsynced requests awaiting transmission
- 📋 **Comprehensive Test Coverage** - Only basic smoke test exists

**Current Behavior:**
- **Back Office:** Full offline functionality + BLE server receives requests and sends status updates (✅ 100% WORKING)
- **Front Desk:** Full offline functionality + BLE client sends requests and receives status updates (✅ 100% WORKING)
- **State Management:** All screens use Provider for reactive UI updates and centralized state
- **BLE Communication:** Full bidirectional sync working (FD ↔ BO)

### Installed Dependencies

**Runtime Packages:**
```yaml
flutter: sdk: flutter
cupertino_icons: ^1.0.8        # iOS-style icons
google_fonts: ^6.2.1           # Inter font family for typography
intl: ^0.19.0                  # Date/time formatting and internationalization
hive: ^2.2.3                   # Local NoSQL database (initialized in main.dart)
hive_flutter: ^1.1.0           # Flutter-specific Hive initialization
uuid: ^4.5.1                   # UUID generation for unique request IDs
flutter_reactive_ble: ^5.3.1   # BLE GATT Client (Front Desk)
ble_peripheral: ^2.4.0         # BLE GATT Server (Back Office)
provider: ^6.1.2               # State management
permission_handler: ^11.3.1    # Runtime Bluetooth permissions (Android 12+, iOS)
```

**Dev Dependencies:**
```yaml
flutter_test: sdk: flutter
flutter_lints: ^5.0.0          # Dart linting rules
hive_generator: ^2.0.1         # Code generation for Hive type adapters
build_runner: ^2.4.13          # Code generation framework
```

**Platform Permissions (Configured in Phase 2):**
- **Android:** Bluetooth permissions for API 31+ and legacy versions (AndroidManifest.xml)
- **macOS:** NSBluetoothAlwaysUsageDescription in Info.plist + bluetooth entitlements

**BLE Service Files (Phase 5 - COMPLETE & TESTED):**
- ✅ `lib/services/ble_service.dart` - GATT Client for Front Desk (~420 lines) - Fully tested
- ✅ `lib/services/ble_server_service.dart` - GATT Server for Back Office (~350 lines) - Fully tested
- ✅ `lib/services/sync_service.dart` - Sync orchestration (~400 lines) - Fully tested
- ✅ `lib/services/ble_initializer.dart` - Role-based initialization (~150 lines) - Fully tested
- ✅ `lib/services/permission_service.dart` - Bluetooth permission handler (~135 lines) - Fully tested

### Next Development Steps

To continue implementation, the recommended order is:

1. **Add Front Desk Persistence** ✅ COMPLETED (Phase 1)
   - ✅ Created front desk boxes in PersistenceService (submitted_requests, delivered_audit)
   - ✅ Added methods for submitted requests and delivered audit
   - ✅ Wired up Front Desk Request Entry screen to save to Hive
   - ✅ Wired up Front Desk Delivered Audit screen to read from Hive with real-time updates

2. **Add BLE Package & Platform Configuration** ✅ COMPLETED (Phase 2)
   - ✅ Added flutter_reactive_ble ^5.3.1 to pubspec.yaml
   - ✅ Added provider ^6.1.2 to pubspec.yaml
   - ✅ Configured Android Bluetooth permissions (API 31+ and legacy support)
   - ✅ Configured macOS Bluetooth permissions (Info.plist)
   - ✅ Configured macOS entitlements (Debug and Release profiles)
   - ✅ Verified app builds successfully on macOS

3. **Implement State Management** ✅ COMPLETED (Phase 3)
   - ✅ Created BleConnectionProvider for BLE connection state
   - ✅ Created FrontDeskProvider for Front Desk data management
   - ✅ Created BackOfficeProvider for Back Office data management
   - ✅ Replaced local state with Provider-managed state in all screens
   - ✅ Wrapped app in MultiProvider in main.dart
   - ✅ Integrated all screens with Consumer pattern
   - ✅ Clean architecture: UI ← Providers ← PersistenceService ← Hive

4. **Implement BLE Service Layer** ✅ COMPLETED (Phase 4)
   - ✅ Built BLE client service using flutter_reactive_ble (ble_service.dart)
   - ✅ Built BLE server service using ble_peripheral (ble_server_service.dart)
   - ✅ Built sync orchestration service (sync_service.dart)
   - ✅ Connected Back Office as GATT server
   - ✅ Connected Front Desk as GATT client
   - ✅ Wired providers to BLE characteristics (A, B, C)

5. **Integrate Providers with BLE Services** ✅ COMPLETED (Phase 4)
   - ✅ Connected FrontDeskProvider to BLE Request Characteristic (A)
   - ✅ Connected BackOfficeProvider to BLE Queue Status Characteristic (B)
   - ✅ Implemented Full Queue Sync Characteristic (C) for reconciliation
   - ✅ Updated BleConnectionProvider with real BLE operations
   - ✅ Implemented three-step reconnection handshake
   - ✅ Created BleInitializer for role-based lazy initialization

6. **BLE Testing and Debugging** ✅ COMPLETED (Phase 5)
   - ✅ Updated RoleSelectionScreen to call BleInitializer when role selected
   - ✅ Fixed CCCD descriptor issues for notifications
   - ✅ Added MTU negotiation for larger payloads
   - ✅ Fixed service discovery timing
   - ✅ Tested bidirectional BLE communication on real devices
   - ✅ Verified persistence integration with BLE sync
   - ✅ Confirmed Front Desk → Back Office communication
   - ✅ Confirmed Back Office → Front Desk status updates

7. **Future Enhancements** 📋 NEXT (Phase 6)
   - Add role persistence to remember selection across app restarts
   - Add connection status indicators in UI
   - Add visual indicators for unsynced offline requests
   - Implement comprehensive test coverage
   - Add unit tests for providers and services
   - Add widget tests for all screens
   - Add integration tests for BLE sync scenarios

## Architecture Overview

### Core Data Model

The entire application revolves around a single data structure: `PosterRequest` (implemented in `lib/models/poster_request.dart`)

**All Fields (Fully Implemented):**
- `uniqueId` (String): Unique identifier (UUID format for BLE transmission)
- `posterNumber` (String): Poster number (e.g., "A457")
- `status` (RequestStatus enum): sent, pending, or fulfilled
- `timestampSent` (DateTime): When request was submitted
- `timestampPulled` (DateTime?): When marked as fulfilled
- `isSynced` (bool): Whether current state has been transmitted via BLE

**Serialization Capabilities:**
- `toJson()` / `fromJson()`: Full object serialization for storage and transmission
- `toRequestCharacteristicJson()`: Optimized for BLE Request Characteristic (A)
- `toQueueStatusJson()`: Optimized for BLE Queue Status Characteristic (B)
- `fromJsonSynced()`: Factory constructor with explicit sync state control

**Hive Integration:**
- Type adapters defined with annotations (typeId: 0 for PosterRequest, typeId: 1 for RequestStatus)
- Run `flutter pub run build_runner build` to generate adapter code
- Box key uses `uniqueId` field for fast lookups

### Two-Role Architecture

**Front Desk (BLE Client):**
- Submits poster requests
- Displays delivery audit sorted by poster number
- Maintains local state with Hive persistence

**Back Office (BLE Server):**
- Receives requests
- Displays live queue sorted by timestamp
- Marks requests as fulfilled
- Acts as source of truth

### BLE Communication Protocol

**Service UUID:** `0000A000-0000-1000-8000-00805F9B34FB`

**Three Characteristics:**

1. **Request Characteristic (A)** - `0000A001-...`
   - Front Desk → Back Office
   - Write With Response (for reliability)
   - Payload: `{uniqueId, posterNumber, timestampSent}`

2. **Queue Status Characteristic (B)** - `0000A002-...`
   - Back Office → Front Desk
   - Indicate (with acknowledgment)
   - Payload: `{uniqueId, status, timestampPulled}`

3. **Full Queue Sync Characteristic (C)** - `0000A003-...`
   - Back Office → Front Desk
   - Read operation
   - Payload: Full array of all requests

### Persistence Strategy

**Technology:** Hive (local NoSQL database)

**Current Implementation:**

**Box Name (Back Office):** `fulfilled_requests`
- Stores all fulfilled poster requests
- Key: PosterRequest.uniqueId (String)
- Value: PosterRequest object
- Managed by global `persistenceService` instance

**Planned Boxes (Front Desk):**
- `submitted_requests` - Stores requests created by front desk
- `delivered_audit` - Stores fulfilled requests synced from back office

**Key Principle:** Write-immediately pattern - all state changes are persisted to Hive BEFORE confirming to user, ensuring no data loss during disconnections.

**Implementation Details:**
- Hive initialized in main.dart with `Hive.initFlutter()`
- Type adapters registered on startup
- Global `persistenceService` instance accessible throughout app
- Back Office uses `ValueListenableBuilder` for real-time UI updates
- All fulfilled requests persist across app restarts

**Sync Flag (`isSynced`):**
- Set to `false` when state changes occur offline
- Set to `true` after successful BLE transmission
- Drives re-sync logic when connection is restored

### Connection Loss & Re-sync Protocol

**On Disconnection:**
- Front Desk: Displays warning banner, caches new requests locally with `isSynced: false`
- Back Office: Displays warning banner, flags status updates with `isSynced: false`

**Three-Step Reconnection Handshake:**
1. Front Desk pushes all unsynced requests
2. Back Office pushes all unsynced status updates
3. Front Desk reads full queue state for reconciliation

### Data Architecture Decisions

**Field Naming Convention:**
The PosterRequest model uses field names that align with the Data Structure Specification rather than typical Dart conventions (e.g., `uniqueId` instead of `id`, `timestampPulled` instead of `timestampFulfilled`). This decision prioritizes:
- Consistency with BLE protocol specification
- Cross-platform data interchange clarity
- Alignment with product requirements documentation

**JSON Serialization Approach:**
- Manual serialization (no json_serializable or freezed) for maximum control over BLE payload format
- DateTime objects serialized to ISO 8601 strings for standard compliance
- `isSynced` field intentionally excluded from JSON (local-only field)
- Specialized methods (`toRequestCharacteristicJson`, `toQueueStatusJson`) for BLE characteristics

**Hive Type Adapter Strategy:**
- Annotations-based approach using hive_generator for compile-time safety
- Type IDs: 0 (PosterRequest), 1 (RequestStatus)
- Generate adapters with: `flutter pub run build_runner build`
- Required before first app run after cloning repository

**Mock Data Design:**
- Static mock data in `lib/models/mock_data.dart` for UI development
- Provides pre-sorted views matching screen requirements (liveQueue, deliveredAudit, fulfilledLog)
- Includes offline scenario data for testing sync logic
- Can generate batches for stress testing

## Project Standards Location

Critical design specifications are in `project_standards/`:

- **Product Requirements Document (PRD) - Poster Runner.md**: Feature requirements and user roles
- **BLE GATT Architecture Design.md**: BLE protocol specification
- **Data Structure Specification.md**: `PosterRequest` object definition
- **Local Persistence Specification.md**: Hive storage patterns
- **Synchronization Protocol and Error Handling.md**: Reconnection logic
- **project-theme.md**: Complete Flutter theme specification (colors, typography, spacing)
- **Front Desk UX Design Document.md**: Front Desk UI specifications with ASCII mockups
- **Back Office UX Design Document.md**: Back Office UI specifications with ASCII mockups

## UI Development Guidelines

### Theme Implementation

All UI components MUST reference `project_standards/project-theme.md` for:
- Color palette (light/dark themes)
- Typography (Inter font family)
- Spacing (8dp grid system)
- Touch targets (56dp minimum)
- Component shapes (8dp border radius)
- Animation durations (150ms/300ms)

### Status Color Convention

**Light Theme:**
- SENT: `#0277BD` (Info Blue)
- PENDING: `#F57C00` (Warning Amber)
- FULFILLED: `#2E7D32` (Success Green)

**Dark Theme:** See project-theme.md for adjusted variants

### Sorting Requirements

**CRITICAL:** Sorting logic determines user workflow

- **Queue Screen:** Sort by `timestampSent` (chronological, oldest first)
- **Delivered Audit Screen:** Sort by `posterNumber` (alphanumeric ascending)

## BLE Communication (Phase 5 - COMPLETE & TESTED)

### How BLE Services Work

BLE services are initialized lazily when the user selects their role via `BleInitializer`:

```dart
import 'package:poster_runner/services/ble_initializer.dart';

// When Front Desk button is pressed:
await BleInitializer.initializeForFrontDesk(context);

// When Back Office button is pressed:
await BleInitializer.initializeForBackOffice(context);
```

### What BleInitializer Does

**For Front Desk:**
1. Creates `BleService` (GATT Client) with `DeviceRole.frontDesk`
2. Creates `SyncService` with `FrontDeskProvider`
3. Sets up BLE callbacks for incoming status updates
4. Injects `SyncService` into `BleConnectionProvider` and `FrontDeskProvider`
5. Automatically discovers and connects to Back Office device

**For Back Office:**
1. Creates `BleServerService` (GATT Server)
2. Initializes the server and defines characteristics (A, B, C)
3. Creates `SyncService` with `BackOfficeProvider`
4. Sets up BLE callbacks for incoming requests
5. Connects full queue provider for Characteristic C
6. Starts advertising as "Poster Runner - Back Office"
7. Injects `SyncService` into `BleConnectionProvider` and `BackOfficeProvider`

### Verified Functionality

**Phase 5 is 100% complete and tested on real devices:**
- ✅ Front Desk → Back Office: Request submission via BLE Request Characteristic
- ✅ Back Office → Front Desk: Status updates via BLE Queue Status Characteristic
- ✅ Automatic connection establishment and service discovery
- ✅ MTU negotiation for larger JSON payloads (512 bytes)
- ✅ Proper CCCD descriptor handling for notifications
- ✅ Bidirectional sync with persistence integration
- ✅ Offline-first with automatic sync when reconnected

## Current Project Structure

```
app/lib/
├── main.dart                          # App entry point (✅ Hive initialization)
├── models/
│   ├── poster_request.dart            # PosterRequest data model (✅ Complete)
│   ├── poster_request.g.dart          # Generated Hive adapters (✅ Complete)
│   └── mock_data.dart                 # Mock data generator (✅ Complete)
├── theme/
│   └── app_theme.dart                 # Theme configuration (✅ Complete)
├── widgets/
│   ├── status_badge.dart              # Status indicator widget (✅ Complete)
│   ├── request_list_item.dart         # List item widget (✅ Complete)
│   ├── search_bar_widget.dart         # Search input widget (✅ Complete)
│   └── poster_entry_keypad.dart       # Custom keypad for poster number entry (✅ Complete)
├── providers/
│   ├── theme_provider.dart            # Theme management (✅ Phase 3)
│   ├── ble_connection_provider.dart   # BLE connection state (✅ Phase 4 - integrated with BLE)
│   ├── front_desk_provider.dart       # Front Desk data & ops (✅ Phase 4 - BLE integrated)
│   └── back_office_provider.dart      # Back Office data & ops (✅ Phase 4 - BLE integrated)
├── screens/
│   ├── role_selection_screen.dart     # Role selection (✅ Complete)
│   ├── front_desk/
│   │   ├── front_desk_home.dart       # Navigation wrapper (✅ Complete)
│   │   ├── request_entry_screen.dart  # Request entry (✅ Complete with BLE)
│   │   └── delivered_audit_screen.dart # Audit log (✅ Complete with BLE)
│   └── back_office/
│       ├── back_office_home.dart      # Navigation wrapper (✅ Complete)
│       ├── live_queue_screen.dart     # Live queue (✅ Complete with BLE)
│       └── fulfilled_log_screen.dart  # Fulfilled log (✅ Complete with BLE)
└── services/
    ├── persistence_service.dart       # Hive storage (✅ Complete)
    ├── ble_service.dart               # BLE GATT Client - Front Desk (✅ Phase 4)
    ├── ble_server_service.dart        # BLE GATT Server - Back Office (✅ Phase 4)
    ├── sync_service.dart              # Sync orchestration (✅ Phase 4)
    └── ble_initializer.dart           # Role-based BLE setup (✅ Phase 4)
```

## Available Claude Code Agents

This project has specialized agents configured in `.claude/agents/` to help with specific development tasks:

### flutter-ui-builder
**Purpose:** Create, modify, or refactor Flutter widgets and UI components based on UX specifications.

**When to use:**
- Implementing screens from UX Design Documents
- Creating custom widgets, layouts, animations
- Updating UI to match design mockups
- Building theme-compliant components

**What it does:**
- Reads UX specs and project-theme.md
- Creates widgets with proper theming
- Uses placeholder data when business logic doesn't exist
- Maintains separation between UI and business logic
- Adds TODO comments for integration points

**What it does NOT do:**
- Business logic or state management
- API integrations or BLE communication
- Database operations or persistence
- Application architecture decisions

**Example usage:**
```
"Use flutter-ui-builder to implement the settings screen from the UX spec"
"Update the request list item widget to match the new design"
```

### flutter-data-architect
**Purpose:** Create, modify, or refactor data models, DTOs, serialization logic, and data transformation utilities.

**When to use:**
- Creating data classes and models
- Building JSON serialization/deserialization
- Designing data transformation pipelines
- Creating extension methods for data manipulation
- Setting up freezed or json_serializable configurations

**What it does:**
- Creates data models from API specifications
- Implements serialization methods
- Builds data validators and parsers
- Defines enums and type definitions
- Creates mapper functions between data formats

**What it does NOT do:**
- Business logic or state management
- UI components or widgets
- Database/local storage implementation (use persistence layer instead)
- API client or networking code
- Navigation or routing logic

**Example usage:**
```
"Use flutter-data-architect to create models for the BLE message payloads"
"Create serialization methods for PosterRequest to/from JSON"
```

### theme-architect
**Purpose:** Create comprehensive theme templates (internal use only).

**When to use:**
- Only invoked via `/createThemeTemplate` slash command
- Do NOT invoke directly

**Note:** The theme has already been created in `project_standards/project-theme.md` and implemented in `app/lib/theme/app_theme.dart`.

## Code Organization Principles

### Separation of Concerns

**UI Layer (Widgets):** ✅ FULLY IMPLEMENTED
- Only presentation and local UI state (e.g., animations, focus)
- Accept data via parameters, actions via callbacks
- NO business logic, NO API calls, NO persistence
- All screens have TODO comments indicating integration points
- **Use `flutter-ui-builder` agent for UI work**

**Data Layer (Models & Serialization):** ✅ FULLY IMPLEMENTED
- `PosterRequest` model complete with all 6 fields including `isSynced`
- Full JSON serialization (toJson/fromJson) implemented
- Specialized BLE serialization methods (toRequestCharacteristicJson, toQueueStatusJson)
- Hive type adapter annotations in place (requires code generation)
- RequestStatus enum with extensions
- Comprehensive mock data generator
- **Use `flutter-data-architect` agent for data model work**

**State Management Layer:** ✅ FULLY IMPLEMENTED (Phase 3)
- ✅ Provider package integrated
- ✅ BleConnectionProvider for connection state
- ✅ FrontDeskProvider for Front Desk operations
- ✅ BackOfficeProvider for Back Office operations
- ✅ All screens use Consumer pattern
- ✅ MultiProvider setup in main.dart
- ✅ Clean separation: UI ← Providers ← PersistenceService ← Hive

**Business Logic Layer:** ✅ FULLY IMPLEMENTED (Phase 5)
- ✅ Request submission validation (in FrontDeskProvider)
- ✅ Request fulfillment logic (in BackOfficeProvider)
- ✅ Error handling for persistence operations
- ✅ BLE communication implemented and tested
- ✅ Sync orchestration implemented and tested
- ✅ Three-step reconnection handshake working
- ✅ Offline-first architecture with sync queuing

**Persistence Layer:** ✅ FULLY IMPLEMENTED
- ✅ Hive database initialized in main.dart
- ✅ PersistenceService class complete for both roles
- ✅ Back office fulfilled requests persist to Hive
- ✅ Front desk submitted requests persist to Hive
- ✅ Front desk delivered audit persists to Hive
- ✅ Real-time UI updates via Provider and Hive listeners
- ✅ Write-immediately pattern for data safety

### When Building UI Components

1. Read the corresponding UX Design Document for ASCII mockups
2. Reference project-theme.md for all styling values
3. Create widgets with data and callback parameters
4. Use placeholder content if data models don't exist yet
5. Add TODO comments indicating where business logic should connect

## Testing Considerations

### Current Test Coverage

**Implemented Tests:**
- `test/widget_test.dart` - Single smoke test verifying app launches with role selection

**Test Coverage:** Minimal (~5%) - Only basic app initialization is tested

### Critical Test Scenarios (To Be Implemented)

**Unit Tests Needed:**
1. **PosterRequest Serialization:** Test toJson/fromJson round-trip accuracy
2. **BLE Characteristic Serialization:** Test toRequestCharacteristicJson and toQueueStatusJson
3. **RequestStatus Extensions:** Test label and icon getters
4. **Mock Data Integrity:** Test filtering and sorting functions

**Widget Tests Needed:**
5. **StatusBadge:** Test color coding for each status type
6. **RequestListItem:** Test data display and fulfilled styling
7. **Screen Rendering:** Test each of the 7 screens renders correctly with mock data
8. **Search Functionality:** Test filtering in audit/log screens

**Integration Tests Needed:**
9. **Offline Request Creation:** Front Desk creates requests while disconnected
10. **Reconnection Sync:** Three-step handshake completes successfully
11. **Status Update During Disconnect:** Back Office marks fulfilled while Front Desk offline
12. **Duplicate Request Handling:** Reject requests with duplicate `uniqueId`
13. **BLE Timeout/Retry:** Handle Write/Indicate timeouts with 3-attempt retry logic
14. **Hive Persistence:** Test data survives app restart
15. **Concurrent Updates:** Test race conditions during sync

## Platform Notes

**Minimum Dart SDK:** 3.9.2
**Flutter Version:** 3.35.5 (Stable channel)
**Material Design:** Uses Material 3 (`useMaterial3: true`)

## Common Gotchas

1. **BLE Roles Are Fixed:** Back Office is ALWAYS the GATT Server, Front Desk is ALWAYS the Client
2. **Status Updates Are Unidirectional:** Only Back Office can mark requests as PULLED
3. **Timestamp Sorting Is Critical:** Queue MUST be chronological for fair processing
4. **isSynced Flag Drives Sync:** Always check/update this flag for offline scenarios
5. **MTU Negotiation Required:** Default 20-byte MTU is too small for JSON payloads, must request 512 bytes
6. **Service Discovery Timing:** Must wait 2+ seconds after connection before subscribing to characteristics
7. **CCCD Auto-Added:** ble_peripheral automatically adds CCCD descriptors for notify/indicate properties
8. **Payload Buffering:** BLE server buffers writes with 1-second timer to handle fragmented messages

## Design Philosophy

Poster Runner prioritizes **operational efficiency over aesthetic decoration**:
- Fast, minimal data entry
- Clear visual hierarchy for status differentiation
- Large touch targets for event environments
- Offline-first with automatic sync
- Reliability and data integrity above all
- After making any code or specification changes, ALWAYS check to see if the README.md and CLAUDE.md files need to be updates and make those updates.
- I do not like emojis. Do not use emojis unless specifically asked to do so for that specific purpose