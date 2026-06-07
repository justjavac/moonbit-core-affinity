# core_affinity

`justjavac/core_affinity` provides a minimal native API for reading and setting
the CPU affinity of the current thread.

## Install

```bash
moon add justjavac/core_affinity
```

## API

- `@core_affinity.get_core_ids()`: returns the zero-based core ids currently
  available to the calling thread.
- `@core_affinity.set_for_current(ids)`: applies a new affinity mask for the
  calling thread and returns whether it succeeded.

## Example

```mbt check
///|
test "read current affinity" {
  let ids = @core_affinity.get_core_ids()
  assert_true(ids.length() > 0)
  assert_true(ids.length() <= 64)
}
```

```mbt check
///|
test "pin to the first available core and restore" {
  let original_ids = @core_affinity.get_core_ids()
  assert_true(original_ids.length() > 0)

  let first_id = original_ids[0]
  assert_true(@core_affinity.set_for_current([first_id]))
  assert_true(@core_affinity.get_core_ids().contains(first_id))

  ignore(@core_affinity.set_for_current(original_ids))
}
```

## Notes

- Core ids are zero-based.
- Only ids in `0..63` are accepted by this package.
- The affinity change only affects the calling thread.
