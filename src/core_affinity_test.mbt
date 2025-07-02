///|
test "get_core_ids returns a non-empty list" {
  let ids = get_core_ids()
  assert_true(ids.length() > 0)
  assert_eq(ids.length(), @num_cpus.get())
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
}
