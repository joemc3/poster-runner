# Product Requirements Document - Poster Runner

## Overview

**Poster Runner** is a cross-platform Flutter application for offline communication between Front Desk and Back Office staff at temporary event locations. The app uses Bluetooth Low Energy (BLE) to sync poster pull requests in environments with unreliable or no internet connectivity.

## Problem Statement

Event venues need to efficiently transfer poster "pull" requests from the Front Desk to the Back Office team in temporary locations with unreliable or no internet connectivity.

## Solution

A mobile/tablet application using Bluetooth Low Energy (BLE) to sync and queue requests between two roles:
- **Front Desk:** Submits poster requests
- **Back Office:** Receives and fulfills requests

## Key Goals

1. **Reliable Offline Communication** - Requests sync instantly over BLE
2. **Clear Prioritization** - Back Office sees requests in chronological order
3. **Simple, Fast UI** - Minimal data entry, maximum clarity

## Core Features

### Front Desk Role
- **Request Entry Screen:** Quick poster number input with BLE submission
- **Delivered Audit Screen:** Alphabetically sorted list of fulfilled requests

### Back Office Role
- **Live Queue Screen:** Chronologically sorted unfulfilled requests with "Mark Fulfilled" action
- **Fulfilled Log Screen:** Alphabetically sorted list of completed requests

## Technical Stack

- **Platform:** Flutter (iOS/Android)
- **Communication:** Bluetooth Low Energy (BLE)
- **Persistence:** Hive (local NoSQL database)
- **State Management:** Provider

## Detailed Specifications

For complete requirements and technical specifications, see:
- **Product Requirements:** [specs/Product Requirements Document (PRD) - Poster Runner.md](specs/Product%20Requirements%20Document%20(PRD)%20-%20Poster%20Runner.md)
- **Data Structure:** [specs/Data Structure Specification.md](specs/Data%20Structure%20Specification.md)
- **BLE Architecture:** [specs/BLE GATT Architecture Design.md](specs/BLE%20GATT%20Architecture%20Design.md)
- **Persistence:** [specs/Local Persistence Specification.md](specs/Local%20Persistence%20Specification.md)
- **Synchronization:** [specs/Synchronization Protocol and Error Handling.md](specs/Synchronization%20Protocol%20and%20Error%20Handling.md)
- **UI/UX:** [specs/Front Desk UX Design Document.md](specs/Front%20Desk%20UX%20Design%20Document.md) and [specs/Back Office UX Design Document.md](specs/Back%20Office%20UX%20Design%20Document.md)
- **Theme:** [specs/project-theme.md](specs/project-theme.md)

## Current Status

**Phase 6 - Essential UX Feedback (IN PROGRESS)**

See GitHub issues for current work and roadmap.
