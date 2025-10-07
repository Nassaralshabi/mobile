package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.PaymentEntity
import com.hotel.management.repository.PaymentRepository
import java.time.LocalDate
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn

class PaymentsViewModel(private val paymentRepository: PaymentRepository) : ViewModel() {

    private val methodFilter = MutableStateFlow<String?>(null)
    private val revenueFilter = MutableStateFlow<String?>(null)
    private val dateRange = MutableStateFlow<Pair<LocalDate?, LocalDate?>>(null to null)

    private val paymentsFlow = paymentRepository.observePayments()

    private val filteredPayments = combine(paymentsFlow, methodFilter, revenueFilter, dateRange) { payments, method, revenue, range ->
        payments.filter { payment ->
            val methodMatches = method?.let { payment.paymentMethod == it } ?: true
            val revenueMatches = revenue?.let { payment.revenueType == it } ?: true
            val dateMatches = range.let { (start, end) ->
                when {
                    start != null && end != null -> !payment.paymentDate.isBefore(start) && !payment.paymentDate.isAfter(end)
                    start != null -> !payment.paymentDate.isBefore(start)
                    end != null -> !payment.paymentDate.isAfter(end)
                    else -> true
                }
            }
            methodMatches && revenueMatches && dateMatches
        }
    }.stateIn(viewModelScope, kotlinx.coroutines.flow.SharingStarted.WhileSubscribed(5_000), emptyList())

    val payments: LiveData<List<PaymentEntity>> = filteredPayments.asLiveData()

    fun setMethodFilter(method: String?) {
        methodFilter.value = method
    }

    fun setRevenueFilter(revenue: String?) {
        revenueFilter.value = revenue
    }

    fun setDateRange(start: LocalDate?, end: LocalDate?) {
        dateRange.value = start to end
    }
}
