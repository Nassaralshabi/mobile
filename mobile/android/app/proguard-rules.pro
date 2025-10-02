# Marina Hotel Android App - ProGuard Rules

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart VM
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# SQLite and database related
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# HTTP and networking
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }

# JSON serialization
-keep class com.google.gson.** { *; }
-keep class com.fasterxml.jackson.** { *; }

# Connectivity and network state
-keep class android.net.** { *; }

# Shared preferences
-keep class android.content.SharedPreferences** { *; }

# Notifications
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class android.app.Notification** { *; }

# Work Manager (for background sync)
-keep class androidx.work.** { *; }

# Keep application class
-keep public class com.marinahotel.mobile.MainActivity { *; }
-keep public class com.marinahotel.mobile.MainApplication { *; }

# Keep custom classes (if any)
-keep class com.marinahotel.mobile.** { *; }

# Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Optimization settings
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Keep line numbers for debugging crashes
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
