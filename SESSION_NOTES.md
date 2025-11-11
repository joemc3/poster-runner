# Development Session Notes - Phase 5 BLE Testing

## Date
Session completed: Current (check git log for exact date)

## Summary
Tested BLE communication on real Android devices and fixed multiple critical issues. Achieved one-way communication (Front Desk → Back Office) successfully. Identified remaining issue with Back Office → Front Desk notifications.

## Fixes Implemented

### 1. CCCD Descriptor Configuration
**Problem:** Front Desk couldn't subscribe to notifications - error: "Cannot write client characteristic config descriptor (code 3)"

**Root Cause:** Explicitly adding CCCD descriptor was conflicting with ble_peripheral's automatic CCCD handling

**Solution:**
- Removed explicit `BleDescriptor` for CCCD (UUID 0x2902)
- Let `ble_peripheral` automatically add CCCD when `notify` property is set
- Changed from `indicate` to `notify` for simpler configuration
- Added `read` property to Characteristic B

**Files Changed:**
- `app/lib/services/ble_server_service.dart`

**Result:** ✅ Front Desk now successfully subscribes to notifications

### 2. MTU Negotiation
**Problem:** JSON payloads truncated at 20 bytes
```
{"uniqueId":"23ad0d1  ← Cut off!
```

**Root Cause:** Default BLE MTU is 23 bytes (20 bytes payload), too small for JSON

**Solution:**
- Added `_requestMtu()` method to request 512-byte MTU
- Called immediately after connection before service discovery
- Added fallback message if MTU negotiation fails

**Files Changed:**
- `app/lib/services/ble_service.dart`

**Result:** ✅ Full JSON payloads (100-150 bytes) transmitted successfully

### 3. Service Discovery Timing
**Problem:** Subscription failed with "Characteristic not found or discovered"

**Root Cause:** Tried to subscribe before service discovery completed

**Solution:**
- Added `_discoverServicesAndSubscribe()` method
- Waits 2 seconds for service discovery to complete
- Includes retry logic if first subscription attempt fails
- Replaced BleStatus.ready check with proper timing

**Files Changed:**
- `app/lib/services/ble_service.dart`

**Result:** ✅ Service discovery completes before subscription

### 4. Permission Handling
**Problem:** No runtime permission requests for Android 12+ and iOS

**Solution:**
- Created `PermissionService` class
- Handles Android 12+ permissions (BLUETOOTH_SCAN, BLUETOOTH_CONNECT, BLUETOOTH_ADVERTISE)
- Handles iOS Bluetooth permission
- Integrated into `BleInitializer` for both roles
- Added `permission_handler: ^11.3.1` package

**Files Changed:**
- `app/lib/services/permission_service.dart` (new file)
- `app/lib/services/ble_initializer.dart`
- `app/pubspec.yaml`

**Result:** ✅ Permissions requested before BLE initialization

### 5. Mock Data Removal
**Problem:** App showed test data (A457, B211, etc.) making testing confusing

**Solution:**
- Removed `MockPosterRequests.liveQueue` from `_loadInitialQueue()`
- Removed `mock_data.dart` import from `back_office_provider.dart`
- Queue now starts empty and populates only via BLE

**Files Changed:**
- `app/lib/providers/back_office_provider.dart`

**Result:** ✅ Clean slate for testing - only real BLE data shown

### 6. Write Buffering Enhancement
**Problem:** Potential for fragmented writes to timeout too quickly

**Solution:**
- Increased buffer timer from 500ms to 1 second
- Added better logging for buffer size
- Fixed buffer update logic

**Files Changed:**
- `app/lib/services/ble_server_service.dart`

**Result:** ✅ More reliable handling of fragmented messages

## What's Working ✅

### Front Desk → Back Office (WORKING)
1. Front Desk connects to Back Office automatically
2. MTU negotiated (typically 247 bytes on Android)
3. Service discovery completes successfully
4. Subscribes to Queue Status Characteristic (B)
5. Sends poster request via Request Characteristic (A)
6. Full JSON payload transmitted (142+ bytes)
7. Back Office receives and parses request
8. Request appears in Back Office Live Queue
9. Persists to Hive database

**Example Log Flow:**
```
[BLE Service] MTU negotiated: 247 bytes
[BLE Service] Service discovery complete
[BLE Service] Subscribed to Queue Status Characteristic successfully
[BLE Service] Request payload: {...} (142 bytes)
[BLE Server] Buffered 142 bytes, total buffer size: 142 bytes
[BLE Server] Parsed request: 23ad0d1a-... - A123
[Back Office Provider] Adding request to queue: A123
```

## Known Issues ⚠️

