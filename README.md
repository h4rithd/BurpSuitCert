# BurpSuiteCert Magisk Module

**Author**: [@h4rithd](https://github.com/h4rithd)  
**Version**: 1.0  
**Purpose**: Install the Burp Suite CA certificate into the Android system certificate store for full HTTPS interception.

---

## Description

`BurpSuiteCert` is a Magisk module that injects the Burp Suite CA certificate directly into the Android system key store, including the APEX `com.android.conscrypt` location (required from Android 10+ and especially Android 14).

This enables **system-wide trusted HTTPS interception** with Burp Suite, including for apps that use custom trust managers.

---

## Features

- Supports Android 10 to Android 14+
- Binds the modified CA certs into `/apex/com.android.conscrypt/cacerts`
- Automatically handles SELinux context
- Outputs log to `/data/local/tmp/BurpSuiteCert.log`

---

## Installation Steps
```
### Upload the zip file in to the magix using app or

#-----| Push the module zip to device
adb push BurpSuiteCert.zip /data/local/tmp/

#-----| Get root shell on device
adb shell
su

#-----| Install the module using Magisk command (Magisk 24+ supports this)
magisk --install-module /data/local/tmp/BurpSuiteCert.zip

#-----| Reboot device to activate the module
reboot

```
---

## Credits

Inspired by: [WindSpiritSR/CustomCACert](https://github.com/WindSpiritSR/CustomCACert)  

---

## Disclaimer

This module modifies system trust settings. Use only in **development** or **controlled environments**.

