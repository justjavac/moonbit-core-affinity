# moonbit-core-affinity

A MoonBit library for managing CPU core affinities to control thread-to-core binding.

## Installation

Add `justjavac/core_affinity` to your dependencies:

```bash
moon update
moon add justjavac/core_affinity
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

## Platform Support

| Platform | get_core_ids() | set_for_current() | Implementation |
|----------|----------------|-------------------|----------------|
| Windows | ✅ | ✅ | Win32 API (`GetProcessAffinityMask`, `SetThreadAffinityMask`) |
| Linux | ✅ | ✅ | POSIX (`sched_getaffinity`, `sched_setaffinity`) |
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

## Examples

You can find example usage in the `example/` directory:

```bash
moon run --target native -C example .
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
