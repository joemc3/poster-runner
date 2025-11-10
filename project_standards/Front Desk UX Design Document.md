
### 1. General Principles

- **Focus:** Speed and accuracy of poster number entry.
    
- **Navigation:** Simple two-tab (or bottom bar) navigation between the active entry screen and the audit screen.
    
- **Aesthetics:** High-contrast colors, large fonts, and large tap targets suitable for rapid use.
    

### 2. Tab 1: Request Entry (Active Screen)

This screen is optimized for quickly inputting and sending a poster number request.

#### **Screen Description**

- Dominated by a large input area for the poster number.
    
- The "Submit" button is large and easy to hit.
    
- A dedicated area shows the status of the _last_ submission.
    

#### **ASCII Art Layout**

Code snippet

```
+---------------------------------+
| Poster Runner - Front Desk      |
|---------------------------------|
|          (Header Bar)           |
|                                 |
| **NEW REQUEST**                 |
| -----------------               |
|                                 |
|  [                               ]
|  [    **A 4 5 7** ]
|  [     (Large Input Field)      ]
|  [                               ]
|                                 |
|  [                              ]
|  [        **SUBMIT** ]
|  [                              ]
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
|**Input Field**|Large, clear font. Accepts alphanumeric input. Clears automatically upon successful submission.|
|**SUBMIT Button**|Large, high-visibility button. Triggered upon full entry, initiates BLE transmission.|
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
| Poster Runner - Front Desk      |
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
|**Search Bar**|Allows users to type in a poster number (e.g., 'B2') to instantly filter the list.|
|**Poster List**|Shows the **Poster Number (bold)** and the **Time Pulled/Fulfilled**.|
|**Sort Order**|Permanently sorted **alphabetically/numerically by Poster Number**.|
|**Data Source**|Data is synced from the Back Office device via BLE when the fulfillment status changes.|
