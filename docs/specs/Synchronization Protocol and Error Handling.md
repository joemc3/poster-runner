
The goal is to ensure that the Back Office (Server) and Front Desk (Client) always converge to the same, correct state whenever they are connected.

---

### 1. Connection Loss Handling

When the BLE connection is unexpectedly terminated (e.g., devices move out of range or a device is powered off), the application must immediately switch to a **disconnected state**.

|**Device**|**Action Taken**|
|---|---|
|**Front Desk**|1. **Immediate Feedback:** Display a visual warning (e.g., a red banner: "**Connection Lost - Caching Requests Locally**"). 2. **Local Caching:** All new requests created by the user are saved locally in the Hive box with the `isSynced: false` flag. 3. **Block Status Updates:** Stop attempting to read or subscribe to the Queue Status Characteristic (B).|
|**Back Office**|1. **Immediate Feedback:** Display a visual warning (e.g., a yellow banner: "**Client Disconnected - Pending Status Updates Will Be Sent When Client Returns**"). 2. **Local Flagging:** Any subsequent "PULL" actions will update the local Hive box and set the request's `isSynced: false` flag for transmission later.|

---

### 2. Connection Regain Synchronization (The Handshake)

When the Back Office (Server) and Front Desk (Client) successfully re-establish a connection, a mandatory three-step handshake ensures all data is accounted for.

#### Step 1: Front Desk Pushes Unsynced Requests (Client $\to$ Server)

The Front Desk prioritizes sending any requests that were created while offline.

1. The Front Desk (Client) scans its local Hive box for all `PosterRequest` objects where **`status` is `SENT`** and **`isSynced` is `false`**.
    
2. For each unsynced request, the Client performs a **Write With Response** operation on the **Request Characteristic (A)**.
    
3. Upon receiving the successful acknowledgment, the Client updates the local request's **`isSynced` to `true`**.
    

#### Step 2: Back Office Pushes Unsynced Statuses (Server $\to$ Client)

The Back Office pushes any "PULLED" status updates that occurred while the Front Desk was offline.

1. The Back Office (Server) scans its local Hive box for all `PosterRequest` objects where **`status` is `PULLED`** and **`isSynced` is `false`**.
    
2. For each unsynced status, the Server performs an **Indication** operation on the **Queue Status Characteristic (B)**.
    
3. Upon receiving the successful acknowledgment from the Client, the Server updates the local request's **`isSynced` to `true`**.
    

#### Step 3: Full Queue Reconciliation (Client Pulls from Server)

To ensure the Front Desk's Delivered Audit log is complete, the Client requests the full current state.

1. The Front Desk (Client) executes a **Read** operation on the **Full Queue Sync Characteristic (C)**.
    
2. The Back Office (Server) returns the compressed array of **all** `PosterRequest` objects for the session from its Hive box.
    
3. The Front Desk uses this full dataset to reconcile its local Hive box, overwriting any conflicting or missing data, ensuring both devices now have the exact same list of completed posters.
    
4. Both devices display a success message (e.g., "**Sync Complete**") and return to the fully connected operational mode.
    

---

### 3. Error Handling

|**Error Scenario**|**Resolution Strategy**|
|---|---|
|**BLE Write/Indicate Timeout**|Retry the operation up to **three times** after a short delay (e.g., 2 seconds). If all retries fail, immediately flag the request as **`isSynced: false`** and return to the **Disconnected State**.|
|**Data Corruption**|If a received BLE payload is malformed, reject the packet, do not apply the change, and log the error locally. Rely on the **Full Queue Reconciliation** (Step 3) to correct the state upon the next successful connection.|
|**Duplicate `uniqueId` Received**|If a device receives a new request that shares a `uniqueId` with an existing local request, **ignore the incoming request** and rely on the local state, as the duplicate suggests a delayed retry or an old packet. The status will be updated later by a proper status change or the full sync.|

This synchronization framework ensures that when connectivity is available, any differences are quickly and reliably resolved with minimal impact on the user experience.