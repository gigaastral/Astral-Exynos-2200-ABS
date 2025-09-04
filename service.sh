#!/system/bin/sh

MODDIR=${0%/*}
LOG_TAG="Astral-ABS-Service"

log_message() {
    log -p i -t "$LOG_TAG" "$1"
}

safe_write() {
    if [ -f "$1" ]; then
        echo "$2" > "$1" 2>/dev/null
        log_message "Applied: $1 = $2"
    fi
}

# Wait for system to be fully ready (after boot complete)
sleep 45

apply_full_optimizations() {
    log_message "Starting full Astral ABS optimizations..."
    
    # Complete undervolting
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl2_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/mif_margin_percent" "-6"
    safe_write "/sys/kernel/percent_margin/int_margin_percent" "-5"
    safe_write "/sys/kernel/percent_margin/npu_margin_percent" "-4"
    safe_write "/sys/kernel/percent_margin/isp_margin_percent" "-4"

    # CPU Frequency Management
    for cpu in 0 1 2 3; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "1440000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "400000"
    done

    for cpu in 4 5 6; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "2112000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "576000"
    done

    # Cortex-X2 core (cpu7)
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor" "powersave"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq" "2304000"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq" "672000"

    # GPU Optimization
    safe_write "/sys/class/kgsl/kgsl-3d0/devfreq/governor" "simple_ondemand"
    safe_write "/sys/class/kgsl/kgsl-3d0/devfreq/max_freq" "342000000"
    safe_write "/sys/class/kgsl/kgsl-3d0/devfreq/min_freq" "100000000"

    # Disable CPU boosts
    safe_write "/sys/module/cpu_boost/parameters/input_boost_enabled" "0"
    safe_write "/sys/module/msm_performance/parameters/touchboost" "0"

    log_message "Full Astral ABS optimizations completed"
}

# Apply full optimizations
apply_full_optimizations

# Maintenance loop - runs every 5 minutes
while true; do
    sleep 300
    
    # Maintain CPU governors
    for cpu in 0 1 2 3 4 5 6 7; do
        current_gov=$(cat /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor 2>/dev/null)
        [ "$current_gov" != "powersave" ] && \
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
    done
    
    # Maintain critical undervolting
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"
    
    log_message "Astral ABS maintenance completed"
done