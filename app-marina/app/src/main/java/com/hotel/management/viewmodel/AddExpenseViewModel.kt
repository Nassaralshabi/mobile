package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.ExpenseEntity
import com.hotel.management.models.SupplierEntity
import com.hotel.management.repository.ExpenseRepository
import com.hotel.management.utils.Result
import kotlinx.coroutines.launch

class AddExpenseViewModel(private val expenseRepository: ExpenseRepository) : ViewModel() {

    val suppliers: LiveData<List<SupplierEntity>> = expenseRepository.observeSuppliers().asLiveData()

    private val _saveState = MutableLiveData<Result<Long>>()
    val saveState: LiveData<Result<Long>> = _saveState

    fun saveExpense(expense: ExpenseEntity) {
        _saveState.value = Result.Loading
        viewModelScope.launch {
            val id = expenseRepository.saveExpense(expense)
            _saveState.value = Result.Success(id)
        }
    }

    fun saveSupplier(supplier: SupplierEntity) {
        viewModelScope.launch {
            expenseRepository.saveSupplier(supplier)
        }
    }
}
