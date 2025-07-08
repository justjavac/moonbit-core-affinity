// Copyright 2025 justjavac
//
// Licensed under the MIT License

///| Example usage of the core_affinity module
/// 
/// This example demonstrates how to:
/// 1. Get available CPU cores
/// 2. Set thread affinity to specific cores
/// 3. Handle errors gracefully
/// 4. Work on systems with different numbers of cores
fn main {
  println("=== Core Affinity Example ===")

  // Get current available cores
  let core_ids = @core_affinity.get_core_ids()
  println("Available core IDs: " + core_ids.to_string())

  // Early return if no cores are available
  if core_ids.length() == 0 {
    println("No available cores found.")
    return
  }

  // Test with first core
  let first_core_id = core_ids[0]
  println("\nSetting affinity to core: " + first_core_id.to_string())
  let success = @core_affinity.set_for_current([first_core_id])
  if not(success) {
    println("Failed to set affinity to core: " + first_core_id.to_string())
    return
  }
  println("Successfully set affinity to core: " + first_core_id.to_string())

  // Verify the change
  let current_cores = @core_affinity.get_core_ids()
  println("Current thread can now run on cores: " + current_cores.to_string())

  // Test with second core if available
  if core_ids.length() > 1 {
    let second_core_id = core_ids[1]
    println("\nSetting affinity to core: " + second_core_id.to_string())
    let success = @core_affinity.set_for_current([second_core_id])
    if not(success) {
      println("Failed to set affinity to core: " + second_core_id.to_string())
      return
    }
    println("Successfully set affinity to core: " + second_core_id.to_string())

    // Verify the change again
    let current_cores = @core_affinity.get_core_ids()
    println("Current thread can now run on cores: " + current_cores.to_string())
  } else {
    println("\nOnly one core available, skipping second core test.")
  }

  // Test with multiple cores if available
  if core_ids.length() > 2 {
    let multi_cores = [core_ids[0], core_ids[2]]
    println("\nSetting affinity to multiple cores: " + multi_cores.to_string())
    let success = @core_affinity.set_for_current(multi_cores)
    if success {
      println("Successfully set affinity to cores: " + multi_cores.to_string())
      let final_cores = @core_affinity.get_core_ids()
      println("Final thread affinity: " + final_cores.to_string())
    } else {
      println("Failed to set affinity to multiple cores")
    }
  } else {
    println("\nLess than 3 cores available, skipping multi-core test.")
  }
  let success = @core_affinity.set_for_current([core_ids.length()])
  if success {
    println(
      "\nSuccessfully set affinity to non-existent core \{core_ids.length().to_string()} (this should not happen)",
    )
  } else {
    println(
      "\nFailed to set affinity to non-existent core \{core_ids.length().to_string()} as expected",
    )
  }
  println("\n=== Example completed successfully ===")
}
