package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.CashRegisterEntity
import com.hotel.management.models.CashTransactionEntity
import com.hotel.management.repository.CashRegisterRepository
import com.hotel.management.utils.Result
import kotlinx.coroutines.launch

class CashRegisterViewModel(private val cashRegisterRepository: CashRegisterRepository) : ViewModel() {

    val latestRegister: LiveData<CashRegisterEntity?> = cashRegisterRepository.observeLatestOpenRegister().asLiveData()

    private val _operationState = MutableLiveData<Result<Long>>()
    val operationState: LiveData<Result<Long>> = _operationState

    fun registerTransactions(registerId: Long): LiveData<List<CashTransactionEntity>> =
        cashRegisterRepository.observeTransactions(registerId).asLiveData()

    fun openRegister(register: CashRegisterEntity) {
        _operationState.value = Result.Loading
        viewModelScope.launch {
            val id = cashRegisterRepository.openRegister(register)
            _operationState.value = Result.Success(id)
        }
    }

    fun updateRegister(register: CashRegisterEntity) {
        viewModelScope.launch {
            cashRegisterRepository.updateRegister(register)
        }
    }

    fun addTransaction(transaction: CashTransactionEntity) {
        _operationState.value = Result.Loading
        viewModelScope.launch {
            val id = cashRegisterRepository.addTransaction(transaction)
            _operationState.value = Result.Success(id)
        }
    }
}
