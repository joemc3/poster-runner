### 1. Introduction and Goals

| **Field**        | **Description**                                                                                                                                                                                                                                                                                    |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Product Name** | **Poster Runner**                                                                                                                                                                                                                                                                                  |
| **Problem**      | Efficiently transferring poster "pull" requests from the **Front Desk** to the **Back Office** team in temporary locations with **unreliable or no internet connectivity**.                                                                                                                        |
| **Solution**     | A cross-platform mobile/tablet application using **Bluetooth Low Energy (BLE)** to sync and queue requests between the two key roles.                                                                                                                                                              |
| **Key Goals**    | 1. **Reliable Offline Communication:** Requests sync instantly and reliably over BLE. <br>2. **Clear Prioritization:** Back Office sees requests in the exact order they were received. <br>3. **Simple, Fast UI:** Minimal data entry for the Front Desk and maximum clarity for the Back Office. |

---

### 2. User Roles and Key Features

#### 2.1 Front Desk Role (Request Sender)

| **Feature**                | **Description**                                                                                                                                                                                          |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Tab 1: Request Entry**   | Single, large input field for entering the **poster number**. Sends number, **timestamp**, and unique ID via BLE. Shows instant status confirmation.                                                     |
| **Tab 2: Delivered Audit** | A second screen displaying a complete list of all posters marked as "Pulled/Fulfilled" that day, sorted **alphabetically/numerically by Poster Number** for quick look-up and confirmation with clients. |
|                            |                                                                                                                                                                                                          |

#### 2.2 Back Office Role (Fulfillment Monitor)

| **Feature**                   | **Description**                                                                                                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Tab 1: Live Request Queue** | Dynamically updating list of **unfulfilled** requests, ordered strictly by **chronological time of receipt**. Includes the **"Pulled/Fulfilled"** action button. |
| **Tab 2: Delivered Audit**    | A second screen displaying a complete list of all posters marked as "Pulled/Fulfilled" that day, sorted **alphabetically/numerically by Poster Number**.         |

---

### 3. Technical Requirements

- **Primary Communication:** **Bluetooth Low Energy (BLE)**.
    
- **Technology Stack:** **Flutter** (for cross-platform iOS and Android application development).
    
- **Data Structure:** Minimal payload: **{`unique_id`, `poster_number`, `timestamp_sent`}**.
    
- **Offline Persistence:** All requests and status updates must be stored **locally** on both devices until fulfilled.
    
- **Synchronization:** Pending requests and status updates must sync **automatically** when the BLE connection is re-established.
    
- **Sorting Logic:**
    
    - **Queue Screen:** Sort by `timestamp_sent` (Ascending).
        
    - **Delivered Screen:** Sort by `poster_number` (Alphanumeric Ascending).
        

---