### Back Office → Front Desk Notifications (NOT WORKING)
**Symptom:** When pulling a poster on Back Office:
```
[Sync Service] Not connected - status update will be queued
```

**Expected Behavior:**
- Back Office should send notification via Characteristic B
- Front Desk should receive status update
- Fulfilled request should appear in Delivered Audit

**Current Behavior:**
- SyncService reports "Not connected"
- No notification sent
- Front Desk doesn't receive status update

**Hypothesis:**
- BLE server connection state not being tracked properly in SyncService
- May need to wire `BleServerService.onClientConnectionChanged` to `BleConnectionProvider`
- SyncService may be checking wrong connection state variable

**Next Steps to Debug:**
1. Check if `BleServerService._isClientConnected` is set to true
2. Verify `onClientConnectionChanged` callback is being called
3. Check if `SyncService` has access to correct connection state
4. May need to pass BleServerService instance to SyncService for Back Office role
5. Compare Front Desk (BleService) vs Back Office (BleServerService) initialization

## Files Modified Today

### New Files
- `app/lib/services/permission_service.dart` - Bluetooth permission handler

### Modified Files
- `app/lib/services/ble_service.dart` - MTU negotiation, service discovery timing
- `app/lib/services/ble_server_service.dart` - CCCD fix, buffering improvements
- `app/lib/services/ble_initializer.dart` - Permission integration
- `app/lib/providers/back_office_provider.dart` - Mock data removal
- `app/pubspec.yaml` - Added permission_handler package
- `CLAUDE.md` - Updated status, known issues, completed tasks
- `README.md` - Updated implementation status

## Testing Recommendations

### To Test Front Desk → Back Office (Already Working)
1. Start Back Office on Device 1
2. Start Front Desk on Device 2
3. Wait for connection (watch logs)
4. Submit poster request from Front Desk
5. Verify appears in Back Office Live Queue

### To Debug Back Office → Front Desk (Next Session)
1. Add extensive logging to `BleServerService` connection callbacks
2. Add logging to `SyncService` when checking connection state
3. Verify `_isClientConnected` flag is true when client connects
4. Check if `onClientConnectionChanged` propagates to SyncService
5. May need to refactor Back Office initialization to properly wire connection state

## Architecture Notes

### BLE Connection Flow
```
Role Selection
    ↓
BleInitializer.initializeForFrontDesk() or initializeForBackOffice()
    ↓
PermissionService.requestBluetoothPermissions()
    ↓
Create BleService (FD) or BleServerService (BO)
    ↓
Create SyncService with appropriate provider
    ↓
Wire callbacks and inject into providers
    ↓
Start scanning (FD) or advertising (BO)
```

### Data Flow - Front Desk → Back Office (Working)
```
Front Desk: User submits poster request
    ↓
FrontDeskProvider.submitRequest()
    ↓
SyncService.sendNewRequest()
    ↓
BleService.writeRequest() [MTU negotiated, full payload]
    ↓
BleServerService._handleWriteRequest() [buffers data]
    ↓
BleServerService._processWriteBuffer() [after 1s timeout]
    ↓
Parse JSON → onRequestReceived callback
    ↓
SyncService.handleIncomingRequest()
    ↓
BackOfficeProvider.handleIncomingRequest()
    ↓
Add to queue + save to Hive
```

### Data Flow - Back Office → Front Desk (Broken)
```
Back Office: User taps "PULL" button
    ↓
BackOfficeProvider.fulfillRequest()
    ↓
SyncService.sendStatusUpdate()
    ↓
❌ Checks connection state → reports "Not connected"
    ↓
Status update queued but never sent
```

## Git Commit Message Suggestion

```
feat: Implement BLE communication with real device testing

Phase 5 progress - Front Desk to Back Office communication working

Features:
- Add runtime Bluetooth permission handling (Android 12+, iOS)
- Implement MTU negotiation (512 bytes) for larger JSON payloads
- Fix service discovery timing (2-second wait before subscription)
- Fix CCCD descriptor configuration for notifications
- Enhance write buffering for fragmented messages
- Remove mock data - app starts with clean state

Working:
- Front Desk → Back Office: Full request transmission via BLE ✅
- Service discovery, MTU negotiation, notification subscription ✅
- JSON payload parsing and queue display ✅

Known Issues:
- Back Office → Front Desk notifications not working (connection state tracking issue)

Files changed:
- New: app/lib/services/permission_service.dart
- Modified: ble_service.dart, ble_server_service.dart, ble_initializer.dart
- Modified: back_office_provider.dart, pubspec.yaml
- Updated: CLAUDE.md, README.md
```
