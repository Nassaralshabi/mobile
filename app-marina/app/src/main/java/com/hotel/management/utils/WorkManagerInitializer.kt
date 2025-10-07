package com.hotel.management.utils

import android.app.Application
import android.util.Log
import androidx.work.Configuration

object WorkManagerInitializer {
    fun provideConfiguration(application: Application): Configuration {
        return Configuration.Builder()
            .setMinimumLoggingLevel(Log.INFO)
            .build()
    }
}
