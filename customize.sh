#!/system/bin/sh

SKIPUNZIP=1

# Create module directory
mkdir -p $MODPATH

# Extract module files
ui_print "📦 Extracting module files..."
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >/dev/null

# Set permissions
ui_print "🔧 Setting permissions..."
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/post-fs-data.sh 0 0 0755
set_perm $MODPATH/service.sh 0 0 0755

ui_print "✅ Installation completed!"
ui_print "🔄 Reboot to apply optimizations"