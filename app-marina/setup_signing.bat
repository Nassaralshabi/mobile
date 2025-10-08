@echo off
echo إعداد ملف التوقيع...
if not exist keystore mkdir keystore
echo storeFile=keystore/marina-hotel-keystore.jks > key.properties
echo storePassword=Marina2024!SecureKey789 >> key.properties  
echo keyAlias=marina-hotel-key >> key.properties
echo keyPassword=HotelApp@2024#Strong456 >> key.properties
echo تم إعداد ملف التوقيع!
pause