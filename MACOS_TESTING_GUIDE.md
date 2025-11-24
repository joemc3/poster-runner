# macOS BLE Testing Guide

## Quick Start

**Goal:** Verify Poster Runner works on macOS with BLE communication to iOS/Android devices.

## Prerequisites

- Mac with Bluetooth (all modern Macs support BLE peripheral role)
- macOS 10.15 (Catalina) or later
- Second device: iPhone/iPad or Android phone with Poster Runner installed
- Bluetooth enabled on both devices

## Test Scenario 1: macOS Front Desk → iOS/Android Back Office

**Setup:**
1. **Mac:** Run `flutter run -d macos` from `app/` directory
2. **Mac:** Select "Front Desk" role
3. **iOS/Android device:** Run app and select "Back Office" role

**Test Steps:**
1. **On iOS/Android Back Office:**
   - App should show "Advertising as Back Office..."
   - Live Queue screen should be empty

2. **On Mac Front Desk:**
   - Click "Connect to Back Office" button
   - Should see "Scanning..." then device name appears
   - Click device name to connect
   - Connection should establish within 5-10 seconds

3. **Submit a request on Mac:**
   - Enter poster number (e.g., "A123")
   - Tap "Submit Request"
   - Should see "Sending..." then "Request sent successfully"

4. **Verify on iOS/Android Back Office:**
   - Request should appear in Live Queue within 2 seconds
   - Poster number, timestamp, and "PENDING" status visible

5. **Mark as fulfilled on iOS/Android:**
   - Tap request in queue
   - Tap "Mark as Pulled"
   - Should see "FULFILLED" status

6. **Verify on Mac Front Desk:**
   - Go to "Delivered Audit" tab
   - Request should show with "FULFILLED" status
   - Timestamp should match fulfillment time

**Success Criteria:**
- ✅ Mac can discover iOS/Android Back Office
- ✅ Connection establishes within 10 seconds
- ✅ Request appears in Back Office queue < 2 seconds
- ✅ Status update appears in Mac delivered audit < 2 seconds

---

## Test Scenario 2: iOS/Android Front Desk → macOS Back Office

**Setup:**
1. **Mac:** Run `flutter run -d macos` and select "Back Office"
2. **iOS/Android:** Run app and select "Front Desk"

**Test Steps:**
1. **On Mac Back Office:**
   - App should show "Advertising as Back Office..."
   - Live Queue should be empty

2. **On iOS/Android Front Desk:**
   - Tap "Connect to Back Office"
   - Should see Mac device in list
   - Tap to connect

3. **Submit request from iOS/Android:**
   - Enter poster number (e.g., "B456")
   - Submit request

4. **Verify on Mac Back Office:**
   - Request appears in Live Queue
   - Shows correct poster number and status

5. **Mark as fulfilled on Mac:**
   - Click request
   - Click "Mark as Pulled"

6. **Verify on iOS/Android Front Desk:**
   - Check Delivered Audit tab
   - Request should show as FULFILLED

**Success Criteria:**
- ✅ iOS/Android can discover Mac Back Office
- ✅ Request submission works from mobile to Mac
- ✅ Status updates flow from Mac to mobile

---

## Test Scenario 3: Reconnection Handshake

**Setup:** Use any combination from scenarios 1-2

**Test Steps:**
1. **Establish connection** between devices
2. **Submit 2-3 requests** and verify they sync

3. **Disconnect BLE:**
   - On Mac: Turn off Bluetooth (System Settings → Bluetooth → toggle off)
   - Both devices should show warning banner: "⚠ Offline - data will sync when reconnected"

4. **While disconnected:**
   - Front Desk: Submit 2 new requests locally
   - Back Office: Mark 1 existing request as fulfilled
   - Both changes cached locally with `isSynced: false`

5. **Reconnect BLE:**
   - On Mac: Turn Bluetooth back on
   - Devices should automatically reconnect within 30 seconds

6. **Verify three-step handshake:**
   - Step 1: Front Desk pushes 2 unsynced requests → Back Office
   - Step 2: Back Office pushes 1 unsynced status update → Front Desk
   - Step 3: Front Desk reads full queue for reconciliation

