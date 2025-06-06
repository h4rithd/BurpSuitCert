#!/system/bin/sh

exec > /data/local/tmp/BurpSuiteCert.log 2>&1
set -x

echo "*******************************"
echo "  BurpSuite CA Installer v1.0  "
echo "                  by @h4rithd  "
echo "*******************************"

MODDIR="${0%/*}"
CUSTOM_CERTS="${MODDIR}/system/etc/security/cacerts"
APEX_CA_DIR="/apex/com.android.conscrypt/cacerts"
TMP_COPY="/data/local/tmp/burpca-h4rithd"

set_context() {
    if [ "$(getenforce)" != "Enforcing" ]; then return 0; fi
    local reference_path="$1"
    local target_path="$2"
    local default_context="u:object_r:system_file:s0"
    local context
    context=$(ls -Zd "$reference_path" | awk '{print $1}')
    if [ -n "$context" ] && [ "$context" != "?" ]; then
        chcon -R "$context" "$target_path"
    else
        chcon -R "$default_context" "$target_path"
    fi
}

echo "[1/5] Setting ownership on custom certs..."
chown -R 0:0 "$CUSTOM_CERTS"

echo "[2/5] Setting SELinux context on custom certs..."
set_context /system/etc/security/cacerts "$CUSTOM_CERTS"

if [ -d "$APEX_CA_DIR" ]; then
    echo "[3/5] Preparing tmpfs for CA cert override..."
    rm -rf "$TMP_COPY"
    mkdir -p "$TMP_COPY"
    mount -t tmpfs tmpfs "$TMP_COPY"

    echo "[4/5] Copying system and Burp certs into tmpfs..."
    cp -f "$APEX_CA_DIR"/* "$TMP_COPY"/
    cp -f "$CUSTOM_CERTS"/* "$TMP_COPY"/
    chown -R 0:0 "$TMP_COPY"
    set_context "$APEX_CA_DIR" "$TMP_COPY"

    CERTS_NUM=$(ls -1 "$TMP_COPY" | wc -l)
    if [ "$CERTS_NUM" -gt 10 ]; then
        echo "[5/5] Binding modified certs to APEX..."
        mount --bind "$TMP_COPY" "$APEX_CA_DIR"
        for pid in 1 $(pgrep zygote) $(pgrep zygote64); do
            nsenter --mount="/proc/${pid}/ns/mnt" -- \
                mount --bind "$TMP_COPY" "$APEX_CA_DIR"
        done
        echo "✅ Burp Suite CA successfully installed and active."
    else
        echo "❌ Aborting: CA cert count too low ($CERTS_NUM)."
    fi

    umount "$TMP_COPY"
    rmdir "$TMP_COPY"
else
    echo "⚠️ APEX CA directory not found. Skipping injection."
fi
create a read me file for the above script. this module is used to install Burp Suite CA certificate on Android devices. and module name is BurpSuiteCert and give me the markdown fle as downloadable