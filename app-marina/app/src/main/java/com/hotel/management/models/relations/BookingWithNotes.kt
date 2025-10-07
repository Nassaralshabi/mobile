package com.hotel.management.models.relations

import androidx.room.Embedded
import androidx.room.Relation
import com.hotel.management.models.BookingEntity
import com.hotel.management.models.BookingNoteEntity

data class BookingWithNotes(
    @Embedded val booking: BookingEntity,
    @Relation(
        parentColumn = "id",
        entityColumn = "booking_id"
    )
    val notes: List<BookingNoteEntity>
)
