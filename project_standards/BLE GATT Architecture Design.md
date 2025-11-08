(Generic ATTribute Profile)
### 1. Device Roles

|**Role**|**GATT Role**|**Purpose**|
|---|---|---|
|**Back Office Device** (Monitor)|**Primary GATT Server**|Stores the definitive queue (all requests, all statuses) and publishes updates.|
|**Front Desk Device** (Sender)|**Primary GATT Client**|Connects to the Server to send new requests and subscribe to fulfillment status changes.|

### 2. Custom Service Definition

We will define one custom primary service to handle all application-specific data.

|**Component**|**UUID**|**Description**|
|---|---|---|
|**Poster Runner Service**|`0000A000-0000-1000-8000-00805F9B34FB`|A unique 128-bit custom UUID to ensure only Poster Runner devices connect.|

### 3. Characteristics (Data Points)

We need three main characteristics for reliable, bidirectional data exchange.

#### A. Request Characteristic (Front Desk → Back Office)

|**Field**|**Detail**|**Property/Use**|
|---|---|---|
|**UUID**|`0000A001-0000-1000-8000-00805F9B34FB`||
|**Data Payload**|JSON/Byte array: `{`unique_id`,` poster_number`,` timestamp_sent`}`||
|**Permissions**|**Write With Response** (Client writes to Server)|**Crucial for reliability.** The Front Desk (Client) writes the new request to this characteristic on the Back Office (Server) and waits for an acknowledgment (Write Response) to confirm receipt.|

#### B. Queue Status Characteristic (Back Office → Front Desk)

|**Field**|**Detail**|**Property/Use**|
|---|---|---|
|**UUID**|`0000A002-0000-1000-8000-00805F9B34FB`||
|**Data Payload**|JSON/Byte array: `{`unique_id`,` status`(e.g., 'PULLED'),`timestamp_pulled`}`||
|**Permissions**|**Indicate** (Server pushes update to Client with acknowledgment)|The Back Office (Server) uses this to push fulfillment status updates to the Front Desk (Client). **Indication** is used to ensure the Front Desk acknowledges receipt of the fulfillment status.|

#### C. Full Queue Sync Characteristic (Back Office $\longleftrightarrow$ Front Desk)

|**Field**|**Detail**|**Property/Use**|
|---|---|---|
|**UUID**|`0000A003-0000-1000-8000-00805F9B34FB`||
|**Data Payload**|Large JSON/Byte array representing the **full current queue state**.||
|**Permissions**|**Read** (Client reads from Server)|Used by the Front Desk (Client) for initial sync or after a disconnection to quickly pull the entire, up-to-date queue state from the Back Office (Server).|

### 4. Communication Flow Summary

1. **Front Desk sends new request:**
    
    - Front Desk (Client) executes a **Write With Response** operation on the **Request Characteristic** on the Back Office (Server).
        
    - The Front Desk waits for the acknowledgement before showing the "SENT" status.
        
2. **Back Office fulfills poster:**
    
    - Back Office (Server) updates its local database.
        
    - Back Office (Server) executes an **Indication** on the **Queue Status Characteristic**, sending the fulfillment status to the Front Desk (Client).
        
    - The Front Desk receives the Indication, updates its Delivered Audit log, and sends an acknowledgment back.
        
3. **Front Desk reconnects/starts up:**
    
    - Front Desk (Client) executes a **Read** operation on the **Full Queue Sync Characteristic** on the Back Office (Server) to get the entire current status of all outstanding and fulfilled requests.
        

This architecture prioritizes data integrity and requires acknowledgment for critical operations (**Write With Response** for new requests and **Indicate** for fulfillment status updates), which is essential for a reliable system.

For more on implementing reliable Bluetooth Low Energy data exchange in Flutter, see [Connecting BLE Devices with Flutter (Part 3) – BLE Communication](https://www.google.com/search?q=https://www.youtube.com/watch%3Fv%3DkYJvR87v3gY).