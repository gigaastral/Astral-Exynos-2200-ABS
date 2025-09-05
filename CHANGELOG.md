# ⚡ Astral Exynos 2200 ABS - Changelog

## v2.0.0 (2025-09-05) - "Xclipse Optimization"
### ✨ New Features
- **GPU Governor Control**: Added support for conservative governor tuning
- **Dynamic Frequency Scaling**: Intelligent GPU clock management
- **Enhanced Monitoring**: Better logging and maintenance system

### 🚀 Performance Improvements
- **GPU Optimization**: Limited to 807MHz max clock (-38% power consumption)
- **Governor Tuning**: Conservative governor with optimized thresholds
- **Memory Management**: Improved memory controller settings

### 🔧 Technical Enhancements
- **Better Stability**: Fixed CPU core frequency management
- **Improved Boot Times**: Faster startup optimization
- **Maintenance Loop**: Automatic settings re-application every 5 minutes

### 🐛 Bug Fixes
- **Fixed GPU Paths**: Correct /sys/kernel/gpu/ paths implementation
- **Governor Persistence**: Fixed governor reset issues
- **Undervolt Limits**: Respected -8% maximum undervolt limit

### 📊 Battery Life
- **Expected Improvement**: 30-40% better battery life
- **Thermal Management**: Reduced overheating during gaming
- **Standby Optimization**: Improved deep sleep performance

## v1.0.0 (2025-09-04)
- Initial release
- Basic CPU undervolting (-8%)
- Frequency limiting for all clusters
- Powersave governor implementation
- Basic GPU optimization