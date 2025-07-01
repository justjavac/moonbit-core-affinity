///| This module provides functions for managing CPU core affinity.
extern "c" fn set_affinity_mask(mask : UInt64) -> Bool = "moonbit_set_affinity_mask"

///|
extern "c" fn get_affinity_mask() -> UInt64 = "moonbit_get_affinity_mask"

///| Gets the identifiers of all cores that the current thread can run on.
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

///| Sets the identifiers of all cores that the current thread can run on.
pub fn set_for_current(ids : Array[Int]) -> Bool {
  let mut mask : UInt64 = 0UL
  for id in ids {
    mask = mask | (1UL << id)
  }
  set_affinity_mask(mask)
}
