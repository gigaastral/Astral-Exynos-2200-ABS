#!/system/bin/sh

MODDIR=${0%/*}
LOG_TAG="Astral-ABS-Ultimate"

apply_combined_optimizations() {
    safe_write() {
        [ -f "$1" ] && echo "$2" > "$1" 2>/dev/null
    }
    
    # TUO UNDERCLOCK ORIGINALE (-8) durante il boot
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"
    
    # I/O scheduler optimization da e2200opt
    for io in /sys/block/*/queue/; do
        [ -d "$io" ] && safe_write "${io}scheduler" "none"
        [ -d "$io" ] && safe_write "${io}read_ahead_kb" "128"
        [ -d "$io" ] && safe_write "${io}nr_requests" "32"
        [ -d "$io" ] && safe_write "${io}iostats" "0"
    done

    # UFC settings da e2200opt
    chmod 644 /sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit
    chmod 644 /sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit_strict
    safe_write "/sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit_strict" "2803000"
    safe_write "/sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit" "2803000"
    chmod 444 /sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit
    chmod 444 /sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit_strict

    # Xperf settings
    safe_write "/sys/devices/platform/xperf/gmc/big_thd" "700"
    safe_write "/sys/devices/platform/xperf/gmc/mid_thd_h" "700"

    # EMS settings
    safe_write "/sys/kernel/ems/energy_step/coregroup0/step" "3"
    safe_write "/sys/kernel/ems/energy_step/coregroup4/step" "5"
    safe_write "/sys/kernel/ems/energy_step/coregroup7/step" "7"
    safe_write "/sys/kernel/ems/energy_step/coregroup0/uclamp_max" "1536"
    safe_write "/sys/kernel/ems/energy_step/coregroup4/uclamp_max" "1185"
    safe_write "/sys/kernel/ems/energy_step/coregroup7/uclamp_max" "1536"
    safe_write "/sys/kernel/ems/frt/disable_cpufreq" "1"

    # Thermal settings completi da e2200opt
    apply_thermal_settings
}

apply_thermal_settings() {
    # [Inserisci qui TUTTE le impostazioni thermal da post-fs-data-e2200opt.sh]
    # (Tutti i trip_point_*_temp e trip_point_*_hyst per tutte le zone)
    # [...] (copiare tutto il blocco thermal qui)
}

sleep 8
apply_combined_optimizations
$MODDIR/service.sh &