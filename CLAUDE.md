# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Poster Runner** is a cross-platform Flutter application designed for offline communication between Front Desk and Back Office staff at temporary event locations. The app uses Bluetooth Low Energy (BLE) to sync poster pull requests in environments with unreliable or no internet connectivity.

### Quick Start for New Developers

**Current State (TL;DR):**
- ✅ **UI is 100% complete** - All 7 screens working with mock data
- ✅ **Data models are 100% complete** - PosterRequest with full serialization
- ✅ **Hive adapters generated** - Type adapters ready in poster_request.g.dart
- ✅ **Back office persistence working** - Fulfilled requests persist across app restarts
- ❌ **No BLE integration** - Package not installed, BLE service doesn't exist
- ❌ **No front desk persistence** - Front desk still uses mock data
- ❌ **No state management** - Each screen manages its own state locally

**What You Can Do Right Now:**
```bash
cd app
flutter pub get
flutter run  # See the complete UI with mock data
# Back Office: Pull a poster and it will persist to Hive database!
# Back Office: Use the settings menu (gear icon) to clear all fulfilled requests
```

**What Needs Implementation:**
1. Add BLE package (flutter_reactive_ble recommended)
2. Add state management (Provider recommended)
3. Build BLE service and sync orchestration
4. Add front desk persistence service
5. Connect front desk UI to real data sources

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
- **Total Dart Files:** 16 files (~3,100 lines of code)
- **Screens:** 7 complete screens
- **Reusable Widgets:** 3 components
- **Data Models:** 1 core model + 1 enum + generated Hive adapters + mock data generator
- **Services:** 1 persistence service (back office fulfilled requests)
- **Test Coverage:** Minimal (1 smoke test)

### What's Complete ✅

