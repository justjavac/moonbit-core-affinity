# moonbit-core-affinity

A MoonBit library for managing CPU core affinities to control thread-to-core binding.

## Installation

Add `justjavac/core_affinity` to your dependencies:

```bash
moon add justjavac/core_affinity
moon update
```

## Usage

```moonbit
fn main {
  // Get available core IDs
  let core_ids = @core_affinity.get_core_ids()
  println("Available core IDs: \{core_ids}")
  
  // Early return if no cores are available
  if core_ids.length() == 0 {
    println("No available cores found.")
    return
  }
  
  let first_core_id = core_ids[0]
  println("Setting affinity to core: \{first_core_id}")
  
  let success = @core_affinity.set_for_current([first_core_id])
  if not(success) {
    println("Failed to set affinity to core: \{first_core_id}")
    return
  }

  println("Successfully set affinity to core: \{first_core_id}")
}
```

## API

### `get_core_ids() -> Array[Int]`

Returns the identifiers of all cores that the current thread can run on.

- **Windows**: Uses `GetProcessAffinityMask()` to get thread affinity mask
- **Unix/Linux/macOS**: Uses `sched_getaffinity()` or equivalent system calls
- **Fallback**: Returns all available cores for unknown platforms

**Returns:** An array of core IDs that the current thread is allowed to run on.

### `set_for_current(ids: Array[Int]) -> Bool`

Sets the identifiers of all cores that the current thread can run on.

- **Windows**: Uses `SetThreadAffinityMask()` to set thread affinity
- **Unix/Linux/macOS**: Uses `sched_setaffinity()` or equivalent system calls
- **Validation**: Validates that core IDs are within valid range

**Parameters:**
- `ids`: An array of core IDs to restrict the current thread to

**Returns:** `true` if the affinity was successfully set, `false` otherwise

## Platform Support

| Platform | get_core_ids() | set_for_current() | Implementation |
|----------|----------------|-------------------|----------------|
| Windows | ✅ | ✅ | Win32 API (GetProcessAffinityMask, SetThreadAffinityMask) |
| Linux | ✅ | ✅ | POSIX (sched_getaffinity, sched_setaffinity) |
| macOS | ✅ | ✅ | BSD/Darwin thread affinity APIs |
| Other Unix | ⚠️ | ⚠️ | Limited support, platform-dependent |

- ✅ = Full support
- ⚠️ = Limited/platform-dependent support

## Examples

### Basic Usage

```moonbit
fn main {
  let cores = @core_affinity.get_core_ids()
  println("Available cores: \{cores}")
}
```

### Single Core Binding

```moonbit
fn bind_to_first_core() -> Bool {
  let cores = @core_affinity.get_core_ids()
  if cores.length() > 0 {
    @core_affinity.set_for_current([cores[0]])
  } else {
    false
  }
}
```

### Multi-Core Binding

```moonbit
fn bind_to_even_cores() -> Bool {
  let cores = @core_affinity.get_core_ids()
  let even_cores = []
  
  for core in cores {
    if core % 2 == 0 {
      even_cores.push(core)
    }
  }
  
  if even_cores.length() > 0 {
    @core_affinity.set_for_current(even_cores)
  } else {
    false
  }
}
```

### Restoring Original Affinity

```moonbit
fn demo_with_restore() {
  // Save original affinity
  let original_cores = @core_affinity.get_core_ids()
  
  // Set to single core
  if original_cores.length() > 0 {
    @core_affinity.set_for_current([original_cores[0]])
    println("Running on single core")
    
    // Do some work...
    
    // Restore original affinity
    @core_affinity.set_for_current(original_cores)
    println("Restored to original affinity")
  }
}
```

## Examples

You can find example usage in the `example/` directory:

```bash
moon run --target native -C example .
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
