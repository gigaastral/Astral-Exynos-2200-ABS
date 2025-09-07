#!/system/bin/sh

MODDIR=${0%/*}
LOG_TAG="Astral-ABS-Ultimate"

log_message() {
    log -p i -t "$LOG_TAG" "$1"
}

safe_write() {
    if [ -f "$1" ]; then
        echo "$2" > "$1" 2>/dev/null
        if [ $? -eq 0 ]; then
            log_message "✓ $1 = $2"
            return 0
        else
            log_message "✗ Failed to write $1 = $2"
            return 1
        fi
    fi
    return 1
}

apply_combined_optimizations() {
    log_message "Applying early boot optimizations..."
    
    # Aggiungi un ritardo per garantire che i subsystem siano pronti
    sleep 3
    
    # TUO UNDERCLOCK ORIGINALE (-8) durante il boot
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"
    
    # I/O scheduler optimization da e2200opt
    for block in /sys/block/*/; do
        if [ -d "${block}queue" ]; then
            safe_write "${block}queue/scheduler" "none"
            safe_write "${block}queue/read_ahead_kb" "128"
            safe_write "${block}queue/nr_requests" "32"
            safe_write "${block}queue/iostats" "0"
        fi
    done

    # UFC settings da e2200opt - con controlli di sicurezza
    if [ -f "/sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit" ]; then
        chmod 644 /sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit
        safe_write "/sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit" "2803000"
        chmod 444 /sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit
    fi
    
    if [ -f "/sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit_strict" ]; then
        chmod 644 /sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit_strict
        safe_write "/sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit_strict" "2803000"
        chmod 444 /sys/devices/platform/exynos-ufcc/ufc/cpufreq_max_limit_strict
    fi

    # Xperf settings - con controlli
    if [ -f "/sys/devices/platform/xperf/gmc/big_thd" ]; then
        safe_write "/sys/devices/platform/xperf/gmc/big_thd" "700"
    fi
    
    if [ -f "/sys/devices/platform/xperf/gmc/mid_thd_h" ]; then
        safe_write "/sys/devices/platform/xperf/gmc/mid_thd_h" "700"
    fi

    # EMS settings - con controlli
    if [ -d "/sys/kernel/ems" ]; then
        safe_write "/sys/kernel/ems/energy_step/coregroup0/step" "3"
        safe_write "/sys/kernel/ems/energy_step/coregroup4/step" "5"
        safe_write "/sys/kernel/ems/energy_step/coregroup7/step" "7"
        safe_write "/sys/kernel/ems/energy_step/coregroup0/uclamp_max" "1536"
        safe_write "/sys/kernel/ems/energy_step/coregroup4/uclamp_max" "1185"
        safe_write "/sys/kernel/ems/energy_step/coregroup7/uclamp_max" "1536"
        safe_write "/sys/kernel/ems/frt/disable_cpufreq" "1"
    fi

    # Thermal settings - applicati solo se disponibili
    apply_thermal_settings
    
    log_message "Early boot optimizations completed"
}

apply_thermal_settings() {
    # Thermal settings con controlli di sicurezza
    thermal_zones="/sys/devices/virtual/thermal"
    
    if [ -d "$thermal_zones" ]; then
        for zone in thermal_zone*; do
            if [ -d "$thermal_zones/$zone" ]; then
                # Imposta temperature di trip point
                for trip_file in trip_point_*_temp; do
                    if [ -f "$thermal_zones/$zone/$trip_file" ]; then
                        safe_write "$thermal_zones/$zone/$trip_file" "95000"
                    fi
                done
                
                # Imposta hysteresis values
                for hyst_file in trip_point_*_hyst; do
                    if [ -f "$thermal_zones/$zone/$hyst_file" ]; then
                        safe_write "$thermal_zones/$zone/$hyst_file" "5000"
                    fi
                done
            fi
        done
        log_message "Thermal settings applied"
    else
        log_message "Thermal zones not found"
    fi
}

# Wait for basic system readiness
sleep 10
apply_combined_optimizations

# Avvia il service.sh in background
if [ -f "$MODDIR/service.sh" ]; then
    log_message "Starting main service..."
    $MODDIR/service.sh &
else
    log_message "ERROR: service.sh not found!"
fi