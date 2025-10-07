package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.InvoiceEntity
import com.hotel.management.repository.InvoiceRepository
import com.hotel.management.utils.Result
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class InvoicesViewModel(private val invoiceRepository: InvoiceRepository) : ViewModel() {

    private val statusFilter = MutableStateFlow<String?>(null)
    private val invoicesFlow = invoiceRepository.observeInvoices()

    private val filteredFlow = combine(invoicesFlow, statusFilter) { invoices, status ->
        status?.let { invoices.filter { it.status == status } } ?: invoices
    }.stateIn(viewModelScope, kotlinx.coroutines.flow.SharingStarted.WhileSubscribed(5_000), emptyList())

    val invoices: LiveData<List<InvoiceEntity>> = filteredFlow.asLiveData()

    private val _operationState = MutableLiveData<Result<Long>>()
    val operationState: LiveData<Result<Long>> = _operationState

    fun setStatusFilter(status: String?) {
        statusFilter.value = status
    }

    fun saveInvoice(invoice: InvoiceEntity) {
        viewModelScope.launch {
            _operationState.value = Result.Loading
            val id = invoiceRepository.saveInvoice(invoice)
            _operationState.value = Result.Success(id)
        }
    }
}
