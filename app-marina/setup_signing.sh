#!/bin/bash
echo "إعداد ملف التوقيع..."
mkdir -p keystore
cat > key.properties << EOF
storeFile=keystore/marina-hotel-keystore.jks
storePassword=Marina2024!SecureKey789
keyAlias=marina-hotel-key
keyPassword=HotelApp@2024#Strong456
EOF
echo "تم إعداد ملف التوقيع!"