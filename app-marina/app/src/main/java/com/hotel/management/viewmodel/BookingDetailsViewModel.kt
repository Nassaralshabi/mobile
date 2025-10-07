package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.BookingEntity
import com.hotel.management.models.BookingNoteEntity
import com.hotel.management.repository.BookingRepository
import com.hotel.management.utils.Result
import kotlinx.coroutines.launch

class BookingDetailsViewModel(private val bookingRepository: BookingRepository) : ViewModel() {

    fun bookingDetails(bookingId: Long): LiveData<Result<com.hotel.management.models.relations.BookingWithNotes?>> =
        bookingRepository.observeBookingDetails(bookingId).asLiveData()

    fun updateStatus(booking: BookingEntity, status: String) {
        viewModelScope.launch {
            bookingRepository.saveBooking(booking.copy(status = status))
        }
    }

    fun addNote(note: BookingNoteEntity) {
        viewModelScope.launch {
            bookingRepository.addBookingNote(note)
        }
    }
}