**UI Layer (100% Complete)**
- All screens implemented with placeholder data
- Role selection screen
- Front Desk: Request Entry + Delivered Audit tabs
- Back Office: Live Queue + Fulfilled Log tabs
- Complete high-contrast theme system (light/dark mode)
  - Pure white backgrounds (#FFFFFF) for maximum contrast
  - True black text (#000000) with 21:1 contrast ratio
  - WCAG AAA compliant colors (7:1+ contrast) throughout
  - All UI components derive styling from theme (zero hardcoded values)
- Reusable widgets (StatusBadge, RequestListItem, SearchBarWidget)
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

**Persistence Layer (Back Office - Partially Complete)**
- `PersistenceService` class (`lib/services/persistence_service.dart`)
  - Manages Hive box for fulfilled requests
  - Write-immediately pattern for data safety
  - Methods: save, retrieve, delete, query fulfilled requests
  - Real-time data change listeners via Hive streams
  - Initialized in main.dart on app startup
- Back Office Live Queue screen
  - "PULL" button saves to Hive with timestampPulled
  - Error handling for save failures
  - Confirmation messages on success
- Back Office Fulfilled Log screen
  - Reads directly from Hive database
  - ValueListenableBuilder for real-time UI updates
  - Automatically refreshes when new requests are pulled
  - Data persists across app restarts
  - Settings menu (gear icon) with "Clear All Fulfilled" option
  - Confirmation dialog before clearing all data
  - Clears both screen and persistent storage

### What's NOT Implemented ⚠️

**Critical Gaps:**
- **BLE package not installed** - Need to add flutter_reactive_ble or similar to pubspec.yaml
- **No BLE service implementation** - BLE communication layer doesn't exist
- **No state management** - No Provider/Riverpod/BLoC package installed
- **No front desk persistence** - Front desk still uses mock data only

**Missing Functionality:**
- BLE communication layer (connection, characteristics, scanning)
- BLE service implementation (ble_service.dart)
- Sync orchestration service (sync_service.dart)
- State management for BLE events and data synchronization
- Actual data synchronization between devices via BLE
- Connection status UI (Bluetooth icons are non-functional)
- Front desk persistence service (submitted requests, delivered audit)
- Retry logic for BLE failures
- Role persistence (role selection resets on app restart)
- Comprehensive test coverage

**Current Behavior:**
- **Back Office:** Pull functionality is fully working with Hive persistence. Fulfilled requests persist across app restarts.
- **Front Desk:** Still uses hardcoded placeholder data. Submitted requests don't persist and won't sync to Back Office until BLE is implemented.

### Installed Dependencies

**Runtime Packages:**
```yaml
flutter: sdk: flutter
cupertino_icons: ^1.0.8        # iOS-style icons
google_fonts: ^6.2.1           # Inter font family for typography
intl: ^0.19.0                  # Date/time formatting and internationalization
hive: ^2.2.3                   # Local NoSQL database (initialized in main.dart)
hive_flutter: ^1.1.0           # Flutter-specific Hive initialization
```

**Dev Dependencies:**
```yaml
flutter_test: sdk: flutter
flutter_lints: ^5.0.0          # Dart linting rules
hive_generator: ^2.0.1         # Code generation for Hive type adapters
build_runner: ^2.4.13          # Code generation framework
```

**Critical Missing Packages:**
- **BLE Communication:** No flutter_reactive_ble, flutter_blue_plus, or similar BLE package
- **State Management:** No provider, riverpod, bloc, or state management package
- **Testing:** Only basic flutter_test, no mockito or integration test packages

### Next Development Steps

To continue implementation, the recommended order is:

1. **Add Front Desk Persistence** ✨ RECOMMENDED NEXT
   - Create front desk boxes in PersistenceService
   - Add methods for submitted requests and delivered audit
   - Wire up Front Desk Request Entry screen to save to Hive
   - Wire up Front Desk Delivered Audit screen to read from Hive

2. **Add BLE Package**
   - Research: flutter_reactive_ble (recommended) vs. flutter_blue_plus
   - Add to pubspec.yaml
   - Configure platform permissions (iOS: Info.plist, Android: AndroidManifest.xml)

3. **Add State Management**
   - Recommended: Provider (simple, officially supported)
   - Alternative: Riverpod (more powerful, modern)

4. **Implement BLE Service Layer**
   - Build BLE service (connection, characteristics, GATT server/client)
   - Build sync orchestration service
   - Connect Back Office as GATT server
   - Connect Front Desk as GATT client

5. **Integrate UI with BLE Services**
   - Replace remaining mock data with state-managed data
   - Wire up BLE events to UI updates
   - Add connection status indicators
   - Implement reconnection handshake

6. **Add Comprehensive Testing**
   - Unit tests for persistence service
   - Widget tests for screens
   - Integration tests for BLE sync scenarios

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
│   └── search_bar_widget.dart         # Search input widget (✅ Complete)
├── screens/
│   ├── role_selection_screen.dart     # Role selection (✅ Complete)
│   ├── front_desk/
│   │   ├── front_desk_home.dart       # Navigation wrapper (✅ Complete)
│   │   ├── request_entry_screen.dart  # Request entry (⚠️ Mock data only)
│   │   └── delivered_audit_screen.dart # Audit log (⚠️ Mock data only)
│   └── back_office/
│       ├── back_office_home.dart      # Navigation wrapper (✅ Complete)
│       ├── live_queue_screen.dart     # Live queue (✅ Pull to Hive working)
│       └── fulfilled_log_screen.dart  # Fulfilled log (✅ Reads from Hive)
└── services/
    └── persistence_service.dart       # Hive storage (✅ Back office complete)
                                       # Note: ble_service.dart and sync_service.dart not yet created
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

**Business Logic Layer:** ⚠️ NOT IMPLEMENTED
- BLE communication
- Data validation
- Sync orchestration
- Error handling

**Persistence Layer:** ⚠️ PARTIALLY IMPLEMENTED
- ✅ Hive database initialized in main.dart
- ✅ PersistenceService class created and working for back office
- ✅ Back office fulfilled requests persist to Hive
- ✅ Real-time UI updates via ValueListenableBuilder
- ❌ Front desk persistence not yet implemented
- ❌ State management (Provider/Riverpod/BLoC) not yet added

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
5. **Write With Response vs. Indicate:** Both require acknowledgment - essential for reliability

## Design Philosophy

Poster Runner prioritizes **operational efficiency over aesthetic decoration**:
- Fast, minimal data entry
- Clear visual hierarchy for status differentiation
- Large touch targets for event environments
- Offline-first with automatic sync
- Reliability and data integrity above all
- After making any code or specification changes, ALWAYS check to see if the README.md and CLAUDE.md files need to be updates and make those updates.
- I do not like emojis. Do not use emojis unless specifically asked to do so for that specific purpose