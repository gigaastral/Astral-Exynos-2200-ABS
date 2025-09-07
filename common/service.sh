#!/system/bin/sh
MODDIR=${0%/*}
LOG_TAG="Astral-ABS-Ultimate"

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

# Wait for boot to be completed
while [ `getprop vendor.post_boot.parsed` != "1" ]; do
    sleep 1
done

sleep 2

# ================= TUTTE LE IMPOSTAZIONI E2200OPT =================
apply_e2200opt_settings() {
    log_message "Applying all e2200opt optimizations..."
    
    # Kernel scheduler settings
    safe_write "/proc/sys/kernel/sched_wakeup_granularity_ns" "3000000"
    safe_write "/proc/sys/kernel/sched_latency_ns" "10000000"
    safe_write "/proc/sys/kernel/sched_min_granularity_ns" "950000"
    safe_write "/proc/sys/kernel/sched_migration_cost_ns" "1000000"
    safe_write "/proc/sys/kernel/sched_rt_period_us" "1000000"
    safe_write "/proc/sys/kernel/perf_cpu_time_max_percent" "10"
    safe_write "/proc/sys/kernel/sched_rr_timeslice_ms" "30"
    safe_write "/proc/sys/kernel/sched_nr_migrate" "64"
    safe_write "/proc/irq/default_smp_affinity" "0f"
    safe_write "/sys/bus/workqueue/devices/writeback/cpumask" "ff"
    safe_write "/sys/devices/virtual/workqueue/cpumask" "ff"
    safe_write "/dev/cpuset/sched_load_balance" "0"
    safe_write "/proc/sys/kernel/pid_max" "65536"
    safe_write "/proc/sys/kernel/printk_devkmsg" "off"
    safe_write "/proc/sys/kernel/sched_schedstats" "0"
    safe_write "/proc/sys/kernel/sched_tunable_scaling" "0"
    safe_write "/proc/sys/kernel/perf_cpu_time_max_percent" "5"
    safe_write "/proc/sys/kernel/perf_event_max_sample_rate" "100000"
    safe_write "/proc/sys/kernel/perf_event_mlock_kb" "516"
    
    if [ -f "/proc/sys/kernel/printk" ]; then
        echo "0 0 0 0" > /proc/sys/kernel/printk
    fi

    # Kernel panic off
    sysctl -w kernel.panic=0
    sysctl -w vm.panic_on_oom=0
    sysctl -w kernel.panic_on_oops=0
    sysctl -w kernel.softlockup_panic=0

    # ZRAM settings
    chmod 644 /dev/block/zram0
    safe_write "/sys/block/zram0/comp_algorithm" "lz4"
    swapoff /dev/block/zram0 > /dev/null 2>&1
    safe_write "/sys/block/zram0/reset" "1"
    safe_write "/sys/block/zram0/disksize" "0"
    safe_write "/sys/block/zram0/max_comp_streams" "4"
    safe_write "/sys/block/zram0/disksize" "1610612736"
    mkswap /dev/block/zram0 > /dev/null 2>&1
    swapon /dev/block/zram0 > /dev/null 2>&1

    # VM settings
    safe_write "/proc/sys/vm/vfs_cache_pressure" "150"
    safe_write "/proc/sys/vm/swappiness" "140"
    safe_write "/proc/sys/vm/dirty_writeback_centisecs" "2000"
    safe_write "/proc/sys/vm/dirty_expire_centisecs" "2000"
    safe_write "/proc/sys/vm/overcommit_ratio" "50"
    safe_write "/proc/sys/vm/dirty_ratio" "25"
    safe_write "/proc/sys/vm/dirty_background_ratio" "10"
    safe_write "/proc/sys/vm/vfs_cache_pressure" "200"
    safe_write "/proc/sys/vm/drop_caches" "3"
    safe_write "/proc/sys/vm/oom_kill_allocating_task" "0"

    # PTY and keys settings
    safe_write "/proc/sys/kernel/pty/max" "6144"
    safe_write "/proc/sys/kernel/keys/gc_delay" "100"
    safe_write "/proc/sys/kernel/keys/maxbytes" "20000"
    safe_write "/proc/sys/kernel/keys/maxkeys" "200"

    # Filesystem settings
    safe_write "/proc/sys/fs/dir-notify-enable" "0"
    safe_write "/proc/sys/fs/lease-break-time" "10"
    safe_write "/proc/sys/fs/aio-max-nr" "327680"
    safe_write "/proc/sys/fs/inotify/max_queued_events" "131072"
    safe_write "/proc/sys/fs/inotify/max_user_watches" "131072"
    safe_write "/proc/sys/fs/inotify/max_user_instances" "1024"

    # Power management
    safe_write "/sys/power/pm_freeze_timeout" "60000"
    safe_write "/sys/module/workqueue/parameters/power_efficient" "N"

    # Network congestion control
    sysctl -w net.ipv4.tcp_congestion_control=bbr

    for cpu in 0 1 2 3 4 5 6 7; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/online" "1"
    done

    # CPU frequency settings
    safe_write "/sys/devices/platform/exynos-migov/cl0/cl0_pm_qos_min_freq" "1824000"
    chown root /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
    safe_write "/sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq" "1824000"

    safe_write "/sys/devices/platform/exynos-migov/cl1/cl1_pm_qos_max_freq" "2515000"
    chown root /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    safe_write "/sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq" "2515000"

    safe_write "/sys/devices/platform/exynos-migov/cl2/cl2_pm_qos_max_freq" "2808000"
    chown root /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq
    safe_write "/sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq" "2808000"
	
	 # ================= CPU FREQUENCY MANAGEMENT =================
    # Cortex-A510 cluster (cpu0-cpu3) - 1.5GHz max
    for cpu in 0 1 2 3; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "1632000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "400000"
    done

    # Cortex-A710 cluster (cpu4-cpu6) - 2.2GHz max  
    for cpu in 4 5 6; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "2304000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "576000"
    done

    # Cortex-X2 prime core (cpu7) - 2.5GHz max
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor" "powersave"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq" "2611000"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq" "672000"

    chmod 0444 /sys/devices/system/cpu/cpufreq/policy*/scaling_max_freq
	
	# ================= XCLIPSE GPU OPTIMIZATION =================
    # Governor GPU - conservative per bilanciare performance e batteria
    safe_write "/sys/kernel/gpu/gpu_governor" "conservative"
    
    # Frequenza massima GPU - 807MHz per risparmio energetico
    safe_write "/sys/kernel/gpu/gpu_max_clock" "999000"
    
    # Frequenza minima GPU - 303MHz per risparmio
    safe_write "/sys/kernel/gpu/gpu_min_clock" "303000"
    
    # Parametri governor conservative
    safe_write "/sys/kernel/gpu/conservative/up_threshold" "80"
    safe_write "/sys/kernel/gpu/conservative/down_threshold" "60"
    safe_write "/sys/kernel/gpu/conservative/sampling_rate" "100000"

    # Schedutil settings
    safe_write "/sys/devices/system/cpu/cpufreq/policy4/schedutil/rate_limit_us" "5000"
    safe_write "/sys/devices/system/cpu/cpufreq/policy0/schedutil/rate_limit_us" "5000"
    safe_write "/sys/devices/system/cpu/cpufreq/policy7/schedutil/rate_limit_us" "5000"

    # Kernel module optimizations
    safe_write "/sys/module/hid_apple/parameters/fnmode" "0"
    safe_write "/sys/module/hid/parameters/ignore_special_drivers" "0"
    safe_write "/sys/module/hid_magicmouse/parameters/emulate_3button" "N"
    safe_write "/sys/module/hid_magicmouse/parameters/emulate_scroll_wheel" "N"
    safe_write "/sys/module/hid_magicmouse/parameters/scroll_speed" "0"
    safe_write "/sys/module/ip6_tunnel/parameters/log_ecn_error" "N"
    safe_write "/sys/module/sit/parameters/log_ecn_error" "N"
    safe_write "/sys/module/printk/parameters/console_suspend" "Y"
    safe_write "/sys/module/printk/parameters/cpu" "N"
    safe_write "/sys/module/printk/parameters/ignore_loglevel" "Y"
    safe_write "/sys/module/printk/parameters/pid" "N"
    safe_write "/sys/module/printk/parameters/time" "N"
    safe_write "/sys/module/battery_saver/parameters/enabled" "Y"
    safe_write "/sys/module/cpuidle/parameters/off" "1"
    safe_write "/sys/module/binder/parameters/debug_mask" "0"
    safe_write "/sys/module/binder_alloc/parameters/debug_mask" "0"
    safe_write "/proc/sys/kernel/printk_devkmsg" "0"
    echo "3 4 1 7" > /proc/sys/kernel/printk
    safe_write "/proc/sys/kernel/kmsg_dump_on_oops" "0"

    # Input booster and stune settings
    for booster in /sys/class/input_booster/*; do
        safe_write "$booster" "0"
    done

    # Foreground settings
    safe_write "/dev/stune/foreground/schedtune.sched_boost_no_override" "0"
    safe_write "/dev/stune/foreground/schedtune.boost" "0"
    safe_write "/dev/stune/foreground/schedtune.prefer_idle" "0"
    safe_write "/dev/cpuctl/foreground/cpu.uclamp.sched_boost_no_override" "0"
    safe_write "/dev/cpuctl/foreground/cpu.uclamp.min" "0"
    safe_write "/dev/cpuctl/foreground/cpu.uclamp.latency_sensitive" "0"

    # Background settings
    safe_write "/dev/stune/background/schedtune.sched_boost_no_override" "0"
    safe_write "/dev/stune/background/schedtune.boost" "0"
    safe_write "/dev/stune/background/schedtune.prefer_idle" "0"
    safe_write "/dev/cpuctl/background/cpu.uclamp.sched_boost_no_override" "0"
    safe_write "/dev/cpuctl/background/cpu.uclamp.min" "0"
    safe_write "/dev/cpuctl/background/cpu.uclamp.latency_sensitive" "0"

    # STUNE settings
    safe_write "/dev/stune/schedtune.boost" "0"
    safe_write "/dev/stune/schedtune.sched_boost_enabled" "0"
    safe_write "/dev/stune/schedtune.sched_boost_no_override" "0"
    safe_write "/dev/stune/schedtune.prefer_idle" "1"
    safe_write "/dev/stune/cgroup.clone_children" "0"

    # Cpuset values
    safe_write "/dev/cpuset/top-app/cpus" "0-7"
    safe_write "/dev/cpuset/foreground/cpus" "0-7"
    safe_write "/dev/cpuset/background/cpus" "0-3"
    safe_write "/dev/cpuset/system-background/cpus" "0-3"
    safe_write "/dev/cpuset/restricted/cpus" "0-3"

    # Fragmentation index
    safe_write "/proc/sys/vm/extfrag_threshold" "750"

    # Network traffic tweaks
    safe_write "/proc/sys/net/ipv4/tcp_tw_recycle" "1"
    safe_write "/proc/sys/net/ipv4/tcp_fack" "1"
    safe_write "/proc/sys/net/ipv4/tcp_ecn" "1"
    safe_write "/proc/sys/net/ipv4/tcp_dsack" "1"
    safe_write "/proc/sys/net/ipv4/conf/default/secure_redirects" "1"
    safe_write "/proc/sys/net/ipv4/tcp_sack" "1"
    safe_write "/proc/sys/net/ipv4/tcp_rfc1337" "1"
    safe_write "/proc/sys/net/ipv4/tcp_fastopen" "3"
    safe_write "/proc/sys/net/ipv4/conf/all/secure_redirects" "1"

    # CPU topology permissions
    for cpu in 0 1 2 3 4 5 6 7; do
        chmod 000 /sys/devices/system/cpu/cpu$cpu/topology/physical_package_id
        chmod 000 /sys/devices/system/cpu/cpu$cpu/topology/core_id
    done

    # ================= TUO UNDERCLOCK ORIGINALE (-8) =================
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl2_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cp_cpu_margin_percent" "-2"
    safe_write "/sys/kernel/percent_margin/cp_cpu_em_margin_percent" "-2"
    safe_write "/sys/kernel/percent_margin/cp_mcw_margin_percent" "-3"
    safe_write "/sys/kernel/percent_margin/npu_margin_percent" "-4"
    safe_write "/sys/kernel/percent_margin/wlbt_margin_percent" "-2"
    safe_write "/sys/kernel/percent_margin/disp_margin_percent" "-10"
    safe_write "/sys/kernel/percent_margin/mif_margin_percent" "-6"
    safe_write "/sys/kernel/percent_margin/int_margin_percent" "-5"
    safe_write "/sys/kernel/percent_margin/cam_margin_percent" "-2"
    safe_write "/sys/kernel/percent_margin/dnc_margin_percent" "-4"
    safe_write "/sys/kernel/percent_margin/gnss_margin_percent" "-2"
    safe_write "/sys/kernel/percent_margin/vts_margin_percent" "-2"
    safe_write "/sys/kernel/percent_margin/intg3d_margin_percent" "-2"
    safe_write "/sys/kernel/percent_margin/aud_margin_percent" "-7"
    safe_write "/sys/kernel/percent_margin/alive_margin_percent" "-3"

    chmod 0644 /sys/kernel/percent_margin/*

    # Devfreq settings
    safe_write "/sys/class/devfreq/17000040.devfreq_disp/max_freq" "800000"
    safe_write "/sys/class/devfreq/17000040.devfreq_disp/min_freq" "800000"
    safe_write "/sys/class/devfreq/17000040.devfreq_disp/target_freq" "800000"

    safe_write "/sys/class/devfreq/17000070.devfreq_aud/max_freq" "1594000"
    safe_write "/sys/class/devfreq/17000070.devfreq_aud/min_freq" "1594000"
    safe_write "/sys/class/devfreq/17000070.devfreq_aud/target_freq" "1594000"

    safe_write "/sys/class/devfreq/17000010.devfreq_mif/max_freq" "3172000"
    safe_write "/sys/class/devfreq/17000010.devfreq_mif/min_freq" "3172000"
    safe_write "/sys/class/devfreq/17000010.devfreq_mif/target_freq" "3172000"
    safe_write "/sys/class/devfreq/17000010.devfreq_mif/exynos_data/debug_scaling_devfreq_min" "3172000"
    safe_write "/sys/class/devfreq/17000010.devfreq_mif/exynos_data/debug_scaling_devfreq_max" "3172000"

    # GPU permissions
    chmod 0644 /sys/kernel/gpu/gpu_freq_table
    chmod 0644 /sys/kernel/gpu/gpu_model
    chmod 0644 /sys/kernel/gpu/gpu_max_clock
    chmod 0644 /sys/kernel/gpu/gpu_min_clock

    # Devfreq permissions
    chmod 0644 /sys/class/devfreq/17000040.devfreq_disp/*
    chmod 0644 /sys/class/devfreq/17000070.devfreq_aud/*
    chmod 0644 /sys/class/devfreq/17000010.devfreq_mif/*

    log_message "All e2200opt settings applied with your -8 undervolt"
}

# ================= APPLICA TUTTO =================
apply_e2200opt_settings

# ================= MAINTENANCE LOOP =================
while true; do
    sleep 300
    
    # Maintain your undervolt settings
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl2_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"
	
	for cpu in 0 1 2 3; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "1632000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "400000"
    done
  
    for cpu in 4 5 6; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_max_freq" "2304000"
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_min_freq" "576000"
    done

    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor" "powersave"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq" "2611000"
    safe_write "/sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq" "672000"
	
	safe_write "/sys/kernel/gpu/gpu_governor" "conservative"
    safe_write "/sys/kernel/gpu/gpu_max_clock" "999000"
    safe_write "/sys/kernel/gpu/gpu_min_clock" "303000"

    log_message "Maintenance completed - All optimizations active"
done
