# Technical Architecture Document - Poster Runner

## System Overview

Poster Runner is a Flutter-based cross-platform mobile application implementing an offline-first architecture with Bluetooth Low Energy (BLE) for peer-to-peer communication between two roles: Front Desk (BLE Client) and Back Office (BLE Server).

## Architecture Layers

### 1. UI Layer (Screens & Widgets)
- **7 complete screens** across two roles
- **6 reusable widgets** (StatusBadge, RequestListItem, SearchBar, PosterEntryKeypad, SyncBadge, CustomizeKeypadDialog)
- Material 3 theming with Light/Dark/System modes
- WCAG AAA high-contrast color scheme

### 2. State Management Layer (Provider)
- **ThemeProvider** - Theme management (light/dark/system)
- **KeypadCustomizationProvider** - Letter button customization (A, B, C, D)
- **BleConnectionProvider** - BLE connection state and status
- **FrontDeskProvider** - Front Desk data operations
- **BackOfficeProvider** - Back Office data operations

### 3. Business Logic Layer (Services)
- **PersistenceService** - Hive database operations
- **BleService** - BLE GATT Client (Front Desk)
- **BleServerService** - BLE GATT Server (Back Office)
- **SyncService** - Synchronization orchestration
- **BleInitializer** - Role-based BLE setup

### 4. Data Layer (Models)
- **PosterRequest** - Core data model (6 fields: uniqueId, posterNumber, status, timestampSent, timestampPulled, isSynced)
- **RequestStatus** - Enum (sent, pending, fulfilled)
- Hive type adapters for persistence
- JSON serialization for BLE transmission

## Technology Stack

### Core Technologies
- **Flutter 3.35.5** (Stable channel)
- **Dart SDK 3.9.2+**
- **Material Design 3**

### Key Dependencies
- **State Management:** provider ^6.1.2
- **Persistence:** hive ^2.2.3, hive_flutter ^1.1.0
- **BLE Communication:** flutter_reactive_ble ^5.3.1, ble_peripheral ^2.4.0
- **Utilities:** uuid ^4.5.1, intl ^0.19.0, google_fonts ^6.2.1
- **Permissions:** permission_handler ^11.3.1

### Code Generation
- **hive_generator ^2.0.1** - Type adapter generation
- **build_runner ^2.4.13** - Code generation framework

## BLE Communication Architecture

### Service Design
- **Service UUID:** `0000A000-0000-1000-8000-00805F9B34FB`
- **Back Office:** GATT Server (always advertising)
- **Front Desk:** GATT Client (connects to server)

### Characteristics
1. **Request Characteristic (A)** - `0000A001-...`
   - Front Desk → Back Office
   - Write With Response
   - Payload: `{uniqueId, posterNumber, timestampSent}`

2. **Queue Status Characteristic (B)** - `0000A002-...`
   - Back Office → Front Desk
   - Indicate (with acknowledgment)
   - Payload: `{uniqueId, status, timestampPulled}`

3. **Full Queue Sync Characteristic (C)** - `0000A003-...`
   - Back Office → Front Desk
   - Read operation
   - Payload: Full array of all requests

### Connection Protocol
1. **Connection:** Front Desk discovers and connects to Back Office
2. **MTU Negotiation:** Request 512 bytes (default 20 is insufficient)
3. **Service Discovery:** Wait 2+ seconds before subscribing
4. **Characteristic Subscription:** Subscribe to notifications/indications
5. **Data Transfer:** JSON payloads with retry logic (3 attempts)

### Reconnection Handshake
1. Front Desk pushes all unsynced requests (`isSynced: false`)
2. Back Office pushes all unsynced status updates
3. Front Desk reads full queue for reconciliation

## Data Persistence Strategy

### Hive Boxes
- **submitted_requests** - Front Desk submitted requests
- **delivered_audit** - Front Desk delivered audit (synced from Back Office)
- **fulfilled_requests** - Back Office fulfilled requests
- **app_preferences** - Theme and app settings

### Persistence Patterns
- **Write-Immediately:** All state changes persisted BEFORE UI confirmation
- **Sync Flag Tracking:** `isSynced` field manages sync state
- **ValueListenable UI:** Real-time UI updates via Hive listeners
- **Type Safety:** Generated Hive type adapters

