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

## Status

**Current Stage**: Initial development

The application architecture and specifications are complete. Implementation is in progress.

## License

[License information to be added]

## Contributing

[Contribution guidelines to be added]
