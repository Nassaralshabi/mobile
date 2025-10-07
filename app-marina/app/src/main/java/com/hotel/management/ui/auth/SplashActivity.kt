package com.hotel.management.ui.auth

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.hotel.management.HotelManagementApp
import com.hotel.management.ui.dashboard.MainActivity

class SplashActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val app = application as HotelManagementApp
        val target = if (app.preferencesManager.rememberUser) {
            MainActivity::class.java
        } else {
            LoginActivity::class.java
        }
        startActivity(Intent(this, target))
        finish()
    }
}
