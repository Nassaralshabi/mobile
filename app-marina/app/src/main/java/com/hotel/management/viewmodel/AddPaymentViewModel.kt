package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.BookingEntity
import com.hotel.management.models.PaymentEntity
import com.hotel.management.repository.BookingRepository
import com.hotel.management.repository.PaymentRepository
import com.hotel.management.utils.Result
import kotlinx.coroutines.launch

class AddPaymentViewModel(
    private val paymentRepository: PaymentRepository,
    private val bookingRepository: BookingRepository
) : ViewModel() {

    val bookings: LiveData<List<BookingEntity>> = bookingRepository.observeBookings().asLiveData()

    private val _saveState = MutableLiveData<Result<Long>>()
    val saveState: LiveData<Result<Long>> = _saveState

    fun savePayment(payment: PaymentEntity) {
        _saveState.value = Result.Loading
        viewModelScope.launch {
            val id = paymentRepository.savePayment(payment)
            _saveState.value = Result.Success(id)
        }
    }
}
