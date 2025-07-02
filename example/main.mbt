// Copyright 2025 justjavac
//
// Licensed under the MIT License

///|
/// Example usage of the core_affinity module
fn main {
  let core_ids = @core_affinity.get_core_ids()
  println("Available core IDs: " + core_ids.to_string())

  // Early return if no cores are available
  if core_ids.length() == 0 {
    println("No available cores found.")
    return
  }
  let first_core_id = core_ids[0]
  println("Setting affinity to core: " + first_core_id.to_string())
  let success = @core_affinity.set_for_current([first_core_id])
  if not(success) {
    println("Failed to set affinity to core: " + first_core_id.to_string())
    return
  }
  println("Successfully set affinity to core: " + first_core_id.to_string())
  let second_core_id = core_ids[1]
  println("Setting affinity to core: " + second_core_id.to_string())
  let success = @core_affinity.set_for_current([second_core_id])
  if not(success) {
    println("Failed to set affinity to core: " + second_core_id.to_string())
    return
  }
  println("Successfully set affinity to core: " + second_core_id.to_string())
}
