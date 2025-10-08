#!/bin/bash
echo "إنشاء keystore جديد للتوقيع..."
keytool -genkey -v -keystore keystore/marina-hotel-keystore.jks -alias marina-hotel-key -keyalg RSA -keysize 2048 -validity 9125 -storepass Marina2024!SecureKey789 -keypass HotelApp@2024#Strong456 -dname "CN=Marina Hotel App, OU=IT Department, O=Marina Hotel, L=Riyadh, ST=Riyadh, C=SA"
echo "تم إنشاء keystore بنجاح!"