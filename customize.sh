#!/system/bin/sh

SKIPUNZIP=1
MODPATH="$2"

ui_print() {
    echo "$1"
    echo "ui_print $1" >> /proc/self/fd/$OUTFD
    echo "ui_print " >> /proc/self/fd/$OUTFD
}

ui_print " "
ui_print "╔══════════════════════════════════════════════╗"
ui_print "║           ⚡ Astral Exynos 2200 ABS ⚡        ║"
ui_print "║         Advanced Battery Saver Module        ║"
ui_print "╚══════════════════════════════════════════════╝"
ui_print " "
ui_print "🔋 Installing Astral ABS optimization module..."
ui_print "📱 Compatible: All Exynos 2200 Devices"
ui_print "⚡ Features: Triple-cluster CPU Optimization"
ui_print "🎮 Xclipse GPU Tuning, Advanced Power Management"
ui_print "🌡️  Intelligent Thermal Control"
ui_print " "

# Extract module files
ui_print "📦 Extracting module files..."
unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2

# Set permissions
ui_print "🔧 Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/customize.sh" 0 0 0755

ui_print " "
ui_print "✅ Astral ABS installation completed!"
ui_print " "
ui_print "📋 Advanced Features:"
ui_print "• Cortex-X2/A710/A510 Undervolting (-8%)"
ui_print "• Xclipse GPU AMD RDNA2 Optimization"
ui_print "• Intelligent Frequency Management"
ui_print "• Advanced Thermal Throttling"
ui_print "• System-wide Power Savings"
ui_print " "
ui_print "⚠️  Reboot required for full effect"
ui_print " "