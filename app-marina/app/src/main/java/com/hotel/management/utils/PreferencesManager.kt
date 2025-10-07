package com.hotel.management.utils

import android.content.Context
import android.content.SharedPreferences
import androidx.core.content.edit

class PreferencesManager(context: Context) {

    private val preferences: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    var authToken: String?
        get() = preferences.getString(KEY_AUTH_TOKEN, null)
        set(value) = preferences.edit { putString(KEY_AUTH_TOKEN, value) }

    var lastSyncTimestamp: Long
        get() = preferences.getLong(KEY_LAST_SYNC, 0L)
        set(value) = preferences.edit { putLong(KEY_LAST_SYNC, value) }

    var rememberUser: Boolean
        get() = preferences.getBoolean(KEY_REMEMBER_USER, false)
        set(value) = preferences.edit { putBoolean(KEY_REMEMBER_USER, value) }

    fun incrementFailedLoginAttempts(): Int {
        val current = preferences.getInt(KEY_FAILED_ATTEMPTS, 0) + 1
        preferences.edit { putInt(KEY_FAILED_ATTEMPTS, current) }
        return current
    }

    fun resetFailedLoginAttempts() {
        preferences.edit { putInt(KEY_FAILED_ATTEMPTS, 0) }
    }

    fun getFailedLoginAttempts(): Int = preferences.getInt(KEY_FAILED_ATTEMPTS, 0)

    fun clearAll() {
        preferences.edit { clear() }
    }

    companion object {
        private const val PREFS_NAME = "hotel_management_prefs"
        private const val KEY_AUTH_TOKEN = "key_auth_token"
        private const val KEY_LAST_SYNC = "key_last_sync"
        private const val KEY_REMEMBER_USER = "key_remember_user"
        private const val KEY_FAILED_ATTEMPTS = "key_failed_attempts"
    }
}
