///|
test "get_core_ids returns a non-empty list" {
  let ids = get_core_ids()
  assert_true(ids.length() > 0)
}

///|
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

  // 4. get core ids again
  let current_ids = get_core_ids()
  println("Current core ids: " + current_ids.to_string())

  // 5. assert that the new list of core ids contains only that one id
  assert_eq(current_ids.length(), 1)
  assert_eq(current_ids[0], first_id)

  // 6. set affinity back to the original list of ids
  println("Restoring affinity to: " + original_ids.to_string())
  let success_restore = set_for_current(original_ids)
  assert_true(success_restore)

  // 7. check if it was restored
  let restored_ids = get_core_ids()
  println("Restored core ids: " + restored_ids.to_string())
  assert_eq(restored_ids.length(), original_ids.length())
}
