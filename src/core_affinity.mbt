///| Set the CPU affinity mask for the current thread.
/// Returns `true` if the operation was successful, `false` otherwise.
extern "c" fn set_affinity_mask(mask : UInt64) -> Bool = "moonbit_set_affinity_mask"

///| Get the CPU affinity mask for the current thread.
/// Returns a bitmask representing which CPU cores the thread can run on.
extern "c" fn get_affinity_mask() -> UInt64 = "moonbit_get_affinity_mask"

///| Gets the identifiers of all CPU cores that the current thread can run on.
/// 
/// Returns:
/// - An array of zero-based core identifiers.
/// 
/// Example:
/// ```moonbit
/// let core_ids = get_core_ids()
/// println("Current thread can run on cores: \{core_ids}")
/// ```
pub fn get_core_ids() -> Array[Int] {
  let mask = get_affinity_mask()
  let ids = Array::new()
  for i = 0; i < 64; i = i + 1 {
    if ((mask >> i) & 1UL) != 0UL {
      ids.push(i)
    }
  }
  ids
}

///| Sets the CPU cores that the current thread is allowed to run on.
/// 
/// Parameters:
/// - `ids` - An array of zero-based core identifiers.
/// 
/// Returns:
/// - `true` if the affinity was successfully set, `false` otherwise.
/// 
/// Example:
/// ```moonbit
/// let success = set_for_current([0, 2])
/// if success {
///   println("Successfully set CPU affinity to cores 0 and 2")
/// }
/// ```
pub fn set_for_current(ids : Array[Int]) -> Bool {
  let mut mask : UInt64 = 0UL
  for id in ids {
    mask = mask | (1UL << id)
  }
  set_affinity_mask(mask)
}
