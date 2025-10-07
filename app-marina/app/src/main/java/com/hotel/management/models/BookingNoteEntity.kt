package com.hotel.management.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.Instant
import java.time.LocalDateTime

@Entity(
    tableName = "booking_notes",
    foreignKeys = [
        ForeignKey(
            entity = BookingEntity::class,
            parentColumns = ["id"],
            childColumns = ["booking_id"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["booking_id"])]
)
data class BookingNoteEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0L,
    @ColumnInfo(name = "booking_id")
    val bookingId: Long,
    @ColumnInfo(name = "note")
    val note: String,
    @ColumnInfo(name = "alert_type")
    val alertType: String,
    @ColumnInfo(name = "alert_until")
    val alertUntil: LocalDateTime? = null,
    @ColumnInfo(name = "added_by")
    val addedBy: String,
    @ColumnInfo(name = "created_at")
    val createdAt: Instant? = null
)
