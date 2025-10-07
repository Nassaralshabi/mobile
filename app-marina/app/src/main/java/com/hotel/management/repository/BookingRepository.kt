package com.hotel.management.repository

import com.hotel.management.database.dao.BookingDao
import com.hotel.management.database.dao.BookingNoteDao
import com.hotel.management.models.BookingEntity
import com.hotel.management.models.BookingNoteEntity
import com.hotel.management.models.relations.BookingWithNotes
import com.hotel.management.utils.HotelApiService
import com.hotel.management.utils.Result
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart

class BookingRepository(
    private val bookingDao: BookingDao,
    private val noteDao: BookingNoteDao,
    private val apiService: HotelApiService
) {

    fun observeBookings(): Flow<List<BookingEntity>> = bookingDao.observeBookings()

    fun observeBookingsWithNotes(): Flow<List<BookingWithNotes>> = bookingDao.observeBookingsWithNotes()

    fun observeBookingsByStatus(status: String): Flow<List<BookingEntity>> = bookingDao.observeBookingsByStatus(status)

    fun searchBookings(query: String): Flow<List<BookingEntity>> = bookingDao.searchBookings(query)

    fun observeBookingDetails(bookingId: Long): Flow<Result<BookingWithNotes?>> = flow {
        try {
            bookingDao.observeBookingWithNotes(bookingId).collect { emit(Result.Success(it)) }
        } catch (ex: Exception) {
            emit(Result.Error(ex))
        }
    }.onStart { emit(Result.Loading) }

    suspend fun saveBooking(booking: BookingEntity): Long = bookingDao.upsert(booking)

    suspend fun addBookingNote(note: BookingNoteEntity): Long = noteDao.upsert(note)

    suspend fun findBooking(id: Long): BookingEntity? = bookingDao.findById(id)

    suspend fun deleteBooking(booking: BookingEntity) = bookingDao.delete(booking)

    suspend fun deleteNote(note: BookingNoteEntity) = noteDao.delete(note)

    suspend fun syncWithRemote() {
        val remoteBookings = try {
            apiService.fetchBookings()
        } catch (_: Exception) {
            emptyList()
        }
        remoteBookings.forEach { bookingDao.upsert(it) }
    }
}
