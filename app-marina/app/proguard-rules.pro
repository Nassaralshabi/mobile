# القواعد الموجودة
-dontwarn org.codehaus.mojo.animal_sniffer.*
-dontwarn javax.annotation.**
-dontwarn kotlin.reflect.jvm.internal.impl.**

# إضافات جديدة
# Retrofit
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# Room
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-keep @androidx.room.Dao class *
-dontwarn androidx.room.paging.**

# Moshi
-keepclasseswithmembers class * {
    @com.squareup.moshi.* <methods>;
}
-keep @com.squareup.moshi.JsonClass class * { *; }

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