## Data Flow

### Front Desk: Submit Request
1. User enters poster number → FrontDeskProvider
2. Create PosterRequest with `isSynced: false`
3. Persist to `submitted_requests` box
4. Transmit via BLE Request Characteristic
5. On success: Update `isSynced: true`

### Back Office: Fulfill Request
1. User marks fulfilled → BackOfficeProvider
2. Update request: `status: fulfilled`, `timestampPulled: now`, `isSynced: false`
3. Persist to `fulfilled_requests` box
4. Transmit via BLE Queue Status Characteristic
5. On success: Update `isSynced: true`

### Front Desk: Receive Status Update
1. BLE notification received → BleService
2. Parse JSON payload → PosterRequest
3. Update `delivered_audit` box
4. UI updates automatically via ValueListenableBuilder

## Offline-First Design

### Core Principles
- **All operations work offline** - BLE disconnection doesn't block user
- **Local persistence first** - Data saved before network transmission
- **Automatic reconciliation** - Three-step handshake on reconnection
- **Sync queue tracking** - `isSynced: false` flags unsynced changes

### Error Handling
- **BLE timeout:** 3-attempt retry with exponential backoff
- **Connection loss:** Warning banner, queue unsync operations
- **Duplicate requests:** Reject based on `uniqueId`
- **Data conflicts:** Back Office is source of truth

## File Structure

```
app/
├── lib/
│   ├── main.dart                      # Entry point, Hive init, MultiProvider
│   ├── models/                        # Data models
│   ├── providers/                     # State management
│   ├── screens/                       # UI screens
│   ├── services/                      # Business logic
│   ├── theme/                         # Theme configuration
│   └── widgets/                       # Reusable components
└── test/                              # Tests (minimal coverage)

docs/
├── PRD.md                             # Product overview
├── TAD.md                             # This document
└── specs/                             # Detailed specifications
    ├── BLE GATT Architecture Design.md
    ├── Data Structure Specification.md
    ├── Local Persistence Specification.md
    ├── Synchronization Protocol and Error Handling.md
    ├── Product Requirements Document (PRD) - Poster Runner.md
    ├── Front Desk UX Design Document.md
    ├── Back Office UX Design Document.md
    └── project-theme.md
```

## Detailed Specifications

For complete technical details, see:
- **BLE Protocol:** [specs/BLE GATT Architecture Design.md](specs/BLE%20GATT%20Architecture%20Design.md)
- **Data Model:** [specs/Data Structure Specification.md](specs/Data%20Structure%20Specification.md)
- **Persistence:** [specs/Local Persistence Specification.md](specs/Local%20Persistence%20Specification.md)
- **Sync Protocol:** [specs/Synchronization Protocol and Error Handling.md](specs/Synchronization%20Protocol%20and%20Error%20Handling.md)

## Testing Strategy (Phase 7 - Planned)

### Unit Tests
- PosterRequest serialization (JSON, BLE characteristics)
- Provider state management
- PersistenceService operations

### Widget Tests
- All 7 screens render correctly
- Component behavior (StatusBadge, RequestListItem, etc.)
- Theme switching

### Integration Tests
- BLE sync scenarios (connect, disconnect, reconnect)
- Offline queue handling
- Data integrity across app restarts

## Deployment Targets

- **iOS:** 12.0+
- **Android:** API 21+ (Android 5.0+)
- **Bluetooth Requirements:** BLE 4.0+ (server mode requires Android 5.0+)

## Known Limitations

- **Single Back Office:** Only one Back Office server per session
- **Unidirectional Status Updates:** Only Back Office can mark requests as fulfilled
- **No Cloud Sync:** Fully offline, no server-side persistence
- **Limited Multi-Device:** Phase 9 feature for multiple Front Desks

## Future Architecture Considerations (Phase 9)

- **Role Persistence:** Save role selection across restarts
- **Multi-Device Support:** Multiple Front Desks → one Back Office
- **Advanced Sync:** Manual sync trigger, conflict resolution UI
- **Request Archive:** Historical data with CSV export
