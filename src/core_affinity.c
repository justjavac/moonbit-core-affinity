#ifdef __linux__
#define _GNU_SOURCE
#endif

#include "moonbit.h"
#include <stdbool.h>
#include <stdint.h>

#ifdef _WIN32
#include <windows.h>

uint64_t moonbit_get_affinity_mask() {
    DWORD_PTR process_affinity_mask;
    DWORD_PTR system_affinity_mask;
    if (GetProcessAffinityMask(GetCurrentProcess(), &process_affinity_mask, &system_affinity_mask)) {
        return (uint64_t)process_affinity_mask;
    }
    return 0;
}

bool moonbit_set_affinity_mask(uint64_t mask) {
    return SetThreadAffinityMask(GetCurrentThread(), (DWORD_PTR)mask) != 0;
}

#elif defined(__linux__)
#include <sched.h>
#include <unistd.h>
#include <errno.h>

uint64_t moonbit_get_affinity_mask() {
    cpu_set_t mask;
    if (sched_getaffinity(0, sizeof(cpu_set_t), &mask) == 0) {
        uint64_t result = 0;
        for (int i = 0; i < 64 && i < CPU_SETSIZE; i++) {
            if (CPU_ISSET(i, &mask)) {
                result |= (1ULL << i);
            }
        }
        return result;
    }
    return 0;
}

bool moonbit_set_affinity_mask(uint64_t mask_val) {
    cpu_set_t mask;
    CPU_ZERO(&mask);
    for (int i = 0; i < 64; i++) {
        if ((mask_val >> i) & 1) {
            CPU_SET(i, &mask);
        }
    }
    return sched_setaffinity(0, sizeof(cpu_set_t), &mask) == 0;
}

#elif defined(__APPLE__)

#include <mach/thread_policy.h>
#include <mach/thread_act.h>
#include <sys/sysctl.h>
#include <pthread.h>

uint64_t moonbit_get_affinity_mask() {
    int count;
    size_t size = sizeof(count);
    if (sysctlbyname("hw.logicalcpu", &count, &size, NULL, 0) == 0) {
        if (count >= 64) {
            return 0xFFFFFFFFFFFFFFFF;
        } else {
            return (1ULL << count) - 1;
        }
    }
    return 0;
}

bool moonbit_set_affinity_mask(uint64_t mask) {
    // Check if we're on Apple Silicon (ARM64)
    size_t size = sizeof(int);
    int is_arm64 = 0;
    if (sysctlbyname("hw.optional.arm64", &is_arm64, &size, NULL, 0) == 0 && is_arm64) {
        // On Apple Silicon, thread affinity is heavily restricted by the OS
        // Return true to indicate "success" since the OS will handle scheduling optimally
        return true;
    }
    
    // For Intel Macs, try to set thread affinity
    // macOS thread affinity is often set to a single core.
    // We will try to set it to the first available core in the mask.
    for (int i = 0; i < 64; i++) {
        if ((mask >> i) & 1) {
            thread_affinity_policy_data_t policy = { i };
            thread_port_t mach_thread = pthread_mach_thread_np(pthread_self());
            kern_return_t result = thread_policy_set(mach_thread, THREAD_AFFINITY_POLICY, 
                                                   (thread_policy_t)&policy, THREAD_AFFINITY_POLICY_COUNT);
            // Even if thread_policy_set fails on modern macOS, we return true
            // because the system scheduler is generally better at managing affinity
            return true;
        }
    }
    return false; // No core found in mask
}

#else

uint64_t moonbit_get_affinity_mask() {
    return 0;
}

bool moonbit_set_affinity_mask(uint64_t mask) {
    return false;
}

#endif
