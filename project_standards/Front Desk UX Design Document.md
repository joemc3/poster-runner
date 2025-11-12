
### 1. General Principles

- **Focus:** Speed and accuracy of poster number entry.
    
- **Navigation:** Simple two-tab (or bottom bar) navigation between the active entry screen and the audit screen.
    
- **Aesthetics:** High-contrast colors, large fonts, and large tap targets suitable for rapid use.
    

### 2. Tab 1: Request Entry (Active Screen)

This screen is optimized for quickly inputting and sending a poster number request.

#### **Screen Description**

- Dominated by a large input area for the poster number.

- Submission occurs via the custom keypad's ENTER button or the keyboard's Enter key.

- A dedicated area shows the status of the _last_ submission.
    

#### **ASCII Art Layout**

Code snippet

```
+---------------------------------+
| Front Desk              [BLE]   |
|---------------------------------|
|          (Header Bar)           |
|                                 |
| **NEW REQUEST**                 |
| -----------------               |
|                                 |
|  [                               ]
|  [    **A 4 5 7** ]
|  [     (Large Input Field)      ]
|  [     (No auto-focus)          ]
|  [                               ]
|                                 |
|  +---+---+---+---+              |
|  | A | B | C | D |              |
|  +---+---+---+---+              |
|  | 7 | 8 | 9 | - |              |
|  +---+---+---+---+              |
|  | 4 | 5 | 6 | E |              |
|  +---+---+---+ N |              |
|  | 1 | 2 | 3 | T |              |
|  +---+---+---+ E |              |
|  |     0     | R |              |
|  +-----------+---+              |
|    (Custom Keypad)              |
|                                 |
| **Status: SENT** (11:58 AM)     |
| Last: A457 - Success.           |
|                                 |
|---------------------------------|
| [ Request ] [ Delivered ]       |
+---------------------------------+
```

#### **Key Elements**

|**Element**|**Detail**|
|---|---|
|**Input Field**|Large, clear font. Displays entered characters. NO auto-focus (prevents mobile keyboard popup on load). Accepts keyboard input (physical keyboard or tap to show mobile keyboard). Pressing Enter on keyboard submits the request. **Becomes read-only immediately when Enter is pressed** to prevent accidental entry during submission processing. Returns to editable state when submission completes and field is cleared.|
|**Custom Keypad**|4x5 grid layout with buttons for A-D (row 1), 7-9 and dash (row 2), 4-6 and top of ENTER (row 3), 1-3 and middle of ENTER (row 4), 0 (wide) and bottom of ENTER (row 5). ENTER button spans 3 rows vertically. Each button appends its character to the input field when editable. ENTER button triggers submission.|
|**Status Bar**|Shows instant feedback: `SENT` (green check) or `FAILED` (red X). Includes the timestamp for the last action.|
|**Navigation**|Bottom navigation bar for switching to the Delivered Audit tab.|

### 3. Tab 2: Delivered Audit (Audit Screen)

This screen is for quickly verifying if a specific poster has been fulfilled by the Back Office.

#### **Screen Description**

- A list view of all fulfilled posters for the current operational period.
    
- Crucially, this list is **sorted by Poster Number** for quick client lookup.
    
- A search bar is required for quickly filtering the list of 1000+ entries.
    

#### **ASCII Art Layout**

Code snippet

```
+---------------------------------+
| Front Desk          [BLE] [⚙️]  |
|---------------------------------|
|          (Header Bar)           |
|                                 |
| **DELIVERED POSTERS**           |
| ------------------------        |
|                                 |
| [ Search by Poster # ]          |
|                                 |
| --- Sorted A-Z ---              |
|                                 |
| **A102** | Pulled: 10:15 AM     |
| **A105** | Pulled: 09:42 AM     |
| **B211** | Pulled: 11:30 AM     |
| **C001** | Pulled: 11:59 AM     |
| **C055** | Pulled: 10:50 AM     |
| (Scrollable List...)            |
|                                 |
|---------------------------------|
| [ Request ] [ Delivered ]       |
+---------------------------------+
```

#### **Key Elements**

|**Element**|**Detail**|
|---|---|
|**BLE Status Icon**|Shows real-time Bluetooth connection status in header: 🔵 Connected (green), 🔍 Scanning/Connecting (amber), ⚫ Disconnected (gray), ❌ Error (red). Tap for tooltip with status text.|
|**Settings Menu (⚙️)**|Gear icon in header opens menu with: "Clear All Delivered" (removes all delivered audit entries with confirmation dialog) and "Theme" (Light/Dark/System mode selection).|
|**Search Bar**|Allows users to type in a poster number (e.g., 'B2') to instantly filter the list.|
|**Poster List**|Shows the **Poster Number (bold)** and the **Time Pulled/Fulfilled**.|
|**Sort Order**|Permanently sorted **alphabetically/numerically by Poster Number**.|
|**Data Source**|Data is synced from the Back Office device via BLE when the fulfillment status changes.|
