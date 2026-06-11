# moonbit-core-affinity

[![ci](https://github.com/justjavac/moonbit-core-affinity/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/justjavac/moonbit-core-affinity/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/codecov/c/github/justjavac/moonbit-core-affinity/main?label=coverage)](https://codecov.io/gh/justjavac/moonbit-core-affinity)
[![linux](https://img.shields.io/codecov/c/github/justjavac/moonbit-core-affinity/main?flag=linux&label=linux)](https://codecov.io/gh/justjavac/moonbit-core-affinity)
[![macos](https://img.shields.io/codecov/c/github/justjavac/moonbit-core-affinity/main?flag=macos&label=macos)](https://codecov.io/gh/justjavac/moonbit-core-affinity)
[![windows](https://img.shields.io/codecov/c/github/justjavac/moonbit-core-affinity/main?flag=windows&label=windows)](https://codecov.io/gh/justjavac/moonbit-core-affinity)

A MoonBit library for managing CPU core affinities to control thread-to-core binding.

This library enables precise control over CPU core affinity, allowing you to bind threads to specific cores. It's particularly useful for high-performance applications, real-time systems, and scenarios where you need to optimize CPU cache locality, reduce context switching overhead, or isolate workloads on dedicated cores.

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
  println("Available core IDs: \{to_repr(core_ids)}")

  // Early return if no cores are available
  if core_ids.length() == 0 {
    println("No available cores found.")
    return
  }

  let first_core_id = core_ids[0]
  println("Setting affinity to core: \{first_core_id}")

  let success = @core_affinity.set_for_current([first_core_id])
  if !success {
    println("Failed to set affinity to core: \{first_core_id}")
    return
  }

  println("Successfully set affinity to core: \{first_core_id}")
}
```

## Platform Support

| Platform | get_core_ids() | set_for_current() | Implementation |
|----------|----------------|-------------------|----------------|
| Windows | Yes | Yes | Win32 API (`GetThreadGroupAffinity`, `SetThreadAffinityMask`) |
| Linux | Yes | Yes | POSIX (`sched_getaffinity`, `sched_setaffinity`) |
| macOS | Yes | Limited | BSD/Darwin thread affinity APIs |
| Other Unix | Limited | Limited | Limited support, platform-dependent |

- Yes = Full support
- Limited = Limited/platform-dependent support

## Examples

### Basic Usage

```moonbit
fn main {
  let cores = @core_affinity.get_core_ids()
  println("Available cores: \{to_repr(cores)}")
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

## Example Project

You can find example usage in the `example/` directory:

```bash
moon -C example run --target native .
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
