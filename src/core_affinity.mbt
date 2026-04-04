///|
/// CPU core affinity helpers for the current thread.
///
/// This package exposes a small native API for inspecting the current thread's
/// allowed CPU cores and narrowing that set when the platform supports it.
/// Core identifiers are zero-based and encoded through a 64-bit mask, so the
/// public API supports core ids in the range `0..63`.

///|
/// Calls the native stub to apply an affinity mask to the current thread.
extern "C" fn set_affinity_mask(mask : UInt64) -> Bool = "moonbit_set_affinity_mask"

///|
/// Calls the native stub to read the affinity mask of the current thread.
extern "C" fn get_affinity_mask() -> UInt64 = "moonbit_get_affinity_mask"

///|
/// Returns the zero-based CPU core ids that the current thread may run on.
///
/// The function reads the platform affinity mask and expands every set bit into
/// a core id. The returned array is ordered from low core id to high core id.
///
/// # Returns
///
/// An `Array[Int]` containing all enabled core ids for the calling thread.
///
/// # Example
/// ```mbt check
/// test "inspect current affinity" {
///   let ids = get_core_ids()
///   assert_true(ids.length() > 0)
///   assert_true(ids.length() <= 64)
/// }
/// ```
///
/// # Notes
///
/// - Core ids are zero-based.
/// - The package currently models up to 64 cores because it uses a `UInt64`
///   mask internally.
/// - The result reflects the calling thread, not the whole process.
pub fn get_core_ids() -> Array[Int] {
  let mask = get_affinity_mask()
  let ids = Array::new()
  for i in 0..<64 {
    if ((mask >> i) & 1UL) != 0UL {
      ids.push(i)
    }
  }
  ids
}

///|
/// Restricts the current thread to the given CPU core ids.
///
/// The input array is converted into a native affinity mask and then passed to
/// the platform-specific implementation. Duplicate core ids are harmless.
///
/// # Parameters
///
/// - `ids`: Zero-based core ids to enable for the current thread.
///
/// # Returns
///
/// Returns `true` when the affinity change succeeds. Returns `false` when:
///
/// - `ids` is empty;
/// - any core id is outside `0..63`;
/// - or the operating system rejects the new affinity mask.
///
/// # Example
/// ```mbt check
/// test "pin thread to one available core" {
///   let original_ids = get_core_ids()
///   assert_true(original_ids.length() > 0)
///
///   let first_id = original_ids[0]
///   assert_true(set_for_current([first_id]))
///
///   let current_ids = get_core_ids()
///   assert_true(current_ids.contains(first_id))
///
///   ignore(set_for_current(original_ids))
/// }
/// ```
///
/// # Notes
///
/// - The change applies only to the calling thread.
/// - Passing a single-element array pins the current thread to one core.
/// - Some platforms may still reject a syntactically valid mask due to system
///   policy, missing permissions, or unsupported affinity APIs.
pub fn set_for_current(ids : Array[Int]) -> Bool {
  if ids.length() == 0 {
    return false
  }
  let mut mask : UInt64 = 0UL
  for id in ids {
    if id < 0 || id >= 64 {
      return false
    }
    mask = mask | (1UL << id)
  }
  set_affinity_mask(mask)
}
