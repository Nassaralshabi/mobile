package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.ExpenseEntity
import com.hotel.management.models.SupplierEntity
import com.hotel.management.repository.ExpenseRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn

class ExpensesViewModel(private val expenseRepository: ExpenseRepository) : ViewModel() {

    private val categoryFilter = MutableStateFlow<String?>(null)
    private val supplierFilter = MutableStateFlow<Long?>(null)

    private val expensesFlow = expenseRepository.observeExpenses()
    private val suppliersFlow = expenseRepository.observeSuppliers()

    private val filteredExpenses = combine(expensesFlow, categoryFilter, supplierFilter) { expenses, category, supplierId ->
        expenses.filter { expense ->
            val categoryMatches = category?.let { expense.category == it } ?: true
            val supplierMatches = supplierId?.let { expense.supplierId == it } ?: true
            categoryMatches && supplierMatches
        }
    }.stateIn(viewModelScope, kotlinx.coroutines.flow.SharingStarted.WhileSubscribed(5_000), emptyList())

    val expenses: LiveData<List<ExpenseEntity>> = filteredExpenses.asLiveData()
    val suppliers: LiveData<List<SupplierEntity>> = suppliersFlow.asLiveData()

    fun setCategoryFilter(category: String?) {
        categoryFilter.value = category
    }

    fun setSupplierFilter(id: Long?) {
        supplierFilter.value = id
    }
}
