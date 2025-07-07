///|
/// # CPU Core Affinity Module
/// 
/// This module provides cross-platform functionality for managing CPU core affinity
/// of threads. CPU affinity allows you to control which CPU cores a thread can run on,
/// which is useful for performance optimization, real-time applications, and
/// system-level programming.
/// 
/// ## Features
/// 
/// - **Cross-platform support**: Works on Linux, Windows, and other Unix-like systems
/// - **Thread affinity control**: Set which CPU cores a thread can execute on
/// - **Core enumeration**: Get list of available CPU cores for current thread
/// - **Bitmask operations**: Direct manipulation of CPU affinity bitmasks
/// - **FFI-based**: Uses native system APIs for optimal performance
/// 
/// ## Basic Usage
/// 
/// ```moonbit
/// // Get current thread's allowed CPU cores
/// let current_cores = @core_affinity.get_core_ids()
/// println("Current thread can run on cores: \{current_cores}")
/// 
/// // Set thread to run only on specific cores (e.g., cores 0 and 2)
/// let success = @core_affinity.set_for_current([0, 2])
/// if success {
///   println("Successfully restricted thread to cores 0 and 2")
/// } else {
///   println("Failed to set CPU affinity")
/// }
/// 
/// // Verify the change
/// let new_cores = @core_affinity.get_core_ids()
/// println("Thread now restricted to cores: \{new_cores}")
/// ```
/// 
/// ## Performance Considerations
/// 
/// - **Cache locality**: Restricting threads to specific cores can improve cache performance
/// - **NUMA awareness**: On multi-socket systems, consider NUMA topology
/// - **Hyperthreading**: Be aware of logical vs physical cores when setting affinity
/// - **System load**: Don't over-restrict cores on heavily loaded systems
/// 
/// ## Platform Support
/// 
/// | Platform | API Used | Notes |
/// |----------|----------|-------|
/// | Linux    | `sched_setaffinity()` | Full support for all features |
/// | Windows  | `SetThreadAffinityMask()` | Limited to 64 cores |
/// | macOS    | `thread_policy_set()` | Best effort implementation |
/// | Unix     | `pthread_setaffinity_np()` | Available on supported systems |
/// 
/// ## Error Handling
/// 
/// - Functions return `false` if the operation fails
/// - Common failure reasons include insufficient permissions or invalid core IDs
/// - Core IDs are zero-based and must be within system limits
/// - Empty core arrays are invalid and will cause the operation to fail

///| FFI binding: Set CPU affinity mask for current thread in native C code.
/// 
/// This is an internal function that interfaces with the C implementation
/// to set the CPU affinity mask for the current thread. The mask is a bitmask
/// where each bit represents a CPU core (bit 0 = core 0, bit 1 = core 1, etc.).
/// 
/// Platform-specific implementation details:
/// - **Linux**: Uses `sched_setaffinity()` with `cpu_set_t`
/// - **Windows**: Uses `SetThreadAffinityMask()` with `DWORD_PTR`
/// - **macOS**: Uses `thread_policy_set()` with thread affinity policy
/// 
/// ## Parameters
/// 
/// - `mask`: A 64-bit bitmask where each bit represents a CPU core
/// 
/// ## Returns
/// 
/// `true` if the operation was successful, `false` otherwise
/// 
/// ## Note
/// 
/// This function is internal and should not be called directly.
/// Users should use `set_for_current()` instead for public API access.
extern "C" fn set_affinity_mask(mask : UInt64) -> Bool = "moonbit_set_affinity_mask"

///| FFI binding: Get CPU affinity mask for current thread in native C code.
/// 
/// This is an internal function that interfaces with the C implementation
/// to retrieve the current CPU affinity mask for the calling thread.
/// The returned mask is a bitmask where each bit represents a CPU core.
/// 
/// Platform-specific implementation details:
/// - **Linux**: Uses `sched_getaffinity()` with `cpu_set_t`
/// - **Windows**: Uses `GetThreadAffinityMask()` or similar Windows API
/// - **macOS**: Uses `thread_policy_get()` with thread affinity policy
/// 
/// ## Returns
/// 
/// A 64-bit bitmask representing which CPU cores the thread can run on.
/// Each bit corresponds to a CPU core (bit 0 = core 0, bit 1 = core 1, etc.).
/// 
/// ## Note
/// 
/// This function is internal and should not be called directly.
/// Users should use `get_core_ids()` instead for public API access.
extern "C" fn get_affinity_mask() -> UInt64 = "moonbit_get_affinity_mask"

