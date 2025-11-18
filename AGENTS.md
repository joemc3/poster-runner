# AGENTS.md – Guidance for Automated Agents

## Project Overview

**Poster Runner** is a cross-platform Flutter application for offline communication between Front Desk and Back Office staff using Bluetooth Low Energy (BLE). Key architecture:

- **Two roles:** Front Desk (BLE Client) submits requests, Back Office (BLE Server) fulfills them
- **Data model:** `PosterRequest` with 6 fields including `isSynced` for offline tracking
- **Persistence:** Hive local database with 3 boxes (fulfilled_requests, submitted_requests, delivered_audit)
- **State management:** Provider pattern with 4 providers (Theme, BLE Connection, Front Desk, Back Office)
- **Current status:** UI complete, persistence working, BLE fully working (bidirectional sync operational)

## Core Data Model

**PosterRequest Fields:**
- `uniqueId` (String): UUID for BLE transmission
- `posterNumber` (String): Poster identifier (e.g., "A457") 
- `status` (RequestStatus): sent, pending, or fulfilled
- `timestampSent` (DateTime): When submitted
- `timestampPulled` (DateTime?): When fulfilled
- `isSynced` (bool): Whether transmitted via BLE

**Key Methods:**
- `toJson()`/`fromJson()`: Full serialization
- `toRequestCharacteristicJson()`: BLE Characteristic A format
- `toQueueStatusJson()`: BLE Characteristic B format

## Build / Lint / Test Commands
- **Install deps:** `flutter pub get`
- **Analyze / lint:** `flutter analyze` (uses `flutter_lints`)
- **Run all tests:** `flutter test`
- **Run a single test file:** `flutter test test/widget_test.dart`
- **Run a specific test by name:** `flutter test --plain-name "<test description>"`
- **Format code:** `dart format .`
- **Generate Hive adapters:** `flutter pub run build_runner build` (required after model changes)
- **Build for iOS:** `flutter build ios`
- **Build for Android:** `flutter build apk`

## Code‑Style Guidelines
- **Imports:**
  ```dart
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:my_app/widgets/custom.dart';
  import '../models/model.dart';
  ```
  * Dart SDK imports → blank line → package imports → blank line → relative imports; alphabetically within each group.
- **Formatting:** Run `dart format .` and keep line length ≤ 100 chars.
- **Types & null‑safety:** Always declare explicit types; prefer `final`/`const`. Use nullable (`?`) only when a value can legitimately be absent.
- **Naming:**
  - Classes & enums: `PascalCase`
  - Variables, methods, parameters: `camelCase`
  - Files & directories: `snake_case.dart`
  - Constants: `SCREAMING_SNAKE`
- **Error handling:** Wrap async/IO calls in `try { … } on SpecificException catch (e) { … }`; log with `print` or a logger, rethrow only when the caller can act on it.
- **Provider usage:** Use `context.read<T>()` for one‑off calls, `context.watch<T>()` inside `build` for UI updates. Keep providers in `lib/providers/` and expose only necessary methods.
- **Comments:** Brief `///` doc comments for public APIs; `//` for inline notes. No TODOs left in production code.
- **Testing:** Place unit tests in `test/` mirroring the source path; widget tests under `test/` as well. Use `group`/`test` and descriptive names.

## Project Structure Guidance

```
app/lib/
├── models/           # Data models and serialization (PosterRequest, RequestStatus)
├── providers/        # Provider state management (4 providers)
├── screens/          # UI screens organized by role (front_desk/, back_office/)
├── widgets/          # Reusable UI components
├── services/         # Business logic (persistence, BLE, sync)
└── theme/           # App theming and styling
```

## BLE Development Notes

- **Service UUID:** `0000A000-0000-1000-8000-00805F9B34FB`
- **3 Characteristics:** Request (A), Queue Status (B), Full Queue Sync (C)
- **MTU negotiation:** Required for JSON payloads (request 512 bytes)
- **Service discovery:** Wait 2+ seconds before subscribing
- **Roles are fixed:** Back Office = GATT Server, Front Desk = GATT Client

## Key Dependencies

**Core BLE & State Management:**
- `flutter_reactive_ble: ^5.3.1` - BLE GATT Client (Front Desk)
- `ble_peripheral: ^2.4.0` - BLE GATT Server (Back Office)  
- `provider: ^6.1.2` - State management
- `permission_handler: ^11.3.1` - Bluetooth permissions

**Data & Storage:**
- `hive: ^2.2.3` - Local NoSQL database
- `hive_flutter: ^1.1.0` - Flutter Hive integration
- `uuid: ^4.5.1` - UUID generation for request IDs

**Development:**
- `hive_generator: ^2.0.1` - Code generation for Hive adapters
- `build_runner: ^2.4.13` - Code generation framework

## Critical Implementation Rules

- **Write-immediately pattern:** Always persist to Hive BEFORE confirming UI actions
- **Sorting logic:** Queue by timestamp (chronological), Audit by posterNumber (A-Z)
- **isSynced flag:** Track offline state changes, set to true after BLE transmission
- **Theme compliance:** All UI must use values from `docs/specs/project-theme.md`
- **No hardcoded values:** Colors, fonts, spacing must come from theme system
- **BLE service types:** Use `BleService` for Front Desk, `BleServerService` for Back Office

*These rules are intended for automated agents to keep the repository consistent and maintainable.*