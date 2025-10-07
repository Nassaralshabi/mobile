package com.hotel.management.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import com.hotel.management.models.BookingEntity
import com.hotel.management.models.relations.BookingWithNotes
import kotlinx.coroutines.flow.Flow

@Dao
interface BookingDao {

    @Query("SELECT * FROM bookings ORDER BY check_in_date DESC")
    fun observeBookings(): Flow<List<BookingEntity>>

    @Transaction
    @Query("SELECT * FROM bookings ORDER BY check_in_date DESC")
    fun observeBookingsWithNotes(): Flow<List<BookingWithNotes>>

    @Query("SELECT * FROM bookings WHERE status = :status ORDER BY check_in_date DESC")
    fun observeBookingsByStatus(status: String): Flow<List<BookingEntity>>

    @Query("SELECT * FROM bookings WHERE guest_name LIKE '%' || :query || '%' OR guest_phone LIKE '%' || :query || '%' OR room_number LIKE '%' || :query || '%'")
    fun searchBookings(query: String): Flow<List<BookingEntity>>

    @Transaction
    @Query("SELECT * FROM bookings WHERE id = :bookingId")
    fun observeBookingWithNotes(bookingId: Long): Flow<BookingWithNotes?>

    @Query("SELECT * FROM bookings WHERE id = :id LIMIT 1")
    suspend fun findById(id: Long): BookingEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(booking: BookingEntity): Long

    @Update
    suspend fun update(booking: BookingEntity)

    @Delete
    suspend fun delete(booking: BookingEntity)
}
