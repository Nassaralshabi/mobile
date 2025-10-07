package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.CashTransactionEntity
import com.hotel.management.models.EmployeeEntity
import com.hotel.management.repository.EmployeeRepository
import com.hotel.management.utils.Result
import kotlinx.coroutines.launch

class EmployeesViewModel(private val employeeRepository: EmployeeRepository) : ViewModel() {

    val employees: LiveData<List<EmployeeEntity>> = employeeRepository.observeEmployees().asLiveData()

    private val _operationState = MutableLiveData<Result<Long>>()
    val operationState: LiveData<Result<Long>> = _operationState

    fun withdrawals(employeeId: Long): LiveData<List<CashTransactionEntity>> =
        employeeRepository.observeWithdrawals(employeeId).asLiveData()

    fun saveEmployee(employee: EmployeeEntity) {
        viewModelScope.launch {
            _operationState.value = Result.Loading
            val id = employeeRepository.saveEmployee(employee)
            _operationState.value = Result.Success(id)
        }
    }

    fun recordWithdrawal(transaction: CashTransactionEntity) {
        viewModelScope.launch {
            _operationState.value = Result.Loading
            val id = employeeRepository.recordWithdrawal(transaction)
            _operationState.value = Result.Success(id)
        }
    }
}
