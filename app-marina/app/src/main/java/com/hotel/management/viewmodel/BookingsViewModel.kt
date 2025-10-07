package com.hotel.management.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.hotel.management.models.BookingEntity
import com.hotel.management.models.relations.BookingWithNotes
import com.hotel.management.repository.BookingRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class BookingsViewModel(private val bookingRepository: BookingRepository) : ViewModel() {

    private val filterState = MutableStateFlow<String?>(null)
    private val searchState = MutableStateFlow("")

    private val bookingsFlow = bookingRepository.observeBookingsWithNotes()

    private val filteredFlow = combine(bookingsFlow, filterState, searchState) { bookings, filter, query ->
        bookings.filter { bookingWithNotes ->
            val matchesFilter = when (filter) {
                "inhouse" -> bookingWithNotes.booking.status in listOf("checked_in", "inhouse")
                "upcoming" -> bookingWithNotes.booking.status == "upcoming"
                "completed" -> bookingWithNotes.booking.status == "completed"
                "cancelled" -> bookingWithNotes.booking.status == "cancelled"
                else -> true
            }
            val matchesQuery = if (query.isBlank()) {
                true
            } else {
                val normalized = query.lowercase()
                listOf(
                    bookingWithNotes.booking.guestName,
                    bookingWithNotes.booking.guestPhone,
                    bookingWithNotes.booking.roomNumber.toString()
                ).any { it.lowercase().contains(normalized) }
            }
            matchesFilter && matchesQuery
        }
    }.stateIn(viewModelScope, kotlinx.coroutines.flow.SharingStarted.WhileSubscribed(5_000), emptyList())

    val bookings: LiveData<List<BookingWithNotes>> = filteredFlow.asLiveData()

    fun applyFilter(filter: String?) {
        filterState.value = filter
    }

    fun updateSearch(query: String) {
        searchState.value = query
    }

    fun saveBooking(booking: BookingEntity) {
        viewModelScope.launch {
            bookingRepository.saveBooking(booking)
        }
    }
}
