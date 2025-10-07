package com.hotel.management.ui.auth

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import com.hotel.management.HotelManagementApp
import com.hotel.management.databinding.ActivityLoginBinding
import com.hotel.management.ui.dashboard.MainActivity
import com.hotel.management.utils.Result
import com.hotel.management.viewmodel.AppViewModelFactory
import com.hotel.management.viewmodel.AuthViewModel

class LoginActivity : AppCompatActivity() {

    private lateinit var binding: ActivityLoginBinding
    private val viewModel: AuthViewModel by viewModels {
        AppViewModelFactory(application as HotelManagementApp)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)
        window.decorView.layoutDirection = View.LAYOUT_DIRECTION_RTL

        binding.loginButton.setOnClickListener {
            val username = binding.usernameInput.text?.toString().orEmpty()
            val password = binding.passwordInput.text?.toString().orEmpty()
            val remember = binding.rememberUser.isChecked
            viewModel.login(username, password, remember)
        }

        binding.failedAttempts.text = viewModel.failedAttempts.toString()

        viewModel.loginState.observe(this) { state ->
            when (state) {
                is Result.Loading -> binding.loginProgress.visibility = View.VISIBLE
                is Result.Success -> {
                    binding.loginProgress.visibility = View.GONE
                    binding.failedAttempts.text = viewModel.failedAttempts.toString()
                    if (state.data) {
                        startActivity(Intent(this, MainActivity::class.java))
                        finish()
                    }
                }
                is Result.Error -> {
                    binding.loginProgress.visibility = View.GONE
                }
            }
        }
    }
}