7. **Verify final state:**
   - Back Office: Should have all 5 requests (3 + 2 new)
   - Front Desk: Delivered audit should show fulfilled request from step 4
   - All devices show consistent state

**Success Criteria:**
- ✅ Offline mode detected on both devices
- ✅ Changes cached locally while offline
- ✅ Automatic reconnection within 30 seconds
- ✅ All unsynced data propagates correctly
- ✅ No data loss or duplication

---

## Test Scenario 4: macOS Front Desk ↔ macOS Back Office

**Setup:** Run two instances of the app on the same Mac (or two Macs)

**Option A: Two Macs**
- Mac 1: Front Desk
- Mac 2: Back Office
- Follow Test Scenario 1 steps

**Option B: One Mac (Debug + Release)**
This is tricky and may not work well due to CoreBluetooth limitations.

**Success Criteria:**
- ✅ macOS ↔ macOS BLE communication works
- ✅ All GATT operations function correctly

---

## Troubleshooting

### "Cannot discover Back Office device"

**Check:**
1. Both devices have Bluetooth enabled
2. Back Office is in "Advertising" mode
3. Devices are within 10 meters
4. No firewall blocking Bluetooth
5. Mac Console.app for CoreBluetooth errors

**Fix:**
- Restart both apps
- Toggle Bluetooth off/on on Mac
- Check System Settings → Privacy & Security → Bluetooth permissions

### "Connection drops frequently"

**Check:**
1. Keep apps in foreground (macOS background restrictions)
2. Move away from WiFi routers (interference)
3. Check macOS version (10.15+ recommended)
4. Console.app for CoreBluetooth errors

**Fix:**
- Reduce distance between devices
- Close other Bluetooth-using apps
- Update macOS if on older version

### "Permission denied" or "Bluetooth not available"

**Check:**
1. System Settings → Privacy & Security → Bluetooth
2. Poster Runner should have Bluetooth access enabled

**Fix:**
- Grant Bluetooth permission in System Settings
- Restart app after granting permission

### "MTU negotiation fails"

**Check Console.app logs for:**
```
[BleService] Requested MTU: 512
[BleService] Negotiated MTU: <value>
```

**Expected:** Negotiated MTU should be 512 bytes

**If lower:** App should still work but with smaller payloads. Check if both devices support 512-byte MTU.

---

## Demo Preparation Checklist

Before your demo:

### Setup
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] App builds successfully on macOS (`flutter build macos --release`)
- [ ] Second device (iOS/Android) charged and ready
- [ ] Both devices have Bluetooth enabled
- [ ] Both devices within 10 meters

### Testing
- [ ] Test Scenario 1 completed successfully
- [ ] Test Scenario 2 completed successfully
- [ ] Test Scenario 3 (reconnection) works
- [ ] Prepared demo data (poster numbers ready to submit)

### Backup Plan
- [ ] Have pre-recorded video of working BLE sync
- [ ] Screenshots of key functionality
- [ ] Console logs showing successful BLE communication

---

## Console Logs to Monitor

**On Mac, monitor Console.app:**

Filter for "Poster Runner" or "flutter" to see:
- BLE initialization logs
- Connection state changes
- MTU negotiation
- Request transmissions
- Status update indications

**Key success indicators:**
```
[BleService] Scanning for devices...
[BleService] Found device: <device-name>
[BleService] Connected to <device-id>
[BleService] MTU negotiated: 512 bytes
[BleService] Discovering services...
[BleService] Found service: 0000A000-0000-1000-8000-00805F9B34FB
[BleService] Subscribed to Queue Status Characteristic
[FrontDeskProvider] Request submitted successfully
[BleService] Received status update for request <id>
```

---

## Next Steps After Testing

1. **Document findings:** Note any issues encountered
2. **Update GitHub issue #47:** Add testing results
3. **Create documentation:** Add macOS-specific setup guide
4. **Consider edge cases:** Multi-device scenarios, long-running connections
