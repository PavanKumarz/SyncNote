/// Represents sync lifecycle of a note
enum SyncStatus {
  synced, // safely synced
  pending, // local changes not synced
  conflict, // conflict detected
}
