# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Poster Runner** is a cross-platform Flutter application designed for offline communication between Front Desk and Back Office staff at temporary event locations. The app uses Bluetooth Low Energy (BLE) to sync poster pull requests in environments with unreliable or no internet connectivity.

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

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

## Current Implementation Status

### What's Complete ✅

**UI Layer (100% Complete)**
- All screens implemented with placeholder data
- Role selection screen
- Front Desk: Request Entry + Delivered Audit tabs
- Back Office: Live Queue + Fulfilled Log tabs
- Complete theme system (light/dark mode)
- Reusable widgets (StatusBadge, RequestListItem, SearchBarWidget)
- All UX specifications from design documents implemented
- Zero linting issues, all tests passing

**Data Models**
- `PosterRequest` class (`lib/models/poster_request.dart`)
- `RequestStatus` enum (sent, pending, fulfilled)
- Extension methods for display labels and icons

### What's NOT Implemented ⚠️

- BLE communication layer
- Hive persistence
- State management (Provider/Riverpod/BLoC)
- Actual data synchronization
- Error handling and retry logic
- Role persistence (role selection resets on app restart)

**Current Behavior:** The app uses hardcoded placeholder data to demonstrate UI/UX. All interactions are local-only and don't persist between app restarts.

## Architecture Overview

### Core Data Model

The entire application revolves around a single data structure: `PosterRequest` (currently implemented in `lib/models/poster_request.dart`)

**Implemented Fields:**
- `uniqueId` (String): Unique identifier (currently uses simple string IDs)
- `posterNumber` (String): Poster number (e.g., "A457")
- `status` (RequestStatus enum): sent, pending, or fulfilled
- `timestampSent` (DateTime): When request was submitted
- `timestampPulled` (DateTime?): When marked as fulfilled

**Fields to Add for BLE Integration:**
- `isSynced` (Boolean): Whether current state has been transmitted via BLE

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

**Box Name:** `poster_requests_box`

**Key Principle:** Write-immediately pattern - all state changes are persisted to Hive BEFORE confirming to user, ensuring no data loss during disconnections.

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
├── main.dart                          # App entry point
├── models/
│   └── poster_request.dart            # PosterRequest data model (✅ Complete)
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
│   │   ├── request_entry_screen.dart  # Request entry (✅ Complete)
│   │   └── delivered_audit_screen.dart # Audit log (✅ Complete)
│   └── back_office/
│       ├── back_office_home.dart      # Navigation wrapper (✅ Complete)
│       ├── live_queue_screen.dart     # Live queue (✅ Complete)
│       └── fulfilled_log_screen.dart  # Fulfilled log (✅ Complete)
└── services/                          # ⚠️ NOT YET IMPLEMENTED
    ├── ble_service.dart               # BLE communication
    ├── persistence_service.dart       # Hive storage
    └── sync_service.dart              # Sync orchestration
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

**UI Layer (Widgets):** ✅ IMPLEMENTED
- Only presentation and local UI state (e.g., animations, focus)
- Accept data via parameters, actions via callbacks
- NO business logic, NO API calls, NO persistence
- All screens have TODO comments indicating integration points
- **Use `flutter-ui-builder` agent for UI work**

**Data Layer (Models & Serialization):** ✅ PARTIALLY IMPLEMENTED
- `PosterRequest` model exists but needs serialization
- Need to add `isSynced` field for BLE integration
- Need JSON serialization for BLE transmission
- Need Hive type adapters for persistence
- **Use `flutter-data-architect` agent for data model work**

**Business Logic Layer:** ⚠️ NOT IMPLEMENTED
- BLE communication
- Data validation
- Sync orchestration
- Error handling

**Persistence Layer:** ⚠️ NOT IMPLEMENTED
- Hive database setup
- Box management
- State management (Provider/Riverpod/BLoC)

### When Building UI Components

1. Read the corresponding UX Design Document for ASCII mockups
2. Reference project-theme.md for all styling values
3. Create widgets with data and callback parameters
4. Use placeholder content if data models don't exist yet
5. Add TODO comments indicating where business logic should connect

## Testing Considerations

### Critical Test Scenarios

1. **Offline Request Creation:** Front Desk creates requests while disconnected
2. **Reconnection Sync:** Three-step handshake completes successfully
3. **Status Update During Disconnect:** Back Office marks fulfilled while Front Desk offline
4. **Duplicate Request Handling:** Reject requests with duplicate `uniqueId`
5. **BLE Timeout/Retry:** Handle Write/Indicate timeouts with 3-attempt retry logic

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
