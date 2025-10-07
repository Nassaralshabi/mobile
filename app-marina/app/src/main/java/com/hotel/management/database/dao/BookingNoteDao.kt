package com.hotel.management.database.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.hotel.management.models.BookingNoteEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface BookingNoteDao {

    @Query("SELECT * FROM booking_notes WHERE booking_id = :bookingId ORDER BY created_at DESC")
    fun observeNotesForBooking(bookingId: Long): Flow<List<BookingNoteEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(note: BookingNoteEntity): Long

    @Delete
    suspend fun delete(note: BookingNoteEntity)
}
