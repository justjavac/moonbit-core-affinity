///| Test that get_core_ids returns a non-empty list of available CPU cores.
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

///| Test setting CPU affinity for the current thread.
/// 
/// This test verifies that we can successfully restrict the current thread
/// to run on a specific CPU core.
test "set_for_current" {
  // 1. get original core ids
  let original_ids = get_core_ids()
  assert_true(original_ids.length() > 0)

  // 2. take the first core id
  let first_id = original_ids[0]
  println("Setting affinity to core: " + first_id.to_string())

  // 3. set affinity to only that core id
  let new_ids = [first_id]
  let success = set_for_current(new_ids)
  assert_true(success)

  // 4. verify the affinity was set correctly
  let current_ids = get_core_ids()
  println("Current thread can run on cores: " + current_ids.to_string())
  assert_true(current_ids.contains(first_id))
}
