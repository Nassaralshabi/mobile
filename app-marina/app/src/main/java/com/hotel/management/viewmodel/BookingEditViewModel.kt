package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.BookingEntity
import com.hotel.management.repository.BookingRepository
import com.hotel.management.repository.RoomRepository
import com.hotel.management.utils.Result
import java.time.LocalDate
import java.time.temporal.ChronoUnit
import kotlinx.coroutines.launch

class BookingEditViewModel(
    private val bookingRepository: BookingRepository,
    private val roomRepository: RoomRepository
) : ViewModel() {

    val rooms = roomRepository.observeRooms().asLiveData()

    private val _saveState = MutableLiveData<Result<Long>>()
    val saveState: LiveData<Result<Long>> = _saveState

    private val _editingBooking = MutableLiveData<BookingEntity?>()
    val editingBooking: LiveData<BookingEntity?> = _editingBooking

    fun loadBooking(id: Long) {
        viewModelScope.launch {
            _editingBooking.value = bookingRepository.findBooking(id)
        }
    }

    fun calculateNights(checkIn: LocalDate, checkOut: LocalDate): Int {
        return ChronoUnit.DAYS.between(checkIn, checkOut).toInt().coerceAtLeast(0)
    }

    fun saveBooking(booking: BookingEntity) {
        _saveState.value = Result.Loading
        viewModelScope.launch {
            val id = bookingRepository.saveBooking(booking)
            _saveState.value = Result.Success(id)
        }
    }
}