///| Gets the identifiers of all CPU cores that the current thread can run on.
/// 
/// This function retrieves the current CPU affinity mask for the calling thread
/// and converts it to a human-readable array of core identifiers. Each identifier
/// represents a CPU core that the thread is allowed to execute on.
/// 
/// The function operates by:
/// 1. Fetching the current affinity mask using FFI
/// 2. Examining each bit in the 64-bit mask
/// 3. Adding the corresponding core ID to the result array if the bit is set
/// 
/// ## Returns
/// 
/// An array of zero-based core identifiers that the current thread can run on.
/// The array will contain integers from 0 to 63, representing the CPU cores
/// available to this thread.
/// 
/// ## Example
/// 
/// ```moonbit
/// let core_ids = get_core_ids()
/// println("Current thread can run on cores: \{core_ids}")
/// // Output might be: [0, 1, 2, 3, 4, 5, 6, 7] on an 8-core system
/// 
/// // Check if thread can run on a specific core
/// if core_ids.contains(0) {
///   println("Thread can run on core 0")
/// }
/// ```
/// 
/// ## Note
/// 
/// - Core IDs are zero-based (0, 1, 2, ...)
/// - The maximum number of cores supported is 64 due to bitmask limitations
/// - On systems with fewer than 64 cores, only valid core IDs will be returned
/// - This function is thread-safe and can be called from any thread
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
/// This function restricts the current thread to execute only on the specified
/// CPU cores. This is useful for performance optimization, real-time applications,
/// and system-level programming where you need precise control over thread placement.
/// 
/// The function operates by:
/// 1. Converting the array of core IDs to a bitmask
/// 2. Setting the appropriate bits for each specified core
/// 3. Calling the native system API to apply the affinity mask
/// 
/// ## Parameters
/// 
/// - `ids`: An array of zero-based core identifiers. Each identifier must be
///   between 0 and 63 (inclusive) and correspond to a valid CPU core on the system.
/// 
/// ## Returns
/// 
/// `true` if the affinity was successfully set, `false` otherwise.
/// 
/// Common failure reasons:
/// - Invalid core IDs (negative, >= 64, or non-existent cores)
/// - Insufficient permissions to modify thread affinity
/// - Empty core array (at least one core must be specified)
/// - System-specific limitations or errors
/// 
/// ## Example
/// 
/// ```moonbit
/// // Restrict thread to cores 0 and 2 only
/// let success = set_for_current([0, 2])
/// if success {
///   println("Successfully set CPU affinity to cores 0 and 2")
///   
///   // Verify the change
///   let active_cores = get_core_ids()
///   println("Thread now restricted to cores: \{active_cores}")
/// } else {
///   println("Failed to set CPU affinity")
/// }
/// 
/// // Restore thread to run on all available cores
/// let all_cores = [0, 1, 2, 3, 4, 5, 6, 7]  // Adjust based on your system
/// let _restored = set_for_current(all_cores)
/// ```
/// 
/// ## Performance Considerations
/// 
/// - **Cache locality**: Restricting threads to specific cores can improve cache performance
/// - **NUMA awareness**: On multi-socket systems, consider NUMA topology when setting affinity
/// - **Hyperthreading**: Be aware of logical vs physical cores for optimal performance
/// - **System load**: Don't over-restrict cores on heavily loaded systems
/// 
/// ## Note
/// 
/// - Core IDs are zero-based and must be valid for the current system
/// - The maximum number of cores supported is 64 due to bitmask limitations
/// - This function affects only the calling thread, not the entire process
/// - Setting affinity may require elevated privileges on some systems
/// - This function is thread-safe and can be called from any thread
pub fn set_for_current(ids : Array[Int]) -> Bool {
  let mut mask : UInt64 = 0UL
  for id in ids {
    mask = mask | (1UL << id)
  }
  set_affinity_mask(mask)
}
