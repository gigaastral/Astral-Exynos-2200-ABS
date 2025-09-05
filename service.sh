#!/system/bin/sh

MODDIR=${0%/*}
LOG_TAG="Astral-ABS-Service"

log_message() {
    log -p i -t "$LOG_TAG" "$1"
}

safe_write() {
    if [ -f "$1" ]; then
        echo "$2" > "$1" 2>/dev/null
        log_message "✓ $1 = $2"
        return 0
    fi
    return 1
}

# Wait for system to be fully ready
sleep 60

apply_full_optimizations() {
    log_message "Starting Exynos 2200 optimizations..."
    
    # ================= UNDERCLOCK (-8 MAX) =================
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8" 
    safe_write "/sys/kernel/percent_margin/cpucl2_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/mif_margin_percent" "-6"
    safe_write "/sys/kernel/percent_margin/int_margin_percent" "-5"
    safe_write "/sys/kernel/percent_margin/npu_margin_percent" "-4"
    safe_write "/sys/kernel/percent_margin/isp_margin_percent" "-4"

    # ================= CPU FREQUENCY MANAGEMENT =================
    # Cortex-A510 cluster (cpu0-cpu3) - 1.5GHz max
    for cpu in 0 1 2 3; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "1536000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "400000"
    done

    # Cortex-A710 cluster (cpu4-cpu6) - 2.2GHz max  
    for cpu in 4 5 6; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "2208000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "576000"
    done

    # Cortex-X2 prime core (cpu7) - 2.5GHz max
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor" "powersave"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq" "2515000"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq" "672000"

    # ================= XCLIPSE GPU OPTIMIZATION =================
    # Governor GPU - conservative per bilanciare performance e batteria
    safe_write "/sys/kernel/gpu/gpu_governor" "conservative"
    
    # Frequenza massima GPU - 807MHz per risparmio energetico
    safe_write "/sys/kernel/gpu/gpu_max_clock" "807000"
    
    # Frequenza minima GPU - 303MHz per risparmio
    safe_write "/sys/kernel/gpu/gpu_min_clock" "303000"
    
    # Parametri governor conservative
    safe_write "/sys/kernel/gpu/conservative/up_threshold" "80"
    safe_write "/sys/kernel/gpu/conservative/down_threshold" "60"
    safe_write "/sys/kernel/gpu/conservative/sampling_rate" "100000"

    # ================= MEMORY CONTROLLER =================
    if [ -f "/sys/class/devfreq/17000010.devfreq_mif/max_freq" ]; then
        safe_write "/sys/class/devfreq/17000010.devfreq_mif/max_freq" "1352000"
        safe_write "/sys/class/devfreq/17000010.devfreq_mif/min_freq" "676000"
    fi
    
    if [ -f "/sys/class/devfreq/17000010.devfreq_mif/governor" ]; then
        safe_write "/sys/class/devfreq/17000010.devfreq_mif/governor" "powersave"
    fi

    # ================= POWER SAVING FEATURES =================
    # I/O scheduler
    for block in /sys/block/sda/queue /sys/block/mmcblk0/queue /sys/block/mmcblk1/queue; do
        [ -d "$block" ] && safe_write "$block/scheduler" "mq-deadline"
        [ -d "$block" ] && safe_write "$block/read_ahead_kb" "128"
        [ -d "$block" ] && safe_write "$block/nr_requests" "128"
        [ -d "$block" ] && safe_write "$block/iostats" "0"
    done

    # Kernel parameters
    safe_write "/proc/sys/vm/swappiness" "10"
    safe_write "/proc/sys/vm/vfs_cache_pressure" "50"
    safe_write "/proc/sys/vm/dirty_ratio" "20"
    safe_write "/proc/sys/vm/dirty_background_ratio" "5"
    safe_write "/proc/sys/vm/dirty_writeback_centisecs" "2000"

    # CPU idle governor
    safe_write "/sys/devices/system/cpu/cpuidle/current_governor" "menu"

    log_message "Exynos 2200 Xclipse optimizations completed"
}

apply_full_optimizations

# ================= MAINTENANCE LOOP =================
while true; do
    sleep 300
    
    # Maintain CPU settings
    for cpu in 0 1 2 3 4 5 6 7; do
        current_gov=$(cat /sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor 2>/dev/null)
        [ "$current_gov" != "powersave" ] && \
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
    done
    
    # Maintain frequencies
    safe_write "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" "1536000"
    safe_write "/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq" "2208000" 
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq" "2515000"
    
    # Maintain GPU settings
    safe_write "/sys/kernel/gpu/gpu_governor" "conservative"
    safe_write "/sys/kernel/gpu/gpu_max_clock" "807000"
    safe_write "/sys/kernel/gpu/gpu_min_clock" "303000"
    
    # Maintain undervolting
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"

    log_message "Astral ABS maintenance completed"
done