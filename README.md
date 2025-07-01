# moonbit-core-affinity

A MoonBit library for managing CPU core affinities to control thread-to-core binding.

## Installation

Add this library to your `moon.mod.json`:

```json
{
  "deps": {
    "justjavac/core_affinity": "*"
  }
}
```

## API Reference

### `get_core_ids() -> Array[Int]`

Gets the identifiers of all cores that the current thread can run on.

**Returns:** An array of core IDs that the current thread is allowed to run on.

### `set_for_current(ids: Array[Int]) -> Bool`

Sets the identifiers of all cores that the current thread can run on.

**Parameters:**
- `ids`: An array of core IDs to restrict the current thread to

**Returns:** `true` if the affinity was successfully set, `false` otherwise

## Usage

```moonbit
fn main {
  // Get available core IDs
  let core_ids = @core_affinity.get_core_ids()
  println("Available core IDs: " + core_ids.to_string())
  
  if core_ids.length() > 0 {
    // Set thread affinity to run only on the first core
    let first_core_id = core_ids[0]
    println("Setting affinity to core: " + first_core_id.to_string())
    
    let success = @core_affinity.set_for_current([first_core_id])
    if success {
      println("Successfully set affinity to core: " + first_core_id.to_string())
    } else {
      println("Failed to set affinity to core: " + first_core_id.to_string())
    }
  } else {
    println("No available cores found.")
  }
}
```

## Platform Support

This library currently supports platforms that provide thread affinity functionality through the underlying C implementation.

## Examples

You can find example usage in the `example/` directory:

```bash
moon run example
```

## Testing

Run the test suite with:

```bash
moon test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
