#!/system/bin/sh

MODDIR=${0%/*}
LOG_TAG="Astral-ABS"

# Minimal optimizations during boot for faster startup
apply_minimal_optimizations() {
    # Safe write function
    safe_write() {
        [ -f "$1" ] && echo "$2" > "$1" 2>/dev/null
    }
    
    # Only essential undervolting during boot
    safe_write "/sys/kernel/percent_margin/cpucl0_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/cpucl1_margin_percent" "-8"
    safe_write "/sys/kernel/percent_margin/g3d_margin_percent" "-8"
    
    # Quick CPU governor setting for all cores
    for cpu in 0 1 2 3 4 5 6 7; do
        safe_write "/sys/devices/system/cpu/cpu$cpu/cpufreq/scaling_governor" "powersave"
    done
}

# Wait a bit for system stability
sleep 8

# Apply minimal optimizations for fast boot
apply_minimal_optimizations

# Start background service for full optimizations
$MODDIR/service.sh &