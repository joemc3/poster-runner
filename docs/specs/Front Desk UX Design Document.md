
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
| **NEW REQUEST** [🔄2 pending]   |
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
|**Sync Badge**|Amber badge showing count of unsynced submitted requests (e.g., "🔄2 pending"). Appears next to header when items are waiting to sync via BLE. Auto-hides when count is 0 (all synced).|
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
|**Settings Menu (⚙️)**|Gear icon in header opens menu with: "Customize Letter Buttons" (opens dialog to customize A, B, C, D button labels and values), "Clear All Delivered" (removes all delivered audit entries with confirmation dialog), and "Theme" (Light/Dark/System mode selection).|
|**Search Bar**|Allows users to type in a poster number (e.g., 'B2') to instantly filter the list.|
|**Poster List**|Shows the **Poster Number (bold)** and the **Time Pulled/Fulfilled**.|
|**Sort Order**|Permanently sorted **alphabetically/numerically by Poster Number**.|
|**Data Source**|Data is synced from the Back Office device via BLE when the fulfillment status changes.|

### 4. Customize Letter Buttons Dialog

This dialog allows customization of the A, B, C, D button labels and values on the Request Entry keypad.

#### **Screen Description**

- Accessed via Settings menu (⚙️) on Delivered Audit screen
- Modal dialog centered on screen
- Four text input fields for customizing button values
- Save/Cancel actions
- Text auto-sizes to fit button (no button resizing)

#### **ASCII Art Layout**

```
+----------------------------------+
|  Customize Letter Buttons        |
|----------------------------------|
|                                  |
| Customize the labels for the     |
| letter buttons on the keypad.    |
|                                  |
| Button A:                        |
| [ Fri                        ]   |
|                                  |
| Button B:                        |
| [ Sat                        ]   |
|                                  |
| Button C:                        |
| [ Sun                        ]   |
|                                  |
| Button D:                        |
| [ Mon                        ]   |
|                                  |
| Maximum 3 characters per button  |
|                                  |
| Letter Button Separator:         |
| [ None                       ▼]  |
|                                  |
|  [ CANCEL ]      [ SAVE ]        |
+----------------------------------+
```

#### **Key Elements**

|**Element**|**Detail**|
|---|---|
|**Title**|"Customize Letter Buttons" - clear description of dialog purpose.|
|**Instructions**|Brief explanation that these customize the keypad letter button labels.|
|**Text Fields**|Four input fields labeled "Button A", "Button B", "Button C", "Button D". Each accepts 0-3 printable characters (letters, numbers, special chars). Case is preserved as entered. Duplicates allowed across buttons.|
|**Character Limit**|Maximum 3 characters per button. Input automatically capped at 3 chars.|
|**Validation**|Accept any printable characters (alphanumeric, dash, slash, etc.). Whitespace trimmed. Empty values allowed (button will display default letter A, B, C, D when empty).|
|**Letter Button Separator**|Dropdown selector with options: None, :, -, Blank Space. When a letter button (A, B, C, D) is pressed, the separator is automatically appended after the button value. For example: Button A="Sa", Separator=":" → pressing A adds "Sa:" to entry field. Default: None.|
|**Save Button**|Saves customization to persistent storage (Hive app_preferences box). Closes dialog. Updates keypad immediately.|
|**Cancel Button**|Dismisses dialog without saving changes. Returns to previous screen.|
|**Text Sizing**|When button values are displayed on keypad, text auto-sizes using FittedBox to fit within button bounds. Button size remains fixed (56dp minimum touch target).|
|**Persistence**|Values persist across app restarts. Stored in Hive `app_preferences` box with keys: `button_a`, `button_b`, `button_c`, `button_d`.|
|**Default Values**|On first use or if no custom values saved: A, B, C, D.|

#### **User Flow**

1. User taps Settings icon (⚙️) on Delivered Audit screen
2. Selects "Customize Letter Buttons" from menu
3. Dialog appears with current button values and separator pre-filled
4. User edits any/all fields (e.g., changes "A" to "Sa")
5. User selects separator from dropdown (e.g., ":")
6. User taps SAVE
7. Dialog closes
8. Keypad on Request Entry screen immediately shows new values
9. When button is pressed, the custom value + separator is entered (e.g., pressing "Sa" button with ":" separator enters "Sa:" in input field)

#### **Example Use Cases**

- **Day-of-week with colon:** Set A=Mon, B=Tue, C=Wed, D=Thu, Separator=":" → Pressing Mon button enters "Mon:" for easy continuation (e.g., "Mon:345")
- **Location prefixes with dash:** Set A=N, B=S, C=E, D=W, Separator="-" → Pressing N button enters "N-" for poster locations (e.g., "N-123")
- **Category codes with space:** Set A=Vip, B=Gen, C=Stf, D=Med, Separator="Blank Space" → Pressing Vip button enters "Vip " (e.g., "Vip 789")
- **Numeric shortcuts (no separator):** Set A=100, B=200, C=300, D=400, Separator="None" → Pressing 100 button enters just "100"
- **Saturday with colon:** Set A=Sa, Separator=":" → Pressing Sa button enters "Sa:" to quickly type "Sa:123" for Saturday booth 123
- **Mixed case preserved:** Set A=Fri, B=Sat, C=1st, D=2nd with any separator preserves exact case entered
