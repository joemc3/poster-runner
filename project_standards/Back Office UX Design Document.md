
### 1. General Principles

- **Focus:** Real-time chronological monitoring and immediate actioning (fulfillment) of requests.
    
- **Navigation:** Simple two-tab (or bottom bar) navigation between the active queue and the audit screen.
    
- **Aesthetics:** High-contrast, highly scannable layout. The active queue must be easily readable from a short distance.
    

### 2. Tab 1: Live Request Queue (Active Screen)

This screen is optimized for instantly seeing and processing the incoming "pull" requests in the order they were received.

#### **Screen Description**

- A prioritized list where the next task is highlighted and clearly actionable.
    
- The list is strictly ordered by the timestamp sent from the Front Desk.
    
- The "Pull" button is the primary action.
    

#### **ASCII Art Layout**

Code snippet

```
+---------------------------------+
| Poster Runner - Back Office     |
|---------------------------------|
|          (Header Bar)           |
|                                 |
| **ACTIVE QUEUE** (4 Pending)    |
| --------------------------------|
|                                 |
| 1. **C055** (10:50 AM) [ PULL ] |
|    (Next to Pull)               |
|                                 |
| 2. **B211** (11:30 AM) [ PULL ] |
|                                 |
| 3. **C001** (11:59 AM) [ PULL ] |
|                                 |
| 4. **A457** (12:05 PM) [ PULL ] |
|    (Scrollable List...)         |
|                                 |
|---------------------------------|
| [ Queue ] [ Delivered ]         |
+---------------------------------+
```

#### **Key Elements**

|**Element**|**Detail**|
|---|---|
|**Queue Items**|Each row clearly shows the **Rank/Order**, **Poster Number (bold, large font)**, and **Time Received**.|
|**PULL Button**|Large, high-visibility button. Tapping it marks the request as **Fulfilled/Pulled**, sends the status back via BLE, and removes the item from the queue.|
|**Order**|Strictly **chronological**, sorted by the `timestamp_sent` (oldest requests at the top).|
|**Navigation**|Bottom navigation bar for switching to the Delivered Audit tab.|

### 3. Tab 2: Delivered Audit (Audit Screen)

This screen provides a secondary check and reference for all fulfilled requests, easily searchable by poster number.

#### **Screen Description**

- A complete log of all posters marked as "Pulled" for the current session/day.
    
- Includes a search bar and is sorted for quick numerical/alphabetical look-up.
    

#### **ASCII Art Layout**

Code snippet

```
+---------------------------------+
| Poster Runner - Back Office     |
|---------------------------------|
|          (Header Bar)           |
|                                 |
| **FULFILLED LOG**               |
| -------------------             |
|                                 |
| [ Search by Poster # ]          |
|                                 |
| --- Sorted A-Z ---              |
|                                 |
| **A102** | Sent: 09:30 AM  | Pulled: 10:15 AM |
| **A105** | Sent: 09:40 AM  | Pulled: 09:42 AM |
| **B211** | Sent: 11:15 AM  | Pulled: 11:30 AM |
| **C001** | Sent: 11:50 AM  | Pulled: 11:59 AM |
| (Scrollable List...)            |
|                                 |
|---------------------------------|
| [ Queue ] [ Delivered ]         |
+---------------------------------+
```

#### **Key Elements**

|**Element**|**Detail**|
|---|---|
|**Search Bar**|Essential for filtering a large log of fulfilled items.|
|**Poster List**|Shows **Poster Number (bold)**, **Time Sent**, and **Time Pulled** for a complete audit trail.|
|**Sort Order**|Permanently sorted **alphabetically/numerically by Poster Number**.|
|**Data Source**|Local storage of fulfilled items, synchronized status updates sent to the Front Desk.|
