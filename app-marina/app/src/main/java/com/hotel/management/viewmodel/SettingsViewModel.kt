package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.UserEntity
import com.hotel.management.repository.UserRepository
import com.hotel.management.utils.PreferencesManager
import com.hotel.management.utils.Result
import kotlinx.coroutines.launch

class SettingsViewModel(
    private val preferencesManager: PreferencesManager,
    private val userRepository: UserRepository
) : ViewModel() {

    val users: LiveData<List<UserEntity>> = userRepository.observeUsers().asLiveData()

    private val _passwordChangeState = MutableLiveData<Result<Boolean>>()
    val passwordChangeState: LiveData<Result<Boolean>> = _passwordChangeState

    val rememberUser: Boolean
        get() = preferencesManager.rememberUser

    fun changePassword(userId: Long, newPassword: String) {
        _passwordChangeState.value = Result.Loading
        viewModelScope.launch {
            userRepository.updatePassword(userId, newPassword)
            _passwordChangeState.value = Result.Success(true)
        }
    }

    fun toggleRememberUser(enabled: Boolean) {
        preferencesManager.rememberUser = enabled
    }

    fun logout() {
        preferencesManager.clearAll()
    }
}
