package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.hotel.management.repository.UserRepository
import com.hotel.management.utils.PreferencesManager
import com.hotel.management.utils.Result
import kotlinx.coroutines.launch

class AuthViewModel(
    private val userRepository: UserRepository,
    private val preferencesManager: PreferencesManager
) : ViewModel() {

    private val _loginState = MutableLiveData<Result<Boolean>>()
    val loginState: LiveData<Result<Boolean>> = _loginState

    val failedAttempts: Int
        get() = preferencesManager.getFailedLoginAttempts()

    fun login(username: String, password: String, rememberUser: Boolean) {
        _loginState.value = Result.Loading
        viewModelScope.launch {
            val success = userRepository.authenticate(username, password)
            if (success) {
                preferencesManager.rememberUser = rememberUser
                preferencesManager.resetFailedLoginAttempts()
                _loginState.value = Result.Success(true)
            } else {
                preferencesManager.incrementFailedLoginAttempts()
                _loginState.value = Result.Success(false)
            }
        }
    }

    fun logout() {
        preferencesManager.clearAll()
    }
}
