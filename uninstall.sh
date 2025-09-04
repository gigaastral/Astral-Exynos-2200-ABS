#!/system/bin/sh

ui_print() {
    echo -e "ui_print $1\nui_print" >> /proc/self/fd/$2\_fd
}

ui_print " "
ui_print "🗑️  Removing ⚡ Astral Exynos 2200 ABS..."
ui_print "🔙 Restoring default system settings..."
ui_print " "

ui_print "✅ Astral ABS uninstalled successfully!"
ui_print "🔄 Reboot to complete uninstallation"
ui_print " "