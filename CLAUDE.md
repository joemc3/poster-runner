# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Poster Runner** is a cross-platform Flutter application designed for offline communication between Front Desk and Back Office staff at temporary event locations. The app uses Bluetooth Low Energy (BLE) to sync poster pull requests in environments with unreliable or no internet connectivity.

### Quick Start for New Developers

**Current State:**
- ✅ **Phases 1-5 Complete** - Full working app with BLE sync tested on real devices
- ✅ **All 7 screens operational** - Front Desk (role selection, request entry, delivered audit) + Back Office (live queue, fulfilled log)
- ✅ **Complete data layer** - PosterRequest model, Hive persistence, full serialization
- ✅ **BLE communication working** - Bidirectional sync between Front Desk (client) and Back Office (server)
- ✅ **Offline-first architecture** - All data persists locally, syncs when connected
- ✅ **UX polish started** - Connection status icons, offline queue badges, theme selection, data management
- ⚡ **Active development** - See GitHub Issues for current work (Epic #19 in progress)

**What You Can Do Right Now:**
```bash
cd app
flutter pub get
flutter run  # Run on two devices to test full BLE sync!
```
Test the app by running Front Desk on one device and Back Office on another. Submit requests on Front Desk, they sync via BLE to Back Office. Mark requests as fulfilled on Back Office, status updates sync back to Front Desk automatically. Watch connection status icons, offline queue badges, and use settings menus to manage data and themes.

**Completed Development (Phases 1-5):**
- ✅ Phase 1-2: UI, data models, persistence, BLE packages, platform permissions
- ✅ Phase 3: State management with Provider (4 providers: Theme, BLE Connection, Front Desk, Back Office)
- ✅ Phase 4: BLE services (client, server, sync orchestration, initialization)
- ✅ Phase 5: BLE testing and integration - full bidirectional sync working on real devices

**Current and Planned Work:**

All active and planned work is tracked in GitHub Issues. See:
- [Epic #19: Phase 6 - Essential UX Feedback](https://github.com/joemc3/poster-runner/issues/19) - **IN PROGRESS** (P0)
- [Epic #20: Phase 7 - Testing & QA](https://github.com/joemc3/poster-runner/issues/20) - Next (P1)
- [Epic #21: Phase 8 - Production Readiness](https://github.com/joemc3/poster-runner/issues/21) - Important (P2)
- [Epic #22: Phase 9 - Nice-to-Have Features](https://github.com/joemc3/poster-runner/issues/22) - Optional (P3)

Use BEADS commands to view ready tasks:
```bash
bd ready --limit 5  # Show top 5 ready tasks
bd stats            # View project statistics
```

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
- **Total Dart Files:** 28 files (~7,500 lines of code)
- **Screens:** 7 complete screens
- **Reusable Widgets:** 6 components (including customize keypad dialog)
- **Data Models:** 1 core model + 1 enum + generated Hive adapters + mock data generator
- **Services:** 5 services (persistence, BLE client, BLE server, sync orchestration, BLE initializer)
- **State Management:** 5 Provider models (Theme, Keypad Customization, BLE connection, Front Desk data, Back Office data)
- **Test Coverage:** Minimal (1 smoke test)

### What's Complete ✅

**Core Application (Phases 1-5):**
- **UI Layer:** All 7 screens with WCAG AAA high-contrast theme (Light/Dark/System), settings menus, real-time BLE status icons, offline queue badges, customizable keypad buttons (A, B, C, D), 6 reusable widgets
- **Data Layer:** PosterRequest model with 6 fields, full JSON serialization, Hive type adapters, RequestStatus enum, mock data generator
- **Persistence:** PersistenceService managing 3 Hive boxes (fulfilled_requests, submitted_requests, delivered_audit), write-immediately pattern, real-time listeners, app_preferences box for settings
- **State Management:** 5 Provider models (ThemeProvider, KeypadCustomizationProvider, BleConnectionProvider, FrontDeskProvider, BackOfficeProvider), all screens use Consumer pattern
- **BLE Services:** 5 service files (client, server, sync orchestration, initializer, permissions), 3 characteristics implemented (Request, Queue Status, Full Sync), retry logic, MTU negotiation
- **Testing Status:** Full bidirectional BLE sync verified on real devices, Front Desk ↔ Back Office communication working

**Known Gaps:**
- 📋 **Test Coverage** - Only basic smoke test exists (minimal ~5% coverage)
- 📋 **Production Assets** - Missing app icons, splash screens, store metadata
- 📋 **Documentation** - No user guide or troubleshooting docs yet
- 📋 **Role Persistence** - Role selection resets on app restart (Epic #22 - optional post-v1.0 feature)

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

**Platform Configuration:**
- Android: Bluetooth permissions for API 31+ and legacy (AndroidManifest.xml)
- macOS: NSBluetoothAlwaysUsageDescription + bluetooth entitlements

### Development Roadmap

**Phases 1-5: ✅ COMPLETE** - UI, data models, persistence, state management, BLE services all implemented and tested

**Current and Upcoming Work:**

All work is tracked in GitHub Issues and BEADS. For current tasks and priorities:

```bash
# View ready tasks
bd ready --limit 5

# View project stats
bd stats

# View specific epic
gh issue view 19  # Phase 6 - Essential UX Feedback (IN PROGRESS)
gh issue view 20  # Phase 7 - Testing & QA
gh issue view 21  # Phase 8 - Production Readiness
gh issue view 22  # Phase 9 - Nice-to-Have Features
```

See the "Current and Planned Work" section above for GitHub issue links.

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

**Hive Boxes:**
- `fulfilled_requests` - Back Office fulfilled requests
- `submitted_requests` - Front Desk submitted requests
- `delivered_audit` - Front Desk delivered audit (synced from Back Office)
- `app_preferences` - Theme and app settings

**Key Principles:**
- Write-immediately pattern - all state changes persisted BEFORE confirming to user
- `isSynced` flag tracks sync state (false = needs BLE transmission, true = synced)
- Type adapters generated with `flutter pub run build_runner build`
- ValueListenableBuilder for real-time UI updates

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

## Project Documentation

Product and technical documentation is in `docs/`:
- **docs/PRD.md**: Product requirements overview
- **docs/TAD.md**: Technical architecture overview

Critical design specifications are in `docs/specs/`:

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

All UI components MUST reference `docs/specs/project-theme.md` for:
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

## BLE Communication (Phase 5 - COMPLETE)

BLE services are initialized via `BleInitializer` when user selects their role:
- `BleInitializer.initializeForFrontDesk(context)` - Creates GATT Client, connects to Back Office
- `BleInitializer.initializeForBackOffice(context)` - Creates GATT Server, starts advertising

**Verified Functionality (tested on real devices):**
- Front Desk → Back Office: Request submission via BLE
- Back Office → Front Desk: Status updates via BLE notifications
- Automatic connection, service discovery, MTU negotiation (512 bytes)
- Three-step reconnection handshake with retry logic
- Full bidirectional sync with persistence integration

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
│   ├── poster_entry_keypad.dart       # Custom keypad for poster number entry (✅ Complete with customization)
│   ├── sync_badge.dart                # Offline queue badge indicator (✅ Complete)
│   └── customize_keypad_dialog.dart   # Dialog for customizing A, B, C, D button labels (✅ Complete)
├── providers/
│   ├── theme_provider.dart            # Theme management (✅ Phase 3)
│   ├── keypad_customization_provider.dart # A, B, C, D button customization (✅ Phase 6)
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

**Note:** The theme has already been created in `docs/specs/project-theme.md` and implemented in `app/lib/theme/app_theme.dart`.

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
- ✅ ThemeProvider for theme management
- ✅ KeypadCustomizationProvider for A, B, C, D button customization
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