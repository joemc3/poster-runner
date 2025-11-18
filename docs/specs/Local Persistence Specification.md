The Poster Runner application will use **Hive** for local data storage on both the Front Desk and Back Office devices.

### 1. Persistence Goal

The primary goal of local persistence is to ensure **data integrity**. Every `PosterRequest` object created or updated must be stored locally before its status is confirmed to guarantee that no request is lost due to temporary BLE disconnection, app closure, or device restart.

### 2. Hive Data Structure

We will use a single **Hive Box** (similar to a table in a relational database) to store all `PosterRequest` objects.

|**Hive Element**|**Specification**|**Rationale**|
|---|---|---|
|**Box Name**|`poster_requests_box`|A single container for all requests for the current operational session.|
|**Key**|`uniqueId` (`String`)|The unique identifier of the `PosterRequest` is the key, allowing for fast retrieval and updating of any request's status.|
|**Value**|`PosterRequest` object|The entire serialized object, including all timestamps and the current `status`.|

### 3. Front Desk Persistence Logic

The Front Desk device needs to maintain its sent list and track which fulfillment acknowledgments have been received.

|**Action**|**Persistence Step**|
|---|---|
|**New Request Creation**|Immediately write the new `PosterRequest` object (with `status: SENT` and `isSynced: false`) to the local Hive box.|
|**BLE Write Failure**|If the BLE write to the Back Office fails, the request remains in the box with `isSynced: false`. The app will attempt to re-sync this request once the connection is restored.|
|**Status Update Received**|When the Back Office sends the `PULLED` status update via BLE, update the local `PosterRequest` object in the box by changing the `status` to `PULLED`, setting `timestampPulled`, and setting `isSynced: true`.|
|**Display Audit Log**|The **Delivered Audit** screen reads all objects from the box where `status` is `PULLED`.|

### 4. Back Office Persistence Logic

The Back Office device is the **GATT Server** and the primary source of truth, requiring persistence for the entire queue.

|**Action**|**Persistence Step**|
|---|---|
|**Receive New Request**|Upon successful receipt of the BLE write from the Front Desk, immediately create and write the new `PosterRequest` object (`status: SENT`, `isSynced: true`) to the local Hive box.|
|**User Clicks "PULL"**|Update the local `PosterRequest` object in the box by changing the `status` to `PULLED` and setting `timestampPulled`. Set `isSynced: false` to flag this status change for immediate transmission back to the Front Desk.|
|**BLE Indication Failure**|If the BLE **Indication** to the Front Desk fails, the object remains with `isSynced: false`. The Back Office device must re-attempt to send this status update when the connection is restored.|
|**Full Queue Sync**|The **Full Queue Sync Characteristic (C)** reads directly from the Hive box, serializing all stored requests for transmission to the Front Desk.|

---

This framework ensures that data is saved locally the moment an action occurs, guaranteeing resilience against connectivity issues and device power cycles.
