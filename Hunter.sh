#!/bin/bash

clear

# 🔥 Banner
figlet "Forensic Hunter"
echo "========================================="
echo "📱 Smart Mobile Forensic Tool (WiFi Mode)"
echo "========================================="

# 📡 Hotspot Info
SSID="Devil"
PASS="\$devilwolf\$"

echo ""
echo "📡 STEP 1: Connect target phone to hotspot"
echo "SSID: $SSID"
echo "Password: $PASS"

echo ""
echo "📷 Scan this QR code on target device:"
echo ""

# 🔥 Python QR Code
python3 - <<EOF
import qrcode
data = "WIFI:T:WPA;S:Devil;P:\$devilwolf\$;;"
qr = qrcode.QRCode(border=2)
qr.add_data(data)
qr.make(fit=True)
qr.print_ascii(invert=True)
EOF

echo ""
read -p "👉 Press ENTER after connecting..."

# 🔐 Pairing
echo ""
echo "🔐 STEP 2: Pair device"
echo "On target phone → Developer Options → Wireless Debugging → Pair device"

read -p "Enter pairing IP:PORT → " pair_addr
adb pair $pair_addr

# 🔗 Connect
echo ""
echo "🔗 STEP 3: Connect device"

read -p "Enter connection IP:PORT → " connect_addr
adb connect $connect_addr

# 🔌 Detect device (FIXED)
echo ""
echo "🔌 Detecting device..."

TARGET_DEVICE=$(adb devices | awk 'NR>1 && $2=="device" && $1 !~ /emulator/ {print $1; exit}')

if [ -z "$TARGET_DEVICE" ]; then
    echo "❌ No real device connected!"
    exit 1
fi

echo "✅ Connected: $TARGET_DEVICE"

# 📁 Case details
echo ""
read -p "📁 Enter Case Name: " CASE_NAME
read -p "📄 Case Number: " CASE_NO
read -p "📞 Investigator Contact: " CONTACT

FOLDER="case_$CASE_NAME"
mkdir -p "$FOLDER"

# 📱 Extract About Phone
echo ""
echo "📱 Extracting device info..."

cat <<EOF > "$FOLDER/about_phone.txt"
========== DEVICE INFO ==========
Model: $(adb -s "$TARGET_DEVICE" shell getprop ro.product.model)
Manufacturer: $(adb -s "$TARGET_DEVICE" shell getprop ro.product.manufacturer)
Android Version: $(adb -s "$TARGET_DEVICE" shell getprop ro.build.version.release)
Build ID: $(adb -s "$TARGET_DEVICE" shell getprop ro.build.id)
Serial: $(adb -s "$TARGET_DEVICE" shell getprop ro.serialno)
Extraction Time: $(date)
================================
EOF

# 📦 Apps list
echo "📦 Extracting installed apps..."
adb -s "$TARGET_DEVICE" shell pm list packages > "$FOLDER/apps.txt"

# ⚙️ System info
echo "⚙️ Extracting system properties..."
adb -s "$TARGET_DEVICE" shell getprop > "$FOLDER/system.txt"

# 📂 Pull files
echo "📂 Extracting public files..."
adb -s "$TARGET_DEVICE" pull /sdcard/Download "$FOLDER/Download" 2>/dev/null
adb -s "$TARGET_DEVICE" pull /sdcard/DCIM "$FOLDER/DCIM" 2>/dev/null

# 📄 Generate report
echo "📄 Generating report..."

cat <<EOF > "$FOLDER/report.txt"
========== FORENSIC REPORT ==========
Case Name: $CASE_NAME
Case Number: $CASE_NO
Investigator Contact: $CONTACT
Device: $TARGET_DEVICE
Time: $(date)

--- DEVICE INFO ---
$(cat "$FOLDER/about_phone.txt")

--- INSTALLED APPS (Top 20) ---
$(head -n 20 "$FOLDER/apps.txt")

====================================
EOF

echo ""
echo "========================================="
echo "✅ FORENSIC SCAN COMPLETE"
echo "📁 Folder: $FOLDER"
echo "📄 Report: $FOLDER/report.txt"
echo "========================================="
