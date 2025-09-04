#!/system/bin/sh

MODDIR=${0%/*}
LOG_TAG="Astral-Exynos2200-ABS"

# Enhanced logging function
log_message() {
    log -p i -t "$LOG_TAG" "$1"
}

# Safe write function with validation
safe_write() {
    if [ -f "$1" ]; then
        echo "$2" > "$1" 2>/dev/null
        if [ $? -eq 0 ]; then
            log_message "✓ Set $1 = $2"
            return 0
        else
            log_message "✗ Failed to write to $1"
            return 1
        fi
    else
        log_message "⚠ File not found: $1"
        return 2
    fi
}

# Wait for system stability
log_message "Starting ⚡ Astral Exynos 2200 ABS ⚡..."
sleep 25

apply_astral_optimizations() {
    log_message "Applying Astral ABS optimizations for Exynos 2200..."
    
    # ================= UNDERCLOCK SECTION =================
    log_message "--- Applying Astral Underclock Settings ---"
    
    # CPU Cluster Underclocking (Cortex-X2, A710, A510)
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl2_margin_percent" "-8"
    
    # Xclipse GPU Underclocking
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"
    
    # Memory and System Underclocking
    safe_write "/sys/kernel/percent_margin/mif_margin_percent" "-6"
    safe_write "/sys/kernel/percent_margin/int_margin_percent" "-5"
    safe_write "/sys/kernel/percent_margin/npu_margin_percent" "-4"
    safe_write "/sys/kernel/percent_margin/isp_margin_percent" "-4"

    # ================= CPU OPTIMIZATION =================
    log_message "--- Astral CPU Frequency Management ---"
    
    # Cortex-A510 cluster (0-3) optimization
    for cpu in 0 1 2 3; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "1440000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "400000"
    done

    # Cortex-A710 cluster (4-6) optimization  
    for cpu in 4 5 6; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "2112000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "576000"
    done

    # Cortex-X2 prime core (7) optimization
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor" "powersave"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq" "2304000"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq" "672000"

    # Disable aggressive boosting
    safe_write "/sys/module/cpu_boost/parameters/input_boost_enabled" "0"
    safe_write "/sys/module/msm_performance/parameters/touchboost" "0"

    # ================= XCLIPSE GPU OPTIMIZATION =================
    log_message "--- Astral Xclipse GPU Tuning ---"
    safe_write "/sys/class/kgsl/kgsl-3d0/devfreq/governor" "simple_ondemand"
    safe_write "/sys/class/kgsl/kgsl-3d0/devfreq/max_freq" "342000000"
    safe_write "/sys/class/kgsl/kgsl-3d0/devfreq/min_freq" "100000000"

    # ================= EXYNOS MEMORY OPTIMIZATION =================
    log_message "--- Astral Memory Controller Tuning ---"
    [ -d "/sys/class/devfreq/exynos-devfreq-mif" ] && \
    safe_write "/sys/class/devfreq/exynos-devfreq-mif/governor" "powersave"

    # ================= I/O SCHEDULER =================
    log_message "--- Astral Storage Optimization ---"
    for block in /sys/block/sd* /sys/block/mmcblk*; do
        [ -d "$block/queue" ] && safe_write "$block/queue/scheduler" "mq-deadline"
        [ -d "$block/queue" ] && safe_write "$block/queue/read_ahead_kb" "128"
    done

    # ================= KERNEL TUNING =================
    log_message "--- Astral Kernel Optimization ---"
    safe_write "/proc/sys/vm/swappiness" "0"
    safe_write "/proc/sys/vm/vfs_cache_pressure" "10"
    safe_write "/proc/sys/vm/dirty_ratio" "100"
    safe_write "/proc/sys/vm/dirty_background_ratio" "50"

    # ================= NETWORK OPTIMIZATION =================
    log_message "--- Astral Network Power Saving ---"
    safe_write "/proc/sys/net/ipv4/tcp_tw_reuse" "1"
    safe_write "/proc/sys/net/ipv4/tcp_sack" "1"

    log_message "✅ ⚡ Astral ABS optimizations applied successfully!"
}

# Execute optimizations
apply_astral_optimizations

# Re-apply after full boot
sleep 45
apply_astral_optimizations

# Start monitoring service
$MODDIR/service.sh &