///|
/// Test that get_core_ids returns a non-empty list of available CPU cores.
/// 
/// This test verifies that the current thread has access to at least one CPU core
/// and that the core affinity detection is working correctly.
test "get_core_ids returns a non-empty list" {
  let ids = get_core_ids()
  assert_true(ids.length() > 0)
  // Note: We expect the number of accessible cores to match the system's CPU count
  // but we don't directly test against @num_cpus.get() to avoid dependency issues
  assert_true(ids.length() <= 64) // Bitmask limitation
}

///|
/// Test setting CPU affinity for the current thread.
/// 
/// This test verifies that we can successfully restrict the current thread
/// to run on a specific CPU core.
test "set_for_current" {
  let original_ids = get_core_ids()
  assert_true(original_ids.length() > 0)

  let first_id = original_ids[0]
  println("Setting affinity to core: " + first_id.to_string())

  let new_ids = [first_id]
  let success = set_for_current(new_ids)
  assert_true(success)

  let current_ids = get_core_ids()
  println("Current thread can run on cores: " + current_ids.to_string())
  assert_true(current_ids.contains(first_id))
  ignore(set_for_current(original_ids))
}

///|
/// Test that invalid affinity requests are rejected before calling native code.
test "set_for_current rejects invalid input" {
  assert_false(set_for_current([]))
  assert_false(set_for_current([-1]))
  assert_false(set_for_current([64]))
}
